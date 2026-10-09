# Complex Queries - Hospital Management System

**Owner:** Project Team (Members 1-5)
**Branch:** `final-reports`
**Database:** MySQL 8.0+ (`hospital_management_system`)
**Purpose:** Advanced SQL queries demonstrating relational concepts

---

## 1. Advanced JOIN Operations

### Query 1: Complete Appointment Details with Multi-Table Join

```sql
-- Get appointment with all related information
SELECT 
    A.AppointmentID,
    A.AppointmentDate,
    A.AppointmentTime,
    P.FirstName AS PatientFirstName,
    P.LastName AS PatientLastName,
    P.Phone AS PatientPhone,
    D.FirstName AS DoctorFirstName,
    D.LastName AS DoctorLastName,
    D.Specialization,
    DP.DeptName,
    A.ReasonForVisit,
    A.Status,
    A.EstimatedDuration,
    B.TotalAmount,
    B.PaymentStatus
FROM APPOINTMENT A
INNER JOIN PATIENT P ON A.PatientID = P.PatientID
INNER JOIN DOCTOR D ON A.DoctorID = D.DoctorID
INNER JOIN DEPARTMENT DP ON D.DepartmentID = DP.DepartmentID
LEFT JOIN BILLING B ON A.AppointmentID = B.AppointmentID
WHERE A.AppointmentDate >= CURDATE()
ORDER BY A.AppointmentDate, A.AppointmentTime;

-- Result: 5 tables, all future appointments with complete context
```

### Query 2: Doctor Performance Analysis

```sql
SELECT 
    D.DoctorID,
    D.FirstName,
    D.LastName,
    D.Specialization,
    DP.DeptName,
    COUNT(DISTINCT A.AppointmentID) AS TotalAppointments,
    COUNT(DISTINCT CASE WHEN A.Status = 'Completed' THEN A.AppointmentID END) AS CompletedAppointments,
    ROUND(100.0 * COUNT(DISTINCT CASE WHEN A.Status = 'Completed' THEN A.AppointmentID END) / 
          NULLIF(COUNT(DISTINCT A.AppointmentID), 0), 2) AS CompletionRate,
    COUNT(DISTINCT A.PatientID) AS UniquePatients,
    ROUND(AVG(D.ConsultationFee), 2) AS AvgConsultationFee,
    ROUND(SUM(B.TotalAmount), 2) AS TotalRevenue,
    ROUND(AVG(B.TotalAmount), 2) AS AvgBillAmount
FROM DOCTOR D
LEFT JOIN DEPARTMENT DP ON D.DepartmentID = DP.DepartmentID
LEFT JOIN APPOINTMENT A ON D.DoctorID = A.DoctorID
LEFT JOIN BILLING B ON A.AppointmentID = B.AppointmentID
WHERE D.IsActive = TRUE
GROUP BY D.DoctorID, D.FirstName, D.LastName, D.Specialization, DP.DeptName
HAVING COUNT(DISTINCT A.AppointmentID) > 0
ORDER BY TotalRevenue DESC;

-- Result: Doctor performance metrics
```

---

## 2. Subqueries and Correlated Subqueries

### Query 3: Patients with Above-Average Billing

```sql
SELECT 
    P.PatientID,
    P.FirstName,
    P.LastName,
    P.Phone,
    COUNT(B.BillingID) AS AppointmentCount,
    ROUND(SUM(B.TotalAmount), 2) AS TotalBilled,
    ROUND(AVG(B.TotalAmount), 2) AS AvgBillAmount
FROM PATIENT P
INNER JOIN BILLING B ON P.PatientID = B.PatientID
WHERE B.TotalAmount > (
    -- Subquery: Calculate average billing amount
    SELECT AVG(TotalAmount) FROM BILLING
)
GROUP BY P.PatientID, P.FirstName, P.LastName, P.Phone
HAVING COUNT(B.BillingID) > 0
ORDER BY TotalBilled DESC;

-- Result: Patients spending above average
```

### Query 4: Doctors Without Recent Appointments

