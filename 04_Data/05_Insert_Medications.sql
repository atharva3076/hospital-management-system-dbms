-- ============================================================
-- File    : 05_Insert_Medications.sql
-- Project : Hospital Management System (HMS)
-- Phase   : 3 - Data Population (Member 4)
-- Purpose : Insert 8 manufacturers and 30 medicines
-- Depends : 02_SQL_Schema only (independent of patient data)
--
-- All manufacturer names are FICTIONAL.
-- Expiry dates are relative to CURDATE() (schema requires future
-- expiry). A few medicines expire within 20-60 days and a few are
-- below reorder level, so v_medicine_expiry_alert and
-- v_medicine_inventory have interesting rows to show.
-- ============================================================

USE hospital_management_system;

-- ------------------------------------------------------------
-- MANUFACTURERS (ManufacturerID 1-8)
-- ------------------------------------------------------------
INSERT INTO MANUFACTURER (ManufacturerName, ContactPerson, Phone, Email, Address, City, Country) VALUES
('MediCore Pharma Pvt Ltd',          'Ravi Kapoor',   '0731-5002001', 'sales@medicore.example',    'Plot 12, Pharma Zone',        'Indore',    'India'),
('LifeWell Laboratories',            'Sheetal Rao',   '022-50020002', 'orders@lifewell.example',   '44, MIDC Industrial Area',    'Mumbai',    'India'),
('Apex Remedies Ltd',                'Dinesh Bhatt',  '079-50020003', 'supply@apexremedies.example','B-9, GIDC Estate',           'Ahmedabad', 'India'),
('NovaCure Pharmaceuticals',         'Lata Menon',    '040-50020004', 'info@novacure.example',     '21, Genome Valley',           'Hyderabad', 'India'),
('Sanjeevani Drugs & Chemicals',     'Alok Trivedi',  '0755-5002005', 'contact@sanjeevani.example','Sector C, Govindpura',        'Bhopal',    'India'),
('BioHeal Industries',               'Nandini Das',   '033-50020006', 'sales@bioheal.example',     '7, Salt Lake Sector V',       'Kolkata',   'India'),
('Prime Health Formulations',        'Harsh Vora',    '0172-5002007', 'orders@primehealth.example','Phase 2, Industrial Area',    'Chandigarh','India'),
('Zenith Lifesciences',              'Pallavi Joshi', '020-50020008', 'care@zenithlife.example',   'Hinjewadi Phase 1',           'Pune',      'India');

-- ------------------------------------------------------------
-- MEDICINES (MedicineID 1-30)
-- ------------------------------------------------------------
INSERT INTO MEDICINE
 (MedicineName, GenericName, ManufacturerID, Category, DosageForm, Strength, UnitPrice, QuantityInStock, ReorderLevel, BatchNumber, ExpiryDate)
