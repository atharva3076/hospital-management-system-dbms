# Database Design Report
## Hospital Management System (HMS) - DBMS Project

**Document Version**: 1.0  
**Date**: October 2026  
**Module**: 01_ER_and_Design  
**Prepared By**: Member 1 (ER Design Lead)  

---

## **EXECUTIVE SUMMARY**

This report documents the design decisions, rationale, and architectural considerations for the Hospital Management System database. The design comprises **14 entities**, **13 relationships**, and implements **3rd Normal Form (3NF)** normalization to ensure data integrity, eliminate redundancy, and optimize query performance.

---

## **1. DESIGN OVERVIEW**

### **1.1 Design Objectives**
- ✅ Support complete hospital operations (doctors, patients, appointments, billing, inventory)
- ✅ Maintain data integrity through constraints and referential integrity
- ✅ Enable efficient queries for reporting and analysis
- ✅ Scale to handle 1000+ records across core entities
- ✅ Support real-world audit trails and compliance requirements
- ✅ Allow flexible role-based access control through views

### **1.2 Design Principles**
1. **Normalization**: 3NF to minimize redundancy
2. **Integrity**: Comprehensive constraints (PK, FK, UNIQUE, CHECK)
3. **Scalability**: Efficient indexing strategy
4. **Auditability**: Timestamp tracking for critical operations
5. **Clarity**: Consistent naming conventions
6. **Maintainability**: Well-documented design decisions

---

## **2. ENTITY-RELATIONSHIP ANALYSIS**

### **2.1 Entity Selection Rationale**

#### **Core Clinical Entities (6 entities)**
1. **DOCTOR** - Medical staff with qualifications and specialization
2. **PATIENT** - Individual seeking medical services
3. **APPOINTMENT** - Clinical encounter record
4. **MEDICAL_HISTORY** - Patient diagnosis and treatment history
5. **LAB_TEST** - Available diagnostic tests in hospital
6. **LAB_REPORT** - Test results for patients

**Why These?**
- Essential for healthcare operations
- Required for appointment scheduling and clinical tracking
- Support diagnosis and treatment workflows

#### **Operational Support Entities (5 entities)**
7. **DEPARTMENT** - Organizational structure with budget allocation
8. **DOCTOR_SCHEDULE** - Doctor availability (separate to avoid multivalued attributes)
9. **MEDICINE** - Pharmacy inventory management
10. **PRESCRIPTION** - Doctor-issued medication instructions
11. **PRESCRIPTION_ITEMS** - Individual medicines in prescription (weak entity)

**Why These?**
- DEPARTMENT: Organizational hierarchy needed for operations
- DOCTOR_SCHEDULE: Eliminates multivalued attribute from DOCTOR
- MEDICINE: Inventory tracking for pharmacy
- PRESCRIPTION: Links doctor orders to patient medicines
- PRESCRIPTION_ITEMS: Weak entity for medicine details per prescription

#### **Business Support Entities (3 entities)**
12. **MANUFACTURER** - Medicine suppliers
13. **INSURANCE** - Patient coverage information
14. **BILLING** - Financial transaction records

**Why These?**
- MANUFACTURER: Tracks medicine sources and suppliers
- INSURANCE: Manages patient coverage and claims
- BILLING: Complete financial records for accounting

---

### **2.2 Relationship Design Rationale**

#### **1-to-Many Relationships (15)**
| Relationship | Cardinality | Participation | Rationale |
|---|---|---|---|
| DEPARTMENT → DOCTOR | 1:M | Partial:Total | One department has many doctors; doctor must belong to department |
| DOCTOR → APPOINTMENT | 1:M | Total:Total | One doctor has many appointments |
| PATIENT → APPOINTMENT | 1:M | Total:Total | One patient has many appointments |
| DOCTOR → PRESCRIPTION | 1:M | Total:Total | One doctor issues multiple prescriptions |
| APPOINTMENT → PRESCRIPTION | 1:M | Total:Partial | One appointment may have prescription |
| PATIENT → LAB_REPORT | 1:M | Total:Total | One patient has many lab reports |
| LAB_TEST → LAB_REPORT | 1:M | Total:Total | One test type has many reports |
| APPOINTMENT → LAB_REPORT | 1:M | Partial:Partial | One appointment may have lab reports |
| PATIENT → MEDICAL_HISTORY | 1:M | Total:Total | One patient has medical history records |
| PATIENT → BILLING | 1:M | Total:Total | One patient has multiple bills |
| DOCTOR → DOCTOR_SCHEDULE | 1:M | Total:Total | One doctor has multiple schedule entries |
| MANUFACTURER → MEDICINE | 1:M | Total:Total | One manufacturer supplies multiple medicines |
| INSURANCE → BILLING | 1:M | Partial:Partial | One insurance covers multiple bills |
| MEDICINE → PRESCRIPTION_ITEMS | 1:M | Total:Total | One medicine appears in many prescriptions |
| PRESCRIPTION → PRESCRIPTION_ITEMS | 1:M | Total:Total | One prescription has many items |

