-- ============================================================================
-- HOSPITAL MANAGEMENT SYSTEM - CONSTRAINTS AND KEYS
-- Member 2: SQL Schema Developer
-- ============================================================================
-- Purpose: Apply all constraints, keys, and validations to tables
-- This script ensures data integrity and enforces business rules
-- ============================================================================

USE hospital_management_system;

-- ============================================================================
-- VERIFY ALL TABLES EXIST BEFORE APPLYING CONSTRAINTS
-- ============================================================================

SHOW TABLES;

-- ============================================================================
-- CONSTRAINT 1: DEPARTMENT TABLE ENHANCEMENTS
-- ============================================================================
-- Add check constraints for department floor numbers

ALTER TABLE DEPARTMENT 
ADD CONSTRAINT chk_dept_floor CHECK (Floor >= 0 AND Floor <= 10),
ADD CONSTRAINT chk_dept_max_beds CHECK (MaxBeds > 0);

-- Add unique constraint on department email
ALTER TABLE DEPARTMENT 
ADD UNIQUE KEY unique_dept_email (Email);

-- ============================================================================
-- CONSTRAINT 2: DOCTOR TABLE ENHANCEMENTS
-- ============================================================================
-- Add check constraints for doctor data

ALTER TABLE DOCTOR
ADD CONSTRAINT chk_doctor_experience CHECK (YearsOfExperience >= 0),
ADD CONSTRAINT chk_doctor_fee CHECK (ConsultationFee > 0);

-- Create index on doctor name for full text search capability
ALTER TABLE DOCTOR
ADD UNIQUE KEY unique_doctor_license (LicenseNumber);

-- ============================================================================
-- CONSTRAINT 3: DOCTOR_SCHEDULE TABLE ENHANCEMENTS
-- ============================================================================
-- Ensure end time is after start time

ALTER TABLE DOCTOR_SCHEDULE
ADD CONSTRAINT chk_schedule_time CHECK (EndTime > StartTime),
ADD CONSTRAINT chk_schedule_appointments CHECK (MaxAppointmentsPerDay > 0);

-- ============================================================================
-- CONSTRAINT 4: PATIENT TABLE ENHANCEMENTS
-- ============================================================================
-- Add check constraints for patient demographics

ALTER TABLE PATIENT
ADD CONSTRAINT chk_patient_dob CHECK (DateOfBirth <= CURDATE()),
ADD CONSTRAINT chk_patient_blood_group CHECK (
    BloodGroup IS NULL 
    OR BloodGroup IN ('A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-')
);

-- Ensure emergency contact is different from patient (optional validation)
-- Additional validation can be done at application level

-- ============================================================================
-- CONSTRAINT 5: APPOINTMENT TABLE ENHANCEMENTS
-- ============================================================================
-- Add check constraints for appointments

ALTER TABLE APPOINTMENT
ADD CONSTRAINT chk_appointment_date CHECK (AppointmentDate >= CURDATE()),
ADD CONSTRAINT chk_appointment_duration CHECK (EstimatedDuration > 0),
ADD CONSTRAINT chk_appointment_actual_duration CHECK (ActualDuration IS NULL OR ActualDuration > 0);

-- Ensure room number format is valid (optional)
-- Example: ALTER TABLE APPOINTMENT ADD CONSTRAINT chk_room_number CHECK (RoomNumber REGEXP '^[0-9]{3}$');

-- ============================================================================
-- CONSTRAINT 6: MEDICAL_HISTORY TABLE ENHANCEMENTS
-- ============================================================================
-- Medical history table mostly relies on referential integrity

-- Add check for non-empty diagnosis and symptoms
-- This is better enforced at application level with NOT NULL

-- ============================================================================
-- CONSTRAINT 7: LAB_TEST TABLE ENHANCEMENTS
-- ============================================================================
-- Add check constraints for lab tests

ALTER TABLE LAB_TEST
ADD CONSTRAINT chk_lab_cost CHECK (CostPrice > 0),
ADD CONSTRAINT chk_lab_turnaround CHECK (TurnaroundDays > 0);

-- ============================================================================
-- CONSTRAINT 8: LAB_REPORT TABLE ENHANCEMENTS
-- ============================================================================
-- Add check constraints for lab reports

ALTER TABLE LAB_REPORT
ADD CONSTRAINT chk_lab_report_date CHECK (TestDate <= CURDATE()),
ADD CONSTRAINT chk_lab_normal_range CHECK (
    (NormalRangeMin IS NULL AND NormalRangeMax IS NULL)
    OR 
    (NormalRangeMin IS NOT NULL AND NormalRangeMax IS NOT NULL AND NormalRangeMin <= NormalRangeMax)
);

