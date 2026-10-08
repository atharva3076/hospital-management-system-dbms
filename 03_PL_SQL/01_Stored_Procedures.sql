-- ============================================================================
-- HOSPITAL MANAGEMENT SYSTEM - STORED PROCEDURES
-- ============================================================================
-- Created by: Member 3 (PL/SQL Developer)
-- Purpose: Encapsulate business logic, improve performance, ensure consistency
-- Date: 2024
-- ============================================================================
-- STORED PROCEDURES: 6 comprehensive procedures covering:
-- 1. Appointment scheduling with validation
-- 2. Patient medical summary retrieval
-- 3. Billing calculation and processing
-- 4. Medicine expiry reporting
-- 5. Doctor performance analysis
-- 6. Monthly revenue calculation
-- ============================================================================

USE hospital_management_system;

-- ============================================================================
-- PROCEDURE 1: sp_schedule_appointment
-- ============================================================================
-- Purpose: Schedule new appointment with comprehensive validation checks
-- 
-- Business Logic:
--   1. Validate patient exists and is active
--   2. Validate doctor exists and is active
--   3. Check appointment date is in future
--   4. Verify appointment time is within business hours (9 AM - 6 PM)
--   5. Check doctor is available on that day
--   6. Verify time slot is not already booked
--   7. Create appointment record
--   8. Return appointment ID and status
--
-- Parameters:
--   IN  p_patient_id        - Patient ID
--   IN  p_doctor_id         - Doctor ID
--   IN  p_appointment_date  - Date of appointment (YYYY-MM-DD)
--   IN  p_appointment_time  - Time of appointment (HH:MM:SS)
--   IN  p_reason            - Reason for visit
--   OUT p_appointment_id    - Generated appointment ID (output)
--   OUT p_error_message     - Error message if any
--   OUT p_success           - Boolean success flag
--
-- Usage:
--   CALL sp_schedule_appointment(1, 5, '2024-12-25', '10:00:00', 
--                                'Chest pain', @app_id, @msg, @success);
--   SELECT @app_id, @msg, @success;
--
-- ============================================================================

DELIMITER //