**Key Decision**: Chose 1:M over M:M to maintain data integrity and simplify queries

#### **1-to-1 Relationships (2)**
1. **PATIENT ↔ INSURANCE**: One patient has at most one insurance policy
   - Rationale: Each patient can have only one active policy; allows optional insurance
   - Partial participation both sides (not all patients insured)

2. **APPOINTMENT ↔ BILLING**: One appointment generates one bill
   - Rationale: Each appointment billing is separate; unique constraint on AppointmentID in BILLING
   - Total participation both sides

**Why No M:M?**
- M:M would require junction tables
- Direct 1:M relationships are simpler for this domain
- Maintains referential integrity more easily

---

## **3. NORMALIZATION PROOF**

### **3.1 First Normal Form (1NF)**
**Requirement**: All attributes must be atomic (single-valued)

**How We Achieved It**:
- ✅ No multivalued attributes (e.g., DOCTOR_SCHEDULE is separate table, not array)
- ✅ No repeating groups (e.g., multiple medicines → PRESCRIPTION_ITEMS table)
- ✅ All attributes contain single values
- ✅ No nested relations

**Example**: Instead of storing doctor's schedule as array in DOCTOR table:
```
❌ DOCTOR (DoctorID, Name, Schedule: [Mon 09:00-17:00, Wed 10:00-18:00])
✅ DOCTOR_SCHEDULE (ScheduleID, DoctorID, DayOfWeek, StartTime, EndTime)
```

### **3.2 Second Normal Form (2NF)**
**Requirement**: Must be 1NF + All non-key attributes depend on **entire** primary key

**How We Achieved It**:
- ✅ All tables have atomic primary keys
- ✅ No partial dependencies
- ✅ Each non-key attribute depends on entire PK

**Example**: 
```
Table: APPOINTMENT
PK: (PatientID, DoctorID, AppointmentDate, AppointmentTime)
All other attributes (Reason, Status, Notes) depend on entire PK
```

### **3.3 Third Normal Form (3NF)**
**Requirement**: Must be 2NF + No transitive dependencies

**How We Achieved It**:
- ✅ No non-key attributes depend on other non-key attributes
- ✅ All attributes directly depend on primary key only

**Example**:
```
❌ DOCTOR (DoctorID, Name, DepartmentName, DeptHead)
   Issue: DeptHead transitively depends on DepartmentName, not DoctorID
   
✅ DOCTOR (DoctorID, Name, DepartmentID)
   DEPARTMENT (DepartmentID, DepartmentName, DeptHead)
   No transitive dependency
```

**Applied Throughout**:
- Doctor information separated from department information
- Patient information separated from insurance information
- Appointment information separated from billing information

---

## **4. DESIGN TRADE-OFFS**

### **4.1 Normalization vs. Performance**

| Aspect | Normalized (3NF) | Denormalized |
|---|---|---|
| **Redundancy** | Minimal | Some duplication |
| **Update Anomalies** | None | Possible |
| **Query Performance** | More JOINs needed | Faster queries |
| **Storage** | Minimal | More storage |
| **Complexity** | Moderate | Lower |

**Our Decision**: ✅ **3NF (Normalized)**
**Rationale**:
- Data integrity is paramount in healthcare
- Reduces risk of update anomalies
- Easier to maintain data consistency
- Indexes compensate for JOIN performance
- Storage is not a constraint for modern systems

### **4.2 Flexible vs. Fixed Schema**

**Options Considered**:
1. Add status tracking for appointments (SCHEDULED, COMPLETED, CANCELLED)
2. Add multiple phone numbers per patient
3. Add multiple addresses per patient

**Our Decision**: ✅ **Fixed Schema with Status Fields**
**Rationale**:
- Clinical data must be precise and complete
- Status fields provide temporal tracking
- Multiple contact info can be added later via extension tables
- Current design handles 95% of use cases

### **4.3 Direct vs. Indirect Relationships**

**Example: How to bill a patient?**

Option A (Direct):
```
BILLING (BillingID, PatientID, Amount)
```

