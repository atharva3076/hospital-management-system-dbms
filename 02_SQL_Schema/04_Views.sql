-- ============================================================================
-- HOSPITAL MANAGEMENT SYSTEM - VIEWS CREATION
-- Member 2: SQL Schema Developer
-- ============================================================================
-- Purpose: Create 12+ views for role-based access and simplified data retrieval
-- Views provide: Security, Abstraction, Simplified Queries, Performance
-- ============================================================================

USE hospital_management_system;

-- ============================================================================
-- VIEW 1: v_doctor_details
-- Purpose: Complete doctor information with department details
-- Users: Admin, Doctors, HR
-- ============================================================================

CREATE VIEW v_doctor_details AS
SELECT 
    d.DoctorID,
    CONCAT(d.FirstName, ' ', d.LastName) as DoctorName,
    d.Email,
    d.Phone,
    d.Qualification,
    d.Specialization,
    d.YearsOfExperience,
    d.ConsultationFee,
    d.AvailabilityStatus,
    d.LicenseNumber,
    dept.DeptName as Department,
    dept.Floor,
    dept.Building,
    d.IsActive,
    d.CreatedDate,
    d.LastModifiedDate
FROM DOCTOR d
LEFT JOIN DEPARTMENT dept ON d.DepartmentID = dept.DepartmentID
ORDER BY d.LastName, d.FirstName;

-- ============================================================================
-- VIEW 2: v_doctor_patient_appointments
-- Purpose: All appointments with doctor and patient details
-- Users: Doctors, Nurses, Admin
-- ============================================================================

CREATE VIEW v_doctor_patient_appointments AS
SELECT 
    a.AppointmentID,
    a.AppointmentDate,
    a.AppointmentTime,
    CONCAT(d.FirstName, ' ', d.LastName) as DoctorName,
    d.Specialization,
    CONCAT(p.FirstName, ' ', p.LastName) as PatientName,
    p.Phone as PatientPhone,
    p.BloodGroup,
    a.ReasonForVisit,
    a.Status,
    a.ConsultationNotes,
    a.RoomNumber,
    d.DoctorID,
    p.PatientID,
    a.EstimatedDuration
FROM APPOINTMENT a
JOIN DOCTOR d ON a.DoctorID = d.DoctorID
JOIN PATIENT p ON a.PatientID = p.PatientID
ORDER BY a.AppointmentDate DESC, a.AppointmentTime DESC;

-- ============================================================================
-- VIEW 3: v_patient_medical_history
-- Purpose: Complete patient medical history with doctor information
-- Users: Patients, Doctors, Nurses
-- ============================================================================

CREATE VIEW v_patient_medical_history AS
SELECT 
    h.HistoryID,
    p.PatientID,
    CONCAT(p.FirstName, ' ', p.LastName) as PatientName,
    h.Diagnosis,
    h.Symptoms,
    h.TreatmentPlan,
    h.DoctorNotes,
    h.Outcome,
    h.CreatedDate as VisitDate,
    CONCAT(d.FirstName, ' ', d.LastName) as TreatingDoctor,
    d.Specialization
FROM MEDICAL_HISTORY h
JOIN PATIENT p ON h.PatientID = p.PatientID
LEFT JOIN APPOINTMENT a ON h.AppointmentID = a.AppointmentID
LEFT JOIN DOCTOR d ON a.DoctorID = d.DoctorID
ORDER BY h.CreatedDate DESC;

-- ============================================================================
-- VIEW 4: v_appointment_summary
-- Purpose: Overview of all appointments with current status
-- Users: All staff members
-- ============================================================================

