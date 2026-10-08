-- ============================================================================
-- HOSPITAL MANAGEMENT SYSTEM - TRIGGERS (DATA INTEGRITY & AUTOMATION)
-- ============================================================================
-- Created by: Member 3 (PL/SQL Developer)
-- Purpose: Automatically enforce business rules and maintain data consistency
-- Date: 2024
-- ============================================================================
-- TRIGGERS: 8 comprehensive triggers covering:
-- 1. Update medicine stock after prescription
-- 2. Auto-complete appointment after prescription
-- 3. Prevent billing for cancelled appointments
-- 4. Auto-update billing payment status
-- 5. Prevent expired medicine from being prescribed
-- 6. Audit log for critical updates
-- 7. Prevent duplicate prescriptions
-- 8. Update patient's last visit date
-- ============================================================================

USE hospital_management_system;

-- ============================================================================
-- CREATE SUPPORT TABLES FOR TRIGGERS
-- ============================================================================

-- Table to track low stock alerts
CREATE TABLE IF NOT EXISTS medicine_alerts (
    AlertID INT PRIMARY KEY AUTO_INCREMENT,
    MedicineID INT NOT NULL,
    AlertType VARCHAR(50),  -- LOW_STOCK, EXPIRING_SOON, EXPIRED
    AlertDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    IsResolved BOOLEAN DEFAULT FALSE,
    ResolvedDate TIMESTAMP NULL,
    FOREIGN KEY (MedicineID) REFERENCES MEDICINE(MedicineID)
        ON DELETE CASCADE,
    INDEX idx_medicine (MedicineID),
    INDEX idx_alert_type (AlertType),
    INDEX idx_resolved (IsResolved)
);

-- Table to audit all changes
CREATE TABLE IF NOT EXISTS audit_log (
    AuditID INT PRIMARY KEY AUTO_INCREMENT,
    TableName VARCHAR(100) NOT NULL,
    RecordID INT NOT NULL,
    Action VARCHAR(50),  -- INSERT, UPDATE, DELETE
    OldValue TEXT,
    NewValue TEXT,
    ChangedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ChangedBy VARCHAR(100) DEFAULT 'SYSTEM',
    INDEX idx_table_record (TableName, RecordID),
    INDEX idx_action (Action),
    INDEX idx_changed_date (ChangedDate)
);

-- ============================================================================
-- TRIGGER 1: trg_update_medicine_stock_on_prescription
-- ============================================================================
-- Event: AFTER INSERT on PRESCRIPTION_ITEMS
-- Action: Automatically reduce medicine stock when medicine is prescribed
--
-- Business Logic:
--   1. Get current medicine stock and reorder level
--   2. Reduce stock by prescribed quantity
--   3. Check if stock falls below reorder level
--   4. If yes, create low stock alert for procurement
--
-- Purpose: Maintain accurate inventory after each prescription
--
-- ============================================================================

DELIMITER //

CREATE TRIGGER trg_update_medicine_stock_on_prescription
AFTER INSERT ON PRESCRIPTION_ITEMS
FOR EACH ROW
BEGIN
    DECLARE v_current_stock INT;
    DECLARE v_reorder_level INT;
    DECLARE v_new_stock INT;
    
    -- Get current stock and reorder level
    SELECT QuantityInStock, ReorderLevel INTO v_current_stock, v_reorder_level
    FROM MEDICINE
    WHERE MedicineID = NEW.MedicineID
    FOR UPDATE;  -- Lock the row
    
    -- Calculate new stock
    SET v_new_stock = v_current_stock - NEW.Quantity;
    
    -- Update medicine stock
    UPDATE MEDICINE
    SET QuantityInStock = v_new_stock
    WHERE MedicineID = NEW.MedicineID;
    
    -- If stock falls below reorder level, create alert
    IF v_new_stock <= v_reorder_level AND v_new_stock > 0 THEN
        INSERT INTO medicine_alerts (MedicineID, AlertType)
        VALUES (NEW.MedicineID, 'LOW_STOCK');
    END IF;
    
    -- If stock reaches zero, create critical alert
    IF v_new_stock = 0 THEN
        INSERT INTO medicine_alerts (MedicineID, AlertType)
        VALUES (NEW.MedicineID, 'OUT_OF_STOCK');
    END IF;