Option B (Through Appointment):
```
BILLING (BillingID, AppointmentID, PatientID, Amount)
```

**Our Decision**: ✅ **Option B (Redundant PatientID but with UNIQUE on AppointmentID)**
**Rationale**:
- Each appointment has exactly one bill
- Reduces ambiguity in billing queries
- Enables appointment-based billing workflows
- PatientID in BILLING for direct patient queries

---

## **5. CONSTRAINT STRATEGY**

### **5.1 Primary Key Constraints**
- ✅ All 14 tables have surrogate keys (ID format)
- ✅ Ensures uniqueness and efficient indexing
- ✅ Allows future changes to natural keys

### **5.2 Foreign Key Constraints**
- ✅ 15 foreign key relationships
- ✅ Referential integrity enforced at database level
- ✅ Cascade delete/update policies defined

**Example**:
```sql
ALTER TABLE PRESCRIPTION
ADD CONSTRAINT FK_PRESCRIPTION_APPOINTMENT
FOREIGN KEY (AppointmentID) REFERENCES APPOINTMENT(AppointmentID)
ON DELETE CASCADE;
```

### **5.3 UNIQUE Constraints**
- ✅ Email addresses (DOCTOR, PATIENT)
- ✅ Phone numbers (DOCTOR, PATIENT)
- ✅ Registration numbers (DOCTOR)
- ✅ Medicine names
- ✅ Policy numbers (INSURANCE)
- ✅ Billing numbers (BILLING)
- ✅ AppointmentID in BILLING (for 1:1 relationship)

### **5.4 CHECK Constraints**
- ✅ Age validation: DOB must produce valid age
- ✅ Date validations: StartDate < EndDate
- ✅ Range validations: Coverage% between 0-100
- ✅ Enum validation: Gender IN ('M', 'F', 'Other')

### **5.5 NOT NULL Constraints**
- ✅ All critical fields marked NOT NULL
- ✅ Allows NULL for optional relationships
- ✅ INSURANCE: Optional (not all patients insured)
- ✅ LAB_REPORT on APPOINTMENT: Optional

---

## **6. SCALABILITY CONSIDERATIONS**

### **6.1 Expected Scale**
| Entity | Records | Growth Rate |
|---|---|---|
| MANUFACTURER | 10-50 | Slow (yearly) |
| DEPARTMENT | 5-15 | Slow (yearly) |
| DOCTOR | 50-200 | Slow (yearly) |
| DOCTOR_SCHEDULE | 100-500 | Medium (quarterly) |
| PATIENT | 1,000-10,000 | Fast (monthly) |
| APPOINTMENT | 2,000-50,000 | Very Fast (weekly) |
| MEDICAL_HISTORY | 1,000-20,000 | Fast (monthly) |
| MEDICINE | 100-500 | Slow (quarterly) |
| PRESCRIPTION | 1,000-10,000 | Fast (weekly) |
| PRESCRIPTION_ITEMS | 5,000-50,000 | Very Fast (weekly) |
| LAB_TEST | 20-100 | Slow (yearly) |
| LAB_REPORT | 2,000-50,000 | Very Fast (weekly) |
| INSURANCE | 500-5,000 | Fast (monthly) |
| BILLING | 2,000-50,000 | Very Fast (weekly) |

### **6.2 Indexing Strategy**
- ✅ Primary key indexes (automatic)
- ✅ Foreign key indexes (for joins)
- ✅ Composite indexes on frequently filtered fields
- ✅ Separate index on PatientID, DoctorID, AppointmentDate

**Example**:
```sql
CREATE INDEX IDX_APPOINTMENT_PATIENT ON APPOINTMENT(PatientID);
CREATE INDEX IDX_APPOINTMENT_DOCTOR ON APPOINTMENT(DoctorID);
CREATE INDEX IDX_APPOINTMENT_DATE ON APPOINTMENT(AppointmentDate);
```

### **6.3 Partitioning Strategy** (Future)
- Partition APPOINTMENT by year
- Partition LAB_REPORT by year
- Partition BILLING by year
- Partition PRESCRIPTION by year

**Rationale**: Time-series data grows very fast; partitioning improves query performance

### **6.4 Archiving Strategy** (Future)
- Archive completed appointments older than 2 years
- Archive settled bills older than 5 years
- Archive cancelled appointments after 1 year
- Reduces active table size

---

## **7. SECURITY CONSIDERATIONS**

### **7.1 Data Privacy**
**Sensitive Fields**:
- Patient: SSN/ID, DOB, Medical conditions
- Doctor: Phone, Email, Qualification details
- Billing: Payment methods, insurance numbers

