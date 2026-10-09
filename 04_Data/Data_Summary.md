# Data Summary - Hospital Management System (Phase 3)

**Owner:** Member 4 (Data Population & Testing)
**Branch:** `member4-data-population`
**Depends on:** Phase 1 - `02_SQL_Schema` (14 tables, 45+ indexes, 15 views)

---

## 1. Record Counts

| # | Table | Records | Loaded by |
|---|-------|--------:|-----------|
| 1 | DEPARTMENT | 10 | `01_Insert_Departments.sql` |
| 2 | DOCTOR | 20 | `02_Insert_Doctors.sql` |
| 3 | DOCTOR_SCHEDULE | 100 | `02_Insert_Doctors.sql` |
| 4 | PATIENT | 100 | `03_Insert_Patients.sql` |
| 5 | MEDICAL_HISTORY | 80 | `03_Insert_Patients.sql` |
| 6 | APPOINTMENT | 120 | `04_Insert_Appointments.sql` |
| 7 | MANUFACTURER | 8 | `05_Insert_Medications.sql` |
| 8 | MEDICINE | 30 | `05_Insert_Medications.sql` |
| 9 | PRESCRIPTION | 108 | `06_Insert_Prescriptions.sql` |
| 10 | PRESCRIPTION_ITEMS | 216 | `06_Insert_Prescriptions.sql` |
| 11 | LAB_TEST | 15 | `07_Insert_Lab_Tests.sql` |
| 12 | LAB_REPORT | 54 | `07_Insert_Lab_Tests.sql` |
| 13 | BILLING | 108 | `08_Insert_Billing.sql` |
| 14 | INSURANCE | 80 | `09_Insert_Insurance.sql` |
| | **TOTAL** | **1,049** | |

---

## 2. Load Order and Dependencies

```
01 Departments ──► 02 Doctors (+ Schedules) ──► 03 Patients (+ Medical History)
                                                        │
05 Manufacturers + Medicines ──────────┐                ▼
                                       │        04 Appointments
                                       │                │
                                       ▼                ▼
                               06 Prescriptions (+ Items)   07 Lab Tests + Reports
                                                        │
                                                        ▼
                                                  08 Billing ──► 09 Insurance
```

Foreign keys require this order. `05` has no patient dependency, but `06` needs both `04` and `05`.

---

## 3. Data Distribution

| Area | Distribution |
|------|--------------|
| Departments | 10 (Cardiology, Neurology, Orthopedics, Pediatrics, Gynecology, Dermatology, General Medicine, ENT, Ophthalmology, Emergency) |
| Doctors per department | 2 each |
| Doctor availability | Mon-Fri, 09:00-17:00, 16 slots (30 min) per day |
| Patient gender | 50 Male / 50 Female |
| Patient blood groups | All 8 groups, evenly spread |
| Patient cities | Bhopal, Indore, Jabalpur, Gwalior, Nagpur, Pune, New Delhi, Lucknow |
| Patient age range | About 18 to 83 years |
| Appointments | 108 Scheduled, 12 Cancelled, spread over the next 30 days |
| Prescriptions | 1 per Scheduled appointment, 2 medicines each |
| Lab reports | 54 (about 25 % flagged Abnormal) |
| Billing status | Roughly one third each: Paid, Partial, Unpaid |
| Insurance | 80 of 100 patients covered (50 / 70 / 80 / 90 % coverage) |

---

## 4. Intentional Edge Cases (for testing views and triggers)

| Scenario | Where | Used by |
|----------|-------|---------|
| Medicines expiring in 20-60 days (Dextromethorphan Syrup, Azithromycin 500, Salbutamol Inhaler, ORS Sachet) | MEDICINE | `v_medicine_expiry_alert` |
| Medicines below reorder level (Salbutamol Inhaler, Insulin Glargine) | MEDICINE | `v_medicine_inventory`, `medicine_alerts` |
| Cancelled appointments with reason and date | APPOINTMENT | Cancellation analysis |
| Patients with no insurance (every 5th PatientID) | PATIENT / INSURANCE | `v_patient_insurance_coverage` |
| Unpaid and partially paid bills | BILLING | `v_billing_summary`, `v_overdue_payments` |
| Abnormal lab results | LAB_REPORT | `v_lab_results` |
| Patients with allergies | PATIENT | Prescription safety tests |

---

## 5. Integrity Checks Built into the Data

- No orphan rows: every FK value points to an existing parent row.
- All patient phones and emails are unique (100 / 100).
- No double bookings: (Patient, Doctor, Date, Time) is unique for all 120 appointments.
- Prescription expiry is always after the prescription date.
- Medicine expiry dates are always in the future.
- Billing: `Total = Consultation + Lab + Medicine + Other - Discount + Tax`.
- Billing: `AmountPaid <= PatientPayable`; insurance coverage is between 0 and 100 %.
- Insurance: `PolicyStartDate < PolicyEndDate`.

---

## 6. Design Notes and Limitations

1. **Relative dates.** The schema CHECK requires `AppointmentDate >= CURDATE()`, so appointment dates are `CURDATE() + 1..30 days`. Dependent rows (prescriptions, lab reports, bills) therefore carry the same future dates.
2. **Generated data.** Patients, appointments, prescriptions, billing and insurance are produced with recursive CTEs / `INSERT ... SELECT`, which guarantees consistency. Names, cities and values are synthetic.
3. **Fictional entities.** Manufacturers and insurance providers are made up. Doctors' license numbers use a dummy `MCI-MP-xxxxx` format.
4. **Stock not decremented.** Prescribing a medicine in this dataset does not reduce `QuantityInStock` (triggers from Phase 2 will do that on live inserts).
5. **Fresh database required.** Scripts assume auto-increment IDs start at 1. Use the reset steps in `README.md` before re-running.
