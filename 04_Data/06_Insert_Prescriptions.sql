-- ============================================================
-- File    : 06_Insert_Prescriptions.sql
-- Project : Hospital Management System (HMS)
-- Phase   : 3 - Data Population (Member 4)
-- Purpose : Create one prescription for every Scheduled
--           appointment (108) with 2 medicines each (216 items)
-- Depends : 04_Insert_Appointments.sql, 05_Insert_Medications.sql
--
-- Data is derived from APPOINTMENT with INSERT ... SELECT, so
-- patient/doctor/appointment links are always consistent.
-- Prescription expiry = prescription date + 30 days (> creation date).
-- ============================================================

USE hospital_management_system;

-- ------------------------------------------------------------
-- PRESCRIPTION (one per Scheduled appointment)
-- ------------------------------------------------------------
INSERT INTO PRESCRIPTION
 (PatientID, DoctorID, AppointmentID, PrescriptionDate, ExpiryDate, Diagnosis, Notes, Status)
SELECT
    a.PatientID,
    a.DoctorID,
    a.AppointmentID,
    a.AppointmentDate,
    DATE_ADD(a.AppointmentDate, INTERVAL 30 DAY),
    ELT(1 + MOD(a.AppointmentID,10), 'Viral fever','Hypertension','Type 2 diabetes','Gastritis','Seasonal allergy',
                                     'Bacterial infection','Joint inflammation','Migraine','Vitamin deficiency','Bronchitis'),
    ELT(1 + MOD(a.AppointmentID,4),  'Take medicines after food','Drink plenty of water','Review after one week','Avoid cold beverages'),
    'Active'
FROM APPOINTMENT a
WHERE a.Status = 'Scheduled'
ORDER BY a.AppointmentID;

-- ------------------------------------------------------------
-- PRESCRIPTION_ITEMS (2 distinct medicines per prescription)
-- offset 0 and 13 guarantee the two MedicineIDs always differ
-- ------------------------------------------------------------
INSERT INTO PRESCRIPTION_ITEMS
 (PrescriptionID, MedicineID, Dosage, Frequency, DurationDays, Quantity, Instructions)
SELECT
    p.PrescriptionID,
    1 + MOD(p.PrescriptionID + o.offset_val, 30)                                                   AS MedicineID,
    ELT(1 + MOD(p.PrescriptionID,3), '1 tablet','1 capsule','2 tablets')                          AS Dosage,
    ELT(1 + MOD(p.PrescriptionID,3), 'Once daily','Twice daily','Thrice daily')                   AS Frequency,
    CAST(ELT(1 + MOD(p.PrescriptionID,4), 5, 7, 10, 14) AS UNSIGNED)                              AS DurationDays,
    (1 + MOD(p.PrescriptionID,3)) * CAST(ELT(1 + MOD(p.PrescriptionID,4), 5, 7, 10, 14) AS UNSIGNED) AS Quantity,
    ELT(1 + MOD(p.PrescriptionID,3), 'After meals','Before meals','At bedtime')                    AS Instructions
FROM PRESCRIPTION p
CROSS JOIN (SELECT 0 AS offset_val UNION ALL SELECT 13) o
ORDER BY p.PrescriptionID, o.offset_val;

-- Verification
SELECT COUNT(*) AS prescriptions_inserted FROM PRESCRIPTION;         -- Expected: 108
SELECT COUNT(*) AS items_inserted         FROM PRESCRIPTION_ITEMS;   -- Expected: 216
SELECT PrescriptionID, COUNT(*) AS meds FROM PRESCRIPTION_ITEMS GROUP BY PrescriptionID HAVING meds <> 2;  -- Expected: empty