CREATE VIEW v_appointment_summary AS
SELECT 
    a.AppointmentID,
    a.AppointmentDate,
    a.AppointmentTime,
    CONCAT(d.FirstName, ' ', d.LastName) as DoctorName,
    CONCAT(p.FirstName, ' ', p.LastName) as PatientName,
    a.ReasonForVisit,
    a.Status,
    a.RoomNumber,
    CASE 
        WHEN a.Status = 'Completed' THEN 'Completed'
        WHEN a.Status = 'Cancelled' THEN 'Cancelled'
        WHEN a.Status = 'No-Show' THEN 'Did Not Arrive'
        WHEN a.Status = 'Scheduled' AND a.AppointmentDate < CURDATE() THEN 'Overdue'
        WHEN a.Status = 'Scheduled' THEN 'Upcoming'
        ELSE 'Unknown'
    END as AppointmentStatus,
    a.CreatedDate,
    a.LastModifiedDate
FROM APPOINTMENT a
JOIN DOCTOR d ON a.DoctorID = d.DoctorID
JOIN PATIENT p ON a.PatientID = p.PatientID
ORDER BY a.AppointmentDate DESC;

-- ============================================================================
-- VIEW 5: v_patient_details
-- Purpose: Complete patient information with contact and health details
-- Users: Nurses, Doctors, Admin
-- ============================================================================

CREATE VIEW v_patient_details AS
SELECT 
    p.PatientID,
    CONCAT(p.FirstName, ' ', p.LastName) as PatientName,
    p.DateOfBirth,
    YEAR(CURDATE()) - YEAR(p.DateOfBirth) as Age,
    p.Gender,
    p.BloodGroup,
    p.Phone,
    p.Email,
    p.Address,
    p.EmergencyContactName,
    p.EmergencyContactPhone,
    p.EmergencyContactRelation,
    p.Allergies,
    p.ChronicDiseases,
    p.PatientStatus,
    p.IsActive,
    p.CreatedDate
FROM PATIENT
ORDER BY p.LastName, p.FirstName;

-- ============================================================================
-- VIEW 6: v_prescription_full_details
-- Purpose: Complete prescription information with medicines
-- Users: Pharmacists, Doctors, Admin
-- ============================================================================

CREATE VIEW v_prescription_full_details AS
SELECT 
    prx.PrescriptionID,
    CONCAT(p.FirstName, ' ', p.LastName) as PatientName,
    p.PatientID,
    CONCAT(d.FirstName, ' ', d.LastName) as DoctorName,
    prx.CreatedDate as PrescriptionDate,
    prx.ExpiryDate,
    prx.Status,
    m.MedicineName,
    pxi.Dosage,
    pxi.Frequency,
    pxi.Duration,
    pxi.Instructions,
    pxi.Quantity,
    m.UnitPrice,
    (pxi.Quantity * m.UnitPrice) as MedicineCost,
    prx.RefillsAllowed,
    prx.RefillsUsed,
    prx.Notes
FROM PRESCRIPTION prx
JOIN PATIENT p ON prx.PatientID = p.PatientID
JOIN DOCTOR d ON prx.DoctorID = d.DoctorID
JOIN PRESCRIPTION_ITEMS pxi ON prx.PrescriptionID = pxi.PrescriptionID
JOIN MEDICINE m ON pxi.MedicineID = m.MedicineID
ORDER BY prx.CreatedDate DESC;

-- ============================================================================
-- VIEW 7: v_lab_results
-- Purpose: Lab test results with patient and test details
-- Users: Lab technicians, Doctors, Patients
-- ============================================================================

CREATE VIEW v_lab_results AS
SELECT 
    lr.ReportID,
    CONCAT(p.FirstName, ' ', p.LastName) as PatientName,
    p.PatientID,
    lt.TestName,
    lt.Unit,
    lr.TestDate,
    lr.ResultValue,
    lt.NormalRange,
    CASE 
        WHEN lr.IsAbnormal = TRUE THEN 'Abnormal'
        WHEN lr.Status = 'Critical' THEN 'Critical'
        WHEN lr.Status = 'Abnormal' THEN 'Abnormal'
        ELSE 'Normal'
    END as ResultStatus,
    lr.LabTechnicianNotes,
    lr.DoctorReview,
    lr.Status as ReportStatus,
    lr.CreatedDate
FROM LAB_REPORT lr
JOIN PATIENT p ON lr.PatientID = p.PatientID
JOIN LAB_TEST lt ON lr.TestID = lt.TestID
ORDER BY lr.TestDate DESC;