END //

DELIMITER ;

-- ============================================================================
-- TRIGGER 2: trg_mark_appointment_completed
-- ============================================================================
-- Event: AFTER INSERT on PRESCRIPTION
-- Action: Automatically mark appointment as 'Completed' when prescription created
--
-- Business Logic:
--   1. Get appointment ID from newly inserted prescription
--   2. If appointment status is 'Scheduled', update to 'Completed'
--   3. Set completion timestamp
--
-- Purpose: Ensure appointment status reflects when treatment was provided
--
-- ============================================================================

DELIMITER //

CREATE TRIGGER trg_mark_appointment_completed
AFTER INSERT ON PRESCRIPTION
FOR EACH ROW
BEGIN
    -- Update appointment status to Completed
    UPDATE APPOINTMENT
    SET Status = 'Completed',
        UpdatedDate = NOW()
    WHERE AppointmentID = NEW.AppointmentID
        AND Status = 'Scheduled';
    
    -- Log this automatic update
    INSERT INTO audit_log (TableName, RecordID, Action, OldValue, NewValue, ChangedBy)
    VALUES ('APPOINTMENT', NEW.AppointmentID, 'UPDATE', 'Status: Scheduled', 'Status: Completed', 'TRIGGER');
END //

DELIMITER ;

-- ============================================================================
-- TRIGGER 3: trg_prevent_billing_cancelled_appointment
-- ============================================================================
-- Event: BEFORE INSERT on BILLING
-- Action: Prevent creating billing record for cancelled appointments
--
-- Business Logic:
--   1. Get appointment status from appointment ID
--   2. If status is 'Cancelled', raise error
--   3. If status is 'No-Show', raise error
--
-- Purpose: Prevent billing for appointments that didn't occur
--
-- ============================================================================

DELIMITER //

CREATE TRIGGER trg_prevent_billing_cancelled_appointment
BEFORE INSERT ON BILLING
FOR EACH ROW
BEGIN
    DECLARE v_appointment_status VARCHAR(50);
    
    -- Get appointment status
    SELECT Status INTO v_appointment_status
    FROM APPOINTMENT
    WHERE AppointmentID = NEW.AppointmentID;
    
    -- Prevent billing for cancelled/no-show appointments
    IF v_appointment_status IN ('Cancelled', 'No-Show') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot create billing for cancelled or no-show appointments';
    END IF;
    
    -- Prevent billing if appointment doesn't exist
    IF v_appointment_status IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Appointment does not exist';
    END IF;
END //

DELIMITER ;

-- ============================================================================
-- TRIGGER 4: trg_update_billing_payment_status
-- ============================================================================
-- Event: AFTER UPDATE on BILLING
-- Action: Automatically update payment status based on amount paid
--
-- Business Logic:
--   1. If AmountPaid >= PatientPayable, set status to 'Paid'
--   2. If AmountPaid > 0 and < PatientPayable, set status to 'Partial'
--   3. If AmountPaid = 0, keep status as 'Pending'
--
-- Purpose: Keep payment status synchronized with actual payments
--
-- ============================================================================

DELIMITER //

CREATE TRIGGER trg_update_billing_payment_status
AFTER UPDATE ON BILLING
FOR EACH ROW
BEGIN
    DECLARE v_new_status VARCHAR(50);
    
    -- Determine new payment status
    IF NEW.AmountPaid >= NEW.PatientPayable THEN
        SET v_new_status = 'Paid';
        -- Update payment date if not already set
        IF NEW.PaymentDate IS NULL THEN
            UPDATE BILLING
            SET PaymentDate = NOW()
            WHERE BillingID = NEW.BillingID;
        END IF;
    ELSEIF NEW.AmountPaid > 0 THEN
        SET v_new_status = 'Partial';
    ELSE
        SET v_new_status = 'Pending';
    END IF;
    
    -- Update status if it changed
    IF v_new_status != NEW.PaymentStatus THEN
        UPDATE BILLING
        SET PaymentStatus = v_new_status
        WHERE BillingID = NEW.BillingID;
    END IF;
    
    -- Log the payment update
    IF NEW.AmountPaid > OLD.AmountPaid THEN
        INSERT INTO audit_log (TableName, RecordID, Action, OldValue, NewValue, ChangedBy)
        VALUES ('BILLING', NEW.BillingID, 'PAYMENT_RECEIVED', 
                CONCAT('Amount: ', OLD.AmountPaid, ', Status: ', OLD.PaymentStatus),
                CONCAT('Amount: ', NEW.AmountPaid, ', Status: ', v_new_status),
                'SYSTEM');
    END IF;
