# Tuple Relational Calculus Queries
## Hospital Management System - DBMS Concepts Module

**Document Version**: 1.0  
**Date**: October 2026  
**Module**: 05_DBMS_Concepts  
**Folder**: 02_Relational_Calculus  
**Prepared By**: Member 5 (DBMS Documentation Lead)  

---

## **INTRODUCTION**

Tuple Relational Calculus (TRC) is a non-procedural language for querying databases. Instead of specifying HOW to retrieve data (like SQL), TRC specifies WHAT data is wanted using mathematical logic. This document demonstrates 15+ TRC queries equivalent to the Relational Algebra examples, showing both the theoretical and practical aspects.

**TRC Notation**:
- `{t | P(t)}` = Set of all tuples t where predicate P(t) is true
- `∃` = "there exists" (existential quantifier)
- `∀` = "for all" (universal quantifier)
- `∧` = AND logical operator
- `∨` = OR logical operator
- `¬` = NOT logical operator
- `∈` = "belongs to" relation

---

## **1. SIMPLE RETRIEVAL QUERIES**

### **Query 1.1: Find all doctors in Cardiology department**

**English**: "Get all doctors working in the Cardiology department"

**Tuple Relational Calculus**:
```
{d | d ∈ DOCTOR ∧ ∃ dept ∈ DEPARTMENT 
     (dept.DepartmentID = d.DepartmentID ∧ dept.DeptName = 'Cardiology')}
```

**Explanation**:
- `{d | ...}` = Result is set of tuples d
- `d ∈ DOCTOR` = d must be a doctor tuple
- `∃ dept ∈ DEPARTMENT` = there exists a department tuple
- `dept.DepartmentID = d.DepartmentID` = doctor belongs to this department
- `dept.DeptName = 'Cardiology'` = department is Cardiology

**Logical Reading**: "Give me all doctor tuples where there exists a department tuple that matches the doctor's department and that department is Cardiology"

**SQL Equivalent**:
```sql
SELECT * FROM DOCTOR d
WHERE d.DepartmentID IN (
    SELECT DepartmentID FROM DEPARTMENT 
    WHERE DeptName = 'Cardiology'
);
```

---

### **Query 1.2: Find all scheduled future appointments**

**English**: "Get appointments scheduled for future dates with status 'Scheduled'"

**Tuple Relational Calculus**:
```
{a | a ∈ APPOINTMENT ∧ a.AppointmentDate ≥ TODAY() ∧ a.Status = 'Scheduled'}
```

**Explanation**:
- `a ∈ APPOINTMENT` = a is an appointment tuple
- `a.AppointmentDate ≥ TODAY()` = appointment is in the future
- `a.Status = 'Scheduled'` = appointment is scheduled (not cancelled)
- `∧` = all conditions must be true (AND logic)

**Logical Reading**: "Give me all appointment tuples where the appointment date is today or later AND the status is 'Scheduled'"

**SQL Equivalent**:
```sql
SELECT * FROM APPOINTMENT a
WHERE a.AppointmentDate >= CURDATE() 
  AND a.Status = 'Scheduled';
```

---

### **Query 1.3: Find medicines with low stock**

**English**: "Get medicines where quantity in stock is below reorder level"

**Tuple Relational Calculus**:
```
{m | m ∈ MEDICINE ∧ m.QuantityInStock ≤ m.ReorderLevel}
```

**Explanation**:
- `m ∈ MEDICINE` = m is a medicine tuple
- `m.QuantityInStock ≤ m.ReorderLevel` = stock is at or below threshold

**Logical Reading**: "Give me all medicine tuples where the quantity in stock is less than or equal to the reorder level"

**SQL Equivalent**:
```sql
SELECT * FROM MEDICINE m
WHERE m.QuantityInStock <= m.ReorderLevel
ORDER BY m.QuantityInStock ASC;
```

---

## **2. PROJECTION QUERIES**

### **Query 2.1: Get patient names and phone numbers**

