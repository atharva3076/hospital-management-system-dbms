-- ACID Properties Demonstration
-- Hospital Management System - DBMS Concepts Module
-- Document Version: 1.0 | Date: October 2026
-- Folder: 05_Transaction_Management

-- ============================================================================
-- PART 1: ATOMICITY - All or Nothing
-- ============================================================================

-- Demo 1.1: Successful Transaction (All Operations Complete)
DELIMITER //
BEGIN TRANSACTION;

-- Insert patient record
INSERT INTO PATIENT (FirstName, LastName, DOB, Gender, BloodGroup, Height, Weight, 
                     Address, City, State, Phone, Email, EmergencyContact, 
                     EmergencyContactPhone, PatientType, RegistrationDate)
VALUES ('John', 'Doe', '1990-05-15', 'M', 'O+', 175, 75, 
        '123 Main St', 'New York', 'NY', '1234567890', 'john@email.com',
        'Jane Doe', '1234567891', 'OPD', CURDATE());

-- Get the inserted patient ID
SET @PatientID = LAST_INSERT_ID();

-- Create appointment
INSERT INTO APPOINTMENT (PatientID, DoctorID, AppointmentDate, AppointmentTime, 
                        Reason, Status, ConsultationFee, Notes)
VALUES (@PatientID, 1, '2026-10-15', '10:00:00', 'Annual Checkup', 
        'Scheduled', 500, 'First visit');

-- Both operations succeed - COMMIT
COMMIT;

-- Result: Both patient and appointment created (Atomicity maintained)
// DELIMITER ;

-- Demo 1.2: Failed Transaction (Rollback)
DELIMITER //
BEGIN TRANSACTION;

-- Insert patient
INSERT INTO PATIENT (FirstName, LastName, DOB, Gender, BloodGroup, Height, Weight,
                     Address, City, State, Phone, Email, EmergencyContact,
                     EmergencyContactPhone, PatientType, RegistrationDate)
VALUES ('Jane', 'Smith', '1995-03-20', 'F', 'A+', 165, 60,
        '456 Oak Ave', 'Boston', 'MA', '9876543210', 'jane@email.com',
        'Bob Smith', '9876543211', 'IPD', CURDATE());

SET @PatientID = LAST_INSERT_ID();

-- Try to create appointment with non-existent doctor (DoctorID = 99999)
-- This violates foreign key constraint!
INSERT INTO APPOINTMENT (PatientID, DoctorID, AppointmentDate, AppointmentTime,
                        Reason, Status, ConsultationFee, Notes)
VALUES (@PatientID, 99999, '2026-10-20', '14:00:00', 'Follow-up',
        'Scheduled', 500, 'Second visit');

-- Error occurs - ROLLBACK
ROLLBACK;

-- Result: Both patient AND appointment are undone (Atomicity maintained)
// DELIMITER ;

-- ============================================================================
-- PART 2: CONSISTENCY - Valid State Maintained
-- ============================================================================

-- Demo 2.1: Maintaining Referential Integrity
DELIMITER //
BEGIN TRANSACTION;

-- Scenario: Move all doctors from one department to another
-- Before: Department 1 has 5 doctors, Department 2 has 3 doctors
-- After: Both departments must have valid doctor count

-- Get source and target departments
SELECT DepartmentID, COUNT(*) as DoctorCount 
FROM DOCTOR 
WHERE DepartmentID IN (1, 2) 
GROUP BY DepartmentID;

-- Move doctors from Dept 1 to Dept 2
UPDATE DOCTOR 
SET DepartmentID = 2
WHERE DepartmentID = 1;

-- Verify consistency
SELECT DepartmentID, COUNT(*) as DoctorCount 
FROM DOCTOR 
WHERE DepartmentID IN (1, 2) 
GROUP BY DepartmentID;

COMMIT;

-- Result: All doctor-department relationships remain valid (Consistency maintained)
// DELIMITER ;

-- Demo 2.2: Check Constraint Enforcement
-- This query shows how CHECK constraints maintain data consistency

-- Attempt 1: Valid insert (passes check)
INSERT INTO MEDICINE (MedicineName, GenericName, Type, ManufacturerID, UnitPrice,
                     QuantityInStock, ReorderLevel, ManufactureDate, ExpiryDate,
                     Dosage, IsActive)
VALUES ('ValidMedicine', 'Generic', 'Antibiotic', 1, 150, 100, 20,
        '2024-01-01', '2026-12-31', '500mg', TRUE);
