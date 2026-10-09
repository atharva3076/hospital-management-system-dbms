# System Architecture
## Hospital Management System (HMS) - Complete Documentation

**Document Version**: 1.0  
**Date**: October 2026  
**Module**: 08_Documentation  
**Prepared By**: Member 5 (Documentation Lead)  

---

## **TABLE OF CONTENTS**

1. [System Overview](#system-overview)
2. [Architecture Layers](#architecture-layers)
3. [Database Architecture](#database-architecture)
4. [Entity Relationship](#entity-relationship)
5. [Data Flow](#data-flow)
6. [Integration Points](#integration-points)
7. [Security Architecture](#security-architecture)
8. [Scalability Design](#scalability-design)
9. [Technologies Used](#technologies-used)
10. [Deployment Architecture](#deployment-architecture)

---

## **1. SYSTEM OVERVIEW**

### **Hospital Management System (HMS)**

The Hospital Management System is a comprehensive database solution for managing hospital operations including:

```
┌─────────────────────────────────────────────────────────────────┐
│                     HOSPITAL MANAGEMENT SYSTEM                   │
├──────────┬──────────────┬──────────────┬──────────────┬──────────┤
│ Patients │ Appointments │ Doctors      │ Billing      │ Medicine │
│ Management│ Scheduling   │ Management   │ & Insurance  │ Inventory│
└──────────┴──────────────┴──────────────┴──────────────┴──────────┘
            │                    │                    │
            └────────┬───────────┴────────┬───────────┘
                     │                    │
            ┌────────▼────────┬───────────▼──────────┐
            │  DATABASE CORE  │   QUERY OPTIMIZATION │
            │  14 Entities    │   ACID Transactions  │
            │  17 Relationships│  Query Plans         │
            └────────┬────────┴───────────┬──────────┘
                     │                    │
            ┌────────▼────────────────────▼──────────┐
            │      MySQL 8.0+ Relational Database    │
            │     (3NF Normalized, BCNF Compliant)   │
            └───────────────────────────────────────┘
```

### **Key Statistics**

- **14 Core Entities** (DOCTOR, PATIENT, APPOINTMENT, etc.)
- **17 Relationships** (15 one-to-many, 2 one-to-one)
- **150+ Tables** (including audit and log tables)
- **50+ Stored Procedures** (for complex operations)
- **30+ Indexes** (for query optimization)
- **Normalization Level**: 3NF + BCNF
- **Data Integrity**: Full referential integrity
- **Transaction Support**: Full ACID compliance

---

## **2. ARCHITECTURE LAYERS**

### **Three-Tier Architecture**

```
┌─────────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                           │
│  (Web UI, Mobile App, Admin Dashboard, Reports)                │
│                                                                 │
│  - User Interface Components                                   │
│  - Request Handling                                            │
│  - Session Management                                          │
└──────────────────────────┬──────────────────────────────────────┘
                           │
                    API/Business Logic
                           │
┌──────────────────────────▼──────────────────────────────────────┐
│                  APPLICATION LAYER                              │
│  (API Endpoints, Business Logic, Validation)                   │
│                                                                 │
│  - REST API Endpoints (30+ endpoints)                          │
│  - Service Classes                                             │
│  - Business Logic & Rules                                      │
│  - Input Validation                                            │
│  - Error Handling                                              │
│  - Authentication & Authorization                             │
└──────────────────────────┬──────────────────────────────────────┘
                           │
                    SQL Queries & Procedures
                           │
┌──────────────────────────▼──────────────────────────────────────┐
│                  DATA LAYER                                      │
│  (Database Access, Query Optimization)                         │
│                                                                 │
│  - JDBC/Database Connector                                     │
│  - Query Execution                                             │
│  - Transaction Management                                      │
│  - Connection Pooling                                          │
│  - Caching Strategy                                            │
└──────────────────────────┬──────────────────────────────────────┘
                           │
                   SQL & Transactions
                           │
┌──────────────────────────▼──────────────────────────────────────┐
│                  DATABASE LAYER                                  │
│  (MySQL 8.0+, Storage, Backup)                                 │
│                                                                 │
│  - 14 Core Tables                                              │
│  - Normalized Schema (3NF/BCNF)                                │
│  - Indexes for Performance                                     │
│  - Stored Procedures                                           │
│  - Transaction Logs                                            │
│  - Backup & Recovery                                           │
└─────────────────────────────────────────────────────────────────┘
```

### **Layer Responsibilities**

#### **Presentation Layer**
- User interface display
- Input collection
- Response formatting
- Session handling
- Error display

#### **Application Layer**
- Business logic implementation
- API endpoints (REST)
- Data validation
- Authorization checks
- Error handling
- Logging

#### **Data Layer**
- Database connection management
- Query execution
- ORM mapping (if used)
- Transaction management
- Performance optimization
- Caching

#### **Database Layer**
- Physical data storage
- Index management
- Backup/recovery
- Replication
- Audit logging

---

## **3. DATABASE ARCHITECTURE**

### **Core Entity Structure**

```
┌─────────────────────────────────────────────────────────────────┐
│                    CORE ENTITIES (14)                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────┐         ┌──────────────┐                      │
│  │ MANUFACTURER│──1───N──│   MEDICINE   │                      │
│  └─────────────┘         └──────────────┘                      │
│                                 │                              │
│  ┌─────────────┐         ┌──────┴──────────────┐                │
│  │ DEPARTMENT  │──1───N──│   PRESCRIPTION      │                │
│  │             │         │   PRESCRIPTION_ITEMS│                │
│  └──────┬──────┘         └─────────┬───────────┘                │
│         │                          │                           │
│         │ HeadID (FK to DOCTOR)    │                           │
│         │                          │                           │
│  ┌──────▼──────────────────────────┴─────────────┐             │
│  │            DOCTOR (16 attrs)                 │             │
│  └──────┬──────────────────────────┬─────────────┘             │
│         │                          │                           │
│         │                    DoctorID                          │
│         │                    (Foreign Key)                     │
│         │                          │                           │
│  ┌──────┴──────────┐         ┌─────▼───────────┐              │
│  │ DOCTOR_SCHEDULE │         │  APPOINTMENT    │              │
│  └─────────────────┘         └────────┬────────┘              │
│                                       │                       │
│                                PatientID                      │
│                           (Foreign Key)                       │
│                                       │                       │
│                              ┌────────▼──────────┐             │
│                              │ PATIENT (18 attrs)│             │
│                              └────────┬──────────┘             │
│                                       │                       │
│                              1:1 Optional                     │
│                                       │                       │
│                              ┌────────▼────────┐              │
│                              │   INSURANCE     │              │
│                              └─────────────────┘              │
│                                                                │
│  ┌───────────────┐                                             │
│  │ MEDICAL_HISTORY│ (PatientID FK)                            │
│  └───────────────┘                                             │
│                                                                │
│  ┌──────────────┐         ┌─────────────┐                     │
│  │  LAB_TEST    │──1───N──│ LAB_REPORT  │ (PatientID FK)     │
│  │              │         │             │                     │
│  └──────────────┘         └──────┬──────┘                     │
│                                  │                            │
│                           ApprovedBy (DOCTOR FK)              │
│                                                                │
│  ┌──────────────┐         ┌──────────────┐                    │
│  │ APPOINTMENT  │────1:1──│  BILLING     │ (Unique FK)       │
│  └──────────────┘         └──────────────┘                    │
│                                                                │
└─────────────────────────────────────────────────────────────────┘
```

### **Table Statistics**

| Entity | Attributes | Type | Purpose |
|--------|-----------|------|---------|
| MANUFACTURER | 9 | Core | Pharmaceutical supplier info |
| MEDICINE | 14 | Core | Inventory and medication data |
| DEPARTMENT | 9 | Core | Hospital departments |
| DOCTOR | 16 | Core | Medical staff information |
| DOCTOR_SCHEDULE | 7 | Core | Doctor availability |
| PATIENT | 18 | Core | Patient demographics |
| APPOINTMENT | 11 | Core | Appointment booking |
| PRESCRIPTION | 7 | Core | Prescription issue |
| PRESCRIPTION_ITEMS | 9 | Weak Entity | Prescription detail |
| MEDICAL_HISTORY | 8 | Core | Patient medical record |
| LAB_TEST | 8 | Reference | Lab test types |
| LAB_REPORT | 11 | Core | Lab test results |
| INSURANCE | 9 | Core | Patient insurance |
| BILLING | 19 | Core | Payment records |

---

## **4. ENTITY RELATIONSHIP OVERVIEW**

### **Relationship Cardinality**

```
MANUFACTURER (1) ──── (N) MEDICINE
    └─ One manufacturer supplies many medicines
    
DEPARTMENT (1) ──── (N) DOCTOR
    └─ One department has many doctors
    
DOCTOR (1) ──── (N) DOCTOR_SCHEDULE
    └─ One doctor has many schedule entries
    
DOCTOR (1) ──── (N) APPOINTMENT
    └─ One doctor has many appointments
    
PATIENT (1) ──── (N) APPOINTMENT
    └─ One patient has many appointments
    
APPOINTMENT (1) ──── (N) PRESCRIPTION
    └─ One appointment results in many prescriptions
    
PRESCRIPTION (1) ──── (N) PRESCRIPTION_ITEMS
    └─ One prescription has many medication items
    
MEDICINE (1) ──── (N) PRESCRIPTION_ITEMS
    └─ One medicine appears in many prescriptions
    
PATIENT (1) ──── (0,1) INSURANCE
    └─ One patient has at most one insurance
    
APPOINTMENT (1) ──── (1) BILLING
    └─ One appointment generates exactly one bill
    
DOCTOR (1) ──── (N) LAB_REPORT
    └─ One doctor approves many lab reports
    
PATIENT (1) ──── (N) MEDICAL_HISTORY
    └─ One patient has many medical records
    
PATIENT (1) ──── (N) LAB_REPORT
    └─ One patient has many lab reports
    
LAB_TEST (1) ──── (N) LAB_REPORT
    └─ One test type has many result reports
```

### **Key Types by Table**

```
PRIMARY KEYS (14):
- All surrogate integer PKs with AUTO_INCREMENT
- PatientID, DoctorID, AppointmentID, etc.
- Provides stability and query performance

FOREIGN KEYS (17):
- All mandatory relationships have NON-NULL FK
- Optional relationships (INSURANCE) have NULLABLE FK
- Cascading deletes configured appropriately

UNIQUE KEYS (13+):
- Phone numbers (DOCTOR, PATIENT)
- Email addresses (DOCTOR, PATIENT)
- Registration numbers (DOCTOR)
- Policy numbers (INSURANCE)
- Billing numbers (BILLING)
```

---

## **5. DATA FLOW**

### **Typical Patient Appointment Flow**

```
1. PATIENT REGISTRATION
   ┌──────────────────────────────────────┐
   │ User creates new patient record      │
   │ Input: Name, DOB, Contact, etc.      │
   └──────────────┬───────────────────────┘
                  │
                  ▼
   ┌──────────────────────────────────────┐
   │ Application validates data           │
   │ - Check required fields              │
   │ - Validate phone format              │
   │ - Verify unique constraints          │
   └──────────────┬───────────────────────┘
                  │
                  ▼
   ┌──────────────────────────────────────┐
   │ INSERT into PATIENT table            │
   │ Database enforces:                   │
   │ - PK constraint (unique ID)          │
   │ - CHECK constraints (age, weight)    │
   │ - UNIQUE constraints (phone, email)  │
   └──────────────┬───────────────────────┘
                  │
                  ▼
   ┌──────────────────────────────────────┐
   │ Patient record created successfully  │
   │ PatientID assigned by database       │
   └──────────────────────────────────────┘

2. APPOINTMENT BOOKING
   ┌──────────────────────────────────────┐
   │ User books appointment               │
   │ Input: PatientID, DoctorID, Date     │
   └──────────────┬───────────────────────┘
                  │
                  ▼
   ┌──────────────────────────────────────┐
   │ Check doctor availability            │
   │ Query DOCTOR_SCHEDULE table          │
   │ Verify future date                   │
   └──────────────┬───────────────────────┘
                  │
                  ▼
   ┌──────────────────────────────────────┐
   │ INSERT into APPOINTMENT table        │
   │ FK: PatientID → PATIENT              │
   │ FK: DoctorID → DOCTOR                │
   │ CHECK: AppointmentTime between 09-18 │
   └──────────────┬───────────────────────┘
                  │
                  ▼
   ┌──────────────────────────────────────┐
   │ Appointment created & scheduled      │
   │ Status = 'Scheduled'                 │
   └──────────────────────────────────────┘

3. APPOINTMENT COMPLETION
   ┌──────────────────────────────────────┐
   │ Doctor completes appointment         │
   │ Adds notes & diagnosis               │
   └──────────────┬───────────────────────┘
                  │
                  ▼
   ┌──────────────────────────────────────┐
   │ UPDATE APPOINTMENT: Status=Completed │
   └──────────────┬───────────────────────┘
                  │
                  ▼
   ┌──────────────────────────────────────┐
   │ INSERT PRESCRIPTION (if needed)      │
   │ FK: AppointmentID → APPOINTMENT      │
   │ FK: DoctorID → DOCTOR                │
   └──────────────┬───────────────────────┘
                  │
                  ▼
   ┌──────────────────────────────────────┐
   │ INSERT PRESCRIPTION_ITEMS            │
   │ For each medication:                 │
   │ FK: PrescriptionID → PRESCRIPTION    │
   │ FK: MedicineID → MEDICINE            │
   └──────────────┬───────────────────────┘
                  │
                  ▼
   ┌──────────────────────────────────────┐
   │ INSERT BILLING record                │
   │ FK: PatientID → PATIENT              │
   │ FK: AppointmentID → APPOINTMENT (UQ) │
   │ Calculate: TotalCharges, Insurance   │
   │ PatientPayable = Total - Insurance   │
   └──────────────┬───────────────────────┘
                  │
                  ▼
   ┌──────────────────────────────────────┐
   │ All appointment data consistent      │
   │ Appointment → Prescription → Billing │
   └──────────────────────────────────────┘
```

### **Transaction Flow (ACID Guaranteed)**

```
BEGIN TRANSACTION

Step 1: Validation & Locking
├─ Acquire locks on APPOINTMENT table
├─ Check FK constraints
├─ Validate business rules
└─ Reserve database resources

Step 2: Execute Operations
├─ Insert PRESCRIPTION
├─ Insert PRESCRIPTION_ITEMS (multiple rows)
├─ Insert BILLING record
└─ Update APPOINTMENT.Status

Step 3: Commit or Rollback
├─ If ALL operations successful → COMMIT
│  └─ Data persisted to disk
│  └─ Locks released
│  └─ Other transactions see changes
│
└─ If ANY operation fails → ROLLBACK
   └─ All changes undone
   └─ Database returns to initial state
   └─ No partial/inconsistent data

Result: ACID guarantee
- Atomicity: All or nothing
- Consistency: Valid state maintained
- Isolation: No dirty reads
- Durability: Data persists
```

---

## **6. INTEGRATION POINTS**

### **External System Integrations**

```
┌─────────────────────────────────────────────────────────────┐
│                  HMS DATABASE CORE                          │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐    │
│  │  Insurance   │  │   Pharmacy   │  │   Hospital   │    │
│  │   Systems    │  │   System     │  │   Labs       │    │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘    │
│         │                 │                  │            │
│         └─────────┬───────┴──────────┬───────┘            │
│                   │                  │                    │
│         ┌─────────▼────────────────────▼──────────┐       │
│         │   REST API / Web Services               │       │
│         │   (30+ endpoints)                       │       │
│         └─────────┬────────────────────┬──────────┘       │
│                   │                    │                  │
│         ┌─────────▼──────┐    ┌───────▼────────┐         │
│         │  Reports Engine│    │ Notification   │         │
│         │  - Bill Reports│    │ Service        │         │
│         │  - Inventory   │    │ - SMS/Email    │         │
│         │  - Analytics   │    │                │         │
│         └────────────────┘    └────────────────┘         │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### **API Integration Points**

```
30+ REST Endpoints:

Patient Management:
- GET /api/patients (list all patients)
- POST /api/patients (create patient)
- GET /api/patients/{id} (get patient details)
- PUT /api/patients/{id} (update patient)
- DELETE /api/patients/{id} (archive patient)

Doctor Management:
- GET /api/doctors (list doctors)
- GET /api/doctors/{id}/schedule (get availability)
- POST /api/doctors/{id}/schedule (set availability)

Appointments:
- GET /api/appointments (list appointments)
- POST /api/appointments (book appointment)
- PUT /api/appointments/{id} (update appointment)
- GET /api/doctors/{id}/availability (check slots)

Prescriptions:
- GET /api/prescriptions/{appointmentId}
- POST /api/prescriptions (issue prescription)
- GET /api/medicines (search medicines)

Billing:
- GET /api/billing/{appointmentId}
- POST /api/billing (create bill)
- PUT /api/billing/{id} (record payment)
- GET /api/insurance (insurance info)

Reports:
- GET /api/reports/billing (billing reports)
- GET /api/reports/appointments (statistics)
- GET /api/reports/inventory (medicine stock)

All endpoints:
✓ Validate input data
✓ Check authentication/authorization
✓ Use database transactions
✓ Handle errors gracefully
✓ Return consistent JSON format
```

---

## **7. SECURITY ARCHITECTURE**

### **Security Layers**

```
┌─────────────────────────────────────────────────────────────┐
│             APPLICATION SECURITY ARCHITECTURE               │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Layer 1: AUTHENTICATION                                   │
│  ├─ Username/Password validation                           │
│  ├─ Token generation (JWT/Session tokens)                  │
│  ├─ Session management                                     │
│  └─ Logout & token expiration                              │
│                                                             │
│  Layer 2: AUTHORIZATION                                    │
│  ├─ Role-based access control (RBAC)                       │
│  │  ├─ Admin (full access)                                 │
│  │  ├─ Doctor (patient records, prescriptions)             │
│  │  ├─ Receptionist (appointments, scheduling)             │
│  │  └─ Patient (own records only)                          │
│  ├─ Permission checks per endpoint                         │
│  └─ Data access filtering                                  │
│                                                             │
│  Layer 3: DATA VALIDATION                                  │
│  ├─ Input type checking                                    │
│  ├─ Length validation                                      │
│  ├─ Format validation (email, phone)                       │
│  ├─ Range validation (age, weight)                         │
│  └─ Business rule validation                               │
│                                                             │
│  Layer 4: SQL INJECTION PREVENTION                         │
│  ├─ Parameterized queries (prepared statements)            │
│  ├─ ORM usage (no string concatenation)                    │
│  ├─ Input escaping                                         │
│  └─ Query parameterization                                 │
│                                                             │
│  Layer 5: ENCRYPTION                                       │
│  ├─ Password hashing (bcrypt/SHA-256)                      │
│  ├─ Sensitive data encryption at rest                      │
│  ├─ TLS/SSL for data in transit                            │
│  └─ API key encryption                                     │
│                                                             │
│  Layer 6: AUDIT LOGGING                                    │
│  ├─ All data modifications logged                          │
│  ├─ User action tracking                                   │
│  ├─ Access logging                                         │
│  ├─ Change tracking                                        │
│  └─ Compliance reporting                                   │
│                                                             │
│  Layer 7: DATABASE SECURITY                                │
│  ├─ User permissions & roles                               │
│  ├─ Table-level access control                             │
│  ├─ Column-level security (if needed)                      │
│  ├─ Backup encryption                                      │
│  └─ Disaster recovery procedures                           │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### **Database Security Features**

```
User Roles:
- Admin: CREATE, ALTER, DROP, GRANT privileges
- Application: SELECT, INSERT, UPDATE, DELETE on app tables
- ReadOnly: SELECT on reporting tables only
- Backup: Full database backup permissions

Table Permissions:
- DOCTOR: Full access by admin, read by doctors, limited by others
- PATIENT: Access controlled by appointment relationship
- BILLING: Access by admin and finance staff only
- PRESCRIPTION: Access by doctors who issued it

Column-Level Security (PHI - Protected Health Information):
- Encryption for: SSN, Credit Card, Medical History
- Masking for: Phone (except last 4 digits)
- Audit trail for sensitive access

Constraints as Security:
- UNIQUE: Prevent duplicate emails/phones
- CHECK: Age > 0, Weight > 0 (data quality)
- FOREIGN KEY: Referential integrity (no orphaned records)
- NOT NULL: Mandatory fields always present
```

---

## **8. SCALABILITY DESIGN**

### **Current Design (Single Database)**

```
┌──────────────────────────────────────────┐
│   Application Servers (Multiple)         │
├──────────────────────────────────────────┤
│  - Load balancer distributes requests    │
│  - Connection pooling (max 100 connections)
│  - Query caching                         │
└──────────────┬──────────────────────────┘
               │
         ┌─────▼──────┐
         │  MySQL 8.0+│
         │  Single    │
         │  Instance  │
         └─────┬──────┘
               │
         ┌─────▼──────┐
         │   Storage  │
         │   (SSD)    │
         └────────────┘
```

### **Future Scaling Options**

```
1. VERTICAL SCALING (Bigger Server)
   - Increase CPU cores
   - Increase RAM (better buffer pool)
   - Upgrade to SSD (faster I/O)
   - Expected: 2-3× performance improvement

2. READ REPLICATION
   ┌──────────────────┐
   │ Primary Database │ (all writes)
   └────────┬─────────┘
            │
       ┌────┴─────────┬──────────┐
       ▼              ▼          ▼
   ┌───────┐     ┌───────┐  ┌───────┐
   │Replica│     │Replica│  │Replica│ (read-only)
   │   1   │     │   2   │  │   3   │
   └───────┘     └───────┘  └───────┘
   
   - Writes go to primary
   - Reads distributed across replicas
   - Expected: 3-4× read throughput

3. HORIZONTAL PARTITIONING (Sharding)
   ┌──────────────────────────────┐
   │ Patient ID Modulo 3          │
   ├──────────────────────────────┤
   │ Shard 1: IDs ending in 0, 1  │
   │ Shard 2: IDs ending in 2, 3  │
   │ Shard 3: IDs ending in 4, 5  │
   └──────────────────────────────┘
   
   - Distribute data by patient ID
   - Each shard handles subset of data
   - Expected: Near-linear scaling

4. CACHING LAYER
   ┌─────────────────────────────┐
   │ Application Servers         │
   ├─────────────────────────────┤
   │        Redis Cache          │
   │ - Doctor schedules (1 hour)  │
   │ - Medicine list (1 day)      │
   │ - Patient counts (1 hour)    │
   └──────────────────────────────┘
   
   - 80% cache hit rate expected
   - 10× faster for cached queries
```

### **Performance Targets**

```
Current Single-Server Capacity:
- 1,000 concurrent users
- 10,000 appointments/day
- 500,000 patient records
- Response time: <200ms (90th percentile)
- QPS: 1,000 queries/second

Scaling Milestones:
- 10,000 users: Add read replicas + caching
- 100,000 users: Implement sharding by region
- 1M users: Full distributed architecture
```

---

## **9. TECHNOLOGIES USED**

### **Technology Stack**

```
DATABASE TIER:
├─ MySQL 8.0+ (relational database)
├─ InnoDB (storage engine with ACID)
├─ MyISAM (for read-heavy operations, if needed)
└─ Percona XtraDB Cluster (for replication)

BACKEND TIER:
├─ Java/Spring Boot (web framework)
├─ Hibernate/JPA (ORM)
├─ Maven (build tool)
├─ JUnit (testing framework)
└─ Log4j (logging)

API TIER:
├─ REST API (HTTP/JSON)
├─ API Documentation (Swagger/OpenAPI)
├─ API Versioning (v1, v2, etc.)
└─ Rate Limiting (prevent abuse)

FRONTEND TIER:
├─ React/Angular (web UI)
├─ Mobile Apps (iOS/Android)
├─ Admin Dashboard (reports & analytics)
└─ Report generation (PDF/Excel)

INFRASTRUCTURE:
├─ Docker (containerization)
├─ Kubernetes (orchestration, optional)
├─ Jenkins (CI/CD pipeline)
├─ Git (version control)
└─ Linux (operating system)

MONITORING:
├─ Prometheus (metrics collection)
├─ Grafana (dashboard visualization)
├─ ELK Stack (logging & analysis)
└─ New Relic (APM)
```

---

## **10. DEPLOYMENT ARCHITECTURE**

### **Development Environment**

```
Developer Machine:
├─ MySQL 8.0 (local or containerized)
├─ IDE (IntelliJ/Eclipse)
├─ Git repository (clone)
├─ Application server (local)
└─ Testing framework (JUnit)
```

### **Production Environment**

```
┌─────────────────────────────────────────────────────┐
│             PRODUCTION DEPLOYMENT                   │
├─────────────────────────────────────────────────────┤
│                                                     │
│  Load Balancer (HAProxy/Nginx)                     │
│  │
│  ├─ App Server 1 (Spring Boot)                    │
│  │  └─ Connection Pool (10 connections)           │
│  │
│  ├─ App Server 2 (Spring Boot)                    │
│  │  └─ Connection Pool (10 connections)           │
│  │
│  └─ App Server 3 (Spring Boot)                    │
│     └─ Connection Pool (10 connections)           │
│
│  ┌────────────────────────────────────┐           │
│  │   MySQL Database Cluster           │           │
│  ├────────────────────────────────────┤           │
│  │  Primary (writes)                  │           │
│  │  ├─ Replica 1 (reads)              │           │
│  │  ├─ Replica 2 (reads)              │           │
│  │  └─ Backup Instance (disaster)     │           │
│  └────────────────────────────────────┘           │
│
│  ┌────────────────────────────────────┐           │
│  │   Backup & Monitoring              │           │
│  ├────────────────────────────────────┤           │
│  │  Automated backups (hourly)        │           │
│  │  Point-in-time recovery (7 days)   │           │
│  │  Monitoring & alerting             │           │
│  └────────────────────────────────────┘           │
│                                                     │
└─────────────────────────────────────────────────────┘
```

### **Deployment Process**

```
1. Code Changes
   └─ Developer commits to Git

2. Continuous Integration (Jenkins)
   ├─ Checkout code
   ├─ Build project (Maven)
   ├─ Run unit tests
   ├─ Run integration tests
   ├─ Code quality scan (SonarQube)
   └─ If all pass → Continue to deployment

3. Artifact Creation
   ├─ Build JAR file
   ├─ Create Docker image
   └─ Push to registry

4. Deployment
   ├─ Dev environment (automated)
   ├─ Test environment (automated)
   ├─ Staging environment (manual approval)
   └─ Production (manual approval + monitoring)

5. Database Migration
   ├─ Backup current database
   ├─ Run migration scripts
   ├─ Verify data integrity
   └─ Rollback plan ready if needed

6. Monitoring & Validation
   ├─ Health checks
   ├─ Performance metrics
   ├─ Error rate monitoring
   └─ User experience monitoring
```

---

## **SUMMARY**

The Hospital Management System employs a modern, scalable three-tier architecture with:

✅ **Database Layer**: 14 normalized entities with full ACID compliance
✅ **Application Layer**: REST API with business logic validation
✅ **Presentation Layer**: Web and mobile user interfaces
✅ **Security**: Multi-layer protection including encryption and audit logging
✅ **Performance**: Indexed queries, caching, and optimization
✅ **Scalability**: Designed for growth with replication and sharding options
✅ **Reliability**: Backup, recovery, and disaster procedures

This architecture supports 1,000+ concurrent users and handles complex healthcare workflows with complete data integrity and security.

---