**English**: "List patient contact information (name and phone only)"

**Tuple Relational Calculus**:
```
{t | ∃ p ∈ PATIENT (t.FirstName = p.FirstName ∧ t.LastName = p.LastName ∧ t.Phone = p.Phone)}
```

**Explanation**:
- `{t | ...}` = Result tuple t with specific attributes
- `∃ p ∈ PATIENT` = there exists a patient tuple p
- `t.FirstName = p.FirstName` = copy patient's first name
- `t.LastName = p.LastName` = copy patient's last name
- `t.Phone = p.Phone` = copy patient's phone

**Alternative Notation**:
```
{t | t[FirstName, LastName, Phone] ∈ PATIENT}
```

**Logical Reading**: "Give me tuples containing only FirstName, LastName, and Phone from all patient tuples"

**SQL Equivalent**:
```sql
SELECT FirstName, LastName, Phone FROM PATIENT;
```

---

### **Query 2.2: Get unique medical specializations**

**English**: "What are the available doctor specialties?"

**Tuple Relational Calculus**:
```
{t | ∃ d ∈ DOCTOR (t.Specialization = d.Specialization)}
  with DISTINCT
```

**Explanation**:
- Project specialization from DOCTOR
- Eliminate duplicates (shown with DISTINCT in pseudo-code)
- Get list of unique specialties

**Logical Reading**: "Give me all specialization values from doctor tuples, eliminating duplicates"

**SQL Equivalent**:
```sql
SELECT DISTINCT Specialization FROM DOCTOR;
```

---

## **3. JOIN QUERIES**

### **Query 3.1: Find appointment details with patient and doctor names**

**English**: "For each appointment, show patient name, doctor name, date, and time"

**Tuple Relational Calculus**:
```
{t | ∃ a ∈ APPOINTMENT ∃ p ∈ PATIENT ∃ d ∈ DOCTOR
     (a.PatientID = p.PatientID ∧ 
      a.DoctorID = d.DoctorID ∧
      t.PatientName = p.FirstName || ' ' || p.LastName ∧
      t.DoctorName = d.FirstName || ' ' || d.LastName ∧
      t.AppointmentDate = a.AppointmentDate ∧
      t.AppointmentTime = a.AppointmentTime)}
```

**Explanation**:
- `∃ a ∈ APPOINTMENT` = there's an appointment
- `∃ p ∈ PATIENT` = there's a patient
- `∃ d ∈ DOCTOR` = there's a doctor
- `a.PatientID = p.PatientID ∧ a.DoctorID = d.DoctorID` = match appointment to patient and doctor
- Concatenate names for display

**Logical Reading**: "For each combination of appointment, patient, and doctor that match on IDs, give me a tuple with the patient name, doctor name, and appointment details"

**SQL Equivalent**:
```sql
SELECT CONCAT(p.FirstName, ' ', p.LastName) as PatientName,
       CONCAT(d.FirstName, ' ', d.LastName) as DoctorName,
       a.AppointmentDate, a.AppointmentTime
FROM APPOINTMENT a
JOIN PATIENT p ON a.PatientID = p.PatientID
JOIN DOCTOR d ON a.DoctorID = d.DoctorID;
```

---

### **Query 3.2: Find prescriptions with medication details**

**English**: "For each prescription, list medicines with dosage and frequency"

**Tuple Relational Calculus**:
```
{t | ∃ presc ∈ PRESCRIPTION ∃ pi ∈ PRESCRIPTION_ITEMS ∃ m ∈ MEDICINE
     (presc.PrescriptionID = pi.PrescriptionID ∧
      pi.MedicineID = m.MedicineID ∧
      t.PrescriptionID = presc.PrescriptionID ∧
      t.MedicineName = m.MedicineName ∧
      t.Dosage = m.Dosage ∧
      t.Frequency = pi.Frequency ∧
      t.Duration = pi.Duration)}
```

