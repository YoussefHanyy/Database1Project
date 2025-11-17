-- 2.1.a Create Database
CREATE DATABASE University_HR_ManagementSystem_64;
GO

USE University_HR_ManagementSystem_64;
GO

-- 2.1.b Create All Tables (FIXED VERSION)
CREATE PROCEDURE createAllTables
AS
BEGIN
    -- Department table
    CREATE TABLE Department (
        name VARCHAR(50) PRIMARY KEY,
        building_location VARCHAR(50)
    );

    -- Employee table
    CREATE TABLE Employee (
        employee_ID INT IDENTITY(1,1) PRIMARY KEY,
        first_name VARCHAR(50),
        last_name VARCHAR(50),
        email VARCHAR(50),
        password VARCHAR(50),
        address VARCHAR(50),
        gender CHAR(1),
        official_day_off VARCHAR(50),
        years_of_experience INT,
        national_ID CHAR(16),
        employment_status VARCHAR(50) CHECK (employment_status IN ('active', 'onleave', 'notice_period', 'resigned')),
        type_of_contract VARCHAR(50) CHECK (type_of_contract IN ('full_time', 'part_time')),
        emergency_contact_name VARCHAR(50),
        emergency_contact_phone CHAR(11),
        annual_balance INT,
        accidental_balance INT, 
        salary DECIMAL(10,2),
        hire_date DATE,
        last_working_date DATE,
        dept_name VARCHAR(50) FOREIGN KEY REFERENCES Department(name)
    );

    -- Employee_Phone table
    CREATE TABLE Employee_Phone (
        emp_ID INT FOREIGN KEY REFERENCES Employee(employee_ID),
        phone_num CHAR(11),
        PRIMARY KEY (emp_ID, phone_num)
    );

    -- Role table
    CREATE TABLE Role (
        role_name VARCHAR(50) PRIMARY KEY,
        title VARCHAR(50),
        description VARCHAR(50),
        rank INT,
        base_salary DECIMAL(10,2),
        percentage_YOE DECIMAL(4,2),
        percentage_overtime DECIMAL(4,2),
        annual_balance INT,
        accidental_balance INT
    );

    -- Employee_Role table
    CREATE TABLE Employee_Role (
        emp_ID INT FOREIGN KEY REFERENCES Employee(employee_ID),
        role_name VARCHAR(50) FOREIGN KEY REFERENCES Role(role_name),
        PRIMARY KEY (emp_ID, role_name)
    );

    -- Role_existsIn_Department table
    CREATE TABLE Role_existsIn_Department (
        department_name VARCHAR(50) FOREIGN KEY REFERENCES Department(name),
        Role_name VARCHAR(50) FOREIGN KEY REFERENCES Role(role_name),
        PRIMARY KEY (department_name, Role_name)
    );

    -- Leave table WITH COMPUTED COLUMN for num_days
    CREATE TABLE Leave (
        request_ID INT IDENTITY(1,1) PRIMARY KEY,
        date_of_request DATE,
        start_date DATE,
        end_date DATE,
        num_days AS (DATEDIFF(day, start_date, end_date) + 1), -- COMPUTED COLUMN
        final_approval_status VARCHAR(50) DEFAULT 'pending' CHECK (final_approval_status IN ('approved', 'rejected', 'pending'))
    );

    -- Annual_Leave table
    CREATE TABLE Annual_Leave (
        request_ID INT FOREIGN KEY REFERENCES Leave(request_ID),
        emp_ID INT FOREIGN KEY REFERENCES Employee(employee_ID),
        replacement_emp INT FOREIGN KEY REFERENCES Employee(employee_ID),
        PRIMARY KEY (request_ID)
    );

    -- Accidental_Leave table
    CREATE TABLE Accidental_Leave (
        request_ID INT FOREIGN KEY REFERENCES Leave(request_ID),
        emp_ID INT FOREIGN KEY REFERENCES Employee(employee_ID),
        PRIMARY KEY (request_ID)
    );

    -- Medical_Leave table
    CREATE TABLE Medical_Leave (
        request_ID INT FOREIGN KEY REFERENCES Leave(request_ID),
        insurance_status BIT,
        disability_details VARCHAR(50),
        type VARCHAR(50) CHECK (type IN ('sick', 'maternity')),
        Emp_ID INT FOREIGN KEY REFERENCES Employee(employee_ID),
        PRIMARY KEY (request_ID)
    );

    -- Unpaid_Leave table
    CREATE TABLE Unpaid_Leave (
        request_ID INT FOREIGN KEY REFERENCES Leave(request_ID),
        Emp_ID INT FOREIGN KEY REFERENCES Employee(employee_ID),
        PRIMARY KEY (request_ID)
    );

    -- Compensation_Leave table
    CREATE TABLE Compensation_Leave (
        request_ID INT FOREIGN KEY REFERENCES Leave(request_ID),
        reason VARCHAR(50),
        date_of_original_workday DATE,
        emp_ID INT FOREIGN KEY REFERENCES Employee(employee_ID),
        replacement_emp INT FOREIGN KEY REFERENCES Employee(employee_ID),
        PRIMARY KEY (request_ID)
    );

    -- Document table
    CREATE TABLE Document (
        document_ID INT IDENTITY(1,1) PRIMARY KEY,
        type VARCHAR(50),
        description VARCHAR(50),
        file_name VARCHAR(50),
        creation_date DATE,
        expiry_date DATE,
        status VARCHAR(50) CHECK (status IN ('valid', 'expired')),
        emp_ID INT FOREIGN KEY REFERENCES Employee(employee_ID),
        medical_ID INT FOREIGN KEY REFERENCES Medical_Leave(request_ID),
        unpaid_ID INT FOREIGN KEY REFERENCES Unpaid_Leave(request_ID)
    );

    -- Payroll table
    CREATE TABLE Payroll (
        ID INT IDENTITY(1,1) PRIMARY KEY,
        payment_date DATE,
        final_salary_amount DECIMAL(10,1),
        from_date DATE,
        to_date DATE,
        comments VARCHAR(150),
        bonus_amount DECIMAL(10,2),
        deductions_amount DECIMAL(10,2),
        emp_ID INT FOREIGN KEY REFERENCES Employee(employee_ID)
    );

    -- Attendance table WITH COMPUTED COLUMN for total_duration
    CREATE TABLE Attendance (
        attendance_ID INT IDENTITY(1,1) PRIMARY KEY,
        date DATE,
        check_in_time TIME,
        check_out_time TIME,
        total_duration AS (
            CASE 
                WHEN check_in_time IS NOT NULL AND check_out_time IS NOT NULL 
                THEN DATEDIFF(HOUR, check_in_time, check_out_time)
                ELSE NULL 
            END
        ), -- COMPUTED COLUMN
        status VARCHAR(50) DEFAULT 'absent' CHECK (status IN ('absent', 'attended')),
        emp_ID INT FOREIGN KEY REFERENCES Employee(employee_ID)
    );

    -- Deduction table
    CREATE TABLE Deduction (
        deduction_ID INT IDENTITY(1,1) PRIMARY KEY,
        emp_ID INT FOREIGN KEY REFERENCES Employee(employee_ID),
        date DATE,
        amount DECIMAL(10,2),
        type VARCHAR(50) CHECK (type IN ('unpaid', 'missing_hours', 'missing_days')),
        status VARCHAR(50) DEFAULT 'pending' CHECK (status IN ('pending', 'finalized')),
        unpaid_ID INT FOREIGN KEY REFERENCES Unpaid_Leave(request_ID),
        attendance_ID INT FOREIGN KEY REFERENCES Attendance(attendance_ID)
    );

    -- Performance table
    CREATE TABLE Performance (
        performance_ID INT IDENTITY(1,1) PRIMARY KEY,
        rating INT CHECK (rating BETWEEN 1 AND 5),
        comments VARCHAR(50),
        semester CHAR(3),
        emp_ID INT FOREIGN KEY REFERENCES Employee(employee_ID)
    );

    -- Employee_Replace_Employee table
    CREATE TABLE Employee_Replace_Employee (
        Emp1_ID INT FOREIGN KEY REFERENCES Employee(employee_ID),
        Emp2_ID INT FOREIGN KEY REFERENCES Employee(employee_ID),
        from_date DATE,
        to_date DATE,
        PRIMARY KEY (Emp1_ID, Emp2_ID, from_date)
    );

    -- Employee_Approve_Leave table
    CREATE TABLE Employee_Approve_Leave (
        Emp1_ID INT FOREIGN KEY REFERENCES Employee(employee_ID),
        Leave_ID INT FOREIGN KEY REFERENCES Leave(request_ID),
        status VARCHAR(50),
        PRIMARY KEY (Emp1_ID, Leave_ID)
    ); 
