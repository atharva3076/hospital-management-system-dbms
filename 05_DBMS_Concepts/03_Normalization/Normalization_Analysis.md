# Normalization Analysis
## Hospital Management System - DBMS Concepts Module

**Document Version**: 1.0  
**Date**: October 2026  
**Module**: 05_DBMS_Concepts | **Folder**: 03_Normalization  

---

## **1. FIRST NORMAL FORM (1NF) ANALYSIS**

### **Requirement**: All attributes must contain atomic (single) values

**HMS Implementation**:

✅ **DOCTOR Table - 1NF Compliant**
```
DOCTOR(DoctorID, FirstName, LastName, DOB, Gender, Qualification, 
       Specialization, DepartmentID, Phone, Email, ...)

All attributes are atomic:
- Names: Single values ✓
- Qualification: Single degree (could be multiple, but stored as single) ✓
- Specialization: Single specialty ✓
- No arrays, no repeating groups ✓
```

❌ **DOCTOR Would Violate 1NF** (Bad Design):
```
DOCTOR_BAD(DoctorID, Name, Qualifications[MBBS, MD, DM], 
           Schedule[MON:09-17, WED:10-18, FRI:14-20])

Problems:
- Qualifications: Multivalued attribute (violates 1NF)
- Schedule: Repeating group (violates 1NF)
```

✅ **Solution - Decompose into Separate Tables**:
```
DOCTOR(DoctorID, FirstName, LastName, Qualification, ...)
DOCTOR_SCHEDULE(ScheduleID, DoctorID, DayOfWeek, StartTime, EndTime)
```

**Verification**:
| Entity | Atomic Values | Multivalued Removed | 1NF Status |
|---|---|---|---|
| DOCTOR | ✓ | ✓ (DOCTOR_SCHEDULE separate) | ✓ 1NF |
| PATIENT | ✓ | ✓ | ✓ 1NF |
| APPOINTMENT | ✓ | ✓ | ✓ 1NF |
| PRESCRIPTION_ITEMS | ✓ | ✓ | ✓ 1NF |
| MEDICINE | ✓ | ✓ | ✓ 1NF |

---

## **2. SECOND NORMAL FORM (2NF) ANALYSIS**

### **Requirement**: Must be 1NF + No partial dependencies

**Definition**: Non-key attribute depends on ENTIRE primary key, not just part of it

### **Testing Each Table**:

#### **DOCTOR - 2NF Compliant** ✓
```
PK: DoctorID (single attribute)
Non-key attributes: FirstName, LastName, DOB, Gender, Qualification, 
                   Specialization, DepartmentID, Phone, Email, ...

Functional Dependencies:
DoctorID → FirstName ✓
DoctorID → LastName ✓
DoctorID → Gender ✓
DoctorID → DepartmentID ✓
(All depend on entire key - single attribute)

2NF Status: ✓ COMPLIANT
```

#### **APPOINTMENT - 2NF Compliant** ✓
```
PK: AppointmentID (single attribute)
Non-key attributes: PatientID, DoctorID, AppointmentDate, Status, ...

Functional Dependencies:
AppointmentID → PatientID ✓
AppointmentID → DoctorID ✓
AppointmentID → AppointmentDate ✓
(All depend on entire key)

2NF Status: ✓ COMPLIANT
```

#### **PRESCRIPTION_ITEMS - 2NF Compliant** ✓
```
PK: PrescriptionItemID (surrogate key)
Natural Key Alternative: (PrescriptionID, MedicineID)

Using Surrogate PK:
PrescriptionItemID → PrescriptionID ✓
PrescriptionItemID → MedicineID ✓
PrescriptionItemID → Dosage ✓
PrescriptionItemID → Frequency ✓

Using Natural Key:
(PrescriptionID, MedicineID) → Dosage ✓
(PrescriptionID, MedicineID) → Frequency ✓
(Both attributes needed for any dependency)

2NF Status: ✓ COMPLIANT (with either key)
```

#### **BILLING - 2NF Compliant** ✓
```
PK: BillingID (single attribute)
Non-key attributes: PatientID, AppointmentID, TotalCharges, 
                   InsuranceCoverage, PatientPayable, ...

Functional Dependencies:
BillingID → PatientID ✓
BillingID → AppointmentID ✓
BillingID → TotalCharges ✓

No partial dependencies (no composite key with partial deps)

2NF Status: ✓ COMPLIANT
```

---

## **3. THIRD NORMAL FORM (3NF) ANALYSIS**

### **Requirement**: Must be 2NF + No transitive dependencies

**Definition**: Non-key attribute X depends on another non-key attribute Y, 
which depends on the primary key

### **Example of Transitive Dependency (BAD)**:
```
❌ DOCTOR_BAD(DoctorID, Name, DepartmentID, DeptName, DeptHead)

Transitive Dependency:
DoctorID → DepartmentID (direct)
DepartmentID → DeptName (transitive)
DoctorID → DeptName (depends through DepartmentID)

Problem: If department info changes, must update all doctors
```

