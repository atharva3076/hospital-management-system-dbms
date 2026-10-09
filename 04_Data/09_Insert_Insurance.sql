-- ============================================================
-- File    : 09_Insert_Insurance.sql
-- Project : Hospital Management System (HMS)
-- Phase   : 3 - Data Population (Member 4)
-- Purpose : Insert 80 insurance policies (every patient whose
--           PatientID is NOT a multiple of 5)
-- Depends : 03_Insert_Patients.sql (08_Insert_Billing.sql uses the
--           same coverage formula, so both stay consistent)
--
-- Provider names are FICTIONAL. Policy start < end (valid dates).
-- ============================================================

USE hospital_management_system;

INSERT INTO INSURANCE
 (PatientID, ProviderName, PolicyNumber, PolicyType, CoveragePercentage, MaxCoverageAmount,
  PolicyStartDate, PolicyEndDate, PremiumAmount, ContactPhone, Status)
SELECT
    p.PatientID,
    ELT(1 + MOD(p.PatientID,6), 'SecureLife Health', 'CarePlus Insurance', 'Shield Health Assurance',
                                'MediSure General', 'Unity Health Insurance', 'National Health Scheme'),
    CONCAT('POL-2026-', LPAD(p.PatientID, 5, '0')),
    ELT(1 + MOD(p.PatientID,3), 'Individual', 'Family Floater', 'Senior Citizen'),
    CAST(ELT(1 + MOD(p.PatientID,4), 50, 70, 80, 90) AS DECIMAL(5,2)),
    CAST(ELT(1 + MOD(p.PatientID,4), 200000, 300000, 500000, 1000000) AS DECIMAL(12,2)),
    DATE_SUB(CURDATE(), INTERVAL (30 + MOD(p.PatientID * 11, 300)) DAY),
    DATE_ADD(CURDATE(), INTERVAL (60 + MOD(p.PatientID * 13, 300)) DAY),
    CAST(ELT(1 + MOD(p.PatientID,4), 8000, 12000, 18000, 30000) AS DECIMAL(10,2)),
    CONCAT('1800', LPAD(100000 + p.PatientID, 6, '0')),
    'Active'
FROM PATIENT p
WHERE MOD(p.PatientID, 5) <> 0
ORDER BY p.PatientID;

-- Verification
SELECT COUNT(*) AS policies_inserted FROM INSURANCE;                                      -- Expected: 80
SELECT COUNT(*) AS invalid_dates FROM INSURANCE WHERE PolicyStartDate >= PolicyEndDate;   -- Expected: 0
SELECT ProviderName, COUNT(*) AS policies FROM INSURANCE GROUP BY ProviderName;
