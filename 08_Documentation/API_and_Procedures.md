# API Endpoints & Stored Procedures
## Hospital Management System - Complete Reference

**Document Version**: 1.0  
**Date**: October 2026  
**Module**: 08_Documentation  
**Prepared By**: Member 5 (Documentation Lead)  

---

## **TABLE OF CONTENTS**

1. [API Overview](#api-overview)
2. [Patient Management API](#patient-management-api)
3. [Doctor Management API](#doctor-management-api)
4. [Appointment Management API](#appointment-management-api)
5. [Prescription API](#prescription-api)
6. [Billing API](#billing-api)
7. [Stored Procedures](#stored-procedures)
8. [Error Handling](#error-handling)

---

## **API OVERVIEW**

### **Base URL**
```
http://localhost:8080/api/v1
```

### **Authentication**
```
Authorization: Bearer <JWT_TOKEN>
Content-Type: application/json
```

### **HTTP Methods**
- **GET**: Retrieve data
- **POST**: Create new record
- **PUT**: Update existing record
- **DELETE**: Archive/soft delete record

### **Response Format**
```json
{
    "success": true,
    "data": { /* response data */ },
    "message": "Operation successful",
    "timestamp": "2026-10-08T14:30:15Z"
}
```

---

## **PATIENT MANAGEMENT API**

### **1. Get All Patients**

**Endpoint**: `GET /api/v1/patients`

**Query Parameters**:
```
- page: 0 (default: 0)
- size: 20 (default: 20)
- sort: firstName (default: patientID)
- isActive: true/false (default: true)
```

**Request**:
```bash
curl -H "Authorization: Bearer TOKEN" \
  "http://localhost:8080/api/v1/patients?page=0&size=20"
```

**Response** (200 OK):
```json
{
    "success": true,
    "data": {
        "content": [
            {
                "patientID": 1,
                "firstName": "John",
                "lastName": "Doe",
                "phone": "9876543210",
                "email": "john@email.com",
                "registrationDate": "2026-01-15"
            }
        ],
        "totalElements": 150,
        "totalPages": 8,
        "currentPage": 0
    }
}
```

---

### **2. Get Patient by ID**

**Endpoint**: `GET /api/v1/patients/{patientID}`

**Path Parameters**:
```
- patientID: Integer (required)
```

**Response** (200 OK):
```json
{
    "success": true,
    "data": {
        "patientID": 1,
        "firstName": "John",
        "lastName": "Doe",
        "dob": "1990-05-15",
        "gender": "M",
        "bloodGroup": "O+",
        "height": 175.5,
        "weight": 75.0,
        "phone": "9876543210",
        "email": "john@email.com",
        "address": "123 Main St",
        "city": "New York",
        "state": "NY",
        "patientType": "OPD",
        "emergencyContact": "Jane Doe",
        "emergencyContactPhone": "9876543211",
        "isActive": true,
        "registrationDate": "2026-01-15"
    }
}
```

---

### **3. Create Patient**

**Endpoint**: `POST /api/v1/patients`

**Request Body**:
```json
{
    "firstName": "Jane",
    "lastName": "Smith",
    "dob": "1995-03-20",
    "gender": "F",
    "bloodGroup": "A+",
    "height": 165.5,
    "weight": 60.0,
    "phone": "9876543212",
    "email": "jane@email.com",
    "address": "456 Oak Ave",
    "city": "Boston",
    "state": "MA",
    "patientType": "OPD",
    "emergencyContact": "Bob Smith",
    "emergencyContactPhone": "9876543213"
}
```

**Response** (201 Created):
```json
{
    "success": true,
    "data": {
        "patientID": 151,
        "firstName": "Jane",
        "lastName": "Smith",
        "registrationDate": "2026-10-08"
    },
    "message": "Patient created successfully"
}
```

**Validation Rules**:
- firstName: Required, max 50 characters
- lastName: Required, max 50 characters
- dob: Required, must be valid date, age > 0
- gender: Required, 'M' or 'F'
- bloodGroup: Required, valid blood group
- height: Required, > 0
- weight: Required, > 0
- phone: Required, unique, valid format
- email: Required, unique, valid email
- emergencyContact: Required, max 100 characters

---

### **4. Update Patient**

**Endpoint**: `PUT /api/v1/patients/{patientID}`

**Response** (200 OK):
```json
{
    "success": true,
    "message": "Patient updated successfully"
}
```

---

### **5. Delete Patient (Soft Delete)**

**Endpoint**: `DELETE /api/v1/patients/{patientID}`

**Response** (200 OK):
```json
{
    "success": true,
    "message": "Patient archived successfully"
}
```

---

## **DOCTOR MANAGEMENT API**

### **1. Get All Doctors**

**Endpoint**: `GET /api/v1/doctors`

**Query Parameters**:
```
- specialization: Cardiology (optional)
- departmentID: 1 (optional)
- isActive: true (default: true)
```

**Response** (200 OK):
```json
{
    "success": true,
    "data": {
        "content": [
            {
                "doctorID": 1,
                "firstName": "Rajesh",
                "lastName": "Kumar",
                "specialization": "Cardiology",
                "registrationNumber": "REG12345",
                "departmentID": 1,
                "phone": "9876543210",
                "consultationFeePerHour": 500,
                "yearsOfExperience": 10,
                "isActive": true
            }
        ],
        "totalElements": 50,
        "totalPages": 3
    }
}
```

---

### **2. Get Doctor Schedule**

**Endpoint**: `GET /api/v1/doctors/{doctorID}/schedule`

**Response** (200 OK):
```json
{
    "success": true,
    "data": [
        {
            "scheduleID": 1,
            "doctorID": 1,
            "dayOfWeek": "MON",
            "startTime": "09:00",
            "endTime": "17:00",
            "isAvailable": true
        },
        {
            "scheduleID": 2,
            "doctorID": 1,
            "dayOfWeek": "TUE",
            "startTime": "10:00",
            "endTime": "18:00",
            "isAvailable": true
        }
    ]
}
```

---

### **3. Check Doctor Availability**

**Endpoint**: `GET /api/v1/doctors/{doctorID}/availability`

**Query Parameters**:
```
- date: 2026-10-15 (required)
```

**Response** (200 OK):
```json
{
    "success": true,
    "data": {
        "doctorID": 1,
        "doctorName": "Rajesh Kumar",
        "date": "2026-10-15",
        "dayOfWeek": "MON",
        "availableSlots": [
            "09:00", "09:30", "10:00", "10:30", "11:00",
            "14:00", "14:30", "15:00", "15:30", "16:00"
        ],
        "bookedSlots": ["11:30", "14:00"]
    }
}
```

---

## **APPOINTMENT MANAGEMENT API**

### **1. Book Appointment**

**Endpoint**: `POST /api/v1/appointments`

**Request Body**:
```json
{
    "patientID": 1,
    "doctorID": 1,
    "appointmentDate": "2026-10-15",
    "appointmentTime": "10:00",
    "reason": "Annual checkup"
}
```

**Response** (201 Created):
```json
{
    "success": true,
    "data": {
        "appointmentID": 501,
        "patientName": "John Doe",
        "doctorName": "Rajesh Kumar",
        "appointmentDate": "2026-10-15",
        "appointmentTime": "10:00",
        "status": "Scheduled",
        "consultationFee": 500
    },
    "message": "Appointment booked successfully"
}
```

**Validation Rules**:
- appointmentDate: Future date only (>= today)
- appointmentTime: Between 09:00 and 18:00
- Doctor must be available on that date/time
- Patient must be active

---

### **2. Get Appointments**

**Endpoint**: `GET /api/v1/appointments`

**Query Parameters**:
```
- patientID: 1 (optional)
- doctorID: 1 (optional)
- status: Scheduled (optional)
- dateFrom: 2026-10-01 (optional)
- dateTo: 2026-10-31 (optional)
```

**Response** (200 OK):
```json
{
    "success": true,
    "data": {
        "content": [
            {
                "appointmentID": 1,
                "patientName": "John Doe",
                "doctorName": "Rajesh Kumar",
                "appointmentDate": "2026-10-15",
                "appointmentTime": "10:00",
                "reason": "Annual checkup",
                "status": "Scheduled",
                "consultationFee": 500
            }
        ],
        "totalElements": 200,
        "totalPages": 10
    }
}
```

---

### **3. Update Appointment Status**

**Endpoint**: `PUT /api/v1/appointments/{appointmentID}/status`

**Request Body**:
```json
{
    "status": "Completed",
    "notes": "Patient examined, prescribed medicine"
}
```

**Response** (200 OK):
```json
{
    "success": true,
    "message": "Appointment status updated to Completed"
}
```

---

### **4. Cancel Appointment**

**Endpoint**: `DELETE /api/v1/appointments/{appointmentID}`

**Response** (200 OK):
```json
{
    "success": true,
    "message": "Appointment cancelled successfully"
}
```

---

## **PRESCRIPTION API**

### **1. Issue Prescription**

**Endpoint**: `POST /api/v1/prescriptions`

**Request Body**:
```json
{
    "appointmentID": 1,
    "doctorID": 1,
    "medicines": [
        {
            "medicineID": 5,
            "dosage": "500mg",
            "frequency": "2X",
            "duration": 7,
            "quantity": 14,
            "instructions": "Take after food"
        },
        {
            "medicineID": 12,
            "dosage": "10ml",
            "frequency": "1X",
            "duration": 7,
            "quantity": 1,
            "instructions": "At bedtime"
        }
    ],
    "notes": "Follow up after 7 days"
}
```

**Response** (201 Created):
```json
{
    "success": true,
    "data": {
        "prescriptionID": 101,
        "appointmentID": 1,
        "doctorName": "Rajesh Kumar",
        "prescriptionDate": "2026-10-08",
        "medicinesCount": 2,
        "status": "Active"
    },
    "message": "Prescription issued successfully"
}
```

---

### **2. Get Prescription**

**Endpoint**: `GET /api/v1/prescriptions/{appointmentID}`

**Response** (200 OK):
```json
{
    "success": true,
    "data": {
        "prescriptionID": 101,
        "appointmentID": 1,
        "patientName": "John Doe",
        "doctorName": "Rajesh Kumar",
        "prescriptionDate": "2026-10-08",
        "medicines": [
            {
                "medicineID": 5,
                "medicineName": "Aspirin",
                "dosage": "500mg",
                "frequency": "2X",
                "duration": 7,
                "quantity": 14,
                "instructions": "Take after food",
                "unitPrice": 50
            }
        ],
        "totalCost": 700,
        "status": "Active"
    }
}
```

---

### **3. Search Medicines**

**Endpoint**: `GET /api/v1/medicines`

**Query Parameters**:
```
- query: Aspirin (search by name)
- type: Antibiotic (optional)
- inStock: true (default: true)
```

**Response** (200 OK):
```json
{
    "success": true,
    "data": [
        {
            "medicineID": 5,
            "medicineName": "Aspirin",
            "genericName": "Acetylsalicylic acid",
            "type": "Analgesic",
            "dosage": "500mg",
            "unitPrice": 50,
            "quantityInStock": 1000,
            "manufacturerName": "Pfizer Inc"
        }
    ]
}
```

---

## **BILLING API**

### **1. Get Bill**

**Endpoint**: `GET /api/v1/billing/{appointmentID}`

**Response** (200 OK):
```json
{
    "success": true,
    "data": {
        "billingID": 1,
        "billingNumber": "BILL-20261008-001",
        "patientName": "John Doe",
        "appointmentDate": "2026-10-08",
        "consultationCharges": 500,
        "labCharges": 300,
        "medicineCharges": 700,
        "otherCharges": 100,
        "totalCharges": 1600,
        "insuranceProvider": "Health Guard",
        "insuranceCoverage": 800,
        "patientPayable": 800,
        "amountPaid": 0,
        "paymentStatus": "Pending",
        "billingDate": "2026-10-08",
        "dueDate": "2026-11-07"
    }
}
```

---

### **2. Create/Update Bill**

**Endpoint**: `POST /api/v1/billing`

**Request Body**:
```json
{
    "appointmentID": 1,
    "consultationCharges": 500,
    "labCharges": 300,
    "medicineCharges": 700,
    "otherCharges": 100,
    "insuranceID": 5
}
```

**Response** (201 Created):
```json
{
    "success": true,
    "data": {
        "billingID": 1,
        "billingNumber": "BILL-20261008-001",
        "totalCharges": 1600,
        "insuranceCoverage": 800,
        "patientPayable": 800
    }
}
```

---

### **3. Record Payment**

**Endpoint**: `PUT /api/v1/billing/{billingID}/payment`

**Request Body**:
```json
{
    "amountPaid": 800,
    "paymentMethod": "Card",
    "transactionID": "TXN123456"
}
```

**Response** (200 OK):
```json
{
    "success": true,
    "data": {
        "billingID": 1,
        "paymentStatus": "Paid",
        "amountPaid": 800,
        "remainingAmount": 0,
        "paymentDate": "2026-10-08"
    }
}
```

---

## **STORED PROCEDURES**

### **1. ProcessAppointment**

**Purpose**: Complete appointment and auto-generate billing

**Syntax**:
```sql
CALL ProcessAppointment(
    @appointmentID INT,
    @consultationFee DECIMAL,
    @result OUT INT
);
```

**Execution**:
```sql
SET @appointmentID = 1;
SET @consultationFee = 500;
CALL ProcessAppointment(@appointmentID, @consultationFee, @result);
SELECT @result;  -- 1 = success, 0 = failure
```

**Steps**:
1. Validate appointment exists and is scheduled
2. Update appointment status to 'Completed'
3. Create billing record
4. Insert audit log entry
5. Return success/failure

---

### **2. IssuePrescription**

**Purpose**: Issue prescription with validation

**Syntax**:
```sql
CALL IssuePrescription(
    @appointmentID INT,
    @doctorID INT,
    @result OUT INT
);
```

**Execution**:
```sql
CALL IssuePrescription(1, 1, @result);
```

**Validation**:
- Appointment must exist
- Doctor must be appointment doctor
- Appointment must be completed
- No active prescription exists

---

### **3. ReorderMedicine**

**Purpose**: Check and reorder low-stock medicines

**Syntax**:
```sql
CALL ReorderMedicine(@threshold INT, OUT CURSOR results);
```

**Returns**: List of medicines below reorder level

**Execution**:
```sql
CALL ReorderMedicine(20);
-- Returns medicines where QuantityInStock < ReorderLevel
```

---

### **4. GenerateBillingReport**

**Purpose**: Generate billing summary for period

**Syntax**:
```sql
CALL GenerateBillingReport(
    @dateFrom DATE,
    @dateTo DATE,
    @departmentID INT,
    OUT CURSOR results
);
```

**Returns**:
- Total bills
- Total charges
- Insurance coverage
- Patient payments
- Outstanding amount

---

### **5. GetAvailableSlots**

**Purpose**: Get doctor's available appointment slots

**Syntax**:
```sql
CALL GetAvailableSlots(
    @doctorID INT,
    @appointmentDate DATE,
    OUT CURSOR results
);
```

**Returns**: List of available time slots

**Example**:
```sql
CALL GetAvailableSlots(1, '2026-10-15');
-- Returns: 09:00, 09:30, 10:00, 10:30, ...
-- Excludes already booked slots
```

---

## **ERROR HANDLING**

### **HTTP Status Codes**

```
200 OK - Successful GET, PUT request
201 Created - Successful POST request
204 No Content - Successful DELETE request
400 Bad Request - Invalid input validation failed
401 Unauthorized - Missing/invalid authentication token
403 Forbidden - Insufficient permissions
404 Not Found - Resource does not exist
409 Conflict - Business rule violation
500 Internal Server Error - Server error
```

### **Error Response Format**

```json
{
    "success": false,
    "error": {
        "code": "VALIDATION_ERROR",
        "message": "Validation failed",
        "details": [
            "phone: Invalid phone format",
            "email: Email already registered"
        ]
    },
    "timestamp": "2026-10-08T14:30:15Z"
}
```

### **Common Error Codes**

```
VALIDATION_ERROR - Input validation failed
AUTHORIZATION_ERROR - User not authorized
RESOURCE_NOT_FOUND - Entity does not exist
DUPLICATE_RECORD - Unique constraint violation
BUSINESS_RULE_VIOLATION - Business rule broken
DATABASE_ERROR - Database operation failed
INTERNAL_ERROR - Unexpected error
```

---

## **API SUMMARY**

**Total Endpoints**: 20+

| Category | Count | Operations |
|----------|-------|-----------|
| Patient | 5 | List, Get, Create, Update, Delete |
| Doctor | 3 | List, Get Schedule, Check Availability |
| Appointment | 4 | Book, List, Update Status, Cancel |
| Prescription | 2 | Issue, Get, Search Medicines |
| Billing | 3 | Get, Create, Record Payment |
| Total | 17+ | Complete CRUD operations |

**Stored Procedures**: 5+

| Procedure | Purpose |
|-----------|---------|
| ProcessAppointment | Complete appointment & billing |
| IssuePrescription | Issue prescription with validation |
| ReorderMedicine | Check low-stock medicines |
| GenerateBillingReport | Financial reports |
| GetAvailableSlots | Doctor availability |

---
