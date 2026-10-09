-- ============================================================
-- File    : 04_Insert_Appointments.sql
-- Project : Hospital Management System (HMS)
-- Phase   : 3 - Data Population (Member 4)
-- Purpose : Insert 120 appointments over the next 30 days
--           (108 Scheduled + 12 Cancelled)
-- Depends : 03_Insert_Patients.sql
--
-- IMPORTANT: The schema enforces AppointmentDate >= CURDATE(),
-- so all dates are generated RELATIVE to today (CURDATE() + 1..30 days).
-- This keeps the script valid no matter when it is executed.
--
-- No double booking: (PatientID, DoctorID, AppointmentDate, AppointmentTime)
-- is unique for every generated row (the cycle length is 1200 > 120 rows).
-- ============================================================

USE hospital_management_system;

INSERT INTO APPOINTMENT
 (PatientID, DoctorID, AppointmentDate, AppointmentTime, ReasonForVisit, Status,
  CancelledDate, CancellationReason, EstimatedDuration, RoomNumber)
WITH RECURSIVE seq AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM seq WHERE n < 120
)
SELECT
    1 + MOD(n * 7, 100)                                         AS PatientID,
    1 + MOD(n, 20)                                              AS DoctorID,
    DATE_ADD(CURDATE(), INTERVAL (1 + MOD(n, 30)) DAY)          AS AppointmentDate,
    SEC_TO_TIME(32400 + MOD(n, 16) * 1800)                      AS AppointmentTime,   -- 09:00 to 16:30
    ELT(1 + MOD(n,10), 'Routine check-up','Follow-up consultation','Chest pain evaluation','Fever and body ache',
                       'Persistent headache','Joint pain','Skin rash','Child vaccination review',
                       'Diabetes monitoring','Eye examination')   AS ReasonForVisit,
    IF(MOD(n,10) = 0, 'Cancelled', 'Scheduled')                 AS Status,
    IF(MOD(n,10) = 0, CURDATE(), NULL)                          AS CancelledDate,
    IF(MOD(n,10) = 0, 'Patient requested cancellation', NULL)   AS CancellationReason,
    ELT(1 + MOD(n,3), 15, 20, 30)                               AS EstimatedDuration,
    CONCAT('R', 100 + 1 + MOD(n, 20))                           AS RoomNumber
FROM seq
ORDER BY n;

-- Verification
SELECT COUNT(*) AS appointments_inserted FROM APPOINTMENT;                         -- Expected: 120
SELECT Status, COUNT(*) AS total FROM APPOINTMENT GROUP BY Status;                 -- Scheduled 108, Cancelled 12
SELECT MIN(AppointmentDate) AS first_date, MAX(AppointmentDate) AS last_date FROM APPOINTMENT;
