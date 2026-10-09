# Relational Algebra Queries
## Hospital Management System - DBMS Concepts Module

**Document Version**: 1.0  
**Date**: October 2026  
**Module**: 05_DBMS_Concepts  
**Folder**: 01_Relational_Algebra  
**Prepared By**: Member 5 (DBMS Documentation Lead)  

---

## **INTRODUCTION**

Relational Algebra is a formal system for manipulating relations (tables) using mathematical operators. This document demonstrates 15+ relational algebra queries on the Hospital Management System database, showcasing fundamental operations: selection (σ), projection (π), join (⨝), union (∪), difference (−), and aggregation (γ).

**Notation Used**:
- σ = Selection (WHERE clause)
- π = Projection (SELECT columns)
- ⨝ = Join (INNER JOIN)
- ⟕ = Left Outer Join
- ∪ = Union
- − = Difference
- × = Cartesian Product
- γ = Aggregation (GROUP BY)
- ρ = Rename

---

## **1. SIMPLE SELECTION QUERIES**

### **Query 1.1: Find all doctors in a specific department**

**English**: "Get all doctors working in the Cardiology department"

**Relational Algebra**:
```
σ(DepartmentID = DeptID of DEPARTMENT where DeptName = 'Cardiology')(DOCTOR)
```

**Step-by-Step Breakdown**:
1. Start with DEPARTMENT table
2. Select row where DeptName = 'Cardiology'
3. Get DepartmentID from result
4. Select all rows from DOCTOR where DepartmentID matches

**Alternative (more readable)**:
```
σ(DeptName = 'Cardiology')(DEPARTMENT) ⨝ DOCTOR
```

**SQL Equivalent**:
```sql
SELECT * FROM DOCTOR
WHERE DepartmentID IN (
    SELECT DepartmentID FROM DEPARTMENT
    WHERE DeptName = 'Cardiology'
);
```

**Result**: All cardiologists (name, qualification, contact info, etc.)

---

### **Query 1.2: Find all active patients**

**English**: "Get information about all currently registered patients"

**Relational Algebra**:
```
σ(IsActive = TRUE)(PATIENT)
```

**Explanation**:
- Filter PATIENT table
- Keep only rows where IsActive = TRUE
- Return all columns for matching rows

**SQL Equivalent**:
```sql
SELECT * FROM PATIENT
WHERE IsActive = TRUE;
```

**Result**: List of all active patients with demographics

---

### **Query 1.3: Find all upcoming appointments**

**English**: "Get appointments scheduled for future dates"

**Relational Algebra**:
```
σ(AppointmentDate ≥ TODAY() AND Status = 'Scheduled')(APPOINTMENT)
```

**Explanation**:
- Select from APPOINTMENT table
- Filter where AppointmentDate is today or later
- AND Status is 'Scheduled'
- Ignore cancelled/completed appointments

**SQL Equivalent**:
```sql
SELECT * FROM APPOINTMENT
WHERE AppointmentDate >= CURDATE() 
  AND Status = 'Scheduled';
```

**Result**: Future scheduled appointments with patient/doctor details

---

### **Query 1.4: Find medicines expiring soon**

**English**: "Get medicines with expiry date within next 3 months"

**Relational Algebra**:
```
σ(ExpiryDate ≤ DATEADD(MONTH, 3, TODAY()) AND ExpiryDate ≥ TODAY())(MEDICINE)
```

**Explanation**:
- Select from MEDICINE table
- Filter where ExpiryDate is between today and 3 months from now
- These medicines need to be sold/used before expiry

**SQL Equivalent**:
```sql
SELECT * FROM MEDICINE
WHERE ExpiryDate BETWEEN CURDATE() 
  AND DATE_ADD(CURDATE(), INTERVAL 3 MONTH)
ORDER BY ExpiryDate;
```

**Result**: Medicines to prioritize for use (inventory management)

---

## **2. PROJECTION QUERIES**