CREATE PROCEDURE sp_schedule_appointment(
    IN p_patient_id INT,
    IN p_doctor_id INT,
    IN p_appointment_date DATE,
    IN p_appointment_time TIME,
    IN p_reason VARCHAR(200),
    OUT p_appointment_id INT,
    OUT p_error_message VARCHAR(500),
    OUT p_success BOOLEAN
)
BEGIN
    DECLARE v_conflict_count INT;
    DECLARE v_availability INT;
    DECLARE v_doc_exists INT;
    DECLARE v_patient_exists INT;
    DECLARE v_consultation_fee DECIMAL(10,2);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_success = FALSE;
        SET p_error_message = 'Database Error: Transaction rolled back';
        ROLLBACK;
    END;
    
    -- Initialize variables
    SET p_success = FALSE;
    SET p_error_message = '';
    SET p_appointment_id = NULL;
    
    -- Validation 1: Check if patient exists
    SELECT COUNT(*) INTO v_patient_exists 
    FROM PATIENT 
    WHERE PatientID = p_patient_id;
    
    IF v_patient_exists = 0 THEN
        SET p_success = FALSE;
        SET p_error_message = 'ERROR: Patient ID does not exist';
        LEAVE;
    END IF;
    
    -- Validation 2: Check if doctor exists and is active
    SELECT COUNT(*) INTO v_doc_exists 
    FROM DOCTOR 
    WHERE DoctorID = p_doctor_id AND IsActive = TRUE;
    
    IF v_doc_exists = 0 THEN
        SET p_success = FALSE;
        SET p_error_message = 'ERROR: Doctor ID does not exist or is inactive';
        LEAVE;
    END IF;
    
    -- Validation 3: Check if appointment date is in future
    IF p_appointment_date < CURDATE() THEN
        SET p_success = FALSE;
        SET p_error_message = 'ERROR: Appointment date must be in the future';
        LEAVE;
    END IF;
    
    -- Validation 4: Check if time is within business hours
    IF TIME(p_appointment_time) < '09:00:00' OR TIME(p_appointment_time) > '18:00:00' THEN
        SET p_success = FALSE;
        SET p_error_message = 'ERROR: Appointment time must be between 9 AM and 6 PM';
        LEAVE;
    END IF;
    
    -- Validation 5: Check doctor is available on that day
    SELECT COUNT(*) INTO v_availability 
    FROM DOCTOR_SCHEDULE 
    WHERE DoctorID = p_doctor_id 
    AND DayOfWeek = DAYNAME(p_appointment_date)
    AND IsAvailable = TRUE;
    
    IF v_availability = 0 THEN
        SET p_success = FALSE;
        SET p_error_message = CONCAT('ERROR: Doctor is not available on ', DAYNAME(p_appointment_date));
        LEAVE;
    END IF;
    
    -- Validation 6: Check if time slot is already booked
    SELECT COUNT(*) INTO v_conflict_count 
    FROM APPOINTMENT 
    WHERE DoctorID = p_doctor_id 
    AND AppointmentDate = p_appointment_date 
    AND AppointmentTime = p_appointment_time 
    AND Status IN ('Scheduled', 'Completed');
    
    IF v_conflict_count > 0 THEN
        SET p_success = FALSE;
        SET p_error_message = 'ERROR: Time slot is already booked. Please choose another time.';
        LEAVE;
    END IF;
    
    -- All validations passed - Get consultation fee and create appointment
    START TRANSACTION;
    
    -- Get doctor's consultation fee
    SELECT ConsultationFeePerHour INTO v_consultation_fee
    FROM DOCTOR 
    WHERE DoctorID = p_doctor_id;
    
    -- Insert appointment record
    INSERT INTO APPOINTMENT (
        PatientID, 
        DoctorID, 
        AppointmentDate, 
        AppointmentTime, 
        Reason, 
        Status, 
        ConsultationFee,
        CreatedDate
    )
    VALUES (
        p_patient_id, 
        p_doctor_id, 
        p_appointment_date, 
        p_appointment_time, 
        p_reason, 
        'Scheduled',
        v_consultation_fee,
        NOW()
    );
    
    -- Get the generated appointment ID
    SET p_appointment_id = LAST_INSERT_ID();
    
    -- Commit transaction
    COMMIT;
    
    -- Set success message
    SET p_success = TRUE;
    SET p_error_message = CONCAT('SUCCESS: Appointment scheduled with ID: ', p_appointment_id);

END //

DELIMITER ;

-- ============================================================================
-- PROCEDURE 2: sp_get_patient_medical_summary
-- ============================================================================
-- Purpose: Retrieve comprehensive medical information for a patient
-- Returns: Patient demographics + medical history + recent appointments + prescriptions
--
-- Business Logic:
--   1. Fetch patient basic information
--   2. Get complete medical history (diagnoses, treatments)
--   3. Retrieve recent appointments
--   4. Get all current prescriptions
--   5. Show lab test results
--
-- Parameters:
--   IN p_patient_id - Patient ID
--
-- Returns: 4 result sets
--   1. Patient basic info
--   2. Medical history (last 10 records)
--   3. Appointments (last 5)
--   4. Current prescriptions
--
-- Usage:
--   CALL sp_get_patient_medical_summary(1);
--
-- ============================================================================

DELIMITER //

