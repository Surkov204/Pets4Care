USE SHOP_PET_Database
GO

-- =====================================================
-- Migration Script: Add doctor_id and remove Employee columns
-- This script modifies existing tables to use doctor_id
-- instead of EmployeeType and EmployeeID
-- =====================================================

PRINT 'Starting migration: Adding doctor_id and removing Employee columns...'
GO

-- =====================================================
-- Step 1: Drop old views
-- =====================================================
PRINT 'Step 1: Dropping old views...'

IF OBJECT_ID('dbo.v_DoctorPayrollRecords', 'V') IS NOT NULL
BEGIN
    DROP VIEW dbo.v_DoctorPayrollRecords;
    PRINT 'Dropped view: v_DoctorPayrollRecords';
END

IF OBJECT_ID('dbo.v_PayrollRecords', 'V') IS NOT NULL
BEGIN
    DROP VIEW dbo.v_PayrollRecords;
    PRINT 'Dropped view: v_PayrollRecords';
END

IF OBJECT_ID('dbo.v_DoctorAttendanceRecords', 'V') IS NOT NULL
BEGIN
    DROP VIEW dbo.v_DoctorAttendanceRecords;
    PRINT 'Dropped view: v_DoctorAttendanceRecords';
END

IF OBJECT_ID('dbo.v_AttendanceRecords', 'V') IS NOT NULL
BEGIN
    DROP VIEW dbo.v_AttendanceRecords;
    PRINT 'Dropped view: v_AttendanceRecords';
END

IF OBJECT_ID('dbo.v_DoctorSalary', 'V') IS NOT NULL
BEGIN
    DROP VIEW dbo.v_DoctorSalary;
    PRINT 'Dropped view: v_DoctorSalary';
END

IF OBJECT_ID('dbo.v_StaffSalary', 'V') IS NOT NULL
BEGIN
    DROP VIEW dbo.v_StaffSalary;
    PRINT 'Dropped view: v_StaffSalary';
END
GO

-- =====================================================
-- Step 2: Drop old indexes
-- =====================================================
PRINT 'Step 2: Dropping old indexes...'

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_AttendanceRecords_Type_ID')
BEGIN
    DROP INDEX IX_AttendanceRecords_Type_ID ON dbo.AttendanceRecords;
    PRINT 'Dropped index: IX_AttendanceRecords_Type_ID';
END

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_PayrollRecords_Type_ID')
BEGIN
    DROP INDEX IX_PayrollRecords_Type_ID ON dbo.PayrollRecords;
    PRINT 'Dropped index: IX_PayrollRecords_Type_ID';
END

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_StaffSalary_Type_ID')
BEGIN
    DROP INDEX IX_StaffSalary_Type_ID ON dbo.StaffSalary;
    PRINT 'Dropped index: IX_StaffSalary_Type_ID';
END
GO

-- =====================================================
-- Step 3: Drop old constraints
-- =====================================================
PRINT 'Step 3: Dropping old constraints...'

-- Drop check constraints
IF EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_EmployeeAttendanceRecords_EmployeeID')
BEGIN
    ALTER TABLE dbo.AttendanceRecords DROP CONSTRAINT CK_EmployeeAttendanceRecords_EmployeeID;
    PRINT 'Dropped constraint: CK_EmployeeAttendanceRecords_EmployeeID';
END

IF EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_EmployeeAttendanceRecords_Type')
BEGIN
    ALTER TABLE dbo.AttendanceRecords DROP CONSTRAINT CK_EmployeeAttendanceRecords_Type;
    PRINT 'Dropped constraint: CK_EmployeeAttendanceRecords_Type';
END

IF EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_EmployeePayrollRecords_EmployeeID')
BEGIN
    ALTER TABLE dbo.PayrollRecords DROP CONSTRAINT CK_EmployeePayrollRecords_EmployeeID;
    PRINT 'Dropped constraint: CK_EmployeePayrollRecords_EmployeeID';
END

IF EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_EmployeePayrollRecords_Type')
BEGIN
    ALTER TABLE dbo.PayrollRecords DROP CONSTRAINT CK_EmployeePayrollRecords_Type;
    PRINT 'Dropped constraint: CK_EmployeePayrollRecords_Type';
END

IF EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_EmployeeSalary_EmployeeID')
BEGIN
    ALTER TABLE dbo.StaffSalary DROP CONSTRAINT CK_EmployeeSalary_EmployeeID;
    PRINT 'Dropped constraint: CK_EmployeeSalary_EmployeeID';
END