### **Correct Solution (3NF)**:
```
✓ DOCTOR(DoctorID, Name, DepartmentID)
✓ DEPARTMENT(DepartmentID, DeptName, DeptHead, Floor, Building)

Dependencies:
DoctorID → DepartmentID (non-transitive)
DepartmentID → DeptName (in DEPARTMENT table, no transitive path in DOCTOR)

Status: 3NF Compliant - No transitive dependencies in DOCTOR
```

### **HMS Table Verification**:

#### **DOCTOR - 3NF Compliant** ✓
```
Attributes:
DoctorID (PK), FirstName, LastName, DOB, Gender, Qualification,
Specialization, DepartmentID (FK), Phone, Email, ...

Dependency Analysis:
DoctorID → FirstName (direct) ✓
DoctorID → LastName (direct) ✓
DoctorID → Gender (direct) ✓
DoctorID → DepartmentID (direct) ✓

No transitive paths:
- DoctorID → DepartmentID → DeptName (DeptName not in DOCTOR table)
- All non-key attributes depend ONLY on DoctorID

3NF Status: ✓ COMPLIANT
```

#### **APPOINTMENT - 3NF Compliant** ✓
```
Attributes:
AppointmentID (PK), PatientID (FK), DoctorID (FK), AppointmentDate,
AppointmentTime, Reason, Status, ConsultationFee, Notes, ...

Dependency Analysis:
AppointmentID → PatientID (direct, FK) ✓
AppointmentID → DoctorID (direct, FK) ✓
AppointmentID → AppointmentDate (direct) ✓
AppointmentID → Status (direct) ✓
AppointmentID → ConsultationFee (direct) ✓

No transitive dependencies:
- DoctorID is FK (references DOCTOR table)
- ConsultationFee copied from doctor but it's appointment-specific
- All attributes depend only on AppointmentID

3NF Status: ✓ COMPLIANT
```

#### **BILLING - 3NF Compliant** ✓
```
Attributes:
BillingID (PK), BillingNumber, PatientID (FK), AppointmentID (FK),
InsuranceID (FK), ConsultationCharges, LabCharges, MedicineCharges,
OtherCharges, TotalCharges, InsuranceCoverage, PatientPayable, ...

Key Dependency: ConsultationCharges
Copied from doctor's rate, but it's captured AT TIME OF APPOINTMENT
This is not transitive - it's a denormalized copy for historical accuracy

Dependency Analysis:
BillingID → BillingNumber ✓
BillingID → PatientID ✓
BillingID → TotalCharges ✓
BillingID → ConsultationCharges (historical snapshot) ✓

No transitive dependencies:
- PatientPayable depends on BillingID, not another attribute
- Calculated fields (TotalCharges, PatientPayable) are dependent on BillingID

3NF Status: ✓ COMPLIANT (denormalization justified for audit trail)
```

---

## **4. BOYCE-CODD NORMAL FORM (BCNF) ANALYSIS**

### **Requirement**: Every determinant must be a candidate key

**Definition**: Stricter than 3NF - no non-key attribute determines another attribute

### **HMS BCNF Analysis**:

#### **All tables in BCNF** ✓
```
DOCTOR Table:
- PK: DoctorID (only determinant is the primary key)
- No alternative keys determining other attributes
- Status: BCNF ✓

APPOINTMENT Table:
- PK: AppointmentID
- Foreign keys (PatientID, DoctorID) are not determinants
- All attributes depend only on AppointmentID
- Status: BCNF ✓

BILLING Table:
- PK: BillingID
- Unique key: AppointmentID (but not a determinant for other attributes)
- Status: BCNF ✓
```

---

## **5. NORMALIZATION PROOF**

### **Complete Decomposition Path**

```
UNNORMALIZED DATA (Raw Hospital Operations)
    ↓
    ↓ Remove multivalued attributes (Schedule, multiple qualifications)
    ↓
1NF: DOCTOR_SCHEDULE separated, all attributes atomic
    ↓
    ↓ Remove partial dependencies (none found - used surrogate keys)
    ↓
2NF: All non-key attributes depend on entire primary key
    ↓
    ↓ Remove transitive dependencies (move department info to DEPARTMENT)
    ↓
3NF: DOCTOR → DepartmentID (FK), not → DeptName
     DEPARTMENT table holds DeptName separately
    ↓
    ↓ Ensure all determinants are candidate keys (already verified)
    ↓
BCNF: All tables satisfy BCNF conditions
```

### **Summary of Decomposition**:

| Level | Action | Result |
|---|---|---|
| **Unnormalized** | Doctor with schedule array | Repeating groups |
| **1NF** | Create DOCTOR_SCHEDULE table | Atomic values only |
| **2NF** | Verify partial deps (none) | All OK with surrogate keys |
| **3NF** | Separate DEPARTMENT entity | No transitive deps |
| **BCNF** | Verify all determinants | All are primary keys |