-- ============================================================================
-- VIEW 8: v_medicine_inventory
-- Purpose: Current medicine inventory with reorder status
-- Users: Pharmacists, Inventory Manager, Admin
-- ============================================================================

CREATE VIEW v_medicine_inventory AS
SELECT 
    m.MedicineID,
    m.MedicineName,
    m.GenericName,
    m.Type,
    m.Strength,
    m.UnitPrice,
    m.QuantityInStock,
    m.MinimumStock,
    m.ReorderLevel,
    CASE 
        WHEN m.QuantityInStock < m.ReorderLevel THEN 'REORDER NEEDED'
        WHEN m.QuantityInStock < m.MinimumStock THEN 'LOW STOCK'
        WHEN m.ExpiryDate <= DATE_ADD(CURDATE(), INTERVAL 30 DAY) THEN 'EXPIRING SOON'
        ELSE 'OK'
    END as InventoryStatus,
    m.ExpiryDate,
    DATEDIFF(m.ExpiryDate, CURDATE()) as DaysUntilExpiry,
    mfg.MfgName as Manufacturer,
    m.StorageLocation,
    m.IsActive,
    (m.QuantityInStock * m.UnitPrice) as StockValue
FROM MEDICINE m
LEFT JOIN MANUFACTURER mfg ON m.ManufacturerID = mfg.ManufacturerID
ORDER BY m.QuantityInStock ASC;

-- ============================================================================
-- VIEW 9: v_billing_summary
-- Purpose: Billing records with payment status and amounts
-- Users: Finance staff, Admin, Billing department
-- ============================================================================

CREATE VIEW v_billing_summary AS
SELECT 
    b.BillingID,
    CONCAT(p.FirstName, ' ', p.LastName) as PatientName,
    p.PatientID,
    b.BillingDate,
    b.ConsultationFee,
    b.LabTestFee,
    b.MedicineCost,
    b.OtherCharges,
    b.TaxAmount,
    b.TotalAmount,
    b.AmountPaid,
    b.PatientPayable,
    b.PaymentStatus,
    b.PaymentMethod,
    b.DueDate,
    CASE 
        WHEN b.PaymentStatus = 'Paid' THEN 0
        WHEN b.DueDate < CURDATE() AND b.PaymentStatus IN ('Unpaid', 'Partial') THEN DATEDIFF(CURDATE(), b.DueDate)
        ELSE NULL
    END as DaysOverdue,
    b.LastModifiedDate
FROM BILLING b
JOIN PATIENT p ON b.PatientID = p.PatientID
ORDER BY b.BillingDate DESC;

-- ============================================================================
-- VIEW 10: v_overdue_payments
-- Purpose: Find all overdue and unpaid bills
-- Users: Finance staff, Admin
-- ============================================================================

CREATE VIEW v_overdue_payments AS
SELECT 
    b.BillingID,
    CONCAT(p.FirstName, ' ', p.LastName) as PatientName,
    p.PatientID,
    p.Phone,
    p.Email,
    b.TotalAmount,
    b.AmountPaid,
    b.PatientPayable as AmountDue,
    b.PaymentStatus,
    b.DueDate,
    DATEDIFF(CURDATE(), b.DueDate) as DaysOverdue,
    b.BillingDate,
    CONCAT(d.FirstName, ' ', d.LastName) as DoctorName,
    CONCAT('Appointment on ', a.AppointmentDate, ' at ', a.AppointmentTime) as AppointmentInfo
FROM BILLING b
JOIN PATIENT p ON b.PatientID = p.PatientID
JOIN APPOINTMENT a ON b.AppointmentID = a.AppointmentID
JOIN DOCTOR d ON a.DoctorID = d.DoctorID
WHERE (b.PaymentStatus = 'Unpaid' OR b.PaymentStatus = 'Partial')
  AND b.DueDate < CURDATE()
ORDER BY DaysOverdue DESC;