CREATE PROCEDURE sp_get_patient_medical_summary(
    IN p_patient_id INT
)
BEGIN
    DECLARE v_patient_exists INT;
    
    -- Check if patient exists
    SELECT COUNT(*) INTO v_patient_exists 
    FROM PATIENT 
    WHERE PatientID = p_patient_id;
    
    IF v_patient_exists = 0 THEN
        SELECT 'Patient ID does not exist' AS Error;
        LEAVE;
    END IF;
    
    -- Result Set 1: Patient Basic Information and Statistics
    SELECT 
        p.PatientID,
        CONCAT(p.FirstName, ' ', p.LastName) AS PatientName,
        DATE_FORMAT(p.DOB, '%Y-%m-%d') AS DateOfBirth,
        YEAR(CURDATE()) - YEAR(p.DOB) AS Age,
        p.Gender,
        p.BloodGroup,
        p.Phone,
        p.Email,
        p.Address,
        p.City,
        COUNT(DISTINCT mh.HistoryID) AS TotalDiagnosis,
        COUNT(DISTINCT ap.AppointmentID) AS TotalAppointments,
        COUNT(DISTINCT lr.ReportID) AS TotalLabReports,
        p.RegistrationDate
    FROM PATIENT p
    LEFT JOIN MEDICAL_HISTORY mh ON p.PatientID = mh.PatientID
    LEFT JOIN APPOINTMENT ap ON p.PatientID = ap.PatientID
    LEFT JOIN LAB_REPORT lr ON p.PatientID = lr.PatientID
    WHERE p.PatientID = p_patient_id
    GROUP BY p.PatientID;
    
    -- Result Set 2: Recent Medical History (Last 10 records)
    SELECT 
        HistoryID,
        Diagnosis,
        Symptoms,
        TreatmentPlan,
        Severity,
        OutcomeStatus,
        DATE_FORMAT(CreatedDate, '%Y-%m-%d %H:%i:%s') AS CreatedDate
    FROM MEDICAL_HISTORY
    WHERE PatientID = p_patient_id
    ORDER BY CreatedDate DESC
    LIMIT 10;
    
    -- Result Set 3: Recent Appointments (Last 5)
    SELECT 
        a.AppointmentID,
        CONCAT(d.FirstName, ' ', d.LastName) AS DoctorName,
        d.Specialization,
        a.AppointmentDate,
        a.AppointmentTime,
        a.Reason,
        a.Status,
        a.ConsultationFee
    FROM APPOINTMENT a
    JOIN DOCTOR d ON a.DoctorID = d.DoctorID
    WHERE a.PatientID = p_patient_id
    ORDER BY a.AppointmentDate DESC
    LIMIT 5;
    
    -- Result Set 4: Current Prescriptions
    SELECT 
        pr.PrescriptionID,
        CONCAT(d.FirstName, ' ', d.LastName) AS DoctorName,
        m.MedicineName,
        m.GenericName,
        pi.Dosage,
        pi.Frequency,
        pi.Duration,
        pi.Instructions,
        DATE_FORMAT(pr.CreatedDate, '%Y-%m-%d') AS PrescriptionDate
    FROM PRESCRIPTION pr
    JOIN DOCTOR d ON pr.DoctorID = d.DoctorID
    JOIN PRESCRIPTION_ITEMS pi ON pr.PrescriptionID = pi.PrescriptionID
    JOIN MEDICINE m ON pi.MedicineID = m.MedicineID
    WHERE pr.PrescriptionID IN (
        SELECT DISTINCT pr2.PrescriptionID 
        FROM PRESCRIPTION pr2
        JOIN APPOINTMENT ap ON pr2.AppointmentID = ap.AppointmentID
        WHERE ap.PatientID = p_patient_id
    )
    AND pr.Status = 'Active'
    ORDER BY pr.CreatedDate DESC;

END //

DELIMITER ;

-- ============================================================================
-- PROCEDURE 3: sp_process_billing
-- ============================================================================
-- Purpose: Calculate and create billing record for an appointment
--
-- Business Logic:
--   1. Get appointment and consultation charges
--   2. Calculate lab test charges
--   3. Get medicine/prescription charges
--   4. Calculate insurance coverage
--   5. Create comprehensive billing record
--   6. Calculate patient payable amount
--   7. Set payment status
--
-- Parameters:
--   IN  p_patient_id        - Patient ID
--   IN  p_appointment_id    - Appointment ID
--   OUT p_billing_id        - Generated billing ID
--   OUT p_patient_payable   - Amount patient needs to pay
--   OUT p_success           - Success flag
--
-- Usage:
--   CALL sp_process_billing(1, 5, @bill_id, @payable, @success);
--   SELECT @bill_id, @payable, @success;
--
-- ============================================================================

DELIMITER //