### **Query 2.1: Get patient contact information**

**English**: "List patient names and phone numbers only"

**Relational Algebra**:
```
π(FirstName, LastName, Phone)(PATIENT)
```

**Explanation**:
- Select specific columns from PATIENT
- Omit sensitive data like DOB, medical history
- Focus on contact information

**SQL Equivalent**:
```sql
SELECT FirstName, LastName, Phone FROM PATIENT;
```

**Result**: 150+ rows with just name and phone

**Use Case**: Quick reference for contacting patients

---

### **Query 2.2: Get all doctor specializations available**

**English**: "What medical specialties are available at the hospital?"

**Relational Algebra**:
```
π(DISTINCT Specialization)(DOCTOR)
```

**Explanation**:
- Project only Specialization column from DOCTOR
- Remove duplicates (DISTINCT)
- Show unique specializations

**SQL Equivalent**:
```sql
SELECT DISTINCT Specialization FROM DOCTOR;
```

**Result**: List of specialties (Cardiology, Neurology, Orthopedics, etc.)

**Use Case**: Patients can see what departments exist

---

### **Query 2.3: Get all medicine names and costs**

**English**: "Create a price list for pharmacy"

**Relational Algebra**:
```
π(MedicineName, GenericName, UnitPrice, Dosage)(MEDICINE)
```

**Explanation**:
- Select medicine info from MEDICINE table
- Include brand name, generic name, price, dosage
- Exclude stock levels, expiry dates, side effects

**SQL Equivalent**:
```sql
SELECT MedicineName, GenericName, UnitPrice, Dosage 
FROM MEDICINE
ORDER BY MedicineName;
```

**Result**: Pharmacy price list (100+ medicines)

---

## **3. JOIN QUERIES**

### **Query 3.1: Find patients and their appointed doctors**

**English**: "For each appointment, show patient name and assigned doctor"

**Relational Algebra**:
```
π(PATIENT.FirstName, PATIENT.LastName, DOCTOR.FirstName, DOCTOR.LastName, 
  APPOINTMENT.AppointmentDate, APPOINTMENT.AppointmentTime)
(PATIENT ⨝ APPOINTMENT ⨝ DOCTOR)
```

**Explanation**:
- Join PATIENT with APPOINTMENT (on PatientID)
- Join result with DOCTOR (on DoctorID)
- Project needed columns
- Show patient-doctor relationships

**SQL Equivalent**:
```sql
SELECT p.FirstName as PatientFirstName, p.LastName as PatientLastName,
       d.FirstName as DoctorFirstName, d.LastName as DoctorLastName,
       a.AppointmentDate, a.AppointmentTime
FROM APPOINTMENT a
JOIN PATIENT p ON a.PatientID = p.PatientID
JOIN DOCTOR d ON a.DoctorID = d.DoctorID
ORDER BY a.AppointmentDate;
```

**Result**: 200+ appointments with patient-doctor info

---

### **Query 3.2: Find prescriptions with medicine details**

**English**: "For each prescription, show medicines and dosages"

**Relational Algebra**:
```
π(PRESCRIPTION.PrescriptionID, MEDICINE.MedicineName, MEDICINE.Dosage,
  PRESCRIPTION_ITEMS.Frequency, PRESCRIPTION_ITEMS.Duration)
(PRESCRIPTION ⨝ PRESCRIPTION_ITEMS ⨝ MEDICINE)
```

**Explanation**:
- Join PRESCRIPTION with PRESCRIPTION_ITEMS (on PrescriptionID)
- Join with MEDICINE (on MedicineID)
- Get prescription and medicine details together
- Shows what medicines are prescribed and how to take them

**SQL Equivalent**:
```sql
SELECT presc.PrescriptionID, m.MedicineName, m.Dosage,
       pi.Frequency, pi.Duration, pi.Quantity
FROM PRESCRIPTION presc
JOIN PRESCRIPTION_ITEMS pi ON presc.PrescriptionID = pi.PrescriptionID
JOIN MEDICINE m ON pi.MedicineID = m.MedicineID
ORDER BY presc.PrescriptionID;
```

