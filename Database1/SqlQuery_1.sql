-- =======================================================================================
-- University HR Management System - Team 64
-- Milestone 2
-- =======================================================================================

-- 2.1.a Create Database
CREATE DATABASE University_HR_ManagementSystem_Team_64;
GO

USE University_HR_ManagementSystem_Team_64;
GO

-- =======================================================================================
-- 2.1.b Create All Tables Procedure
-- =======================================================================================
CREATE PROC createAllTables
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
    -- num_days is a computed column: end_date - start_date + 1
    CREATE TABLE Leave (
        request_ID INT IDENTITY(1,1) PRIMARY KEY, 
        date_of_request DATE,
        start_date DATE,
        end_date DATE,
        num_days AS (DATEDIFF(day, start_date, end_date) + 1), 
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
        unpaid_ID INT FOREIGN KEY REFERENCES Unpaid_Leave(request_ID),
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
    -- total_duration is a computed column: check_out_time - check_in_time
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
        ), 
        status VARCHAR(50) DEFAULT 'absent' CHECK (status IN ('absent', 'attended')),
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
        Table_ID INT IDENTITY(1,1) PRIMARY KEY, 
        Emp1_ID INT FOREIGN KEY REFERENCES Employee(employee_ID),
        Emp2_ID INT FOREIGN KEY REFERENCES Employee(employee_ID),
        from_date DATE,
        to_date DATE
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

-- EXECUTE IMMEDIATELY to create table structure for following procedures/views
EXEC createAllTables;
GO

-- =======================================================================================
-- 2.1.c Drop All Tables Procedure
-- =======================================================================================
CREATE PROC dropAllTables
AS
BEGIN
    DROP TABLE Employee_Approve_Leave;
    DROP TABLE Employee_Replace_Employee;
    DROP TABLE Performance;
    DROP TABLE Deduction;
    DROP TABLE Attendance;
    DROP TABLE Payroll;
    DROP TABLE Document;
    DROP TABLE Compensation_Leave;
    DROP TABLE Unpaid_Leave;
    DROP TABLE Medical_Leave;
    DROP TABLE Accidental_Leave;
    DROP TABLE Annual_Leave;
    DROP TABLE Leave;
    DROP TABLE Role_existsIn_Department;
    DROP TABLE Employee_Role;
    DROP TABLE Role;
    DROP TABLE Employee_Phone;
    DROP TABLE Employee;
    DROP TABLE Department;
    IF OBJECT_ID('Holiday', 'U') IS NOT NULL DROP TABLE Holiday;
END;
GO

-- =======================================================================================
-- 2.1.d Drop All Procedures, Functions, Views Procedure
-- =======================================================================================
CREATE PROC dropAllProceduresFunctionsViews
AS
BEGIN
    DECLARE @sql NVARCHAR(MAX) = '';
    
    SELECT @sql = @sql + 'DROP PROCEDURE ' + QUOTENAME(name) + ';'
    FROM sys.procedures 
    WHERE type = 'P'
      AND is_ms_shipped = 0
      AND name != 'dropAllProceduresFunctionsViews';
    
    SELECT @sql = @sql + 'DROP FUNCTION ' + QUOTENAME(name) + ';'
    FROM sys.objects
    WHERE type IN ('FN', 'IF', 'TF')
      AND is_ms_shipped = 0;
    
    SELECT @sql = @sql + 'DROP VIEW ' + QUOTENAME(name) + ';'
    FROM sys.views
    WHERE is_ms_shipped = 0;
    
    IF @sql != ''
        EXEC sp_executesql @sql;
END;
GO

-- =======================================================================================
-- 2.1.e Clear All Tables Procedure
-- =======================================================================================
CREATE PROC clearAllTables
AS
BEGIN
    EXEC sp_MSforeachtable 'ALTER TABLE ? NOCHECK CONSTRAINT ALL';
    EXEC sp_MSforeachtable 'DELETE FROM ?';
    EXEC sp_MSforeachtable 'ALTER TABLE ? WITH CHECK CHECK CONSTRAINT ALL';
    EXEC sp_MSforeachtable 'IF OBJECTPROPERTY(object_id(''?''), ''TableHasIdentity'') = 1 DBCC CHECKIDENT (''?'', RESEED, 0)';
END;
GO

-- =======================================================================================
-- 2.2 Views
-- =======================================================================================

-- 2.2 a)
CREATE VIEW allEmployeeProfiles AS
SELECT employee_ID, first_name, last_name, gender, email, address, years_of_experience, official_day_off, type_of_contract, employment_status, annual_balance, accidental_balance 
FROM Employee;
GO

-- 2.2 b)
CREATE VIEW NoEmployeeDept AS
SELECT D.name AS department_name, COUNT(E.employee_ID) AS number_of_employees 
FROM Employee E 
RIGHT OUTER JOIN Department D ON E.dept_name = D.name 
GROUP BY D.name;
GO

-- 2.2 c)
CREATE VIEW allPerformance AS
SELECT P.performance_ID, P.rating, P.comments, P.semester, E.employee_ID, E.first_name, E.last_name, E.dept_name 
FROM Performance P 
INNER JOIN Employee E ON P.emp_ID = E.employee_ID 
WHERE P.semester LIKE 'W%';
GO