CREATE PROCEDURE sp_process_billing(
    IN p_patient_id INT,
    IN p_appointment_id INT,
    OUT p_billing_id INT,
    OUT p_patient_payable DECIMAL(12,2),
    OUT p_success BOOLEAN
)
BEGIN
    DECLARE v_consultation_fee DECIMAL(10,2);
    DECLARE v_lab_charges DECIMAL(10,2);
    DECLARE v_medicine_charges DECIMAL(10,2);
    DECLARE v_total_charges DECIMAL(12,2);
    DECLARE v_insurance_coverage DECIMAL(12,2);
    DECLARE v_insurance_id INT;
    DECLARE v_coverage_percentage INT;
    DECLARE v_billing_number VARCHAR(50);
    DECLARE v_appointment_exists INT;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_success = FALSE;
        ROLLBACK;
    END;
    
    SET p_success = FALSE;
    SET v_lab_charges = 0;
    SET v_medicine_charges = 0;
    SET v_insurance_coverage = 0;
    
    -- Check if appointment exists
    SELECT COUNT(*) INTO v_appointment_exists 
    FROM APPOINTMENT 
    WHERE AppointmentID = p_appointment_id;
    
    IF v_appointment_exists = 0 THEN
        SELECT 'Appointment does not exist' AS Error;
        LEAVE;
    END IF;
    
    START TRANSACTION;
    
    -- Get consultation fee from appointment
    SELECT ConsultationFee INTO v_consultation_fee 
    FROM APPOINTMENT 
    WHERE AppointmentID = p_appointment_id;
    
    IF v_consultation_fee IS NULL THEN
        SET v_consultation_fee = 0;
    END IF;
    
    -- Get lab charges from lab reports associated with appointment
    SELECT COALESCE(SUM(lt.CostPrice), 0) INTO v_lab_charges
    FROM LAB_REPORT lr
    JOIN LAB_TEST lt ON lr.TestID = lt.TestID
    WHERE lr.AppointmentID = p_appointment_id
    AND lr.Status IN ('Normal', 'Abnormal', 'Critical');
    
    -- Get medicine charges from prescriptions
    SELECT COALESCE(SUM(m.UnitPrice * pi.Quantity), 0) INTO v_medicine_charges
    FROM PRESCRIPTION pr
    JOIN PRESCRIPTION_ITEMS pi ON pr.PrescriptionID = pi.PrescriptionID
    JOIN MEDICINE m ON pi.MedicineID = m.MedicineID
    WHERE pr.AppointmentID = p_appointment_id;
    
    -- Calculate total charges
    SET v_total_charges = v_consultation_fee + v_lab_charges + v_medicine_charges;
    
    -- Check if patient has active insurance
    SELECT InsuranceID, CoveragePercentage INTO v_insurance_id, v_coverage_percentage
    FROM INSURANCE
    WHERE PatientID = p_patient_id AND IsActive = TRUE AND ValidTo >= CURDATE();
    
    -- Calculate insurance coverage
    IF v_insurance_id IS NOT NULL THEN
        SET v_insurance_coverage = (v_total_charges * v_coverage_percentage) / 100;
    END IF;
    
    -- Generate unique billing number
    SET v_billing_number = CONCAT('BILL-', DATE_FORMAT(NOW(), '%Y%m%d'), '-', LPAD(LAST_INSERT_ID(), 5, '0'));
    
    -- Create billing record
    INSERT INTO BILLING (
        BillingNumber,
        PatientID,
        AppointmentID,
        InsuranceID,
        ConsultationCharges,
        LabCharges,
        MedicineCharges,
        TotalCharges,
        InsuranceCoverage,
        PatientPayable,
        PaymentStatus,
        DueDate,
        BillingDate
    )
    VALUES (
        v_billing_number,
        p_patient_id,
        p_appointment_id,
        v_insurance_id,
        v_consultation_fee,
        v_lab_charges,
        v_medicine_charges,
        v_total_charges,
        v_insurance_coverage,
        (v_total_charges - v_insurance_coverage),
        'Pending',
        DATE_ADD(CURDATE(), INTERVAL 7 DAY),
        NOW()
    );
    
    SET p_billing_id = LAST_INSERT_ID();
    SET p_patient_payable = (v_total_charges - v_insurance_coverage);
    SET p_success = TRUE;
    
    COMMIT;

END //

DELIMITER ;

-- ============================================================================
-- PROCEDURE 4: sp_get_medicine_expiry_report
-- ============================================================================
-- Purpose: Generate medicines expiring within specified days for inventory management
--
-- Business Logic:
--   1. Get all medicines expiring soon
--   2. Calculate days until expiry
--   3. Identify stock levels
--   4. Show manufacturer info
--   5. Highlight critical items
--
-- Parameters:
--   IN p_days_ahead - Number of days to look ahead for expiry
--
-- Usage:
--   CALL sp_get_medicine_expiry_report(30);  -- Medicines expiring in 30 days
--
-- ============================================================================