**Result**: 50+ prescriptions with detailed medicine info

---

### **Query 3.3: Find billing details with patient and insurance info**

**English**: "Show billing amounts, insurance coverage, and patient payable"

**Relational Algebra**:
```
π(PATIENT.FirstName, PATIENT.LastName, BILLING.BillingNumber,
  BILLING.TotalCharges, BILLING.InsuranceCoverage, BILLING.PatientPayable,
  INSURANCE.InsuranceProvider)
(BILLING ⨝ PATIENT ⨝ (INSURANCE ⟕ BILLING))
```

**Explanation**:
- Join BILLING with PATIENT (on PatientID)
- Left outer join with INSURANCE (optional coverage)
- Shows billing amounts broken down by insurance/patient

**SQL Equivalent**:
```sql
SELECT p.FirstName, p.LastName, b.BillingNumber,
       b.TotalCharges, b.InsuranceCoverage, b.PatientPayable,
       COALESCE(i.InsuranceProvider, 'No Insurance') as InsuranceProvider
FROM BILLING b
JOIN PATIENT p ON b.PatientID = p.PatientID
LEFT JOIN INSURANCE i ON b.InsuranceID = i.InsuranceID
ORDER BY b.BillingDate DESC;
```

**Result**: 150+ bills with coverage breakdown

---

## **4. AGGREGATION QUERIES**

### **Query 4.1: Count total patients by department (through appointments)**

**English**: "How many patients visit each department?"

**Relational Algebra**:
```
γ(DepartmentID; COUNT(DISTINCT PatientID))(
  σ(Status = 'Completed')(APPOINTMENT) ⨝ DOCTOR
)
```

**Explanation**:
- Join completed APPOINTMENTS with DOCTOR
- Group by DepartmentID
- Count distinct patients per department

**SQL Equivalent**:
```sql
SELECT d.DepartmentID, d.DeptName, COUNT(DISTINCT a.PatientID) as PatientCount
FROM APPOINTMENT a
JOIN DOCTOR d ON a.DoctorID = d.DoctorID
WHERE a.Status = 'Completed'
GROUP BY d.DepartmentID, d.DeptName
ORDER BY PatientCount DESC;
```

**Result**: Patient distribution across departments

---

### **Query 4.2: Calculate average consultation fee by doctor specialization**

**English**: "What's the average consultation cost per medical specialty?"

**Relational Algebra**:
```
γ(Specialization; AVG(ConsultationFeePerHour))(DOCTOR)
```

**Explanation**:
- Group DOCTOR by Specialization
- Calculate average consultation fee for each specialty

**SQL Equivalent**:
```sql
SELECT Specialization, AVG(ConsultationFeePerHour) as AvgFee, 
       COUNT(*) as DoctorCount
FROM DOCTOR
GROUP BY Specialization
ORDER BY AvgFee DESC;
```

**Result**: Average costs per specialty (helps with billing)

---

### **Query 4.3: Total billing amount by insurance provider**

**English**: "How much does each insurance company cover?"

**Relational Algebra**:
```
γ(InsuranceProvider; SUM(InsuranceCoverage), COUNT(*))(
  BILLING ⨝ (INSURANCE ⟕ BILLING)
)
```

**Explanation**:
- Join BILLING with INSURANCE
- Group by InsuranceProvider
- Sum insurance coverage amounts per provider
- Count bills per provider

**SQL Equivalent**:
```sql
SELECT i.InsuranceProvider, 
       SUM(b.InsuranceCoverage) as TotalCoverage,
       COUNT(b.BillingID) as NumberOfBills,
       AVG(b.InsuranceCoverage) as AvgCoverage
FROM BILLING b
LEFT JOIN INSURANCE i ON b.InsuranceID = i.InsuranceID
WHERE i.InsuranceID IS NOT NULL
GROUP BY i.InsuranceProvider
ORDER BY TotalCoverage DESC;
```

