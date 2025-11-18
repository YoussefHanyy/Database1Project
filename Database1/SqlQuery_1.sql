-- ============================================================================
-- FINAL CLEAN SQL SCRIPT
-- University HR Management System - Team 64
-- ============================================================================

USE master;
GO

-- 1. CLEANUP: Drop database if exists (Force Close Connections)
IF DB_ID('University_HR_ManagementSystem_Team_64') IS NOT NULL
BEGIN
    ALTER DATABASE University_HR_ManagementSystem_Team_64 SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE University_HR_ManagementSystem_Team_64;
END
GO

-- 2. SETUP: Create and Use Database
CREATE DATABASE University_HR_ManagementSystem_Team_64;
GO

USE University_HR_ManagementSystem_Team_64;
GO

-- ============================================================================
-- 2.1.b Create All Tables Procedure
-- ============================================================================
CREATE PROCEDURE createAllTables
AS
BEGIN
    -- Department Table
    CREATE TABLE Department (
        name VARCHAR(50) PRIMARY KEY,
        building_location VARCHAR(50)
    );

    -- Employee Table
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

    -- Employee_Phone Table
    CREATE TABLE Employee_Phone (
        emp_ID INT FOREIGN KEY REFERENCES Employee(employee_ID),
        phone_num CHAR(11),
        PRIMARY KEY (emp_ID, phone_num)
    );

    -- Role Table
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

    -- Employee_Role Table
    CREATE TABLE Employee_Role (
        emp_ID INT FOREIGN KEY REFERENCES Employee(employee_ID),
        role_name VARCHAR(50) FOREIGN KEY REFERENCES Role(role_name),
        PRIMARY KEY (emp_ID, role_name)
    );

    -- Role_existsIn_Department Table
    CREATE TABLE Role_existsIn_Department (
        department_name VARCHAR(50) FOREIGN KEY REFERENCES Department(name),
        Role_name VARCHAR(50) FOREIGN KEY REFERENCES Role(role_name),
        PRIMARY KEY (department_name, Role_name)
    );

    -- Leave Table
    CREATE TABLE Leave (
        request_ID INT IDENTITY(1,1) PRIMARY KEY,
        date_of_request DATE,
        start_date DATE,
        end_date DATE,
        num_days AS (DATEDIFF(day, start_date, end_date)), 
        final_approval_status VARCHAR(50) DEFAULT 'pending' CHECK (final_approval_status IN ('approved', 'rejected', 'pending'))
    );

    -- Annual_Leave Table
    CREATE TABLE Annual_Leave (
        request_ID INT FOREIGN KEY REFERENCES Leave(request_ID),
        emp_ID INT FOREIGN KEY REFERENCES Employee(employee_ID),
        replacement_emp INT FOREIGN KEY REFERENCES Employee(employee_ID),
        PRIMARY KEY (request_ID)
    );

    -- Accidental_Leave Table
    CREATE TABLE Accidental_Leave (
        request_ID INT FOREIGN KEY REFERENCES Leave(request_ID),
        emp_ID INT FOREIGN KEY REFERENCES Employee(employee_ID),
        PRIMARY KEY (request_ID)
    );

    -- Medical_Leave Table
    CREATE TABLE Medical_Leave (
        request_ID INT FOREIGN KEY REFERENCES Leave(request_ID),
        insurance_status BIT,
        disability_details VARCHAR(50),
        type VARCHAR(50) CHECK (type IN ('sick', 'maternity')),
        Emp_ID INT FOREIGN KEY REFERENCES Employee(employee_ID),
        PRIMARY KEY (request_ID)
    );

    -- Unpaid_Leave Table
    CREATE TABLE Unpaid_Leave (
        request_ID INT FOREIGN KEY REFERENCES Leave(request_ID),
        Emp_ID INT FOREIGN KEY REFERENCES Employee(employee_ID),
        PRIMARY KEY (request_ID)
    );

    -- Compensation_Leave Table
    CREATE TABLE Compensation_Leave (
        request_ID INT FOREIGN KEY REFERENCES Leave(request_ID),
        reason VARCHAR(50),
        date_of_original_workday DATE,
        emp_ID INT FOREIGN KEY REFERENCES Employee(employee_ID),
        replacement_emp INT FOREIGN KEY REFERENCES Employee(employee_ID),
        PRIMARY KEY (request_ID)
    );

    -- Document Table
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

    -- Payroll Table
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

    -- Attendance Table
    CREATE TABLE Attendance (
        attendance_ID INT IDENTITY(1,1) PRIMARY KEY,
        date DATE,
        check_in_time TIME,
        check_out_time TIME,
        total_duration AS (DATEDIFF(HOUR, check_in_time, check_out_time)), 
        status VARCHAR(50) DEFAULT 'Absent' CHECK (status IN ('Absent', 'attended')), 
        emp_ID INT FOREIGN KEY REFERENCES Employee(employee_ID)
    );

    -- Deduction Table
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

    -- Performance Table
    CREATE TABLE Performance (
        performance_ID INT IDENTITY(1,1) PRIMARY KEY,
        rating INT CHECK (rating BETWEEN 1 AND 5),
        comments VARCHAR(50),
        semester CHAR(3),
        emp_ID INT FOREIGN KEY REFERENCES Employee(employee_ID)
    );

    -- Employee_Replace_Employee Table
    CREATE TABLE Employee_Replace_Employee (
        Emp1_ID INT FOREIGN KEY REFERENCES Employee(employee_ID),
        Emp2_ID INT FOREIGN KEY REFERENCES Employee(employee_ID),
        from_date DATE,
        to_date DATE,
        PRIMARY KEY (Emp1_ID, Emp2_ID, from_date)
    );

    -- Employee_Approve_Leave Table
    CREATE TABLE Employee_Approve_Leave (
        Emp1_ID INT FOREIGN KEY REFERENCES Employee(employee_ID),
        Leave_ID INT FOREIGN KEY REFERENCES Leave(request_ID),
        status VARCHAR(50),
        PRIMARY KEY (Emp1_ID, Leave_ID)
    ); 