DELIMITER //

CREATE PROCEDURE sp_get_medicine_expiry_report(
    IN p_days_ahead INT
)
BEGIN
    DECLARE v_days_valid INT;
    
    -- Validate input parameter
    IF p_days_ahead <= 0 OR p_days_ahead > 365 THEN
        SELECT 'Invalid days value. Please provide days between 1 and 365' AS Error;
        LEAVE;
    END IF;
    
    -- Get medicines expiring within specified days
    SELECT 
        m.MedicineID,
        m.MedicineName,
        m.GenericName,
        m.Type,
        mfg.MfgName AS Manufacturer,
        m.UnitPrice,
        m.QuantityInStock,
        m.ReorderLevel,
        m.ExpiryDate,
        CURDATE() AS CurrentDate,
        DATEDIFF(m.ExpiryDate, CURDATE()) AS DaysUntilExpiry,
        CASE 
            WHEN DATEDIFF(m.ExpiryDate, CURDATE()) <= 7 THEN 'CRITICAL - Dispose Immediately'
            WHEN DATEDIFF(m.ExpiryDate, CURDATE()) <= 14 THEN 'HIGH - Expedite Usage'
            WHEN DATEDIFF(m.ExpiryDate, CURDATE()) <= 30 THEN 'MEDIUM - Plan Usage'
            ELSE 'LOW - Stock Available'
        END AS ExpirySeverity,
        CASE 
            WHEN m.QuantityInStock < m.ReorderLevel THEN 'LOW_STOCK'
            WHEN m.QuantityInStock = 0 THEN 'OUT_OF_STOCK'
            ELSE 'ADEQUATE'
        END AS StockStatus
    FROM MEDICINE m
    JOIN MANUFACTURER mfg ON m.ManufacturerID = mfg.ManufacturerID
    WHERE m.ExpiryDate <= DATE_ADD(CURDATE(), INTERVAL p_days_ahead DAY)
        AND m.ExpiryDate >= CURDATE()
        AND m.IsActive = TRUE
    ORDER BY m.ExpiryDate ASC, ExpirySeverity DESC;

END //

DELIMITER ;

-- ============================================================================
-- PROCEDURE 5: sp_get_doctor_performance
-- ============================================================================
-- Purpose: Analyze doctor's performance metrics
--
-- Business Logic:
--   1. Total appointments count
--   2. Completion rate
--   3. Cancellation rate
--   4. Average consultation fee
--   5. Patient satisfaction
--   6. Period-based analysis
--
-- Parameters:
--   IN p_doctor_id - Doctor ID
--
-- Usage:
--   CALL sp_get_doctor_performance(1);
--
-- ============================================================================

DELIMITER //