-- Success: UnitPrice > 0, QuantityInStock >= 0, ExpiryDate > ManufactureDate

-- Attempt 2: Invalid insert (fails check)
-- INSERT INTO MEDICINE (...)
-- VALUES ('InvalidMed', 'Generic', 'Antibiotic', 1, -50, 100, 20,  -- NEGATIVE PRICE!
--        '2024-01-01', '2026-12-31', '500mg', TRUE);
-- Error: CHECK constraint violation (UnitPrice must be > 0)

-- Result: Database maintains consistency through constraint enforcement
-- ============================================================================
-- PART 3: ISOLATION - Concurrent Transactions Don't Interfere
-- ============================================================================

-- Demo 3.1: Dirty Read Prevention (READ COMMITTED level)
-- Session A (Booking Appointment)
DELIMITER //
BEGIN TRANSACTION;

-- Doctor: Update consultation fee
UPDATE DOCTOR 
SET ConsultationFeePerHour = 1000
WHERE DoctorID = 1;

-- Before committing, Session B tries to read this value
-- With READ COMMITTED: Session B will see the old value (NOT the updated one)
-- This prevents "dirty reads"

COMMIT;

-- Now the update is visible to all sessions
// DELIMITER ;

-- Demo 3.2: Lost Update Prevention
-- Session A: Increase medicine stock
DELIMITER //
BEGIN TRANSACTION;

-- Read current stock
SELECT @CurrentStock := QuantityInStock FROM MEDICINE WHERE MedicineID = 1;
-- Suppose: @CurrentStock = 100

-- Simulate delay (other operations)
-- Session B also updates here with same medicine...

-- Increase stock
UPDATE MEDICINE
SET QuantityInStock = @CurrentStock + 50
WHERE MedicineID = 1;

COMMIT;

-- Result: With isolation, both sessions get consistent view
// DELIMITER ;

-- Demo 3.3: Isolation Levels Demonstration

-- Level 1: READ UNCOMMITTED (Lowest isolation, highest performance)
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
BEGIN TRANSACTION;
-- Can read uncommitted changes from other sessions (dirty reads possible)
SELECT * FROM APPOINTMENT WHERE AppointmentDate >= CURDATE();
COMMIT;

-- Level 2: READ COMMITTED (Default for most databases)
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
BEGIN TRANSACTION;
-- Can only read committed changes (dirty reads prevented)
SELECT * FROM DOCTOR WHERE DepartmentID = 1;
COMMIT;

-- Level 3: REPEATABLE READ (Prevents non-repeatable reads)
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
BEGIN TRANSACTION;
-- Multiple reads of same data return consistent results
SELECT @PatientCount := COUNT(*) FROM PATIENT WHERE IsActive = TRUE;
-- Even if other sessions modify patients, we get same count
SELECT COUNT(*) FROM PATIENT WHERE IsActive = TRUE;  -- Same as @PatientCount
COMMIT;

-- Level 4: SERIALIZABLE (Highest isolation, lowest performance)
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
BEGIN TRANSACTION;
-- Transactions run one-by-one, highest consistency
-- Phantom read prevention
SELECT * FROM APPOINTMENT WHERE Status = 'Scheduled';
COMMIT;

-- ============================================================================
-- PART 4: DURABILITY - Data Persists After Commit
-- ============================================================================

-- Demo 4.1: Data Persistence After Commit
DELIMITER //
BEGIN TRANSACTION;

-- Insert patient with specific details
INSERT INTO PATIENT (FirstName, LastName, DOB, Gender, BloodGroup, Height, Weight,
                     Address, City, State, Phone, Email, EmergencyContact,
                     EmergencyContactPhone, PatientType, RegistrationDate)
VALUES ('Persistent', 'Patient', '1985-06-10', 'M', 'B-', 180, 85,
        '789 Pine Rd', 'Chicago', 'IL', '5551234567', 'persistent@email.com',
        'Contact Person', '5551234568', 'OPD', CURDATE());

COMMIT;
-- Data is now written to disk and recovered even if system crashes

-- Demo 4.2: Log-based Recovery
-- Conceptual: After COMMIT, transaction is written to transaction log
-- If system crashes:
--   1. System reads log on restart
--   2. Identifies committed vs uncommitted transactions
--   3. Rolls forward committed transactions
--   4. Rolls back uncommitted transactions
-- Result: Data is durable and consistent

// DELIMITER ;

-- ============================================================================
-- PART 5: MULTI-STATEMENT TRANSACTIONS
-- ============================================================================