END;
GO

-- 2.1.c Drop All Tables (EXACTLY AS YOU HAD IT)
CREATE PROCEDURE dropAllTables
AS
BEGIN
    DROP TABLE IF EXISTS Employee_Approve_Leave;
    DROP TABLE IF EXISTS Employee_Replace_Employee;
    DROP TABLE IF EXISTS Performance;
    DROP TABLE IF EXISTS Deduction;
    DROP TABLE IF EXISTS Attendance;
    DROP TABLE IF EXISTS Payroll;
    DROP TABLE IF EXISTS Document;
    DROP TABLE IF EXISTS Compensation_Leave;
    DROP TABLE IF EXISTS Unpaid_Leave;
    DROP TABLE IF EXISTS Medical_Leave;
    DROP TABLE IF EXISTS Accidental_Leave;
    DROP TABLE IF EXISTS Annual_Leave;
    DROP TABLE IF EXISTS Leave;
    DROP TABLE IF EXISTS Role_existsIn_Department;
    DROP TABLE IF EXISTS Employee_Role;
    DROP TABLE IF EXISTS Role;
    DROP TABLE IF EXISTS Employee_Phone;
    DROP TABLE IF EXISTS Employee;
    DROP TABLE IF EXISTS Department;
END;
GO

-- 2.1.d Drop All Procedures, Functions, and Views (except this one) (EXACTLY AS YOU HAD IT)
CREATE PROCEDURE dropAllProceduresFunctionsViews
AS
BEGIN
    DECLARE @sql NVARCHAR(MAX) = '';
    
    -- Drop all stored procedures except dropAllProceduresFunctionsViews
    SELECT @sql = @sql + 'DROP PROCEDURE ' + QUOTENAME(name) + ';'
    FROM sys.procedures 
    WHERE type = 'P'
      AND is_ms_shipped = 0
      AND name != 'dropAllProceduresFunctionsViews';
    
    -- Drop all user-defined functions
    SELECT @sql = @sql + 'DROP FUNCTION ' + QUOTENAME(name) + ';'
    FROM sys.objects
    WHERE type IN ('FN', 'IF', 'TF')
      AND is_ms_shipped = 0;
    
    -- Drop all views
    SELECT @sql = @sql + 'DROP VIEW ' + QUOTENAME(name) + ';'
    FROM sys.views
    WHERE is_ms_shipped = 0;
    
    IF @sql != ''
        EXEC sp_executesql @sql;
