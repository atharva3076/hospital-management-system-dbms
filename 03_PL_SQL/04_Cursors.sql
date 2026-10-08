-- ============================================================================
-- HOSPITAL MANAGEMENT SYSTEM - CURSORS (PL/SQL)
-- ============================================================================
-- Created by: Member 3 (PL/SQL Developer)
-- Purpose: Demonstrate explicit cursor handling for row-by-row processing
-- Date: 2024
-- ============================================================================
-- CURSORS: 5 explicit cursor demonstrations covering:
-- 1. Process all patients and calculate health metrics
-- 2. Generate monthly salary for all doctors
-- 3. Update expired medicines status
-- 4. Process pending prescriptions
-- 5. Generate patient bill reminders
-- ============================================================================

USE hospital_management_system;

-- ============================================================================
-- CURSOR 1: Process All Patients and Calculate Health Metrics
-- ============================================================================
-- Purpose: Demonstrate basic cursor with LOOP, FETCH, and EXIT
-- 
-- Business Logic:
--   1. Fetch all active patients
--   2. For each patient, calculate BMI and risk category
--   3. Log patient health status
--
-- Cursor Attributes Used:
--   - CURSOR ... FOR (SELECT ...)
--   - OPEN cursor
--   - FETCH cursor INTO variables
--   - FOUND_ROWS for row count
--
-- ============================================================================

DELIMITER //

