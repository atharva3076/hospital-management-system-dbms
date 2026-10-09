# Setup Guide
## Hospital Management System - Installation & Configuration

**Document Version**: 1.0  
**Date**: October 2026  
**Module**: 08_Documentation  
**Prepared By**: Member 5 (Documentation Lead)  

---

## **TABLE OF CONTENTS**

1. [System Requirements](#system-requirements)
2. [Prerequisites](#prerequisites)
3. [Database Setup](#database-setup)
4. [Application Setup](#application-setup)
5. [Configuration](#configuration)
6. [Verification](#verification)
7. [Troubleshooting](#troubleshooting)
8. [Quick Start](#quick-start)

---

## **1. SYSTEM REQUIREMENTS**

### **Hardware Requirements**

```
Minimum Requirements:
├─ CPU: 2+ cores
├─ RAM: 4 GB
├─ Storage: 50 GB SSD
├─ Network: 1 Mbps internet
└─ OS: Linux/Windows/Mac

Recommended Requirements:
├─ CPU: 4+ cores
├─ RAM: 8-16 GB
├─ Storage: 100+ GB SSD
├─ Network: 10 Mbps+ internet
└─ OS: Linux (Ubuntu 20.04+) / Windows Server 2019+
```

### **Software Requirements**

```
Required:
├─ MySQL 8.0 or higher
├─ Java JDK 11 or higher
├─ Maven 3.6 or higher
├─ Git 2.20 or higher
└─ curl (for API testing)

Optional:
├─ Docker (for containerization)
├─ Postman (for API testing)
├─ MySQL Workbench (GUI database tool)
├─ IntelliJ IDEA (IDE)
└─ VS Code (editor)

Supported Operating Systems:
├─ Ubuntu 20.04 LTS
├─ CentOS 7/8
├─ Windows 10/11
├─ macOS 10.15+
└─ Any Linux distribution
```

---

## **2. PREREQUISITES**

### **Install Java JDK**

#### **On Ubuntu/Debian**:
```bash
# Update package manager
sudo apt-get update
sudo apt-get upgrade

# Install Java 11
sudo apt-get install openjdk-11-jdk

# Verify installation
java -version
javac -version
```

#### **On macOS**:
```bash
# Using Homebrew
brew install openjdk@11

# Add to PATH
export PATH="/usr/local/opt/openjdk@11/bin:$PATH"

# Verify
java -version
```

#### **On Windows**:
```
1. Download JDK 11 from oracle.com
2. Run installer (follow prompts)
3. Set JAVA_HOME environment variable:
   - Right-click "This PC" → Properties
   - Click "Advanced system settings"
   - Click "Environment Variables"
   - New → Variable name: JAVA_HOME
   - Variable value: C:\Program Files\Java\jdk-11
4. Verify: Open CMD, type: java -version
```

### **Install Maven**

#### **On Ubuntu/Debian**:
```bash
# Install Maven
sudo apt-get install maven

# Verify
mvn -version
```

#### **On macOS**:
```bash
# Using Homebrew
brew install maven

# Verify
mvn -version
```

#### **On Windows**:
```
1. Download Maven from maven.apache.org
2. Extract to C:\Program Files\Apache\maven
3. Set M2_HOME environment variable:
   - Variable name: M2_HOME
   - Variable value: C:\Program Files\Apache\maven
4. Add to PATH: %M2_HOME%\bin
5. Verify: CMD → mvn -version
```

### **Install MySQL 8.0**

#### **On Ubuntu/Debian**:
```bash
# Install MySQL Server
sudo apt-get install mysql-server

# Secure installation (optional)
sudo mysql_secure_installation

# Start MySQL service
sudo systemctl start mysql
sudo systemctl enable mysql  # Auto-start on boot

# Verify
mysql --version
```

#### **On macOS**:
```bash
# Using Homebrew
brew install mysql@8.0

# Start MySQL
brew services start mysql@8.0

# Verify
mysql --version
```

#### **On Windows**:
```
1. Download MySQL Community Server from mysql.com
2. Run MSI installer
3. Choose setup type (Developer Default)
4. Complete MySQL Server Configuration
5. Start MySQL service:
   - Open Services (services.msc)
   - Find "MySQL80"
   - Right-click → Start
6. Verify: CMD → mysql --version
```

### **Install Git**

#### **On Ubuntu/Debian**:
```bash
sudo apt-get install git
```

#### **On macOS**:
```bash
brew install git
```

#### **On Windows**:
```
Download from git-scm.com and run installer
```

---

## **3. DATABASE SETUP**

### **Step 1: Create Database & User**

```bash
# Connect to MySQL as root
mysql -u root -p

# Create database
CREATE DATABASE hospital_management_system;

# Create application user
CREATE USER 'hms_user'@'localhost' IDENTIFIED BY 'secure_password_123';

# Grant privileges
GRANT ALL PRIVILEGES ON hospital_management_system.* TO 'hms_user'@'localhost';
GRANT ALL PRIVILEGES ON hospital_management_system.* TO 'hms_user'@'%';

# Reload privileges
FLUSH PRIVILEGES;

# Verify
SELECT user, host FROM mysql.user;

# Exit MySQL
EXIT;
```

### **Step 2: Create Tables from Schema**

```bash
# Download schema file (from Module 2: SQL Schema)
# File: 02_SQL_Schema/Relational_Schema.sql

# Import schema
mysql -u hms_user -p hospital_management_system < Relational_Schema.sql

# Verify tables created
mysql -u hms_user -p hospital_management_system -e "SHOW TABLES;"

# Expected output: 14 tables
# APPOINTMENT, BILLING, DEPARTMENT, DOCTOR, DOCTOR_SCHEDULE,
# INSURANCE, LAB_REPORT, LAB_TEST, MANUFACTURER, MEDICINE,
# MEDICAL_HISTORY, PATIENT, PRESCRIPTION, PRESCRIPTION_ITEMS
```

### **Step 3: Load Sample Data**

```bash
# Download data file (from Module 4: Data Population)
# File: 04_Data_Population/sample_data.sql

# Import sample data
mysql -u hms_user -p hospital_management_system < sample_data.sql

# Verify data loaded
mysql -u hms_user -p hospital_management_system -e "SELECT COUNT(*) FROM DOCTOR;"
mysql -u hms_user -p hospital_management_system -e "SELECT COUNT(*) FROM PATIENT;"
mysql -u hms_user -p hospital_management_system -e "SELECT COUNT(*) FROM APPOINTMENT;"
```

### **Step 4: Verify Indexes**

```bash
# Check if indexes exist
mysql -u hms_user -p hospital_management_system -e "SHOW INDEXES FROM DOCTOR;"

# Expected indexes:
# - idx_dept_id (DepartmentID)
# - idx_doctor_registration (RegistrationNumber)
# - PRIMARY (DoctorID)
```

---

## **4. APPLICATION SETUP**

### **Step 1: Clone Repository**

```bash
# Clone from GitHub
git clone https://github.com/yourteam/hospital-management-system-dbms.git
cd hospital-management-system-dbms

# List contents
ls -la
# Expected: 08_Documentation/, 02_SQL_Schema/, 04_Data_Population/, etc.
```

### **Step 2: Configure Application Properties**

Edit `src/main/resources/application.properties`:

```properties
# Database Connection
spring.datasource.url=jdbc:mysql://localhost:3306/hospital_management_system
spring.datasource.username=hms_user
spring.datasource.password=secure_password_123
spring.datasource.driver-class-name=com.mysql.cj.jdbc.Driver

# JPA/Hibernate Configuration
spring.jpa.hibernate.ddl-auto=validate
spring.jpa.show-sql=false
spring.jpa.properties.hibernate.dialect=org.hibernate.dialect.MySQL8Dialect

# Connection Pool
spring.datasource.hikari.maximum-pool-size=20
spring.datasource.hikari.minimum-idle=5
spring.datasource.hikari.connection-timeout=30000

# Logging
logging.level.root=INFO
logging.level.com.hms=DEBUG
logging.file.name=logs/application.log

# Server Configuration
server.port=8080
server.servlet.context-path=/api/v1

# Pagination
spring.data.web.pageable.default-page-size=20
spring.data.web.pageable.one-indexed-parameters=false

# Timezone
spring.jackson.time-zone=UTC
spring.jpa.properties.hibernate.jdbc.time_zone=UTC
```

### **Step 3: Install Dependencies**

```bash
# Build project and download dependencies
mvn clean install

# Expected output: BUILD SUCCESS

# Or just download without building:
mvn dependency:resolve
```

### **Step 4: Build Application**

```bash
# Clean and build
mvn clean build

# Or compile only
mvn compile

# Package as JAR
mvn package

# Expected: target/hms-application.jar
```

---

## **5. CONFIGURATION**

### **Database Configuration**

```yaml
# application.yml (alternative to properties)
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/hospital_management_system
    username: hms_user
    password: secure_password_123
    hikari:
      maximum-pool-size: 20
      minimum-idle: 5
      
  jpa:
    hibernate:
      ddl-auto: validate
    properties:
      hibernate:
        dialect: org.hibernate.dialect.MySQL8Dialect
        jdbc:
          time_zone: UTC
```

### **Logging Configuration**

```xml
<!-- logback.xml -->
<configuration>
    <appender name="FILE" class="ch.qos.logback.core.FileAppender">
        <file>logs/application.log</file>
        <pattern>%d{HH:mm:ss.SSS} [%thread] %-5level %logger{36} - %msg%n</pattern>
    </appender>
    
    <root level="INFO">
        <appender-ref ref="FILE"/>
    </root>
    
    <logger name="com.hms" level="DEBUG"/>
</configuration>
```

### **Security Configuration**

```java
// SecurityConfig.java
@Configuration
@EnableWebSecurity
public class SecurityConfig {
    
    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }
    
    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .csrf().disable()
            .authorizeRequests()
                .antMatchers("/api/v1/auth/**").permitAll()
                .antMatchers("/api/v1/public/**").permitAll()
                .anyRequest().authenticated()
            .and()
            .httpBasic();
        return http.build();
    }
}
```

---

## **6. VERIFICATION**

### **Verify Database Connection**

```bash
# Test connection
mysql -u hms_user -p hospital_management_system -e "SELECT 'Connection successful' as Status;"

# Output: Connection successful
```

### **Verify Tables**

```bash
mysql -u hms_user -p hospital_management_system -e "SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA='hospital_management_system';"

# Expected: 14 tables listed
```

### **Verify Data**

```bash
mysql -u hms_user -p hospital_management_system << EOF
SELECT COUNT(*) as 'Total Doctors' FROM DOCTOR;
SELECT COUNT(*) as 'Total Patients' FROM PATIENT;
SELECT COUNT(*) as 'Total Appointments' FROM APPOINTMENT;
SELECT COUNT(*) as 'Total Medicines' FROM MEDICINE;
EOF

# Sample Output:
# Total Doctors: 25
# Total Patients: 150
# Total Appointments: 200
# Total Medicines: 100
```

### **Run Application**

```bash
# Start Spring Boot application
mvn spring-boot:run

# Or using JAR:
java -jar target/hms-application.jar

# Expected output:
# ...
# 2026-10-08 14:30:15.123 INFO 12345 --- [main] com.hms.HmsApplication: HMS Application started
# 2026-10-08 14:30:15.456 INFO 12345 --- [main] o.s.b.w.embedded.tomcat.TomcatWebServer: Tomcat started on port(s): 8080
```

### **Test API**

```bash
# Test patients endpoint
curl http://localhost:8080/api/v1/patients

# Expected response: JSON array of patients

# Test specific patient
curl http://localhost:8080/api/v1/patients/1

# Expected response: Single patient object in JSON
```

### **Database Health Check**

```bash
# Check database performance
mysql -u hms_user -p hospital_management_system -e "
SELECT 
    COUNT(*) as total_appointments,
    AVG(ConsultationFee) as avg_fee,
    MAX(ConsultationFee) as max_fee
FROM APPOINTMENT;
"

# Expected output: Statistics
```

---

## **7. TROUBLESHOOTING**

### **Issue 1: MySQL Connection Refused**

**Error**: `Communications link failure`

**Solution**:
```bash
# Check MySQL service status
sudo systemctl status mysql

# Start MySQL if not running
sudo systemctl start mysql

# Verify port 3306 is open
sudo netstat -tupln | grep 3306

# Check connection
mysql -h localhost -u root -p
```

### **Issue 2: Permission Denied**

**Error**: `Access denied for user 'hms_user'@'localhost'`

**Solution**:
```bash
# Verify user exists
mysql -u root -p -e "SELECT user FROM mysql.user WHERE user='hms_user';"

# If not exists, create user
mysql -u root -p -e "CREATE USER 'hms_user'@'localhost' IDENTIFIED BY 'password';"

# Grant privileges
mysql -u root -p -e "GRANT ALL ON hospital_management_system.* TO 'hms_user'@'localhost';"
mysql -u root -p -e "FLUSH PRIVILEGES;"
```

### **Issue 3: Table Not Found**

**Error**: `Table 'hospital_management_system.DOCTOR' doesn't exist`

**Solution**:
```bash
# Import schema again
mysql -u hms_user -p hospital_management_system < Relational_Schema.sql

# Verify tables
mysql -u hms_user -p hospital_management_system -e "SHOW TABLES;"
```

### **Issue 4: Application Won't Start**

**Error**: `Failed to configure a DataSource`

**Solution**:
```bash
# Check application.properties
cat src/main/resources/application.properties

# Verify values:
# - spring.datasource.url (correct host:port)
# - spring.datasource.username (exists in MySQL)
# - spring.datasource.password (correct)

# Test database connection manually
mysql -h localhost -u hms_user -p hospital_management_system -e "SELECT 1;"
```

### **Issue 5: Port Already in Use**

**Error**: `Tomcat started on port 8080 (http) with context path '/'`

**Solution**:
```bash
# Check what's using port 8080
sudo lsof -i :8080

# Kill the process
sudo kill -9 <PID>

# Or change port in application.properties
# server.port=8081
```

---

## **8. QUICK START**

### **Complete Setup in 5 Steps**

```bash
# Step 1: Install prerequisites (if not already installed)
# Follow Section 2: Prerequisites

# Step 2: Clone repository
git clone https://github.com/yourteam/hospital-management-system-dbms.git
cd hospital-management-system-dbms

# Step 3: Create database and import schema
mysql -u root -p < 02_SQL_Schema/Relational_Schema.sql
mysql -u root -p < 04_Data_Population/sample_data.sql

# Step 4: Configure application
# Edit src/main/resources/application.properties with your settings

# Step 5: Run application
mvn spring-boot:run

# Application is now running on http://localhost:8080
```

### **Using Docker (Optional)**

```dockerfile
# Dockerfile
FROM openjdk:11
COPY target/hms-application.jar app.jar
ENTRYPOINT ["java", "-jar", "app.jar"]
```

```bash
# Build Docker image
docker build -t hms-app .

# Run with MySQL container
docker run --name mysql-hms -e MYSQL_ROOT_PASSWORD=root -d mysql:8.0
docker run --name hms-app --link mysql-hms:db -p 8080:8080 hms-app
```

---

## **SUMMARY**

Setup checklist:
✅ Install Java, Maven, MySQL, Git
✅ Create database and user
✅ Import schema and sample data
✅ Clone repository
✅ Configure application properties
✅ Build and run application
✅ Verify with API tests

Expected result: 
- Application running on port 8080
- Database connected and populated
- Ready for production use

---