**Explanation**:
- Join PRESCRIPTION ← PRESCRIPTION_ITEMS → MEDICINE
- Match on appropriate foreign keys
- Project prescription ID, medicine name, dosage instructions

**Logical Reading**: "For each prescription item that belongs to a prescription and references a medicine, give me the prescription ID, medicine name, and how to take it"

**SQL Equivalent**:
```sql
SELECT presc.PrescriptionID, m.MedicineName, m.Dosage,
       pi.Frequency, pi.Duration, pi.Quantity
FROM PRESCRIPTION presc
JOIN PRESCRIPTION_ITEMS pi ON presc.PrescriptionID = pi.PrescriptionID
JOIN MEDICINE m ON pi.MedicineID = m.MedicineID;
```

---

### **Query 3.3: Find patient billing with insurance coverage**

**English**: "Show billing amount, insurance coverage, and patient responsibility"

**Tuple Relational Calculus**:
```
{t | ∃ b ∈ BILLING ∃ p ∈ PATIENT 
     (b.PatientID = p.PatientID ∧
      t.PatientName = p.FirstName || ' ' || p.LastName ∧
      t.BillingNumber = b.BillingNumber ∧
      t.TotalCharges = b.TotalCharges ∧
      ((∃ i ∈ INSURANCE (b.InsuranceID = i.InsuranceID ∧
                        t.InsuranceProvider = i.InsuranceProvider)) ∨
       (¬∃ i ∈ INSURANCE (b.InsuranceID = i.InsuranceID) ∧
        t.InsuranceProvider = 'No Insurance')) ∧
      t.InsuranceCoverage = b.InsuranceCoverage ∧
      t.PatientPayable = b.PatientPayable)}
```

**Explanation**:
- Join BILLING with PATIENT
- Optional join with INSURANCE (using OR logic with negation)
- Show all billing components

**Logical Reading**: "For each bill, find the patient and show billing details. If insurance exists, include provider name; otherwise, show 'No Insurance'"

**SQL Equivalent**:
```sql
SELECT p.FirstName || ' ' || p.LastName as PatientName,
       b.BillingNumber, b.TotalCharges,
       COALESCE(i.InsuranceProvider, 'No Insurance') as InsuranceProvider,
       b.InsuranceCoverage, b.PatientPayable
FROM BILLING b
JOIN PATIENT p ON b.PatientID = p.PatientID
LEFT JOIN INSURANCE i ON b.InsuranceID = i.InsuranceID;
```

---

## **4. QUANTIFIED QUERIES**

### **Query 4.1: Find doctors who are department heads**

**English**: "Which doctors hold management positions as department heads?"

**Tuple Relational Calculus**:
```
{t | ∃ d ∈ DOCTOR ∃ dept ∈ DEPARTMENT
     (d.DoctorID = dept.HeadID ∧
      t.DoctorID = d.DoctorID ∧
      t.DoctorName = d.FirstName || ' ' || d.LastName ∧
      t.DepartmentName = dept.DeptName)}
```

**Explanation**:
- Find DOCTOR where DoctorID = DEPARTMENT.HeadID
- These doctors have dual roles
- Project doctor and department information

**Logical Reading**: "For each doctor whose ID matches a department's HeadID, give me the doctor's name and department"

**SQL Equivalent**:
```sql
SELECT d.DoctorID, d.FirstName || ' ' || d.LastName as DoctorName,
       dept.DepartmentName
FROM DOCTOR d
WHERE d.DoctorID IN (SELECT HeadID FROM DEPARTMENT);
```

---

### **Query 4.2: Find patients without any insurance**

**English**: "Which patients are uninsured?"

**Tuple Relational Calculus**:
```
{t | ∃ p ∈ PATIENT
     (¬∃ i ∈ INSURANCE (i.PatientID = p.PatientID) ∧
      t.PatientID = p.PatientID ∧
      t.PatientName = p.FirstName || ' ' || p.LastName ∧
      t.Phone = p.Phone)}
```