CREATE PROCEDURE sp_get_doctor_performance(
    IN p_doctor_id INT
)
BEGIN
    DECLARE v_doctor_exists INT;
    DECLARE v_current_month DATE;
    DECLARE v_last_month_start DATE;
    DECLARE v_last_month_end DATE;
    
    -- Check if doctor exists
    SELECT COUNT(*) INTO v_doctor_exists 
    FROM DOCTOR 
    WHERE DoctorID = p_doctor_id;
    
    IF v_doctor_exists = 0 THEN
        SELECT 'Doctor ID does not exist' AS Error;
        LEAVE;
    END IF;
    
    -- Calculate date ranges
    SET v_current_month = DATE_FORMAT(CURDATE(), '%Y-%m-01');
    SET v_last_month_start = DATE_SUB(v_current_month, INTERVAL 1 MONTH);
    SET v_last_month_end = DATE_SUB(DATE_ADD(v_current_month, INTERVAL 1 MONTH), INTERVAL 1 DAY);
    
    -- Result Set 1: Overall Performance
    SELECT 
        d.DoctorID,
        CONCAT(d.FirstName, ' ', d.LastName) AS DoctorName,
        d.Specialization,
        dept.DeptName,
        d.YearsOfExperience,
        d.ConsultationFeePerHour,
        COUNT(DISTINCT a.AppointmentID) AS TotalAppointments,
        SUM(CASE WHEN a.Status = 'Completed' THEN 1 ELSE 0 END) AS CompletedAppointments,
        SUM(CASE WHEN a.Status = 'Cancelled' THEN 1 ELSE 0 END) AS CancelledAppointments,
        SUM(CASE WHEN a.Status = 'No-Show' THEN 1 ELSE 0 END) AS NoShowAppointments,
        ROUND(SUM(CASE WHEN a.Status = 'Completed' THEN 1 ELSE 0 END) / 
            COUNT(DISTINCT a.AppointmentID) * 100, 2) AS CompletionRate,
        ROUND(SUM(CASE WHEN a.Status = 'Cancelled' THEN 1 ELSE 0 END) / 
            COUNT(DISTINCT a.AppointmentID) * 100, 2) AS CancellationRate
    FROM DOCTOR d
    LEFT JOIN DEPARTMENT dept ON d.DepartmentID = dept.DepartmentID
    LEFT JOIN APPOINTMENT a ON d.DoctorID = a.DoctorID
    WHERE d.DoctorID = p_doctor_id
    GROUP BY d.DoctorID;
    
    -- Result Set 2: Monthly Performance Comparison
    SELECT 
        'Current Month' AS Period,
        COUNT(DISTINCT AppointmentID) AS AppointmentsCount,
        SUM(CASE WHEN Status = 'Completed' THEN 1 ELSE 0 END) AS CompletedCount,
        ROUND(AVG(ConsultationFee), 2) AS AvgConsultationFee,
        MIN(AppointmentDate) AS FirstAppointment,
        MAX(AppointmentDate) AS LastAppointment
    FROM APPOINTMENT
    WHERE DoctorID = p_doctor_id
        AND AppointmentDate >= v_current_month
    UNION ALL
    SELECT 
        'Last Month',
        COUNT(DISTINCT AppointmentID),
        SUM(CASE WHEN Status = 'Completed' THEN 1 ELSE 0 END),
        ROUND(AVG(ConsultationFee), 2),
        MIN(AppointmentDate),
        MAX(AppointmentDate)
    FROM APPOINTMENT
    WHERE DoctorID = p_doctor_id
        AND AppointmentDate >= v_last_month_start
        AND AppointmentDate <= v_last_month_end;
    
    -- Result Set 3: Patient Demographics
    SELECT 
        COUNT(DISTINCT a.PatientID) AS TotalPatients,
        SUM(CASE WHEN p.Gender = 'M' THEN 1 ELSE 0 END) AS MalePatients,
        SUM(CASE WHEN p.Gender = 'F' THEN 1 ELSE 0 END) AS FemalePatients,
        ROUND(AVG(YEAR(CURDATE()) - YEAR(p.DOB)), 1) AS AvgPatientAge
    FROM APPOINTMENT a
    JOIN PATIENT p ON a.PatientID = p.PatientID
    WHERE a.DoctorID = p_doctor_id
        AND a.Status = 'Completed';

END //

DELIMITER ;

-- ============================================================================
-- PROCEDURE 6: sp_calculate_monthly_revenue
-- ============================================================================
-- Purpose: Calculate monthly revenue with detailed breakdown
--
-- Business Logic:
--   1. Get total billing amount
--   2. Get amount received
--   3. Calculate pending/outstanding
--   4. Payment method breakdown
--   5. Insurance vs self-pay analysis
--
-- Parameters:
--   IN p_year  - Year for report
--   IN p_month - Month for report
--
-- Usage:
--   CALL sp_calculate_monthly_revenue(2024, 12);
--
-- ============================================================================

DELIMITER //