END;
GO

-- ============================================================================
-- 2.1.c Drop All Tables Procedure
-- ============================================================================
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
    DROP TABLE IF EXISTS Holiday;
END;
GO

-- ============================================================================
-- 2.1.d Drop All Procedures, Functions, and Views Procedure
-- ============================================================================
CREATE PROCEDURE dropAllProceduresFunctionsViews
AS
BEGIN
    DECLARE @sql NVARCHAR(MAX) = '';
    
    SELECT @sql = @sql + 'DROP PROCEDURE ' + QUOTENAME(name) + ';'
    FROM sys.procedures 
    WHERE type = 'P'
      AND is_ms_shipped = 0
      AND name NOT IN ('dropAllProceduresFunctionsViews', 'createAllTables', 'dropAllTables', 'clearAllTables', 'Create_Holiday');
    
    SELECT @sql = @sql + 'DROP FUNCTION ' + QUOTENAME(name) + ';'
    FROM sys.objects
    WHERE type IN ('FN', 'IF', 'TF') AND is_ms_shipped = 0;
    
    SELECT @sql = @sql + 'DROP VIEW ' + QUOTENAME(name) + ';'
    FROM sys.views
    WHERE is_ms_shipped = 0;
    
    IF @sql != '' EXEC sp_executesql @sql;
END;
GO

-- ============================================================================
-- 2.1.e Clear All Tables Procedure
-- ============================================================================
CREATE PROCEDURE clearAllTables
AS
BEGIN
    EXEC sp_MSforeachtable 'ALTER TABLE ? NOCHECK CONSTRAINT ALL';
    EXEC sp_MSforeachtable 'DELETE FROM ?';
    EXEC sp_MSforeachtable 'ALTER TABLE ? WITH CHECK CHECK CONSTRAINT ALL';
    EXEC sp_MSforeachtable 'IF OBJECTPROPERTY(object_id(''?''), ''TableHasIdentity'') = 1 DBCC CHECKIDENT (''?'', RESEED, 0)';
END;
GO

-- ============================================================================
-- EXECUTE createAllTables to enable View/Function creation
-- ============================================================================
EXEC createAllTables;
GO

-- ============================================================================
-- 2.2 Views
-- ============================================================================
CREATE VIEW allEmployeeProfiles AS
SELECT employee_ID, first_name, last_name, gender, email, address, years_of_experience, official_day_off, type_of_contract, employment_status, annual_balance, accidental_balance FROM Employee;
GO

CREATE VIEW NoEmployeeDept AS
SELECT D.name AS department_name, COUNT(E.employee_ID) AS number_of_employees FROM Employee E RIGHT JOIN Department D ON E.dept_name = D.name GROUP BY D.name;
GO

CREATE VIEW allPerformance AS
SELECT P.performance_ID, P.rating, P.comments, P.semester, E.employee_ID, E.first_name, E.last_name, E.dept_name FROM Performance P INNER JOIN Employee E ON P.emp_ID = E.employee_ID WHERE P.semester LIKE 'W%';
GO

CREATE VIEW allRejectedMedicals AS
SELECT ML.request_ID, ML.type, ML.insurance_status, ML.disability_details, L.start_date, L.end_date, L.num_days, L.date_of_request, E.employee_ID, E.first_name, E.last_name, E.dept_name FROM Medical_Leave ML INNER JOIN Leave L ON ML.request_ID = L.request_ID INNER JOIN Employee E ON ML.Emp_ID = E.employee_ID WHERE L.final_approval_status = 'rejected';
GO