**Explanation**:
- `¬∃ i ∈ INSURANCE (i.PatientID = p.PatientID)` = there does NOT exist insurance for patient
- Select patients with no matching insurance record
- Return patient details

**Logical Reading**: "For each patient where NO insurance tuple exists with matching PatientID, give me the patient information"

**SQL Equivalent**:
```sql
SELECT p.PatientID, p.FirstName || ' ' || p.LastName as PatientName, p.Phone
FROM PATIENT p
WHERE NOT EXISTS (SELECT 1 FROM INSURANCE i WHERE i.PatientID = p.PatientID);
```

---

### **Query 4.3: Find doctors who have prescribed specific medicine**

**English**: "Which doctors have prescribed Aspirin?"

**Tuple Relational Calculus**:
```
{t | ∃ d ∈ DOCTOR
     (∃ presc ∈ PRESCRIPTION ∃ pi ∈ PRESCRIPTION_ITEMS ∃ m ∈ MEDICINE
      (d.DoctorID = presc.DoctorID ∧
       presc.PrescriptionID = pi.PrescriptionID ∧
       pi.MedicineID = m.MedicineID ∧
       m.MedicineName = 'Aspirin' ∧
       t.DoctorID = d.DoctorID ∧
       t.DoctorName = d.FirstName || ' ' || d.LastName))}
```

**Explanation**:
- Chain of existential quantifiers: doctor → prescription → item → medicine
- Match all foreign keys in sequence
- Filter for specific medicine name
- Return doctor information

**Logical Reading**: "For each doctor, find all their prescriptions that contain Aspirin, and return the doctor's name"

**SQL Equivalent**:
```sql
SELECT DISTINCT d.DoctorID, d.FirstName || ' ' || d.LastName as DoctorName,
       d.Specialization
FROM DOCTOR d
WHERE EXISTS (
    SELECT 1 FROM PRESCRIPTION presc
    WHERE presc.DoctorID = d.DoctorID
      AND EXISTS (
          SELECT 1 FROM PRESCRIPTION_ITEMS pi
          WHERE pi.PrescriptionID = presc.PrescriptionID
            AND EXISTS (
                SELECT 1 FROM MEDICINE m
                WHERE m.MedicineID = pi.MedicineID
                  AND m.MedicineName = 'Aspirin'
            )
      )
);
```

---

## **5. AGGREGATE AND FUNCTION QUERIES**

### **Query 5.1: Count appointments per doctor (using GROUP BY logic)**

**English**: "How many appointments does each doctor have?"

**Tuple Relational Calculus** (simulated with counting):
```
{t | ∃ d ∈ DOCTOR
     (t.DoctorID = d.DoctorID ∧
      t.DoctorName = d.FirstName || ' ' || d.LastName ∧
      t.AppointmentCount = COUNT({a | a ∈ APPOINTMENT ∧ a.DoctorID = d.DoctorID}))}
```

**Explanation**:
- For each doctor, count matching appointments
- Inner query: `COUNT({a | a ∈ APPOINTMENT ∧ a.DoctorID = d.DoctorID})`
- Pseudo-code extends TRC to include aggregation

**Logical Reading**: "For each doctor, count how many appointment tuples have that doctor's ID"

**SQL Equivalent**:
```sql
SELECT d.DoctorID, d.FirstName || ' ' || d.LastName as DoctorName,
       COUNT(a.AppointmentID) as AppointmentCount
FROM DOCTOR d
LEFT JOIN APPOINTMENT a ON d.DoctorID = a.DoctorID
GROUP BY d.DoctorID, d.FirstName, d.LastName
ORDER BY AppointmentCount DESC;
```

---

### **Query 5.2: Find total billing per insurance provider**

**English**: "What is the total coverage amount per insurance company?"

**Tuple Relational Calculus**:
```
{t | ∃ i ∈ INSURANCE
     (t.InsuranceProvider = i.InsuranceProvider ∧
      t.TotalCoverage = SUM({b | b ∈ BILLING ∧ b.InsuranceID = i.InsuranceID ∧ 
                                  b.InsuranceCoverage}))}
```