-- 2.2 d)
CREATE VIEW allRejectedMedicals AS
SELECT ML.request_ID, ML.type, ML.insurance_status, ML.disability_details, L.start_date, L.end_date, L.num_days, L.date_of_request, E.employee_ID, E.first_name, E.last_name, E.dept_name 
FROM Medical_Leave ML 
INNER JOIN Leave L ON ML.request_ID = L.request_ID 
INNER JOIN Employee E ON ML.Emp_ID = E.employee_ID 
WHERE L.final_approval_status = 'rejected';
GO

-- 2.2 e)
CREATE VIEW allEmployeeAttendance AS
SELECT A.attendance_ID, A.date, A.check_in_time, A.check_out_time, A.total_duration, A.status, E.employee_ID, E.first_name, E.last_name, E.dept_name, E.type_of_contract 
FROM Attendance A 
INNER JOIN Employee E ON A.emp_ID = E.employee_ID 
WHERE A.date = DATEADD(day, -1, CAST(GETDATE() AS DATE));
GO

-- =======================================================================================
-- 2.5 f) Function Is_On_Leave (Needed for 2.3.c)
-- =======================================================================================
CREATE FUNCTION Is_On_Leave 
    (@employee_ID INT, @from_date DATE, @to_date DATE) 
RETURNS BIT
AS
BEGIN
    DECLARE @IsOnLeave BIT = 0;
    
    IF EXISTS (
        SELECT 1 
        FROM Leave l 
        LEFT OUTER JOIN Annual_Leave al ON l.request_ID = al.request_ID 
        LEFT OUTER JOIN Accidental_Leave acl ON l.request_ID = acl.request_ID 
        LEFT OUTER JOIN Medical_Leave ml ON l.request_ID = ml.request_ID 
        LEFT OUTER JOIN Unpaid_Leave ul ON l.request_ID = ul.request_ID 
        LEFT OUTER JOIN Compensation_Leave cl ON l.request_ID = cl.request_ID 
        WHERE l.final_approval_status IN ('approved', 'pending') 
          AND l.start_date <= @to_date 
          AND l.end_date >= @from_date 
          AND (al.emp_ID = @employee_ID OR acl.emp_ID = @employee_ID OR ml.Emp_ID = @employee_ID OR ul.Emp_ID = @employee_ID OR cl.emp_ID = @employee_ID)
    )
    BEGIN
        SET @IsOnLeave = 1;
    END
    
    RETURN @IsOnLeave;
END;
GO

-- =======================================================================================
-- 2.3 Admin Procedures
-- =======================================================================================

-- 2.3 a)
CREATE PROC Update_Status_Doc
AS
BEGIN
    UPDATE Document 
    SET status = 'expired' 
    WHERE expiry_date < CAST(GETDATE() AS DATE) 
    AND status = 'valid';
END;
GO

-- 2.3 b)
CREATE PROC Remove_Deductions
AS
BEGIN
    DELETE FROM Deduction 
    WHERE emp_ID IN (
        SELECT employee_ID 
        FROM Employee 
        WHERE employment_status = 'resigned'
    );
END;
GO

-- 2.3 c)
CREATE PROC Update_Employment_Status
    @Employee_ID INT
AS
BEGIN
    DECLARE @IsOnLeave BIT;
    SET @IsOnLeave = dbo.Is_On_Leave(@Employee_ID, CAST(GETDATE() AS DATE), CAST(GETDATE() AS DATE));
    
    IF @IsOnLeave = 1
    BEGIN
        UPDATE Employee 
        SET employment_status = 'onleave' 
        WHERE employee_ID = @Employee_ID;
    END
    ELSE
    BEGIN
        UPDATE Employee 
        SET employment_status = 'active' 
        WHERE employee_ID = @Employee_ID 
        AND employment_status = 'onleave';
    END
END;
GO

-- 2.3 d)
CREATE PROC Create_Holiday
AS
BEGIN
    CREATE TABLE Holiday (
        holiday_id INT IDENTITY(1,1) PRIMARY KEY,
        name VARCHAR(50),
        from_date DATE,
        to_date DATE
    );
END;
GO

-- 2.3 e)
CREATE PROC Add_Holiday
    @holiday_name VARCHAR(50),
    @from_date DATE,
    @to_date DATE
AS
BEGIN
    INSERT INTO Holiday (name, from_date, to_date)
    VALUES (@holiday_name, @from_date, @to_date);
END;
GO

-- 2.3 f) (Name matches PDF typo "Intitiate")
CREATE PROC Intitiate_Attendance
AS
BEGIN
    INSERT INTO Attendance (date, check_in_time, check_out_time, status, emp_ID)
    SELECT 
        CAST(GETDATE() AS DATE),
        NULL,
        NULL,
        'Absent',
        employee_ID
    FROM Employee 
    WHERE employment_status = 'active';
END;
GO

-- 2.3 g)
CREATE PROC Update_Attendance
    @Employee_id INT,
    @check_in_time TIME,
    @check_out_time TIME
AS
BEGIN
    DECLARE @total_duration INT;
    DECLARE @status VARCHAR(50);
    
    SET @total_duration = DATEDIFF(HOUR, @check_in_time, @check_out_time);
    
    IF @total_duration > 0
        SET @status = 'attended';
    ELSE
        SET @status = 'Absent';
    
    UPDATE Attendance 
    SET 
        check_in_time = @check_in_time,
        check_out_time = @check_out_time,
        status = @status
    WHERE emp_ID = @Employee_id 
    AND date = CAST(GETDATE() AS DATE);
