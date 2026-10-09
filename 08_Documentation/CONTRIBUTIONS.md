# Contributing to Hospital Management System
## Guidelines & Standards

**Document Version**: 1.0  
**Date**: October 2026  
**Module**: 08_Documentation  
**Prepared By**: Member 5 (Documentation Lead)  

---

## **TABLE OF CONTENTS**

1. [Getting Started](#getting-started)
2. [Development Workflow](#development-workflow)
3. [Code Standards](#code-standards)
4. [Documentation Standards](#documentation-standards)
5. [Testing Requirements](#testing-requirements)
6. [Pull Request Process](#pull-request-process)
7. [Commit Message Guidelines](#commit-message-guidelines)
8. [Team Responsibilities](#team-responsibilities)

---

## **GETTING STARTED**

### **Prerequisites**

✅ Java 11+  
✅ MySQL 8.0+  
✅ Maven 3.6+  
✅ Git 2.20+  
✅ GitHub account  

### **Repository Setup**

```bash
# Clone the repository
git clone https://github.com/yourteam/hospital-management-system-dbms.git
cd hospital-management-system-dbms

# Create your feature branch
git checkout -b feature/your-feature-name

# Set up development environment
mvn clean install
```

---

## **DEVELOPMENT WORKFLOW**

### **Branch Naming Convention**

```
feature/feature-name       - New feature development
bugfix/bug-name           - Bug fixes
refactor/refactor-name    - Code refactoring
docs/documentation-title  - Documentation updates
chore/maintenance-task    - Build, dependencies, etc.

Examples:
- feature/patient-registration
- bugfix/appointment-validation
- docs/api-documentation
- chore/update-dependencies
```

### **Step-by-Step Workflow**

1. **Create Branch**
```bash
git checkout -b feature/new-feature
```

2. **Make Changes**
```bash
# Edit files
# Write code
# Add tests
```

3. **Commit Changes**
```bash
git add .
git commit -m "feat: Add new feature description

- Detailed explanation of changes
- Additional context as needed"
```

4. **Push to GitHub**
```bash
git push origin feature/new-feature
```

5. **Create Pull Request**
```
Title: [Feature] Brief description
Description: Detailed explanation, issue reference
```

6. **Code Review**
```
- Team members review code
- Request changes if needed
- Approve once satisfied
```

7. **Merge to Main**
```bash
git checkout main
git pull origin main
git merge feature/new-feature
git push origin main
```

---

## **CODE STANDARDS**

### **Java Coding Standards**

```java
// Class naming: PascalCase
public class PatientService {
    
    // Method naming: camelCase
    public void createPatient(PatientDTO patient) {
        // Implementation
    }
    
    // Variable naming: camelCase
    private String patientName;
    private int maxAttempts = 3;
    
    // Constant naming: UPPER_CASE
    private static final int DEFAULT_PAGE_SIZE = 20;
    private static final String DEFAULT_TIMEZONE = "UTC";
}
```

### **Code Style Guidelines**

```
- Indentation: 4 spaces (no tabs)
- Line length: Max 100 characters
- Blank lines: Between methods (1 line)
- Imports: Organized, no wildcards
- Comments: Meaningful, explain WHY not WHAT
```

### **Code Organization**

```java
public class PatientService {
    
    // Constants first
    private static final int MAX_PATIENTS = 1000;
    
    // Private fields next
    private PatientRepository patientRepository;
    private PatientValidator validator;
    
    // Constructor
    public PatientService(PatientRepository repo, PatientValidator val) {
        this.patientRepository = repo;
        this.validator = val;
    }
    
    // Public methods
    public Patient createPatient(PatientDTO dto) {
        // Implementation
    }
    
    // Private helper methods
    private void validatePatient(PatientDTO dto) {
        // Implementation
    }
}
```

### **Error Handling**

```java
// Good: Specific exception handling
try {
    patient = patientRepository.findById(id);
} catch (EntityNotFoundException e) {
    logger.error("Patient not found: {}", id, e);
    throw new BusinessException("Patient does not exist");
} catch (DataAccessException e) {
    logger.error("Database error", e);
    throw new SystemException("Database error occurred");
}

// Bad: Generic exception handling
try {
    // ...
} catch (Exception e) {
    // Ignore or generic response
}
```

### **Null Safety**

```java
// Use Optional
public Optional<Patient> getPatient(Integer id) {
    return patientRepository.findById(id);
}

// Use null checks
if (patient != null && patient.isActive()) {
    // Process patient
}

// Use Objects utility
Objects.requireNonNull(patient, "Patient cannot be null");
```

---

## **DOCUMENTATION STANDARDS**

### **JavaDoc Comments**

```java
/**
 * Creates a new patient record in the system.
 *
 * @param patientDTO the patient data transfer object containing:
 *        - firstName: Patient's first name (required)
 *        - lastName: Patient's last name (required)
 *        - dob: Date of birth (required, must be valid date)
 * @return the created Patient object with assigned PatientID
 * @throws ValidationException if input validation fails
 * @throws DuplicateException if patient with same phone/email exists
 * @since 1.0
 */
public Patient createPatient(PatientDTO patientDTO) {
    // Implementation
}
```

### **Method Documentation**

```
Description: What the method does
Parameters: Input parameters with types
Returns: What the method returns
Throws: Exceptions that can be thrown
Examples: Usage examples if complex
```

### **Class Documentation**

```java
/**
 * Service class for patient management operations.
 * 
 * Handles patient registration, profile updates, and queries.
 * All operations are transactional and include validation.
 * 
 * @author Member 1
 * @version 1.0
 * @since 2026-10-08
 */
public class PatientService {
    // Implementation
}
```

### **README Standards**

Every module should have a README with:
- Module description
- Files included
- Quick start guide
- Folder structure
- Contributors

---

## **TESTING REQUIREMENTS**

### **Unit Tests**

```java
@RunWith(SpringRunner.class)
public class PatientServiceTest {
    
    @Mock
    private PatientRepository patientRepository;
    
    @InjectMocks
    private PatientService patientService;
    
    @Test
    public void testCreatePatientSuccess() {
        // Arrange
        PatientDTO dto = new PatientDTO("John", "Doe");
        Patient expected = new Patient(1, "John", "Doe");
        when(patientRepository.save(any())).thenReturn(expected);
        
        // Act
        Patient result = patientService.createPatient(dto);
        
        // Assert
        assertEquals(expected, result);
        verify(patientRepository, times(1)).save(any());
    }
    
    @Test(expected = ValidationException.class)
    public void testCreatePatientValidationFails() {
        // Arrange
        PatientDTO invalidDto = new PatientDTO("", ""); // Invalid
        
        // Act
        patientService.createPatient(invalidDto);
        
        // Assert: Exception should be thrown
    }
}
```

### **Test Coverage**

```
Minimum coverage: 80%
- Unit tests: All service methods
- Integration tests: Database operations
- API tests: All endpoints
- Validation tests: Input validation

Coverage Report:
mvn jacoco:report
# Report available at: target/site/jacoco/
```

### **Test Database**

```sql
-- Use separate test database
CREATE DATABASE hospital_test;
CREATE USER 'hms_test'@'localhost' IDENTIFIED BY 'test_password';
GRANT ALL PRIVILEGES ON hospital_test.* TO 'hms_test'@'localhost';

-- Configure in application-test.properties
spring.datasource.url=jdbc:mysql://localhost:3306/hospital_test
spring.datasource.username=hms_test
spring.datasource.password=test_password
```

---

## **PULL REQUEST PROCESS**

### **PR Checklist**

Before submitting a pull request, verify:

```
✅ Branch created from latest main
✅ Code follows style guidelines
✅ All tests pass locally
✅ Code coverage >= 80%
✅ No breaking changes documented
✅ Documentation updated
✅ Commit messages are clear
✅ No merge conflicts
✅ PR description is complete
✅ Related issues referenced
```

### **PR Template**

```markdown
## Description
Brief description of changes

## Related Issue
Fixes #123

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Changes Made
- Change 1
- Change 2
- Change 3

## Testing
- [ ] Unit tests added
- [ ] Integration tests added
- [ ] All tests pass

## Documentation
- [ ] README updated
- [ ] JavaDoc comments added
- [ ] API documentation updated

## Screenshots (if applicable)
[Add screenshots here]
```

---

## **COMMIT MESSAGE GUIDELINES**

### **Format**

```
<type>(<scope>): <subject>

<body>

<footer>
```

### **Type**

```
feat:     A new feature
fix:      A bug fix
refactor: Code change that neither fixes a bug nor adds a feature
style:    Changes that don't affect code meaning (formatting, missing semicolons, etc)
test:     Adding missing tests or correcting existing tests
docs:     Documentation only changes
chore:    Changes to build process, dependencies, or tools
```

### **Examples**

```
feat(patient): Add patient registration API endpoint

- Implement POST /api/v1/patients endpoint
- Add input validation for patient data
- Add unit tests with 90% coverage
- Update API documentation

Closes #123

feat(appointment): Add appointment booking system

- Book appointments with doctor availability check
- Automatic billing generation
- Send confirmation notifications
- Add database indexes for performance

BREAKING CHANGE: Appointment status changed from string to enum

fix(billing): Fix incorrect insurance coverage calculation

The insurance coverage percentage was being applied incorrectly.
Changed from multiplying by percentage to dividing.

Fixes #456

docs(README): Update setup instructions for MySQL 8.0

- Add MySQL 8.0 installation steps
- Update configuration examples
- Add troubleshooting section
```

---

## **TEAM RESPONSIBILITIES**

### **Member 1: ER Design & Schema**
```
Responsible for:
✅ Entity relationship diagrams
✅ Table creation and relationships
✅ Primary/foreign key constraints
✅ Normalization (up to BCNF)
✅ Data integrity constraints
```

### **Member 2: SQL Schema & Views**
```
Responsible for:
✅ Complete SQL DDL
✅ Table definitions
✅ Index creation
✅ View creation
✅ Trigger implementation (if needed)
```

### **Member 3: PL/SQL Procedures**
```
Responsible for:
✅ Stored procedures
✅ Triggers
✅ Complex business logic
✅ Batch operations
✅ Performance optimization
```

### **Member 4: Data Population**
```
Responsible for:
✅ Sample data creation
✅ Data integrity validation
✅ Test data sets
✅ Data loading scripts
✅ Data cleanup procedures
```

### **Member 5: Documentation & DBMS Concepts**
```
Responsible for:
✅ Complete documentation
✅ API documentation
✅ DBMS concepts coverage
✅ User guides
✅ Troubleshooting guides
✅ Architecture documentation
```

---

## **REVIEW CHECKLIST FOR REVIEWERS**

When reviewing code:

```
Code Quality:
✅ Code follows style guidelines
✅ Methods are appropriately sized
✅ No code duplication
✅ Error handling is proper
✅ Null safety is maintained

Functionality:
✅ Changes meet requirements
✅ No breaking changes
✅ Edge cases are handled
✅ Performance is acceptable

Testing:
✅ Tests are comprehensive
✅ Coverage is adequate (>80%)
✅ Tests are meaningful
✅ All tests pass

Documentation:
✅ JavaDoc is present
✅ Comments explain WHY, not WHAT
✅ README/API docs updated
✅ Changelog updated

Database:
✅ Schema changes documented
✅ Migration scripts provided
✅ Referential integrity maintained
✅ Performance indexes added
```

---

## **MERGE STRATEGY**

```
Default: Squash and merge
- Keeps history clean
- One commit per feature

Exception: Main branch merges
- Use merge commit
- Preserves branch history
```

---

## **DEPLOYMENT CHECKLIST**

Before deploying to production:

```
✅ All tests pass
✅ Code review approved
✅ Database backups created
✅ Migration scripts tested
✅ Documentation updated
✅ Security audit passed
✅ Performance tests passed
✅ Rollback plan documented
```

---

## **COMMUNICATION**

### **For Questions**
1. Check documentation first
2. Search GitHub issues
3. Ask in team channel
4. Email lead if urgent

### **For Issues**
1. Create GitHub issue
2. Include error message
3. Add reproduction steps
4. Tag relevant members

### **For Meetings**
- Weekly standup: Wednesday 10 AM
- Code review: Thursday 3 PM
- Architecture discussion: Friday 2 PM

---

## **SUMMARY**

✅ Follow coding standards consistently  
✅ Write tests for all code  
✅ Document your changes  
✅ Use clear commit messages  
✅ Participate in code reviews  
✅ Keep team informed  

---

**Questions?** Contact Member 5 (Documentation Lead) or Team Lead.