END;
GO

-- 2.1.e Clear All Tables (EXACTLY AS YOU HAD IT)
CREATE PROCEDURE clearAllTables
AS
BEGIN
    -- Disable all foreign key constraints
    EXEC sp_MSforeachtable 'ALTER TABLE ? NOCHECK CONSTRAINT ALL';
    
    -- Delete all data from tables
    EXEC sp_MSforeachtable 'DELETE FROM ?';
    
    -- Re-enable all foreign key constraints
    EXEC sp_MSforeachtable 'ALTER TABLE ? WITH CHECK CHECK CONSTRAINT ALL';
    
    -- Reseed identity columns
    EXEC sp_MSforeachtable 'IF OBJECTPROPERTY(object_id(''?''), ''TableHasIdentity'') = 1 DBCC CHECKIDENT (''?'', RESEED, 0)';
END;
GO

-- Execute the procedures to set up the database
EXEC dropAllProceduresFunctionsViews;
EXEC createAllTables;

-- ============================================
-- TEST 1: Department Insertions
-- ============================================
PRINT '=== TEST 1: Department Insertions ===';
INSERT INTO Department (name, building_location) VALUES ('MET', 'Building A');
INSERT INTO Department (name, building_location) VALUES ('IET', 'Building B');
INSERT INTO Department (name, building_location) VALUES ('HR Department', 'Building C');
INSERT INTO Department (name, building_location) VALUES ('Medical Department', 'Building D');
PRINT 'Department insertions successful';
GO

-- ============================================
-- TEST 2: Valid Employee Insertions
-- ============================================
PRINT '=== TEST 2: Valid Employee Insertions ===';
INSERT INTO Employee (first_name, last_name, email, password, employment_status, type_of_contract, dept_name) 
VALUES ('John', 'Doe', 'john@test.com', 'pass123', 'active', 'full_time', 'MET');