END;
GO

-- 2.3 h)
CREATE PROC Remove_Holiday
AS
BEGIN
    IF OBJECT_ID('Holiday', 'U') IS NOT NULL
    BEGIN
        DELETE FROM Attendance
        WHERE date IN (
            SELECT DISTINCT a.date
            FROM Attendance a
            INNER JOIN Holiday h ON a.date BETWEEN h.from_date AND h.to_date
        );
    END
    ELSE
    BEGIN
        PRINT 'Holiday table does not exist. Please create it first using Create_Holiday procedure.';
    END
END;
GO

-- 2.3 i)
CREATE PROC Remove_DayOff
    @Employee_id INT
AS
BEGIN
    DECLARE @current_date DATE = GETDATE();
    DECLARE @month_start DATE = DATEFROMPARTS(YEAR(@current_date), MONTH(@current_date), 1);
    
    DELETE FROM Attendance
    WHERE emp_ID = @Employee_id
      AND date >= @month_start
      AND date <= @current_date
      AND status = 'absent'
      AND DATENAME(WEEKDAY, date) = (
          SELECT official_day_off 
          FROM Employee 
          WHERE employee_ID = @Employee_id
      );
END;
GO

-- 2.3 j)
CREATE PROC Remove_Approved_Leaves
    @Employee_id INT
AS
BEGIN
    DELETE FROM Attendance
    WHERE emp_ID = @Employee_id
      AND EXISTS (
          SELECT 1 
          FROM Leave l
          WHERE l.final_approval_status = 'approved'
            AND l.start_date <= Attendance.date
            AND l.end_date >= Attendance.date
            AND l.request_ID IN (
                SELECT request_ID FROM Annual_Leave WHERE emp_ID = @Employee_id
                UNION ALL
                SELECT request_ID FROM Accidental_Leave WHERE emp_ID = @Employee_id  
                UNION ALL
                SELECT request_ID FROM Medical_Leave WHERE Emp_ID = @Employee_id
                UNION ALL
                SELECT request_ID FROM Unpaid_Leave WHERE Emp_ID = @Employee_id
                UNION ALL
                SELECT request_ID FROM Compensation_Leave WHERE emp_ID = @Employee_id
            )
      );
END;
GO

-- 2.3 k)
CREATE PROC Replace_employee
    @Emp1_ID INT,
    @Emp2_ID INT, 
    @from_date DATE,
    @to_date DATE
AS
BEGIN
    INSERT INTO Employee_Replace_Employee (Emp1_ID, Emp2_ID, from_date, to_date)
    VALUES (@Emp1_ID, @Emp2_ID, @from_date, @to_date);
END;
GO

-- =======================================================================================
-- 2.4 HR Procedures
-- =======================================================================================

-- 2.4 a)
CREATE FUNCTION HRLoginValidation 
    (@employee_ID INT, @password VARCHAR(50))
RETURNS BIT
AS
BEGIN
    DECLARE @Success BIT = 0;
    IF EXISTS (
        SELECT 1 
        FROM Employee E 
        INNER JOIN Employee_Role ER ON E.employee_ID = ER.emp_ID 
        WHERE E.employee_ID = @employee_ID 
          AND E.password = @password 
          AND (ER.role_name LIKE 'HR_%' OR ER.role_name = 'HR Manager')
    )
        SET @Success = 1;
        
    RETURN @Success;
END;
GO

-- 2.4 b)
CREATE PROC HR_approval_an_acc 
    @request_ID INT, @HR_ID INT
AS
BEGIN
    DECLARE @emp_ID INT, @num_days INT, @annual_bal INT, @accidental_bal INT;
    DECLARE @leave_type VARCHAR(20) = NULL;
    
    SELECT @emp_ID = AL.emp_ID, @num_days = L.num_days, 
           @annual_bal = E.annual_balance, @accidental_bal = E.accidental_balance,
           @leave_type = 'annual'
    FROM Leave L 
    INNER JOIN Annual_Leave AL ON L.request_ID = AL.request_ID 
    INNER JOIN Employee E ON AL.emp_ID = E.employee_ID 
    WHERE L.request_ID = @request_ID;

    IF @emp_ID IS NULL
    BEGIN
        SELECT @emp_ID = ACL.emp_ID, @num_days = L.num_days, 
               @annual_bal = E.annual_balance, @accidental_bal = E.accidental_balance,
               @leave_type = 'accidental'
        FROM Leave L 
        INNER JOIN Accidental_Leave ACL ON L.request_ID = ACL.request_ID 
        INNER JOIN Employee E ON ACL.emp_ID = E.employee_ID 
        WHERE L.request_ID = @request_ID;
    END

    IF @emp_ID IS NULL OR @leave_type IS NULL RETURN;

    IF @leave_type = 'annual'
    BEGIN
        IF @annual_bal >= @num_days AND @num_days >= 0  
        BEGIN
            UPDATE Leave SET final_approval_status = 'approved' WHERE request_ID = @request_ID;
            IF @num_days > 0
                UPDATE Employee SET annual_balance = annual_balance - @num_days WHERE employee_ID = @emp_ID;
        END
        ELSE
        BEGIN
            UPDATE Leave SET final_approval_status = 'rejected' WHERE request_ID = @request_ID;
        END
    END
    ELSE IF @leave_type = 'accidental'
    BEGIN
        IF @accidental_bal >= @num_days AND @num_days >= 0  
        BEGIN
            UPDATE Leave SET final_approval_status = 'approved' WHERE request_ID = @request_ID;
            IF @num_days > 0
                UPDATE Employee SET accidental_balance = accidental_balance - @num_days WHERE employee_ID = @emp_ID;
        END
        ELSE
        BEGIN
            UPDATE Leave SET final_approval_status = 'rejected' WHERE request_ID = @request_ID;
        END
    END
