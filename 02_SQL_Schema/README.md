# Hospital Management System (HMS) - SQL Schema
## Complete Database Design & Implementation

---

## **📋 Table of Contents**

- [Overview](#overview)
- [Quick Start](#quick-start)
- [Project Structure](#project-structure)
- [Database Architecture](#database-architecture)
- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)
- [Files Description](#files-description)
- [Database Schema](#database-schema)
- [Key Components](#key-components)
- [Performance](#performance)
- [Testing](#testing)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [Team Member Responsibilities](#team-member-responsibilities)
- [Next Steps](#next-steps)
- [References](#references)

---

## **Overview**

This is a **complete, production-ready SQL database schema** for a Hospital Management System (HMS) developed as part of a comprehensive DBMS course project. The schema implements industry best practices including normalization (1NF to BCNF), referential integrity, performance optimization, and role-based access control.

### **Key Statistics**

- **14 Normalized Tables**: Core entities covering all hospital operations
- **150+ Columns**: Fully typed and documented
- **45+ Indexes**: Strategic performance optimization
- **15 Views**: Role-based data access
- **50+ Constraints**: Data validation and integrity
- **2500+ Lines**: Complete documentation
- **Production-Ready**: MySQL 8.0+, InnoDB, UTF8MB4

### **Supported Entities**

- 🏥 Departments & Staff Management
- 👨‍⚕️ Doctor Information & Scheduling
- 👥 Patient Demographics & Medical History
- 📅 Appointment Management
- 💊 Pharmacy & Prescription Management
- 🧪 Laboratory Testing & Results
- 💰 Billing & Insurance
- 📊 Audit & Reporting

---

## **Quick Start**

### **Prerequisites**

```bash
# Check MySQL installation
mysql --version
# Expected: mysql Ver 8.0.x Client

# Check MySQL service status
sudo systemctl status mysql
# If not running: sudo systemctl start mysql
```

### **Installation (5 Minutes)**

```bash
# 1. Create database
mysql -u root -p -e "CREATE DATABASE hospital_management_system;"

# 2. Execute SQL files in order
cd 02_SQL_Schema/
mysql -u root -p hospital_management_system < 01_DDL_Tables.sql
mysql -u root -p hospital_management_system < 02_Constraints_and_Keys.sql
mysql -u root -p hospital_management_system < 03_Indexes.sql
mysql -u root -p hospital_management_system < 04_Views.sql

# 3. Verify installation
mysql -u root -p hospital_management_system -e "SHOW TABLES; SELECT COUNT(*) FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_SCHEMA='hospital_management_system';"
```

### **Verification**

```sql
-- Expected output:
-- Tables: 14
-- Views: 15
-- Indexes: 45+
-- Constraints: 50+
```

---

## **Project Structure**

```
hospital-management-system-dbms/
│
├── 02_SQL_Schema/                          # Member 2's deliverables
│   │
│   ├── 01_DDL_Tables.sql                   # 14 table creation statements
│   │   ├── MANUFACTURER (suppliers)
│   │   ├── DEPARTMENT (hospital departments)
│   │   ├── DOCTOR (physicians)
│   │   ├── DOCTOR_SCHEDULE (working hours)
│   │   ├── PATIENT (demographics)
│   │   ├── APPOINTMENT (consultations)
│   │   ├── MEDICAL_HISTORY (diagnoses)
│   │   ├── LAB_TEST (available tests)
│   │   ├── LAB_REPORT (test results)
│   │   ├── MEDICINE (pharmacy inventory)
│   │   ├── PRESCRIPTION (medication orders)
│   │   ├── PRESCRIPTION_ITEMS (medicine in prescriptions)
│   │   ├── BILLING (invoices & payments)
│   │   └── INSURANCE (policy information)
│   │
│   ├── 02_Constraints_and_Keys.sql         # Data validation & integrity
│   │   ├── Primary Keys (14)
│   │   ├── Foreign Keys (15+)
│   │   ├── Unique Constraints (12)
│   │   ├── Check Constraints (40+)
│   │   ├── Not Null Constraints (80+)
│   │   └── Default Values (25+)
│   │
│   ├── 03_Indexes.sql                      # Performance optimization
│   │   ├── Single-Column Indexes (30+)
│   │   ├── Composite Indexes (12)
│   │   ├── Full-Text Indexes (3)
│   │   └── Performance Analysis Queries
│   │
│   ├── 04_Views.sql                        # Role-based access control
│   │   ├── v_doctor_details
│   │   ├── v_doctor_patient_appointments
│   │   ├── v_patient_medical_history
│   │   ├── v_appointment_summary
│   │   ├── v_patient_details
│   │   ├── v_prescription_full_details
│   │   ├── v_lab_results
│   │   ├── v_medicine_inventory
│   │   ├── v_billing_summary
│   │   ├── v_overdue_payments
│   │   ├── v_doctor_performance
│   │   ├── v_patient_insurance_coverage
│   │   ├── v_department_statistics
│   │   ├── v_medicine_expiry_alert
│   │   └── v_today_appointments
│   │
│   ├── Schema_Documentation.md              # Complete data dictionary
│   │   ├── Table descriptions (14)
│   │   ├── Column documentation
│   │   ├── Relationships & cardinalities
│   │   ├── Constraint summary
│   │   ├── Index strategy
│   │   ├── Query examples
│   │   └── Maintenance schedule
│   │
│   ├── SQL_SCHEMA_IMPLEMENTATION_GUIDE.md  # Step-by-step implementation
│   │   ├── Prerequisites
│   │   ├── Database setup
│   │   ├── Table creation methodology
│   │   ├── Constraint implementation
│   │   ├── Index creation strategy
│   │   ├── View design
│   │   ├── Testing procedures
│   │   ├── Troubleshooting
│   │   └── Git workflow
│   │
│   ├── QUICK_REFERENCE.md                  # Quick lookup guide
│   │   ├── File summaries
│   │   ├── 5-minute setup
│   │   ├── Verification queries
│   │   ├── Common errors
│   │   └── Performance tips
│   │
│   └── README.md                           # This file
│       ├── Overview
│       ├── Quick start
│       ├── Installation
│       ├── Database schema
│       ├── Features
│       └── Contributing guidelines
│
├── 01_ER_and_Design/                       # Member 1's ER diagrams
├── 03_PL_SQL/                              # Member 3's procedures & triggers
├── 04_Data/                                # Member 4's sample data
├── 05_DBMS_Concepts/                       # Member 5's concepts & analysis
├── 06_Reports/                             # Analysis reports
├── 07_Testing/                             # Test cases
└── 08_Documentation/                       # Project documentation
```

---

## **Database Architecture**

### **Entity Relationship Diagram**

```
┌─────────────────────────────────────────────────────────────────┐
│                    HOSPITAL MANAGEMENT SYSTEM                   │
└─────────────────────────────────────────────────────────────────┘

CORE ENTITIES:
├── MANUFACTURER ──┐
│                  └──→ MEDICINE ──→ PRESCRIPTION_ITEMS ←── PRESCRIPTION
│
├── DEPARTMENT ────→ DOCTOR ──→ APPOINTMENT ──→ PRESCRIPTION
│                    │          │              
│                    │          ├──→ MEDICAL_HISTORY
│                    │          ├──→ LAB_REPORT ←── LAB_TEST
│                    │          └──→ BILLING ──→ INSURANCE
│                    │
│                    └──→ DOCTOR_SCHEDULE
│
└── PATIENT ───────→ APPOINTMENT
               │    ├──→ PRESCRIPTION
               │    ├──→ LAB_REPORT
               ├─→ MEDICAL_HISTORY
               ├─→ BILLING
               └─→ INSURANCE
```

### **Normalization Levels**

- **1NF (First Normal Form)**: Atomic values only
- **2NF (Second Normal Form)**: No partial dependencies
- **3NF (Third Normal Form)**: No transitive dependencies
- **BCNF (Boyce-Codd Normal Form)**: Every determinant is a candidate key

✅ **All tables normalized to BCNF**

### **Table Relationships**

| Relationship | Type | Example |
|---|---|---|
| DOCTOR → DEPARTMENT | Many-to-One (M:1) | Many doctors in one department |
| APPOINTMENT → DOCTOR | Many-to-One (M:1) | Many appointments with one doctor |
| APPOINTMENT → PATIENT | Many-to-One (M:1) | Many appointments for one patient |
| PRESCRIPTION → PRESCRIPTION_ITEMS | One-to-Many (1:M) | One prescription has many medicines |
| PATIENT → INSURANCE | One-to-Many (1:M) | One patient may have multiple policies |
| MEDICINE → PRESCRIPTION_ITEMS | One-to-Many (1:M) | One medicine in many prescriptions |

---

## **Features**

### **✅ Core Features**

- **Comprehensive Entity Coverage**
  - 14 tables covering all hospital operations
  - Departments, doctors, patients, appointments
  - Medical history, lab tests, prescriptions
  - Billing, insurance, inventory management

- **Data Integrity**
  - Primary keys for unique identification
  - Foreign keys for referential integrity
  - Unique constraints for identifiers
  - Check constraints for valid values
  - Not null constraints for mandatory fields

- **Performance Optimization**
  - 45+ strategic indexes
  - Single-column indexes for search
  - Composite indexes for joins
  - Full-text indexes for text search
  - Query optimization analysis included

- **Security & Access Control**
  - 15 role-based views
  - Hide sensitive data (salary, passwords)
  - Different views for different roles
  - Simplified complex queries

- **Data Quality**
  - Date validations (past births, future appointments)
  - Blood group validation
  - Fee validation (positive amounts)
  - Insurance coverage validation (0-100%)
  - Medicine expiry tracking

- **Audit Trail Support**
  - Timestamps on all records
  - Change tracking capability
  - Audit log table for tracking modifications
  - Last modified date on updates

### **🔒 Security Features**

- **Role-Based Views**
  ```
  Doctors → See appointments, prescriptions, medical history
  Patients → See personal info, medical history, bills
  Pharmacists → See prescriptions, medicine inventory
  Finance → See billing, insurance, overdue payments
  Admin → See all data with performance metrics
  ```

- **Referential Integrity**
  - Cannot delete department if doctors assigned
  - Cannot create appointment for non-existent patient
  - Cannot prescribe medicine that doesn't exist
  - Automatic data consistency

- **Data Validation**
  - Age must be calculated from past dates
  - Blood group from valid list
  - Appointment fees must be positive
  - Insurance coverage must be 0-100%

### **📊 Reporting Capabilities**

- Doctor performance metrics
- Department statistics
- Billing and payment status
- Medicine inventory alerts
- Overdue payment reports
- Lab result notifications
- Prescription tracking

---

## **Installation**

### **System Requirements**

```
Operating System: Linux, macOS, or Windows
MySQL Version: 8.0.0 or higher
Disk Space: 500 MB minimum
RAM: 2 GB minimum
```

### **Step-by-Step Installation**

#### **Step 1: Install MySQL (if not already installed)**

**Ubuntu/Debian:**
```bash
sudo apt-get update
sudo apt-get install mysql-server
sudo mysql_secure_installation
```

**macOS:**
```bash
brew install mysql
brew services start mysql
mysql_secure_installation
```

**Windows:**
- Download from: https://dev.mysql.com/downloads/mysql/
- Run installer and follow wizard

#### **Step 2: Clone Repository**

```bash
git clone https://github.com/yourusername/hospital-management-system-dbms.git
cd hospital-management-system-dbms
```

#### **Step 3: Create Database**

```bash
mysql -u root -p
# Enter password when prompted

# Inside MySQL:
CREATE DATABASE hospital_management_system;
USE hospital_management_system;
EXIT;
```

#### **Step 4: Execute SQL Files**

**Important**: Run in this exact order (order matters due to foreign keys)

```bash
# Navigate to SQL directory
cd 02_SQL_Schema/

# 1. Create tables
mysql -u root -p hospital_management_system < 01_DDL_Tables.sql

# 2. Add constraints
mysql -u root -p hospital_management_system < 02_Constraints_and_Keys.sql

# 3. Create indexes
mysql -u root -p hospital_management_system < 03_Indexes.sql

# 4. Create views
mysql -u root -p hospital_management_system < 04_Views.sql
```

#### **Step 5: Verify Installation**

```bash
mysql -u root -p hospital_management_system

# Inside MySQL:
SHOW TABLES;
# Should show 14 tables

SELECT COUNT(*) as ViewCount 
FROM INFORMATION_SCHEMA.VIEWS 
WHERE TABLE_SCHEMA = 'hospital_management_system';
# Should show 15

SELECT COUNT(DISTINCT INDEX_NAME) - 1 as IndexCount
FROM INFORMATION_SCHEMA.STATISTICS 
WHERE TABLE_SCHEMA = 'hospital_management_system' 
AND INDEX_NAME != 'PRIMARY';
# Should show 45+

EXIT;
```

### **Alternative: Single Command Installation**

```bash
# Create database and run all files at once
mysql -u root -p -e "CREATE DATABASE hospital_management_system;"

# Run all SQL files
for file in 01_DDL_Tables.sql 02_Constraints_and_Keys.sql 03_Indexes.sql 04_Views.sql; do
    mysql -u root -p hospital_management_system < "$file"
done

echo "Installation complete!"
```

---

## **Usage**

### **Connecting to Database**

```bash
# Connect to database
mysql -u root -p hospital_management_system

# Or use a GUI tool
# MySQL Workbench, DBeaver, PHPMyAdmin, etc.
```

### **Basic Queries**

```sql
-- View all doctors
SELECT * FROM v_doctor_details;

-- Find appointments for today
SELECT * FROM v_today_appointments;

-- Check overdue payments
SELECT * FROM v_overdue_payments 
WHERE DaysOverdue > 30;

-- Get medicine inventory status
SELECT * FROM v_medicine_inventory 
WHERE InventoryStatus IN ('REORDER NEEDED', 'LOW STOCK');

-- Patient medical history
SELECT * FROM v_patient_medical_history 
WHERE PatientID = 1;

-- Lab results
SELECT * FROM v_lab_results 
WHERE PatientID = 2;

-- Billing summary
SELECT * FROM v_billing_summary 
WHERE PaymentStatus = 'Unpaid';
```

### **Inserting Data**

```sql
-- Insert department
INSERT INTO DEPARTMENT (DeptName, Floor, MaxBeds) 
VALUES ('Cardiology', 2, 50);

-- Insert doctor
INSERT INTO DOCTOR (FirstName, LastName, Qualification, Specialization, DepartmentID, Phone, Email)
VALUES ('John', 'Smith', 'MD', 'Cardiology', 1, '9876543210', 'john.smith@hospital.com');

-- Insert patient
INSERT INTO PATIENT (FirstName, LastName, DateOfBirth, Gender, BloodGroup, Address, Phone, EmergencyContactName, EmergencyContactPhone)
VALUES ('Ram', 'Kumar', '1980-05-15', 'Male', 'O+', '123 Main St', '9123456789', 'Sita Kumar', '9123456790');

-- Insert appointment
INSERT INTO APPOINTMENT (PatientID, DoctorID, AppointmentDate, AppointmentTime, ReasonForVisit)
VALUES (1, 1, '2024-02-20', '10:30', 'Heart checkup');
```

### **Updating Data**

```sql
-- Update doctor availability
UPDATE DOCTOR 
SET AvailabilityStatus = 'On Leave' 
WHERE DoctorID = 1;

-- Mark appointment as completed
UPDATE APPOINTMENT 
SET Status = 'Completed', ActualDuration = 35 
WHERE AppointmentID = 1;

-- Update medicine stock
UPDATE MEDICINE 
SET QuantityInStock = QuantityInStock - 10 
WHERE MedicineID = 5;
```

### **Deleting Data**

```sql
-- Cancel appointment
UPDATE APPOINTMENT 
SET Status = 'Cancelled', CancelledDate = NOW(), CancellationReason = 'Patient request' 
WHERE AppointmentID = 1;

-- Deactivate doctor
UPDATE DOCTOR 
SET IsActive = FALSE 
WHERE DoctorID = 5;

-- Mark patient as discharged
UPDATE PATIENT 
SET PatientStatus = 'Discharged' 
WHERE PatientID = 10;
```

### **Complex Queries**

```sql
-- Find all appointments with details
SELECT 
    a.AppointmentID,
    a.AppointmentDate,
    CONCAT(d.FirstName, ' ', d.LastName) as DoctorName,
    CONCAT(p.FirstName, ' ', p.LastName) as PatientName,
    a.Status
FROM APPOINTMENT a
JOIN DOCTOR d ON a.DoctorID = d.DoctorID
JOIN PATIENT p ON a.PatientID = p.PatientID
WHERE a.AppointmentDate = CURDATE()
ORDER BY a.AppointmentTime;

-- Doctor performance metrics
SELECT 
    DoctorName,
    TotalAppointments,
    CompletedAppointments,
    CompletionRate,
    TotalRevenue
FROM v_doctor_performance
ORDER BY TotalRevenue DESC;

-- Department statistics
SELECT * FROM v_department_statistics
ORDER BY TotalAppointments DESC;
```

---

## **Files Description**

### **📄 SQL Files (Executable)**

#### **01_DDL_Tables.sql** (600 lines)
Creates 14 normalized tables with complete structure:
- `MANUFACTURER` - Medicine suppliers
- `DEPARTMENT` - Hospital departments
- `DOCTOR` - Physician information
- `DOCTOR_SCHEDULE` - Working hours
- `PATIENT` - Patient demographics
- `APPOINTMENT` - Consultations
- `MEDICAL_HISTORY` - Diagnoses and treatment
- `LAB_TEST` - Available lab tests
- `LAB_REPORT` - Test results
- `MEDICINE` - Pharmacy inventory
- `PRESCRIPTION` - Medication orders
- `PRESCRIPTION_ITEMS` - Medicines in prescriptions
- `BILLING` - Invoices and payments
- `INSURANCE` - Insurance policies

**Features:**
- InnoDB engine for ACID compliance
- UTF8MB4 charset for internationalization
- Comprehensive column comments
- Proper data types and constraints
- Default values and timestamps

#### **02_Constraints_and_Keys.sql** (200 lines)
Implements data validation:
- PRIMARY KEY constraints (14)
- FOREIGN KEY constraints (15+)
- UNIQUE constraints (12)
- CHECK constraints (40+)
- NOT NULL constraints (80+)
- Referential integrity rules

**Benefits:**
- Prevents invalid data entry
- Maintains data consistency
- Enforces business rules
- Creates audit trail table

#### **03_Indexes.sql** (350 lines)
Performance optimization:
- Single-column indexes (30+)
- Composite indexes (12)
- Full-text indexes (3)
- Query analysis with EXPLAIN
- Index maintenance commands

**Performance Impact:**
- SELECT queries: 10-100x faster
- Common JOINs optimized
- Search operations accelerated
- Text search capabilities

#### **04_Views.sql** (400 lines)
Role-based access:
- Doctor views (2)
- Patient views (2)
- Appointment views (2)
- Lab views (2)
- Finance views (3)
- Admin views (2)
- Pharmacy views (2)

**Security & Simplicity:**
- Hide sensitive columns
- Simplify complex queries
- Pre-optimized queries
- Role-based access control

### **📚 Documentation Files**

#### **Schema_Documentation.md** (1000+ lines)
Complete reference:
- Data dictionary (all 14 tables)
- Column specifications
- Relationship documentation
- Constraint summaries
- Index strategies
- Query examples
- Maintenance procedures

#### **SQL_SCHEMA_IMPLEMENTATION_GUIDE.md** (1500+ lines)
Step-by-step guide:
- Prerequisites and setup
- Database creation
- Table creation methodology
- Constraint implementation
- Index creation strategy
- View design
- Testing procedures
- Troubleshooting

#### **QUICK_REFERENCE.md** (400 lines)
Quick lookup guide:
- 5-minute setup
- Verification queries
- Common errors
- Performance tips
- Git workflow
- Timeline breakdown

#### **README.md** (This file)
Project overview:
- Quick start guide
- Installation instructions
- Feature overview
- Usage examples
- File descriptions

---

## **Database Schema**

### **Table Statistics**

| Table | Columns | Purpose |
|-------|---------|---------|
| MANUFACTURER | 10 | Medicine suppliers |
| DEPARTMENT | 11 | Hospital departments |
| DOCTOR | 14 | Physician information |
| DOCTOR_SCHEDULE | 9 | Working schedule |
| PATIENT | 19 | Patient demographics |
| APPOINTMENT | 15 | Consultations |
| MEDICAL_HISTORY | 10 | Diagnoses |
| LAB_TEST | 11 | Lab test definitions |
| LAB_REPORT | 15 | Test results |
| MEDICINE | 18 | Pharmacy inventory |
| PRESCRIPTION | 13 | Medication orders |
| PRESCRIPTION_ITEMS | 11 | Medicines in prescriptions |
| BILLING | 20 | Invoices & payments |
| INSURANCE | 17 | Insurance policies |
| **TOTAL** | **186** | **14 tables** |

### **Data Types Used**

```sql
INT - Integers (IDs, quantities)
BIGINT - Large integers
VARCHAR(n) - Variable text strings
TEXT - Long text (notes, descriptions)
DATE - Calendar dates
TIME - Time of day
DATETIME - Date and time
TIMESTAMP - Auto-updating timestamps
DECIMAL(m,n) - Money/decimal numbers
ENUM - Predefined values (status, type)
BOOLEAN - True/False
```

### **Key Columns by Category**

**Identification (PKs)**
- DoctorID, PatientID, AppointmentID, etc.

**Foreign Keys (FKs)**
- DepartmentID, PatientID, DoctorID, TestID, etc.

**Dates & Times**
- AppointmentDate, TestDate, CreatedDate, LastModifiedDate

**Amounts & Quantities**
- ConsultationFee, QuantityInStock, TotalAmount

**Status Flags**
- IsActive, PaymentStatus, AvailabilityStatus

---

## **Key Components**

### **1. Normalization**

**Benefits of Database Normalization:**

✅ **Eliminates redundancy** - No repeated data
✅ **Improves consistency** - Single source of truth
✅ **Enables scalability** - Grows easily
✅ **Reduces storage** - Efficient space usage
✅ **Simplifies maintenance** - Easier updates

**BCNF Compliance:**
- Every determinant is a candidate key
- All non-key dependencies removed
- Highest level of normalization

### **2. Indexes**

**Index Strategy:**

```
High Priority (Used Frequently):
├── APPOINTMENT.AppointmentDate
├── APPOINTMENT.(DoctorID, AppointmentDate)
├── BILLING.PaymentStatus
├── MEDICINE.QuantityInStock
└── DOCTOR.Specialization

Medium Priority:
├── PATIENT.BloodGroup
├── LAB_REPORT.Status
├── PRESCRIPTION.Status
└── APPOINTMENT.CancelledDate

Low Priority:
├── Specialty lookups
├── Status filtering
└── Date range queries
```

**Performance Impact:**
- `SELECT` queries: **10-100x faster**
- `JOIN` operations: **5-10x faster**
- Complex queries: **2-5x faster**
- Trade-off: `INSERT/UPDATE` slightly slower (worth it)

### **3. Views**

**15 Views for Different Users:**

```
Doctor Views:
├── v_doctor_details - Personal info & department
└── v_doctor_patient_appointments - Their appointments

Patient Views:
├── v_patient_details - Personal information
└── v_patient_medical_history - Medical records

Appointment Views:
├── v_appointment_summary - All appointments
└── v_today_appointments - Today's schedule

Lab Views:
├── v_lab_results - Test results
└── v_medicine_expiry_alert - Expiring medicines

Finance Views:
├── v_billing_summary - Bills & payments
└── v_overdue_payments - Unpaid bills

Admin Views:
├── v_doctor_performance - Staff metrics
└── v_department_statistics - Department metrics

Pharmacy Views:
├── v_prescription_full_details - Prescriptions
└── v_medicine_inventory - Stock status

Patient Insurance:
└── v_patient_insurance_coverage - Insurance info
```

### **4. Constraints**

**Types of Constraints:**

| Type | Count | Purpose |
|------|-------|---------|
| PRIMARY KEY | 14 | Unique identification |
| FOREIGN KEY | 15+ | Referential integrity |
| UNIQUE | 12 | Prevent duplicates |
| CHECK | 40+ | Validate values |
| NOT NULL | 80+ | Mandatory fields |
| DEFAULT | 25+ | Default values |

**Constraint Examples:**
```sql
-- Blood group validation
CHECK (BloodGroup IN ('A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'))

-- Date validations
CHECK (DateOfBirth <= CURDATE())
CHECK (AppointmentDate >= CURDATE())

-- Fee validation
CHECK (ConsultationFee > 0)

-- Insurance coverage
CHECK (CoveragePercentage >= 0 AND CoveragePercentage <= 100)

-- Time validation
CHECK (EndTime > StartTime)
```

---

## **Performance**

### **Expected Performance Metrics**

| Query Type | Expected Time | With Index |
|---|---|---|
| Simple SELECT by ID | < 1ms | < 1ms |
| Search by status | < 10ms | < 2ms |
| JOIN 2 tables | < 50ms | < 10ms |
| JOIN 3+ tables | < 100ms | < 20ms |
| Complex aggregation | 1-5s | 100-500ms |
| Full table scan | 1-10s | N/A |

### **Optimization Techniques**

```sql
-- 1. Use indexes
CREATE INDEX idx_appointment_date ON APPOINTMENT(AppointmentDate);

-- 2. Use views (pre-optimized)
SELECT * FROM v_doctor_patient_appointments 
WHERE AppointmentDate = '2024-02-15';

-- 3. Analyze table statistics
ANALYZE TABLE APPOINTMENT;

-- 4. Use EXPLAIN to check execution plan
EXPLAIN SELECT * FROM DOCTOR WHERE Specialization = 'Cardiology';
```

### **Optimization Tips**

✅ Use indexes on WHERE clause columns
✅ Use composite indexes for JOIN conditions
✅ Limit result set with WHERE clause
✅ Update table statistics regularly
✅ Archive old records (> 2 years)
✅ Use EXPLAIN to analyze queries
✅ Avoid SELECT * (select specific columns)
✅ Use views instead of complex queries

---

## **Testing**

### **Testing Procedures**

#### **Test 1: Verify Table Creation**

```sql
SHOW TABLES;
-- Should show all 14 tables
```

#### **Test 2: Test Foreign Key Constraints**

```sql
-- This should FAIL (good!)
INSERT INTO DOCTOR (FirstName, LastName, Qualification, Specialization, DepartmentID, Phone, Email)
VALUES ('Test', 'Doctor', 'MD', 'Cardiology', 9999, '123', 'test@test.com');

-- Error: Cannot add or update a child row: a foreign key constraint fails
```

#### **Test 3: Test Unique Constraints**

```sql
-- Insert first department
INSERT INTO DEPARTMENT (DeptName, Floor) VALUES ('ICU', 5);

-- This should FAIL (good!)
INSERT INTO DEPARTMENT (DeptName, Floor) VALUES ('ICU', 6);

-- Error: Duplicate entry for key unique key 'unique_dept_name'
```

#### **Test 4: Test Check Constraints**

```sql
-- This should FAIL (good!)
INSERT INTO PATIENT (FirstName, LastName, DateOfBirth, Gender, Phone, EmergencyContactName, EmergencyContactPhone)
VALUES ('Test', 'Patient', '2030-01-01', 'Male', '123', 'Contact', '456');

-- Error: Check constraint violation
```

#### **Test 5: Test Indexes**

```sql
-- This should use index (fast)
EXPLAIN SELECT * FROM DOCTOR WHERE Specialization = 'Cardiology';
-- Should show: Using index

-- This should also use index
EXPLAIN SELECT * FROM APPOINTMENT 
WHERE AppointmentDate = '2024-02-15' AND DoctorID = 1;
-- Should show: Using index
```

#### **Test 6: Test Views**

```sql
-- All views should return results
SELECT COUNT(*) FROM v_doctor_details;
SELECT COUNT(*) FROM v_appointment_summary;
SELECT COUNT(*) FROM v_medicine_inventory;
SELECT COUNT(*) FROM v_billing_summary;

-- Should all return 0 initially (no data), but query should work
```

### **Test Data Insertion**

```sql
-- Insert test data in correct order

-- 1. Insert manufacturer
INSERT INTO MANUFACTURER (MfgName, Phone, Address) 
VALUES ('Pharma Corp', '9876543210', '123 Industrial Area');

-- 2. Insert department
INSERT INTO DEPARTMENT (DeptName, Floor, MaxBeds) 
VALUES ('Cardiology', 2, 50);

-- 3. Insert doctor
INSERT INTO DOCTOR (FirstName, LastName, Qualification, Specialization, DepartmentID, Phone, Email)
VALUES ('Dr. Smith', 'John', 'MD', 'Cardiology', 1, '9123456789', 'smith@hospital.com');

-- 4. Insert patient
INSERT INTO PATIENT (FirstName, LastName, DateOfBirth, Gender, BloodGroup, Address, Phone, EmergencyContactName, EmergencyContactPhone)
VALUES ('Ram', 'Kumar', '1980-05-15', 'Male', 'O+', '123 Main St', '9987654321', 'Sita', '9987654322');

-- 5. Insert appointment
INSERT INTO APPOINTMENT (PatientID, DoctorID, AppointmentDate, AppointmentTime, ReasonForVisit)
VALUES (1, 1, CURDATE() + INTERVAL 5 DAY, '10:30', 'Heart checkup');

-- Verify
SELECT * FROM v_doctor_patient_appointments;
```

---

## **Troubleshooting**

### **Common Issues & Solutions**

#### **Issue 1: "Access denied for user 'root'@'localhost'"**

**Cause**: Incorrect password or user not found

**Solution**:
```bash
# Try without password
mysql -u root hospital_management_system

# Or reset password
sudo mysql -u root
ALTER USER 'root'@'localhost' IDENTIFIED BY 'new_password';
FLUSH PRIVILEGES;
EXIT;
```

#### **Issue 2: "Unknown database 'hospital_management_system'"**

**Cause**: Database not created

**Solution**:
```bash
# Create database first
mysql -u root -p -e "CREATE DATABASE hospital_management_system;"

# Then run SQL files
mysql -u root -p hospital_management_system < 01_DDL_Tables.sql
```

#### **Issue 3: "Foreign key constraint fails"**

**Cause**: Parent record doesn't exist

**Solution**:
```sql
-- Always insert parent before child
-- Insert DEPARTMENT first:
INSERT INTO DEPARTMENT (DeptName, Floor) VALUES ('Cardiology', 2);

-- Then insert DOCTOR:
INSERT INTO DOCTOR (DepartmentID, ...) VALUES (1, ...);

-- Check parent exists:
SELECT * FROM DEPARTMENT WHERE DepartmentID = 1;
```

#### **Issue 4: "Duplicate entry for key"**

**Cause**: Unique constraint violation

**Solution**:
```sql
-- Check for duplicates
SELECT Email, COUNT(*) as Count 
FROM DOCTOR 
GROUP BY Email 
HAVING COUNT(*) > 1;

-- Use unique email
INSERT INTO DOCTOR (Email, ...) VALUES ('unique.email@hospital.com', ...);
```

#### **Issue 5: "Check constraint violation"**

**Cause**: Invalid data value

**Solution**:
```sql
-- Validate before insert
-- DOB must be in past
INSERT INTO PATIENT (DateOfBirth, ...) VALUES ('1980-05-15', ...); ✅

-- Blood group must be valid
INSERT INTO PATIENT (BloodGroup, ...) VALUES ('O+', ...); ✅
INSERT INTO PATIENT (BloodGroup, ...) VALUES ('XY+', ...); ❌

-- Fee must be positive
INSERT INTO DOCTOR (ConsultationFee, ...) VALUES (500.00, ...); ✅
INSERT INTO DOCTOR (ConsultationFee, ...) VALUES (-100.00, ...); ❌
```

#### **Issue 6: "Syntax error near line XXX"**

**Cause**: File encoding or special characters

**Solution**:
```bash
# Check file encoding
file 01_DDL_Tables.sql
# Should show: ASCII text or UTF-8 Unicode

# Convert if needed
iconv -f UTF-16 -t UTF-8 01_DDL_Tables.sql > 01_DDL_Tables_fixed.sql
```

#### **Issue 7: "Files executed but no data showing"**

**Cause**: Normal - no data inserted yet

**Solution**:
```sql
-- This is expected. Schema is created but empty.
-- Data insertion is Member 4's responsibility.

-- Verify schema exists:
SHOW TABLES; -- Should show 14 tables
DESC DOCTOR; -- Should show columns
SELECT * FROM v_doctor_details LIMIT 0; -- Query should work
```

### **Debug Checklist**

- [ ] MySQL service running: `sudo systemctl status mysql`
- [ ] Database exists: `SHOW DATABASES;`
- [ ] All tables created: `SHOW TABLES;` (should show 14)
- [ ] Views created: `SHOW FULL TABLES WHERE TABLE_TYPE = 'VIEW';` (should show 15)
- [ ] Indexes exist: `SHOW INDEX FROM DOCTOR;`
- [ ] Can insert test data: Try test insertion
- [ ] Foreign keys working: Try inserting with invalid FK
- [ ] Constraints working: Try violating constraints

---

## **Contributing**

### **Contributing Guidelines**

This is a course project with defined member responsibilities. However, contributions follow this process:

#### **For Team Members**

1. **Create your feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make changes and commit**
   ```bash
   git add .
   git commit -m "Add: Description of changes"
   ```

3. **Push to branch**
   ```bash
   git push origin feature/your-feature-name
   ```

4. **Create Pull Request**
   - Go to GitHub
   - Click "New Pull Request"
   - Add description
   - Request review from Team Lead

#### **For External Contributors**

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add: Amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### **Commit Message Format**

```
[Component] Brief description

- What changed
- Why it changed
- How to verify

Example:
[SQL_Schema] Add DOCTOR_SCHEDULE table

- Created new table for doctor working hours
- Includes day of week, start time, end time
- Composite unique key on (DoctorID, DayOfWeek)
- Tested with sample data
```

### **Code Style**

- SQL: Uppercase keywords, lowercase identifiers
- Comments: Clear, concise, on separate lines
- Formatting: Consistent indentation (2 spaces)
- Naming: descriptive_names for tables, PascalCase for procedures

---

## **Team Member Responsibilities**

### **Member 1: ER Design & Relational Schema**
- ✅ Create ER diagram (Lucidchart/Draw.io)
- ✅ Document entities and relationships
- ✅ Define relational schemas
- ✅ Coordinate with Member 2

### **Member 2: SQL Schema Developer (PRIMARY)**
- ✅ **COMPLETED**: 14 normalized tables
- ✅ **COMPLETED**: Constraints and keys
- ✅ **COMPLETED**: 45+ performance indexes
- ✅ **COMPLETED**: 15 role-based views
- ✅ **COMPLETED**: Complete documentation
- ➡️ **NEXT**: Coordinate with Member 3

### **Member 3: PL/SQL Developer**
- ➡️ **NEXT**: Create 4+ stored procedures
- ➡️ **NEXT**: Create 6+ triggers
- ➡️ **NEXT**: Custom functions
- ➡️ **NEXT**: Cursor demonstrations

### **Member 4: Data Population & Testing**
- ➡️ **NEXT**: Insert 100+ records per table
- ➡️ **NEXT**: Generate realistic data
- ➡️ **NEXT**: Test data integrity
- ➡️ **NEXT**: Create test cases

### **Member 5: Documentation & Analysis**
- ➡️ **NEXT**: 15+ Relational Algebra queries
- ➡️ **NEXT**: 10+ Tuple Relational Calculus queries
- ➡️ **NEXT**: Query optimization analysis
- ➡️ **NEXT**: DBMS concepts documentation

---

## **Next Steps**

### **Immediate Tasks**

1. ✅ **SQL Schema Setup** (Member 2 - DONE)
   - All 14 tables created
   - Constraints implemented
   - Indexes created
   - Views established

2. ⏭️ **Review & Approval** (Team Lead - Member 1)
   - Review schema design
   - Verify normalization
   - Approve for merge to main

3. ➡️ **Merge to Main Branch**
   ```bash
   git checkout main
   git pull origin main
   git merge member2-sql-schema
   git push origin main
   ```

### **Next Phase: PL/SQL (Member 3)**

After merge to main, Member 3 will:
- Add stored procedures for business logic
- Create triggers for automation
- Implement functions for calculations
- Add exception handling

### **Later Phase: Data Population (Member 4)**

After PL/SQL complete, Member 4 will:
- Insert realistic sample data
- Create data generation scripts
- Verify data integrity
- Perform performance testing

### **Final Phase: Documentation (Member 5)**

Throughout the project, Member 5 will:
- Document all DBMS concepts
- Create query optimization analysis
- Write complex SQL queries
- Generate final reports

---

## **References**

### **MySQL Documentation**
- [MySQL 8.0 Reference Manual](https://dev.mysql.com/doc/refman/8.0/en/)
- [MySQL CREATE TABLE Syntax](https://dev.mysql.com/doc/refman/8.0/en/create-table.html)
- [MySQL ALTER TABLE Syntax](https://dev.mysql.com/doc/refman/8.0/en/alter-table.html)
- [MySQL CREATE INDEX Syntax](https://dev.mysql.com/doc/refman/8.0/en/create-index.html)
- [MySQL CREATE VIEW Syntax](https://dev.mysql.com/doc/refman/8.0/en/create-view.html)

### **Database Design**
- [Database Normalization - Wikipedia](https://en.wikipedia.org/wiki/Database_normalization)
- [BCNF - Boyce-Codd Normal Form](https://en.wikipedia.org/wiki/Boyce%E2%80%93Codd_normal_form)
- [Entity-Relationship Model](https://en.wikipedia.org/wiki/Entity%E2%80%93relationship_model)
- [Relational Database Design](https://en.wikipedia.org/wiki/Relational_database)

### **SQL Best Practices**
- [Use The Index, Luke!](https://use-the-index-luke.com/)
- [SQL Performance Best Practices](https://www.postgresql.org/docs/current/sql-syntax.html)
- [MySQL Performance Schema](https://dev.mysql.com/doc/refman/8.0/en/performance-schema.html)
- [Query Optimization](https://dev.mysql.com/doc/refman/8.0/en/optimization.html)

### **Tools**
- [MySQL Workbench](https://www.mysql.com/products/workbench/)
- [DBeaver Community](https://dbeaver.io/)
- [PhpMyAdmin](https://www.phpmyadmin.net/)
- [MySQL Shell](https://dev.mysql.com/doc/mysql-shell/8.0/en/)

### **Related Course Material**
- ER Modeling (01_ER_and_Design/)
- PL/SQL Procedures (03_PL_SQL/)
- Data Population (04_Data/)
- DBMS Concepts (05_DBMS_Concepts/)

---

## **License**

This project is licensed under the MIT License - see the LICENSE file for details.

```
MIT License

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, and/or sell copies of the
Software, and to permit persons to whom the Software is furnished to do so.
```

---

## **Authors**

**Member 2 - SQL Schema Developer**
- Responsible for: Database schema design, normalization, constraints, indexes, views
- Files: 01_DDL_Tables.sql, 02_Constraints_and_Keys.sql, 03_Indexes.sql, 04_Views.sql
- Contact: [Your GitHub/Email]

**Team Leads & Contributors**
- **Member 1** - ER Design & Project Coordination
- **Member 3** - PL/SQL Procedures & Triggers
- **Member 4** - Data Population & Testing
- **Member 5** - DBMS Concepts & Documentation

---

## **Acknowledgments**

- MySQL Community for excellent documentation
- Team members for collaboration
- Faculty for project guidance
- Stack Overflow community for solutions

---

## **FAQ**

### **Q: Why MySQL 8.0+?**
A: Better performance, InnoDB as default, JSON support, Window functions, improved security

### **Q: Why BCNF normalization?**
A: Eliminates all anomalies, ensures data integrity, prevents redundancy

### **Q: Why 45+ indexes?**
A: Significantly speeds up queries (10-100x), minimal trade-off on insert/update

### **Q: Why UTF8MB4?**
A: Supports all languages, emojis, international characters, better than UTF8

### **Q: Why InnoDB engine?**
A: ACID compliance, foreign key support, transaction safety, crash recovery

### **Q: Can I modify the schema?**
A: Yes, but ensure normalization and integrity. Document changes in pull request.

### **Q: How to add new tables?**
A: Follow normalization rules, use InnoDB, add constraints, create indexes, document properly

### **Q: How to optimize slow queries?**
A: Check EXPLAIN output, add missing indexes, review query logic, consider denormalization

---

## **Support**

For issues or questions:

1. **Check Documentation**: Start with Schema_Documentation.md
2. **Review Guide**: Read SQL_SCHEMA_IMPLEMENTATION_GUIDE.md
3. **Search Issues**: Look for similar issues in GitHub
4. **Create Issue**: If not found, create detailed GitHub issue
5. **Contact Team Lead**: For approvals and decisions

---

## **Version History**

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2024 | Initial schema design with 14 tables, 45+ indexes, 15 views |
| 1.1 | TBD | PL/SQL procedures and triggers |
| 1.2 | TBD | Sample data and performance tuning |
| 2.0 | TBD | Full system integration |

---

## **Contact & Support**

- **GitHub**: [Repository Link]
- **Issues**: [GitHub Issues]
- **Discussions**: [GitHub Discussions]
- **Email**: [Team Email]

---

**Last Updated**: 2024
**Status**: ✅ Schema Complete, Ready for Data Population
**Next Step**: Waiting for Member 3 (PL/SQL) to continue

---

**🎉 Happy Database Design! Start implementing today! 🎉**