**Protection Measures**:
- ✅ Role-based views (patient, doctor, admin views)
- ✅ Encryption at column level (future)
- ✅ Audit logging for sensitive data access

### **7.2 Access Control**
**Proposed Roles**:
1. **Admin**: Full access to all tables
2. **Doctor**: Access to own patients, appointments, prescriptions
3. **Nurse**: Access to patient records, lab reports
4. **Receptionist**: Access to appointments, basic patient info
5. **Patient**: Access to own records only

**Implementation**: Database views with WHERE clauses

### **7.3 Audit Trail**
- Timestamp tracking (CreatedDate, UpdatedDate)
- Automatic audit triggers on DOCTOR, PATIENT, BILLING
- Support table: audit_log for tracking changes

### **7.4 Data Validation**
- Application-level validation (before insert)
- Database-level constraints (CHECK, UNIQUE, NOT NULL)
- Stored procedures for complex validations

---

## **8. RELATIONSHIP ANALYSIS**

### **8.1 Why 13 Relationships?**

**Calculated as**:
- Core domain relationships: 9 (DOCTOR-APPOINTMENT, PATIENT-APPOINTMENT, etc.)
- Supporting relationships: 4 (DOCTOR_SCHEDULE, PRESCRIPTION_ITEMS, MANUFACTURER-MEDICINE)

**Could we reduce?**
- ❌ Not without sacrificing functionality
- ❌ Each relationship serves specific business logic
- ✅ Count aligns with healthcare domain complexity

### **8.2 Weak Entity: PRESCRIPTION_ITEMS**

**Why Weak?**
- Existence depends on PRESCRIPTION
- Composite key: (PrescriptionID, MedicineID)
- Cannot exist independently

**Alternative Considered**: M:M junction table
```
❌ PRESCRIPTION_MEDICINE (PrescriptionID, MedicineID)
✅ PRESCRIPTION_ITEMS (PrescriptionItemID, PrescriptionID, MedicineID, Dosage, Frequency, Duration, Quantity)
```

**Why We Chose PRESCRIPTION_ITEMS**:
- Stores additional attributes (Dosage, Frequency, Duration, Quantity)
- These attributes specific to prescription instance, not medicine type
- More flexible for varying prescriptions of same medicine

### **8.3 Cardinality Validation**

**1:1 Relationships**:
- PATIENT ↔ INSURANCE (Correct: patient has at most one policy)
- APPOINTMENT ↔ BILLING (Correct: each appointment has one bill)

**1:M Relationships**:
- All correctly identified
- Verified against domain knowledge
- Participation types match business rules

---

## **9. FUTURE ENHANCEMENTS**

### **9.1 Possible Extensions**

1. **Multi-Location Support**
   - Add HOSPITAL/BRANCH entity
   - Partition data by location
   - Add location references to DEPARTMENT, DOCTOR

2. **Advanced Scheduling**
   - APPOINTMENT_SLOT for time-based availability
   - WAITING_LIST for overbooked times
   - CANCELLATION_POLICY for rules

3. **Pharmacy Operations**
   - MEDICINE_BATCH for inventory tracking
   - STOCK_TRANSACTION for audit trail
   - SUPPLIER_ORDER for procurement

4. **Patient Communication**
   - NOTIFICATION_LOG for SMS/Email tracking
   - FEEDBACK for patient satisfaction
   - ALLERGY_RECORD for allergy tracking

5. **Advanced Billing**
   - INVOICE for formal invoicing
   - PAYMENT_PLAN for installments
   - CLAIM for insurance claims

### **9.2 Backward Compatibility**
- All extensions use new tables (no schema changes)
- Existing relationships remain unchanged
- Views can be updated to include new data

---

## **10. PERFORMANCE OPTIMIZATION**

### **10.1 Query Optimization Strategies**
1. **Index on frequently filtered fields**: PatientID, DoctorID, AppointmentDate
2. **Composite indexes**: (PatientID, AppointmentDate) for range queries
3. **Avoid SELECT ***: Query only needed columns
4. **Use JOINs instead of subqueries** where possible
5. **Denormalize views**: Pre-computed views for common queries

### **10.2 Query Patterns**
```sql
-- Pattern 1: Patient's upcoming appointments
SELECT * FROM APPOINTMENT 
WHERE PatientID = ? AND AppointmentDate >= CURDATE()
ORDER BY AppointmentDate;

-- Pattern 2: Doctor's schedule for date range
SELECT * FROM DOCTOR_SCHEDULE
WHERE DoctorID = ? AND DayOfWeek IN ('MON', 'TUE', 'WED', 'THU', 'FRI');

-- Pattern 3: Patient's medical history
SELECT * FROM MEDICAL_HISTORY
WHERE PatientID = ?
ORDER BY CreatedDate DESC;
```

