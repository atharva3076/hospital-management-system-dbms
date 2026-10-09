# 04_Data - Sample Data for the Hospital Management System

**Phase 3 - Data Population & Testing (Member 4)**
**Branch:** `member4-data-population`
**Database:** MySQL 8.0+ (`hospital_management_system`)

This folder fills the 14-table schema built in Phase 1 (`02_SQL_Schema`) with **1,049 consistent records** so that views, indexes, triggers and queries can be tested with realistic data.

---

## Contents

| File | Tables loaded | Rows |
|------|---------------|-----:|
| `01_Insert_Departments.sql` | DEPARTMENT | 10 |
| `02_Insert_Doctors.sql` | DOCTOR, DOCTOR_SCHEDULE | 20 + 100 |
| `03_Insert_Patients.sql` | PATIENT, MEDICAL_HISTORY | 100 + 80 |
| `04_Insert_Appointments.sql` | APPOINTMENT | 120 |
| `05_Insert_Medications.sql` | MANUFACTURER, MEDICINE | 8 + 30 |
| `06_Insert_Prescriptions.sql` | PRESCRIPTION, PRESCRIPTION_ITEMS | 108 + 216 |
| `07_Insert_Lab_Tests.sql` | LAB_TEST, LAB_REPORT | 15 + 54 |
| `08_Insert_Billing.sql` | BILLING | 108 |
| `09_Insert_Insurance.sql` | INSURANCE | 80 |
| `Data_Summary.md` | Statistics, distribution, edge cases | - |
| `README.md` | This guide | - |

---

## Prerequisites

1. MySQL **8.0 or higher** (the scripts use recursive CTEs inside `INSERT ... SELECT`).
2. Phase 1 completed on a **fresh** database:
   ```bash
   mysql -u root -p hospital_management_system < 02_SQL_Schema/01_DDL_Tables.sql
   mysql -u root -p hospital_management_system < 02_SQL_Schema/02_Constraints_and_Keys.sql
   mysql -u root -p hospital_management_system < 02_SQL_Schema/03_Indexes.sql
   mysql -u root -p hospital_management_system < 02_SQL_Schema/04_Views.sql
   ```
3. Tables must be empty (auto-increment IDs must start at 1 because the scripts reference IDs such as `DoctorID 1-20`).

---

## Quick Start

Run the files **in numeric order** (foreign keys depend on it):

```bash
cd 04_Data
for f in 01_Insert_Departments.sql 02_Insert_Doctors.sql 03_Insert_Patients.sql \
         04_Insert_Appointments.sql 05_Insert_Medications.sql 06_Insert_Prescriptions.sql \
         07_Insert_Lab_Tests.sql 08_Insert_Billing.sql 09_Insert_Insurance.sql
do
  echo "Running $f ..."
  mysql -u root -p hospital_management_system < "$f" || break
done
```

Or from the MySQL shell:

```sql
USE hospital_management_system;
SOURCE 01_Insert_Departments.sql;
SOURCE 02_Insert_Doctors.sql;
-- ... continue through 09_Insert_Insurance.sql
```

Each script ends with verification queries that print the expected row count.

---

## Verify Everything

```sql
SELECT 'DEPARTMENT' AS tbl, COUNT(*) AS cnt FROM DEPARTMENT UNION ALL
SELECT 'DOCTOR',            COUNT(*) FROM DOCTOR            UNION ALL
SELECT 'DOCTOR_SCHEDULE',   COUNT(*) FROM DOCTOR_SCHEDULE   UNION ALL
SELECT 'PATIENT',           COUNT(*) FROM PATIENT           UNION ALL
SELECT 'MEDICAL_HISTORY',   COUNT(*) FROM MEDICAL_HISTORY   UNION ALL
SELECT 'APPOINTMENT',       COUNT(*) FROM APPOINTMENT       UNION ALL
SELECT 'MANUFACTURER',      COUNT(*) FROM MANUFACTURER      UNION ALL
SELECT 'MEDICINE',          COUNT(*) FROM MEDICINE          UNION ALL
SELECT 'PRESCRIPTION',      COUNT(*) FROM PRESCRIPTION      UNION ALL
SELECT 'PRESCRIPTION_ITEMS',COUNT(*) FROM PRESCRIPTION_ITEMS UNION ALL
SELECT 'LAB_TEST',          COUNT(*) FROM LAB_TEST          UNION ALL
SELECT 'LAB_REPORT',        COUNT(*) FROM LAB_REPORT        UNION ALL
SELECT 'BILLING',           COUNT(*) FROM BILLING           UNION ALL
SELECT 'INSURANCE',         COUNT(*) FROM INSURANCE;
```