-- ============================================================================
-- CONSTRAINT 9: MEDICINE TABLE ENHANCEMENTS
-- ============================================================================
-- Add check constraints for medicine inventory

ALTER TABLE MEDICINE
ADD CONSTRAINT chk_medicine_price CHECK (UnitPrice > 0),
ADD CONSTRAINT chk_medicine_quantity CHECK (QuantityInStock >= 0),
ADD CONSTRAINT chk_medicine_stock_levels CHECK (
    MinimumStock >= 0 AND ReorderLevel >= MinimumStock
),
ADD CONSTRAINT chk_medicine_expiry CHECK (ExpiryDate > CURDATE());

-- Ensure medicine type is valid
ALTER TABLE MEDICINE
ADD CONSTRAINT chk_medicine_type CHECK (
    Type IN ('Tablet', 'Capsule', 'Injection', 'Syrup', 'Liquid', 'Powder', 'Cream', 'Ointment', 'Other')
);

-- ============================================================================
-- CONSTRAINT 10: PRESCRIPTION TABLE ENHANCEMENTS
-- ============================================================================
-- Add check constraints for prescriptions

ALTER TABLE PRESCRIPTION
ADD CONSTRAINT chk_prescription_expiry CHECK (
    ExpiryDate IS NULL OR ExpiryDate > CreatedDate
),
ADD CONSTRAINT chk_prescription_refills CHECK (
    RefillsAllowed >= 0 AND RefillsUsed >= 0 AND RefillsUsed <= RefillsAllowed
);

-- ============================================================================
-- CONSTRAINT 11: PRESCRIPTION_ITEMS TABLE ENHANCEMENTS
-- ============================================================================
-- Add check constraints for prescription items

ALTER TABLE PRESCRIPTION_ITEMS
ADD CONSTRAINT chk_prescription_item_duration CHECK (Duration > 0),
ADD CONSTRAINT chk_prescription_item_quantity CHECK (Quantity > 0);

-- Validate frequency format (optional constraint)
ALTER TABLE PRESCRIPTION_ITEMS
ADD CONSTRAINT chk_prescription_frequency CHECK (
    Frequency IN (
        'Once Daily', 'Twice Daily', 'Thrice Daily', 'Four Times Daily',
        'Every 6 hours', 'Every 8 hours', 'Every 12 hours',
        'Once Weekly', 'Twice Weekly',
        'As Needed', 'Before Meals', 'After Meals'
    )
);

-- ============================================================================
-- CONSTRAINT 12: BILLING TABLE ENHANCEMENTS
-- ============================================================================
-- Add check constraints for billing

ALTER TABLE BILLING
ADD CONSTRAINT chk_billing_fee CHECK (ConsultationFee >= 0),
ADD CONSTRAINT chk_billing_lab_fee CHECK (LabTestFee >= 0),
ADD CONSTRAINT chk_billing_medicine CHECK (MedicineCost >= 0),
ADD CONSTRAINT chk_billing_other CHECK (OtherCharges >= 0),
ADD CONSTRAINT chk_billing_discount CHECK (Discount >= 0),
ADD CONSTRAINT chk_billing_tax CHECK (TaxAmount >= 0),
ADD CONSTRAINT chk_billing_amount CHECK (TotalAmount >= 0),
ADD CONSTRAINT chk_billing_paid CHECK (AmountPaid >= 0),
ADD CONSTRAINT chk_billing_payable CHECK (PatientPayable >= 0),
ADD CONSTRAINT chk_billing_insurance CHECK (InsuranceCoverageAmount >= 0);

-- Ensure total amount calculation is valid
ALTER TABLE BILLING
ADD CONSTRAINT chk_billing_calculation CHECK (
    TotalAmount = (ConsultationFee + LabTestFee + MedicineCost + OtherCharges + TaxAmount - Discount)
);

-- Ensure due date is after billing date
ALTER TABLE BILLING
ADD CONSTRAINT chk_billing_due_date CHECK (
    DueDate IS NULL OR DueDate >= BillingDate
);

-- ============================================================================
-- CONSTRAINT 13: INSURANCE TABLE ENHANCEMENTS
-- ============================================================================
-- Add check constraints for insurance