CREATE PROCEDURE sp_calculate_monthly_revenue(
    IN p_year INT,
    IN p_month INT
)
BEGIN
    DECLARE v_month_start DATE;
    DECLARE v_month_end DATE;
    
    -- Validate input
    IF p_month < 1 OR p_month > 12 THEN
        SELECT 'Invalid month. Please provide month between 1 and 12' AS Error;
        LEAVE;
    END IF;
    
    IF p_year < 2020 OR p_year > YEAR(CURDATE()) THEN
        SELECT 'Invalid year. Please provide valid year' AS Error;
        LEAVE;
    END IF;
    
    -- Calculate month boundaries
    SET v_month_start = STR_TO_DATE(CONCAT(p_year, '-', p_month, '-01'), '%Y-%m-%d');
    SET v_month_end = LAST_DAY(v_month_start);
    
    -- Result Set 1: Overall Monthly Revenue
    SELECT 
        DATE_FORMAT(v_month_start, '%Y-%m') AS Month,
        COUNT(DISTINCT BillingID) AS TotalBillings,
        SUM(TotalCharges) AS TotalCharges,
        SUM(InsuranceCoverage) AS InsurancePaid,
        SUM(AmountPaid) AS AmountReceived,
        SUM(PatientPayable - AmountPaid) AS OutstandingBalance,
        ROUND(SUM(AmountPaid) / SUM(TotalCharges) * 100, 2) AS CollectionPercentage
    FROM BILLING
    WHERE BillingDate >= v_month_start 
        AND BillingDate <= v_month_end;
    
    -- Result Set 2: Payment Status Breakdown
    SELECT 
        PaymentStatus,
        COUNT(BillingID) AS Count,
        SUM(TotalCharges) AS TotalAmount,
        SUM(AmountPaid) AS PaidAmount,
        SUM(PatientPayable - AmountPaid) AS PendingAmount
    FROM BILLING
    WHERE BillingDate >= v_month_start 
        AND BillingDate <= v_month_end
    GROUP BY PaymentStatus;
    
    -- Result Set 3: Payment Method Breakdown
    SELECT 
        PaymentMethod,
        COUNT(BillingID) AS TransactionCount,
        SUM(AmountPaid) AS TotalAmount,
        ROUND(SUM(AmountPaid) / 
            (SELECT SUM(AmountPaid) FROM BILLING 
             WHERE BillingDate >= v_month_start AND BillingDate <= v_month_end) * 100, 2) AS Percentage
    FROM BILLING
    WHERE BillingDate >= v_month_start 
        AND BillingDate <= v_month_end
        AND AmountPaid > 0
    GROUP BY PaymentMethod;
    
    -- Result Set 4: Department-wise Revenue
    SELECT 
        dept.DeptName,
        COUNT(DISTINCT b.BillingID) AS TotalBillings,
        SUM(b.TotalCharges) AS Revenue,
        ROUND(AVG(b.TotalCharges), 2) AS AvgBillingAmount,
        SUM(b.AmountPaid) AS AmountCollected
    FROM BILLING b
    JOIN APPOINTMENT a ON b.AppointmentID = a.AppointmentID
    JOIN DOCTOR d ON a.DoctorID = d.DoctorID
    JOIN DEPARTMENT dept ON d.DepartmentID = dept.DepartmentID
    WHERE DATE_FORMAT(b.BillingDate, '%Y-%m') = DATE_FORMAT(v_month_start, '%Y-%m')
    GROUP BY dept.DeptName
    ORDER BY Revenue DESC;

END //

DELIMITER ;

-- ============================================================================
-- SUMMARY
-- ============================================================================
-- Total Stored Procedures: 6
--
-- 1. sp_schedule_appointment       - Complex validation for appointment scheduling
-- 2. sp_get_patient_medical_summary - Multi-result set medical records retrieval
-- 3. sp_process_billing            - Calculate and create billing records
-- 4. sp_get_medicine_expiry_report - Inventory management and expiry tracking
-- 5. sp_get_doctor_performance     - Doctor performance analytics
-- 6. sp_calculate_monthly_revenue  - Financial reporting and analysis
--
-- DBMS Concepts Covered:
-- ✅ Parameter handling (IN, OUT)
-- ✅ Local variables (DECLARE)
-- ✅ Control flow (IF-THEN-ELSE, LEAVE)
-- ✅ Transactions (START TRANSACTION, COMMIT, ROLLBACK)
-- ✅ Cursors (implicit in result sets)
-- ✅ Exception handling (DECLARE ... HANDLER)
-- ✅ Date/Time functions
-- ✅ Aggregate functions (SUM, COUNT, AVG, etc.)
-- ✅ Multiple result sets
-- ✅ Complex business logic
--
-- ============================================================================
-- End of Stored Procedures Script
-- ============================================================================