```sql
SELECT 
    D.DoctorID,
    D.FirstName,
    D.LastName,
    D.Specialization,
    DP.DeptName,
    D.ConsultationFee
FROM DOCTOR D
LEFT JOIN DEPARTMENT DP ON D.DepartmentID = DP.DepartmentID
WHERE D.IsActive = TRUE
AND NOT EXISTS (
    -- Correlated subquery: Check if doctor has recent appointments
    SELECT 1 FROM APPOINTMENT A 
    WHERE A.DoctorID = D.DoctorID 
    AND A.AppointmentDate >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
)
ORDER BY D.LastName, D.FirstName;

-- Result: Inactive or underutilized doctors
```

### Query 5: Medicines with Usage Statistics

```sql
SELECT 
    M.MedicineID,
    M.MedicineName,
    M.GenericName,
    MF.ManufacturerName,
    M.UnitPrice,
    M.QuantityInStock,
    M.ReorderLevel,
    (
        SELECT COUNT(*) FROM PRESCRIPTION_ITEMS PI 
        WHERE PI.MedicineID = M.MedicineID
    ) AS TimesPrescribed,
    (
        SELECT SUM(PI.Quantity) FROM PRESCRIPTION_ITEMS PI 
        WHERE PI.MedicineID = M.MedicineID
    ) AS TotalQuantityPrescribed,
    CASE 
        WHEN M.QuantityInStock < M.ReorderLevel THEN 'REORDER'
        WHEN M.ExpiryDate < DATE_ADD(CURDATE(), INTERVAL 30 DAY) THEN 'EXPIRING_SOON'
        ELSE 'OK'
    END AS Status
FROM MEDICINE M
LEFT JOIN MANUFACTURER MF ON M.ManufacturerID = MF.ManufacturerID
ORDER BY TimesPrescribed DESC;

-- Result: Medicine usage and inventory status
```

---

## 3. Aggregation and Window Functions

### Query 6: Billing Analysis by Payment Status

```sql
SELECT 
    PaymentStatus,
    COUNT(*) AS BillCount,
    ROUND(SUM(TotalAmount), 2) AS TotalAmount,
    ROUND(AVG(TotalAmount), 2) AS AvgAmount,
    MIN(TotalAmount) AS MinAmount,
    MAX(TotalAmount) AS MaxAmount,
    ROUND(STDDEV(TotalAmount), 2) AS StdDev,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM BILLING), 2) AS PercentageOfTotal
FROM BILLING
GROUP BY PaymentStatus
ORDER BY TotalAmount DESC;

-- Result: Billing statistics by payment status
```

### Query 7: Monthly Revenue Trend

```sql
SELECT 
    YEAR(BillingDate) AS Year,
    MONTH(BillingDate) AS Month,
    DATE_FORMAT(BillingDate, '%Y-%m') AS YearMonth,
    COUNT(*) AS BillCount,
    ROUND(SUM(CASE WHEN PaymentStatus = 'Paid' THEN TotalAmount ELSE 0 END), 2) AS PaidAmount,
    ROUND(SUM(CASE WHEN PaymentStatus = 'Partial' THEN TotalAmount ELSE 0 END), 2) AS PartialAmount,
    ROUND(SUM(CASE WHEN PaymentStatus = 'Unpaid' THEN TotalAmount ELSE 0 END), 2) AS UnpaidAmount,
    ROUND(SUM(TotalAmount), 2) AS TotalAmount,
    ROUND(SUM(TotalAmount) OVER (ORDER BY YEAR(BillingDate), MONTH(BillingDate)) / 
          COUNT(*) OVER (ORDER BY YEAR(BillingDate), MONTH(BillingDate)), 2) AS CumulativeAvg
FROM BILLING
GROUP BY YEAR(BillingDate), MONTH(BillingDate), YearMonth
ORDER BY Year DESC, Month DESC;

-- Result: Monthly billing trends and cumulative analysis
```

### Query 8: Appointment Completion Rate by Department

```sql
SELECT 
    DP.DepartmentID,
    DP.DeptName,
    COUNT(*) AS TotalAppointments,
    SUM(CASE WHEN A.Status = 'Scheduled' THEN 1 ELSE 0 END) AS ScheduledCount,
    SUM(CASE WHEN A.Status = 'Completed' THEN 1 ELSE 0 END) AS CompletedCount,
    SUM(CASE WHEN A.Status = 'Cancelled' THEN 1 ELSE 0 END) AS CancelledCount,
    SUM(CASE WHEN A.Status = 'No-Show' THEN 1 ELSE 0 END) AS NoShowCount,
    ROUND(100.0 * SUM(CASE WHEN A.Status = 'Completed' THEN 1 ELSE 0 END) / 
          COUNT(*), 2) AS CompletionRate,
    ROUND(100.0 * SUM(CASE WHEN A.Status = 'Cancelled' THEN 1 ELSE 0 END) / 
          COUNT(*), 2) AS CancellationRate
FROM DEPARTMENT DP
INNER JOIN DOCTOR D ON DP.DepartmentID = D.DepartmentID
INNER JOIN APPOINTMENT A ON D.DoctorID = A.DoctorID
GROUP BY DP.DepartmentID, DP.DeptName
ORDER BY CompletionRate DESC;

-- Result: Department performance metrics
```

