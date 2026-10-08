# Hospital Management System - Schema Documentation
## Complete Database Design Reference

---

## **TABLE OF CONTENTS**

1. [Database Overview](#database-overview)
2. [Table Descriptions](#table-descriptions)
3. [Data Dictionary](#data-dictionary)
4. [Relationships](#relationships)
5. [Constraints Summary](#constraints-summary)
6. [Indexes Summary](#indexes-summary)
7. [Views Documentation](#views-documentation)
8. [Query Examples](#query-examples)

---

## **DATABASE OVERVIEW**

**Database Name**: `hospital_management_system`
**Character Set**: UTF8MB4 (supports all languages)
**Collation**: utf8mb4_unicode_ci (case-insensitive)
**Engine**: InnoDB (ACID compliance, transactions)
**Total Tables**: 14
**Total Views**: 15
**Total Indexes**: 45+
**Normalization Level**: 1NF to BCNF

### **Purpose**

Complete database for managing:
- Patient demographics and medical history
- Doctor information and schedules
- Hospital departments
- Appointments and consultations
- Prescriptions and medicines
- Lab tests and results
- Billing and insurance
- Audit trails and alerts

---

## **TABLE DESCRIPTIONS**

### **TABLE 1: MANUFACTURER**

**Purpose**: Store medicine manufacturers/suppliers

| Column | Type | Key | Constraint | Description |
|--------|------|-----|-----------|-------------|
| ManufacturerID | INT | PK | AUTO_INCREMENT | Unique identifier |
| MfgName | VARCHAR(100) | | NOT NULL | Company name |
| Phone | VARCHAR(20) | | NOT NULL | Contact phone |
| Address | TEXT | | NOT NULL | Business address |
| Email | VARCHAR(100) | | | Email address |
| Website | VARCHAR(100) | | | Company website |
| Country | VARCHAR(50) | | | Manufacturing country |
| CreatedDate | TIMESTAMP | | DEFAULT CURRENT_TIMESTAMP | Record creation |
| LastModifiedDate | TIMESTAMP | | AUTO UPDATE | Last update |
| IsActive | BOOLEAN | | DEFAULT TRUE | Status flag |

**Indexes**: idx_manufacturer_name, idx_manufacturer_active, idx_manufacturer_country

---

### **TABLE 2: DEPARTMENT**

**Purpose**: Hospital departments and their information

| Column | Type | Key | Constraint | Description |
|--------|------|-----|-----------|-------------|
| DepartmentID | INT | PK | AUTO_INCREMENT | Unique identifier |
| DeptName | VARCHAR(100) | UQ | NOT NULL | Department name (Cardiology, etc.) |
| Floor | INT | | CHECK (Floor 0-10) | Floor location |
| Building | VARCHAR(50) | | | Building identifier |
| HeadID | INT | FK | | Department head doctor ID |
| Phone | VARCHAR(20) | | | Department extension |
| Email | VARCHAR(100) | | UNIQUE | Department email |
| MaxBeds | INT | | CHECK > 0 | Bed capacity |
| CreatedDate | TIMESTAMP | | DEFAULT | Creation date |
| LastModifiedDate | TIMESTAMP | | AUTO UPDATE | Modification date |
| IsActive | BOOLEAN | | DEFAULT TRUE | Active status |

**Relationships**: 
- (1) DEPARTMENT → (M) DOCTOR
- (1) DEPARTMENT → (M) DOCTOR_SCHEDULE

**Indexes**: idx_department_name, idx_department_floor, idx_department_active

---

### **TABLE 3: DOCTOR**

**Purpose**: Doctor/physician information

| Column | Type | Key | Constraint | Description |
|--------|------|-----|-----------|-------------|
| DoctorID | INT | PK | AUTO_INCREMENT | Unique identifier |
| FirstName | VARCHAR(50) | | NOT NULL | First name |
| LastName | VARCHAR(50) | | NOT NULL | Last name |
| Qualification | VARCHAR(100) | | NOT NULL | MD, MBBS, etc. |
| Specialization | VARCHAR(100) | | NOT NULL | Cardiology, Neurology, etc. |
| DepartmentID | INT | FK | NOT NULL | Department assigned |
| Phone | VARCHAR(20) | UQ | NOT NULL | Contact phone |
| Email | VARCHAR(100) | UQ | NOT NULL | Email address |
| LicenseNumber | VARCHAR(50) | UQ | | Medical license |
| YearsOfExperience | INT | | CHECK >= 0 | Years of practice |
| ConsultationFee | DECIMAL(10,2) | | CHECK > 0 | Fee per consultation |
| AvailabilityStatus | ENUM | | | Available/Busy/On Leave/Retired |
| CreatedDate | TIMESTAMP | | DEFAULT | Record creation |
| LastModifiedDate | TIMESTAMP | | AUTO UPDATE | Last update |
| IsActive | BOOLEAN | | DEFAULT TRUE | Active status |

**Relationships**:
- (M) DOCTOR → (1) DEPARTMENT (foreign key)
- (1) DOCTOR → (M) APPOINTMENT
- (1) DOCTOR → (M) PRESCRIPTION
- (1) DOCTOR → (M) DOCTOR_SCHEDULE

**Indexes**: idx_doctor_specialization, idx_doctor_department, idx_doctor_availability, idx_doctor_active, idx_doctor_fullname

---

### **TABLE 4: DOCTOR_SCHEDULE**

**Purpose**: Doctor weekly working schedule

| Column | Type | Key | Constraint | Description |
|--------|------|-----|-----------|-------------|
| ScheduleID | INT | PK | AUTO_INCREMENT | Unique identifier |
| DoctorID | INT | FK | NOT NULL | Doctor this schedule belongs to |
| DayOfWeek | ENUM | | NOT NULL | Monday-Sunday |
| StartTime | TIME | | NOT NULL | Shift start |
| EndTime | TIME | | NOT NULL, CHECK > StartTime | Shift end |
| MaxAppointmentsPerDay | INT | | CHECK > 0 | Max appointments allowed |
| IsOnDuty | BOOLEAN | | DEFAULT TRUE | On duty flag |
| CreatedDate | TIMESTAMP | | DEFAULT | Creation date |
| LastModifiedDate | TIMESTAMP | | AUTO UPDATE | Last update |

**Unique Constraint**: unique_doctor_day (DoctorID, DayOfWeek)

**Indexes**: idx_schedule_doctor, idx_schedule_day, idx_schedule_doctor_day

---

### **TABLE 5: PATIENT**

**Purpose**: Patient demographic and medical information

| Column | Type | Key | Constraint | Description |
|--------|------|-----|-----------|-------------|
| PatientID | INT | PK | AUTO_INCREMENT | Unique identifier |
| FirstName | VARCHAR(50) | | NOT NULL | First name |
| LastName | VARCHAR(50) | | NOT NULL | Last name |
| DateOfBirth | DATE | | NOT NULL, CHECK <= CURDATE() | Birth date |
| Gender | ENUM | | NOT NULL | Male/Female/Other |
| BloodGroup | VARCHAR(5) | | CHECK IN (...) | A+, B-, O+, AB-, etc. |
| Address | TEXT | | NOT NULL | Residential address |
| Phone | VARCHAR(20) | UQ | NOT NULL | Contact phone |
| Email | VARCHAR(100) | UQ | | Email address |
| EmergencyContactName | VARCHAR(100) | | NOT NULL | Emergency contact person |
| EmergencyContactPhone | VARCHAR(20) | | NOT NULL | Emergency contact phone |
| EmergencyContactRelation | VARCHAR(50) | | | Relation to patient |
| Allergies | TEXT | | | Known allergies |
| ChronicDiseases | TEXT | | | Chronic conditions |
| PatientStatus | ENUM | | DEFAULT Active | Active/Inactive/Discharged |
| CreatedDate | TIMESTAMP | | DEFAULT | Record creation |
| LastModifiedDate | TIMESTAMP | | AUTO UPDATE | Last update |
| IsActive | BOOLEAN | | DEFAULT TRUE | Active status |

**Relationships**:
- (1) PATIENT → (M) APPOINTMENT
- (1) PATIENT → (M) MEDICAL_HISTORY
- (1) PATIENT → (M) LAB_REPORT
- (1) PATIENT → (M) BILLING
- (1) PATIENT → (M) INSURANCE

**Indexes**: idx_patient_blood_group, idx_patient_phone, idx_patient_email, idx_patient_active, idx_patient_status, idx_patient_fullname, idx_patient_dob

---

### **TABLE 6: APPOINTMENT**

**Purpose**: Patient-doctor appointments/consultations

| Column | Type | Key | Constraint | Description |
|--------|------|-----|-----------|-------------|
| AppointmentID | INT | PK | AUTO_INCREMENT | Unique identifier |
| PatientID | INT | FK | NOT NULL | Patient ID |
| DoctorID | INT | FK | NOT NULL | Doctor ID |
| AppointmentDate | DATE | | NOT NULL, CHECK >= CURDATE() | Appointment date |
| AppointmentTime | TIME | | NOT NULL | Appointment time |
| ReasonForVisit | VARCHAR(255) | | NOT NULL | Chief complaint/reason |
| Status | ENUM | | DEFAULT Scheduled | Scheduled/Completed/No-Show/Cancelled/Rescheduled |
| ConsultationNotes | TEXT | | | Doctor's notes |
| CancelledDate | DATETIME | | | When cancelled |
| CancellationReason | VARCHAR(255) | | | Why cancelled |
| EstimatedDuration | INT | | CHECK > 0 | Minutes |
| ActualDuration | INT | | CHECK > 0 OR NULL | Minutes taken |
| RoomNumber | VARCHAR(10) | | | Room/cabin assignment |
| CreatedDate | TIMESTAMP | | DEFAULT | Creation date |
| LastModifiedDate | TIMESTAMP | | AUTO UPDATE | Last update |

**Unique Constraint**: unique_appointment (PatientID, DoctorID, AppointmentDate, AppointmentTime)

**Indexes**: idx_appointment_date, idx_appointment_status, idx_appointment_patient, idx_appointment_doctor, idx_appointment_doctor_date, idx_appointment_patient_date, idx_appointment_date_status, idx_appointment_cancelled_date

---

### **TABLE 7: MEDICAL_HISTORY**

**Purpose**: Patient medical diagnosis and treatment records

| Column | Type | Key | Constraint | Description |
|--------|------|-----|-----------|-------------|
| HistoryID | INT | PK | AUTO_INCREMENT | Unique identifier |
| PatientID | INT | FK | NOT NULL | Patient ID |
| AppointmentID | INT | FK | | Associated appointment |
| Diagnosis | VARCHAR(255) | | NOT NULL | Medical diagnosis |
| Symptoms | TEXT | | NOT NULL | Reported symptoms |
| TreatmentPlan | TEXT | | NOT NULL | Prescribed treatment |
| DoctorNotes | TEXT | | | Additional notes |
| Outcome | VARCHAR(100) | | | Recovered/Ongoing/etc. |
| CreatedDate | TIMESTAMP | | DEFAULT | Record date |
| LastModifiedDate | TIMESTAMP | | AUTO UPDATE | Last update |

**Indexes**: idx_history_patient, idx_history_appointment, idx_history_date, idx_history_diagnosis

---

### **TABLE 8: LAB_TEST**

**Purpose**: Available laboratory tests

| Column | Type | Key | Constraint | Description |
|--------|------|-----|-----------|-------------|
| TestID | INT | PK | AUTO_INCREMENT | Unique identifier |
| TestName | VARCHAR(100) | UQ | NOT NULL | Test name (CBC, etc.) |
| Description | TEXT | | NOT NULL | What the test measures |
| NormalRange | VARCHAR(100) | | | Normal result range |
| Unit | VARCHAR(50) | | | Unit of measurement |
| CostPrice | DECIMAL(10,2) | | CHECK > 0 | Test cost to patient |
| CollectionMethod | VARCHAR(100) | | | Blood draw, urine, etc. |
| TurnaroundDays | INT | | CHECK > 0 | Days for results |
| IsActive | BOOLEAN | | DEFAULT TRUE | Active status |
| CreatedDate | TIMESTAMP | | DEFAULT | Creation date |
| LastModifiedDate | TIMESTAMP | | AUTO UPDATE | Last update |

**Indexes**: idx_lab_test_name, idx_lab_test_active

---

### **TABLE 9: LAB_REPORT**

**Purpose**: Lab test results for patients

| Column | Type | Key | Constraint | Description |
|--------|------|-----|-----------|-------------|
| ReportID | INT | PK | AUTO_INCREMENT | Unique identifier |
| PatientID | INT | FK | NOT NULL | Patient who took test |
| TestID | INT | FK | NOT NULL | Type of test |
| AppointmentID | INT | FK | | Associated appointment |
| TestDate | DATE | | NOT NULL, CHECK <= CURDATE() | Test date |
| ResultValue | VARCHAR(100) | | NOT NULL | Actual result |
| Status | ENUM | | DEFAULT Pending | Pending/Completed/Abnormal/Critical |
| NormalRangeMin | DECIMAL(10,2) | | | Min normal value |
| NormalRangeMax | DECIMAL(10,2) | | | Max normal value |
| IsAbnormal | BOOLEAN | | DEFAULT FALSE | Abnormality flag |
| LabTechnicianNotes | TEXT | | | Technician notes |
| DoctorReview | TEXT | | | Doctor's review |
| DoctorReviewDate | DATETIME | | | When reviewed |
| CreatedDate | TIMESTAMP | | DEFAULT | Creation date |
| LastModifiedDate | TIMESTAMP | | AUTO UPDATE | Last update |

**Indexes**: idx_lab_report_patient, idx_lab_report_test, idx_lab_report_date, idx_lab_report_status, idx_lab_report_abnormal, idx_lab_report_patient_date, idx_lab_report_appointment

---

### **TABLE 10: MEDICINE**

**Purpose**: Medicine/pharmaceutical inventory

| Column | Type | Key | Constraint | Description |
|--------|------|-----|-----------|-------------|
| MedicineID | INT | PK | AUTO_INCREMENT | Unique identifier |
| MedicineName | VARCHAR(100) | UQ | NOT NULL | Medicine name |
| Type | ENUM | | NOT NULL | Tablet/Injection/Syrup/etc. |
| ManufacturerID | INT | FK | NOT NULL | Medicine manufacturer |
| GenericName | VARCHAR(100) | | | Chemical generic name |
| Strength | VARCHAR(50) | | | Dosage strength (500mg) |
| UnitPrice | DECIMAL(10,2) | | CHECK > 0 | Price per unit |
| QuantityInStock | INT | | CHECK >= 0 | Current stock |
| MinimumStock | INT | | CHECK >= 0 | Minimum level |
| ReorderLevel | INT | | CHECK >= MinStock | Reorder trigger level |
| ExpiryDate | DATE | | CHECK > CURDATE() | Expiry date |
| StorageLocation | VARCHAR(100) | | | Where stored |
| SideEffects | TEXT | | | Known side effects |
| Contraindications | TEXT | | | When not to use |
| Interactions | TEXT | | | Drug interactions |
| CreatedDate | TIMESTAMP | | DEFAULT | Creation date |
| LastModifiedDate | TIMESTAMP | | AUTO UPDATE | Last update |
| IsActive | BOOLEAN | | DEFAULT TRUE | Active status |

**Indexes**: idx_medicine_name, idx_medicine_manufacturer, idx_medicine_expiry, idx_medicine_active, idx_medicine_stock, idx_medicine_stock_expiry, idx_medicine_type

---

### **TABLE 11: PRESCRIPTION**

**Purpose**: Prescriptions issued to patients

| Column | Type | Key | Constraint | Description |
|--------|------|-----|-----------|-------------|
| PrescriptionID | INT | PK | AUTO_INCREMENT | Unique identifier |
| AppointmentID | INT | FK | NOT NULL | Associated appointment |
| DoctorID | INT | FK | NOT NULL | Doctor who issued |
| PatientID | INT | FK | NOT NULL | Patient for whom |
| CreatedDate | DATE | | NOT NULL, DEFAULT TODAY | Prescription date |
| ExpiryDate | DATE | | CHECK > CreatedDate OR NULL | Expiry date |
| Notes | TEXT | | | Special instructions |
| Status | ENUM | | DEFAULT Active | Active/Completed/Expired/Cancelled |
| RefillsAllowed | INT | | CHECK >= 0 | Max refills allowed |
| RefillsUsed | INT | | CHECK >= 0, <= RefillsAllowed | Refills already used |
| LastFillDate | DATE | | | When last filled |
| CreatedDateTime | TIMESTAMP | | DEFAULT | Creation timestamp |
| LastModifiedDate | TIMESTAMP | | AUTO UPDATE | Last update |

**Indexes**: idx_prescription_patient, idx_prescription_doctor, idx_prescription_appointment, idx_prescription_created_date, idx_prescription_status, idx_prescription_patient_status, idx_prescription_expiry

---

### **TABLE 12: PRESCRIPTION_ITEMS**

**Purpose**: Individual medicines in a prescription

| Column | Type | Key | Constraint | Description |
|--------|------|-----|-----------|-------------|
| PrescriptionItemID | INT | PK | AUTO_INCREMENT | Unique identifier |
| PrescriptionID | INT | FK | NOT NULL | Prescription ID |
| MedicineID | INT | FK | NOT NULL | Medicine ID |
| Dosage | VARCHAR(50) | | NOT NULL | Dose per dose (500mg) |
| Frequency | VARCHAR(50) | | CHECK IN (...) | How often (Twice Daily) |
| Duration | INT | | CHECK > 0 | Duration in days |
| Instructions | TEXT | | | Special instructions |
| Quantity | INT | | CHECK > 0 | Total quantity |
| IsRefillable | BOOLEAN | | DEFAULT TRUE | Can be refilled |
| CreatedDate | TIMESTAMP | | DEFAULT | Creation date |
| LastModifiedDate | TIMESTAMP | | AUTO UPDATE | Last update |

**Indexes**: idx_prescription_items_prescription, idx_prescription_items_medicine

---

### **TABLE 13: BILLING**

**Purpose**: Patient billing and payment records

| Column | Type | Key | Constraint | Description |
|--------|------|-----|-----------|-------------|
| BillingID | INT | PK | AUTO_INCREMENT | Unique identifier |
| PatientID | INT | FK | NOT NULL | Patient ID |
| AppointmentID | INT | FK | NOT NULL | Appointment ID |
| ConsultationFee | DECIMAL(10,2) | | CHECK >= 0 | Doctor fee |
| LabTestFee | DECIMAL(10,2) | | CHECK >= 0 | Lab fees |
| MedicineCost | DECIMAL(10,2) | | CHECK >= 0 | Medicine cost |
| OtherCharges | DECIMAL(10,2) | | CHECK >= 0 | Other charges |
| Discount | DECIMAL(10,2) | | CHECK >= 0 | Discount given |
| TaxAmount | DECIMAL(10,2) | | CHECK >= 0 | Tax/GST |
| TotalAmount | DECIMAL(10,2) | | NOT NULL | Final total (calculated) |
| AmountPaid | DECIMAL(10,2) | | CHECK >= 0 | Amount paid |
| PatientPayable | DECIMAL(10,2) | | | Amount still owed |
| PaymentStatus | ENUM | | DEFAULT Unpaid | Paid/Partial/Unpaid/Refunded |
| PaymentMethod | VARCHAR(50) | | | Cash/Card/etc. |
| InsuranceCoverageAmount | DECIMAL(10,2) | | CHECK >= 0 | Insurance coverage |
| BillingDate | DATE | | NOT NULL, DEFAULT TODAY | Bill date |
| DueDate | DATE | | CHECK >= BillingDate OR NULL | Payment due date |
| PaymentDate | DATE | | | Actual payment date |
| CreatedDate | TIMESTAMP | | DEFAULT | Creation date |
| LastModifiedDate | TIMESTAMP | | AUTO UPDATE | Last update |

**Calculation Constraint**: TotalAmount = ConsultationFee + LabTestFee + MedicineCost + OtherCharges + TaxAmount - Discount

**Indexes**: idx_billing_patient, idx_billing_appointment, idx_billing_date, idx_billing_status, idx_billing_due_date, idx_billing_status_due, idx_billing_patient_status, idx_billing_payment_date

---

### **TABLE 14: INSURANCE**

**Purpose**: Patient insurance information

| Column | Type | Key | Constraint | Description |
|--------|------|-----|-----------|-------------|
| InsuranceID | INT | PK | AUTO_INCREMENT | Unique identifier |
| PatientID | INT | FK | NOT NULL | Patient ID |
| BillingID | INT | FK | | Related billing record |
| InsuranceProvider | VARCHAR(100) | | NOT NULL | Insurance company |
| PolicyNumber | VARCHAR(50) | UQ | NOT NULL | Policy number |
| CoveragePercentage | INT | | CHECK 0-100 | Coverage percentage |
| CoverageLimit | DECIMAL(15,2) | | CHECK > 0 OR NULL | Max coverage limit |
| ValidFromDate | DATE | | NOT NULL | Policy start |
| ValidToDate | DATE | | NOT NULL, CHECK > ValidFromDate | Policy end |
| PolicyType | VARCHAR(50) | | CHECK IN (...) | Individual/Family/Group |
| PreAuthorizationNumber | VARCHAR(50) | | | Pre-auth for procedures |
| CoverageStatus | ENUM | | DEFAULT Active | Active/Inactive/Expired/Suspended |
| ClaimsProcessed | INT | | CHECK >= 0 | Number of claims |
| TotalClaimsAmount | DECIMAL(15,2) | | CHECK >= 0 | Total claimed amount |
| RemainingCoverage | DECIMAL(15,2) | | | Remaining available |
| CreatedDate | TIMESTAMP | | DEFAULT | Creation date |
| LastModifiedDate | TIMESTAMP | | AUTO UPDATE | Last update |

**Indexes**: idx_insurance_patient, idx_insurance_billing, idx_insurance_status, idx_insurance_policy, idx_insurance_valid_dates, idx_insurance_provider

---

## **RELATIONSHIPS**

### **Entity Relationship Diagram (Text Format)**

```
MANUFACTURER (1) ──→ (M) MEDICINE

DEPARTMENT (1) ──→ (M) DOCTOR
                  ──→ (M) DOCTOR_SCHEDULE

DOCTOR (1) ──→ (M) APPOINTMENT
           ──→ (M) PRESCRIPTION
           ──→ (M) DOCTOR_SCHEDULE

DOCTOR_SCHEDULE (M) ──→ (1) DOCTOR

PATIENT (1) ──→ (M) APPOINTMENT
            ──→ (M) MEDICAL_HISTORY
            ──→ (M) LAB_REPORT
            ──→ (M) BILLING
            ──→ (M) INSURANCE

APPOINTMENT (1) ──→ (M) MEDICAL_HISTORY
             ──→ (M) LAB_REPORT
             ──→ (M) PRESCRIPTION
             ──→ (M) BILLING

PRESCRIPTION (1) ──→ (M) PRESCRIPTION_ITEMS

PRESCRIPTION_ITEMS (M) ──→ (1) MEDICINE

LAB_TEST (1) ──→ (M) LAB_REPORT

BILLING (1) ──→ (M) INSURANCE
```

### **Relationship Types**

| Relationship | Type | Cardinality | Example |
|-------------|------|------------|---------|
| DOCTOR → DEPARTMENT | Many-to-One | M:1 | Many doctors work in one department |
| APPOINTMENT → DOCTOR | Many-to-One | M:1 | Many appointments with one doctor |
| APPOINTMENT → PATIENT | Many-to-One | M:1 | Many appointments for one patient |
| PRESCRIPTION → PRESCRIPTION_ITEMS | One-to-Many | 1:M | One prescription has many medicines |
| PATIENT → INSURANCE | One-to-Many | 1:M | One patient may have multiple policies |
| DOCTOR → DOCTOR_SCHEDULE | One-to-Many | 1:M | One doctor has schedule for each day |

---

## **CONSTRAINTS SUMMARY**

### **Primary Key Constraints**
All 14 tables have AUTO_INCREMENT integer primary keys:
- Ensures uniqueness
- Enables fast lookups
- Surrogate keys (better than composite natural keys)

### **Foreign Key Constraints**

| FK | References | Action | Reason |
|----|------------|--------|--------|
| DOCTOR.DepartmentID | DEPARTMENT | RESTRICT | Prevent deleting department while doctors exist |
| APPOINTMENT.PatientID | PATIENT | RESTRICT | Prevent deleting patient with appointments |
| APPOINTMENT.DoctorID | DOCTOR | RESTRICT | Maintain referential integrity |
| PRESCRIPTION.PatientID | PATIENT | RESTRICT | Maintain prescription history |
| PRESCRIPTION.DoctorID | DOCTOR | RESTRICT | Know which doctor prescribed |
| PRESCRIPTION.AppointmentID | APPOINTMENT | RESTRICT | Link to appointment |
| PRESCRIPTION_ITEMS.PrescriptionID | PRESCRIPTION | CASCADE | Delete medicines when prescription deleted |
| PRESCRIPTION_ITEMS.MedicineID | MEDICINE | RESTRICT | Prevent deleting medicine in use |
| MEDICAL_HISTORY.PatientID | PATIENT | CASCADE | Delete history when patient deleted |
| LAB_REPORT.PatientID | PATIENT | RESTRICT | Maintain test results |
| LAB_REPORT.TestID | LAB_TEST | RESTRICT | Reference to test definition |
| BILLING.PatientID | PATIENT | RESTRICT | Maintain billing records |
| BILLING.AppointmentID | APPOINTMENT | RESTRICT | Link to appointment |
| INSURANCE.PatientID | PATIENT | RESTRICT | Maintain insurance records |
| MEDICINE.ManufacturerID | MANUFACTURER | RESTRICT | Know medicine source |

### **Unique Constraints**

| Table | Column | Purpose |
|-------|--------|---------|
| DEPARTMENT | DeptName | One department per name |
| DEPARTMENT | Email | Unique department contact |
| DOCTOR | Email | Professional identifier |
| DOCTOR | Phone | Unique contact |
| DOCTOR | LicenseNumber | Medical license uniqueness |
| PATIENT | Phone | Unique patient contact |
| PATIENT | Email | Unique patient email |
| LAB_TEST | TestName | Unique test names |
| MEDICINE | MedicineName | Unique medicine identification |
| INSURANCE | PolicyNumber | Unique policy identifier |
| APPOINTMENT | (PatientID, DoctorID, Date, Time) | Prevent double booking |
| DOCTOR_SCHEDULE | (DoctorID, DayOfWeek) | One schedule per day per doctor |

### **Check Constraints**

| Table | Column | Validation | Purpose |
|-------|--------|------------|---------|
| DEPARTMENT | Floor | 0-10 | Valid floor range |
| DEPARTMENT | MaxBeds | > 0 | Positive bed count |
| DOCTOR | YearsOfExperience | >= 0 | Non-negative years |
| DOCTOR | ConsultationFee | > 0 | Positive fee |
| DOCTOR_SCHEDULE | EndTime | > StartTime | Valid time range |
| DOCTOR_SCHEDULE | MaxAppointments | > 0 | Positive count |
| PATIENT | DateOfBirth | <= CURDATE() | Past date only |
| PATIENT | BloodGroup | IN (...) | Valid blood group |
| APPOINTMENT | AppointmentDate | >= CURDATE() | Future date |
| APPOINTMENT | EstimatedDuration | > 0 | Positive duration |
| MEDICINE | UnitPrice | > 0 | Positive price |
| MEDICINE | QuantityInStock | >= 0 | Non-negative quantity |
| MEDICINE | ExpiryDate | > CURDATE() | Future expiry |
| PRESCRIPTION | ExpiryDate | > CreatedDate | Valid expiry |
| PRESCRIPTION | RefillsUsed | <= RefillsAllowed | Valid refill count |
| PRESCRIPTION_ITEMS | Duration | > 0 | Positive days |
| PRESCRIPTION_ITEMS | Frequency | IN (...) | Valid frequency |
| BILLING | ConsultationFee, LabTestFee, etc. | >= 0 | Non-negative amounts |
| BILLING | TotalAmount | Formula checked | Calculated correctly |
| INSURANCE | CoveragePercentage | 0-100 | Valid percentage |
| INSURANCE | CoverageLimit | > 0 or NULL | Positive limit |

### **Not Null Constraints**

Applied to all mandatory fields:
- Identification: FirstName, LastName, Name fields
- Contact: Phone, Email where required
- Dates: DOB, AppointmentDate, TestDate, etc.
- Amounts: UnitPrice, TotalAmount, etc.
- Descriptions: Address, Diagnosis, etc.

---

## **INDEXES SUMMARY**

### **Index Categories**

| Category | Count | Tables |
|----------|-------|--------|
| Clustered (Primary Key) | 14 | All tables |
| Single-Column | 30+ | Frequent search columns |
| Composite (2+ columns) | 12 | Common query combinations |
| Full-Text | 3 | DOCTOR, PATIENT, MEDICAL_HISTORY |
| **Total** | **45+** | |

### **High-Performance Indexes**

Indexes optimized for most common queries:

1. **Appointment Queries** (Most critical)
   - idx_appointment_date
   - idx_appointment_doctor_date
   - idx_appointment_patient_date
   - idx_appointment_status

2. **Financial Queries**
   - idx_billing_status
   - idx_billing_status_due (overdue payments)
   - idx_billing_date

3. **Inventory Queries**
   - idx_medicine_stock
   - idx_medicine_stock_expiry
   - idx_medicine_expiry

4. **Lab Operations**
   - idx_lab_report_status
   - idx_lab_report_date
   - idx_lab_report_abnormal

5. **Search Queries**
   - idx_doctor_fullname (full-text)
   - idx_patient_fullname (full-text)
   - idx_history_diagnosis (full-text)

### **Index Statistics**

- **Clustered Index**: 14 (one per table)
- **Foreign Key Indexes**: 15 (for joins)
- **Search Indexes**: 10+ (specialization, status, etc.)
- **Date Indexes**: 8+ (appointment, test, billing dates)
- **Composite Indexes**: 12 (common multi-column queries)
- **Full-Text Indexes**: 3 (name and text searches)

---

## **VIEWS DOCUMENTATION**

### **Available Views (15 Total)**

| View Name | Purpose | Key Columns | Users |
|-----------|---------|-------------|-------|
| v_doctor_details | Doctor info with department | DoctorID, Name, Specialization, Fee | Admin, Doctors |
| v_doctor_patient_appointments | Appointments with details | AppointmentID, Date, Doctor, Patient | Doctors, Nurses |
| v_patient_medical_history | Patient history with doctor | HistoryID, Diagnosis, Outcome | Patients, Doctors |
| v_appointment_summary | All appointments overview | AppointmentID, Status, Doctor, Patient | All staff |
| v_patient_details | Complete patient info | PatientID, Age, Phone, Allergies | Nurses, Doctors |
| v_prescription_full_details | Prescription with medicines | PrescriptionID, Medicine, Dosage | Pharmacists |
| v_lab_results | Lab test results | ReportID, TestName, Result, Status | Lab, Doctors |
| v_medicine_inventory | Medicine stock status | MedicineID, Quantity, ExpiryStatus | Pharmacists |
| v_billing_summary | Bills and payments | BillingID, TotalAmount, Status, DueDate | Finance |
| v_overdue_payments | Unpaid/overdue bills | BillingID, AmountDue, DaysOverdue | Finance |
| v_doctor_performance | Doctor statistics | DoctorID, Appointments, CompletionRate, Revenue | Admin |
| v_patient_insurance_coverage | Insurance details | InsuranceID, PolicyStatus, Coverage | Finance |
| v_department_statistics | Department metrics | DepartmentID, DoctorCount, Appointments | Admin |
| v_medicine_expiry_alert | Expiring medicines | MedicineID, ExpiryStatus, DaysUntilExpiry | Pharmacists |
| v_today_appointments | Today's appointments | Time, Doctor, Patient, Room | Front Desk |

### **Benefits of Views**

1. **Security**: Hide sensitive columns (salary, personal contact details)
2. **Simplicity**: Complex joins simplified to single table
3. **Performance**: Pre-defined queries optimized
4. **Consistency**: Standardized data format across application
5. **Maintenance**: Change query logic without touching application

---

## **QUERY EXAMPLES**

### **Find All Appointments for a Doctor on a Date**

```sql
SELECT * FROM v_doctor_patient_appointments
WHERE DoctorID = 1 AND AppointmentDate = '2024-02-15'
ORDER BY AppointmentTime;
```

### **Get Patient Medical History**

```sql
SELECT * FROM v_patient_medical_history
WHERE PatientID = 5
ORDER BY VisitDate DESC;
```

### **Find Overdue Payments**

```sql
SELECT * FROM v_overdue_payments
WHERE DaysOverdue > 30
ORDER BY AmountDue DESC;
```

### **Check Medicine Inventory**

```sql
SELECT * FROM v_medicine_inventory
WHERE InventoryStatus IN ('REORDER NEEDED', 'LOW STOCK')
ORDER BY QuantityInStock ASC;
```

### **Get Lab Results for Patient**

```sql
SELECT * FROM v_lab_results
WHERE PatientID = 3
ORDER BY TestDate DESC;
```

### **Doctor Performance Report**

```sql
SELECT * FROM v_doctor_performance
ORDER BY TotalAppointments DESC
LIMIT 10;
```

### **Find Expiring Medicines**

```sql
SELECT * FROM v_medicine_expiry_alert
WHERE DaysUntilExpiry <= 30
ORDER BY ExpiryDate ASC;
```

### **Department Statistics**

```sql
SELECT * FROM v_department_statistics
ORDER BY TotalAppointments DESC;
```

---

## **DATA VALIDATION RULES**

### **Business Rules Enforced**

1. **Patient**: Must have valid DOB in past, blood group must be valid
2. **Doctor**: Must belong to a department, license number is unique
3. **Appointment**: Cannot be in past, patient-doctor-date-time combination is unique
4. **Prescription**: Expiry date must be after creation date
5. **Medicine**: Stock quantity non-negative, must not be expired
6. **Billing**: Total amount is calculated from components, payment cannot exceed total
7. **Insurance**: Policy dates must be valid (from < to), coverage 0-100%
8. **Lab Report**: Test date cannot be in future

---

## **PERFORMANCE CONSIDERATIONS**

### **Optimization Strategies**

1. **Indexing**: 45+ indexes on frequently queried columns
2. **Partitioning**: Consider by date for large tables (future enhancement)
3. **Archive**: Move old records to archive tables (e.g., > 2 years old)
4. **Statistics**: Run ANALYZE periodically to update optimizer statistics
5. **Queries**: Use views instead of complex joins

### **Expected Performance**

- **SELECT queries**: < 100ms (< 1 second for complex queries)
- **INSERT/UPDATE**: < 50ms
- **JOIN queries**: < 200ms (with proper indexes)
- **Complex aggregate queries**: 1-5 seconds

---

## **MAINTENANCE SCHEDULE**

| Task | Frequency | Command |
|------|-----------|---------|
| Update Statistics | Weekly | ANALYZE TABLE table_name; |
| Check Indexes | Monthly | SHOW INDEX FROM table_name; |
| Rebuild Indexes | Quarterly | OPTIMIZE TABLE table_name; |
| Backup Database | Daily | mysqldump command |
| Check Integrity | Monthly | CHECK TABLE table_name; |
| Review Slow Queries | Weekly | Check slow query log |

---

## **NEXT STEPS**

1. ✅ Database created with proper structure
2. ✅ All tables with appropriate constraints
3. ✅ Comprehensive indexes for performance
4. ✅ Views for role-based access
5. ➡️ Data population (Member 4)
6. ➡️ PL/SQL procedures and triggers (Member 3)
7. ➡️ Complex queries and optimization (Member 5)

---

## **REFERENCES**

- [MySQL Documentation](https://dev.mysql.com/doc/)
- [Database Normalization](https://en.wikipedia.org/wiki/Database_normalization)
- [SQL Indexing](https://use-the-index-luke.com/)
- [View Best Practices](https://dev.mysql.com/doc/refman/8.0/en/view-syntax.html)

---

**Document Version**: 1.0
**Last Updated**: 2024
**Database Version**: MySQL 8.0+