END;
GO

-- 2.4 c)
CREATE PROC HR_approval_unpaid 
    @request_ID INT, @HR_ID INT
AS
BEGIN
    DECLARE @emp_ID INT, @num_days INT, @contract_type VARCHAR(50), @approved_unpaid_count INT;
    SELECT @emp_ID = ul.Emp_ID, @num_days = l.num_days FROM Leave l INNER JOIN Unpaid_Leave ul ON l.request_ID = ul.request_ID WHERE l.request_ID = @request_ID;
    SELECT @contract_type = type_of_contract FROM Employee WHERE employee_ID = @emp_ID;
    SELECT @approved_unpaid_count = COUNT(*) FROM Leave l INNER JOIN Unpaid_Leave ul ON l.request_ID = ul.request_ID WHERE ul.Emp_ID = @emp_ID AND l.final_approval_status = 'approved' AND YEAR(l.start_date) = YEAR(GETDATE());

    IF @contract_type = 'part_time' OR @num_days > 30 OR @approved_unpaid_count > 0
        UPDATE Leave SET final_approval_status = 'rejected' WHERE request_ID = @request_ID;
    ELSE
        UPDATE Leave SET final_approval_status = 'approved' WHERE request_ID = @request_ID;
END;
GO

-- 2.4 d)
CREATE PROC HR_approval_comp 
    @request_ID INT, @HR_ID INT
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

-- 2.4 e)
CREATE PROC Deduction_hours 
    @employee_ID INT
AS
BEGIN
    DECLARE @attendance_id INT;
    DECLARE @current_date DATE = GETDATE();
    DECLARE @month_start DATE = DATEFROMPARTS(YEAR(@current_date), MONTH(@current_date), 1);
    DECLARE @salary DECIMAL(10,2);
    DECLARE @hours_worked DECIMAL(10,2);
    DECLARE @missing_hours DECIMAL(10,2);
    DECLARE @rate_per_hour DECIMAL(10,2);
    DECLARE @deduction_amount DECIMAL(10,2);
    
    SELECT TOP 1 @attendance_id = attendance_ID, @hours_worked = total_duration
    FROM Attendance 
    WHERE emp_ID = @employee_ID 
      AND date >= @month_start 
      AND date <= @current_date 
      AND status = 'attended' 
      AND total_duration < 8 
    ORDER BY date ASC;
    
    IF @attendance_id IS NOT NULL
    BEGIN
        SELECT @salary = salary FROM Employee WHERE employee_ID = @employee_ID;
        SET @missing_hours = 8 - @hours_worked;
        SET @rate_per_hour = (@salary / 22.0) / 8.0;
        SET @deduction_amount = @rate_per_hour * @missing_hours;
        
        INSERT INTO Deduction (emp_ID, date, amount, type, status, attendance_ID) 
        VALUES (@employee_ID, @current_date, @deduction_amount, 'missing_hours', 'pending', @attendance_id);
    END
END;
GO

-- 2.4 f)
CREATE PROC Deduction_days 
    @employee_ID INT
AS
BEGIN
    DECLARE @current_date DATE = GETDATE();
    DECLARE @month_start DATE = DATEFROMPARTS(YEAR(@current_date), MONTH(@current_date), 1);
    DECLARE @salary DECIMAL(10,2);
    DECLARE @deduction_per_day DECIMAL(10,2);
    
    SELECT @salary = salary FROM Employee WHERE employee_ID = @employee_ID;
    
    SET @deduction_per_day = @salary / 22.0;
    
    IF NOT EXISTS (
        SELECT 1 
        FROM Deduction 
        WHERE emp_ID = @employee_ID 
          AND type = 'missing_days' 
          AND MONTH(date) = MONTH(@current_date)
          AND YEAR(date) = YEAR(@current_date)
    )
    BEGIN
        INSERT INTO Deduction (emp_ID, date, amount, type, status, attendance_ID)
        SELECT 
            @employee_ID,
            @current_date,
            @deduction_per_day,
            'missing_days',
            'pending',
            a.attendance_ID
        FROM Attendance a
        WHERE a.emp_ID = @employee_ID
          AND a.date >= @month_start
          AND a.date <= @current_date
          AND a.status = 'absent';
    END
END;
GO

-- 2.4 g)
CREATE PROC Deduction_unpaid 
    @employee_ID INT