**Explanation**:
- For each insurance company
- Sum all InsuranceCoverage values from bills using that insurance
- Return provider name and total

**Logical Reading**: "For each insurance provider, sum up the coverage amounts from all billing tuples using that insurance"

**SQL Equivalent**:
```sql
SELECT i.InsuranceProvider,
       SUM(b.InsuranceCoverage) as TotalCoverage,
       COUNT(b.BillingID) as NumberOfBills
FROM INSURANCE i
JOIN BILLING b ON i.InsuranceID = b.InsuranceID
GROUP BY i.InsuranceProvider
ORDER BY TotalCoverage DESC;
```

---

## **6. COMPLEX LOGICAL QUERIES**

### **Query 6.1: Find patients with appointments AND prescriptions this month**

**English**: "Which patients had appointments AND received prescriptions this month?"

**Tuple Relational Calculus**:
```
{t | ∃ p ∈ PATIENT
     (∃ a ∈ APPOINTMENT ∃ presc ∈ PRESCRIPTION
      (p.PatientID = a.PatientID ∧
       a.DoctorID = presc.DoctorID ∧
       a.AppointmentID = presc.AppointmentID ∧
       MONTH(a.AppointmentDate) = MONTH(TODAY()) ∧
       YEAR(a.AppointmentDate) = YEAR(TODAY()) ∧
       t.PatientID = p.PatientID ∧
       t.PatientName = p.FirstName || ' ' || p.LastName))}
```

**Explanation**:
- Find patient where:
  - There exists an appointment for this patient in current month
  - AND that appointment has a prescription
- Double existential quantifier checks both conditions

**Logical Reading**: "For each patient, check if they have an appointment with a prescription this month. If so, return the patient"

**SQL Equivalent**:
```sql
SELECT DISTINCT p.PatientID, p.FirstName || ' ' || p.LastName as PatientName
FROM PATIENT p
WHERE EXISTS (
    SELECT 1 FROM APPOINTMENT a
    WHERE a.PatientID = p.PatientID
      AND MONTH(a.AppointmentDate) = MONTH(CURDATE())
      AND YEAR(a.AppointmentDate) = YEAR(CURDATE())
      AND EXISTS (
          SELECT 1 FROM PRESCRIPTION presc
          WHERE presc.AppointmentID = a.AppointmentID
      )
);
```

---

### **Query 6.2: Find medicines in stock BUT low quantity**

**English**: "Which medicines are available but need reordering soon?"

**Tuple Relational Calculus**:
```
{t | ∃ m ∈ MEDICINE
     (m.QuantityInStock > 0 ∧                          -- In stock
      m.QuantityInStock ≤ m.ReorderLevel ∧            -- Below reorder level
      m.ExpiryDate > TODAY() ∧                         -- Not expired
      t.MedicineID = m.MedicineID ∧
      t.MedicineName = m.MedicineName ∧
      t.QuantityInStock = m.QuantityInStock ∧
      t.ReorderLevel = m.ReorderLevel)}
```

**Explanation**:
- Multiple conditions combined with ∧ (AND)
- Available but critically low stock
- Still within expiry date
- Priority reorder list

**Logical Reading**: "For each medicine that is in stock, below reorder level, and not expired, return its details"

**SQL Equivalent**:
```sql
SELECT m.MedicineID, m.MedicineName, m.QuantityInStock, 
       m.ReorderLevel, m.ExpiryDate
FROM MEDICINE m
WHERE m.QuantityInStock > 0
  AND m.QuantityInStock <= m.ReorderLevel
  AND m.ExpiryDate > CURDATE()
ORDER BY m.QuantityInStock ASC;
```

---

### **Query 6.3: Find doctors who are NOT cardiology specialists**

**English**: "List all non-cardiology doctors"