CREATE VIEW allEmployeeAttendance AS
SELECT A.attendance_ID, A.date, A.check_in_time, A.check_out_time, A.total_duration, A.status, E.employee_ID, E.first_name, E.last_name, E.dept_name, E.type_of_contract FROM Attendance A INNER JOIN Employee E ON A.emp_ID = E.employee_ID WHERE A.date = DATEADD(day, -1, CAST(GETDATE() AS DATE));
GO

-- ============================================================================
-- 2.3 Admin Procedures
-- ============================================================================
CREATE PROCEDURE Update_Status_Doc
AS
BEGIN
    UPDATE Document SET status = 'expired' WHERE expiry_date < CAST(GETDATE() AS DATE) AND status = 'valid';
END;
GO

CREATE PROCEDURE Remove_Deductions
AS
BEGIN
    DELETE FROM Deduction WHERE emp_ID IN (SELECT employee_ID FROM Employee WHERE employment_status = 'resigned');
END;
GO

CREATE PROCEDURE Create_Holiday
AS
BEGIN
    IF OBJECT_ID('Holiday', 'U') IS NULL
    BEGIN
        CREATE TABLE Holiday (holiday_id INT IDENTITY(1,1) PRIMARY KEY, name VARCHAR(50), from_date DATE, to_date DATE);
    END
END;
GO

CREATE PROCEDURE Add_Holiday
    @holiday_name VARCHAR(50), @from_date DATE, @to_date DATE
AS
BEGIN
    INSERT INTO Holiday (name, from_date, to_date) VALUES (@holiday_name, @from_date, @to_date);
END;
GO

CREATE PROCEDURE Intitiate_Attendance
AS
BEGIN
    INSERT INTO Attendance (date, emp_ID)
    SELECT CAST(GETDATE() AS DATE), e.employee_ID
    FROM Employee e WHERE e.employment_status = 'active'
    AND NOT EXISTS (SELECT 1 FROM Attendance a WHERE a.emp_ID = e.employee_ID AND a.date = CAST(GETDATE() AS DATE));
END;
GO

CREATE PROCEDURE Update_Attendance
    @Employee_id INT, @check_in_time TIME, @check_out_time TIME
AS
BEGIN
    DECLARE @status VARCHAR(50) = CASE WHEN DATEDIFF(HOUR, @check_in_time, @check_out_time) > 0 THEN 'attended' ELSE 'Absent' END;
    UPDATE Attendance SET check_in_time = @check_in_time, check_out_time = @check_out_time, status = @status
    WHERE emp_ID = @Employee_id AND date = CAST(GETDATE() AS DATE);
END;
GO

CREATE PROCEDURE Remove_Holiday
AS
BEGIN
    IF OBJECT_ID('Holiday', 'U') IS NOT NULL
    BEGIN
        DELETE FROM Attendance WHERE date IN (SELECT DISTINCT a.date FROM Attendance a INNER JOIN Holiday h ON a.date BETWEEN h.from_date AND h.to_date);
    END
    ELSE PRINT 'Holiday table does not exist.';
END;
GO

CREATE PROCEDURE Remove_DayOff
    @Employee_id INT
AS
BEGIN
    DECLARE @current_date DATE = GETDATE();
    DECLARE @month_start DATE = DATEFROMPARTS(YEAR(@current_date), MONTH(@current_date), 1);
    DELETE FROM Attendance WHERE emp_ID = @Employee_id AND date >= @month_start AND date <= @current_date AND status = 'Absent' 
    AND DATENAME(WEEKDAY, date) = (SELECT official_day_off FROM Employee WHERE employee_ID = @Employee_id);
END;
GO

CREATE PROCEDURE Remove_Approved_Leaves
    @Employee_id INT
AS
BEGIN
    DELETE FROM Attendance WHERE emp_ID = @Employee_id AND EXISTS (
        SELECT 1 FROM Leave l WHERE l.final_approval_status = 'approved' AND l.start_date <= Attendance.date AND l.end_date >= Attendance.date
        AND l.request_ID IN (
            SELECT request_ID FROM Annual_Leave WHERE emp_ID = @Employee_id UNION ALL
            SELECT request_ID FROM Accidental_Leave WHERE emp_ID = @Employee_id UNION ALL
            SELECT request_ID FROM Medical_Leave WHERE Emp_ID = @Employee_id UNION ALL
            SELECT request_ID FROM Unpaid_Leave WHERE Emp_ID = @Employee_id UNION ALL
            SELECT request_ID FROM Compensation_Leave WHERE emp_ID = @Employee_id
        )
    );
END;
GO

CREATE PROCEDURE Replace_employee
    @Emp1_ID INT, @Emp2_ID INT, @from_date DATE, @to_date DATE
AS
BEGIN
    INSERT INTO Employee_Replace_Employee (Emp1_ID, Emp2_ID, from_date, to_date) VALUES (@Emp1_ID, @Emp2_ID, @from_date, @to_date);
