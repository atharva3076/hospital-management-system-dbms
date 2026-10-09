-- ============================================================
-- File    : 03_Insert_Patients.sql
-- Project : Hospital Management System (HMS)
-- Phase   : 3 - Data Population (Member 4)
-- Purpose : Insert 100 patients (generated, realistic Indian
--           names/cities) and 80 medical history records
-- Depends : 02_Insert_Doctors.sql
-- Note    : Uses a recursive CTE (MySQL 8.0+) so that every row
--           gets a UNIQUE phone and email without hand-typing.
-- ============================================================

USE hospital_management_system;

-- ------------------------------------------------------------
-- PATIENTS (PatientID 1-100)
-- ------------------------------------------------------------
INSERT INTO PATIENT
 (FirstName, LastName, DateOfBirth, Gender, BloodGroup, Phone, Email, Address, City, State, PostalCode,
  EmergencyContactName, EmergencyContactPhone, Allergies)
WITH RECURSIVE seq AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM seq WHERE n < 100
),
p AS (
    SELECT
        n,
        IF(MOD(n,2) = 0, 'Female', 'Male') AS gender,
        IF(MOD(n,2) = 0,
           ELT(1 + MOD(n DIV 2, 15), 'Aarti','Sneha','Pooja','Ritu','Divya','Kiran','Anjali','Neelam','Swati','Mamta','Rekha','Shweta','Nisha','Komal','Tanvi'),
           ELT(1 + MOD(n DIV 2, 15), 'Rohit','Amit','Suresh','Vivek','Karan','Manish','Ajay','Sachin','Nikhil','Pankaj','Gaurav','Ashish','Mohit','Varun','Yogesh')
        ) AS fname,
        ELT(1 + MOD(n,20), 'Sharma','Verma','Gupta','Singh','Patel','Mishra','Tiwari','Yadav','Jain','Agarwal',
                           'Chauhan','Pandey','Saxena','Joshi','Rathore','Dubey','Shukla','Thakur','Kulkarni','Khan') AS lname,
        MOD(n,8) AS c
    FROM seq
)
SELECT
    fname,
    lname,
    DATE_SUB(CURDATE(), INTERVAL (6570 + MOD(n * 263, 24000)) DAY)                          AS DateOfBirth,   -- age ~18 to ~83
    gender,
    ELT(1 + MOD(n,8), 'A+','B+','O+','AB+','A-','B-','O-','AB-')                            AS BloodGroup,
    CONCAT('98', LPAD(10000000 + n * 37, 8, '0'))                                           AS Phone,
    LOWER(CONCAT(fname, '.', lname, n, '@example.com'))                                     AS Email,
    CONCAT(10 + n, ', ', ELT(1 + MOD(n,5), 'MG Road','Gandhi Nagar','Arera Colony','Civil Lines','Station Road')) AS Address,
    ELT(1 + c, 'Bhopal','Indore','Jabalpur','Gwalior','Nagpur','Pune','New Delhi','Lucknow') AS City,
    ELT(1 + c, 'Madhya Pradesh','Madhya Pradesh','Madhya Pradesh','Madhya Pradesh','Maharashtra','Maharashtra','Delhi','Uttar Pradesh') AS State,
    ELT(1 + c, '462001','452001','482001','474001','440001','411001','110001','226001')     AS PostalCode,
    CONCAT(ELT(1 + MOD(n,10), 'Ramesh','Sunita','Mahesh','Geeta','Dinesh','Seema','Naresh','Usha','Lokesh','Radha'), ' ', lname) AS EmergencyContactName,
    CONCAT('97', LPAD(20000000 + n * 41, 8, '0'))                                           AS EmergencyContactPhone,
    ELT(1 + MOD(n,6), 'None','None','Penicillin','Dust','None','Sulfa drugs')               AS Allergies
FROM p
ORDER BY n;

-- ------------------------------------------------------------
-- MEDICAL_HISTORY (80 records: patients 1-80)
-- ------------------------------------------------------------
INSERT INTO MEDICAL_HISTORY (PatientID, DoctorID, Diagnosis, Symptoms, Treatment, DiagnosisDate, Status)
WITH RECURSIVE seq AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM seq WHERE n < 80
)
SELECT
    n,
    1 + MOD(n, 20),
    ELT(1 + MOD(n,10), 'Type 2 Diabetes Mellitus','Hypertension','Seasonal Allergic Rhinitis','Bronchial Asthma','Migraine',
                       'Gastroesophageal Reflux Disease','Lower Back Pain','Iron Deficiency Anemia','Hypothyroidism','Viral Fever'),
    ELT(1 + MOD(n,10), 'Increased thirst, frequent urination, fatigue','Headache, dizziness, elevated blood pressure','Sneezing, runny nose, itchy eyes',
                       'Wheezing, shortness of breath, night cough','Severe one-sided headache, light sensitivity',
                       'Heartburn, acid regurgitation, bloating','Pain in lower back on bending, stiffness','Weakness, pallor, breathlessness on exertion',
                       'Weight gain, cold intolerance, tiredness','High fever, body ache, sore throat'),
    ELT(1 + MOD(n,10), 'Metformin, diet control and regular exercise','Amlodipine, low-salt diet, regular monitoring','Cetirizine, avoid allergens',
                       'Salbutamol inhaler, Montelukast','Rest in dark room, analgesics, trigger avoidance',
                       'Pantoprazole, dietary changes','Physiotherapy, Diclofenac, posture correction','Iron and Folic Acid supplements, diet advice',
                       'Levothyroxine, periodic TSH testing','Paracetamol, fluids and rest'),
    DATE_SUB(CURDATE(), INTERVAL (30 + MOD(n * 17, 700)) DAY),
    IF(MOD(n,3) = 0, 'Resolved', 'Ongoing')
FROM seq
ORDER BY n;

-- Verification
SELECT COUNT(*) AS patients_inserted         FROM PATIENT;           -- Expected: 100
SELECT COUNT(*) AS medical_history_inserted  FROM MEDICAL_HISTORY;   -- Expected: 80
SELECT COUNT(DISTINCT Phone) AS unique_phones, COUNT(DISTINCT Email) AS unique_emails FROM PATIENT;  -- Expected: 100, 100
