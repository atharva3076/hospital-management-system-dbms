# PL/SQL Module - Hospital Management System

This module contains all PL/SQL objects (procedures, functions, triggers, cursors, and exception handling).

## Files in This Module

1. **01_Stored_Procedures.sql** - 6 complex stored procedures
2. **02_Functions.sql** - 8 custom scalar functions
3. **03_Triggers.sql** - 8 database triggers
4. **04_Cursors.sql** - 5 cursor demonstrations
5. **05_Exception_Handling.sql** - 4 exception handling procedures
6. **PL_SQL_Documentation.md** - Complete documentation
7. **README.md** - This file

## Quick Start

### Load all PL/SQL objects:
```bash
mysql -u root -p hospital_management_system < 01_Stored_Procedures.sql
mysql -u root -p hospital_management_system < 02_Functions.sql
mysql -u root -p hospital_management_system < 03_Triggers.sql
mysql -u root -p hospital_management_system < 04_Cursors.sql
mysql -u root -p hospital_management_system < 05_Exception_Handling.sql
```

### Test procedures:
```sql
CALL sp_schedule_appointment(1, 1, '2024-12-25', '10:00:00', 'Test', @id, @msg, @success);
CALL sp_get_patient_medical_summary(1);
CALL sp_process_billing(1, 1, @bid, @payable, @success);
```

## Statistics

- **Stored Procedures**: 14 total
  - 6 in 01_Stored_Procedures.sql
  - 2 in 04_Cursors.sql
  - 4 in 05_Exception_Handling.sql
  - 2 in 03_Triggers.sql

- **Custom Functions**: 8 total
  - All in 02_Functions.sql

- **Database Triggers**: 8 total
  - All in 03_Triggers.sql

- **Support Tables**: 3
  - medicine_alerts (created by triggers)
  - audit_log (created by triggers)
  - exception_log (created by exception handling)

## Key Features

✅ Input validation with SIGNAL  
✅ Transaction management (COMMIT/ROLLBACK)  
✅ Exception handling with error logging  
✅ Row-by-row processing with cursors  
✅ Automatic data consistency with triggers  
✅ Reusable functions for calculations  
✅ Comprehensive error handling  
✅ Audit trail for critical operations  

## DBMS Concepts Demonstrated

- Parameters (IN, OUT)
- Variables and scope
- Control structures
- Cursors (explicit)
- Exception handlers
- Transactions
- Triggers (BEFORE/AFTER)
- Functions
- Views through procedures
- Performance optimization