AS
BEGIN
    DECLARE @current_date DATE = GETDATE();
    DECLARE @current_month_start DATE = DATEFROMPARTS(YEAR(@current_date), MONTH(@current_date), 1);
    DECLARE @prev_month_start DATE = DATEADD(MONTH, -1, @current_month_start);
    DECLARE @prev_month_end DATE = DATEADD(DAY, -1, @current_month_start);
    
    INSERT INTO Deduction (emp_ID, date, amount, type, status, unpaid_ID)
    SELECT ul.Emp_ID, @prev_month_end, 0, 'unpaid', 'pending', ul.request_ID
    FROM Unpaid_Leave ul 
    INNER JOIN Leave l ON ul.request_ID = l.request_ID
    WHERE ul.Emp_ID = @employee_ID 
      AND l.final_approval_status = 'approved' 
      AND l.start_date <= @prev_month_end 
      AND l.end_date >= @prev_month_start  
      AND NOT EXISTS (
          SELECT 1 FROM Deduction d 
          WHERE d.emp_ID = ul.Emp_ID 
            AND d.type = 'unpaid' 
            AND d.unpaid_ID = ul.request_ID 
            AND MONTH(d.date) = MONTH(@prev_month_start) 
            AND YEAR(d.date) = YEAR(@prev_month_start)
      );
    
    INSERT INTO Deduction (emp_ID, date, amount, type, status, unpaid_ID)
    SELECT ul.Emp_ID, @current_date, 0, 'unpaid', 'pending', ul.request_ID
    FROM Unpaid_Leave ul 
    INNER JOIN Leave l ON ul.request_ID = l.request_ID
    WHERE ul.Emp_ID = @employee_ID 
      AND l.final_approval_status = 'approved' 
      AND l.start_date <= EOMONTH(@current_date)  
      AND l.end_date >= @current_month_start      
      AND NOT EXISTS (
          SELECT 1 FROM Deduction d 
          WHERE d.emp_ID = ul.Emp_ID 
            AND d.type = 'unpaid' 
            AND d.unpaid_ID = ul.request_ID 
            AND MONTH(d.date) = MONTH(@current_date) 
            AND YEAR(d.date) = YEAR(@current_date)
      );
END;
GO

-- 2.4 h)
CREATE FUNCTION Bonus_amount
    (@employee_ID INT) 
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @bonus_amount DECIMAL(10,2) = 0;
    DECLARE @salary DECIMAL(10,2);
    DECLARE @rate_per_hour DECIMAL(10,4); 
    DECLARE @overtime_factor DECIMAL(4,2);
    DECLARE @total_extra_hours INT = 0;
    
    SELECT TOP 1 
        @salary = E.salary, 
        @overtime_factor = R.percentage_overtime
    FROM Employee E
    INNER JOIN Employee_Role ER ON E.employee_ID = ER.emp_ID
    INNER JOIN Role R ON ER.role_name = R.role_name
    WHERE E.employee_ID = @employee_ID
    ORDER BY R.rank ASC; 
    
    SET @rate_per_hour = (@salary / 22.0) / 8.0;
    
    SELECT @total_extra_hours = ISNULL(SUM(total_duration - 8), 0) 
    FROM Attendance 
    WHERE emp_ID = @employee_ID 
      AND total_duration > 8 
      AND MONTH(date) = MONTH(GETDATE()) 
      AND YEAR(date) = YEAR(GETDATE());
      
    SET @bonus_amount = @rate_per_hour * ((@overtime_factor * @total_extra_hours) / 100.0);
    
    RETURN @bonus_amount;
END;
GO

-- 2.4 i)
CREATE PROC Add_Payroll 
    @employee_ID INT, 
    @from_date DATE, 
    @to_date DATE
AS
BEGIN
    DECLARE @salary DECIMAL(10,2);
    DECLARE @bonus_amount DECIMAL(10,2);
    DECLARE @deduction DECIMAL(10,2);
    DECLARE @final_salary DECIMAL(10,2);
    
    SELECT @salary = salary FROM Employee WHERE employee_ID = @employee_ID;
    
    SET @bonus_amount = dbo.Bonus_amount(@employee_ID);
    
    SELECT @deduction = ISNULL(SUM(amount), 0) 
    FROM Deduction 
    WHERE emp_ID = @employee_ID 
      AND status = 'pending' 
      AND date BETWEEN @from_date AND @to_date;
      
    SET @final_salary = @salary + @bonus_amount - @deduction;
    
    INSERT INTO Payroll (payment_date, final_salary_amount, from_date, to_date, comments, bonus_amount, deductions_amount, emp_ID)
    VALUES (GETDATE(), @final_salary, @from_date, @to_date, 'Monthly Payroll', @bonus_amount, @deduction, @employee_ID);
    
    UPDATE Deduction 
    SET status = 'finalized' 
    WHERE emp_ID = @employee_ID 
      AND status = 'pending' 
      AND date BETWEEN @from_date AND @to_date;
END;
GO

-- =======================================================================================
-- 2.5 Employee Procedures
-- =======================================================================================

-- 2.5 a)
CREATE FUNCTION EmployeeLoginValidation 
    (@employee_ID INT, @password VARCHAR(50)) 
RETURNS BIT
AS
BEGIN
    DECLARE @Success BIT = 0;
    IF EXISTS (SELECT 1 FROM Employee E WHERE E.employee_ID = @employee_ID AND E.password = @password) 
        SET @Success = 1;
    RETURN @Success;
END;
GO

-- 2.5 b)
CREATE FUNCTION MyPerformance 
    (@employee_ID INT, @semester CHAR(3)) 