**Result**: Insurance company payment summary

---

### **Query 4.4: Count medicines by manufacturer**

**English**: "How many medicines does each pharmaceutical company supply?"

**Relational Algebra**:
```
γ(ManufacturerID; COUNT(*), SUM(QuantityInStock))(MEDICINE)
```

**Explanation**:
- Group MEDICINE by ManufacturerID
- Count medicines per manufacturer
- Sum total quantity in stock per manufacturer

**SQL Equivalent**:
```sql
SELECT m.ManufacturerID, m.MfgName, COUNT(*) as MedicineCount,
       SUM(med.QuantityInStock) as TotalStock
FROM MEDICINE med
JOIN MANUFACTURER m ON med.ManufacturerID = m.ManufacturerID
GROUP BY m.ManufacturerID, m.MfgName
ORDER BY MedicineCount DESC;
```

**Result**: Supplier performance metrics

---

## **5. SET OPERATIONS**

### **Query 5.1: Find doctors who are also department heads**

**English**: "Which doctors hold management positions?"

**Relational Algebra**:
```
π(DoctorID, FirstName, LastName)(DOCTOR) 
∩ 
π(HeadID, FirstName, LastName)(DEPARTMENT ⨝ DOCTOR)
```

**Explanation**:
- Find all doctors in DOCTOR table
- Find all doctors who are department heads (HeadID)
- Intersection shows doctors in both sets

**SQL Equivalent**:
```sql
SELECT DISTINCT d.DoctorID, d.FirstName, d.LastName, dept.DeptName
FROM DOCTOR d
WHERE d.DoctorID IN (
    SELECT HeadID FROM DEPARTMENT
)
ORDER BY d.FirstName;
```

**Result**: Doctors with dual roles (clinician + administrator)

---

### **Query 5.2: Find patients without insurance vs with insurance**

**English**: "Which patients have insurance coverage?"

**Relational Algebra**:
```
-- Patients WITH insurance
π(PatientID)(INSURANCE)

-- Patients WITHOUT insurance
π(PatientID)(PATIENT) − π(PatientID)(INSURANCE)
```

**Explanation**:
- Patients with insurance = those in INSURANCE table
- Patients without = all patients minus those with insurance
- Difference operation shows uninsured patients

**SQL Equivalent**:
```sql
SELECT p.PatientID, p.FirstName, p.LastName,
       CASE WHEN i.InsuranceID IS NOT NULL THEN 'Yes' ELSE 'No' END as HasInsurance
FROM PATIENT p
LEFT JOIN INSURANCE i ON p.PatientID = i.PatientID
ORDER BY HasInsurance;
```

**Result**: Insurance coverage breakdown

---

### **Query 5.3: Find completed appointments this month**

**English**: "Show all finished appointments from current month"

**Relational Algebra**:
```
σ(Status = 'Completed' AND MONTH(AppointmentDate) = CURRENT_MONTH)(APPOINTMENT)
```

**Explanation**:
- Select from APPOINTMENT where Status = 'Completed'
- Filter for current month
- Shows completed visit history

**SQL Equivalent**:
```sql
SELECT a.AppointmentID, p.FirstName as PatientName, 
       d.FirstName as DoctorName, a.AppointmentDate,
       a.Reason, a.Notes
FROM APPOINTMENT a
JOIN PATIENT p ON a.PatientID = p.PatientID
JOIN DOCTOR d ON a.DoctorID = d.DoctorID
WHERE a.Status = 'Completed' 
  AND MONTH(a.AppointmentDate) = MONTH(CURDATE())
  AND YEAR(a.AppointmentDate) = YEAR(CURDATE())
ORDER BY a.AppointmentDate DESC;
```

**Result**: Current month's completed appointments

---

## **6. COMPLEX MULTI-STEP QUERIES**