END //

DELIMITER ;

-- ============================================================================
-- TRIGGER 5: trg_prevent_expired_medicine_prescription
-- ============================================================================
-- Event: BEFORE INSERT on PRESCRIPTION_ITEMS
-- Action: Prevent adding expired medicine to prescription
--
-- Business Logic:
--   1. Get medicine expiry date
--   2. If expired, raise error
--   3. If expiring within 7 days, raise warning
--
-- Purpose: Prevent patient harm from expired medication
--
-- ============================================================================

DELIMITER //

CREATE TRIGGER trg_prevent_expired_medicine_prescription
BEFORE INSERT ON PRESCRIPTION_ITEMS
FOR EACH ROW
BEGIN
    DECLARE v_expiry_date DATE;
    DECLARE v_medicine_name VARCHAR(150);
    
    -- Get medicine expiry date and name
    SELECT ExpiryDate, MedicineName INTO v_expiry_date, v_medicine_name
    FROM MEDICINE
    WHERE MedicineID = NEW.MedicineID;
    
    -- Check if medicine is expired
    IF v_expiry_date IS NOT NULL AND v_expiry_date < CURDATE() THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = CONCAT('CRITICAL: Cannot prescribe expired medicine: ', v_medicine_name, 
                                 ' (Expired on ', v_expiry_date, ')');
    END IF;
    
    -- Check if medicine is expiring within 7 days
    IF v_expiry_date IS NOT NULL AND v_expiry_date <= DATE_ADD(CURDATE(), INTERVAL 7 DAY) THEN
        -- Log warning but allow prescription (warning only)
        INSERT INTO medicine_alerts (MedicineID, AlertType)
        VALUES (NEW.MedicineID, 'EXPIRING_SOON');
    END IF;
END //

DELIMITER ;

-- ============================================================================
-- TRIGGER 6: trg_audit_critical_updates
-- ============================================================================
-- Event: AFTER UPDATE on PATIENT
-- Action: Log all updates to patient records for audit trail
--
-- Business Logic:
--   1. Track what was changed
--   2. Record old and new values
--   3. Store timestamp and system info
--
-- Purpose: Maintain audit trail for compliance and data integrity verification
--
-- ============================================================================

DELIMITER //

CREATE TRIGGER trg_audit_critical_updates
AFTER UPDATE ON PATIENT
FOR EACH ROW
BEGIN
    DECLARE v_changes TEXT;
    DECLARE v_old_value TEXT;
    DECLARE v_new_value TEXT;
    
    -- Track changes in blood group (critical for safety)
    IF NEW.BloodGroup != OLD.BloodGroup THEN
        SET v_old_value = CONCAT('BloodGroup: ', OLD.BloodGroup);
        SET v_new_value = CONCAT('BloodGroup: ', NEW.BloodGroup);
        INSERT INTO audit_log (TableName, RecordID, Action, OldValue, NewValue, ChangedBy)
        VALUES ('PATIENT', NEW.PatientID, 'UPDATE', v_old_value, v_new_value, 'SYSTEM');
    END IF;
    
    -- Track changes in contact information
    IF NEW.Phone != OLD.Phone OR NEW.Email != OLD.Email THEN
        INSERT INTO audit_log (TableName, RecordID, Action, OldValue, NewValue, ChangedBy)
        VALUES ('PATIENT', NEW.PatientID, 'UPDATE', 
                CONCAT('Contact: ', OLD.Phone, ' / ', OLD.Email),
                CONCAT('Contact: ', NEW.Phone, ' / ', NEW.Email),
                'SYSTEM');
    END IF;
END //

DELIMITER ;