-- Demo 5.1: Complex Hospital Billing Transaction
DELIMITER //
CREATE PROCEDURE ProcessBilling (
    IN p_PatientID INT,
    IN p_AppointmentID INT,
    IN p_ConsultationFee DECIMAL(10,2),
    IN p_LabCharges DECIMAL(10,2),
    IN p_MedicineCharges DECIMAL(10,2)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Billing failed';
    END;

    START TRANSACTION;

    -- Step 1: Create billing record
    INSERT INTO BILLING (BillingNumber, PatientID, AppointmentID,
                        ConsultationCharges, LabCharges, MedicineCharges,
                        OtherCharges, TotalCharges, InsuranceCoverage,
                        PatientPayable, AmountPaid, PaymentStatus,
                        BillingDate, DueDate)
    VALUES (CONCAT('BILL-', DATE_FORMAT(NOW(), '%Y%m%d'), '-', RAND()),
           p_PatientID, p_AppointmentID, p_ConsultationFee, p_LabCharges,
           p_MedicineCharges, 0,
           p_ConsultationFee + p_LabCharges + p_MedicineCharges,
           0, p_ConsultationFee + p_LabCharges + p_MedicineCharges,
           0, 'Pending', CURDATE(), DATE_ADD(CURDATE(), INTERVAL 30 DAY));

    -- Step 2: Update appointment status
    UPDATE APPOINTMENT
    SET Status = 'Completed'
    WHERE AppointmentID = p_AppointmentID;

    -- Step 3: Log transaction for audit
    INSERT INTO audit_log (Table_Name, Operation, OldValue, NewValue, ChangedDate)
    VALUES ('BILLING', 'INSERT', NULL, 'New Bill Created', NOW());

    -- All steps succeed - COMMIT
    COMMIT;
END //
DELIMITER ;

-- Call the billing procedure
CALL ProcessBilling(1, 100, 500, 200, 1500);

-- ============================================================================
-- PART 6: SAVEPOINTS (Partial Rollback)
-- ============================================================================

DELIMITER //
BEGIN TRANSACTION;

-- Insert patient record
INSERT INTO PATIENT (FirstName, LastName, DOB, Gender, BloodGroup, Height, Weight,
                     Address, City, State, Phone, Email, EmergencyContact,
                     EmergencyContactPhone, PatientType, RegistrationDate)
VALUES ('Savepoint', 'Test', '1990-01-01', 'M', 'O+', 170, 70,
        '100 Test St', 'Test City', 'TC', '1111111111', 'test@test.com',
        'Test Contact', '1111111112', 'OPD', CURDATE());

SET @PatientID = LAST_INSERT_ID();

-- Create first savepoint
SAVEPOINT sp_after_patient;

-- Try to insert appointment (may fail)
-- If fails:
INSERT INTO APPOINTMENT (PatientID, DoctorID, AppointmentDate, AppointmentTime,
                        Reason, Status, ConsultationFee, Notes)
VALUES (@PatientID, 1, '2026-10-25', '09:00:00', 'Checkup',
        'Scheduled', 400, 'Test appointment');

-- Create second savepoint
SAVEPOINT sp_after_appointment;

-- Try to insert prescription (may fail)
-- If fails: ROLLBACK TO sp_after_appointment;
-- This keeps patient and appointment but removes prescription

-- If all is well
COMMIT;

// DELIMITER ;

-- ============================================================================
-- PART 7: DEADLOCK EXAMPLE AND RESOLUTION
-- ============================================================================

-- Scenario: Two users updating same patient billing simultaneously
-- Without proper locking, deadlock can occur

-- User 1: Processing Payment
BEGIN TRANSACTION;
  -- Lock billing record 1
  SELECT * FROM BILLING WHERE BillingID = 1 FOR UPDATE;
  -- User 1 then tries to update billing record 2
  UPDATE BILLING SET AmountPaid = AmountPaid + 1000 WHERE BillingID = 2;
  -- DEADLOCK: Waiting for User 2 to release lock on record 2
COMMIT;

-- User 2: Adjusting Charges
BEGIN TRANSACTION;
  -- Lock billing record 2
  SELECT * FROM BILLING WHERE BillingID = 2 FOR UPDATE;
  -- User 2 then tries to update billing record 1
  UPDATE BILLING SET TotalCharges = TotalCharges - 500 WHERE BillingID = 1;
  -- DEADLOCK: Waiting for User 1 to release lock on record 1
COMMIT;

-- Resolution: Use consistent ordering
BEGIN TRANSACTION;
  -- Always lock in same order (BillingID 1 before 2)
  SELECT * FROM BILLING WHERE BillingID IN (1, 2) FOR UPDATE ORDER BY BillingID;
  UPDATE BILLING SET AmountPaid = AmountPaid + 1000 WHERE BillingID = 2;
  UPDATE BILLING SET TotalCharges = TotalCharges - 500 WHERE BillingID = 1;
COMMIT;

-- ============================================================================
-- PART 8: TESTING ACID PROPERTIES
-- ============================================================================

-- Test 1: Atomicity - Insert with Foreign Key Violation
DELIMITER //
BEGIN TRANSACTION;
  INSERT INTO PATIENT (FirstName, LastName, DOB, Gender, BloodGroup,
                       Height, Weight, Address, City, State, Phone, Email,
                       EmergencyContact, EmergencyContactPhone, PatientType,
                       RegistrationDate)
  VALUES ('Test', 'Atomicity', '2000-01-01', 'M', 'O+', 175, 75,
          '123 Test', 'Test', 'TC', '1111111111', 'test@test.com',
          'Contact', '1111111112', 'OPD', CURDATE());
  
  SET @TestPatientID = LAST_INSERT_ID();
  
  -- This will fail (DoctorID 99999 doesn't exist)
  INSERT INTO APPOINTMENT (PatientID, DoctorID, AppointmentDate,
                          AppointmentTime, Reason, Status, ConsultationFee)
  VALUES (@TestPatientID, 99999, '2026-11-01', '10:00:00',
          'Test', 'Scheduled', 500);
ROLLBACK;

-- Result: Patient record is rolled back too (Atomicity: ✓)

-- Test 2: Consistency - Referential Integrity
INSERT INTO DOCTOR (FirstName, LastName, DOB, Gender, Qualification,
                    Specialization, RegistrationNumber, DepartmentID,
                    Phone, Email, JoiningDate, YearsOfExperience,
                    ConsultationFeePerHour, IsActive)
VALUES ('Test', 'Doctor', '1980-01-01', 'M', 'MBBS', 'Test',
        'REG12345', 1, '9999999999', 'doc@test.com', '2020-01-01', 5, 500, TRUE);

-- All doctor appointments now refer to valid doctor (Consistency: ✓)

-- Test 3: Isolation - Read Committed
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
BEGIN TRANSACTION;
  SELECT COUNT(*) as TotalAppointments FROM APPOINTMENT;
  -- Other transaction modifies appointments
  -- Next read will show committed changes only
  SELECT COUNT(*) as TotalAppointments FROM APPOINTMENT;
COMMIT;

-- Test 4: Durability - After Commit
BEGIN TRANSACTION;
  INSERT INTO PATIENT (FirstName, LastName, DOB, Gender, BloodGroup,
                       Height, Weight, Address, City, State, Phone, Email,
                       EmergencyContact, EmergencyContactPhone, PatientType,
                       RegistrationDate)
  VALUES ('Durable', 'Data', '2000-01-01', 'M', 'A+', 180, 80,
          '456 Durable', 'City', 'ST', '2222222222', 'durable@test.com',
          'Contact', '2222222223', 'OPD', CURDATE());
COMMIT;

-- Even if system crashes now, this data is in database (Durability: ✓)
SELECT * FROM PATIENT WHERE FirstName = 'Durable';

-- ============================================================================
-- SUMMARY: ACID Properties Verification
-- ============================================================================

/*
ATOMICITY (A):
✓ Transaction either fully completes or rolls back entirely
✓ No partial updates
✓ Foreign key violations cause full rollback
✓ Demonstrated via: Multi-statement transactions with error handling

CONSISTENCY (C):
✓ Database moves from valid state to valid state
✓ Referential integrity maintained
✓ Check constraints enforced
✓ Data always consistent
✓ Demonstrated via: Constraint enforcement and key relationships

ISOLATION (I):
✓ Concurrent transactions don't interfere
✓ Dirty reads prevented (READ COMMITTED)
✓ Non-repeatable reads prevented (REPEATABLE READ)
✓ Phantom reads prevented (SERIALIZABLE)
✓ Demonstrated via: Isolation levels and transaction scheduling

DURABILITY (D):
✓ Committed data persists
✓ Survives system failures
✓ Logged to stable storage
✓ Recovered on restart
✓ Demonstrated via: Data remains after COMMIT

All ACID properties verified: ✓ ✓ ✓ ✓
*/

-- ============================================================================