INSERT INTO Employee (first_name, last_name, email, password, employment_status, type_of_contract, dept_name) 
VALUES ('Jane', 'Smith', 'jane@test.com', 'pass456', 'onleave', 'part_time', 'IET');

INSERT INTO Employee (first_name, last_name, email, password, employment_status, type_of_contract, dept_name) 
VALUES ('Bob', 'Johnson', 'bob@test.com', 'pass789', 'notice_period', 'full_time', 'HR Department');

INSERT INTO Employee (first_name, last_name, email, password, employment_status, type_of_contract, dept_name) 
VALUES ('Alice', 'Green', 'alice@test.com', 'pass111', 'resigned', 'full_time', 'Medical Department');
PRINT 'Valid employee insertions successful';
GO

-- ============================================
-- TEST 3: Invalid employment_status (SHOULD FAIL)
-- ============================================
PRINT '=== TEST 3: Invalid employment_status (SHOULD FAIL) ===';
BEGIN TRY
    INSERT INTO Employee (first_name, last_name, email, employment_status) 
    VALUES ('Error', 'Test', 'error@test.com', 'resided');
    PRINT 'ERROR: Invalid employment_status was accepted!';
END TRY
BEGIN CATCH
    PRINT 'SUCCESS: Invalid employment_status rejected - ' + ERROR_MESSAGE();
END CATCH
GO

-- ============================================
-- TEST 4: Invalid type_of_contract (SHOULD FAIL)
-- ============================================
PRINT '=== TEST 4: Invalid type_of_contract (SHOULD FAIL) ===';
BEGIN TRY
    INSERT INTO Employee (first_name, last_name, email, type_of_contract) 
    VALUES ('Error', 'Test2', 'error2@test.com', 'contractor');
    PRINT 'ERROR: Invalid type_of_contract was accepted!';
END TRY
BEGIN CATCH
    PRINT 'SUCCESS: Invalid type_of_contract rejected - ' + ERROR_MESSAGE();
END CATCH
GO

-- ============================================
-- TEST 5: Role Insertions
-- ============================================
PRINT '=== TEST 5: Role Insertions ===';
INSERT INTO Role (role_name, title, rank, base_salary, percentage_YOE, percentage_overtime, annual_balance, accidental_balance)
VALUES ('President', 'University President', 1, 50000.00, 5.00, 10.00, 30, 10);

INSERT INTO Role (role_name, title, rank, base_salary, percentage_YOE, percentage_overtime, annual_balance, accidental_balance)
VALUES ('Dean', 'Department Dean', 3, 30000.00, 4.00, 8.00, 25, 8);

INSERT INTO Role (role_name, title, rank, base_salary, percentage_YOE, percentage_overtime, annual_balance, accidental_balance)
VALUES ('Lecturer', 'Lecturer', 5, 15000.00, 3.00, 6.00, 20, 6);
PRINT 'Role insertions successful';
GO

-- ============================================
-- TEST 6: Leave Insertions with Valid Status (UPDATED FOR COMPUTED COLUMN)
-- ============================================
PRINT '=== TEST 6: Leave Insertions ===';
INSERT INTO Leave (date_of_request, start_date, end_date, final_approval_status)
VALUES ('2025-11-01', '2025-11-15', '2025-11-20', 'pending');

INSERT INTO Leave (date_of_request, start_date, end_date, final_approval_status)
VALUES ('2025-10-01', '2025-10-10', '2025-10-12', 'approved');

INSERT INTO Leave (date_of_request, start_date, end_date, final_approval_status)
VALUES ('2025-09-01', '2025-09-05', '2025-09-07', 'rejected');
PRINT 'Leave insertions successful';
GO

-- ============================================
-- TEST 7: Invalid Leave Status (SHOULD FAIL)
-- ============================================
PRINT '=== TEST 7: Invalid Leave Status (SHOULD FAIL) ===';
BEGIN TRY
    INSERT INTO Leave (date_of_request, start_date, end_date, final_approval_status)
    VALUES ('2025-11-01', '2025-11-15', '2025-11-20', 'processing');
    PRINT 'ERROR: Invalid leave status was accepted!';
END TRY
BEGIN CATCH
    PRINT 'SUCCESS: Invalid leave status rejected - ' + ERROR_MESSAGE();
END CATCH
GO