**Tuple Relational Calculus**:
```
{t | ∃ d ∈ DOCTOR
     (¬(d.Specialization = 'Cardiology') ∧
      t.DoctorID = d.DoctorID ∧
      t.DoctorName = d.FirstName || ' ' || d.LastName ∧
      t.Specialization = d.Specialization)}
```

**Explanation**:
- `¬(d.Specialization = 'Cardiology')` = Specialization is NOT 'Cardiology'
- Return doctors in other specialties
- Simple negation of a condition

**Logical Reading**: "For each doctor whose specialization is not Cardiology, return the doctor details"

**SQL Equivalent**:
```sql
SELECT d.DoctorID, d.FirstName || ' ' || d.LastName as DoctorName,
       d.Specialization
FROM DOCTOR d
WHERE d.Specialization != 'Cardiology'
ORDER BY d.Specialization;
```

---

## **7. UNIVERSAL QUANTIFIER QUERIES**

### **Query 7.1: Find patients who have seen doctors from ALL departments**

**English**: "Which patients have appointments with doctors from every department?"

**Tuple Relational Calculus**:
```
{t | ∃ p ∈ PATIENT
     (∀ dept ∈ DEPARTMENT
      ∃ a ∈ APPOINTMENT ∃ d ∈ DOCTOR
      (a.PatientID = p.PatientID ∧
       a.DoctorID = d.DoctorID ∧
       d.DepartmentID = dept.DepartmentID ∧
       t.PatientID = p.PatientID ∧
       t.PatientName = p.FirstName || ' ' || p.LastName))}
```

**Explanation**:
- `∀ dept ∈ DEPARTMENT` = for ALL departments
- `∃ a ∈ APPOINTMENT ...` = there EXISTS an appointment in that department
- Patient must have appointments covering every department

**Logical Reading**: "For each patient, check if they have an appointment with a doctor from EVERY department. If so, return the patient"

**SQL Equivalent**:
```sql
SELECT p.PatientID, p.FirstName || ' ' || p.LastName as PatientName
FROM PATIENT p
WHERE NOT EXISTS (
    SELECT 1 FROM DEPARTMENT dept
    WHERE NOT EXISTS (
        SELECT 1 FROM APPOINTMENT a
        JOIN DOCTOR d ON a.DoctorID = d.DoctorID
        WHERE a.PatientID = p.PatientID
          AND d.DepartmentID = dept.DepartmentID
    )
);
```

---

## **SUMMARY OF TRC SYNTAX**

| Concept | Notation | Meaning |
|---|---|---|
| **Set Builder** | `{t \| P(t)}` | All tuples t where P(t) is true |
| **Existential** | `∃` | "there exists" |
| **Universal** | `∀` | "for all" |
| **Member** | `∈` | "is a member of" |
| **AND** | `∧` | Conjunction (all must be true) |
| **OR** | `∨` | Disjunction (at least one true) |
| **NOT** | `¬` | Negation |
| **Comparison** | `=, ≠, <, >, ≤, ≥` | Relations |
| **Concatenate** | `\|\|` | String concatenation |

---

## **KEY DIFFERENCES: TRC vs SQL**

| Aspect | TRC | SQL |
|---|---|---|
| **Nature** | Declarative, Logical | Declarative, but procedural hints |
| **Quantifiers** | Explicit ∃, ∀ | Implicit in WHERE clauses |
| **Negation** | Explicit ¬ | NOT keyword |
| **Aggregates** | Extended notation | Built-in functions |
| **Expression** | Mathematical | English-like |
| **Join** | Implicit via conditions | Explicit JOIN keywords |

---

## **LEARNING OUTCOMES**

After studying these TRC queries, you understand:
✅ How to express database queries using formal logic
✅ Difference between existential and universal quantifiers
✅ How TRC maps to SQL queries
✅ Power of negation and complex logical conditions
✅ How to reason about data formally

---

**This module provides theoretical foundation for understanding query languages and optimization.**