-- ============================================================================
-- VIEW 11: v_doctor_performance
-- Purpose: Doctor performance metrics and appointment statistics
-- Users: Admin, Department heads
-- ============================================================================

CREATE VIEW v_doctor_performance AS
SELECT 
    d.DoctorID,
    CONCAT(d.FirstName, ' ', d.LastName) as DoctorName,
    d.Specialization,
    dept.DeptName as Department,
    COUNT(DISTINCT a.AppointmentID) as TotalAppointments,
    SUM(CASE WHEN a.Status = 'Completed' THEN 1 ELSE 0 END) as CompletedAppointments,
    SUM(CASE WHEN a.Status = 'No-Show' THEN 1 ELSE 0 END) as NoShowAppointments,
    SUM(CASE WHEN a.Status = 'Cancelled' THEN 1 ELSE 0 END) as CancelledAppointments,
    ROUND(
        (SUM(CASE WHEN a.Status = 'Completed' THEN 1 ELSE 0 END) / COUNT(DISTINCT a.AppointmentID)) * 100, 2
    ) as CompletionRate,
    COUNT(DISTINCT prx.PrescriptionID) as PrescriptionsIssued,
    COUNT(DISTINCT mh.HistoryID) as PatientsWithHistory,
    d.ConsultationFee,
    (COUNT(DISTINCT a.AppointmentID) * d.ConsultationFee) as TotalRevenue
FROM DOCTOR d
LEFT JOIN DEPARTMENT dept ON d.DepartmentID = dept.DepartmentID
LEFT JOIN APPOINTMENT a ON d.DoctorID = a.DoctorID
LEFT JOIN PRESCRIPTION prx ON d.DoctorID = prx.DoctorID
LEFT JOIN MEDICAL_HISTORY mh ON a.DoctorID = d.DoctorID
GROUP BY d.DoctorID, d.FirstName, d.LastName, d.Specialization, dept.DeptName, d.ConsultationFee
ORDER BY TotalAppointments DESC;

-- ============================================================================
-- VIEW 12: v_patient_insurance_coverage
-- Purpose: Patient insurance details and coverage information
-- Users: Finance, Admin, Insurance coordinator
-- ============================================================================

CREATE VIEW v_patient_insurance_coverage AS
SELECT 
    i.InsuranceID,
    CONCAT(p.FirstName, ' ', p.LastName) as PatientName,
    p.PatientID,
    i.InsuranceProvider,
    i.PolicyNumber,
    i.PolicyType,
    i.CoveragePercentage as CoveragePercentage,
    i.CoverageLimit,
    i.ValidFromDate,
    i.ValidToDate,
    CASE 
        WHEN i.ValidToDate < CURDATE() THEN 'Expired'
        WHEN i.ValidFromDate > CURDATE() THEN 'Not Started'
        ELSE 'Active'
    END as PolicyStatus,
    i.ClaimsProcessed,
    i.TotalClaimsAmount,
    i.RemainingCoverage,
    i.PreAuthorizationNumber,
    i.CoverageStatus
FROM INSURANCE i
JOIN PATIENT p ON i.PatientID = p.PatientID
ORDER BY i.ValidToDate DESC;

-- ============================================================================
-- VIEW 13: v_department_statistics
-- Purpose: Department-wise statistics and metrics
-- Users: Admin, Department heads
-- ============================================================================

CREATE VIEW v_department_statistics AS
SELECT 
    dept.DepartmentID,
    dept.DeptName as Department,
    dept.Floor,
    COUNT(DISTINCT d.DoctorID) as TotalDoctors,
    COUNT(DISTINCT a.AppointmentID) as TotalAppointments,
    SUM(CASE WHEN a.Status = 'Completed' THEN 1 ELSE 0 END) as CompletedAppointments,
    SUM(CASE WHEN a.Status = 'Scheduled' THEN 1 ELSE 0 END) as ScheduledAppointments,
    COUNT(DISTINCT a.PatientID) as UniquePatients,
    dept.MaxBeds as MaxBedCapacity