-- ============================================
-- TEST 8: Medical Leave with Valid Type
-- ============================================
PRINT '=== TEST 8: Medical Leave Insertions ===';
INSERT INTO Medical_Leave (request_ID, insurance_status, type, Emp_ID)
VALUES (1, 1, 'sick', 1);

INSERT INTO Medical_Leave (request_ID, insurance_status, type, Emp_ID)
VALUES (2, 1, 'maternity', 1);
PRINT 'Medical leave insertions successful';
GO

-- ============================================
-- TEST 9: Invalid Medical Leave Type (SHOULD FAIL)
-- ============================================
PRINT '=== TEST 9: Invalid Medical Leave Type (SHOULD FAIL) ===';
BEGIN TRY
    INSERT INTO Medical_Leave (request_ID, insurance_status, type, Emp_ID)
    VALUES (3, 1, 'injury', 3);
    PRINT 'ERROR: Invalid medical leave type was accepted!';
END TRY
BEGIN CATCH
    PRINT 'SUCCESS: Invalid medical leave type rejected - ' + ERROR_MESSAGE();
END CATCH
GO

-- ============================================
-- TEST 10: Document with Valid Status
-- ============================================
PRINT '=== TEST 10: Document Insertions ===';
INSERT INTO Document (type, description, file_name, creation_date, expiry_date, status, emp_ID)
VALUES ('Contract', 'Employment Contract', 'contract.pdf', '2025-01-01', '2026-01-01', 'valid', 1);

INSERT INTO Document (type, description, file_name, creation_date, expiry_date, status, emp_ID)
VALUES ('ID', 'National ID', 'id.pdf', '2020-01-01', '2025-01-01', 'expired', 2);
PRINT 'Document insertions successful';
GO

-- ============================================
-- TEST 11: Invalid Document Status (SHOULD FAIL)
-- ============================================
PRINT '=== TEST 11: Invalid Document Status (SHOULD FAIL) ===';
BEGIN TRY
    INSERT INTO Document (type, description, file_name, creation_date, status, emp_ID)
    VALUES ('License', 'Driving License', 'license.pdf', '2025-01-01', 'pending', 1);
    PRINT 'ERROR: Invalid document status was accepted!';
END TRY
BEGIN CATCH
    PRINT 'SUCCESS: Invalid document status rejected - ' + ERROR_MESSAGE();
END CATCH
GO

-- ============================================
-- TEST 12: Attendance with Valid Status (UPDATED FOR COMPUTED COLUMN)
-- ============================================
PRINT '=== TEST 12: Attendance Insertions ===';
INSERT INTO Attendance (date, check_in_time, check_out_time, status, emp_ID)
VALUES ('2025-11-17', '09:00:00', '17:00:00', 'attended', 1);

INSERT INTO Attendance (date, status, emp_ID)
VALUES ('2025-11-17', 'absent', 2);
PRINT 'Attendance insertions successful';
GO

-- ============================================
-- TEST 13: Invalid Attendance Status (SHOULD FAIL)
-- ============================================
PRINT '=== TEST 13: Invalid Attendance Status (SHOULD FAIL) ===';
BEGIN TRY
    INSERT INTO Attendance (date, status, emp_ID)
    VALUES ('2025-11-17', 'late', 1);
    PRINT 'ERROR: Invalid attendance status was accepted!';
END TRY
BEGIN CATCH
    PRINT 'SUCCESS: Invalid attendance status rejected - ' + ERROR_MESSAGE();
END CATCH
GO

-- ============================================
-- TEST 14: Deduction with Valid Type and Status
-- ============================================
PRINT '=== TEST 14: Deduction Insertions ===';
INSERT INTO Deduction (emp_ID, date, amount, type, status)
VALUES (1, '2025-11-17', 100.00, 'missing_hours', 'pending');

INSERT INTO Deduction (emp_ID, date, amount, type, status)
VALUES (2, '2025-11-17', 200.00, 'missing_days', 'finalized');

INSERT INTO Deduction (emp_ID, date, amount, type, status)
VALUES (3, '2025-11-17', 300.00, 'unpaid', 'pending');
PRINT 'Deduction insertions successful';
GO

-- ============================================
-- TEST 15: Invalid Deduction Type (SHOULD FAIL)
-- ============================================
PRINT '=== TEST 15: Invalid Deduction Type (SHOULD FAIL) ===';
BEGIN TRY
    INSERT INTO Deduction (emp_ID, date, amount, type, status)
    VALUES (1, '2025-11-17', 50.00, 'late_arrival', 'pending');
    PRINT 'ERROR: Invalid deduction type was accepted!';