ALTER TABLE INSURANCE
ADD CONSTRAINT chk_insurance_coverage CHECK (CoveragePercentage >= 0 AND CoveragePercentage <= 100),
ADD CONSTRAINT chk_insurance_limit CHECK (CoverageLimit IS NULL OR CoverageLimit > 0),
ADD CONSTRAINT chk_insurance_dates CHECK (ValidFromDate < ValidToDate),
ADD CONSTRAINT chk_insurance_claims CHECK (ClaimsProcessed >= 0),
ADD CONSTRAINT chk_insurance_amount CHECK (TotalClaimsAmount >= 0),
ADD CONSTRAINT chk_insurance_remaining CHECK (RemainingCoverage IS NULL OR RemainingCoverage >= 0);

-- Validate policy type
ALTER TABLE INSURANCE
ADD CONSTRAINT chk_insurance_type CHECK (
    PolicyType IS NULL OR PolicyType IN ('Individual', 'Family', 'Group', 'Senior Citizen', 'Student')
);

-- ============================================================================
-- ADD UNIQUE CONSTRAINTS
-- ============================================================================

-- Email must be unique across doctors
ALTER TABLE DOCTOR 
ADD UNIQUE KEY unique_doctor_email (Email);

-- Phone must be unique for patients
ALTER TABLE PATIENT
ADD UNIQUE KEY unique_patient_phone (Phone);

-- Policy number must be unique for insurance
ALTER TABLE INSURANCE
ADD UNIQUE KEY unique_policy_number (PolicyNumber);

-- ============================================================================
-- ADD DEFAULT VALUES FOR TIMESTAMPS
-- ============================================================================
-- Already added in table creation, but verify:
-- LastModifiedDate should auto-update on every row modification

-- ============================================================================
-- CREATE AUDIT TABLES FOR TRACKING CHANGES
-- ============================================================================