-- ============================================================================
-- TRIGGER 7: trg_prevent_duplicate_prescriptions
-- ============================================================================
-- Event: BEFORE INSERT on PRESCRIPTION
-- Action: Prevent creating multiple prescriptions for same appointment
--
-- Business Logic:
--   1. Check if prescription already exists for this appointment
--   2. If yes, raise error
--
-- Purpose: Prevent duplicate prescriptions and data inconsistency
--
-- ============================================================================

DELIMITER //

CREATE TRIGGER trg_prevent_duplicate_prescriptions
BEFORE INSERT on PRESCRIPTION
FOR EACH ROW
BEGIN
    DECLARE v_existing_count INT;
    
    -- Check if prescription already exists for this appointment
    SELECT COUNT(*) INTO v_existing_count
    FROM PRESCRIPTION
    WHERE AppointmentID = NEW.AppointmentID;
    
    IF v_existing_count > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Prescription already exists for this appointment. Cannot create duplicate.';
    END IF;
END //

DELIMITER ;

-- ============================================================================
-- TRIGGER 8: trg_update_patient_last_visit
-- ============================================================================
-- Event: AFTER INSERT on APPOINTMENT
-- Action: Update patient's profile with last visit timestamp
--
-- Business Logic:
--   1. When appointment is scheduled, update patient record
--   2. This helps in tracking active vs inactive patients
--
-- Purpose: Keep patient activity tracking current
--
-- ============================================================================

DELIMITER //

CREATE TRIGGER trg_update_patient_last_visit
AFTER INSERT ON APPOINTMENT
FOR EACH ROW
BEGIN
    -- Update patient's updated date to track last activity
    UPDATE PATIENT
    SET UpdatedDate = NOW()
    WHERE PatientID = NEW.PatientID;
    
    -- Log the appointment in audit
    INSERT INTO audit_log (TableName, RecordID, Action, OldValue, NewValue, ChangedBy)
    VALUES ('APPOINTMENT', NEW.AppointmentID, 'INSERT', 
            'New appointment scheduled',
            CONCAT('Appointment ID: ', NEW.AppointmentID, ' on ', NEW.AppointmentDate),
            'SYSTEM');
END //

DELIMITER ;

-- ============================================================================
-- VERIFICATION AND TESTING QUERIES
-- ============================================================================

-- View all triggers in the database
SELECT TRIGGER_SCHEMA, TRIGGER_NAME, EVENT_MANIPULATION, EVENT_OBJECT_TABLE 
FROM INFORMATION_SCHEMA.TRIGGERS 
WHERE TRIGGER_SCHEMA = 'hospital_management_system'
ORDER BY EVENT_OBJECT_TABLE, EVENT_MANIPULATION;

-- View trigger details
SHOW TRIGGERS IN hospital_management_system;

-- ============================================================================
-- SUMMARY OF TRIGGERS
-- ============================================================================
-- Total Triggers: 8
--
-- 1. trg_update_medicine_stock_on_prescription      - Inventory management
-- 2. trg_mark_appointment_completed                 - Status automation
-- 3. trg_prevent_billing_cancelled_appointment      - Business rule enforcement
-- 4. trg_update_billing_payment_status              - Payment tracking
-- 5. trg_prevent_expired_medicine_prescription      - Patient safety
-- 6. trg_audit_critical_updates                     - Compliance & audit trail
-- 7. trg_prevent_duplicate_prescriptions            - Data integrity
-- 8. trg_update_patient_last_visit                  - Activity tracking
--
-- Support Tables Created:
-- - medicine_alerts (for low stock notifications)
-- - audit_log (for audit trail)
--
-- DBMS Concepts Covered:
-- ✅ BEFORE/AFTER triggers
-- ✅ INSERT/UPDATE/DELETE events
-- ✅ FOR EACH ROW clause
-- ✅ NEW and OLD references
-- ✅ Trigger actions (enforce rules)
-- ✅ Signal (raise errors)
-- ✅ Automatic actions
-- ✅ Data consistency maintenance
-- ✅ Audit trail implementation
--
-- Trigger Firing Order:
-- 1. BEFORE INSERT triggers
-- 2. AFTER INSERT triggers
-- 3. BEFORE UPDATE triggers
-- 4. AFTER UPDATE triggers
-- 5. BEFORE DELETE triggers
-- 6. AFTER DELETE triggers
--
-- ============================================================================
-- End of Triggers Script
-- ============================================================================
