# ER Model Description
## Hospital Management System (HMS) - Entity & Relationship Documentation

**Document Version**: 1.0  
**Date**: October 2026  
**Module**: 01_ER_and_Design  
**Prepared By**: Member 1 (ER Design Lead)  

---

## **TABLE OF CONTENTS**
1. [Entity Definitions](#entity-definitions)
2. [Relationship Definitions](#relationship-definitions)
3. [Constraint Specifications](#constraint-specifications)
4. [Domain Rules](#domain-rules)

---

## **ENTITY DEFINITIONS**

### **1. MANUFACTURER**

**Purpose**: Track pharmaceutical companies that manufacture medicines

**Primary Key**: `ManufacturerID` (Surrogate Key - Integer)

| Attribute | Data Type | Constraint | Description |
|---|---|---|---|
| ManufacturerID | INT | PK, AUTO_INCREMENT | Unique identifier |
| MfgName | VARCHAR(100) | UNIQUE, NOT NULL | Company name (e.g., "Cipla Ltd") |
| Phone | VARCHAR(15) | UNIQUE, NOT NULL | Contact number (10-15 digits) |
| Address | VARCHAR(200) | NOT NULL | Street address |
| City | VARCHAR(50) | NOT NULL | City name |
| State | VARCHAR(50) | NOT NULL | State/Province |
| ContactPerson | VARCHAR(100) | NULL | Authorized contact name |
| Email | VARCHAR(100) | NULL | Company email |
| CreatedDate | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Record creation |

**Business Logic**:
- Each manufacturer supplies one or more medicines
- Unique phone and name ensure no duplicate manufacturers
- Contact information supports supplier management

**Relationships**:
- 1:M with MEDICINE (one manufacturer supplies many medicines)

---

### **2. DEPARTMENT**

**Purpose**: Hospital organizational structure and administration

**Primary Key**: `DepartmentID` (Surrogate Key - Integer)

| Attribute | Data Type | Constraint | Description |
|---|---|---|---|
| DepartmentID | INT | PK, AUTO_INCREMENT | Unique identifier |
| DeptName | VARCHAR(100) | UNIQUE, NOT NULL | Department name (e.g., "Cardiology") |
| Floor | INT | NOT NULL | Floor number (1-10) |
| Building | VARCHAR(50) | NOT NULL | Building code (e.g., "A", "B", "C") |
| HeadID | INT | FK → DOCTOR | Department head (senior doctor) |
| EstablishedYear | YEAR | NOT NULL | Foundation year |
| BudgetAllocation | DECIMAL(12,2) | NOT NULL, CHECK > 0 | Annual budget in rupees |
| Description | TEXT | NULL | Department description |
| UpdatedDate | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP ON UPDATE | Last modification |

**Business Logic**:
- Each department has a head (senior doctor)
- Budget allocation for operational costs
- Established year for historical records
- Floor and building for physical location

**Relationships**:
- 1:M with DOCTOR (one department has many doctors)
- FK to DOCTOR (HeadID) for department head

---

### **3. DOCTOR**

**Purpose**: Medical professionals providing healthcare services

**Primary Key**: `DoctorID` (Surrogate Key - Integer)

| Attribute | Data Type | Constraint | Description |
|---|---|---|---|
| DoctorID | INT | PK, AUTO_INCREMENT | Unique identifier |
| FirstName | VARCHAR(50) | NOT NULL | First/given name |
| LastName | VARCHAR(50) | NOT NULL | Last/family name |
| DOB | DATE | NOT NULL, CHECK valid age | Date of birth |
| Gender | ENUM('M','F','Other') | NOT NULL | Biological gender |
| Qualification | VARCHAR(100) | NOT NULL | Medical degree (e.g., "MBBS", "MD") |
| Specialization | VARCHAR(100) | NOT NULL | Medical specialty (e.g., "Cardiology") |
| RegistrationNumber | VARCHAR(50) | UNIQUE, NOT NULL | Medical council registration |
| DepartmentID | INT | FK → DEPARTMENT, NOT NULL | Current department |
| Phone | VARCHAR(15) | UNIQUE, NOT NULL | Contact number |
| Email | VARCHAR(100) | UNIQUE, NOT NULL | Email address |
| JoiningDate | DATE | NOT NULL | Employment start date |
| YearsOfExperience | INT | NOT NULL, CHECK >= 0 | Years in medical field |
| ConsultationFeePerHour | DECIMAL(8,2) | NOT NULL, CHECK > 0 | Hourly consultation fee |
| IsActive | BOOLEAN | DEFAULT TRUE | Current employment status |
| CreatedDate | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Record creation |

**Business Logic**:
- Must have valid registration number (verified by medical council)
- Specialization determines service offerings
- Consultation fee for billing purposes
- Active status for managing roster
- Years of experience for credibility

**Relationships**:
- M:1 with DEPARTMENT (many doctors in one department)
- 1:M with APPOINTMENT (one doctor has many appointments)
- 1:M with PRESCRIPTION (one doctor issues many prescriptions)
- 1:M with DOCTOR_SCHEDULE (one doctor has multiple schedule entries)
- 1:1 with DEPARTMENT as HeadID (department head relationship)

---

### **4. DOCTOR_SCHEDULE**

**Purpose**: Doctor availability on different days (separate to maintain 1NF)

**Primary Key**: `ScheduleID` (Surrogate Key - Integer)

| Attribute | Data Type | Constraint | Description |
|---|---|---|---|
| ScheduleID | INT | PK, AUTO_INCREMENT | Unique identifier |
| DoctorID | INT | FK → DOCTOR, NOT NULL | Which doctor |
| DayOfWeek | ENUM(...) | NOT NULL | MON, TUE, WED, THU, FRI, SAT, SUN |
| StartTime | TIME | NOT NULL, CHECK >= 09:00 | Schedule start |
| EndTime | TIME | NOT NULL, CHECK <= 18:00 | Schedule end |
| IsAvailable | BOOLEAN | DEFAULT TRUE | Currently available |
| CreatedDate | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Record creation |

**Business Logic**:
- Separated from DOCTOR to avoid multivalued attributes
- Enables 1NF compliance
- Supports flexible scheduling (different hours on different days)
- IsAvailable allows temporary schedule changes

**Relationships**:
- M:1 with DOCTOR (many schedule entries for one doctor)

---

### **5. PATIENT**

**Purpose**: Individuals receiving healthcare services

**Primary Key**: `PatientID` (Surrogate Key - Integer)

| Attribute | Data Type | Constraint | Description |
|---|---|---|---|
| PatientID | INT | PK, AUTO_INCREMENT | Unique identifier |
| FirstName | VARCHAR(50) | NOT NULL | First/given name |
| LastName | VARCHAR(50) | NOT NULL | Last/family name |
| DOB | DATE | NOT NULL | Date of birth |
| Gender | ENUM('M','F','Other') | NOT NULL | Biological gender |
| BloodGroup | ENUM('A+','A-','B+','B-','AB+','AB-','O+','O-') | NOT NULL | Blood type |
| Height | DECIMAL(5,2) | NOT NULL, CHECK > 0 | Height in cm |
| Weight | DECIMAL(5,2) | NOT NULL, CHECK > 0 | Weight in kg |
| Address | VARCHAR(200) | NOT NULL | Residential address |
| City | VARCHAR(50) | NOT NULL | City name |
| State | VARCHAR(50) | NOT NULL | State/Province |
| Phone | VARCHAR(15) | UNIQUE, NOT NULL | Primary contact |
| Email | VARCHAR(100) | NULL | Email address |
| EmergencyContact | VARCHAR(100) | NOT NULL | Emergency contact name |
| EmergencyContactPhone | VARCHAR(15) | NOT NULL | Emergency phone number |
| PatientType | ENUM('OPD','IPD','Emergency') | NOT NULL | Type of patient |
| RegistrationDate | DATE | NOT NULL | First registration date |
| CreatedDate | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Record creation |

**Business Logic**:
- Blood group critical for medical decisions
- Height and weight for BMI and dosage calculations
- Emergency contact mandatory for safety
- PatientType determines priority and care level
- Phone must be unique for contact verification

**Relationships**:
- 1:M with APPOINTMENT (one patient has many appointments)
- 1:M with LAB_REPORT (one patient has many test reports)
- 1:M with MEDICAL_HISTORY (one patient has treatment history)
- 1:M with BILLING (one patient has multiple bills)
- 1:1 with INSURANCE (optional: one patient has at most one active insurance)

---

### **6. APPOINTMENT**

**Purpose**: Clinical encounters between doctors and patients

**Primary Key**: `AppointmentID` (Surrogate Key - Integer)

| Attribute | Data Type | Constraint | Description |
|---|---|---|---|
| AppointmentID | INT | PK, AUTO_INCREMENT | Unique identifier |
| PatientID | INT | FK → PATIENT, NOT NULL | Which patient |
| DoctorID | INT | FK → DOCTOR, NOT NULL | Which doctor |
| AppointmentDate | DATE | NOT NULL, CHECK >= TODAY | Appointment day |
| AppointmentTime | TIME | NOT NULL | Appointment time (09:00-18:00) |
| Reason | VARCHAR(200) | NOT NULL | Chief complaint |
| Status | ENUM('Scheduled','Completed','Cancelled','No-Show') | NOT NULL | Current status |
| ConsultationFee | DECIMAL(8,2) | NOT NULL, CHECK > 0 | Doctor's fee for this appointment |
| Notes | TEXT | NULL | Doctor's clinical notes |
| CancelledDate | DATE | NULL | When cancelled (if applicable) |
| CancelReason | VARCHAR(200) | NULL | Why cancelled |
| CreatedDate | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Record creation |

**Business Logic**:
- Date must be in future (future constraint)
- Time must be within operating hours (09:00-18:00)
- Status tracks appointment lifecycle
- Cancelled/No-Show for scheduling analytics
- Notes for clinical decision-making

**Relationships**:
- M:1 with PATIENT (many appointments for one patient)
- M:1 with DOCTOR (many appointments with one doctor)
- 1:M with PRESCRIPTION (one appointment may have prescription)
- 1:M with LAB_REPORT (one appointment may have lab tests)
- 1:1 with BILLING (one appointment generates one bill)

---

### **7. MEDICAL_HISTORY**

**Purpose**: Patient's diagnosis and treatment records

**Primary Key**: `HistoryID` (Surrogate Key - Integer)

| Attribute | Data Type | Constraint | Description |
|---|---|---|---|
| HistoryID | INT | PK, AUTO_INCREMENT | Unique identifier |
| PatientID | INT | FK → PATIENT, NOT NULL | Which patient |
| Diagnosis | VARCHAR(200) | NOT NULL | Medical diagnosis (e.g., "Hypertension") |
| Symptoms | TEXT | NOT NULL | Presenting symptoms |
| TreatmentPlan | TEXT | NOT NULL | Prescribed treatment approach |
| Severity | ENUM('Mild','Moderate','Severe','Critical') | NOT NULL | Severity level |
| OutcomeStatus | ENUM('Recovering','Stable','Worsening','Resolved') | NOT NULL | Treatment outcome |
| CreatedDate | TIMESTAMP | NOT NULL | When recorded |
| UpdatedDate | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP ON UPDATE | Last update |

**Business Logic**:
- Permanent record of patient's medical conditions
- Severity level for risk assessment
- Outcome status tracks treatment effectiveness
- Multiple records per patient (one per condition/episode)

**Relationships**:
- M:1 with PATIENT (many history records for one patient)

---

### **8. MEDICINE**

**Purpose**: Pharmaceutical inventory management

**Primary Key**: `MedicineID` (Surrogate Key - Integer)

| Attribute | Data Type | Constraint | Description |
|---|---|---|---|
| MedicineID | INT | PK, AUTO_INCREMENT | Unique identifier |
| MedicineName | VARCHAR(100) | UNIQUE, NOT NULL | Brand name (e.g., "Aspirin") |
| GenericName | VARCHAR(100) | NOT NULL | Generic name (e.g., "Acetylsalicylic Acid") |
| Type | VARCHAR(100) | NOT NULL | Category (e.g., "Analgesic", "Antibiotic") |
| ManufacturerID | INT | FK → MANUFACTURER, NOT NULL | Manufacturing company |
| UnitPrice | DECIMAL(8,2) | NOT NULL, CHECK > 0 | Price per unit (in rupees) |
| QuantityInStock | INT | NOT NULL, CHECK >= 0 | Current stock level |
| ReorderLevel | INT | NOT NULL, CHECK >= 0 | Minimum stock threshold |
| ManufactureDate | DATE | NOT NULL | Production date |
| ExpiryDate | DATE | NOT NULL, CHECK > ManufactureDate | Expiration date |
| SideEffects | TEXT | NULL | Known side effects |
| Dosage | VARCHAR(100) | NOT NULL | Standard dosage (e.g., "500mg") |
| IsActive | BOOLEAN | DEFAULT TRUE | Still in use |
| CreatedDate | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Record creation |

**Business Logic**:
- Unique medicine name prevents duplicates
- Stock levels trigger reorder alerts
- Expiry date for inventory management
- Side effects documented for patient safety
- Generic name enables drug substitution

**Relationships**:
- M:1 with MANUFACTURER (many medicines from one manufacturer)
- 1:M with PRESCRIPTION_ITEMS (one medicine in many prescriptions)

---

### **9. PRESCRIPTION**

**Purpose**: Doctor's medication orders for patients

**Primary Key**: `PrescriptionID` (Surrogate Key - Integer)

| Attribute | Data Type | Constraint | Description |
|---|---|---|---|
| PrescriptionID | INT | PK, AUTO_INCREMENT | Unique identifier |
| AppointmentID | INT | FK → APPOINTMENT, NOT NULL | Related appointment |
| DoctorID | INT | FK → DOCTOR, NOT NULL | Prescribing doctor |
| PrescriptionDate | DATE | NOT NULL | When prescribed |
| Notes | TEXT | NULL | Special instructions |
| Status | ENUM('Active','Expired','Completed','Cancelled') | NOT NULL | Current status |
| CreatedDate | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Record creation |

**Business Logic**:
- Links to specific appointment
- Doctor reference for verification
- Status tracks prescription lifecycle
- Notes for patient-specific instructions

**Relationships**:
- M:1 with APPOINTMENT (many prescriptions from one appointment)
- M:1 with DOCTOR (many prescriptions from one doctor)
- 1:M with PRESCRIPTION_ITEMS (one prescription has many medicines)

---

### **10. PRESCRIPTION_ITEMS** (Weak Entity)

**Purpose**: Individual medicines within a prescription

**Primary Key**: `PrescriptionItemID` (Surrogate Key - Integer)  
**Weak Entity Dependencies**: Exists only with PRESCRIPTION

| Attribute | Data Type | Constraint | Description |
|---|---|---|---|
| PrescriptionItemID | INT | PK, AUTO_INCREMENT | Unique identifier |
| PrescriptionID | INT | FK → PRESCRIPTION, NOT NULL | Which prescription |
| MedicineID | INT | FK → MEDICINE, NOT NULL | Which medicine |
| Dosage | VARCHAR(100) | NOT NULL | Dosage (e.g., "500mg") |
| Frequency | VARCHAR(100) | NOT NULL | Frequency (e.g., "Twice daily") |
| Duration | VARCHAR(100) | NOT NULL | Duration (e.g., "10 days") |
| Quantity | INT | NOT NULL, CHECK > 0 | Total quantity prescribed |
| Instructions | TEXT | NULL | Special instructions |
| CreatedDate | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Record creation |

**Business Logic**:
- Weak entity (depends on PRESCRIPTION for existence)
- Multiple medicines per prescription
- Stores prescription-specific dosage (different from medicine's standard)
- Frequency and duration specific to patient's case

**Relationships**:
- M:1 with PRESCRIPTION (many items in one prescription)
- M:1 with MEDICINE (many prescriptions use one medicine)

---

### **11. LAB_TEST**

**Purpose**: Available diagnostic tests in the hospital

**Primary Key**: `TestID` (Surrogate Key - Integer)

| Attribute | Data Type | Constraint | Description |
|---|---|---|---|
| TestID | INT | PK, AUTO_INCREMENT | Unique identifier |
| TestName | VARCHAR(100) | UNIQUE, NOT NULL | Test name (e.g., "Blood Glucose") |
| Description | TEXT | NOT NULL | What the test measures |
| NormalRangeMin | DECIMAL(10,2) | NOT NULL | Minimum normal value |
| NormalRangeMax | DECIMAL(10,2) | NOT NULL | Maximum normal value |
| Unit | VARCHAR(50) | NOT NULL | Measurement unit (e.g., "mg/dL") |
| CostPrice | DECIMAL(8,2) | NOT NULL, CHECK > 0 | Test cost in rupees |
| CreatedDate | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Record creation |

**Business Logic**:
- Reference data (relatively static)
- Normal range determines abnormal results
- Cost for billing purposes
- Unit identifies measurement type

**Relationships**:
- 1:M with LAB_REPORT (one test type has many reports)

---

### **12. LAB_REPORT**

**Purpose**: Laboratory test results for patients

**Primary Key**: `ReportID` (Surrogate Key - Integer)

| Attribute | Data Type | Constraint | Description |
|---|---|---|---|
| ReportID | INT | PK, AUTO_INCREMENT | Unique identifier |
| PatientID | INT | FK → PATIENT, NOT NULL | Which patient |
| TestID | INT | FK → LAB_TEST, NOT NULL | Which test |
| AppointmentID | INT | FK → APPOINTMENT, NULL | Related appointment (optional) |
| TestDate | DATE | NOT NULL | When test performed |
| ResultValue | DECIMAL(10,2) | NOT NULL | Measured value |
| Status | ENUM('Pending','Completed','Reviewed','Abnormal') | NOT NULL | Report status |
| Interpretation | TEXT | NULL | Doctor's interpretation |
| TechnicianName | VARCHAR(100) | NOT NULL | Lab technician |
| ApprovedBy | INT | FK → DOCTOR | Approving doctor |
| CreatedDate | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Record creation |

**Business Logic**:
- Result value compared against normal range
- Status tracks report lifecycle
- Approved by doctor for validity
- Interpretation provides clinical context
- Optional appointment link (can do tests outside appointments)

**Relationships**:
- M:1 with PATIENT (many reports for one patient)
- M:1 with LAB_TEST (many results for one test)
- M:1 with APPOINTMENT (optional: reports related to appointments)
- M:1 with DOCTOR (approved by doctor)

---

### **13. INSURANCE**

**Purpose**: Patient insurance coverage information

**Primary Key**: `InsuranceID` (Surrogate Key - Integer)

| Attribute | Data Type | Constraint | Description |
|---|---|---|---|
| InsuranceID | INT | PK, AUTO_INCREMENT | Unique identifier |
| PatientID | INT | FK → PATIENT, UNIQUE, NOT NULL | Which patient (one per patient) |
| InsuranceProvider | VARCHAR(100) | NOT NULL | Insurance company name |
| PolicyNumber | VARCHAR(100) | UNIQUE, NOT NULL | Policy identifier |
| CoveragePercentage | INT | NOT NULL, CHECK BETWEEN 0 AND 100 | Percentage covered |
| ValidFrom | DATE | NOT NULL | Policy start date |
| ValidTo | DATE | NOT NULL, CHECK > ValidFrom | Policy end date |
| IsActive | BOOLEAN | DEFAULT TRUE | Current validity |
| CreatedDate | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Record creation |

**Business Logic**:
- One insurance per patient (optional)
- UNIQUE constraint on PatientID ensures no duplicates
- Coverage percentage determines hospital's pay vs patient's pay
- Active status for filtering valid policies
- Policy numbers unique for identification

**Relationships**:
- 1:1 with PATIENT (optional: not all patients insured)
- 1:M with BILLING (one insurance covers multiple bills)

---

### **14. BILLING**

**Purpose**: Financial transaction and bill management

**Primary Key**: `BillingID` (Surrogate Key - Integer)

| Attribute | Data Type | Constraint | Description |
|---|---|---|---|
| BillingID | INT | PK, AUTO_INCREMENT | Unique identifier |
| BillingNumber | VARCHAR(50) | UNIQUE, NOT NULL | Invoice number |
| PatientID | INT | FK → PATIENT, NOT NULL | Which patient |
| AppointmentID | INT | FK → APPOINTMENT, UNIQUE, NOT NULL | Related appointment (1:1) |
| InsuranceID | INT | FK → INSURANCE, NULL | Insurance (if applicable) |
| ConsultationCharges | DECIMAL(10,2) | NOT NULL, CHECK >= 0 | Doctor's fee |
| LabCharges | DECIMAL(10,2) | NOT NULL, CHECK >= 0 | Lab tests cost |
| MedicineCharges | DECIMAL(10,2) | NOT NULL, CHECK >= 0 | Pharmacy cost |
| OtherCharges | DECIMAL(10,2) | NOT NULL, CHECK >= 0 | Miscellaneous charges |
| TotalCharges | DECIMAL(10,2) | NOT NULL, CHECK > 0 | Sum of all charges |
| InsuranceCoverage | DECIMAL(10,2) | NOT NULL, CHECK >= 0 | Insurance pays this |
| PatientPayable | DECIMAL(10,2) | NOT NULL, CHECK >= 0 | Patient pays this |
| AmountPaid | DECIMAL(10,2) | NOT NULL, CHECK >= 0 | Amount already paid |
| PaymentStatus | ENUM('Pending','Partial','Paid','Overdue','Cancelled') | NOT NULL | Payment status |
| PaymentMethod | ENUM('Cash','Card','Cheque','Insurance','Online') | NULL | Payment method |
| PaymentDate | DATE | NULL | When paid |
| BillingDate | DATE | NOT NULL | Invoice date |
| DueDate | DATE | NOT NULL | Payment due date |
| CreatedDate | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Record creation |

**Business Logic**:
- Comprehensive charge tracking (consultation, lab, medicine, other)
- Insurance coverage automatically calculated
- Patient payable = Total - Insurance coverage
- Unique appointment ID ensures one bill per appointment
- Multiple payment methods supported
- Overdue tracking for follow-up

**Relationships**:
- M:1 with PATIENT (many bills for one patient)
- 1:1 with APPOINTMENT (each appointment has one bill)
- M:1 with INSURANCE (bills link to insurance if available)

---

## **RELATIONSHIP DEFINITIONS**

### **Relationship 1: DEPARTMENT → DOCTOR**
- **Type**: One-to-Many (1:M)
- **Cardinality**: 1 department has M doctors
- **Participation**: Partial on DEPARTMENT, Total on DOCTOR
- **Foreign Key**: DepartmentID in DOCTOR
- **Business Logic**: Each doctor must work in a department; not all departments filled immediately

---

### **Relationship 2: DOCTOR → APPOINTMENT**
- **Type**: One-to-Many (1:M)
- **Cardinality**: 1 doctor has M appointments
- **Participation**: Total both sides
- **Foreign Key**: DoctorID in APPOINTMENT
- **Business Logic**: Doctor must have appointments; appointment must have a doctor

---

### **Relationship 3: PATIENT → APPOINTMENT**
- **Type**: One-to-Many (1:M)
- **Cardinality**: 1 patient has M appointments
- **Participation**: Total both sides
- **Foreign Key**: PatientID in APPOINTMENT
- **Business Logic**: Patient must have appointments; appointment must have a patient

---

### **Relationship 4: DOCTOR → PRESCRIPTION**
- **Type**: One-to-Many (1:M)
- **Cardinality**: 1 doctor issues M prescriptions
- **Participation**: Total both sides
- **Foreign Key**: DoctorID in PRESCRIPTION
- **Business Logic**: Doctor prescribes medications; prescription must be from a doctor

---

### **Relationship 5: APPOINTMENT → PRESCRIPTION**
- **Type**: One-to-Many (1:M)
- **Cardinality**: 1 appointment may have M prescriptions (typically 1)
- **Participation**: Total on PRESCRIPTION, Partial on APPOINTMENT
- **Foreign Key**: AppointmentID in PRESCRIPTION
- **Business Logic**: Some appointments don't result in prescriptions; prescriptions linked to appointment

---

### **Relationship 6: PATIENT → LAB_REPORT**
- **Type**: One-to-Many (1:M)
- **Cardinality**: 1 patient has M lab reports
- **Participation**: Total both sides
- **Foreign Key**: PatientID in LAB_REPORT
- **Business Logic**: Patient must have lab reports; report must belong to a patient

---

### **Relationship 7: LAB_TEST → LAB_REPORT**
- **Type**: One-to-Many (1:M)
- **Cardinality**: 1 test type produces M reports
- **Participation**: Total on LAB_REPORT, Total on LAB_TEST
- **Foreign Key**: TestID in LAB_REPORT
- **Business Logic**: Test must have reports; report must reference a test type

---

### **Relationship 8: APPOINTMENT → LAB_REPORT**
- **Type**: One-to-Many (1:M)
- **Cardinality**: 1 appointment may have M lab reports
- **Participation**: Partial on APPOINTMENT, Partial on LAB_REPORT
- **Foreign Key**: AppointmentID in LAB_REPORT
- **Business Logic**: Some appointments don't have lab tests; some tests not from appointments

---

### **Relationship 9: PATIENT → MEDICAL_HISTORY**
- **Type**: One-to-Many (1:M)
- **Cardinality**: 1 patient has M history records
- **Participation**: Total both sides
- **Foreign Key**: PatientID in MEDICAL_HISTORY
- **Business Logic**: Patient must have medical records; each history entry for specific patient

---

### **Relationship 10: PATIENT → BILLING**
- **Type**: One-to-Many (1:M)
- **Cardinality**: 1 patient has M bills
- **Participation**: Total both sides
- **Foreign Key**: PatientID in BILLING
- **Business Logic**: Patient must have bills; each bill for specific patient

---

### **Relationship 11: APPOINTMENT → BILLING**
- **Type**: One-to-One (1:1)
- **Cardinality**: 1 appointment generates exactly 1 bill
- **Participation**: Total both sides
- **Foreign Key**: AppointmentID in BILLING (UNIQUE constraint)
- **Business Logic**: Each appointment has single bill; each bill from single appointment

---

### **Relationship 12: INSURANCE → BILLING**
- **Type**: One-to-Many (1:M)
- **Cardinality**: 1 insurance covers M bills
- **Participation**: Partial on INSURANCE, Partial on BILLING
- **Foreign Key**: InsuranceID in BILLING
- **Business Logic**: Not all bills have insurance; some insurance not used for bills

---

### **Relationship 13: DOCTOR → DOCTOR_SCHEDULE**
- **Type**: One-to-Many (1:M)
- **Cardinality**: 1 doctor has M schedule entries (typically 5-7 days)
- **Participation**: Total on DOCTOR_SCHEDULE, Total on DOCTOR
- **Foreign Key**: DoctorID in DOCTOR_SCHEDULE
- **Business Logic**: Doctor must have schedule; schedule belongs to specific doctor

---

### **Relationship 14: PATIENT → INSURANCE**
- **Type**: One-to-One (1:1)
- **Cardinality**: 1 patient has at most 1 insurance policy
- **Participation**: Partial both sides
- **Foreign Key**: PatientID in INSURANCE (UNIQUE constraint)
- **Business Logic**: Not all patients have insurance; no patient with multiple active policies

---

### **Relationship 15: PRESCRIPTION → PRESCRIPTION_ITEMS**
- **Type**: One-to-Many (1:M)
- **Cardinality**: 1 prescription has M items
- **Participation**: Total both sides
- **Foreign Key**: PrescriptionID in PRESCRIPTION_ITEMS
- **Business Logic**: Prescription must have items; items belong to specific prescription

---

### **Relationship 16: MEDICINE → PRESCRIPTION_ITEMS**
- **Type**: One-to-Many (1:M)
- **Cardinality**: 1 medicine appears in M prescriptions
- **Participation**: Total on PRESCRIPTION_ITEMS, Total on MEDICINE
- **Foreign Key**: MedicineID in PRESCRIPTION_ITEMS
- **Business Logic**: Medicine prescribed multiple times; items reference medicines

---

### **Relationship 17: MANUFACTURER → MEDICINE**
- **Type**: One-to-Many (1:M)
- **Cardinality**: 1 manufacturer supplies M medicines
- **Participation**: Total on MEDICINE, Total on MANUFACTURER
- **Foreign Key**: ManufacturerID in MEDICINE
- **Business Logic**: Manufacturer makes multiple medicines; each medicine from one manufacturer

---

## **CONSTRAINT SPECIFICATIONS**

### **Primary Key Constraints**
All 14 entities have surrogate key primary keys (ID columns):
- Auto-increment for easy insertion
- Efficiency for joins and indexing
- Stability (doesn't change if natural attributes updated)

### **Foreign Key Constraints**
17 foreign key relationships with referential integrity:
- CASCADE delete for non-critical references
- RESTRICT delete for critical references
- CASCADE update for key changes

### **UNIQUE Constraints**
Applied to:
- MANUFACTURER: MfgName, Phone
- DOCTOR: RegistrationNumber, Phone, Email
- PATIENT: Phone
- MEDICINE: MedicineName
- INSURANCE: PolicyNumber, PatientID (1:1)
- BILLING: BillingNumber, AppointmentID (1:1)

### **CHECK Constraints**
Domain validation:
- Age: DOB produces valid age (0-150 years)
- Dates: StartDate < EndDate, ExpiryDate > ManufactureDate
- Amounts: Prices > 0, Coverage% between 0-100
- Quantities: Stock >= 0
- Times: 09:00-18:00 operating hours

### **NOT NULL Constraints**
Critical attributes marked NOT NULL:
- All keys (PK, FK)
- Names and identifiers
- Dates for transactions
- Status fields
- Essential references

### **DEFAULT Values**
- CreatedDate: CURRENT_TIMESTAMP
- IsActive: TRUE
- IsAvailable: TRUE (DOCTOR_SCHEDULE)
- Status: 'Scheduled' (APPOINTMENT), 'Active' (PRESCRIPTION)

---

## **DOMAIN RULES**

### **Age Validation**
- Patient: Must be age 0-120 years
- Doctor: Must be age 21-80 years (valid medical age)

### **Date Validations**
- Appointment: Must be future date
- Appointment Time: Must be 09:00-18:00
- ExpiryDate > ManufactureDate (medicines)
- ValidTo > ValidFrom (insurance)
- DueDate >= BillingDate

### **Phone Format**
- Length: 10-15 digits
- Must contain only digits and optional '+' prefix
- Unique per person

### **Email Format**
- Must contain '@' symbol
- Must have domain (e.g., @gmail.com)
- Unique per person

### **Blood Group**
- Must be one of: A+, A-, B+, B-, AB+, AB-, O+, O-
- Cannot be NULL for patient

### **Coverage Percentage**
- Range: 0-100
- Integer values only
- Represents percentage covered by insurance

### **Amount Calculations**
- TotalCharges = ConsultationCharges + LabCharges + MedicineCharges + OtherCharges
- InsuranceCoverage = TotalCharges × (CoveragePercentage / 100)
- PatientPayable = TotalCharges - InsuranceCoverage
- AmountDue = PatientPayable - AmountPaid

---

## **SUMMARY**

| Aspect | Count | Details |
|---|---|---|
| **Entities** | 14 | Complete domain coverage |
| **Attributes** | 100+ | Comprehensive data capture |
| **Relationships** | 17 | Including 2 one-to-one |
| **Primary Keys** | 14 | All surrogate keys |
| **Foreign Keys** | 17 | Referential integrity |
| **Unique Constraints** | 13 | Duplicate prevention |
| **Check Constraints** | 20+ | Domain validation |
| **Weak Entities** | 1 | PRESCRIPTION_ITEMS |

**This ER model comprehensively represents hospital management operations while maintaining data integrity and supporting efficient queries.**

---

**Document Version**: 1.0  
**Last Updated**: October 2026  
**Status**: Ready for Implementation  
**Next**: Generate SQL schema from this design