---

## 4. Set Operations (UNION, EXCEPT, INTERSECT)

### Query 9: All People in System (Doctors and Patients)

```sql
SELECT 
    'Doctor' AS PersonType,
    DoctorID AS PersonID,
    FirstName,
    LastName,
    Phone,
    Email,
    NULL AS BloodGroup
FROM DOCTOR
WHERE IsActive = TRUE

UNION ALL

SELECT 
    'Patient' AS PersonType,
    PatientID AS PersonID,
    FirstName,
    LastName,
    Phone,
    Email,
    BloodGroup
FROM PATIENT

ORDER BY PersonType, LastName, FirstName;

-- Result: Unified contact list of all people
```

### Query 10: Doctors Who Are Also Billing Records (unusual but possible)

```sql
-- Doctors who have prescribed AND billed (unusual scenario)
SELECT D.* FROM DOCTOR D
WHERE EXISTS (
    SELECT 1 FROM APPOINTMENT A 
    WHERE A.DoctorID = D.DoctorID
)
INTERSECT
SELECT D.* FROM DOCTOR D
WHERE EXISTS (
    SELECT 1 FROM BILLING B
    JOIN APPOINTMENT A ON B.AppointmentID = A.AppointmentID
    WHERE A.DoctorID = D.DoctorID
);

-- Result: Intersection of two sets
```

---

## 5. Recursive Queries and Hierarchy

### Query 11: Patient's Complete Medical Timeline

```sql
WITH RECURSIVE MedicalTimeline AS (
    -- Base case: Get all medical history for patient
    SELECT 
        MH.HistoryID,
        MH.PatientID,
        MH.Diagnosis,
        MH.Symptoms,
        MH.Treatment,
        MH.DiagnosisDate,
        MH.Status,
        MH.CreatedDate,
        1 AS Level,
        CAST(MH.HistoryID AS CHAR(20)) AS Path
    FROM MEDICAL_HISTORY MH
    WHERE MH.PatientID = 1
    
    UNION ALL
    
    -- Recursive case: (simplified for medical records)
    SELECT 
        MH.HistoryID,
        MH.PatientID,
        MH.Diagnosis,
        MH.Symptoms,
        MH.Treatment,
        MH.DiagnosisDate,
        MH.Status,
        MH.CreatedDate,
        MT.Level + 1,
        CONCAT(MT.Path, '->', MH.HistoryID)
    FROM MedicalTimeline MT
    JOIN MEDICAL_HISTORY MH ON MT.PatientID = MH.PatientID
    WHERE MH.CreatedDate > MT.CreatedDate
    AND MT.Level < 10  -- Prevent infinite recursion
)
SELECT * FROM MedicalTimeline
ORDER BY DiagnosisDate DESC, Level;

-- Result: Hierarchical medical history for a patient
```

---

## 6. Complex Filtering and Case Statements

### Query 12: Patient Risk Assessment

