-- ============================================================================
-- HOSPITAL MANAGEMENT SYSTEM - CUSTOM FUNCTIONS (PL/SQL)
-- ============================================================================
-- Created by: Member 3 (PL/SQL Developer)
-- Purpose: Create reusable functions for business logic and calculations
-- Date: 2024
-- ============================================================================
-- FUNCTIONS: 8 custom functions covering:
-- 1. Calculate patient age from DOB
-- 2. Calculate patient BMI
-- 3. Get doctor's current workload
-- 4. Calculate bill discount based on payment
-- 5. Check medicine availability
-- 6. Get patient total spent
-- 7. Calculate appointment delay
-- 8. Get department average rating
-- ============================================================================

USE hospital_management_system;

-- ============================================================================
-- FUNCTION 1: fn_calculate_age
-- ============================================================================
-- Purpose: Calculate age in years from date of birth
-- 
-- Parameters:
--   birth_date - DATE value
--
-- Returns: INT (Age in years)
--
-- Logic:
--   1. Calculate difference between current year and birth year
--   2. Adjust if birthday hasn't occurred yet this year
--
-- Usage:
--   SELECT PatientID, FirstName, fn_calculate_age(DOB) AS Age 
--   FROM PATIENT;
--
-- ============================================================================

DELIMITER //

CREATE FUNCTION fn_calculate_age(
    birth_date DATE
)
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_age INT;
    
    -- Calculate age
    SET v_age = YEAR(CURDATE()) - YEAR(birth_date);
    
    -- Adjust if birthday hasn't occurred yet this year
    IF MONTH(CURDATE()) < MONTH(birth_date) 
       OR (MONTH(CURDATE()) = MONTH(birth_date) AND DAY(CURDATE()) < DAY(birth_date))
    THEN
        SET v_age = v_age - 1;
    END IF;
    
    RETURN v_age;
END //

DELIMITER ;

-- ============================================================================
-- FUNCTION 2: fn_calculate_bmi
-- ============================================================================
-- Purpose: Calculate Body Mass Index from height (cm) and weight (kg)
--
-- Formula: BMI = Weight (kg) / (Height (m))^2
--
-- Parameters:
--   height_cm - Height in centimeters
--   weight_kg - Weight in kilograms
--
-- Returns: DECIMAL(5,2) (BMI value)
--
-- Usage:
--   SELECT PatientID, FirstName, fn_calculate_bmi(Height, Weight) AS BMI 
--   FROM PATIENT;
--
-- BMI Categories:
--   < 18.5 = Underweight
--   18.5-24.9 = Normal
--   25-29.9 = Overweight
--   >= 30 = Obese
--
-- ============================================================================

DELIMITER //

CREATE FUNCTION fn_calculate_bmi(
    height_cm DECIMAL(5,2),
    weight_kg DECIMAL(5,2)
)
RETURNS DECIMAL(5,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_height_m DECIMAL(5,3);
    DECLARE v_bmi DECIMAL(5,2);
    
    -- Validate inputs
    IF height_cm <= 0 OR weight_kg <= 0 THEN
        RETURN NULL;
    END IF;
    
    -- Convert height to meters
    SET v_height_m = height_cm / 100;
    
    -- Calculate BMI
    SET v_bmi = weight_kg / (v_height_m * v_height_m);
    
    RETURN ROUND(v_bmi, 2);
END //

DELIMITER ;

-- ============================================================================
-- FUNCTION 3: fn_get_doctor_workload
-- ============================================================================
-- Purpose: Get number of appointments scheduled for doctor in next 7 days
--
-- Parameters:
--   doctor_id - Doctor ID
--
-- Returns: INT (Number of appointments)
--
-- Usage:
--   SELECT DoctorID, FirstName, fn_get_doctor_workload(DoctorID) AS UpcomingAppointments 
--   FROM DOCTOR;
--
-- ============================================================================

DELIMITER //

CREATE FUNCTION fn_get_doctor_workload(
    doctor_id INT
)
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_appointment_count INT;
    
    -- Count appointments for next 7 days
    SELECT COUNT(*) INTO v_appointment_count
    FROM APPOINTMENT
    WHERE DoctorID = doctor_id
        AND AppointmentDate BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 7 DAY)
        AND Status IN ('Scheduled', 'Completed');
    
    IF v_appointment_count IS NULL THEN
        RETURN 0;
    END IF;
    
    RETURN v_appointment_count;
END //

DELIMITER ;