### **Query 6.1: Find high-value patients (by billing)**

**English**: "Which patients have paid the most in total bills?"

**Relational Algebra**:
```
γ(PatientID; SUM(TotalCharges) as TotalSpent)(BILLING)
⨝ PATIENT
σ(TotalSpent > AVG(TotalSpent))(result)
π(FirstName, LastName, TotalSpent, AppointmentCount)
```

**Explanation**:
1. Group BILLING by PatientID
2. Sum total charges per patient
3. Join with PATIENT for names
4. Filter for above-average spenders
5. Project names and totals

**SQL Equivalent**:
```sql
WITH PatientTotals AS (
    SELECT b.PatientID, SUM(b.TotalCharges) as TotalSpent,
           COUNT(b.BillingID) as BillCount
    FROM BILLING b
    GROUP BY b.PatientID
)
SELECT p.FirstName, p.LastName, pt.TotalSpent, pt.BillCount
FROM PatientTotals pt
JOIN PATIENT p ON pt.PatientID = p.PatientID
WHERE pt.TotalSpent > (SELECT AVG(TotalSpent) FROM PatientTotals)
ORDER BY pt.TotalSpent DESC;
```

**Result**: Top-value patients for hospital

---

### **Query 6.2: Find doctors with most appointments this month**

**English**: "Which doctors are busiest this month?"

**Relational Algebra**:
```
σ(MONTH(AppointmentDate) = CURRENT_MONTH AND Status != 'Cancelled')(APPOINTMENT)
⨝ DOCTOR
γ(DoctorID; COUNT(*) as AppointmentCount)
π(FirstName, LastName, Specialization, AppointmentCount)
σ(AppointmentCount > 10)
```

**Explanation**:
1. Filter appointments for current month (exclude cancellations)
2. Join with DOCTOR table
3. Group by DoctorID and count appointments
4. Project doctor info and count
5. Filter doctors with >10 appointments

**SQL Equivalent**:
```sql
SELECT d.FirstName, d.LastName, d.Specialization, 
       COUNT(a.AppointmentID) as AppointmentCount
FROM APPOINTMENT a
JOIN DOCTOR d ON a.DoctorID = d.DoctorID
WHERE MONTH(a.AppointmentDate) = MONTH(CURDATE())
  AND YEAR(a.AppointmentDate) = YEAR(CURDATE())
  AND a.Status != 'Cancelled'
GROUP BY d.DoctorID, d.FirstName, d.LastName, d.Specialization
HAVING COUNT(a.AppointmentID) > 10
ORDER BY AppointmentCount DESC;
```

**Result**: Busiest doctors this month

---

### **Query 6.3: Find low-stock medicines by urgency**

**English**: "Which medicines need urgent reordering?"

**Relational Algebra**:
```
σ(QuantityInStock ≤ ReorderLevel)(MEDICINE)
⨝ MANUFACTURER
γ(ManufacturerID; COUNT(*) as UrgentCount)
π(MfgName, UrgentCount, MedicineList)
σ(UrgentCount > 5)
```

**Explanation**:
1. Select medicines where stock ≤ reorder level
2. Join with MANUFACTURER for supplier info
3. Group by manufacturer to see who's affected
4. Filter manufacturers with multiple low-stock items
5. Identify top priority suppliers

**SQL Equivalent**:
```sql
SELECT m.ManufacturerID, m.MfgName, m.Phone,
       COUNT(med.MedicineID) as LowStockCount,
       GROUP_CONCAT(med.MedicineName) as MedicinesNeeded
FROM MEDICINE med
JOIN MANUFACTURER m ON med.ManufacturerID = m.ManufacturerID
WHERE med.QuantityInStock <= med.ReorderLevel
GROUP BY m.ManufacturerID, m.MfgName, m.Phone
HAVING COUNT(med.MedicineID) > 0
ORDER BY LowStockCount DESC;
```

**Result**: Urgent reorder list by manufacturer

---