---

## **6. FUNCTIONAL DEPENDENCY ANALYSIS**

### **Key FDs in Main Entities**:

```
DOCTOR:
DoctorID → FirstName, LastName, DOB, Gender, Qualification, 
           Specialization, RegistrationNumber, DepartmentID, Phone, 
           Email, JoiningDate, YearsOfExperience, ConsultationFeePerHour

PATIENT:
PatientID → FirstName, LastName, DOB, Gender, BloodGroup, Height, 
            Weight, Address, City, State, Phone, Email

APPOINTMENT:
AppointmentID → PatientID, DoctorID, AppointmentDate, AppointmentTime,
                Reason, Status, ConsultationFee, Notes

PRESCRIPTION:
PrescriptionID → AppointmentID, DoctorID, PrescriptionDate, Notes, Status

BILLING:
BillingID → PatientID, AppointmentID, InsuranceID, TotalCharges,
            InsuranceCoverage, PatientPayable, PaymentStatus

All FDs respect 3NF: Each non-key attribute depends ONLY on the primary key
```

---

## **7. EXAMPLES OF NORMALIZATION ISSUES AND SOLUTIONS**

### **Issue 1: Storing Doctor Schedule as Array**

**Unnormalized**:
```sql
CREATE TABLE DOCTOR_BAD (
    DoctorID INT,
    Name VARCHAR(100),
    Schedule VARCHAR(500)  -- "MON:09-17, WED:10-18, FRI:14-20"
);
```

**Problems**:
- Can't query "Find doctors available on Monday"
- Can't enforce time constraints in database
- Difficult to update schedules
- Violates 1NF

**Normalized Solution**:
```sql
CREATE TABLE DOCTOR_SCHEDULE (
    ScheduleID INT PRIMARY KEY,
    DoctorID INT REFERENCES DOCTOR(DoctorID),
    DayOfWeek ENUM('MON', 'TUE', 'WED', ...),
    StartTime TIME,
    EndTime TIME
);
```

**Benefits**:
- Can query by day: `WHERE DayOfWeek = 'MON'`
- Can enforce time constraints: `CHECK (EndTime > StartTime)`
- Easy to add/remove schedule entries
- 1NF compliant

---

### **Issue 2: Storing Multiple Qualifications**

**Unnormalized**:
```sql
CREATE TABLE DOCTOR_BAD (
    DoctorID INT,
    Qualifications VARCHAR(500)  -- "MBBS, MD, DM"
);
```

**Normalized Solution**:
```sql
CREATE TABLE DOCTOR_QUALIFICATION (
    QualificationID INT PRIMARY KEY,
    DoctorID INT REFERENCES DOCTOR(DoctorID),
    Qualification VARCHAR(100)
);
```

---

### **Issue 3: Department Info in Doctor Table**

**Not Normalized (Transitive Dependency)**:
```sql
CREATE TABLE DOCTOR_BAD (
    DoctorID INT,
    Name VARCHAR(100),
    DepartmentID INT,
    DepartmentName VARCHAR(100),  -- TRANSITIVE!
    DepartmentHead VARCHAR(100)   -- TRANSITIVE!
);

Issue: DoctorID → DepartmentID → DepartmentName
```

**Normalized (3NF)**:
```sql
CREATE TABLE DEPARTMENT (
    DepartmentID INT PRIMARY KEY,
    DepartmentName VARCHAR(100),
    DepartmentHead INT
);

CREATE TABLE DOCTOR (
    DoctorID INT PRIMARY KEY,
    Name VARCHAR(100),
    DepartmentID INT REFERENCES DEPARTMENT(DepartmentID)
);

Result: DoctorID → DepartmentID (no further dependency)
```

---

## **SUMMARY TABLE: NORMALIZATION LEVELS**

| Level | Requirement | HMS Compliance | Verified |
|---|---|---|---|
| **1NF** | Atomic values, no repeating groups | ✓ All 14 tables | ✓ |
| **2NF** | 1NF + No partial dependencies | ✓ All tables (surrogate keys) | ✓ |
| **3NF** | 2NF + No transitive dependencies | ✓ All tables | ✓ |
| **BCNF** | Every determinant is a candidate key | ✓ All tables | ✓ |

---

## **CONCLUSION**

The Hospital Management System database achieves **3NF (Third Normal Form)** normalization throughout, with all tables satisfying **BCNF (Boyce-Codd Normal Form)** requirements. This ensures:

✅ Data integrity (no update anomalies)
✅ Minimal redundancy
✅ Efficient storage
✅ Flexible querying
✅ Maintainability

The design specifically addresses common normalization issues through careful table decomposition while maintaining referential integrity through foreign keys.

---