RETURNS TABLE 
AS 
RETURN (
    SELECT * FROM Performance 
    WHERE emp_ID = @employee_ID 
      AND semester = @semester
);
GO

-- 2.5 c)
CREATE FUNCTION MyAttendance 
    (@employee_ID INT) 
RETURNS TABLE 
AS 
RETURN (
    SELECT A.attendance_ID, A.date, A.check_in_time, A.check_out_time, A.total_duration, A.status, A.emp_ID 
    FROM Attendance A 
    INNER JOIN Employee E ON A.emp_ID = E.employee_ID 
    WHERE A.emp_ID = @employee_ID 
      AND MONTH(A.date) = MONTH(GETDATE()) 
      AND YEAR(A.date) = YEAR(GETDATE()) 
      AND NOT (A.status = 'Absent' AND LTRIM(RTRIM(DATENAME(WEEKDAY, A.date))) = LTRIM(RTRIM(E.official_day_off)))
);
GO

-- 2.5 d)
CREATE FUNCTION Last_month_payroll 
    (@employee_ID INT) 
RETURNS TABLE 
AS 
RETURN (
    SELECT TOP 1 * FROM Payroll 
    WHERE emp_ID = @employee_ID 
      AND from_date >= DATEADD(MONTH, -1, DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1)) 
      AND to_date < DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1) 
    ORDER BY payment_date DESC
);
GO

-- 2.5 e)
CREATE FUNCTION Deductions_Attendance 
    (@employee_ID INT, @target_month INT) 
RETURNS TABLE 
AS 
RETURN (
    SELECT D.deduction_ID, D.emp_ID, D.date, D.amount, D.type, D.status, D.unpaid_ID, D.attendance_ID 
    FROM Deduction D 
    WHERE D.emp_ID = @employee_ID 
      AND MONTH(D.date) = @target_month 
      AND YEAR(D.date) = YEAR(GETDATE()) 
      AND D.type IN ('missing_hours', 'missing_days')
);
GO

-- 2.5 g)
CREATE PROC Submit_annual 
    @employee_ID INT, @replacement_emp INT, @start_date DATE, @end_date DATE
AS
BEGIN
    INSERT INTO Leave (date_of_request, start_date, end_date) 
    VALUES (GETDATE(), @start_date, @end_date);
    
    DECLARE @req_ID INT = SCOPE_IDENTITY();
    
    INSERT INTO Annual_Leave (request_ID, emp_ID, replacement_emp) 
    VALUES (@req_ID, @employee_ID, @replacement_emp);
    
    DECLARE @Dean_ID INT, @HR_Rep_ID INT;
    
    SELECT TOP 1 @Dean_ID = E.employee_ID 
    FROM Employee E 
    INNER JOIN Employee_Role ER ON E.employee_ID = ER.emp_ID 
    WHERE E.dept_name = (SELECT dept_name FROM Employee WHERE employee_ID = @employee_ID) 
      AND ER.role_name = 'Dean';
      
    SELECT TOP 1 @HR_Rep_ID = E.employee_ID 
    FROM Employee E 
    INNER JOIN Employee_Role ER ON E.employee_ID = ER.emp_ID 
    WHERE ER.role_name LIKE 'HR_Representative_%'; 
    
    IF @Dean_ID IS NOT NULL 
        INSERT INTO Employee_Approve_Leave (Emp1_ID, Leave_ID, status) VALUES (@Dean_ID, @req_ID, 'pending');
        
    IF @HR_Rep_ID IS NOT NULL 
        INSERT INTO Employee_Approve_Leave (Emp1_ID, Leave_ID, status) VALUES (@HR_Rep_ID, @req_ID, 'pending');
END;
GO

-- 2.5 h)
CREATE FUNCTION Status_leaves 
    (@employee_ID INT) 
RETURNS TABLE 
AS 
RETURN (
    SELECT l.request_ID, l.date_of_request, l.final_approval_status AS status 
    FROM Leave l 
    WHERE MONTH(l.date_of_request) = MONTH(GETDATE()) 
      AND YEAR(l.date_of_request) = YEAR(GETDATE()) 
      AND l.request_ID IN (
          SELECT request_ID FROM Annual_Leave WHERE emp_ID = @employee_ID 
          UNION ALL 
          SELECT request_ID FROM Accidental_Leave WHERE emp_ID = @employee_ID
      )
);
GO

-- 2.5 i)
CREATE PROC Upperboard_approve_annual 
    @request_ID INT, @Upperboard_ID INT, @replacement_ID INT
AS
BEGIN
    DECLARE @emp_dept VARCHAR(50), @rep_dept VARCHAR(50), @rep_on_leave BIT = 0, @start_date DATE, @end_date DATE;
    
    SELECT @start_date = start_date, @end_date = end_date FROM Leave WHERE request_ID = @request_ID;
    
    SELECT @emp_dept = dept_name 
    FROM Employee 
    WHERE employee_ID = (SELECT emp_ID FROM Annual_Leave WHERE request_ID = @request_ID);
    
    SELECT @rep_dept = dept_name 
    FROM Employee 
    WHERE employee_ID = @replacement_ID;
    
    SET @rep_on_leave = dbo.Is_On_Leave(@replacement_ID, @start_date, @end_date);
    
    IF @rep_on_leave = 0 AND @emp_dept = @rep_dept 
    BEGIN
        UPDATE Employee_Approve_Leave SET status = 'approved' WHERE Leave_ID = @request_ID AND Emp1_ID = @Upperboard_ID;
    END
    ELSE 
    BEGIN 
        UPDATE Employee_Approve_Leave SET status = 'rejected' WHERE Leave_ID = @request_ID AND Emp1_ID = @Upperboard_ID; 
        UPDATE Leave SET final_approval_status = 'rejected' WHERE request_ID = @request_ID; 
    END