END;
GO

-- ============================================================================
-- 2.4 HR Procedures
-- ============================================================================
CREATE FUNCTION HRLoginValidation (@employee_ID INT, @password VARCHAR(50))
RETURNS BIT
AS
BEGIN
    DECLARE @Success BIT = 0;
    IF EXISTS (SELECT 1 FROM Employee E JOIN Employee_Role ER ON E.employee_ID = ER.emp_ID WHERE E.employee_ID = @employee_ID AND E.password = @password AND (ER.role_name LIKE 'HR_%' OR ER.role_name = 'HR Manager'))
        SET @Success = 1;
    RETURN @Success;
END;
GO

CREATE PROCEDURE HR_approval_an_acc @request_ID INT, @HR_ID INT
AS
BEGIN
    DECLARE @emp_ID INT, @num_days INT, @annual_bal INT, @accidental_bal INT;
    SELECT @emp_ID = E.employee_ID, @num_days = L.num_days, @annual_bal = E.annual_balance, @accidental_bal = E.accidental_balance
    FROM Leave L INNER JOIN Annual_Leave AL ON L.request_ID = AL.request_ID INNER JOIN Employee E ON AL.emp_ID = E.employee_ID WHERE L.request_ID = @request_ID;

    IF @@ROWCOUNT = 0
        SELECT @emp_ID = E.employee_ID, @num_days = L.num_days, @annual_bal = E.annual_balance, @accidental_bal = E.accidental_balance
        FROM Leave L INNER JOIN Accidental_Leave ACL ON L.request_ID = ACL.request_ID INNER JOIN Employee E ON ACL.emp_ID = E.employee_ID WHERE L.request_ID = @request_ID;

    IF EXISTS (SELECT 1 FROM Annual_Leave WHERE request_ID = @request_ID)
        UPDATE Leave SET final_approval_status = CASE WHEN @annual_bal >= @num_days THEN 'approved' ELSE 'rejected' END WHERE request_ID = @request_ID;
    ELSE
        UPDATE Leave SET final_approval_status = CASE WHEN @accidental_bal >= @num_days THEN 'approved' ELSE 'rejected' END WHERE request_ID = @request_ID;

    IF EXISTS (SELECT 1 FROM Annual_Leave WHERE request_ID = @request_ID) AND @annual_bal >= @num_days
        UPDATE Employee SET annual_balance = annual_balance - (@num_days + 1) WHERE employee_ID = @emp_ID;
    ELSE IF EXISTS (SELECT 1 FROM Accidental_Leave WHERE request_ID = @request_ID) AND @accidental_bal >= @num_days
        UPDATE Employee SET accidental_balance = accidental_balance - (@num_days + 1) WHERE employee_ID = @emp_ID;
END;
GO

CREATE PROCEDURE HR_approval_unpaid @request_ID INT, @HR_ID INT
AS
BEGIN
    DECLARE @emp_ID INT, @num_days INT, @contract_type VARCHAR(50), @approved_unpaid_count INT;
    SELECT @emp_ID = ul.Emp_ID, @num_days = l.num_days FROM Leave l INNER JOIN Unpaid_Leave ul ON l.request_ID = ul.request_ID WHERE l.request_ID = @request_ID;
    SELECT @contract_type = type_of_contract FROM Employee WHERE employee_ID = @emp_ID;
    SELECT @approved_unpaid_count = COUNT(*) FROM Leave l INNER JOIN Unpaid_Leave ul ON l.request_ID = ul.request_ID WHERE ul.Emp_ID = @emp_ID AND l.final_approval_status = 'approved' AND YEAR(l.start_date) = YEAR(GETDATE());

    IF @contract_type = 'part_time' OR @num_days > 29 OR @approved_unpaid_count > 0
        UPDATE Leave SET final_approval_status = 'rejected' WHERE request_ID = @request_ID;
    ELSE
        UPDATE Leave SET final_approval_status = 'approved' WHERE request_ID = @request_ID;
END;
GO

CREATE PROCEDURE HR_approval_comp @request_ID INT, @HR_ID INT
AS
BEGIN
    DECLARE @emp_ID INT, @original_date DATE, @req_date DATE;
    SELECT @emp_ID = cl.emp_ID, @original_date = cl.date_of_original_workday, @req_date = l.date_of_request
    FROM Compensation_Leave cl INNER JOIN Leave l ON cl.request_ID = l.request_ID WHERE cl.request_ID = @request_ID;

    IF MONTH(@original_date) != MONTH(@req_date) OR YEAR(@original_date) != YEAR(@req_date)
    BEGIN
        UPDATE Leave SET final_approval_status = 'rejected' WHERE request_ID = @request_ID;
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM Attendance WHERE emp_ID = @emp_ID AND date = @original_date AND total_duration >= 8)
        UPDATE Leave SET final_approval_status = 'approved' WHERE request_ID = @request_ID;
    ELSE
        UPDATE Leave SET final_approval_status = 'rejected' WHERE request_ID = @request_ID;