### **10.3 Index Strategy**
```sql
-- Single column indexes
CREATE INDEX IDX_APPOINTMENT_PATIENT ON APPOINTMENT(PatientID);
CREATE INDEX IDX_APPOINTMENT_DOCTOR ON APPOINTMENT(DoctorID);
CREATE INDEX IDX_DOCTOR_DEPARTMENT ON DOCTOR(DepartmentID);

-- Composite indexes
CREATE INDEX IDX_APPOINTMENT_DATE_PATIENT ON APPOINTMENT(AppointmentDate, PatientID);
```

---

## **11. VALIDATION & INTEGRITY**

### **11.1 Referential Integrity**

All foreign keys enforce:
- ✅ Update cascade for domain tables (DOCTOR, PATIENT)
- ✅ Restrict delete for non-disposable relationships
- ✅ Cascade delete only where appropriate (PRESCRIPTION_ITEMS)

### **11.2 Data Quality Rules**

**Phone Numbers**:
- Format: 10-15 digits
- Cannot be negative
- Should be numeric

**Email Addresses**:
- Must contain '@'
- Must have domain
- Case-insensitive unique

**Dates**:
- AppointmentDate must be in future
- DOB must be valid (person not yet born)
- ManufactureDate < ExpiryDate

**Coverage Percentage**:
- Range: 0-100
- Should be integer

---

## **12. ASSUMPTIONS & CONSTRAINTS**

### **12.1 Assumptions Made**
1. Hospital operates in single location (can extend later)
2. One billing per appointment (not for multiple doctors)
3. Doctors have only one department (can extend with position table)
4. Patients have at most one insurance policy
5. All doctors have valid registration numbers
6. All medicines have valid manufacturers

### **12.2 Business Constraints**
1. Consultation hours: 09:00 - 18:00
2. Appointment must be booked in future
3. Cannot cancel appointment on same day
4. Insurance requires valid policy number
5. Billing requires valid appointment

### **12.3 Technical Constraints**
1. Database: MySQL 8.0+
2. Character set: UTF-8
3. Timezone: UTC (timestamps)
4. Engine: InnoDB (for transactions)

---

## **13. COMPARISON WITH ALTERNATIVES**

### **13.1 Alternative 1: Fewer Entities (10 entities)**

**Entities to Combine**:
- DOCTOR_SCHEDULE into DOCTOR (as schedule text field)
- PRESCRIPTION_ITEMS into PRESCRIPTION
- MEDICAL_HISTORY into PATIENT (as history text)

**Disadvantages**:
- ❌ Violates 1NF (multivalued attributes)
- ❌ Harder to query specific schedules
- ❌ Update anomalies (changing one schedule affects entire DOCTOR record)
- ❌ Cannot track history properly

**Our Choice**: ✅ Keep 14 entities (better design)

### **13.2 Alternative 2: More Entities (18 entities)**

**Additional Entities**:
- DOCTOR_QUALIFICATION (separate doctors' qualifications)
- DOCTOR_SPECIALIZATION (separate specializations)
- PATIENT_CONTACT (multiple contacts per patient)
- ADDRESS (separate address table)

**Disadvantages**:
- ❌ Over-normalization (BCNF)
- ❌ Increased complexity
- ❌ More JOINs needed
- ❌ Marginal benefit for our use case

**Our Choice**: ✅ Keep 14 entities (good balance)

---

## **14. CONCLUSION**

The Hospital Management System database design achieves the following:

✅ **Comprehensive**: 14 entities covering all major hospital operations
✅ **Normalized**: 3NF design ensures data integrity
✅ **Scalable**: Indexes and partitioning support 10,000+ records
✅ **Secure**: Views and constraints enforce access control
✅ **Maintainable**: Clear relationships and constraints
✅ **Extensible**: Support for future enhancements

The design successfully balances normalization benefits with practical query performance, making it suitable for production hospital management operations.

---

## **DOCUMENT APPROVAL**

| Role | Name | Date | Signature |
|---|---|---|---|
| Design Lead | Member 1 | Oct 2026 | ✓ |
| Review Lead | Team Lead | Oct 2026 | Pending |

---

**Document Version**: 1.0  
**Last Updated**: October 2026  
**Status**: Ready for Review  
**Next**: Proceed to Implementation Phase

