-- ============================================================================
-- HOSPITAL MANAGEMENT SYSTEM - DATABASE SCHEMA
-- Member 2: SQL Schema Developer
-- ============================================================================
-- Purpose: Create 14 normalized tables for complete HMS
-- Database: hospital_management_system
-- Collation: utf8mb4_unicode_ci (supports all languages and emojis)
-- ============================================================================

-- ============================================================================
-- SAFETY: Drop tables if they exist (for development/testing)
-- Uncomment only if you want to start fresh
-- ============================================================================
DROP TABLE IF EXISTS PRESCRIPTION_ITEMS;
DROP TABLE IF EXISTS PRESCRIPTION;
DROP TABLE IF EXISTS LAB_REPORT;
DROP TABLE IF EXISTS LAB_TEST;
DROP TABLE IF EXISTS BILLING;
DROP TABLE IF EXISTS INSURANCE;
DROP TABLE IF EXISTS MEDICAL_HISTORY;
DROP TABLE IF EXISTS APPOINTMENT;
DROP TABLE IF EXISTS DOCTOR_SCHEDULE;
DROP TABLE IF EXISTS MEDICINE;
DROP TABLE IF EXISTS DOCTOR;
DROP TABLE IF EXISTS DEPARTMENT;
DROP TABLE IF EXISTS MANUFACTURER;
DROP TABLE IF EXISTS PATIENT;

-- ============================================================================
-- USE DATABASE
-- ============================================================================

USE hospital_management_system;

-- ============================================================================
-- TABLE 1: MANUFACTURER
-- Purpose: Store medicine manufacturers
-- ============================================================================