END;
GO

CREATE PROCEDURE Deduction_hours @employee_ID INT
AS
BEGIN
    DECLARE @attendance_id INT;
    DECLARE @current_date DATE = GETDATE();
    DECLARE @month_start DATE = DATEFROMPARTS(YEAR(@current_date), MONTH(@current_date), 1);
    
    SELECT TOP 1 @attendance_id = attendance_ID FROM Attendance WHERE emp_ID = @employee_ID AND date >= @month_start AND date <= @current_date AND status = 'attended' AND DATEDIFF(HOUR, check_in_time, check_out_time) < 8 ORDER BY date ASC;
    
    IF @attendance_id IS NOT NULL
        INSERT INTO Deduction (emp_ID, date, amount, type, status, attendance_ID) VALUES (@employee_ID, @current_date, 0, 'missing_hours', 'pending', @attendance_id);
END;
GO

CREATE PROCEDURE Deduction_days @employee_ID INT
AS
BEGIN
    DECLARE @current_date DATE = GETDATE();
    DECLARE @month_start DATE = DATEFROMPARTS(YEAR(@current_date), MONTH(@current_date), 1);
    DECLARE @days_missing INT = 0;
    DECLARE @official_day_off VARCHAR(50);
    SELECT @official_day_off = official_day_off FROM Employee WHERE employee_ID = @employee_ID;
    
    ;WITH DateRange AS (
        SELECT @month_start AS d UNION ALL SELECT DATEADD(DAY, 1, d) FROM DateRange WHERE d < @current_date
    ),
    WorkDays AS (SELECT d AS work_date FROM DateRange WHERE DATENAME(WEEKDAY, d) != @official_day_off)
    SELECT @days_missing = COUNT(*) FROM WorkDays wd WHERE NOT EXISTS (SELECT 1 FROM Attendance WHERE emp_ID = @employee_ID AND date = wd.work_date AND status = 'attended') OPTION (MAXRECURSION 32); 
    
    IF @days_missing > 0 INSERT INTO Deduction (emp_ID, date, amount, type, status) VALUES (@employee_ID, @current_date, 0, 'missing_days', 'pending');
END;
GO

CREATE PROCEDURE Deduction_unpaid @employee_ID INT
AS
BEGIN
    DECLARE @current_date DATE = GETDATE();
    DECLARE @current_month_start DATE = DATEFROMPARTS(YEAR(@current_date), MONTH(@current_date), 1);
    DECLARE @prev_month_start DATE = DATEADD(MONTH, -1, @current_month_start);
    DECLARE @prev_month_end DATE = DATEADD(DAY, -1, @current_month_start);
    
    INSERT INTO Deduction (emp_ID, date, amount, type, status, unpaid_ID)
    SELECT ul.Emp_ID, @prev_month_end, 0, 'unpaid', 'pending', ul.request_ID
    FROM Unpaid_Leave ul INNER JOIN Leave l ON ul.request_ID = l.request_ID
    WHERE ul.Emp_ID = @employee_ID AND l.final_approval_status = 'approved' AND l.start_date <= @prev_month_end AND l.end_date >= @prev_month_start 
    AND NOT EXISTS (SELECT 1 FROM Deduction d WHERE d.emp_ID = ul.Emp_ID AND d.type = 'unpaid' AND d.unpaid_ID = ul.request_ID AND MONTH(d.date) = MONTH(@prev_month_start) AND YEAR(d.date) = YEAR(@prev_month_start));
    
    INSERT INTO Deduction (emp_ID, date, amount, type, status, unpaid_ID)
    SELECT ul.Emp_ID, @current_date, 0, 'unpaid', 'pending', ul.request_ID
    FROM Unpaid_Leave ul INNER JOIN Leave l ON ul.request_ID = l.request_ID
    WHERE ul.Emp_ID = @employee_ID AND l.final_approval_status = 'approved' AND l.start_date <= EOMONTH(@current_date) AND l.end_date >= @current_month_start
    AND NOT EXISTS (SELECT 1 FROM Deduction d WHERE d.emp_ID = ul.Emp_ID AND d.type = 'unpaid' AND d.unpaid_ID = ul.request_ID AND MONTH(d.date) = MONTH(@current_date) AND YEAR(d.date) = YEAR(@current_date));
END;
GO

