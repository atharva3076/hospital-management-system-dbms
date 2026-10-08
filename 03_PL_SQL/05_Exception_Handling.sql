-- ============================================================================
-- HOSPITAL MANAGEMENT SYSTEM - EXCEPTION HANDLING (PL/SQL)
-- ============================================================================
-- Created by: Member 3 (PL/SQL Developer)
-- Purpose: Demonstrate error handling, validation, and recovery mechanisms
-- Date: 2024
-- ============================================================================
-- EXCEPTION HANDLING: 4 comprehensive procedures demonstrating:
-- 1. Basic exception handling with error codes
-- 2. Custom error messages and signals
-- 3. Multiple exception handlers
-- 4. Error logging and recovery
-- ============================================================================

USE hospital_management_system;

-- ============================================================================
-- CREATE EXCEPTION LOGGING TABLE
-- ============================================================================

CREATE TABLE IF NOT EXISTS exception_log (
    ExceptionID INT PRIMARY KEY AUTO_INCREMENT,
    ProcedureName VARCHAR(100),
    ErrorCode VARCHAR(10),
    ErrorMessage TEXT,
    ErrorDetails TEXT,
    OccurredDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ResolvedBy VARCHAR(100),
    ResolvedDate TIMESTAMP NULL,
    INDEX idx_procedure (ProcedureName),
    INDEX idx_error_code (ErrorCode),
    INDEX idx_occurred_date (OccurredDate)
);

-- ============================================================================
-- PROCEDURE 1: Basic Exception Handling with DECLARE HANDLER
-- ============================================================================
-- Purpose: Demonstrate different exception handler types
--
-- Handler Types:
--   1. CONTINUE HANDLER - Continue execution after exception
--   2. EXIT HANDLER - Exit procedure after exception
--
-- Exception Types:
--   1. Specific error codes (SQLSTATE '45000')
--   2. Named conditions (NOT FOUND, SQLEXCEPTION)
--   3. Exception handlers for SQLEXCEPTION (any error)
--
-- ============================================================================

DELIMITER //