## **7. DIVISION QUERIES**

### **Query 7.1: Find patients who had appointments with ALL cardiologists**

**English**: "Which patients have been seen by every cardiologist in the hospital?"

**Relational Algebra**:
```
-- All cardiologists
π(DoctorID)(σ(Specialization = 'Cardiology')(DOCTOR)) as AllCardiologists

-- Doctors each patient has seen
π(PatientID, DoctorID)(
  APPOINTMENT ⨝ σ(Specialization = 'Cardiology')(DOCTOR)
) ÷ AllCardiologists
```

**Explanation**:
1. Find all cardiologists in hospital
2. For each patient, find which cardiologists they've seen
3. Division operation: patients who've seen ALL cardiologists
4. These patients have comprehensive cardiology evaluations

**SQL Equivalent**:
```sql
SELECT p.PatientID, p.FirstName, p.LastName, 
       COUNT(DISTINCT a.DoctorID) as CardiologistCount
FROM PATIENT p
JOIN APPOINTMENT a ON p.PatientID = a.PatientID
JOIN DOCTOR d ON a.DoctorID = d.DoctorID
WHERE d.Specialization = 'Cardiology'
GROUP BY p.PatientID, p.FirstName, p.LastName
HAVING COUNT(DISTINCT a.DoctorID) = (
    SELECT COUNT(*) FROM DOCTOR WHERE Specialization = 'Cardiology'
);
```

**Result**: Patients with multi-specialist cardiology care

---

## **SUMMARY TABLE OF QUERIES**

| Query # | Type | Complexity | Purpose |
|---|---|---|---|
| 1.1 | Selection | Low | Find department doctors |
| 1.2 | Selection | Low | Active patients |
| 1.3 | Selection | Low | Upcoming appointments |
| 1.4 | Selection | Medium | Inventory management |
| 2.1 | Projection | Low | Contact info |
| 2.2 | Projection | Low | Available specialties |
| 2.3 | Projection | Low | Price list |
| 3.1 | Join | Medium | Patient-doctor relationships |
| 3.2 | Join | Medium | Prescription details |
| 3.3 | Join | Medium | Billing breakdown |
| 4.1 | Aggregation | Medium | Patient distribution |
| 4.2 | Aggregation | Medium | Average costs |
| 4.3 | Aggregation | Medium | Insurance summary |
| 4.4 | Aggregation | Medium | Supplier metrics |
| 5.1 | Set Operation | Medium | Doctor roles |
| 5.2 | Set Operation | Medium | Insurance coverage |
| 5.3 | Set Operation | Medium | Monthly summary |
| 6.1 | Complex | High | High-value patients |
| 6.2 | Complex | High | Busy doctors |
| 6.3 | Complex | High | Reorder priority |
| 7.1 | Division | High | Specialist coverage |

---

## **KEY CONCEPTS DEMONSTRATED**

✅ Selection (σ) - Filtering rows based on conditions
✅ Projection (π) - Selecting specific columns
✅ Join (⨝) - Combining tables on common attributes
✅ Outer Joins (⟕) - Including unmatched rows
✅ Union (∪) - Combining result sets
✅ Difference (−) - Rows in one set but not another
✅ Cartesian Product (×) - All combinations of rows
✅ Aggregation (γ) - GROUP BY and COUNT/SUM/AVG
✅ Rename (ρ) - Aliasing for clarity
✅ Division (÷) - Advanced set operations

---

## **PERFORMANCE NOTES**

- Simple selections (1.1-1.4): O(n) - linear scan
- Projections (2.1-2.3): O(n) - with deduplication O(n log n)
- Joins (3.1-3.3): O(n×m) without index, O(n log m) with proper indexing
- Aggregations (4.1-4.4): O(n log n) with sorting, O(n) with hash aggregation
- Complex queries (6.1-6.3): Multiple operations, optimized via query planner

---

**This module covers essential relational algebra operations needed for database understanding and optimization.**