IF EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_EmployeeSalary_Type')
BEGIN
    ALTER TABLE dbo.StaffSalary DROP CONSTRAINT CK_EmployeeSalary_Type;
    PRINT 'Dropped constraint: CK_EmployeeSalary_Type';
END
GO

-- =====================================================
-- Step 4: Add doctor_id column to tables
-- =====================================================
PRINT 'Step 4: Adding doctor_id column to tables...'

-- Add doctor_id to AttendanceRecords
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.AttendanceRecords') AND name = 'doctor_id')
BEGIN
    ALTER TABLE dbo.AttendanceRecords ADD doctor_id INT NULL;
    PRINT 'Added column: AttendanceRecords.doctor_id';
END
ELSE
BEGIN
    PRINT 'Column AttendanceRecords.doctor_id already exists';
END

-- Add doctor_id to PayrollRecords
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.PayrollRecords') AND name = 'doctor_id')
BEGIN
    ALTER TABLE dbo.PayrollRecords ADD doctor_id INT NULL;
    PRINT 'Added column: PayrollRecords.doctor_id';
END
ELSE
BEGIN
    PRINT 'Column PayrollRecords.doctor_id already exists';
END

-- Add doctor_id to StaffSalary
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.StaffSalary') AND name = 'doctor_id')
BEGIN
    ALTER TABLE dbo.StaffSalary ADD doctor_id INT NULL;
    PRINT 'Added column: StaffSalary.doctor_id';
END
ELSE
BEGIN
    PRINT 'Column StaffSalary.doctor_id already exists';
END
GO

-- =====================================================
-- Step 5: Migrate data from EmployeeID to doctor_id
-- Only for records where EmployeeType = 'DOCTOR'
-- =====================================================
PRINT 'Step 5: Migrating data from EmployeeID to doctor_id...'

-- Migrate AttendanceRecords
IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.AttendanceRecords') AND name = 'EmployeeID')
BEGIN
    UPDATE dbo.AttendanceRecords
    SET doctor_id = EmployeeID
    WHERE EmployeeType = 'DOCTOR' AND doctor_id IS NULL;
    
    DECLARE @attendance_count INT = @@ROWCOUNT;
    PRINT 'Migrated ' + CAST(@attendance_count AS NVARCHAR) + ' records from AttendanceRecords';
END

-- Migrate PayrollRecords
IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.PayrollRecords') AND name = 'EmployeeID')
BEGIN
    UPDATE dbo.PayrollRecords
    SET doctor_id = EmployeeID
    WHERE EmployeeType = 'DOCTOR' AND doctor_id IS NULL;
    
    DECLARE @payroll_count INT = @@ROWCOUNT;
    PRINT 'Migrated ' + CAST(@payroll_count AS NVARCHAR) + ' records from PayrollRecords';
END

-- Migrate StaffSalary
IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.StaffSalary') AND name = 'EmployeeID')
BEGIN
    UPDATE dbo.StaffSalary
    SET doctor_id = EmployeeID
    WHERE EmployeeType = 'DOCTOR' AND doctor_id IS NULL;
    
    DECLARE @salary_count INT = @@ROWCOUNT;
    PRINT 'Migrated ' + CAST(@salary_count AS NVARCHAR) + ' records from StaffSalary';
END
GO

-- =====================================================
-- Step 6: Delete records that are not for doctors
-- (Optional: Only if you want to keep only doctor records)
-- =====================================================
PRINT 'Step 6: Cleaning up non-doctor records...'

-- Delete non-doctor records from AttendanceRecords
IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.AttendanceRecords') AND name = 'EmployeeType')
BEGIN
    DELETE FROM dbo.AttendanceRecords WHERE EmployeeType != 'DOCTOR' OR doctor_id IS NULL;
    DECLARE @deleted_attendance INT = @@ROWCOUNT;
    PRINT 'Deleted ' + CAST(@deleted_attendance AS NVARCHAR) + ' non-doctor records from AttendanceRecords';
END

-- Delete non-doctor records from PayrollRecords
IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.PayrollRecords') AND name = 'EmployeeType')
BEGIN
    DELETE FROM dbo.PayrollRecords WHERE EmployeeType != 'DOCTOR' OR doctor_id IS NULL;
    DECLARE @deleted_payroll INT = @@ROWCOUNT;
    PRINT 'Deleted ' + CAST(@deleted_payroll AS NVARCHAR) + ' non-doctor records from PayrollRecords';
END