```sql
SELECT 
    P.PatientID,
    P.FirstName,
    P.LastName,
    P.DateOfBirth,
    YEAR(CURDATE()) - YEAR(P.DateOfBirth) AS Age,
    COUNT(DISTINCT MH.HistoryID) AS DiagnosisCount,
    COUNT(DISTINCT A.AppointmentID) AS AppointmentCount,
    COUNT(DISTINCT B.BillingID) AS BillingCount,
    ROUND(SUM(B.TotalAmount), 2) AS TotalBilled,
    CASE 
        WHEN COUNT(DISTINCT MH.HistoryID) >= 5 THEN 'HIGH_RISK'
        WHEN COUNT(DISTINCT MH.HistoryID) >= 3 THEN 'MEDIUM_RISK'
        WHEN COUNT(DISTINCT MH.HistoryID) >= 1 THEN 'LOW_RISK'
        ELSE 'NO_RISK'
    END AS HealthRisk,
    CASE 
        WHEN ROUND(SUM(B.TotalAmount), 2) > 50000 THEN 'HIGH_COST'
        WHEN ROUND(SUM(B.TotalAmount), 2) > 20000 THEN 'MEDIUM_COST'
        WHEN ROUND(SUM(B.TotalAmount), 2) > 5000 THEN 'LOW_COST'
        ELSE 'MINIMAL_COST'
    END AS CostCategory,
    CASE 
        WHEN EXISTS (SELECT 1 FROM INSURANCE I WHERE I.PatientID = P.PatientID AND I.IsActive = TRUE) 
            THEN 'INSURED' ELSE 'UNINSURED' 
    END AS InsuranceStatus,
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM BILLING B2 
            WHERE B2.PatientID = P.PatientID 
            AND B2.PaymentStatus IN ('Unpaid', 'Partial')
        ) THEN 'HAS_OVERDUE' ELSE 'NO_OVERDUE' 
    END AS PaymentStatus
FROM PATIENT P
LEFT JOIN MEDICAL_HISTORY MH ON P.PatientID = MH.PatientID
LEFT JOIN APPOINTMENT A ON P.PatientID = A.PatientID
LEFT JOIN BILLING B ON A.AppointmentID = B.AppointmentID
GROUP BY P.PatientID, P.FirstName, P.LastName, P.DateOfBirth
ORDER BY TotalBilled DESC;

-- Result: Comprehensive patient risk and cost profile
```

---

## 7. Pivot-style Queries

### Query 13: Appointment Status Cross-tabulation

```sql
SELECT 
    YEAR(A.AppointmentDate) AS Year,
    MONTH(A.AppointmentDate) AS Month,
    SUM(CASE WHEN A.Status = 'Scheduled' THEN 1 ELSE 0 END) AS Scheduled,
    SUM(CASE WHEN A.Status = 'Completed' THEN 1 ELSE 0 END) AS Completed,
    SUM(CASE WHEN A.Status = 'Cancelled' THEN 1 ELSE 0 END) AS Cancelled,
    SUM(CASE WHEN A.Status = 'No-Show' THEN 1 ELSE 0 END) AS NoShow,
    SUM(CASE WHEN A.Status = 'Rescheduled' THEN 1 ELSE 0 END) AS Rescheduled,
    COUNT(*) AS Total
FROM APPOINTMENT A
WHERE A.AppointmentDate >= DATE_SUB(CURDATE(), INTERVAL 12 MONTH)
GROUP BY YEAR(A.AppointmentDate), MONTH(A.AppointmentDate)
ORDER BY Year DESC, Month DESC;

-- Result: Appointment status by month (pivot format)
```

### Query 14: Medicine Category Inventory

```sql
SELECT 
    M.Category,
    COUNT(*) AS MedicineCount,
    ROUND(SUM(M.QuantityInStock), 0) AS TotalStock,
    ROUND(SUM(M.QuantityInStock * M.UnitPrice), 2) AS InventoryValue,
    ROUND(AVG(M.UnitPrice), 2) AS AvgPrice,
    SUM(CASE WHEN M.QuantityInStock < M.ReorderLevel THEN 1 ELSE 0 END) AS LowStockCount,
    SUM(CASE WHEN M.ExpiryDate < CURDATE() THEN 1 ELSE 0 END) AS ExpiredCount,
    SUM(CASE WHEN M.ExpiryDate < DATE_ADD(CURDATE(), INTERVAL 30 DAY) THEN 1 ELSE 0 END) AS ExpiringCount
FROM MEDICINE M
GROUP BY M.Category
ORDER BY InventoryValue DESC;

-- Result: Inventory status by medicine category
```

---

## 8. Data Quality and Integrity Checks

### Query 15: Data Consistency Validation

