-- ============================================================
-- File    : 02_Insert_Doctors.sql
-- Project : Hospital Management System (HMS)
-- Phase   : 3 - Data Population (Member 4)
-- Purpose : Insert 20 doctors (2 per department) and their
--           weekly schedules (Mon-Fri, 100 rows)
-- Depends : 01_Insert_Departments.sql
-- ============================================================

USE hospital_management_system;

-- ------------------------------------------------------------
-- DOCTORS (DoctorID 1-20; DepartmentID = CEIL(DoctorID / 2))
-- ------------------------------------------------------------
INSERT INTO DOCTOR
 (FirstName, LastName, Qualification, Specialization, DepartmentID, Phone, Email, LicenseNumber, YearsOfExperience, ConsultationFee, AvailabilityStatus, IsActive)
VALUES
('Rajesh',  'Sharma',    'MD, DM (Cardiology)',        'Interventional Cardiology', 1,  '9811000001', 'rajesh.sharma@hms-hospital.example',   'MCI-MP-10001', 18, 1500.00, 'Available', TRUE),
('Anita',   'Verma',     'MD (Medicine), DM',          'Non-Invasive Cardiology',   1,  '9811000002', 'anita.verma@hms-hospital.example',     'MCI-MP-10002', 12, 1200.00, 'Available', TRUE),
('Vikram',  'Singh',     'MD, DM (Neurology)',         'General Neurology',         2,  '9811000003', 'vikram.singh@hms-hospital.example',    'MCI-MP-10003', 15, 1400.00, 'Available', TRUE),
('Sunita',  'Iyer',      'MD, DM (Neurology)',         'Stroke Medicine',           2,  '9811000004', 'sunita.iyer@hms-hospital.example',     'MCI-MP-10004', 10, 1300.00, 'Available', TRUE),
('Amit',    'Patel',     'MS (Orthopedics)',           'Joint Replacement',         3,  '9811000005', 'amit.patel@hms-hospital.example',      'MCI-MP-10005', 20, 1300.00, 'Available', TRUE),
('Neha',    'Gupta',     'MS (Orthopedics)',           'Sports Medicine',           3,  '9811000006', 'neha.gupta@hms-hospital.example',      'MCI-MP-10006',  9, 1000.00, 'Available', TRUE),
('Priya',   'Nair',      'MD (Pediatrics)',            'General Pediatrics',        4,  '9811000007', 'priya.nair@hms-hospital.example',      'MCI-MP-10007', 11,  800.00, 'Available', TRUE),
('Sanjay',  'Mishra',    'MD (Pediatrics), DCH',       'Neonatology',               4,  '9811000008', 'sanjay.mishra@hms-hospital.example',   'MCI-MP-10008', 16,  900.00, 'Available', TRUE),
('Kavita',  'Joshi',     'MS (Obstetrics & Gynecology)','Obstetrics',               5,  '9811000009', 'kavita.joshi@hms-hospital.example',    'MCI-MP-10009', 14, 1000.00, 'Available', TRUE),
('Meera',   'Reddy',     'MD (Obstetrics & Gynecology)','Infertility Medicine',     5,  '9811000010', 'meera.reddy@hms-hospital.example',     'MCI-MP-10010',  8, 1100.00, 'Available', TRUE),
('Arjun',   'Malhotra',  'MD (Dermatology)',           'Cosmetic Dermatology',      6,  '9811000011', 'arjun.malhotra@hms-hospital.example',  'MCI-MP-10011',  7,  900.00, 'Available', TRUE),
('Pooja',   'Chawla',    'MD (DVL)',                   'Clinical Dermatology',      6,  '9811000012', 'pooja.chawla@hms-hospital.example',    'MCI-MP-10012', 10,  800.00, 'Available', TRUE),
('Rahul',   'Deshmukh',  'MD (Internal Medicine)',     'Internal Medicine',         7,  '9811000013', 'rahul.deshmukh@hms-hospital.example',  'MCI-MP-10013', 13,  600.00, 'Available', TRUE),
('Fatima',  'Khan',      'MD (Medicine), Dip. Diabetology','Diabetology',           7,  '9811000014', 'fatima.khan@hms-hospital.example',     'MCI-MP-10014',  9,  700.00, 'Available', TRUE),
('Manoj',   'Tiwari',    'MS (ENT)',                   'Otology',                   8,  '9811000015', 'manoj.tiwari@hms-hospital.example',    'MCI-MP-10015', 17,  800.00, 'Available', TRUE),
('Shalini', 'Saxena',    'MS (ENT)',                   'Rhinology',                 8,  '9811000016', 'shalini.saxena@hms-hospital.example',  'MCI-MP-10016',  6,  700.00, 'Available', TRUE),
('Deepak',  'Agarwal',   'MS (Ophthalmology)',         'Retina Specialist',         9,  '9811000017', 'deepak.agarwal@hms-hospital.example',  'MCI-MP-10017', 19, 1000.00, 'Available', TRUE),
('Ritu',    'Bansal',    'MS (Ophthalmology)',         'Cataract Surgery',          9,  '9811000018', 'ritu.bansal@hms-hospital.example',     'MCI-MP-10018', 11,  900.00, 'Available', TRUE),
('Harish',  'Yadav',     'MD (Emergency Medicine)',    'Emergency Medicine',        10, '9811000019', 'harish.yadav@hms-hospital.example',    'MCI-MP-10019', 12,  500.00, 'Available', TRUE),
('Swati',   'Kulkarni',  'MD (Anesthesia), FCCM',      'Critical Care',             10, '9811000020', 'swati.kulkarni@hms-hospital.example',  'MCI-MP-10020',  8,  600.00, 'Available', TRUE);

-- ------------------------------------------------------------
-- DOCTOR_SCHEDULE : every doctor works Mon-Fri, 09:00-17:00
-- (20 doctors x 5 days = 100 rows). Slots are 30 min => 16/day.
-- ------------------------------------------------------------
INSERT INTO DOCTOR_SCHEDULE (DoctorID, DayOfWeek, StartTime, EndTime, MaxAppointmentsPerDay)
SELECT d.DoctorID, days.DayName, '09:00:00', '17:00:00', 16
FROM DOCTOR d
CROSS JOIN (
    SELECT 'Monday'    AS DayName UNION ALL
    SELECT 'Tuesday'              UNION ALL
    SELECT 'Wednesday'            UNION ALL
    SELECT 'Thursday'             UNION ALL
    SELECT 'Friday'
) days
ORDER BY d.DoctorID, FIELD(days.DayName,'Monday','Tuesday','Wednesday','Thursday','Friday');

-- Verification
SELECT COUNT(*) AS doctors_inserted   FROM DOCTOR;            -- Expected: 20
SELECT COUNT(*) AS schedules_inserted FROM DOCTOR_SCHEDULE;   -- Expected: 100