-- Delete non-doctor records from StaffSalary
IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.StaffSalary') AND name = 'EmployeeType')
BEGIN
    DELETE FROM dbo.StaffSalary WHERE EmployeeType != 'DOCTOR' OR doctor_id IS NULL;
    DECLARE @deleted_salary INT = @@ROWCOUNT;
    PRINT 'Deleted ' + CAST(@deleted_salary AS NVARCHAR) + ' non-doctor records from StaffSalary';
END
GO

-- =====================================================
-- Step 7: Make doctor_id NOT NULL and add foreign keys
-- =====================================================
PRINT 'Step 7: Setting doctor_id as NOT NULL and adding foreign keys...'

-- Update AttendanceRecords
IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.AttendanceRecords') AND name = 'doctor_id' AND is_nullable = 1)
BEGIN
    -- Check if there are any NULL values
    IF EXISTS (SELECT 1 FROM dbo.AttendanceRecords WHERE doctor_id IS NULL)
    BEGIN
        PRINT 'WARNING: There are NULL doctor_id values in AttendanceRecords. Please fix them before making the column NOT NULL.';
    END
    ELSE
    BEGIN
        ALTER TABLE dbo.AttendanceRecords ALTER COLUMN doctor_id INT NOT NULL;
        PRINT 'Set AttendanceRecords.doctor_id as NOT NULL';
        
        -- Add foreign key
        IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_AttendanceRecords_Doctor')
        BEGIN
            ALTER TABLE dbo.AttendanceRecords
            ADD CONSTRAINT FK_AttendanceRecords_Doctor FOREIGN KEY (doctor_id)
            REFERENCES dbo.Doctor(doctor_id) ON DELETE CASCADE;
            PRINT 'Added foreign key: FK_AttendanceRecords_Doctor';
        END
    END
END

-- Update PayrollRecords
IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.PayrollRecords') AND name = 'doctor_id' AND is_nullable = 1)
BEGIN
    IF EXISTS (SELECT 1 FROM dbo.PayrollRecords WHERE doctor_id IS NULL)
    BEGIN
        PRINT 'WARNING: There are NULL doctor_id values in PayrollRecords. Please fix them before making the column NOT NULL.';
    END
    ELSE
    BEGIN
        ALTER TABLE dbo.PayrollRecords ALTER COLUMN doctor_id INT NOT NULL;
        PRINT 'Set PayrollRecords.doctor_id as NOT NULL';
        
        -- Add foreign key
        IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_PayrollRecords_Doctor')
        BEGIN
            ALTER TABLE dbo.PayrollRecords
            ADD CONSTRAINT FK_PayrollRecords_Doctor FOREIGN KEY (doctor_id)
            REFERENCES dbo.Doctor(doctor_id) ON DELETE CASCADE;
            PRINT 'Added foreign key: FK_PayrollRecords_Doctor';
        END
    END
END

-- Update StaffSalary
IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.StaffSalary') AND name = 'doctor_id' AND is_nullable = 1)
BEGIN
    IF EXISTS (SELECT 1 FROM dbo.StaffSalary WHERE doctor_id IS NULL)
    BEGIN
        PRINT 'WARNING: There are NULL doctor_id values in StaffSalary. Please fix them before making the column NOT NULL.';
    END
    ELSE
    BEGIN
        ALTER TABLE dbo.StaffSalary ALTER COLUMN doctor_id INT NOT NULL;
        PRINT 'Set StaffSalary.doctor_id as NOT NULL';
        
        -- Add unique constraint if not exists
        IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UQ_StaffSalary_DoctorID')
        BEGIN
            CREATE UNIQUE NONCLUSTERED INDEX UQ_StaffSalary_DoctorID ON dbo.StaffSalary(doctor_id);
            PRINT 'Added unique index: UQ_StaffSalary_DoctorID';
        END
        
        -- Add foreign key
        IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_StaffSalary_Doctor')
        BEGIN
            ALTER TABLE dbo.StaffSalary
            ADD CONSTRAINT FK_StaffSalary_Doctor FOREIGN KEY (doctor_id)
            REFERENCES dbo.Doctor(doctor_id) ON DELETE CASCADE;
            PRINT 'Added foreign key: FK_StaffSalary_Doctor';
        END
    END
END
GO

-- =====================================================
-- Step 8: Drop EmployeeType and EmployeeID columns
-- =====================================================
PRINT 'Step 8: Dropping EmployeeType and EmployeeID columns...'

-- Drop from AttendanceRecords
IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.AttendanceRecords') AND name = 'EmployeeType')
BEGIN
    ALTER TABLE dbo.AttendanceRecords DROP COLUMN EmployeeType;
    PRINT 'Dropped column: AttendanceRecords.EmployeeType';