END;
GO

-- 2.5 j)
CREATE PROC Submit_accidental
    @employee_ID INT,
    @start_date  DATE,
    @end_date    DATE
AS
BEGIN
    IF DATEDIFF(DAY, @start_date, @end_date) <> 0
    BEGIN
        PRINT 'Accidental leave must be 1 day only.';
        RETURN;
    END

    INSERT INTO dbo.Leave (date_of_request, start_date, end_date, final_approval_status)
    VALUES (CAST(GETDATE() AS DATE), @start_date, @end_date,  'pending');

    DECLARE @req_ID INT = SCOPE_IDENTITY();

    INSERT INTO dbo.Accidental_Leave (request_ID, emp_ID)
    VALUES (@req_ID, @employee_ID);

    DECLARE @Dean_ID INT, @HR_Rep_ID INT;

    SELECT TOP 1 @Dean_ID = E.employee_ID
    FROM dbo.Employee E
    INNER JOIN dbo.Employee_Role ER ON E.employee_ID = ER.emp_ID
    WHERE E.dept_name = (SELECT dept_name FROM dbo.Employee WHERE employee_ID = @employee_ID)
      AND ER.role_name = 'Dean';

    SELECT TOP 1 @HR_Rep_ID = E.employee_ID
    FROM dbo.Employee E
    INNER JOIN dbo.Employee_Role ER ON E.employee_ID = ER.emp_ID
    WHERE ER.role_name = 'HR Representative';

    IF @Dean_ID IS NOT NULL
        INSERT INTO dbo.Employee_Approve_Leave (Emp1_ID, Leave_ID, status)
        VALUES (@Dean_ID, @req_ID, 'pending');

    IF @HR_Rep_ID IS NOT NULL
        INSERT INTO dbo.Employee_Approve_Leave (Emp1_ID, Leave_ID, status)
        VALUES (@HR_Rep_ID, @req_ID, 'pending');
END;
GO

-- 2.5 k)
CREATE PROC Submit_medical 
    @employee_ID INT,
    @start_date DATE,
    @end_date DATE,
    @type VARCHAR(50),
    @insurance_status BIT,
    @disability_details VARCHAR(50),
    @document_description VARCHAR(50),
    @file_name VARCHAR(50)
AS
BEGIN
    IF @end_date < @start_date
    BEGIN
        PRINT 'Invalid date range.';
        RETURN;
    END

    INSERT INTO Leave (date_of_request, start_date, end_date)
    VALUES (CAST(GETDATE() AS DATE), @start_date, @end_date);

    DECLARE @req_ID INT = SCOPE_IDENTITY();
    
    INSERT INTO Medical_Leave (request_ID, insurance_status, disability_details, type, Emp_ID) 
    VALUES (@req_ID, @insurance_status, @disability_details, @type, @employee_ID);
    
    INSERT INTO Document (type, description, file_name, creation_date, status, medical_ID)
    VALUES ('Medical', @document_description, @file_name, CAST(GETDATE() AS DATE), 'valid', @req_ID);

    DECLARE @Dean_ID INT, @HR_Rep_ID INT;

    SELECT TOP 1 @Dean_ID = E.employee_ID
    FROM Employee E 
    INNER JOIN Employee_Role ER ON E.employee_ID = ER.emp_ID
    WHERE ER.role_name = 'Dean'
      AND E.dept_name = (SELECT dept_name FROM Employee WHERE employee_ID = @employee_ID);
      
    SELECT TOP 1 @HR_Rep_ID = E.employee_ID
    FROM Employee E 
    INNER JOIN Employee_Role ER ON E.employee_ID = ER.emp_ID
    WHERE ER.role_name = 'HR Representative';

    IF @Dean_ID IS NOT NULL
        INSERT INTO Employee_Approve_Leave (Emp1_ID, Leave_ID, status)
        VALUES (@Dean_ID, @req_ID, 'pending');

    IF @HR_Rep_ID IS NOT NULL
        INSERT INTO Employee_Approve_Leave (Emp1_ID, Leave_ID, status)
        VALUES (@HR_Rep_ID, @req_ID, 'pending');
END;
GO

-- 2.5 l)
CREATE PROC Submit_unpaid 
    @employee_ID INT, 
    @start_date DATE, 
    @end_date DATE, 
    @document_description VARCHAR(50), 
    @file_name VARCHAR(50)