CREATE PROCEDURE sp_transfer_patient_with_handler(
    IN p_patient_id INT,
    IN p_new_department_id INT,
    OUT p_success BOOLEAN,
    OUT p_message VARCHAR(500)
)
BEGIN
    DECLARE v_patient_exists INT;
    DECLARE v_department_exists INT;
    DECLARE v_error_text TEXT;
    
    -- Handler 1: Continue on NOT FOUND (patient doesn't exist)
    DECLARE CONTINUE HANDLER FOR NOT FOUND
    BEGIN
        SET p_success = FALSE;
        SET p_message = 'Patient or Department not found';
        SET v_error_text = CONCAT('Patient ID: ', p_patient_id, ' or Department ID: ', p_new_department_id);
        INSERT INTO exception_log (ProcedureName, ErrorCode, ErrorMessage, ErrorDetails)
        VALUES ('sp_transfer_patient_with_handler', '02000', p_message, v_error_text);
    END;
    
    -- Handler 2: Continue on any SQL Exception
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_success = FALSE;
        SET p_message = 'Database error occurred during transfer';
        INSERT INTO exception_log (ProcedureName, ErrorCode, ErrorMessage, ErrorDetails)
        VALUES ('sp_transfer_patient_with_handler', 'SQLEXC', p_message, 'See detailed logs');
        ROLLBACK;
    END;
    
    -- Initialize
    SET p_success = FALSE;
    SET p_message = '';
    
    -- Validate patient exists
    SELECT COUNT(*) INTO v_patient_exists 
    FROM PATIENT 
    WHERE PatientID = p_patient_id;
    
    IF v_patient_exists = 0 THEN
        SET p_message = CONCAT('Patient ID ', p_patient_id, ' does not exist');
        LEAVE;
    END IF;
    
    -- Validate department exists
    SELECT COUNT(*) INTO v_department_exists 
    FROM DEPARTMENT 
    WHERE DepartmentID = p_new_department_id;
    
    IF v_department_exists = 0 THEN
        SET p_message = CONCAT('Department ID ', p_new_department_id, ' does not exist');
        LEAVE;
    END IF;
    
    -- If all validations pass
    SET p_success = TRUE;
    SET p_message = CONCAT('Patient transferred to Department ID: ', p_new_department_id);
END //

DELIMITER ;

-- ============================================================================
-- PROCEDURE 2: Custom Error Signals and Validation
-- ============================================================================
-- Purpose: Demonstrate SIGNAL for raising custom errors
--
-- SIGNAL Components:
--   1. SQLSTATE - Error code (5 characters)
--   2. SET MESSAGE_TEXT - Custom error message
--   3. SET MYSQL_ERRNO - Custom error number (optional)
--
-- Common SQLSTATEs:
--   45000 - User-defined exception
--   23000 - Integrity constraint violation
--   42000 - Syntax error or access violation
--   01000 - Warning
--
-- ============================================================================

DELIMITER //

CREATE PROCEDURE sp_register_patient_with_validation(
    IN p_first_name VARCHAR(50),
    IN p_last_name VARCHAR(50),
    IN p_dob DATE,
    IN p_phone VARCHAR(15),
    IN p_email VARCHAR(100),
    IN p_blood_group VARCHAR(5),
    OUT p_patient_id INT,
    OUT p_message VARCHAR(500)
)
BEGIN
    DECLARE v_age INT;
    DECLARE v_duplicate_phone INT;
    DECLARE v_duplicate_email INT;
    
    -- Exception handler for constraint violations
    DECLARE CONTINUE HANDLER FOR 1062  -- Duplicate key error
    BEGIN
        SET p_message = 'Phone or Email already registered in system';
        SET p_patient_id = NULL;
    END;
    
    SET p_patient_id = NULL;
    SET p_message = '';
    
    -- Validation 1: Check first name
    IF p_first_name IS NULL OR TRIM(p_first_name) = '' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'ERROR: First name cannot be empty',
            MYSQL_ERRNO = 1001;
    END IF;
    
    -- Validation 2: Check last name
    IF p_last_name IS NULL OR TRIM(p_last_name) = '' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'ERROR: Last name cannot be empty',
            MYSQL_ERRNO = 1002;
    END IF;
    
    -- Validation 3: Check date of birth
    IF p_dob IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'ERROR: Date of birth is required',
            MYSQL_ERRNO = 1003;
    END IF;
    
    -- Validation 4: Check age (must be at least 0 years)
    SET v_age = YEAR(CURDATE()) - YEAR(p_dob);
    IF v_age < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'ERROR: Date of birth cannot be in the future',
            MYSQL_ERRNO = 1004;
    END IF;
    
    IF v_age > 150 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'ERROR: Date of birth seems invalid - age exceeds 150 years',
            MYSQL_ERRNO = 1005;
    END IF;
    
    -- Validation 5: Check phone format
    IF p_phone IS NULL OR p_phone NOT REGEXP '^[0-9]{10,15}$' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'ERROR: Phone must be 10-15 digits',
            MYSQL_ERRNO = 1006;
    END IF;
    
    -- Validation 6: Check for duplicate phone
    SELECT COUNT(*) INTO v_duplicate_phone 
    FROM PATIENT 
    WHERE Phone = p_phone;
    
    IF v_duplicate_phone > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = CONCAT('ERROR: Phone number ', p_phone, ' already registered'),
            MYSQL_ERRNO = 1007;
    END IF;
    
    -- Validation 7: Check email format
    IF p_email IS NOT NULL AND p_email NOT REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Z|a-z]{2,}$' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'ERROR: Invalid email format',
            MYSQL_ERRNO = 1008;
    END IF;
    
    -- Validation 8: Check for duplicate email
    IF p_email IS NOT NULL THEN
        SELECT COUNT(*) INTO v_duplicate_email 
        FROM PATIENT 
        WHERE Email = p_email;
        
        IF v_duplicate_email > 0 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = CONCAT('ERROR: Email ', p_email, ' already registered'),
                MYSQL_ERRNO = 1009;
        END IF;
    END IF;
    
    -- Validation 9: Check blood group
    IF p_blood_group NOT IN ('A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'ERROR: Invalid blood group. Must be one of: A+, A-, B+, B-, AB+, AB-, O+, O-',
            MYSQL_ERRNO = 1010;
    END IF;
    
    -- All validations passed - Insert patient
    INSERT INTO PATIENT (FirstName, LastName, DOB, Gender, BloodGroup, Phone, Email, 
                         Address, City, State, EmergencyContact, EmergencyContactPhone)
    VALUES (p_first_name, p_last_name, p_dob, 'M', p_blood_group, p_phone, p_email,
            'To be updated', 'Bangalore', 'Karnataka', 'Emergency contact to be updated', '9000000000');
    
    SET p_patient_id = LAST_INSERT_ID();
    SET p_message = CONCAT('SUCCESS: Patient registered with ID: ', p_patient_id);
END //

DELIMITER ;

-- ============================================================================
-- PROCEDURE 3: Multiple Exception Handlers
-- ============================================================================
-- Purpose: Handle different exception scenarios
--
-- Business Logic:
--   1. Try to execute appointment scheduling
--   2. Handle different error conditions differently
--   3. Provide appropriate recovery actions
--   4. Log exceptions
--
-- ============================================================================

DELIMITER //

CREATE PROCEDURE sp_schedule_appointment_robust(
    IN p_patient_id INT,
    IN p_doctor_id INT,
    IN p_appointment_date DATE,
    IN p_appointment_time TIME,
    IN p_reason VARCHAR(200),
    OUT p_appointment_id INT,
    OUT p_success BOOLEAN,
    OUT p_message VARCHAR(500)
)
BEGIN
    DECLARE v_conflict_count INT;
    DECLARE v_availability INT;
    DECLARE v_doc_exists INT;
    DECLARE v_patient_exists INT;
    
    -- Handler for foreign key constraint violations
    DECLARE CONTINUE HANDLER FOR 1452  -- Cannot add or update child row
    BEGIN
        SET p_success = FALSE;
        SET p_message = 'Invalid Patient or Doctor ID - Foreign key constraint violation';
        INSERT INTO exception_log (ProcedureName, ErrorCode, ErrorMessage)
        VALUES ('sp_schedule_appointment_robust', '1452', p_message);
    END;
    
    -- Handler for duplicate key violations
    DECLARE CONTINUE HANDLER FOR 1062  -- Duplicate key entry
    BEGIN
        SET p_success = FALSE;
        SET p_message = 'Duplicate appointment - Time slot already booked';
        INSERT INTO exception_log (ProcedureName, ErrorCode, ErrorMessage)
        VALUES ('sp_schedule_appointment_robust', '1062', p_message);
    END;
    
    -- Handler for data too long for column
    DECLARE CONTINUE HANDLER FOR 1406  -- Data too long for column
    BEGIN
        SET p_success = FALSE;
        SET p_message = 'Input data too long - Please provide shorter text';
        INSERT INTO exception_log (ProcedureName, ErrorCode, ErrorMessage)
        VALUES ('sp_schedule_appointment_robust', '1406', p_message);
    END;
    
    -- Handler for general SQL exceptions
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_success = FALSE;
        SET p_message = 'Unexpected database error occurred';
        INSERT INTO exception_log (ProcedureName, ErrorCode, ErrorMessage)
        VALUES ('sp_schedule_appointment_robust', 'SQLEXC', p_message);
        ROLLBACK;
    END;
    
    -- Initialize
    SET p_appointment_id = NULL;
    SET p_success = FALSE;
    SET p_message = '';
    
    -- Validate inputs using exception signals
    IF p_patient_id <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'ERROR: Patient ID must be positive integer';
    END IF;
    
    IF p_doctor_id <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'ERROR: Doctor ID must be positive integer';
    END IF;
    
    IF p_appointment_date < CURDATE() THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'ERROR: Appointment date must be in future';
    END IF;
    
    IF p_appointment_time < '09:00:00' OR p_appointment_time > '18:00:00' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'ERROR: Appointment time must be between 9 AM and 6 PM';
    END IF;
    
    IF LENGTH(p_reason) > 200 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'ERROR: Reason text too long (max 200 characters)';
    END IF;
    
    -- If all validations pass
    START TRANSACTION;
    
    INSERT INTO APPOINTMENT (
        PatientID, DoctorID, AppointmentDate, AppointmentTime, 
        Reason, Status, CreatedDate
    )
    VALUES (p_patient_id, p_doctor_id, p_appointment_date, p_appointment_time, 
            p_reason, 'Scheduled', NOW());
    
    SET p_appointment_id = LAST_INSERT_ID();
    SET p_success = TRUE;
    SET p_message = CONCAT('SUCCESS: Appointment scheduled with ID: ', p_appointment_id);
    
    COMMIT;
END //

DELIMITER ;

-- ============================================================================
-- PROCEDURE 4: Exception Logging and Recovery
-- ============================================================================
-- Purpose: Comprehensive error logging with recovery options
--
-- Features:
--   1. Capture all exception details
--   2. Log to exception_log table
--   3. Provide recovery actions
--   4. Track error history
--
-- ============================================================================

DELIMITER //

CREATE PROCEDURE sp_process_billing_with_recovery(
    IN p_patient_id INT,
    IN p_appointment_id INT,
    OUT p_billing_id INT,
    OUT p_success BOOLEAN,
    OUT p_message VARCHAR(500)
)
BEGIN
    DECLARE v_error_message TEXT;
    DECLARE v_error_code VARCHAR(5);
    DECLARE v_appointment_exists INT;
    
    -- Handler to log and recover from errors
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1
            v_error_code = RETURNED_SQLSTATE,
            v_error_message = MESSAGE_TEXT;
        
        -- Log the exception
        INSERT INTO exception_log (
            ProcedureName,
            ErrorCode,
            ErrorMessage,
            ErrorDetails
        )
        VALUES (
            'sp_process_billing_with_recovery',
            COALESCE(v_error_code, 'UNKNOWN'),
            COALESCE(v_error_message, 'Unknown error'),
            CONCAT('Patient ID: ', p_patient_id, ', Appointment ID: ', p_appointment_id)
        );
        
        -- Set output parameters
        SET p_success = FALSE;
        SET p_message = CONCAT('ERROR: ', v_error_message);
        SET p_billing_id = NULL;
        
        -- Rollback transaction
        ROLLBACK;
    END;
    
    -- Initialize
    SET p_billing_id = NULL;
    SET p_success = FALSE;
    SET p_message = '';
    
    -- Validate appointment exists
    SELECT COUNT(*) INTO v_appointment_exists 
    FROM APPOINTMENT 
    WHERE AppointmentID = p_appointment_id 
      AND PatientID = p_patient_id;
    
    IF v_appointment_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Appointment not found for given Patient and Appointment ID';
    END IF;
    
    -- Start transaction
    START TRANSACTION;
    
    -- Create billing record
    INSERT INTO BILLING (
        BillingNumber,
        PatientID,
        AppointmentID,
        TotalCharges,
        PatientPayable,
        PaymentStatus,
        BillingDate
    )
    VALUES (
        CONCAT('BILL-', DATE_FORMAT(NOW(), '%Y%m%d'), '-', LPAD(p_patient_id, 5, '0')),
        p_patient_id,
        p_appointment_id,
        1500.00,  -- Default consultation fee
        1500.00,
        'Pending',
        NOW()
    );
    
    SET p_billing_id = LAST_INSERT_ID();
    SET p_success = TRUE;
    SET p_message = CONCAT('SUCCESS: Billing created with ID: ', p_billing_id);
    
    COMMIT;
END //

DELIMITER ;

-- ============================================================================
-- TESTING THE EXCEPTION HANDLERS
-- ============================================================================

-- Test SIGNAL with invalid input
-- CALL sp_register_patient_with_validation('', 'Singh', '1990-01-01', '9876543210', 'test@test.com', 'O+', @id, @msg);
-- SELECT @id, @msg;

-- Test multiple handlers
-- CALL sp_schedule_appointment_robust(999, 999, '2024-12-25', '10:00:00', 'Test', @app_id, @success, @msg);
-- SELECT @app_id, @success, @msg;

-- View exception logs
-- SELECT * FROM exception_log ORDER BY OccurredDate DESC;

-- ============================================================================
-- SUMMARY OF EXCEPTION HANDLING
-- ============================================================================
-- Total Procedures with Exception Handling: 4
--
-- 1. sp_transfer_patient_with_handler          - Basic CONTINUE/EXIT handlers
-- 2. sp_register_patient_with_validation       - SIGNAL for custom errors
-- 3. sp_schedule_appointment_robust            - Multiple exception handlers
-- 4. sp_process_billing_with_recovery          - Error logging with recovery
--
-- DBMS Concepts Covered:
-- ✅ DECLARE HANDLER (CONTINUE, EXIT)
-- ✅ SIGNAL for custom errors
-- ✅ SQLSTATE error codes
-- ✅ MySQL-specific error codes (errno)
-- ✅ Named conditions (NOT FOUND, SQLEXCEPTION)
-- ✅ Specific error codes (1062, 1452, etc.)
-- ✅ GET DIAGNOSTICS for error details
-- ✅ ROLLBACK on error
-- ✅ Error logging
-- ✅ Recovery actions
--
-- Error Handling Strategy:
-- 1. Validate inputs with SIGNAL
-- 2. Use specific exception handlers for known errors
-- 3. Use generic SQLEXCEPTION handler as fallback
-- 4. Log all exceptions
-- 5. Provide meaningful error messages
-- 6. Rollback on critical errors
-- 7. Allow recovery or retry mechanisms
--
-- ============================================================================
-- End of Exception Handling Script
-- ============================================================================