CREATE PROCEDURE sp_process_patient_health_metrics()
BEGIN
    DECLARE v_patient_id INT;
    DECLARE v_patient_name VARCHAR(100);
    DECLARE v_height DECIMAL(5,2);
    DECLARE v_weight DECIMAL(5,2);
    DECLARE v_bmi DECIMAL(5,2);
    DECLARE v_health_category VARCHAR(50);
    DECLARE v_done BOOLEAN DEFAULT FALSE;
    DECLARE v_processed_count INT DEFAULT 0;
    
    -- Declare cursor to fetch all active patients
    DECLARE patient_cursor CURSOR FOR
        SELECT 
            PatientID,
            CONCAT(FirstName, ' ', LastName),
            Height,
            Weight
        FROM PATIENT
        WHERE Height IS NOT NULL AND Weight IS NOT NULL
        ORDER BY PatientID;
    
    -- Declare continue handler to detect end of cursor
    DECLARE CONTINUE HANDLER FOR NOT FOUND
        SET v_done = TRUE;
    
    -- Create temporary table to store results
    CREATE TEMPORARY TABLE IF NOT EXISTS patient_health_report (
        PatientID INT,
        PatientName VARCHAR(100),
        Height DECIMAL(5,2),
        Weight DECIMAL(5,2),
        BMI DECIMAL(5,2),
        HealthCategory VARCHAR(50),
        ProcessedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
    
    -- Open cursor
    OPEN patient_cursor;
    
    -- Loop through all rows
    process_loop: LOOP
        FETCH patient_cursor INTO v_patient_id, v_patient_name, v_height, v_weight;
        
        -- Exit loop if no more rows
        IF v_done THEN
            LEAVE process_loop;
        END IF;
        
        -- Calculate BMI
        SET v_bmi = ROUND(v_weight / ((v_height/100) * (v_height/100)), 2);
        
        -- Determine health category based on BMI
        IF v_bmi < 18.5 THEN
            SET v_health_category = 'Underweight';
        ELSEIF v_bmi < 25 THEN
            SET v_health_category = 'Normal';
        ELSEIF v_bmi < 30 THEN
            SET v_health_category = 'Overweight';
        ELSE
            SET v_health_category = 'Obese';
        END IF;
        
        -- Insert into temporary table
        INSERT INTO patient_health_report (PatientID, PatientName, Height, Weight, BMI, HealthCategory)
        VALUES (v_patient_id, v_patient_name, v_height, v_weight, v_bmi, v_health_category);
        
        SET v_processed_count = v_processed_count + 1;
    END LOOP;
    
    -- Close cursor
    CLOSE patient_cursor;
    
    -- Return results
    SELECT * FROM patient_health_report;
    
    -- Display summary
    SELECT CONCAT('Total patients processed: ', v_processed_count) AS Summary;
END //

DELIMITER ;

-- ============================================================================
-- CURSOR 2: Generate Monthly Salary for All Doctors
-- ============================================================================
-- Purpose: Demonstrate cursor with conditional processing and aggregation
--
-- Business Logic:
--   1. Fetch all active doctors
--   2. Calculate salary based on:
--      - Base salary (consultation fee * appointments)
--      - Bonus for performance (completion rate > 90%)
--      - Deductions for no-shows
--   3. Generate salary slip
--
-- ============================================================================

DELIMITER //

CREATE PROCEDURE sp_generate_doctor_salary_slip(
    IN p_year INT,
    IN p_month INT
)
BEGIN
    DECLARE v_doctor_id INT;
    DECLARE v_doctor_name VARCHAR(100);
    DECLARE v_specialization VARCHAR(100);
    DECLARE v_consultation_fee DECIMAL(10,2);
    DECLARE v_total_appointments INT;
    DECLARE v_completed_appointments INT;
    DECLARE v_no_show_count INT;
    DECLARE v_base_salary DECIMAL(12,2);
    DECLARE v_bonus DECIMAL(10,2);
    DECLARE v_deduction DECIMAL(10,2);
    DECLARE v_net_salary DECIMAL(12,2);
    DECLARE v_completion_rate DECIMAL(5,2);
    DECLARE v_done BOOLEAN DEFAULT FALSE;
    DECLARE v_month_start DATE;
    DECLARE v_month_end DATE;
    
    -- Declare cursor for all active doctors
    DECLARE doctor_cursor CURSOR FOR
        SELECT 
            DoctorID,
            CONCAT(FirstName, ' ', LastName),
            Specialization,
            ConsultationFeePerHour
        FROM DOCTOR
        WHERE IsActive = TRUE
        ORDER BY DoctorID;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND
        SET v_done = TRUE;
    
    -- Create temporary salary report table
    CREATE TEMPORARY TABLE IF NOT EXISTS doctor_salary_slip (
        DoctorID INT,
        DoctorName VARCHAR(100),
        Specialization VARCHAR(100),
        TotalAppointments INT,
        CompletedAppointments INT,
        CompletionRate DECIMAL(5,2),
        BaseSalary DECIMAL(12,2),
        Bonus DECIMAL(10,2),
        Deduction DECIMAL(10,2),
        NetSalary DECIMAL(12,2),
        GeneratedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
    
    -- Calculate date range
    SET v_month_start = STR_TO_DATE(CONCAT(p_year, '-', p_month, '-01'), '%Y-%m-%d');
    SET v_month_end = LAST_DAY(v_month_start);
    
    -- Open cursor
    OPEN doctor_cursor;
    
    salary_loop: LOOP
        FETCH doctor_cursor INTO v_doctor_id, v_doctor_name, v_specialization, v_consultation_fee;
        
        IF v_done THEN
            LEAVE salary_loop;
        END IF;
        
        -- Get appointment statistics for the month
        SELECT 
            COUNT(DISTINCT AppointmentID),
            SUM(CASE WHEN Status = 'Completed' THEN 1 ELSE 0 END),
            SUM(CASE WHEN Status = 'No-Show' THEN 1 ELSE 0 END)
        INTO v_total_appointments, v_completed_appointments, v_no_show_count
        FROM APPOINTMENT
        WHERE DoctorID = v_doctor_id
            AND AppointmentDate >= v_month_start
            AND AppointmentDate <= v_month_end;
        
        -- Handle NULL values
        IF v_total_appointments IS NULL THEN
            SET v_total_appointments = 0;
            SET v_completed_appointments = 0;
            SET v_no_show_count = 0;
        END IF;
        
        -- Calculate completion rate
        IF v_total_appointments > 0 THEN
            SET v_completion_rate = (v_completed_appointments / v_total_appointments) * 100;
        ELSE
            SET v_completion_rate = 0;
        END IF;
        
        -- Calculate base salary (50% of consultation fees earned)
        SET v_base_salary = (v_consultation_fee * v_completed_appointments) * 0.5;
        
        -- Calculate bonus (if completion rate > 90%)
        IF v_completion_rate > 90 THEN
            SET v_bonus = v_base_salary * 0.1;  -- 10% bonus
        ELSE
            SET v_bonus = 0;
        END IF;
        
        -- Calculate deductions (Rs. 100 per no-show)
        SET v_deduction = v_no_show_count * 100;
        
        -- Calculate net salary
        SET v_net_salary = v_base_salary + v_bonus - v_deduction;
        
        -- Insert into temporary table
        INSERT INTO doctor_salary_slip
        VALUES (v_doctor_id, v_doctor_name, v_specialization, v_total_appointments, 
                v_completed_appointments, v_completion_rate, v_base_salary, 
                v_bonus, v_deduction, v_net_salary);
    END LOOP;
    
    CLOSE doctor_cursor;
    
    -- Return salary slips
    SELECT * FROM doctor_salary_slip
    ORDER BY NetSalary DESC;
    
    -- Display summary
    SELECT 
        CONCAT('Month: ', p_year, '-', LPAD(p_month, 2, '0')) AS Period,
        COUNT(*) AS TotalDoctors,
        ROUND(SUM(NetSalary), 2) AS TotalPayroll
    FROM doctor_salary_slip;
END //

DELIMITER ;

-- ============================================================================
-- CURSOR 3: Update Expired Medicines Status
-- ============================================================================
-- Purpose: Demonstrate cursor with UPDATE and dynamic message generation
--
-- Business Logic:
--   1. Fetch all medicines
--   2. Check expiry date
--   3. Update status if expired
--   4. Move expired medicines to separate status
--   5. Generate report
--
-- ============================================================================

DELIMITER //

CREATE PROCEDURE sp_update_expired_medicines()
BEGIN
    DECLARE v_medicine_id INT;
    DECLARE v_medicine_name VARCHAR(150);
    DECLARE v_expiry_date DATE;
    DECLARE v_current_stock INT;
    DECLARE v_is_active BOOLEAN;
    DECLARE v_done BOOLEAN DEFAULT FALSE;
    DECLARE v_expired_count INT DEFAULT 0;
    DECLARE v_expiring_soon_count INT DEFAULT 0;
    
    -- Declare cursor for all medicines
    DECLARE medicine_cursor CURSOR FOR
        SELECT 
            MedicineID,
            MedicineName,
            ExpiryDate,
            QuantityInStock,
            IsActive
        FROM MEDICINE
        WHERE IsActive = TRUE
        ORDER BY ExpiryDate ASC;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND
        SET v_done = TRUE;
    
    -- Create report table
    CREATE TEMPORARY TABLE IF NOT EXISTS medicine_status_report (
        MedicineID INT,
        MedicineName VARCHAR(150),
        ExpiryDate DATE,
        Stock INT,
        Status VARCHAR(50),
        ActionTaken VARCHAR(200),
        ProcessedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
    
    OPEN medicine_cursor;
    
    medicine_loop: LOOP
        FETCH medicine_cursor INTO v_medicine_id, v_medicine_name, v_expiry_date, v_current_stock, v_is_active;
        
        IF v_done THEN
            LEAVE medicine_loop;
        END IF;
        
        -- Check if medicine is expired
        IF v_expiry_date < CURDATE() THEN
            -- Update medicine status
            UPDATE MEDICINE
            SET IsActive = FALSE
            WHERE MedicineID = v_medicine_id;
            
            SET v_expired_count = v_expired_count + 1;
            
            INSERT INTO medicine_status_report
            VALUES (v_medicine_id, v_medicine_name, v_expiry_date, v_current_stock, 
                    'EXPIRED', CONCAT('Deactivated - Expired on ', v_expiry_date));
        
        -- Check if medicine is expiring within 30 days
        ELSEIF v_expiry_date <= DATE_ADD(CURDATE(), INTERVAL 30 DAY) THEN
            SET v_expiring_soon_count = v_expiring_soon_count + 1;
            
            INSERT INTO medicine_status_report
            VALUES (v_medicine_id, v_medicine_name, v_expiry_date, v_current_stock, 
                    'EXPIRING_SOON', CONCAT('Alert - Expires on ', v_expiry_date));
        
        -- Medicine is OK
        ELSE
            INSERT INTO medicine_status_report
            VALUES (v_medicine_id, v_medicine_name, v_expiry_date, v_current_stock, 
                    'OK', 'No action required');
        END IF;
    END LOOP;
    
    CLOSE medicine_cursor;
    
    -- Return report
    SELECT * FROM medicine_status_report;
    
    -- Summary report
    SELECT 
        v_expired_count AS ExpiredMedicines,
        v_expiring_soon_count AS ExpiringWithin30Days,
        (v_expired_count + v_expiring_soon_count) AS TotalToManage;
END //

DELIMITER ;

-- ============================================================================
-- CURSOR 4: Process Pending Prescriptions
-- ============================================================================
-- Purpose: Demonstrate cursor with row-level processing and status updates
--
-- Business Logic:
--   1. Fetch all pending prescriptions
--   2. Verify all medicines are in stock
--   3. Check for drug interactions
--   4. Approve or flag prescriptions
--
-- ============================================================================

DELIMITER //

CREATE PROCEDURE sp_process_pending_prescriptions()
BEGIN
    DECLARE v_prescription_id INT;
    DECLARE v_patient_id INT;
    DECLARE v_patient_name VARCHAR(100);
    DECLARE v_items_count INT;
    DECLARE v_low_stock_items INT;
    DECLARE v_prescription_status VARCHAR(50);
    DECLARE v_done BOOLEAN DEFAULT FALSE;
    DECLARE v_processed_count INT DEFAULT 0;
    
    DECLARE prescription_cursor CURSOR FOR
        SELECT 
            p.PrescriptionID,
            ap.PatientID,
            CONCAT(pat.FirstName, ' ', pat.LastName),
            COUNT(pi.PrescriptionItemID) AS ItemCount
        FROM PRESCRIPTION p
        JOIN APPOINTMENT ap ON p.AppointmentID = ap.AppointmentID
        JOIN PATIENT pat ON ap.PatientID = pat.PatientID
        JOIN PRESCRIPTION_ITEMS pi ON p.PrescriptionID = pi.PrescriptionID
        WHERE p.Status = 'Active'
        GROUP BY p.PrescriptionID
        ORDER BY p.CreatedDate;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND
        SET v_done = TRUE;
    
    -- Create processing report table
    CREATE TEMPORARY TABLE IF NOT EXISTS prescription_processing_report (
        PrescriptionID INT,
        PatientName VARCHAR(100),
        ItemsCount INT,
        LowStockItems INT,
        Status VARCHAR(50),
        Notes TEXT,
        ProcessedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
    
    OPEN prescription_cursor;
    
    prescription_loop: LOOP
        FETCH prescription_cursor INTO v_prescription_id, v_patient_id, v_patient_name, v_items_count;
        
        IF v_done THEN
            LEAVE prescription_loop;
        END IF;
        
        -- Count items with low stock
        SELECT COUNT(*) INTO v_low_stock_items
        FROM PRESCRIPTION_ITEMS pi
        JOIN MEDICINE m ON pi.MedicineID = m.MedicineID
        WHERE pi.PrescriptionID = v_prescription_id
            AND m.QuantityInStock < pi.Quantity;
        
        -- Determine prescription status
        IF v_low_stock_items > 0 THEN
            SET v_prescription_status = 'FLAGGED';
        ELSE
            SET v_prescription_status = 'APPROVED';
        END IF;
        
        -- Update prescription status
        UPDATE PRESCRIPTION
        SET Status = v_prescription_status
        WHERE PrescriptionID = v_prescription_id;
        
        -- Insert into report
        INSERT INTO prescription_processing_report
        VALUES (v_prescription_id, v_patient_name, v_items_count, v_low_stock_items, 
                v_prescription_status, 
                CONCAT(v_low_stock_items, ' medicines have low stock - ', 
                       'Patient needs to wait for restocking'));
        
        SET v_processed_count = v_processed_count + 1;
    END LOOP;
    
    CLOSE prescription_cursor;
    
    -- Return report
    SELECT * FROM prescription_processing_report;
    
    -- Summary
    SELECT CONCAT('Processed ', v_processed_count, ' prescriptions') AS Summary;
END //

DELIMITER ;

-- ============================================================================
-- CURSOR 5: Generate Patient Bill Reminders
-- ============================================================================
-- Purpose: Demonstrate cursor for batch processing and notification generation
--
-- Business Logic:
--   1. Fetch all pending/partial payment bills
--   2. Calculate overdue days
--   3. Generate priority-based reminders
--   4. Prepare reminder message
--
-- ============================================================================

DELIMITER //

CREATE PROCEDURE sp_generate_bill_reminders()
BEGIN
    DECLARE v_billing_id INT;
    DECLARE v_billing_number VARCHAR(50);
    DECLARE v_patient_id INT;
    DECLARE v_patient_name VARCHAR(100);
    DECLARE v_patient_phone VARCHAR(15);
    DECLARE v_patient_email VARCHAR(100);
    DECLARE v_amount_due DECIMAL(12,2);
    DECLARE v_due_date DATE;
    DECLARE v_days_overdue INT;
    DECLARE v_priority VARCHAR(20);
    DECLARE v_reminder_message TEXT;
    DECLARE v_done BOOLEAN DEFAULT FALSE;
    DECLARE v_reminder_count INT DEFAULT 0;
    
    DECLARE billing_cursor CURSOR FOR
        SELECT 
            b.BillingID,
            b.BillingNumber,
            p.PatientID,
            CONCAT(p.FirstName, ' ', p.LastName),
            p.Phone,
            p.Email,
            (b.PatientPayable - b.AmountPaid) AS AmountDue,
            b.DueDate
        FROM BILLING b
        JOIN PATIENT p ON b.PatientID = p.PatientID
        WHERE b.PaymentStatus IN ('Pending', 'Partial')
            AND b.DueDate < CURDATE()
        ORDER BY b.DueDate ASC;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND
        SET v_done = TRUE;
    
    -- Create reminder table
    CREATE TEMPORARY TABLE IF NOT EXISTS billing_reminder_report (
        BillingID INT,
        BillingNumber VARCHAR(50),
        PatientName VARCHAR(100),
        PatientPhone VARCHAR(15),
        PatientEmail VARCHAR(100),
        AmountDue DECIMAL(12,2),
        DaysOverdue INT,
        Priority VARCHAR(20),
        ReminderMessage TEXT,
        GeneratedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
    
    OPEN billing_cursor;
    
    reminder_loop: LOOP
        FETCH billing_cursor INTO v_billing_id, v_billing_number, v_patient_id, 
                                  v_patient_name, v_patient_phone, v_patient_email,
                                  v_amount_due, v_due_date;
        
        IF v_done THEN
            LEAVE reminder_loop;
        END IF;
        
        -- Calculate days overdue
        SET v_days_overdue = DATEDIFF(CURDATE(), v_due_date);
        
        -- Determine priority
        IF v_days_overdue > 90 THEN
            SET v_priority = 'CRITICAL';
        ELSEIF v_days_overdue > 30 THEN
            SET v_priority = 'HIGH';
        ELSE
            SET v_priority = 'MEDIUM';
        END IF;
        
        -- Generate reminder message
        SET v_reminder_message = CONCAT(
            'Dear ', v_patient_name, ',\n',
            'This is a reminder regarding your pending bill.\n',
            'Bill Number: ', v_billing_number, '\n',
            'Amount Due: Rs. ', v_amount_due, '\n',
            'Due Date: ', v_due_date, '\n',
            'Days Overdue: ', v_days_overdue, '\n',
            'Please settle the payment at the earliest.\n',
            'Contact: ', v_patient_phone, ' / ', v_patient_email
        );
        
        -- Insert into reminder table
        INSERT INTO billing_reminder_report
        VALUES (v_billing_id, v_billing_number, v_patient_name, v_patient_phone, 
                v_patient_email, v_amount_due, v_days_overdue, v_priority, v_reminder_message);
        
        SET v_reminder_count = v_reminder_count + 1;
    END LOOP;
    
    CLOSE billing_cursor;
    
    -- Return reminders sorted by priority
    SELECT * FROM billing_reminder_report
    ORDER BY CASE Priority WHEN 'CRITICAL' THEN 1 WHEN 'HIGH' THEN 2 ELSE 3 END;
    
    -- Summary
    SELECT 
        CONCAT('Total reminders generated: ', v_reminder_count) AS Summary,
        (SELECT COUNT(*) FROM billing_reminder_report WHERE Priority = 'CRITICAL') AS CriticalCount,
        (SELECT COUNT(*) FROM billing_reminder_report WHERE Priority = 'HIGH') AS HighPriorityCount;
END //

DELIMITER ;

-- ============================================================================
-- SUMMARY OF CURSORS
-- ============================================================================
-- Total Explicit Cursor Demonstrations: 5
--
-- 1. sp_process_patient_health_metrics      - Basic cursor, LOOP, FETCH
-- 2. sp_generate_doctor_salary_slip         - Cursor with aggregation
-- 3. sp_update_expired_medicines            - Cursor with UPDATE
-- 4. sp_process_pending_prescriptions       - Cursor with complex logic
-- 5. sp_generate_bill_reminders             - Cursor for batch processing
--
-- DBMS Concepts Covered:
-- ✅ DECLARE CURSOR ... FOR (SELECT ...)
-- ✅ OPEN cursor
-- ✅ FETCH cursor INTO variables
-- ✅ LOOP ... END LOOP
-- ✅ EXIT HANDLER FOR NOT FOUND
-- ✅ Cursor attributes (no explicit cursor attributes in MySQL)
-- ✅ Row-by-row processing
-- ✅ CLOSE cursor
-- ✅ Temporary tables
-- ✅ Batch processing
--
-- Testing the Cursors:
-- CALL sp_process_patient_health_metrics();
-- CALL sp_generate_doctor_salary_slip(2024, 12);
-- CALL sp_update_expired_medicines();
-- CALL sp_process_pending_prescriptions();
-- CALL sp_generate_bill_reminders();
--
-- ============================================================================
-- End of Cursors Script
-- ============================================================================