CREATE FUNCTION Bonus_amount(@employee_ID INT) RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @bonus DECIMAL(10,2) = 0, @salary DECIMAL(10,2), @rate_per_hour DECIMAL(10,4), @overtime_factor DECIMAL(4,2);
    SELECT TOP 1 @salary = e.salary, @overtime_factor = r.percentage_overtime FROM Employee e JOIN Employee_Role er ON e.employee_ID = er.emp_ID JOIN Role r ON er.role_name = r.role_name WHERE e.employee_ID = @employee_ID ORDER BY r.rank ASC;
    SET @rate_per_hour = (@salary / 22.0) / 8.0;
    DECLARE @total_extra_hours INT = 0;
    SELECT @total_extra_hours = ISNULL(SUM(total_duration - 8), 0) FROM Attendance WHERE emp_ID = @employee_ID AND total_duration > 8 AND MONTH(date) = MONTH(GETDATE()) AND YEAR(date) = YEAR(GETDATE());
    SET @bonus = @rate_per_hour * ((@overtime_factor * @total_extra_hours) / 100.0);
    RETURN @bonus;
END;
GO

CREATE PROCEDURE Add_Payroll @employee_ID INT, @from_date DATE, @to_date DATE
AS
BEGIN
    DECLARE @salary DECIMAL(10,2), @bonus DECIMAL(10,2), @deduction DECIMAL(10,2), @final_salary DECIMAL(10,2);
    SELECT @salary = salary FROM Employee WHERE employee_ID = @employee_ID;
    SET @bonus = dbo.Bonus_amount(@employee_ID);
    SELECT @deduction = ISNULL(SUM(amount), 0) FROM Deduction WHERE emp_ID = @employee_ID AND status = 'pending' AND date BETWEEN @from_date AND @to_date;
    SET @final_salary = @salary + @bonus - @deduction;
    INSERT INTO Payroll (payment_date, final_salary_amount, from_date, to_date, comments, bonus_amount, deductions_amount, emp_ID)
    VALUES (GETDATE(), @final_salary, @from_date, @to_date, 'Monthly Payroll', @bonus, @deduction, @employee_ID);
    UPDATE Deduction SET status = 'finalized' WHERE emp_ID = @employee_ID AND status = 'pending' AND date BETWEEN @from_date AND @to_date;
END;
GO

-- ============================================================================
-- 2.5 Employee Procedures
-- ============================================================================
CREATE FUNCTION EmployeeLoginValidation (@employee_ID INT, @password VARCHAR(50)) RETURNS BIT
AS
BEGIN
    DECLARE @Success BIT = 0;
    IF EXISTS (SELECT 1 FROM Employee E WHERE E.employee_ID = @employee_ID AND E.password = @password) SET @Success = 1;
    RETURN @Success;
END;
GO

CREATE FUNCTION MyPerformance (@employee_ID INT, @semester CHAR(3)) RETURNS TABLE 
AS RETURN (SELECT * FROM Performance WHERE emp_ID = @employee_ID AND semester = @semester);
GO

CREATE FUNCTION MyAttendance (@employee_ID INT) RETURNS TABLE 
AS RETURN (SELECT A.attendance_ID, A.date, A.check_in_time, A.check_out_time, A.total_duration, A.status, A.emp_ID FROM Attendance A JOIN Employee E ON A.emp_ID = E.employee_ID WHERE A.emp_ID = @employee_ID AND MONTH(A.date) = MONTH(GETDATE()) AND YEAR(A.date) = YEAR(GETDATE()) AND NOT (A.status = 'Absent' AND LTRIM(RTRIM(DATENAME(WEEKDAY, A.date))) = LTRIM(RTRIM(E.official_day_off))));
GO

CREATE FUNCTION Last_month_payroll (@employee_ID INT) RETURNS TABLE 
AS RETURN (SELECT TOP 1 * FROM Payroll WHERE emp_ID = @employee_ID AND from_date >= DATEADD(MONTH, -1, DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1)) AND to_date < DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1) ORDER BY payment_date DESC);
GO

CREATE FUNCTION Deductions_Attendance (@employee_ID INT, @target_month INT) RETURNS TABLE 
AS RETURN (SELECT D.deduction_ID, D.emp_ID, D.date, D.amount, D.type, D.status, D.unpaid_ID, D.attendance_ID FROM Deduction D WHERE D.emp_ID = @employee_ID AND MONTH(D.date) = @target_month AND YEAR(D.date) = YEAR(GETDATE()) AND D.type IN ('missing_hours', 'missing_days'));
GO

CREATE FUNCTION Is_On_Leave (@employee_ID INT, @from_date DATE, @to_date DATE) RETURNS BIT
AS
BEGIN
    DECLARE @IsOnLeave BIT = 0;
    IF EXISTS (SELECT 1 FROM Leave l LEFT JOIN Annual_Leave al ON l.request_ID = al.request_ID LEFT JOIN Accidental_Leave acl ON l.request_ID = acl.request_ID LEFT JOIN Medical_Leave ml ON l.request_ID = ml.request_ID LEFT JOIN Unpaid_Leave ul ON l.request_ID = ul.request_ID LEFT JOIN Compensation_Leave cl ON l.request_ID = cl.request_ID WHERE l.final_approval_status IN ('approved', 'pending') AND l.start_date <= @to_date AND l.end_date >= @from_date AND (al.emp_ID = @employee_ID OR acl.emp_ID = @employee_ID OR ml.Emp_ID = @employee_ID OR ul.Emp_ID = @employee_ID OR cl.emp_ID = @employee_ID))
        SET @IsOnLeave = 1;
    RETURN @IsOnLeave;