END

IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.AttendanceRecords') AND name = 'EmployeeID')
BEGIN
    ALTER TABLE dbo.AttendanceRecords DROP COLUMN EmployeeID;
    PRINT 'Dropped column: AttendanceRecords.EmployeeID';
END

-- Drop from PayrollRecords
IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.PayrollRecords') AND name = 'EmployeeType')
BEGIN
    ALTER TABLE dbo.PayrollRecords DROP COLUMN EmployeeType;
    PRINT 'Dropped column: PayrollRecords.EmployeeType';
END

IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.PayrollRecords') AND name = 'EmployeeID')
BEGIN
    ALTER TABLE dbo.PayrollRecords DROP COLUMN EmployeeID;
    PRINT 'Dropped column: PayrollRecords.EmployeeID';
END

-- Drop from StaffSalary
IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.StaffSalary') AND name = 'EmployeeType')
BEGIN
    ALTER TABLE dbo.StaffSalary DROP COLUMN EmployeeType;
    PRINT 'Dropped column: StaffSalary.EmployeeType';
END

IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.StaffSalary') AND name = 'EmployeeID')
BEGIN
    ALTER TABLE dbo.StaffSalary DROP COLUMN EmployeeID;
    PRINT 'Dropped column: StaffSalary.EmployeeID';
END
GO

-- =====================================================
-- Step 9: Create new indexes
-- =====================================================
PRINT 'Step 9: Creating new indexes...'

-- Index for AttendanceRecords
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_AttendanceRecords_DoctorID')
BEGIN
    CREATE NONCLUSTERED INDEX IX_AttendanceRecords_DoctorID ON dbo.AttendanceRecords
    (
        doctor_id ASC,
        CheckIn ASC
    );
    PRINT 'Created index: IX_AttendanceRecords_DoctorID';
END

-- Index for PayrollRecords
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_PayrollRecords_DoctorID')
BEGIN
    CREATE NONCLUSTERED INDEX IX_PayrollRecords_DoctorID ON dbo.PayrollRecords
    (
        doctor_id ASC,
        PeriodStart ASC,
        PeriodEnd ASC
    );
    PRINT 'Created index: IX_PayrollRecords_DoctorID';
END

-- Index for StaffSalary
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_StaffSalary_DoctorID')
BEGIN
    CREATE NONCLUSTERED INDEX IX_StaffSalary_DoctorID ON dbo.StaffSalary
    (
        doctor_id ASC
    );
    PRINT 'Created index: IX_StaffSalary_DoctorID';
END
GO

-- =====================================================
-- Step 10: Add new check constraints
-- =====================================================
PRINT 'Step 10: Adding new check constraints...'

-- Check constraint for AttendanceRecords.doctor_id
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_AttendanceRecords_DoctorID')
BEGIN
    ALTER TABLE dbo.AttendanceRecords
    ADD CONSTRAINT CK_AttendanceRecords_DoctorID CHECK (doctor_id > 0);
    PRINT 'Added constraint: CK_AttendanceRecords_DoctorID';
END

-- Check constraint for PayrollRecords.doctor_id
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_PayrollRecords_DoctorID')
BEGIN
    ALTER TABLE dbo.PayrollRecords
    ADD CONSTRAINT CK_PayrollRecords_DoctorID CHECK (doctor_id > 0);
    PRINT 'Added constraint: CK_PayrollRecords_DoctorID';
END

-- Check constraint for StaffSalary.doctor_id
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_StaffSalary_DoctorID')
BEGIN
    ALTER TABLE dbo.StaffSalary
    ADD CONSTRAINT CK_StaffSalary_DoctorID CHECK (doctor_id > 0);
    PRINT 'Added constraint: CK_StaffSalary_DoctorID';
END
GO

-- =====================================================
-- Step 11: Update stored procedures
-- =====================================================
PRINT 'Step 11: Updating stored procedures...'

