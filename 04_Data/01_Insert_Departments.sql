-- ============================================================
-- File    : 01_Insert_Departments.sql
-- Project : Hospital Management System (HMS)
-- Phase   : 3 - Data Population (Member 4)
-- Purpose : Insert 10 hospital departments
-- Depends : 02_SQL_Schema (all 4 SQL files executed)
-- Run on a FRESH database so auto-increment IDs start at 1
-- ============================================================

USE hospital_management_system;

INSERT INTO DEPARTMENT (DeptName, Description, Floor, Phone, Email, IsActive) VALUES
('Cardiology',       'Diagnosis and treatment of heart and blood vessel disorders',           2, '0755-4001001', 'cardiology@hms-hospital.example',   TRUE),
('Neurology',        'Care for disorders of the brain, spine and nervous system',             3, '0755-4001002', 'neurology@hms-hospital.example',    TRUE),
('Orthopedics',      'Bone, joint, ligament and muscle treatment and surgery',                1, '0755-4001003', 'orthopedics@hms-hospital.example',  TRUE),
('Pediatrics',       'Medical care for infants, children and adolescents',                    1, '0755-4001004', 'pediatrics@hms-hospital.example',   TRUE),
('Gynecology',       'Women''s reproductive health, pregnancy and childbirth care',           2, '0755-4001005', 'gynecology@hms-hospital.example',   TRUE),
('Dermatology',      'Skin, hair and nail disorders',                                         1, '0755-4001006', 'dermatology@hms-hospital.example',  TRUE),
('General Medicine', 'Primary care and internal medicine for adults',                         0, '0755-4001007', 'generalmed@hms-hospital.example',   TRUE),
('ENT',              'Ear, nose and throat disorders',                                        2, '0755-4001008', 'ent@hms-hospital.example',          TRUE),
('Ophthalmology',    'Eye examination, vision correction and eye surgery',                    3, '0755-4001009', 'ophthalmology@hms-hospital.example',TRUE),
('Emergency',        '24x7 emergency and critical care services',                             0, '0755-4001010', 'emergency@hms-hospital.example',    TRUE);

-- Verification
SELECT COUNT(*) AS departments_inserted FROM DEPARTMENT;   -- Expected: 10