```sql
-- Check for orphaned records and inconsistencies
SELECT 
    'Orphaned Appointments' AS IssueType,
    COUNT(*) AS Count,
    'Delete appointments with no matching patient or doctor' AS Action
FROM APPOINTMENT A
WHERE A.PatientID NOT IN (SELECT PatientID FROM PATIENT)
   OR A.DoctorID NOT IN (SELECT DoctorID FROM DOCTOR)

UNION ALL

SELECT 
    'Orphaned Prescriptions',
    COUNT(*),
    'Fix foreign key references'
FROM PRESCRIPTION P
WHERE P.DoctorID NOT IN (SELECT DoctorID FROM DOCTOR)

UNION ALL

SELECT 
    'Orphaned Billing',
    COUNT(*),
    'Link billing to valid appointments'
FROM BILLING B
WHERE B.AppointmentID NOT IN (SELECT AppointmentID FROM APPOINTMENT)

UNION ALL

SELECT 
    'Invalid Patient Age',
    COUNT(*),
    'Update date of birth to valid value'
FROM PATIENT
WHERE DateOfBirth > CURDATE()

UNION ALL

SELECT 
    'Duplicate Doctor Emails',
    COUNT(*),
    'Merge or remove duplicate records'
FROM (
    SELECT Email, COUNT(*) as cnt 
    FROM DOCTOR 
    WHERE Email IS NOT NULL 
    GROUP BY Email 
    HAVING cnt > 1
) DuplicateEmails;

-- Result: Data quality issues requiring attention
```

---

## 9. Export and Reporting Queries

### Query 16: Monthly Billing Report for Auditing

```sql
SELECT 
    DATE_FORMAT(B.BillingDate, '%Y-%m') AS Month,
    B.BillingNumber,
    P.FirstName,
    P.LastName,
    D.FirstName AS DoctorName,
    DP.DeptName,
    B.ConsultationFee,
    B.LabTestFee,
    B.MedicineCost,
    B.OtherCharges,
    B.Discount,
    B.TaxAmount,
    B.TotalAmount,
    B.AmountPaid,
    B.PatientPayable,
    B.PaymentStatus,
    B.PaymentMethod,
    COALESCE(I.CoveragePercentage, 0) AS InsuranceCoverage,
    B.InsuranceCoverageAmount,
    DATEDIFF(CURDATE(), B.DueDate) AS DaysOverdue
FROM BILLING B
INNER JOIN PATIENT P ON B.PatientID = P.PatientID
INNER JOIN APPOINTMENT A ON B.AppointmentID = A.AppointmentID
INNER JOIN DOCTOR D ON A.DoctorID = D.DoctorID
INNER JOIN DEPARTMENT DP ON D.DepartmentID = DP.DepartmentID
LEFT JOIN INSURANCE I ON B.PatientID = I.PatientID
WHERE B.BillingDate >= DATE_SUB(CURDATE(), INTERVAL 3 MONTH)
ORDER BY B.BillingDate DESC, B.BillingNumber;

-- Result: Audit-ready billing report with all details
```

---

## 10. Performance-Critical Queries

### Query 17: Insurance Claims Processing

```sql
-- Optimized query for batch claims processing
SELECT 
    B.BillingID,
    B.BillingNumber,
    B.PatientID,
    P.FirstName,
    P.LastName,
    I.InsuranceID,
    I.InsuranceProvider,
    I.PolicyNumber,
    B.TotalAmount,
    I.CoveragePercentage,
    ROUND(B.TotalAmount * I.CoveragePercentage / 100, 2) AS ClaimAmount,
    B.PaymentStatus,
    CASE 
        WHEN B.PaymentStatus = 'Paid' THEN 'PROCESSED'
        WHEN B.PaymentStatus = 'Partial' THEN 'PENDING'
        ELSE 'NEW'
    END AS ClaimStatus
FROM BILLING B
INNER JOIN PATIENT P ON B.PatientID = P.PatientID
INNER JOIN INSURANCE I ON B.PatientID = I.PatientID AND I.IsActive = TRUE
WHERE B.BillingDate >= DATE_SUB(CURDATE(), INTERVAL 60 DAY)
  AND B.InsuranceCoverageAmount = 0  -- Not yet claimed
ORDER BY B.BillingDate;

-- Result: Claims ready for processing
```

---

## Summary

These 17 complex queries demonstrate:

✓ Multi-table JOINs (8 tables)
✓ Correlated subqueries
✓ Window functions and aggregations
✓ Set operations (UNION, INTERSECT)
✓ Recursive CTEs
✓ Case-statement logic
✓ Pivot-style analysis
✓ Data quality validation
✓ Reporting and export
✓ Performance optimization

**Use Cases:** Analytics, reporting, auditing, data validation, business intelligence