Expected: 10, 20, 100, 100, 80, 120, 8, 30, 108, 216, 15, 54, 108, 80.

Test the views from Phase 1:

```sql
SELECT * FROM v_doctor_details LIMIT 5;
SELECT * FROM v_today_appointments;
SELECT * FROM v_billing_summary LIMIT 10;
SELECT * FROM v_medicine_expiry_alert;
SELECT * FROM v_department_statistics;
```

---

## Resetting the Data (re-run from scratch)

```sql
USE hospital_management_system;
SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE PRESCRIPTION_ITEMS;
TRUNCATE TABLE PRESCRIPTION;
TRUNCATE TABLE LAB_REPORT;
TRUNCATE TABLE LAB_TEST;
TRUNCATE TABLE BILLING;
TRUNCATE TABLE INSURANCE;
TRUNCATE TABLE MEDICAL_HISTORY;
TRUNCATE TABLE APPOINTMENT;
TRUNCATE TABLE DOCTOR_SCHEDULE;
TRUNCATE TABLE PATIENT;
TRUNCATE TABLE DOCTOR;
TRUNCATE TABLE DEPARTMENT;
TRUNCATE TABLE MEDICINE;
TRUNCATE TABLE MANUFACTURER;
SET FOREIGN_KEY_CHECKS = 1;
```

`TRUNCATE` also resets auto-increment counters to 1.

---

## How the Data Was Built

- **Hand-written:** departments, doctors, manufacturers, medicines, lab tests (small reference tables).
- **Generated with recursive CTEs:** patients, medical history, appointments (guarantees unique phones, emails and no double-booking).
- **Derived with `INSERT ... SELECT`:** prescriptions, items, lab reports, billing, insurance (so every foreign key and every amount is consistent with its parent rows).
- **Dates are relative to `CURDATE()`** because the schema forbids past appointment dates and future medicine expiry dates.

See `Data_Summary.md` for the full distribution and intentional edge cases.

---

## Troubleshooting

| Error | Cause | Fix |
|-------|-------|-----|
| `Unknown column 'X' in 'field list'` | A column name in the script differs from `01_DDL_Tables.sql` | Open the DDL, rename the column in the `INSERT` column list |
| `Data truncated for column 'Status'` / `Invalid ENUM value` | ENUM values in the DDL differ from the ones used here | Check `SHOW COLUMNS FROM <table>` and adjust the literal in the script |
| `Cannot add or update a child row: a foreign key constraint fails` | Files run out of order, or tables not empty / IDs do not start at 1 | Run the reset script, then execute 01 to 09 in order |
| `Duplicate entry ... for key` | Script executed twice | Run the reset script first |
| `Field 'X' doesn't have a default value` | A NOT NULL column exists in the DDL that the script does not fill | Add the column and a value to the `INSERT` |
| `CHECK constraint ... is violated` | A CHECK rule in the schema rejects a value | Read the constraint with `SHOW CREATE TABLE <table>` and adjust the value |
| `You have an error in your SQL syntax near 'WITH'` | MySQL older than 8.0 | Upgrade to MySQL 8.0+ |

---

## Team Workflow

```bash
git checkout -b member4-data-population
git add 04_Data/
git commit -m "feat(data): add sample data scripts and documentation"
git push origin member4-data-population
```

Then open a Pull Request for Member 1 (Team Lead) to review and merge.

---

## Next Phase

**Phase 4 (Member 5):** relational algebra / calculus queries, ACID demonstrations, complex SQL queries and final documentation - all of which can now run against this dataset.