END;
GO

CREATE PROCEDURE Update_Employment_Status @Employee_ID INT
AS
BEGIN
    DECLARE @IsOnLeave BIT;
    SET @IsOnLeave = dbo.Is_On_Leave(@Employee_ID, CAST(GETDATE() AS DATE), CAST(GETDATE() AS DATE));
    IF @IsOnLeave = 1 UPDATE Employee SET employment_status = 'onleave' WHERE employee_ID = @Employee_ID;
    ELSE UPDATE Employee SET employment_status = 'active' WHERE employee_ID = @Employee_ID AND employment_status = 'onleave';
END;
GO

CREATE PROCEDURE Submit_annual @employee_ID INT, @replacement_emp INT, @start_date DATE, @end_date DATE
AS
BEGIN
    INSERT INTO Leave (date_of_request, start_date, end_date) VALUES (GETDATE(), @start_date, @end_date);
    DECLARE @req_ID INT = SCOPE_IDENTITY();
    INSERT INTO Annual_Leave (request_ID, emp_ID, replacement_emp) VALUES (@req_ID, @employee_ID, @replacement_emp);
    DECLARE @Dean_ID INT, @HR_Rep_ID INT;
    SELECT TOP 1 @Dean_ID = E.employee_ID FROM Employee E JOIN Employee_Role ER ON E.employee_ID = ER.emp_ID WHERE E.dept_name = (SELECT dept_name FROM Employee WHERE employee_ID = @employee_ID) AND ER.role_name = 'Dean';
    SELECT TOP 1 @HR_Rep_ID = E.employee_ID FROM Employee E JOIN Employee_Role ER ON E.employee_ID = ER.emp_ID WHERE ER.role_name LIKE 'HR_Representative_%'; 
    IF @Dean_ID IS NOT NULL INSERT INTO Employee_Approve_Leave (Emp1_ID, Leave_ID, status) VALUES (@Dean_ID, @req_ID, 'pending');
    IF @HR_Rep_ID IS NOT NULL INSERT INTO Employee_Approve_Leave (Emp1_ID, Leave_ID, status) VALUES (@HR_Rep_ID, @req_ID, 'pending');
END;
GO

CREATE FUNCTION Status_leaves (@employee_ID INT) RETURNS TABLE 
AS RETURN (SELECT l.request_ID, l.date_of_request, l.final_approval_status AS status FROM Leave l WHERE MONTH(l.date_of_request) = MONTH(GETDATE()) AND YEAR(l.date_of_request) = YEAR(GETDATE()) AND l.request_ID IN (SELECT request_ID FROM Annual_Leave WHERE emp_ID = @employee_ID UNION ALL SELECT request_ID FROM Accidental_Leave WHERE emp_ID = @employee_ID));
GO

CREATE PROCEDURE Upperboard_approve_annual @request_ID INT, @Upperboard_ID INT, @replacement_ID INT
AS
BEGIN
    DECLARE @emp_dept VARCHAR(50), @rep_dept VARCHAR(50), @rep_on_leave BIT = 0, @start_date DATE, @end_date DATE;
    SELECT @start_date = start_date, @end_date = end_date FROM Leave WHERE request_ID = @request_ID;
    SELECT @emp_dept = dept_name FROM Employee WHERE employee_ID = (SELECT emp_ID FROM Annual_Leave WHERE request_ID = @request_ID);
    SELECT @rep_dept = dept_name FROM Employee WHERE employee_ID = @replacement_ID;
    SET @rep_on_leave = dbo.Is_On_Leave(@replacement_ID, @start_date, @end_date);
    
    IF @rep_on_leave = 0 AND @emp_dept = @rep_dept UPDATE Employee_Approve_Leave SET status = 'approved' WHERE Leave_ID = @request_ID AND Emp1_ID = @Upperboard_ID;
    ELSE BEGIN UPDATE Employee_Approve_Leave SET status = 'rejected' WHERE Leave_ID = @request_ID AND Emp1_ID = @Upperboard_ID; UPDATE Leave SET final_approval_status = 'rejected' WHERE request_ID = @request_ID; END
END;
GO