VALUES
('Paracetamol 500',          'Paracetamol',          1, 'Analgesic',            'Tablet',    '500 mg',      1.50, 5000, 500, 'BT-2601-001', DATE_ADD(CURDATE(), INTERVAL 540 DAY)),
('Ibuprofen 400',            'Ibuprofen',            2, 'NSAID',                'Tablet',    '400 mg',      2.20, 3000, 300, 'BT-2601-002', DATE_ADD(CURDATE(), INTERVAL 500 DAY)),
('Amoxicillin 500',          'Amoxicillin',          3, 'Antibiotic',           'Capsule',   '500 mg',      8.50, 2500, 300, 'BT-2601-003', DATE_ADD(CURDATE(), INTERVAL 420 DAY)),
('Azithromycin 500',         'Azithromycin',         3, 'Antibiotic',           'Tablet',    '500 mg',     22.00,  800, 150, 'BT-2512-004', DATE_ADD(CURDATE(), INTERVAL 30 DAY)),
('Cetirizine 10',            'Cetirizine',           4, 'Antihistamine',        'Tablet',    '10 mg',       2.00, 4000, 400, 'BT-2601-005', DATE_ADD(CURDATE(), INTERVAL 600 DAY)),
('Omeprazole 20',            'Omeprazole',           1, 'Proton Pump Inhibitor','Capsule',   '20 mg',       3.50, 3500, 300, 'BT-2601-006', DATE_ADD(CURDATE(), INTERVAL 480 DAY)),
('Pantoprazole 40',          'Pantoprazole',         2, 'Proton Pump Inhibitor','Tablet',    '40 mg',       5.00, 3000, 300, 'BT-2601-007', DATE_ADD(CURDATE(), INTERVAL 450 DAY)),
('Metformin 500',            'Metformin',            5, 'Antidiabetic',         'Tablet',    '500 mg',      2.50, 4500, 500, 'BT-2601-008', DATE_ADD(CURDATE(), INTERVAL 520 DAY)),
('Glimepiride 2',            'Glimepiride',          5, 'Antidiabetic',         'Tablet',    '2 mg',        4.00, 2000, 200, 'BT-2601-009', DATE_ADD(CURDATE(), INTERVAL 510 DAY)),
('Amlodipine 5',             'Amlodipine',           6, 'Antihypertensive',     'Tablet',    '5 mg',        3.00, 4000, 400, 'BT-2601-010', DATE_ADD(CURDATE(), INTERVAL 560 DAY)),
('Atenolol 50',              'Atenolol',             6, 'Beta Blocker',         'Tablet',    '50 mg',       2.80, 2800, 250, 'BT-2601-011', DATE_ADD(CURDATE(), INTERVAL 530 DAY)),
('Losartan 50',              'Losartan',             6, 'Antihypertensive',     'Tablet',    '50 mg',       6.00, 2600, 250, 'BT-2601-012', DATE_ADD(CURDATE(), INTERVAL 470 DAY)),
('Atorvastatin 10',          'Atorvastatin',         7, 'Statin',               'Tablet',    '10 mg',       7.50, 3200, 300, 'BT-2601-013', DATE_ADD(CURDATE(), INTERVAL 490 DAY)),
('Aspirin 75',               'Aspirin',              7, 'Antiplatelet',         'Tablet',    '75 mg',       1.20, 5000, 500, 'BT-2601-014', DATE_ADD(CURDATE(), INTERVAL 580 DAY)),
('Clopidogrel 75',           'Clopidogrel',          7, 'Antiplatelet',         'Tablet',    '75 mg',       9.00, 1800, 200, 'BT-2601-015', DATE_ADD(CURDATE(), INTERVAL 440 DAY)),
('Salbutamol Inhaler',       'Salbutamol',           8, 'Bronchodilator',       'Inhaler',   '100 mcg',   145.00,   15,  30, 'BT-2511-016', DATE_ADD(CURDATE(), INTERVAL 45 DAY)),
('Montelukast 10',           'Montelukast',          8, 'Antiasthmatic',        'Tablet',    '10 mg',      12.00, 1500, 150, 'BT-2601-017', DATE_ADD(CURDATE(), INTERVAL 430 DAY)),
('Diclofenac 50',            'Diclofenac',           2, 'NSAID',                'Tablet',    '50 mg',       3.20, 3000, 300, 'BT-2601-018', DATE_ADD(CURDATE(), INTERVAL 500 DAY)),
('Ciprofloxacin 500',        'Ciprofloxacin',        3, 'Antibiotic',           'Tablet',    '500 mg',      6.50, 2200, 250, 'BT-2601-019', DATE_ADD(CURDATE(), INTERVAL 410 DAY)),
('Levothyroxine 50',         'Levothyroxine',        4, 'Thyroid Hormone',      'Tablet',    '50 mcg',      3.80, 2400, 250, 'BT-2601-020', DATE_ADD(CURDATE(), INTERVAL 550 DAY)),
('Vitamin D3 60K',           'Cholecalciferol',      1, 'Supplement',           'Capsule',   '60000 IU',   25.00, 1600, 150, 'BT-2601-021', DATE_ADD(CURDATE(), INTERVAL 400 DAY)),
('Calcium + D3',             'Calcium Carbonate',    1, 'Supplement',           'Tablet',    '500 mg',      6.00, 2800, 250, 'BT-2601-022', DATE_ADD(CURDATE(), INTERVAL 460 DAY)),
('Ondansetron 4',            'Ondansetron',          2, 'Antiemetic',           'Tablet',    '4 mg',        4.50, 1800, 200, 'BT-2601-023', DATE_ADD(CURDATE(), INTERVAL 380 DAY)),
('Domperidone 10',           'Domperidone',          4, 'Prokinetic',           'Tablet',    '10 mg',       3.00, 2000, 200, 'BT-2601-024', DATE_ADD(CURDATE(), INTERVAL 390 DAY)),
('ORS Sachet',               'Oral Rehydration Salts',1,'Electrolyte',          'Powder',    '21 g',       18.00,  900, 150, 'BT-2602-025', DATE_ADD(CURDATE(), INTERVAL 60 DAY)),
('Dextromethorphan Syrup',   'Dextromethorphan',     8, 'Antitussive',          'Syrup',     '10 mg/5 ml', 85.00,  120,  40, 'BT-2510-026', DATE_ADD(CURDATE(), INTERVAL 20 DAY)),
('Ofloxacin Eye Drops',      'Ofloxacin',            4, 'Ophthalmic Antibiotic','Eye Drops', '0.3%',       55.00,  300,  50, 'BT-2601-027', DATE_ADD(CURDATE(), INTERVAL 300 DAY)),
('Betamethasone Cream',      'Betamethasone',        6, 'Topical Steroid',      'Cream',     '0.05%',      68.00,  250,  50, 'BT-2601-028', DATE_ADD(CURDATE(), INTERVAL 320 DAY)),
('Folic Acid 5',             'Folic Acid',           7, 'Vitamin',              'Tablet',    '5 mg',        1.80, 3500, 300, 'BT-2601-029', DATE_ADD(CURDATE(), INTERVAL 570 DAY)),
('Insulin Glargine',         'Insulin Glargine',     5, 'Antidiabetic',         'Injection', '100 IU/ml', 650.00,   40,  50, 'BT-2601-030', DATE_ADD(CURDATE(), INTERVAL 180 DAY));

-- Verification
SELECT COUNT(*) AS manufacturers_inserted FROM MANUFACTURER;   -- Expected: 8
SELECT COUNT(*) AS medicines_inserted     FROM MEDICINE;       -- Expected: 30
SELECT MedicineName, QuantityInStock, ReorderLevel FROM MEDICINE WHERE QuantityInStock < ReorderLevel;  -- Low-stock demo rows
SELECT MedicineName, ExpiryDate FROM MEDICINE WHERE ExpiryDate <= DATE_ADD(CURDATE(), INTERVAL 60 DAY); -- Expiry-alert demo rows
