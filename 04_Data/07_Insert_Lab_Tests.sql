-- ============================================================
-- File    : 07_Insert_Lab_Tests.sql
-- Project : Hospital Management System (HMS)
-- Phase   : 3 - Data Population (Member 4)
-- Purpose : Insert 15 lab test definitions and 54 lab reports
-- Depends : 04_Insert_Appointments.sql
-- ============================================================

USE hospital_management_system;

-- ------------------------------------------------------------
-- LAB_TEST (TestID 1-15)
-- ------------------------------------------------------------
INSERT INTO LAB_TEST (TestName, Category, Description, Price, NormalRange, SampleType, TurnaroundHours) VALUES
('Complete Blood Count',      'Hematology',   'Measures red cells, white cells, hemoglobin and platelets',   350.00, 'Hb 12-16 g/dL; WBC 4000-11000/uL',   'Blood',  6),
('Fasting Blood Sugar',       'Biochemistry', 'Blood glucose after 8-12 hours of fasting',                   120.00, '70-100 mg/dL',                       'Blood',  4),
('HbA1c',                     'Biochemistry', 'Average blood sugar over the last 3 months',                  550.00, 'Below 5.7 %',                        'Blood', 12),
('Lipid Profile',             'Biochemistry', 'Total cholesterol, LDL, HDL and triglycerides',               600.00, 'Total cholesterol below 200 mg/dL',  'Blood',  8),
('Liver Function Test',       'Biochemistry', 'Bilirubin, SGOT, SGPT and alkaline phosphatase',              700.00, 'SGPT 7-56 U/L',                      'Blood',  8),
('Kidney Function Test',      'Biochemistry', 'Urea, creatinine and uric acid levels',                       650.00, 'Creatinine 0.6-1.3 mg/dL',           'Blood',  8),
('Thyroid Profile (TSH)',     'Endocrinology','TSH, T3 and T4 hormone levels',                               500.00, 'TSH 0.4-4.0 mIU/L',                  'Blood', 12),
('Urine Routine',             'Pathology',    'Physical, chemical and microscopic urine examination',        150.00, 'Protein and glucose negative',       'Urine',  4),
('Vitamin D (25-OH)',         'Biochemistry', 'Vitamin D deficiency screening',                             1200.00, '30-100 ng/mL',                       'Blood', 24),
('Vitamin B12',               'Biochemistry', 'Vitamin B12 deficiency screening',                            900.00, '200-900 pg/mL',                      'Blood', 24),
('Serum Electrolytes',        'Biochemistry', 'Sodium, potassium and chloride levels',                       400.00, 'Na 135-145 mmol/L',                  'Blood',  6),
('C-Reactive Protein',        'Immunology',   'Marker of inflammation and infection',                        450.00, 'Below 6 mg/L',                       'Blood',  6),
('Dengue NS1 Antigen',        'Serology',     'Early detection of dengue infection',                        1000.00, 'Negative',                           'Blood',  6),
('Uric Acid',                 'Biochemistry', 'Gout and kidney stone screening',                             250.00, '3.5-7.2 mg/dL',                      'Blood',  4),
('Prothrombin Time (PT/INR)', 'Hematology',   'Blood clotting time',                                         500.00, 'INR 0.8-1.2',                        'Blood',  6);

-- ------------------------------------------------------------
-- LAB_REPORT (one report for each Scheduled appointment with
-- AppointmentID <= 60  ->  54 reports)
-- ------------------------------------------------------------
INSERT INTO LAB_REPORT
 (PatientID, TestID, DoctorID, AppointmentID, SampleCollectedDate, ReportDate, ResultValue, ResultStatus, Remarks, Status)
SELECT
    a.PatientID,
    1 + MOD(a.AppointmentID, 15),
    a.DoctorID,
    a.AppointmentID,
    a.AppointmentDate,
    a.AppointmentDate,
    ELT(1 + MOD(a.AppointmentID,6), 'Within reference range','Slightly elevated','Within reference range','Borderline low','Within reference range','Elevated'),
    IF(MOD(a.AppointmentID,4) = 0, 'Abnormal', 'Normal'),
    IF(MOD(a.AppointmentID,4) = 0, 'Abnormal value - doctor review advised', 'No action required'),
    'Completed'
FROM APPOINTMENT a
WHERE a.Status = 'Scheduled' AND a.AppointmentID <= 60
ORDER BY a.AppointmentID;

-- Verification
SELECT COUNT(*) AS lab_tests_inserted   FROM LAB_TEST;     -- Expected: 15
SELECT COUNT(*) AS lab_reports_inserted FROM LAB_REPORT;   -- Expected: 54
SELECT ResultStatus, COUNT(*) AS total FROM LAB_REPORT GROUP BY ResultStatus;