CREATE PROCEDURE Submit_accidental @employee_ID INT, @start_date DATE, @end_date DATE
AS
BEGIN
    IF DATEDIFF(day, @start_date, @end_date) != 0 BEGIN PRINT 'Accidental leave must be 1 day only.'; RETURN; END
    INSERT INTO Leave (date_of_request, start_date, end_date) VALUES (GETDATE(), @start_date, @end_date);
    DECLARE @req_ID INT = SCOPE_IDENTITY();
    INSERT INTO Accidental_Leave (request_ID, emp_ID) VALUES (@req_ID, @employee_ID);
    DECLARE @Dean_ID INT, @HR_Rep_ID INT;
    SELECT TOP 1 @Dean_ID = E.employee_ID FROM Employee E JOIN Employee_Role ER ON E.employee_ID = ER.emp_ID WHERE E.dept_name = (SELECT dept_name FROM Employee WHERE employee_ID = @employee_ID) AND ER.role_name = 'Dean';
    SELECT TOP 1 @HR_Rep_ID = E.employee_ID FROM Employee E JOIN Employee_Role ER ON E.employee_ID = ER.emp_ID WHERE ER.role_name LIKE 'HR_Representative_%';
    IF @Dean_ID IS NOT NULL INSERT INTO Employee_Approve_Leave (Emp1_ID, Leave_ID, status) VALUES (@Dean_ID, @req_ID, 'pending');
    IF @HR_Rep_ID IS NOT NULL INSERT INTO Employee_Approve_Leave (Emp1_ID, Leave_ID, status) VALUES (@HR_Rep_ID, @req_ID, 'pending');
END;
GO

CREATE PROCEDURE Submit_medical @employee_ID INT, @start_date DATE, @end_date DATE, @type VARCHAR(50), @insurance_status BIT, @disability_details VARCHAR(50), @document_description VARCHAR(50), @file_name VARCHAR(50)
AS
BEGIN
    INSERT INTO Leave (date_of_request, start_date, end_date) VALUES (GETDATE(), @start_date, @end_date);
    DECLARE @req_ID INT = SCOPE_IDENTITY();
    INSERT INTO Medical_Leave (request_ID, insurance_status, disability_details, type, Emp_ID) VALUES (@req_ID, @insurance_status, @disability_details, @type, @employee_ID);
    INSERT INTO Document (type, description, file_name, creation_date, status, medical_ID) VALUES ('Medical', @document_description, @file_name, GETDATE(), 'valid', @req_ID);
END;
GO

CREATE PROCEDURE Submit_unpaid @employee_ID INT, @start_date DATE, @end_date DATE, @document_description VARCHAR(50), @file_name VARCHAR(50)
AS
BEGIN
    INSERT INTO Leave (date_of_request, start_date, end_date) VALUES (GETDATE(), @start_date, @end_date);
    DECLARE @req_ID INT = SCOPE_IDENTITY();
    INSERT INTO Unpaid_Leave (request_ID, Emp_ID) VALUES (@req_ID, @employee_ID);
    INSERT INTO Document (type, description, file_name, creation_date, status, unpaid_ID) VALUES ('Unpaid Memo', @document_description, @file_name, GETDATE(), 'valid', @req_ID);
END;
GO

CREATE PROCEDURE Upperboard_approve_unpaids @request_ID INT, @Upperboard_ID INT
AS
BEGIN
    IF EXISTS (SELECT 1 FROM Document d JOIN Unpaid_Leave ul ON d.unpaid_ID = ul.request_ID WHERE ul.request_ID = @request_ID AND d.status = 'valid')
        UPDATE Employee_Approve_Leave SET status = 'approved' WHERE Leave_ID = @request_ID AND Emp1_ID = @Upperboard_ID;
    ELSE BEGIN UPDATE Employee_Approve_Leave SET status = 'rejected' WHERE Leave_ID = @request_ID AND Emp1_ID = @Upperboard_ID; UPDATE Leave SET final_approval_status = 'rejected' WHERE request_ID = @request_ID; END
END;
GO

CREATE PROCEDURE Submit_compensation @employee_ID INT, @compensation_date DATE, @reason VARCHAR(50), @date_of_original_workday DATE, @replacement_emp INT
AS
BEGIN
    INSERT INTO Leave (date_of_request, start_date, end_date) VALUES (GETDATE(), @compensation_date, @compensation_date); 
    DECLARE @req_ID INT = SCOPE_IDENTITY();
    INSERT INTO Compensation_Leave (request_ID, reason, date_of_original_workday, emp_ID, replacement_emp) VALUES (@req_ID, @reason, @date_of_original_workday, @employee_ID, @replacement_emp);
END;
GO

CREATE PROCEDURE Dean_andHR_Evaluation @employee_ID INT, @rating INT, @comment VARCHAR(50), @semester CHAR(3)
AS
BEGIN
    INSERT INTO Performance (rating, comments, semester, emp_ID) VALUES (@rating, @comment, @semester, @employee_ID);
END;
GO