-- Update DoctorCheckIn
IF OBJECT_ID('dbo.DoctorCheckIn', 'P') IS NOT NULL
BEGIN
    EXEC('
    CREATE OR ALTER PROCEDURE [dbo].[DoctorCheckIn]
        @p_doctor_id INT
    AS
    BEGIN
        SET NOCOUNT ON;

        -- Check if already checked in today
        IF EXISTS (
            SELECT 1 FROM AttendanceRecords
            WHERE doctor_id = @p_doctor_id
              AND CAST(CheckIn AS DATE) = CAST(GETDATE() AS DATE)
        )
        BEGIN
            PRINT N''Doctor has already checked in today.'';
            RETURN;
        END;

        INSERT INTO AttendanceRecords (doctor_id, CheckIn, CreatedAt)
        VALUES (@p_doctor_id, GETDATE(), GETDATE());

        PRINT N''Check-in successful at '' + CONVERT(NVARCHAR, GETDATE(), 120);
    END;
    ');
    PRINT 'Updated stored procedure: DoctorCheckIn';
END

-- Update DoctorCheckOut
IF OBJECT_ID('dbo.DoctorCheckOut', 'P') IS NOT NULL
BEGIN
    EXEC('
    CREATE OR ALTER PROCEDURE [dbo].[DoctorCheckOut]
        @p_doctor_id INT
    AS
    BEGIN
        SET NOCOUNT ON;

        DECLARE @checkin DATETIME;

        -- Get the most recent shift that hasn''t been checked out
        SELECT TOP 1 @checkin = CheckIn
        FROM AttendanceRecords
        WHERE doctor_id = @p_doctor_id AND CheckOut IS NULL
        ORDER BY CheckIn DESC;

        IF @checkin IS NULL
        BEGIN
            PRINT N''Doctor has not checked in or has already checked out.'';
            RETURN;
        END;

        -- Update checkout time and total hours
        UPDATE AttendanceRecords
        SET CheckOut = GETDATE(),
            TotalHours = ROUND(DATEDIFF(MINUTE, @checkin, GETDATE()) / 60.0, 2),
            Status = N''Completed''
        WHERE doctor_id = @p_doctor_id AND CheckOut IS NULL;

        PRINT N''Check-out successful at '' + CONVERT(NVARCHAR, GETDATE(), 120);
    END;
    ');
    PRINT 'Updated stored procedure: DoctorCheckOut';
END

-- Update GenerateDoctorPayroll
IF OBJECT_ID('dbo.GenerateDoctorPayroll', 'P') IS NOT NULL
BEGIN
    EXEC('
    CREATE OR ALTER PROCEDURE [dbo].[GenerateDoctorPayroll]
        @p_doctor_id INT,
        @p_start DATE,
        @p_end DATE
    AS
    BEGIN
        SET NOCOUNT ON;

        DECLARE 
            @total_hours FLOAT = 0,
            @rate DECIMAL(10,2) = 25000, -- Default hourly rate for doctor
            @salary DECIMAL(12,2) = 0;

        -- Calculate total working hours
        SELECT @total_hours = ISNULL(SUM(TotalHours), 0)
        FROM AttendanceRecords
        WHERE doctor_id = @p_doctor_id
          AND CheckIn >= @p_start
          AND CheckIn <= DATEADD(DAY, 1, @p_end);

        -- Get specific hourly rate if available
        SELECT @rate = ISNULL(HourlyRate, @rate)
        FROM StaffSalary
        WHERE doctor_id = @p_doctor_id;

        SET @salary = ROUND(@total_hours * @rate, 2);

        -- Check if record for this month already exists
        IF EXISTS (
            SELECT 1 FROM PayrollRecords
            WHERE doctor_id = @p_doctor_id
              AND MONTH(PeriodStart) = MONTH(@p_start)
              AND YEAR(PeriodStart) = YEAR(@p_start)
        )
        BEGIN
            UPDATE PayrollRecords
            SET TotalHours = @total_hours,
                HourlyRate = @rate,
                TotalSalary = @salary,
                PeriodStart = @p_start,
                PeriodEnd = @p_end,
                CreatedAt = GETDATE()
            WHERE doctor_id = @p_doctor_id
              AND MONTH(PeriodStart) = MONTH(@p_start)
              AND YEAR(PeriodStart) = YEAR(@p_start);

            PRINT N''Updated payroll record for current month for doctor '' + CAST(@p_doctor_id AS NVARCHAR);
        END
        ELSE
        BEGIN
            INSERT INTO PayrollRecords (doctor_id, PeriodStart, PeriodEnd, TotalHours, HourlyRate, TotalSalary, CreatedAt)
            VALUES (@p_doctor_id, @p_start, @p_end, @total_hours, @rate, @salary, GETDATE());

            PRINT N''Created new payroll record for doctor '' + CAST(@p_doctor_id AS NVARCHAR);
        END
    END;
    ');
    PRINT 'Updated stored procedure: GenerateDoctorPayroll';
END
GO

PRINT 'Migration completed successfully!'
PRINT 'Please verify the changes and test the stored procedures.'
GO