CREATE TABLE IF NOT EXISTS change_log (
    LogID INT PRIMARY KEY AUTO_INCREMENT COMMENT 'Unique log identifier',
    TableName VARCHAR(100) NOT NULL COMMENT 'Table name where change occurred',
    RecordID INT NOT NULL COMMENT 'ID of record that changed',
    ChangeType ENUM('INSERT', 'UPDATE', 'DELETE') NOT NULL COMMENT 'Type of change',
    OldValue TEXT COMMENT 'Old value before change',
    NewValue TEXT COMMENT 'New value after change',
    ChangedBy VARCHAR(100) DEFAULT CURRENT_USER COMMENT 'User who made change',
    ChangedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'When change was made',
    INDEX idx_table_record (TableName, RecordID),
    INDEX idx_date (ChangedDate)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Audit trail for all table changes';

-- ============================================================================
-- REFERENTIAL INTEGRITY VERIFICATION
-- ============================================================================
-- Verify all foreign key relationships are properly established

SELECT 
    CONSTRAINT_NAME,
    TABLE_NAME,
    COLUMN_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'hospital_management_system'
AND REFERENCED_TABLE_NAME IS NOT NULL
ORDER BY TABLE_NAME, CONSTRAINT_NAME;

-- ============================================================================
-- SUMMARY OF CONSTRAINTS AND KEYS
-- ============================================================================
/*

PRIMARY KEY CONSTRAINTS:
- All 14 tables have auto-increment primary keys (Good for surrogate keys)
- Examples: DoctorID, PatientID, AppointmentID, etc.

FOREIGN KEY CONSTRAINTS:
- DOCTOR → DEPARTMENT (One-to-Many)
- DOCTOR_SCHEDULE → DOCTOR (One-to-Many)
- APPOINTMENT → DOCTOR, PATIENT (Many-to-One relationships)
- MEDICAL_HISTORY → PATIENT, APPOINTMENT
- LAB_REPORT → PATIENT, LAB_TEST, APPOINTMENT
- PRESCRIPTION → APPOINTMENT, DOCTOR, PATIENT
- PRESCRIPTION_ITEMS → PRESCRIPTION, MEDICINE
- BILLING → PATIENT, APPOINTMENT
- INSURANCE → PATIENT, BILLING
- MEDICINE → MANUFACTURER

UNIQUE CONSTRAINTS:
- DEPARTMENT.DeptName (Department names must be unique)
- DOCTOR.Email, DOCTOR.Phone, DOCTOR.LicenseNumber (Professional identifiers)
- PATIENT.Phone, PATIENT.Email (Contact information)
- LAB_TEST.TestName (Test names must be unique)
- MEDICINE.MedicineName (Medicine names must be unique)
- PRESCRIPTION.PolicyNumber (Insurance policy numbers)
- APPOINTMENT.unique_appointment (Prevent double booking)
- DOCTOR_SCHEDULE.unique_doctor_day (One schedule per doctor per day)

CHECK CONSTRAINTS:
- Numeric ranges (experience >= 0, fees > 0, quantities > 0)
- Date constraints (DOB in past, dates in valid sequence)
- Enum validations (Blood group, Gender, Status fields)
- Calculated field validations (Total amount calculations)
- Business rule constraints (time ranges, stock levels)

NOT NULL CONSTRAINTS:
- Applied to all mandatory fields (FirstName, LastName, etc.)
- Defined in table creation DDL statements

DEFAULT VALUES:
- Timestamps: CreatedDate (CURRENT_TIMESTAMP), LastModifiedDate (AUTO UPDATE)
- Boolean: IsActive = TRUE
- Numeric: Quantities = 0, Counts = 0
- Text: Enum fields have sensible defaults ('Active', 'Scheduled', etc.)

REFERENTIAL INTEGRITY ACTIONS:
- ON DELETE RESTRICT: Prevent deletion if referenced (for important records)
- ON DELETE CASCADE: Delete child records (for prescriptions, schedule, history)
- ON DELETE SET NULL: Set FK to NULL (for optional references)

*/

-- ============================================================================
-- VERIFY ALL CONSTRAINTS ARE IN PLACE
-- ============================================================================

-- Count all constraints
SELECT 
    'PRIMARY KEYS' as ConstraintType,
    COUNT(*) as Count
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
WHERE TABLE_SCHEMA = 'hospital_management_system'
AND CONSTRAINT_TYPE = 'PRIMARY KEY'
UNION ALL
SELECT 
    'FOREIGN KEYS',
    COUNT(*)
FROM INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS
WHERE CONSTRAINT_SCHEMA = 'hospital_management_system'
UNION ALL
SELECT 
    'UNIQUE CONSTRAINTS',
    COUNT(*)
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
WHERE TABLE_SCHEMA = 'hospital_management_system'
AND CONSTRAINT_TYPE = 'UNIQUE'
UNION ALL
SELECT 
    'CHECK CONSTRAINTS',
    COUNT(*)
FROM INFORMATION_SCHEMA.CHECK_CONSTRAINTS
WHERE CONSTRAINT_SCHEMA = 'hospital_management_system';

-- ============================================================================
-- TEST CONSTRAINTS (Uncomment to run tests)
-- ============================================================================

/*

-- TEST 1: Try to insert doctor with invalid department (should fail)
INSERT INTO DOCTOR (FirstName, LastName, Qualification, Specialization, DepartmentID, Phone, Email)
VALUES ('Test', 'Doctor', 'MD', 'Cardiology', 9999, '1234567890', 'test@email.com');
-- Expected: Error - Foreign key constraint fails

-- TEST 2: Try to set future date of birth (should fail)
INSERT INTO PATIENT (FirstName, LastName, DateOfBirth, Gender, Address, Phone, EmergencyContactName, EmergencyContactPhone)
VALUES ('Test', 'Patient', '2030-01-01', 'Male', 'Address', '9876543210', 'Emergency', '9876543211');
-- Expected: Error - Check constraint violation

-- TEST 3: Try to insert invalid blood group (should fail)
INSERT INTO PATIENT (FirstName, LastName, DateOfBirth, Gender, BloodGroup, Address, Phone, EmergencyContactName, EmergencyContactPhone)
VALUES ('Test', 'Patient', '1990-01-01', 'Male', 'XY+', 'Address', '9876543210', 'Emergency', '9876543211');
-- Expected: Error - Check constraint violation

-- TEST 4: Try to create duplicate email (should fail)
INSERT INTO DOCTOR (FirstName, LastName, Qualification, Specialization, DepartmentID, Phone, Email)
VALUES ('Another', 'Doctor', 'MD', 'Neurology', 1, '9876543210', 'existing@email.com');
-- Expected: Error - Unique constraint violation

-- TEST 5: Ensure referential integrity
INSERT INTO APPOINTMENT (PatientID, DoctorID, AppointmentDate, AppointmentTime, ReasonForVisit)
VALUES (9999, 1, '2024-02-15', '10:00', 'Check-up');
-- Expected: Error - Cannot add child row (PatientID 9999 doesn't exist)

*/

-- ============================================================================
-- END OF CONSTRAINTS AND KEYS SCRIPT
-- ============================================================================
-- Total Constraints Applied: 40+
-- Referential Integrity: Fully Implemented
-- Data Validation: Complete
-- ============================================================================

-- Display success message
SELECT '✓ All Constraints and Keys Applied Successfully!' as Status;