FROM DEPARTMENT dept
LEFT JOIN DOCTOR d ON dept.DepartmentID = d.DepartmentID
LEFT JOIN APPOINTMENT a ON d.DoctorID = a.DoctorID
GROUP BY dept.DepartmentID, dept.DeptName, dept.Floor, dept.MaxBeds
ORDER BY TotalAppointments DESC;

-- ============================================================================
-- VIEW 14: v_medicine_expiry_alert
-- Purpose: Medicines expiring soon or already expired
-- Users: Pharmacists, Inventory manager
-- ============================================================================

CREATE VIEW v_medicine_expiry_alert AS
SELECT 
    m.MedicineID,
    m.MedicineName,
    m.GenericName,
    m.Type,
    mfg.MfgName as Manufacturer,
    m.ExpiryDate,
    DATEDIFF(m.ExpiryDate, CURDATE()) as DaysUntilExpiry,
    m.QuantityInStock,
    (m.QuantityInStock * m.UnitPrice) as StockValue,
    CASE 
        WHEN m.ExpiryDate < CURDATE() THEN 'EXPIRED'
        WHEN m.ExpiryDate <= DATE_ADD(CURDATE(), INTERVAL 7 DAY) THEN 'CRITICAL - Expires in 7 days'
        WHEN m.ExpiryDate <= DATE_ADD(CURDATE(), INTERVAL 30 DAY) THEN 'WARNING - Expires in 30 days'
        WHEN m.ExpiryDate <= DATE_ADD(CURDATE(), INTERVAL 60 DAY) THEN 'ALERT - Expires in 60 days'
        ELSE 'OK'
    END as ExpiryStatus,
    m.StorageLocation
FROM MEDICINE m
LEFT JOIN MANUFACTURER mfg ON m.ManufacturerID = mfg.ManufacturerID
WHERE m.ExpiryDate <= DATE_ADD(CURDATE(), INTERVAL 90 DAY)
ORDER BY m.ExpiryDate ASC;

-- ============================================================================
-- ADDITIONAL UTILITY VIEWS
-- ============================================================================

-- VIEW 15: v_today_appointments
-- Purpose: Quick view of today's appointments
-- Users: Front desk, Doctors, Nurses

CREATE VIEW v_today_appointments AS
SELECT 
    a.AppointmentID,
    a.AppointmentTime,
    CONCAT(d.FirstName, ' ', d.LastName) as DoctorName,
    d.Specialization,
    CONCAT(p.FirstName, ' ', p.LastName) as PatientName,
    p.Phone,
    a.ReasonForVisit,
    a.Status,
    a.RoomNumber
FROM APPOINTMENT a
JOIN DOCTOR d ON a.DoctorID = d.DoctorID
JOIN PATIENT p ON a.PatientID = p.PatientID
WHERE a.AppointmentDate = CURDATE()
ORDER BY a.AppointmentTime ASC;

-- ============================================================================
-- VERIFY ALL VIEWS ARE CREATED
-- ============================================================================

SELECT 'All Views Created Successfully!' as Status,
       COUNT(*) as TotalViews
FROM INFORMATION_SCHEMA.VIEWS
WHERE TABLE_SCHEMA = 'hospital_management_system';

-- List all created views
SELECT TABLE_NAME as ViewName
FROM INFORMATION_SCHEMA.VIEWS
WHERE TABLE_SCHEMA = 'hospital_management_system'
ORDER BY TABLE_NAME;

-- ============================================================================
-- VIEW USAGE AND TESTING
-- ============================================================================

-- TEST: Try selecting from each view
-- SELECT * FROM v_doctor_details LIMIT 5;
-- SELECT * FROM v_appointment_summary LIMIT 5;
-- SELECT * FROM v_billing_summary LIMIT 5;
-- SELECT * FROM v_medicine_inventory LIMIT 5;
-- SELECT * FROM v_lab_results LIMIT 5;

-- ============================================================================
-- END OF VIEWS SCRIPT
-- ============================================================================
-- Total Views: 15
-- Features: Role-based access, Simplified queries, Data security
-- ============================================================================