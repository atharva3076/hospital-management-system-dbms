# Data Dictionary
## Hospital Management System - Complete Reference

**Document Version**: 1.0  
**Date**: October 2026  
**Module**: 08_Documentation  
**Prepared By**: Member 5 (Documentation Lead)  

---

## **TABLE OF CONTENTS**

1. [Overview](#overview)
2. [Entity Definitions](#entity-definitions)
3. [Column Specifications](#column-specifications)
4. [Relationships](#relationships)
5. [Constraints](#constraints)
6. [Data Types](#data-types)
7. [Valid Values](#valid-values)

---

## **OVERVIEW**

The Hospital Management System consists of 14 core entities with 150+ total attributes. This data dictionary provides complete specifications for each entity, column, relationship, and constraint.

### **Entity Summary**

| # | Entity | Rows | Purpose | 
|---|--------|------|---------|
| 1 | MANUFACTURER | 10+ | Pharmaceutical suppliers |
| 2 | DEPARTMENT | 10+ | Hospital departments |
| 3 | DOCTOR | 50+ | Medical staff |
| 4 | DOCTOR_SCHEDULE | 100+ | Doctor availability |
| 5 | PATIENT | 500+ | Patient records |
| 6 | APPOINTMENT | 1,000+ | Appointment bookings |
| 7 | MEDICINE | 200+ | Medication inventory |
| 8 | PRESCRIPTION | 500+ | Prescription issuance |
| 9 | PRESCRIPTION_ITEMS | 1,000+ | Prescription details |
| 10 | MEDICAL_HISTORY | 500+ | Patient medical records |
| 11 | LAB_TEST | 50+ | Lab test types |
| 12 | LAB_REPORT | 300+ | Test results |
| 13 | INSURANCE | 200+ | Insurance details |
| 14 | BILLING | 1,000+ | Payment records |

---

## **ENTITY DEFINITIONS**

### **1. MANUFACTURER**

**Purpose**: Store pharmaceutical company information

**Attributes** (9):

| Attribute | Type | Size | Null | Unique | Description |
|-----------|------|------|------|--------|-------------|
| ManufacturerID | INT | - | NO | YES | Primary key, auto-increment |
| MfgName | VARCHAR | 100 | NO | YES | Company name |
| Address | VARCHAR | 255 | NO | NO | Street address |
| City | VARCHAR | 50 | NO | NO | City |
| State | VARCHAR | 50 | NO | NO | State/Province |
| Country | VARCHAR | 50 | NO | NO | Country |
| Phone | VARCHAR | 20 | NO | YES | Contact phone |
| Email | VARCHAR | 100 | NO | YES | Email address |
| RegistrationDate | DATE | - | NO | NO | Registration date |

**Sample Data**:
```
ManufacturerID | MfgName | City | Phone
1 | Pfizer Inc | New York | +1-212-733-2323
2 | Merck & Co | Rahway | +1-908-423-1000
3 | Johnson & Johnson | New Jersey | +1-732-524-0400
```

---

### **2. DEPARTMENT**

**Purpose**: Store hospital department information

**Attributes** (9):

| Attribute | Type | Size | Null | Unique | Description |
|-----------|------|------|------|--------|-------------|
| DepartmentID | INT | - | NO | YES | Primary key, auto-increment |
| DeptName | VARCHAR | 100 | NO | YES | Department name |
| Description | TEXT | - | YES | NO | Department description |
| Building | VARCHAR | 50 | NO | NO | Building location |
| Floor | INT | - | NO | NO | Floor number |
| HeadID | INT | YES | NO | FKREF to DOCTOR(DoctorID) | Department head doctor |
| Phone | VARCHAR | 20 | YES | NO | Department phone |
| Email | VARCHAR | 100 | YES | NO | Department email |
| EstablishedDate | DATE | - | NO | NO | Establishment date |

**Valid Departments**:
- Cardiology, Neurology, Orthopedics, Pediatrics, Dermatology, ENT, Ophthalmology, Dentistry, Psychiatry, Oncology, etc.

---

### **3. DOCTOR**

**Purpose**: Store doctor/medical staff information

**Attributes** (16):

| Attribute | Type | Size | Null | Unique | Description |
|-----------|------|------|------|--------|-------------|
| DoctorID | INT | - | NO | YES | Primary key, auto-increment |
| FirstName | VARCHAR | 50 | NO | NO | First name |
| LastName | VARCHAR | 50 | NO | NO | Last name |
| DOB | DATE | - | NO | NO | Date of birth |
| Gender | ENUM | - | NO | NO | 'M' or 'F' |
| Qualification | VARCHAR | 200 | NO | NO | Medical degree (MBBS, MD, DM) |
| Specialization | VARCHAR | 100 | NO | NO | Medical specialty |
| RegistrationNumber | VARCHAR | 50 | NO | YES | Medical license number |
| DepartmentID | INT | - | NO | FK | Reference to DEPARTMENT |
| Phone | VARCHAR | 20 | NO | YES | Contact phone |
| Email | VARCHAR | 100 | NO | YES | Email address |
| JoiningDate | DATE | - | NO | NO | Hospital joining date |
| YearsOfExperience | INT | - | NO | NO | Years in practice |
| ConsultationFeePerHour | DECIMAL | 10,2 | NO | NO | Hourly consultation fee |
| IsActive | BOOLEAN | - | NO | NO | Active/Inactive status |
| CreatedDate | TIMESTAMP | - | NO | NO | Record creation date |

**Sample Data**:
```
DoctorID | FirstName | LastName | Specialization | DepartmentID
1 | Rajesh | Kumar | Cardiology | 1
2 | Priya | Singh | Neurology | 2
3 | Amit | Sharma | Orthopedics | 3
```

---

### **4. DOCTOR_SCHEDULE**

**Purpose**: Store doctor's availability schedule

**Attributes** (7):

| Attribute | Type | Size | Null | Unique | Description |
|-----------|------|------|------|--------|-------------|
| ScheduleID | INT | - | NO | YES | Primary key, auto-increment |
| DoctorID | INT | - | NO | FK | Reference to DOCTOR |
| DayOfWeek | ENUM | - | NO | NO | MON, TUE, WED, THU, FRI, SAT, SUN |
| StartTime | TIME | - | NO | NO | Shift start time |
| EndTime | TIME | - | NO | NO | Shift end time |
| IsAvailable | BOOLEAN | - | NO | NO | Available (TRUE/FALSE) |
| CreatedDate | TIMESTAMP | - | NO | NO | Record creation date |

**Composite Key**: (DoctorID, DayOfWeek) - Doctor appears once per day

**Sample Data**:
```
ScheduleID | DoctorID | DayOfWeek | StartTime | EndTime | IsAvailable
1 | 1 | MON | 09:00:00 | 17:00:00 | TRUE
2 | 1 | TUE | 10:00:00 | 18:00:00 | TRUE
3 | 1 | WED | NULL | NULL | FALSE (day off)
```

---

### **5. PATIENT**

**Purpose**: Store patient demographics and contact information

**Attributes** (18):

| Attribute | Type | Size | Null | Unique | Description |
|-----------|------|------|------|--------|-------------|
| PatientID | INT | - | NO | YES | Primary key, auto-increment |
| FirstName | VARCHAR | 50 | NO | NO | First name |
| LastName | VARCHAR | 50 | NO | NO | Last name |
| DOB | DATE | - | NO | NO | Date of birth (CHECK: >0 years old) |
| Gender | ENUM | - | NO | NO | 'M' or 'F' |
| BloodGroup | ENUM | - | NO | NO | A+, A-, B+, B-, AB+, AB-, O+, O- |
| Height | DECIMAL | 5,2 | NO | NO | Height in cm (CHECK: >0) |
| Weight | DECIMAL | 5,2 | NO | NO | Weight in kg (CHECK: >0) |
| Address | VARCHAR | 255 | NO | NO | Street address |
| City | VARCHAR | 50 | NO | NO | City |
| State | VARCHAR | 50 | NO | NO | State/Province |
| Phone | VARCHAR | 20 | NO | YES | Contact phone |
| Email | VARCHAR | 100 | NO | YES | Email address |
| PatientType | ENUM | - | NO | NO | OPD (Out-Patient) or IPD (In-Patient) |
| EmergencyContact | VARCHAR | 100 | NO | NO | Emergency contact name (REQUIRED) |
| EmergencyContactPhone | VARCHAR | 20 | NO | NO | Emergency contact phone |
| IsActive | BOOLEAN | - | NO | NO | Active/Inactive status |
| RegistrationDate | TIMESTAMP | - | NO | NO | Registration date |

---

### **6. APPOINTMENT**

**Purpose**: Store appointment bookings

**Attributes** (11):

| Attribute | Type | Size | Null | Unique | Description |
|-----------|------|------|------|--------|-------------|
| AppointmentID | INT | - | NO | YES | Primary key, auto-increment |
| PatientID | INT | - | NO | FK | Reference to PATIENT |
| DoctorID | INT | - | NO | FK | Reference to DOCTOR |
| AppointmentDate | DATE | - | NO | NO | Appointment date (CHECK: >=TODAY) |
| AppointmentTime | TIME | - | NO | NO | Appointment time (CHECK: 09:00-18:00) |
| Reason | VARCHAR | 255 | NO | NO | Reason for appointment |
| Status | ENUM | - | NO | NO | Scheduled, Completed, Cancelled |
| ConsultationFee | DECIMAL | 10,2 | NO | NO | Consultation charge |
| Notes | TEXT | - | YES | NO | Doctor notes |
| CreatedDate | TIMESTAMP | - | NO | NO | Booking date |
| ModifiedDate | TIMESTAMP | - | NO | NO | Last modified date |

**Constraints**:
- AppointmentDate >= CURDATE() (future appointments only)
- AppointmentTime between 09:00 and 18:00
- PatientID and DoctorID must exist

---

### **7. MEDICINE**

**Purpose**: Store medication and inventory information

**Attributes** (14):

| Attribute | Type | Size | Null | Unique | Description |
|-----------|------|------|------|--------|-------------|
| MedicineID | INT | - | NO | YES | Primary key, auto-increment |
| MedicineName | VARCHAR | 100 | NO | YES | Brand name |
| GenericName | VARCHAR | 100 | NO | NO | Generic name |
| Type | VARCHAR | 50 | NO | NO | Antibiotic, Analgesic, etc. |
| ManufacturerID | INT | - | NO | FK | Reference to MANUFACTURER |
| UnitPrice | DECIMAL | 10,2 | NO | NO | Price per unit (CHECK: >0) |
| Dosage | VARCHAR | 50 | NO | NO | Standard dosage (500mg, 10ml) |
| QuantityInStock | INT | - | NO | NO | Units available (CHECK: >=0) |
| ReorderLevel | INT | - | NO | NO | Minimum stock level |
| ManufactureDate | DATE | - | NO | NO | Manufacturing date |
| ExpiryDate | DATE | - | NO | NO | Expiration date (CHECK: >ManufactureDate) |
| SideEffects | TEXT | - | YES | NO | Known side effects |
| IsActive | BOOLEAN | - | NO | NO | Active/Inactive status |
| CreatedDate | TIMESTAMP | - | NO | NO | Record creation date |

---

### **8-9. PRESCRIPTION & PRESCRIPTION_ITEMS**

**PRESCRIPTION** (7 attributes):

| Attribute | Type | Null | Description |
|-----------|------|------|-------------|
| PrescriptionID | INT | NO | Primary key, auto-increment |
| AppointmentID | INT | NO | FK to APPOINTMENT |
| DoctorID | INT | NO | FK to DOCTOR |
| PrescriptionDate | DATE | NO | Date issued |
| Notes | TEXT | YES | Additional notes |
| Status | ENUM | NO | Active, Fulfilled, Expired |
| CreatedDate | TIMESTAMP | NO | Creation date |

**PRESCRIPTION_ITEMS** (9 attributes - Weak Entity):

| Attribute | Type | Null | Description |
|-----------|------|------|-------------|
| PrescriptionItemID | INT | NO | Primary key |
| PrescriptionID | INT | NO | FK to PRESCRIPTION |
| MedicineID | INT | NO | FK to MEDICINE |
| Dosage | VARCHAR | NO | Quantity per dose |
| Frequency | VARCHAR | NO | Times per day (1X, 2X, 3X) |
| Duration | VARCHAR | NO | Number of days |
| Quantity | INT | NO | Total pills/ml |
| Instructions | TEXT | YES | Special instructions |
| CreatedDate | TIMESTAMP | NO | Creation date |

---

### **10-12. MEDICAL_HISTORY, LAB_TEST, LAB_REPORT**

**MEDICAL_HISTORY** (8 attributes):

| Attribute | Type | Null | Description |
|-----------|------|------|-------------|
| HistoryID | INT | NO | Primary key |
| PatientID | INT | NO | FK to PATIENT |
| Diagnosis | VARCHAR | NO | Medical diagnosis |
| Symptoms | TEXT | NO | Reported symptoms |
| Severity | ENUM | NO | Mild, Moderate, Severe |
| TreatmentDate | DATE | NO | Treatment date |
| Outcome | VARCHAR | YES | Treatment outcome |
| CreatedDate | TIMESTAMP | NO | Record date |

**LAB_TEST** (8 attributes):

| Attribute | Type | Null | Description |
|-----------|------|------|-------------|
| TestID | INT | NO | Primary key |
| TestName | VARCHAR | NO | Lab test name |
| Description | TEXT | YES | Test description |
| NormalRange | VARCHAR | NO | Normal value range |
| Unit | VARCHAR | NO | Measurement unit |
| Cost | DECIMAL | NO | Test cost |
| TurnaroundTime | INT | NO | Result delivery in hours |
| IsActive | BOOLEAN | NO | Active/Inactive |

**LAB_REPORT** (11 attributes):

| Attribute | Type | Null | Description |
|-----------|------|------|-------------|
| ReportID | INT | NO | Primary key |
| PatientID | INT | NO | FK to PATIENT |
| TestID | INT | NO | FK to LAB_TEST |
| Result | VARCHAR | NO | Test result value |
| Interpretation | TEXT | NO | Doctor interpretation |
| ApprovedBy | INT | YES | FK to DOCTOR (approver) |
| ReportDate | DATE | NO | Report generated date |
| ApprovalDate | DATE | YES | Approval date |
| Status | ENUM | NO | Pending, Approved, Rejected |
| CreatedDate | TIMESTAMP | NO | Creation date |

---

### **13. INSURANCE**

**Purpose**: Store patient insurance details (1:1 optional relationship)

**Attributes** (9):

| Attribute | Type | Null | Description |
|-----------|------|------|-------------|
| InsuranceID | INT | NO | Primary key |
| PatientID | INT | NO | FK to PATIENT (UNIQUE) |
| InsuranceProvider | VARCHAR | NO | Insurance company name |
| PolicyNumber | VARCHAR | NO | Policy number (UNIQUE) |
| CoverageAmount | DECIMAL | NO | Maximum coverage (CHECK: >0) |
| CoveragePercentage | INT | NO | Coverage % (CHECK: 0-100) |
| StartDate | DATE | NO | Coverage start date |
| EndDate | DATE | YES | Coverage end date |
| CreatedDate | TIMESTAMP | NO | Record date |

---

### **14. BILLING**

**Purpose**: Store billing and payment information

**Attributes** (19):

| Attribute | Type | Null | Description |
|-----------|------|------|-------------|
| BillingID | INT | NO | Primary key |
| BillingNumber | VARCHAR | NO | Unique bill number (UNIQUE) |
| PatientID | INT | NO | FK to PATIENT |
| AppointmentID | INT | NO | FK to APPOINTMENT (UNIQUE 1:1) |
| InsuranceID | INT | YES | FK to INSURANCE (optional) |
| ConsultationCharges | DECIMAL | NO | Doctor fee |
| LabCharges | DECIMAL | NO | Lab test charges |
| MedicineCharges | DECIMAL | NO | Medicine cost |
| OtherCharges | DECIMAL | NO | Additional charges |
| TotalCharges | DECIMAL | NO | Sum of all charges (CHECK: >0) |
| InsuranceCoverage | DECIMAL | NO | Amount covered |
| PatientPayable | DECIMAL | NO | Amount patient pays |
| AmountPaid | DECIMAL | NO | Amount actually paid |
| PaymentStatus | ENUM | NO | Pending, Partial, Paid |
| PaymentMethod | ENUM | YES | Cash, Card, Cheque, Online |
| BillingDate | DATE | NO | Bill creation date |
| DueDate | DATE | NO | Payment due date |
| PaidDate | DATE | YES | Actual payment date |
| Remarks | TEXT | YES | Payment remarks |

---

## **RELATIONSHIPS**

### **Foreign Key Relationships**

```
MANUFACTURER (1) ──┬──── (N) MEDICINE
                   └─ MedicineFK: ManufacturerID

DEPARTMENT (1) ────┬──── (N) DOCTOR
                   └─ DoctorFK: DepartmentID

DEPARTMENT (1) ──── (1) DOCTOR (as HeadID)
                   └─ Dept FK: HeadID

DOCTOR (1) ────┬──── (N) DOCTOR_SCHEDULE
               ├──── (N) APPOINTMENT
               └──── (N) LAB_REPORT (as ApprovedBy)

PATIENT (1) ────┬──── (N) APPOINTMENT
                ├──── (N) MEDICAL_HISTORY
                ├──── (1) INSURANCE (optional)
                ├──── (N) LAB_REPORT
                └──── (1) BILLING

APPOINTMENT (1) ┬──── (N) PRESCRIPTION
                └──── (1) BILLING (unique)

PRESCRIPTION (1) ┬──── (N) PRESCRIPTION_ITEMS
                 └─ PrescFK: PrescriptionID

MEDICINE (1) ──── (N) PRESCRIPTION_ITEMS
              └─ MedFK: MedicineID

LAB_TEST (1) ──── (N) LAB_REPORT
             └─ TestFK: TestID
```

---

## **CONSTRAINTS**

### **Check Constraints**

```sql
-- PATIENT table
CHECK (DATEDIFF(CURDATE(), DOB) > 0)  -- Age > 0
CHECK (Height > 0)
CHECK (Weight > 0)

-- MEDICINE table
CHECK (UnitPrice > 0)
CHECK (QuantityInStock >= 0)
CHECK (ExpiryDate > ManufactureDate)

-- APPOINTMENT table
CHECK (AppointmentDate >= CURDATE())
CHECK (TIME(AppointmentTime) >= '09:00:00' AND TIME(AppointmentTime) <= '18:00:00')

-- INSURANCE table
CHECK (CoverageAmount > 0)
CHECK (CoveragePercentage BETWEEN 0 AND 100)

-- BILLING table
CHECK (TotalCharges > 0)
CHECK (PatientPayable >= 0)
```

### **Unique Constraints**

```
DOCTOR: RegistrationNumber, Phone, Email
PATIENT: Phone, Email
MANUFACTURER: MfgName, Phone, Email
MEDICINE: MedicineName
INSURANCE: PatientID (1:1), PolicyNumber
BILLING: BillingNumber, AppointmentID (1:1)
DEPARTMENT: DeptName
```

---

## **DATA TYPES**

### **Used Data Types**

```
INT: Integer numbers (IDs, quantities, years)
DECIMAL(10,2): Monetary values and precise decimals
VARCHAR(n): Variable character strings (names, addresses)
TEXT: Large text fields (descriptions, notes)
DATE: Date values (YYYY-MM-DD)
TIME: Time values (HH:MM:SS)
TIMESTAMP: Date + Time auto-updated
ENUM: Fixed set of values (Gender: M/F, Status: Scheduled/Completed)
BOOLEAN: TRUE/FALSE values
```

---

## **VALID VALUES**

### **Enum Fields**

```
DOCTOR.Gender: 'M', 'F'
PATIENT.Gender: 'M', 'F'
PATIENT.BloodGroup: 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'
PATIENT.PatientType: 'OPD', 'IPD'
APPOINTMENT.Status: 'Scheduled', 'Completed', 'Cancelled'
PRESCRIPTION.Status: 'Active', 'Fulfilled', 'Expired'
PRESCRIPTION_ITEMS.Frequency: '1X', '2X', '3X', '4X'
LAB_REPORT.Status: 'Pending', 'Approved', 'Rejected'
MEDICAL_HISTORY.Severity: 'Mild', 'Moderate', 'Severe'
BILLING.PaymentStatus: 'Pending', 'Partial', 'Paid'
BILLING.PaymentMethod: 'Cash', 'Card', 'Cheque', 'Online'
DOCTOR_SCHEDULE.DayOfWeek: 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'
```

---

## **SUMMARY**

✅ **14 Core Entities** with complete definitions
✅ **150+ Attributes** with specifications
✅ **17 Relationships** properly documented
✅ **40+ Constraints** for data integrity
✅ **Valid values** for all enum fields

This data dictionary provides the complete reference for the Hospital Management System database.

---