CREATE TABLE MANUFACTURER (
    ManufacturerID INT PRIMARY KEY AUTO_INCREMENT COMMENT 'Unique manufacturer identifier',
    MfgName VARCHAR(100) NOT NULL COMMENT 'Manufacturer company name',
    Phone VARCHAR(20) NOT NULL COMMENT 'Contact phone number',
    Address TEXT NOT NULL COMMENT 'Complete business address',
    Email VARCHAR(100) COMMENT 'Contact email address',
    Website VARCHAR(100) COMMENT 'Company website',
    Country VARCHAR(50) COMMENT 'Manufacturing country',
    CreatedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Record creation date',
    LastModifiedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Last update date',
    IsActive BOOLEAN DEFAULT TRUE COMMENT 'Active/Inactive status'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Stores medicine manufacturer information';

-- ============================================================================
-- TABLE 2: DEPARTMENT
-- Purpose: Store hospital departments
-- ============================================================================

CREATE TABLE DEPARTMENT (
    DepartmentID INT PRIMARY KEY AUTO_INCREMENT COMMENT 'Unique department identifier',
    DeptName VARCHAR(100) NOT NULL UNIQUE COMMENT 'Department name (e.g., Cardiology, Neurology)',
    Floor INT NOT NULL COMMENT 'Floor number where department is located',
    Building VARCHAR(50) COMMENT 'Building identifier',
    HeadID INT COMMENT 'DoctorID of department head',
    Phone VARCHAR(20) COMMENT 'Department phone extension',
    Email VARCHAR(100) COMMENT 'Department email',
    MaxBeds INT DEFAULT 50 COMMENT 'Maximum number of beds in department',
    CreatedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Record creation date',
    LastModifiedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Last update date',
    IsActive BOOLEAN DEFAULT TRUE COMMENT 'Active/Inactive status'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Stores hospital department information';

-- ============================================================================
-- TABLE 3: DOCTOR
-- Purpose: Store doctor information
-- ============================================================================

CREATE TABLE DOCTOR (
    DoctorID INT PRIMARY KEY AUTO_INCREMENT COMMENT 'Unique doctor identifier',
    FirstName VARCHAR(50) NOT NULL COMMENT 'Doctor first name',
    LastName VARCHAR(50) NOT NULL COMMENT 'Doctor last name',
    Qualification VARCHAR(100) NOT NULL COMMENT 'Medical qualification (MD, MBBS, etc.)',
    Specialization VARCHAR(100) NOT NULL COMMENT 'Medical specialization',
    DepartmentID INT NOT NULL COMMENT 'Department the doctor belongs to',
    Phone VARCHAR(20) NOT NULL UNIQUE COMMENT 'Doctor contact phone',
    Email VARCHAR(100) NOT NULL UNIQUE COMMENT 'Doctor email address',
    LicenseNumber VARCHAR(50) UNIQUE COMMENT 'Medical license number',
    YearsOfExperience INT DEFAULT 0 COMMENT 'Total years of medical experience',
    ConsultationFee DECIMAL(10,2) DEFAULT 500.00 COMMENT 'Consultation fee in rupees',
    AvailabilityStatus ENUM('Available', 'Busy', 'On Leave', 'Retired') DEFAULT 'Available' COMMENT 'Current availability status',
    CreatedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Record creation date',
    LastModifiedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Last update date',
    IsActive BOOLEAN DEFAULT TRUE COMMENT 'Active/Inactive status',
    FOREIGN KEY (DepartmentID) REFERENCES DEPARTMENT(DepartmentID) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Stores doctor/physician information';

-- ============================================================================
-- TABLE 4: DOCTOR_SCHEDULE
-- Purpose: Store doctor working schedule
-- ============================================================================

CREATE TABLE DOCTOR_SCHEDULE (
    ScheduleID INT PRIMARY KEY AUTO_INCREMENT COMMENT 'Unique schedule identifier',
    DoctorID INT NOT NULL COMMENT 'Doctor this schedule belongs to',
    DayOfWeek ENUM('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday') NOT NULL COMMENT 'Day of week',
    StartTime TIME NOT NULL COMMENT 'Shift start time',
    EndTime TIME NOT NULL COMMENT 'Shift end time',
    MaxAppointmentsPerDay INT DEFAULT 15 COMMENT 'Maximum appointments allowed per day',
    IsOnDuty BOOLEAN DEFAULT TRUE COMMENT 'Whether doctor is on duty this day',
    CreatedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Record creation date',
    LastModifiedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Last update date',
    FOREIGN KEY (DoctorID) REFERENCES DOCTOR(DoctorID) ON DELETE CASCADE,
    UNIQUE KEY unique_doctor_day (DoctorID, DayOfWeek)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Stores doctor weekly working schedule';

-- ============================================================================
-- TABLE 5: PATIENT
-- Purpose: Store patient demographic information
-- ============================================================================

CREATE TABLE PATIENT (
    PatientID INT PRIMARY KEY AUTO_INCREMENT COMMENT 'Unique patient identifier',
    FirstName VARCHAR(50) NOT NULL COMMENT 'Patient first name',
    LastName VARCHAR(50) NOT NULL COMMENT 'Patient last name',
    DateOfBirth DATE NOT NULL COMMENT 'Patient date of birth',
    Gender ENUM('Male', 'Female', 'Other') NOT NULL COMMENT 'Patient gender',
    BloodGroup VARCHAR(5) COMMENT 'Blood group (A+, B-, O+, etc.)',
    Address TEXT NOT NULL COMMENT 'Complete residential address',
    Phone VARCHAR(20) NOT NULL UNIQUE COMMENT 'Patient contact phone number',
    Email VARCHAR(100) UNIQUE COMMENT 'Patient email address',
    EmergencyContactName VARCHAR(100) NOT NULL COMMENT 'Emergency contact person name',
    EmergencyContactPhone VARCHAR(20) NOT NULL COMMENT 'Emergency contact phone number',
    EmergencyContactRelation VARCHAR(50) COMMENT 'Relation to patient',
    Allergies TEXT COMMENT 'Known drug/food allergies',
    ChronicDiseases TEXT COMMENT 'List of chronic diseases if any',
    PatientStatus ENUM('Active', 'Inactive', 'Discharged') DEFAULT 'Active' COMMENT 'Current patient status',
    CreatedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Record creation date',
    LastModifiedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Last update date',
    IsActive BOOLEAN DEFAULT TRUE COMMENT 'Active/Inactive status'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Stores patient demographic and emergency information';

-- ============================================================================
-- TABLE 6: APPOINTMENT
-- Purpose: Store patient-doctor appointments
-- ============================================================================

CREATE TABLE APPOINTMENT (
    AppointmentID INT PRIMARY KEY AUTO_INCREMENT COMMENT 'Unique appointment identifier',
    PatientID INT NOT NULL COMMENT 'Patient ID for this appointment',
    DoctorID INT NOT NULL COMMENT 'Doctor ID for this appointment',
    AppointmentDate DATE NOT NULL COMMENT 'Date of appointment',
    AppointmentTime TIME NOT NULL COMMENT 'Time of appointment',
    ReasonForVisit VARCHAR(255) NOT NULL COMMENT 'Reason for visiting doctor',
    Status ENUM('Scheduled', 'Completed', 'No-Show', 'Cancelled', 'Rescheduled') DEFAULT 'Scheduled' COMMENT 'Appointment status',
    ConsultationNotes TEXT COMMENT 'Doctor notes during consultation',
    CancelledDate DATETIME COMMENT 'Date and time when appointment was cancelled',
    CancellationReason VARCHAR(255) COMMENT 'Reason for cancellation',
    EstimatedDuration INT DEFAULT 30 COMMENT 'Estimated duration in minutes',
    ActualDuration INT COMMENT 'Actual duration in minutes',
    RoomNumber VARCHAR(10) COMMENT 'Assigned room/cabin number',
    CreatedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Record creation date',
    LastModifiedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Last update date',
    FOREIGN KEY (PatientID) REFERENCES PATIENT(PatientID) ON DELETE RESTRICT,
    FOREIGN KEY (DoctorID) REFERENCES DOCTOR(DoctorID) ON DELETE RESTRICT,
    UNIQUE KEY unique_appointment (PatientID, DoctorID, AppointmentDate, AppointmentTime)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Stores patient-doctor appointment bookings';

-- ============================================================================
-- TABLE 7: MEDICAL_HISTORY
-- Purpose: Store patient medical history and diagnoses
-- ============================================================================

CREATE TABLE MEDICAL_HISTORY (
    HistoryID INT PRIMARY KEY AUTO_INCREMENT COMMENT 'Unique history record identifier',
    PatientID INT NOT NULL COMMENT 'Patient this history belongs to',
    AppointmentID INT COMMENT 'Associated appointment ID',
    Diagnosis VARCHAR(255) NOT NULL COMMENT 'Medical diagnosis given by doctor',
    Symptoms TEXT NOT NULL COMMENT 'Symptoms experienced by patient',
    TreatmentPlan TEXT NOT NULL COMMENT 'Prescribed treatment plan',
    DoctorNotes TEXT COMMENT 'Additional notes by doctor',
    Outcome VARCHAR(100) COMMENT 'Outcome of treatment (Recovered, Ongoing, etc.)',
    CreatedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Record creation date',
    LastModifiedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Last update date',
    FOREIGN KEY (PatientID) REFERENCES PATIENT(PatientID) ON DELETE CASCADE,
    FOREIGN KEY (AppointmentID) REFERENCES APPOINTMENT(AppointmentID) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Stores patient medical history and diagnoses';

-- ============================================================================
-- TABLE 8: LAB_TEST
-- Purpose: Store available laboratory tests
-- ============================================================================

CREATE TABLE LAB_TEST (
    TestID INT PRIMARY KEY AUTO_INCREMENT COMMENT 'Unique lab test identifier',
    TestName VARCHAR(100) NOT NULL UNIQUE COMMENT 'Name of laboratory test',
    Description TEXT NOT NULL COMMENT 'Detailed description of test',
    NormalRange VARCHAR(100) COMMENT 'Normal range for test results',
    Unit VARCHAR(50) COMMENT 'Unit of measurement (mg/dl, etc.)',
    CostPrice DECIMAL(10,2) NOT NULL DEFAULT 200.00 COMMENT 'Cost of test to patient',
    CollectionMethod VARCHAR(100) COMMENT 'How sample is collected (blood draw, urine, etc.)',
    TurnaroundDays INT DEFAULT 1 COMMENT 'Days needed for results',
    IsActive BOOLEAN DEFAULT TRUE COMMENT 'Active/Inactive status',
    CreatedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Record creation date',
    LastModifiedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Last update date'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Stores available laboratory tests';

-- ============================================================================
-- TABLE 9: LAB_REPORT
-- Purpose: Store lab test results for patients
-- ============================================================================

CREATE TABLE LAB_REPORT (
    ReportID INT PRIMARY KEY AUTO_INCREMENT COMMENT 'Unique lab report identifier',
    PatientID INT NOT NULL COMMENT 'Patient who took the test',
    TestID INT NOT NULL COMMENT 'Type of test performed',
    AppointmentID INT COMMENT 'Associated appointment ID',
    TestDate DATE NOT NULL COMMENT 'Date when test was performed',
    ResultValue VARCHAR(100) NOT NULL COMMENT 'Actual test result value',
    Status ENUM('Pending', 'Completed', 'Abnormal', 'Critical') DEFAULT 'Pending' COMMENT 'Report status',
    NormalRangeMin DECIMAL(10,2) COMMENT 'Lower limit of normal range',
    NormalRangeMax DECIMAL(10,2) COMMENT 'Upper limit of normal range',
    IsAbnormal BOOLEAN DEFAULT FALSE COMMENT 'Whether result is abnormal',
    LabTechnicianNotes TEXT COMMENT 'Notes by lab technician',
    DoctorReview TEXT COMMENT 'Doctor review of results',
    DoctorReviewDate DATETIME COMMENT 'When doctor reviewed results',
    CreatedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Record creation date',
    LastModifiedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Last update date',
    FOREIGN KEY (PatientID) REFERENCES PATIENT(PatientID) ON DELETE RESTRICT,
    FOREIGN KEY (TestID) REFERENCES LAB_TEST(TestID) ON DELETE RESTRICT,
    FOREIGN KEY (AppointmentID) REFERENCES APPOINTMENT(AppointmentID) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Stores laboratory test results';

-- ============================================================================
-- TABLE 10: MEDICINE
-- Purpose: Store medicine inventory
-- ============================================================================

CREATE TABLE MEDICINE (
    MedicineID INT PRIMARY KEY AUTO_INCREMENT COMMENT 'Unique medicine identifier',
    MedicineName VARCHAR(100) NOT NULL UNIQUE COMMENT 'Generic and brand name',
    Type VARCHAR(50) NOT NULL COMMENT 'Type of medicine (tablet, injection, syrup, etc.)',
    ManufacturerID INT NOT NULL COMMENT 'Medicine manufacturer',
    GenericName VARCHAR(100) COMMENT 'Generic chemical name',
    Strength VARCHAR(50) COMMENT 'Strength of medicine (500mg, 10ml, etc.)',
    UnitPrice DECIMAL(10,2) NOT NULL COMMENT 'Price per unit',
    QuantityInStock INT DEFAULT 0 COMMENT 'Current stock quantity',
    MinimumStock INT DEFAULT 50 COMMENT 'Minimum stock level',
    ReorderLevel INT DEFAULT 100 COMMENT 'Stock level that triggers reorder',
    ExpiryDate DATE NOT NULL COMMENT 'Medicine expiry date',
    StorageLocation VARCHAR(100) COMMENT 'Where medicine is stored',
    SideEffects TEXT COMMENT 'Known side effects',
    Contraindications TEXT COMMENT 'Medical conditions where not to use',
    Interactions TEXT COMMENT 'Known drug interactions',
    CreatedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Record creation date',
    LastModifiedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Last update date',
    IsActive BOOLEAN DEFAULT TRUE COMMENT 'Active/Inactive status',
    FOREIGN KEY (ManufacturerID) REFERENCES MANUFACTURER(ManufacturerID) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Stores medicine inventory';

-- ============================================================================
-- TABLE 11: PRESCRIPTION
-- Purpose: Store prescriptions issued to patients
-- ============================================================================

CREATE TABLE PRESCRIPTION (
    PrescriptionID INT PRIMARY KEY AUTO_INCREMENT COMMENT 'Unique prescription identifier',
    AppointmentID INT NOT NULL COMMENT 'Associated appointment',
    DoctorID INT NOT NULL COMMENT 'Doctor who issued prescription',
    PatientID INT NOT NULL COMMENT 'Patient for whom prescribed',
    CreatedDate DATE NOT NULL DEFAULT CURDATE() COMMENT 'Date prescription was issued',
    ExpiryDate DATE COMMENT 'Date prescription expires',
    Notes TEXT COMMENT 'Special instructions for patient',
    Status ENUM('Active', 'Completed', 'Expired', 'Cancelled') DEFAULT 'Active' COMMENT 'Prescription status',
    RefillsAllowed INT DEFAULT 3 COMMENT 'Number of times prescription can be refilled',
    RefillsUsed INT DEFAULT 0 COMMENT 'Number of refills already used',
    LastFillDate DATE COMMENT 'Last date prescription was filled',
    CreatedDateTime TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Record creation timestamp',
    LastModifiedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Last update date',
    FOREIGN KEY (AppointmentID) REFERENCES APPOINTMENT(AppointmentID) ON DELETE RESTRICT,
    FOREIGN KEY (DoctorID) REFERENCES DOCTOR(DoctorID) ON DELETE RESTRICT,
    FOREIGN KEY (PatientID) REFERENCES PATIENT(PatientID) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Stores prescriptions issued to patients';

-- ============================================================================
-- TABLE 12: PRESCRIPTION_ITEMS
-- Purpose: Store individual medicines in a prescription
-- ============================================================================

CREATE TABLE PRESCRIPTION_ITEMS (
    PrescriptionItemID INT PRIMARY KEY AUTO_INCREMENT COMMENT 'Unique prescription item identifier',
    PrescriptionID INT NOT NULL COMMENT 'Prescription this item belongs to',
    MedicineID INT NOT NULL COMMENT 'Medicine being prescribed',
    Dosage VARCHAR(50) NOT NULL COMMENT 'Dosage per dose (e.g., 500mg)',
    Frequency VARCHAR(50) NOT NULL COMMENT 'How often to take (e.g., twice daily)',
    Duration INT NOT NULL COMMENT 'Duration in days',
    Instructions TEXT COMMENT 'Special instructions (e.g., with food)',
    Quantity INT NOT NULL DEFAULT 1 COMMENT 'Total quantity to dispense',
    IsRefillable BOOLEAN DEFAULT TRUE COMMENT 'Can this item be refilled',
    CreatedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Record creation date',
    LastModifiedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Last update date',
    FOREIGN KEY (PrescriptionID) REFERENCES PRESCRIPTION(PrescriptionID) ON DELETE CASCADE,
    FOREIGN KEY (MedicineID) REFERENCES MEDICINE(MedicineID) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Stores individual medicine items in prescriptions';

-- ============================================================================
-- TABLE 13: BILLING
-- Purpose: Store patient billing information
-- ============================================================================

CREATE TABLE BILLING (
    BillingID INT PRIMARY KEY AUTO_INCREMENT COMMENT 'Unique billing record identifier',
    PatientID INT NOT NULL COMMENT 'Patient being billed',
    AppointmentID INT NOT NULL COMMENT 'Associated appointment',
    ConsultationFee DECIMAL(10,2) DEFAULT 0.00 COMMENT 'Doctor consultation fee',
    LabTestFee DECIMAL(10,2) DEFAULT 0.00 COMMENT 'Laboratory test fees',
    MedicineCost DECIMAL(10,2) DEFAULT 0.00 COMMENT 'Total medicine cost',
    OtherCharges DECIMAL(10,2) DEFAULT 0.00 COMMENT 'Miscellaneous charges',
    Discount DECIMAL(10,2) DEFAULT 0.00 COMMENT 'Applied discount',
    TaxAmount DECIMAL(10,2) DEFAULT 0.00 COMMENT 'Tax (GST)',
    TotalAmount DECIMAL(10,2) NOT NULL COMMENT 'Final total amount',
    AmountPaid DECIMAL(10,2) DEFAULT 0.00 COMMENT 'Amount paid by patient',
    PatientPayable DECIMAL(10,2) COMMENT 'Amount patient still owes',
    PaymentStatus ENUM('Paid', 'Partial', 'Unpaid', 'Refunded') DEFAULT 'Unpaid' COMMENT 'Payment status',
    PaymentMethod VARCHAR(50) COMMENT 'How payment was made (Cash, Card, etc.)',
    InsuranceCoverageAmount DECIMAL(10,2) DEFAULT 0.00 COMMENT 'Amount covered by insurance',
    BillingDate DATE NOT NULL DEFAULT CURDATE() COMMENT 'Date bill was generated',
    DueDate DATE COMMENT 'Payment due date',
    PaymentDate DATE COMMENT 'Actual payment date',
    CreatedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Record creation date',
    LastModifiedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Last update date',
    FOREIGN KEY (PatientID) REFERENCES PATIENT(PatientID) ON DELETE RESTRICT,
    FOREIGN KEY (AppointmentID) REFERENCES APPOINTMENT(AppointmentID) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Stores patient billing and payment information';

-- ============================================================================
-- TABLE 14: INSURANCE
-- Purpose: Store patient insurance information
-- ============================================================================

CREATE TABLE INSURANCE (
    InsuranceID INT PRIMARY KEY AUTO_INCREMENT COMMENT 'Unique insurance record identifier',
    PatientID INT NOT NULL COMMENT 'Patient this insurance belongs to',
    BillingID INT COMMENT 'Associated billing record',
    InsuranceProvider VARCHAR(100) NOT NULL COMMENT 'Insurance company name',
    PolicyNumber VARCHAR(50) NOT NULL UNIQUE COMMENT 'Insurance policy number',
    CoveragePercentage INT DEFAULT 80 COMMENT 'Percentage of cost covered (0-100)',
    CoverageLimit DECIMAL(15,2) COMMENT 'Maximum coverage limit per year',
    ValidFromDate DATE NOT NULL COMMENT 'Policy start date',
    ValidToDate DATE NOT NULL COMMENT 'Policy end date',
    PolicyType VARCHAR(50) COMMENT 'Type of policy (individual, family, group)',
    PreAuthorizationNumber VARCHAR(50) COMMENT 'Pre-authorization number for procedures',
    CoverageStatus ENUM('Active', 'Inactive', 'Expired', 'Suspended') DEFAULT 'Active' COMMENT 'Current coverage status',
    ClaimsProcessed INT DEFAULT 0 COMMENT 'Number of claims processed',
    TotalClaimsAmount DECIMAL(15,2) DEFAULT 0.00 COMMENT 'Total amount claimed',
    RemainingCoverage DECIMAL(15,2) COMMENT 'Remaining coverage available',
    CreatedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Record creation date',
    LastModifiedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Last update date',
    FOREIGN KEY (PatientID) REFERENCES PATIENT(PatientID) ON DELETE RESTRICT,
    FOREIGN KEY (BillingID) REFERENCES BILLING(BillingID) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Stores patient insurance information';

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================
-- Run these queries to verify all tables are created successfully

SELECT 'Tables Created Successfully!' as Status;

SELECT TABLE_NAME 
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_SCHEMA = 'hospital_management_system' 
AND TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_NAME;

-- Count total tables
SELECT COUNT(*) as TotalTablesCreated
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_SCHEMA = 'hospital_management_system'
AND TABLE_TYPE = 'BASE TABLE';

-- ============================================================================
-- END OF DDL TABLES SCRIPT
-- ============================================================================
-- Total Tables: 14
-- Total Columns: 150+
-- Normalized Levels: 1NF to BCNF
-- ============================================================================