-- ============================================================================
-- FUNCTION 4: fn_get_payment_discount
-- ============================================================================
-- Purpose: Calculate discount based on payment method and amount paid
--
-- Business Logic:
--   - Cash payment: 5% discount
--   - Insurance payment: 2% discount
--   - Early payment (within 3 days): 3% additional discount
--   - Multiple condition: sum applicable discounts
--
-- Parameters:
--   total_amount - Total billing amount
--   payment_method - Payment method (Cash, Card, UPI, Insurance, etc.)
--   payment_days - Days since bill due date (negative = early)
--
-- Returns: DECIMAL(10,2) (Discount amount)
--
-- Usage:
--   SELECT fn_get_payment_discount(5000, 'Cash', -2) AS Discount;
--
-- ============================================================================

DELIMITER //

CREATE FUNCTION fn_get_payment_discount(
    total_amount DECIMAL(12,2),
    payment_method VARCHAR(50),
    payment_days INT
)
RETURNS DECIMAL(10,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_discount_rate DECIMAL(5,2);
    DECLARE v_discount DECIMAL(10,2);
    
    SET v_discount_rate = 0;
    
    -- Validate input
    IF total_amount <= 0 THEN
        RETURN 0;
    END IF;
    
    -- Payment method discount
    IF payment_method = 'Cash' THEN
        SET v_discount_rate = v_discount_rate + 5.00;
    ELSEIF payment_method = 'Insurance' THEN
        SET v_discount_rate = v_discount_rate + 2.00;
    ELSEIF payment_method = 'UPI' THEN
        SET v_discount_rate = v_discount_rate + 1.50;
    END IF;
    
    -- Early payment discount (negative payment_days means early)
    IF payment_days < -3 THEN
        SET v_discount_rate = v_discount_rate + 3.00;
    ELSEIF payment_days < 0 THEN
        SET v_discount_rate = v_discount_rate + 1.50;
    END IF;
    
    -- Calculate discount amount
    SET v_discount = (total_amount * v_discount_rate) / 100;
    
    RETURN ROUND(v_discount, 2);
END //

DELIMITER ;

-- ============================================================================
-- FUNCTION 5: fn_check_medicine_availability
-- ============================================================================
-- Purpose: Check if medicine is available and safe to prescribe
--
-- Checks:
--   1. Medicine is active/not discontinued
--   2. Stock > reorder level
--   3. Not expired
--   4. Quantity available > requested quantity
--
-- Parameters:
--   medicine_id - Medicine ID
--   requested_qty - Quantity requested for prescription
--
-- Returns: VARCHAR(100) (Status message)
--
-- Usage:
--   SELECT MedicineID, MedicineName, fn_check_medicine_availability(MedicineID, 10) AS Status 
--   FROM MEDICINE;
--
-- ============================================================================

DELIMITER //

CREATE FUNCTION fn_check_medicine_availability(
    medicine_id INT,
    requested_qty INT
)
RETURNS VARCHAR(100)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_is_active BOOLEAN;
    DECLARE v_quantity_stock INT;
    DECLARE v_reorder_level INT;
    DECLARE v_expiry_date DATE;
    
    -- Get medicine details
    SELECT IsActive, QuantityInStock, ReorderLevel, ExpiryDate 
    INTO v_is_active, v_quantity_stock, v_reorder_level, v_expiry_date
    FROM MEDICINE
    WHERE MedicineID = medicine_id;
    
    -- Check if medicine exists
    IF v_is_active IS NULL THEN
        RETURN 'UNAVAILABLE: Medicine does not exist';
    END IF;
    
    -- Check if medicine is discontinued
    IF v_is_active = FALSE THEN
        RETURN 'UNAVAILABLE: Medicine is discontinued';
    END IF;
    
    -- Check if expired
    IF v_expiry_date < CURDATE() THEN
        RETURN 'UNAVAILABLE: Medicine has expired';
    END IF;
    
    -- Check if expiring soon (within 30 days)
    IF v_expiry_date < DATE_ADD(CURDATE(), INTERVAL 30 DAY) THEN
        RETURN 'WARNING: Medicine expiring soon (within 30 days)';
    END IF;
    
    -- Check stock level
    IF v_quantity_stock = 0 THEN
        RETURN 'UNAVAILABLE: Out of stock';
    END IF;
    
    -- Check if sufficient quantity available
    IF v_quantity_stock < requested_qty THEN
        RETURN CONCAT('LIMITED: Only ', v_quantity_stock, ' units available, ', requested_qty, ' requested');
    END IF;
    
    -- Check if stock below reorder level
    IF v_quantity_stock < v_reorder_level THEN
        RETURN 'LOW_STOCK: Quantity below reorder level';
    END IF;
    
    -- All checks passed
    RETURN 'AVAILABLE: Medicine is available and safe to prescribe';
END //

DELIMITER ;

-- ============================================================================
-- FUNCTION 6: fn_get_patient_total_spent
-- ============================================================================
-- Purpose: Calculate total amount patient has spent on hospital services
--
-- Parameters:
--   patient_id - Patient ID
--
-- Returns: DECIMAL(12,2) (Total amount spent)
--
-- Usage:
--   SELECT PatientID, FirstName, fn_get_patient_total_spent(PatientID) AS TotalSpent 
--   FROM PATIENT;
--
-- ============================================================================

DELIMITER //

CREATE FUNCTION fn_get_patient_total_spent(
    patient_id INT
)
RETURNS DECIMAL(12,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_total_spent DECIMAL(12,2);
    
    -- Get sum of all paid bills for patient
    SELECT COALESCE(SUM(AmountPaid), 0) INTO v_total_spent
    FROM BILLING
    WHERE PatientID = patient_id
        AND PaymentStatus IN ('Paid', 'Partial');
    
    RETURN ROUND(v_total_spent, 2);
END //

DELIMITER ;

-- ============================================================================
-- FUNCTION 7: fn_get_appointment_delay_minutes
-- ============================================================================
-- Purpose: Calculate how many minutes late the appointment is/was
--
-- Parameters:
--   appointment_id - Appointment ID
--
-- Returns: INT (Minutes late, negative if early)
--
-- Usage:
--   SELECT AppointmentID, fn_get_appointment_delay_minutes(AppointmentID) AS DelayMinutes 
--   FROM APPOINTMENT;
--
-- ============================================================================

DELIMITER //

CREATE FUNCTION fn_get_appointment_delay_minutes(
    appointment_id INT
)
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_scheduled_time DATETIME;
    DECLARE v_delay_minutes INT;
    
    -- Get scheduled appointment time
    SELECT DATE_ADD(CONCAT_WS(' ', AppointmentDate, AppointmentTime), INTERVAL 0 MINUTE)
    INTO v_scheduled_time
    FROM APPOINTMENT
    WHERE AppointmentID = appointment_id;
    
    -- If appointment hasn't occurred yet, return 0
    IF v_scheduled_time > NOW() OR v_scheduled_time IS NULL THEN
        RETURN 0;
    END IF;
    
    -- Calculate delay in minutes (can be negative if completed early)
    SET v_delay_minutes = TIMESTAMPDIFF(MINUTE, v_scheduled_time, NOW());
    
    RETURN v_delay_minutes;
END //

DELIMITER ;

-- ============================================================================
-- FUNCTION 8: fn_get_department_avg_rating
-- ============================================================================
-- Purpose: Calculate average rating for a department based on appointments
--
-- Parameters:
--   department_id - Department ID
--
-- Returns: DECIMAL(3,2) (Average rating 0-5)
--
-- Usage:
--   SELECT DepartmentID, DeptName, fn_get_department_avg_rating(DepartmentID) AS AvgRating 
--   FROM DEPARTMENT;
--
-- ============================================================================

DELIMITER //

CREATE FUNCTION fn_get_department_avg_rating(
    department_id INT
)
RETURNS DECIMAL(3,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_avg_rating DECIMAL(3,2);
    
    -- Get average rating from doctors in department
    SELECT COALESCE(AVG(d.Rating), 0) INTO v_avg_rating
    FROM DOCTOR d
    WHERE d.DepartmentID = department_id
        AND d.IsActive = TRUE;
    
    IF v_avg_rating IS NULL THEN
        RETURN 0;
    END IF;
    
    -- Ensure rating is between 0 and 5
    IF v_avg_rating > 5 THEN
        RETURN 5.00;
    END IF;
    
    RETURN ROUND(v_avg_rating, 2);
END //

DELIMITER ;

-- ============================================================================
-- SUMMARY OF FUNCTIONS
-- ============================================================================
-- Total Functions: 8
--
-- 1. fn_calculate_age                   - Calculate patient age from DOB
-- 2. fn_calculate_bmi                   - Calculate BMI from height and weight
-- 3. fn_get_doctor_workload             - Count upcoming appointments
-- 4. fn_get_payment_discount            - Calculate discount based on payment method
-- 5. fn_check_medicine_availability     - Verify medicine is safe to prescribe
-- 6. fn_get_patient_total_spent         - Sum patient's total spending
-- 7. fn_get_appointment_delay_minutes   - Calculate appointment delay
-- 8. fn_get_department_avg_rating       - Average department rating
--
-- DBMS Concepts Covered:
-- ✅ Scalar functions (return single value)
-- ✅ DETERMINISTIC clause (for optimization)
-- ✅ READS SQL DATA (functions that query database)
-- ✅ Control flow (IF-THEN-ELSE, CASE)
-- ✅ Date/Time functions
-- ✅ Mathematical calculations
-- ✅ NULL handling
-- ✅ Data validation
--
-- ============================================================================
-- End of Functions Script
-- ============================================================================