AS
BEGIN
    IF @end_date < @start_date
    BEGIN
        PRINT 'Invalid date range.';
        RETURN;
    END

    INSERT INTO Leave (date_of_request, start_date, end_date)
    VALUES (GETDATE(), @start_date, @end_date);

    DECLARE @req_ID INT = SCOPE_IDENTITY();

    INSERT INTO Unpaid_Leave (request_ID, Emp_ID)
    VALUES (@req_ID, @employee_ID);

    INSERT INTO Document (type, description, file_name, creation_date, status, unpaid_ID)
    VALUES ('Unpaid Memo', @document_description, @file_name, GETDATE(), 'valid', @req_ID);

    DECLARE @dept VARCHAR(50);
    DECLARE @DeanID INT = NULL;
    DECLARE @HRRepID INT = NULL;

    SELECT @dept = dept_name 
    FROM Employee 
    WHERE employee_ID = @employee_ID;

    SELECT TOP 1 @DeanID = E.employee_ID
    FROM Employee E
    INNER JOIN Employee_Role ER ON E.employee_ID = ER.emp_ID
    WHERE E.dept_name = @dept AND ER.role_name = 'Dean';

    SELECT TOP 1 @HRRepID = E.employee_ID
    FROM Employee E
    INNER JOIN Employee_Role ER ON E.employee_ID = ER.emp_ID
    WHERE ER.role_name LIKE 'HR Representative';

    IF @DeanID IS NOT NULL
        INSERT INTO Employee_Approve_Leave (Emp1_ID, Leave_ID, status)
        VALUES (@DeanID, @req_ID, 'pending');

    IF @HRRepID IS NOT NULL
        INSERT INTO Employee_Approve_Leave (Emp1_ID, Leave_ID, status)
        VALUES (@HRRepID, @req_ID, 'pending');
END
GO

-- 2.5 m)
CREATE PROC Upperboard_approve_unpaids 
    @request_ID INT, @Upperboard_ID INT
AS
BEGIN
    IF EXISTS (
        SELECT 1 
        FROM Document d 
        INNER JOIN Unpaid_Leave ul ON d.unpaid_ID = ul.request_ID 
        WHERE ul.request_ID = @request_ID 
          AND d.status = 'valid' 
          AND d.type = 'Memo'
    )
    BEGIN
        UPDATE Employee_Approve_Leave SET status = 'approved' WHERE Leave_ID = @request_ID AND Emp1_ID = @Upperboard_ID;
    END
    ELSE 
    BEGIN 
        UPDATE Employee_Approve_Leave SET status = 'rejected' WHERE Leave_ID = @request_ID AND Emp1_ID = @Upperboard_ID; 
        UPDATE Leave SET final_approval_status = 'rejected' WHERE request_ID = @request_ID; 
    END
END;
GO

-- 2.5 n)
CREATE PROC Submit_compensation 
    @employee_ID INT, 
    @compensation_date DATE, 
    @reason VARCHAR(50), 
    @date_of_original_workday DATE, 
    @replacement_emp INT
AS
BEGIN
    INSERT INTO Leave (date_of_request, start_date, end_date)
    VALUES (GETDATE(), @compensation_date, @compensation_date);

    DECLARE @req_ID INT = SCOPE_IDENTITY();

    INSERT INTO Compensation_Leave (request_ID, reason, date_of_original_workday, emp_ID, replacement_emp)
    VALUES (@req_ID, @reason, @date_of_original_workday, @employee_ID, @replacement_emp);

    DECLARE @dept VARCHAR(50);
    SELECT @dept = dept_name FROM Employee WHERE employee_ID = @employee_ID;

    DECLARE @Dean INT = NULL;
    DECLARE @ViceDean INT = NULL;
    DECLARE @HRRep INT = NULL;

    SELECT TOP 1 @Dean = E.employee_ID
    FROM Employee E 
    INNER JOIN Employee_Role ER ON E.employee_ID = ER.emp_ID
    INNER JOIN Role R ON ER.role_name = R.role_name
    WHERE R.rank = 3 AND E.dept_name = @dept AND R.role_name = 'Dean';
    
    SELECT TOP 1 @ViceDean = E.employee_ID
    FROM Employee E 
    INNER JOIN Employee_Role ER ON E.employee_ID = ER.emp_ID
    INNER JOIN Role R ON ER.role_name = R.role_name
    WHERE R.rank = 4 AND E.dept_name = @dept AND R.role_name = 'Vice Dean';

    SELECT TOP 1 @HRRep = E.employee_ID
    FROM Employee E
    INNER JOIN Employee_Role ER ON E.employee_ID = ER.emp_ID
    WHERE ER.role_name = 'HR Representative';

    IF @Dean IS NOT NULL
        INSERT INTO Employee_Approve_Leave (Emp1_ID, Leave_ID, status)
        VALUES (@Dean, @req_ID, 'pending');

    IF @ViceDean IS NOT NULL
        INSERT INTO Employee_Approve_Leave (Emp1_ID, Leave_ID, status)
        VALUES (@ViceDean, @req_ID, 'pending');

    IF @HRRep IS NOT NULL
        INSERT INTO Employee_Approve_Leave (Emp1_ID, Leave_ID, status)
        VALUES (@HRRep, @req_ID, 'pending');
END;
GO

-- 2.5 o)
CREATE PROC Dean_andHR_Evaluation 
    @employee_ID INT, 
    @rating INT, 
    @comment VARCHAR(50),
    @semester CHAR(3)
AS
BEGIN
    INSERT INTO Performance (rating, comments, semester, emp_ID)
    VALUES (@rating, @comment, @semester, @employee_ID);    
END;
GO