END TRY
BEGIN CATCH
    PRINT 'SUCCESS: Invalid deduction type rejected - ' + ERROR_MESSAGE();
END CATCH
GO

-- ============================================
-- TEST 16: Invalid Deduction Status (SHOULD FAIL)
-- ============================================
PRINT '=== TEST 16: Invalid Deduction Status (SHOULD FAIL) ===';
BEGIN TRY
    INSERT INTO Deduction (emp_ID, date, amount, type, status)
    VALUES (1, '2025-11-17', 50.00, 'unpaid', 'approved');
    PRINT 'ERROR: Invalid deduction status was accepted!';
END TRY
BEGIN CATCH
    PRINT 'SUCCESS: Invalid deduction status rejected - ' + ERROR_MESSAGE();
END CATCH
GO

-- ============================================
-- TEST 17: Performance with Valid Rating
-- ============================================
PRINT '=== TEST 17: Performance Insertions ===';
INSERT INTO Performance (rating, comments, semester, emp_ID)
VALUES (1, 'Needs improvement', 'W25', 1);

INSERT INTO Performance (rating, comments, semester, emp_ID)
VALUES (3, 'Average performance', 'W25', 2);

INSERT INTO Performance (rating, comments, semester, emp_ID)
VALUES (5, 'Excellent work', 'W25', 3);
PRINT 'Performance insertions successful';
GO

-- ============================================
-- TEST 18: Invalid Performance Rating - Too Low (SHOULD FAIL)
-- ============================================
PRINT '=== TEST 18: Invalid Performance Rating - Too Low (SHOULD FAIL) ===';
BEGIN TRY
    INSERT INTO Performance (rating, comments, semester, emp_ID)
    VALUES (0, 'Poor', 'W25', 1);
    PRINT 'ERROR: Invalid rating (0) was accepted!';
END TRY
BEGIN CATCH
    PRINT 'SUCCESS: Invalid rating (0) rejected - ' + ERROR_MESSAGE();
END CATCH
GO

-- ============================================
-- TEST 19: Invalid Performance Rating - Too High (SHOULD FAIL)
-- ============================================
PRINT '=== TEST 19: Invalid Performance Rating - Too High (SHOULD FAIL) ===';
BEGIN TRY
    INSERT INTO Performance (rating, comments, semester, emp_ID)
    VALUES (6, 'Exceptional', 'W25', 1);
    PRINT 'ERROR: Invalid rating (6) was accepted!';
END TRY
BEGIN CATCH
    PRINT 'SUCCESS: Invalid rating (6) rejected - ' + ERROR_MESSAGE();
END CATCH
GO

-- ============================================
-- TEST 20: Summary Query
-- ============================================
PRINT '=== TEST 20: Summary of Inserted Data ===';
SELECT 'Departments' AS TableName, COUNT(*) AS RecordCount FROM Department
UNION ALL
SELECT 'Employees', COUNT(*) FROM Employee
UNION ALL
SELECT 'Roles', COUNT(*) FROM Role
UNION ALL
SELECT 'Leaves', COUNT(*) FROM Leave
UNION ALL
SELECT 'Medical Leaves', COUNT(*) FROM Medical_Leave
UNION ALL
SELECT 'Documents', COUNT(*) FROM Document
UNION ALL
SELECT 'Attendance', COUNT(*) FROM Attendance
UNION ALL
SELECT 'Deductions', COUNT(*) FROM Deduction
UNION ALL
SELECT 'Performance', COUNT(*) FROM Performance;
GO

-- ============================================
-- TEST 21: Test computed columns work correctly
-- ============================================
PRINT '=== TEST 21: Testing Computed Columns ===';
PRINT 'Leave num_days computation:';
SELECT request_ID, start_date, end_date, num_days FROM Leave;

PRINT 'Attendance total_duration computation:';
SELECT attendance_ID, check_in_time, check_out_time, total_duration FROM Attendance WHERE check_in_time IS NOT NULL;
GO

-- ============================================
-- FINAL CLEANUP: Drop all tables to clean up
-- ============================================
PRINT '=== FINAL CLEANUP: Dropping all tables ===';
EXEC dropAllTables;
PRINT 'All tables dropped successfully';
GO