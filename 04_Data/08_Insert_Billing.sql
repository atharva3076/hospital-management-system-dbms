-- ============================================================
-- File    : 08_Insert_Billing.sql
-- Project : Hospital Management System (HMS)
-- Phase   : 3 - Data Population (Member 4)
-- Purpose : Generate one bill for each Scheduled appointment (108)
-- Depends : 04_Insert_Appointments.sql (and DOCTOR fees)
--
-- Business rules respected:
--   Subtotal      = ConsultationFee + LabTestFee + MedicineCost + OtherCharges - Discount
--   TaxAmount     = 5 % of Subtotal
--   TotalAmount   = Subtotal + TaxAmount
--   InsuranceCoverageAmount = Total x Coverage %   (0 for patients with no insurance)
--   PatientPayable= Total - InsuranceCoverageAmount
--   AmountPaid    <= PatientPayable  (Paid = full, Partial = half, Unpaid = 0)
--
-- Coverage % uses the SAME formula as 09_Insert_Insurance.sql
-- (patients whose PatientID is a multiple of 5 have no insurance).
-- ============================================================

USE hospital_management_system;

INSERT INTO BILLING
 (PatientID, AppointmentID, ConsultationFee, LabTestFee, MedicineCost, OtherCharges, Discount, TaxAmount,
  TotalAmount, AmountPaid, PatientPayable, PaymentStatus, PaymentMethod, InsuranceCoverageAmount,
  BillingDate, DueDate, PaymentDate)
WITH base AS (
    SELECT
        a.AppointmentID,
        a.PatientID,
        a.AppointmentDate,
        d.ConsultationFee                                                              AS cfee,
        CAST(ELT(1 + MOD(a.AppointmentID,4), 0, 350, 600, 1200)       AS DECIMAL(10,2)) AS lab,
        CAST(ELT(1 + MOD(a.AppointmentID,5), 0, 150, 420, 800, 260)   AS DECIMAL(10,2)) AS med,
        CAST(ELT(1 + MOD(a.AppointmentID,3), 0, 50, 100)              AS DECIMAL(10,2)) AS other,
        CAST(ELT(1 + MOD(a.AppointmentID,6), 0, 0, 0, 0, 100, 200)    AS DECIMAL(10,2)) AS disc,
        IF(MOD(a.PatientID,5) = 0, 0,
           CAST(ELT(1 + MOD(a.PatientID,4), 50, 70, 80, 90) AS DECIMAL(5,2)))          AS cov,
        ELT(1 + MOD(a.AppointmentID,3), 'Paid', 'Partial', 'Unpaid')                    AS pstatus,
        ELT(1 + MOD(a.AppointmentID,4), 'Cash', 'Card', 'UPI', 'Net Banking')           AS pmethod
    FROM APPOINTMENT a
    JOIN DOCTOR d ON d.DoctorID = a.DoctorID
    WHERE a.Status = 'Scheduled'
),
calc AS (
    SELECT b.*,
           (b.cfee + b.lab + b.med + b.other - b.disc)                       AS sub,
           ROUND((b.cfee + b.lab + b.med + b.other - b.disc) * 0.05, 2)      AS tax
    FROM base b
),
tot AS (
    SELECT c.*,
           (c.sub + c.tax)                              AS total,
           ROUND((c.sub + c.tax) * c.cov / 100, 2)      AS ins
    FROM calc c
),
fin AS (
    SELECT t.*, (t.total - t.ins) AS pay
    FROM tot t
)
SELECT
    f.PatientID,
    f.AppointmentID,
    f.cfee,
    f.lab,
    f.med,
    f.other,
    f.disc,
    f.tax,
    f.total,
    CASE f.pstatus WHEN 'Paid' THEN f.pay WHEN 'Partial' THEN ROUND(f.pay / 2, 2) ELSE 0 END AS AmountPaid,
    f.pay,
    f.pstatus,
    f.pmethod,
    f.ins,
    f.AppointmentDate,
    DATE_ADD(f.AppointmentDate, INTERVAL 15 DAY),
    IF(f.pstatus = 'Unpaid', NULL, f.AppointmentDate)
FROM fin f
ORDER BY f.AppointmentID;

-- Verification
SELECT COUNT(*) AS bills_inserted FROM BILLING;                                   -- Expected: 108
SELECT PaymentStatus, COUNT(*) AS bills, ROUND(SUM(TotalAmount),2) AS total_amount FROM BILLING GROUP BY PaymentStatus;
SELECT COUNT(*) AS invalid_totals FROM BILLING
 WHERE ROUND(ConsultationFee + LabTestFee + MedicineCost + OtherCharges - Discount + TaxAmount, 2) <> TotalAmount;  -- Expected: 0
SELECT COUNT(*) AS overpaid FROM BILLING WHERE AmountPaid > PatientPayable;       -- Expected: 0
