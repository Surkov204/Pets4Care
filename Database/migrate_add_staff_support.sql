-- =============================================
-- Migration Script: Merge Staff and Doctor Support in Attendance, Payroll, and Salary Tables
-- Description: 
--   Ban đầu: Đồng nghiệp 1 tạo bảng cho Staff, Đồng nghiệp 2 tạo bảng riêng cho Doctor
--   Mục tiêu: Gộp lại thành một bộ bảng chung cho cả Staff và Doctor
--   Pattern: Giống WorkSchedule - mỗi record chỉ thuộc Doctor HOẶC Staff (không được cả hai)
-- Date: 2025-11-15
-- =============================================

USE [SHOP_PET_Database]
GO

PRINT 'Starting migration: Merging Staff and Doctor support in Attendance, Payroll, and Salary tables...'
PRINT '  - Previously: Separate tables for Staff and Doctor'
PRINT '  - Now: Unified tables supporting both Staff and Doctor (one or the other, not both)'
PRINT ''

BEGIN TRANSACTION;

BEGIN TRY
    -- =============================================
    -- Step 1: Modify AttendanceRecords table
    -- =============================================
    PRINT 'Step 1: Modifying AttendanceRecords table...'
    
    -- Add staff_id column (nullable)
    ALTER TABLE [dbo].[AttendanceRecords]
    ADD [staff_id] [int] NULL;
    
    PRINT '  Added column: AttendanceRecords.staff_id'
    
    -- Drop existing foreign key and check constraint
    ALTER TABLE [dbo].[AttendanceRecords]
    DROP CONSTRAINT [FK_AttendanceRecords_Doctor];
    
    ALTER TABLE [dbo].[AttendanceRecords]
    DROP CONSTRAINT [CK_AttendanceRecords_DoctorID];
    
    -- Make doctor_id nullable
    ALTER TABLE [dbo].[AttendanceRecords]
    ALTER COLUMN [doctor_id] [int] NULL;
    
    PRINT '  Made doctor_id nullable'
    
    -- Add foreign key for staff_id
    ALTER TABLE [dbo].[AttendanceRecords]
    ADD CONSTRAINT [FK_AttendanceRecords_Staff] FOREIGN KEY([staff_id])
    REFERENCES [dbo].[Staff] ([staff_id])
    ON DELETE CASCADE;
    
    PRINT '  Added foreign key: FK_AttendanceRecords_Staff'
    
    -- Re-add foreign key for doctor_id (now nullable)
    ALTER TABLE [dbo].[AttendanceRecords]
    ADD CONSTRAINT [FK_AttendanceRecords_Doctor] FOREIGN KEY([doctor_id])
    REFERENCES [dbo].[Doctor] ([doctor_id])
    ON DELETE CASCADE;
    
    PRINT '  Re-added foreign key: FK_AttendanceRecords_Doctor'
    
    -- Add check constraint: must have exactly one of doctor_id or staff_id
    -- Use dynamic SQL to ensure column exists before creating constraint
    DECLARE @sql1 NVARCHAR(MAX) = N'
    ALTER TABLE [dbo].[AttendanceRecords]
    ADD CONSTRAINT [CK_AttendanceRecords_OneOwner] CHECK (
        ([doctor_id] IS NOT NULL AND [staff_id] IS NULL) OR 
        ([doctor_id] IS NULL AND [staff_id] IS NOT NULL)
    );';
    EXEC sp_executesql @sql1;
    
    PRINT '  Added constraint: CK_AttendanceRecords_OneOwner'
    
    -- Update index to include staff_id
    IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_AttendanceRecords_DoctorID' AND object_id = OBJECT_ID('dbo.AttendanceRecords'))
        DROP INDEX [IX_AttendanceRecords_DoctorID] ON [dbo].[AttendanceRecords];
    
    DECLARE @sql_idx1 NVARCHAR(MAX) = N'
    CREATE NONCLUSTERED INDEX [IX_AttendanceRecords_DoctorID] ON [dbo].[AttendanceRecords]
    (
        [doctor_id] ASC,
        [CheckIn] ASC
    )
    WHERE ([doctor_id] IS NOT NULL)
    WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY];';
    EXEC sp_executesql @sql_idx1;
    
    DECLARE @sql_idx2 NVARCHAR(MAX) = N'
    CREATE NONCLUSTERED INDEX [IX_AttendanceRecords_StaffID] ON [dbo].[AttendanceRecords]
    (
        [staff_id] ASC,
        [CheckIn] ASC
    )
    WHERE ([staff_id] IS NOT NULL)
    WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY];';
    EXEC sp_executesql @sql_idx2;
    
    PRINT '  Updated indexes for AttendanceRecords'
    PRINT ''
    
    -- =============================================
    -- Step 2: Modify PayrollRecords table
    -- =============================================
    PRINT 'Step 2: Modifying PayrollRecords table...'
    
    -- Add staff_id column (nullable)
    ALTER TABLE [dbo].[PayrollRecords]
    ADD [staff_id] [int] NULL;
    
    PRINT '  Added column: PayrollRecords.staff_id'
    
    -- Drop existing foreign key and check constraint
    ALTER TABLE [dbo].[PayrollRecords]
    DROP CONSTRAINT [FK_PayrollRecords_Doctor];
    
    ALTER TABLE [dbo].[PayrollRecords]
    DROP CONSTRAINT [CK_PayrollRecords_DoctorID];
    
    -- Make doctor_id nullable
    ALTER TABLE [dbo].[PayrollRecords]
    ALTER COLUMN [doctor_id] [int] NULL;
    
    PRINT '  Made doctor_id nullable'
    
    -- Add foreign key for staff_id
    ALTER TABLE [dbo].[PayrollRecords]
    ADD CONSTRAINT [FK_PayrollRecords_Staff] FOREIGN KEY([staff_id])
    REFERENCES [dbo].[Staff] ([staff_id])
    ON DELETE CASCADE;
    
    PRINT '  Added foreign key: FK_PayrollRecords_Staff'
    
    -- Re-add foreign key for doctor_id (now nullable)
    ALTER TABLE [dbo].[PayrollRecords]
    ADD CONSTRAINT [FK_PayrollRecords_Doctor] FOREIGN KEY([doctor_id])
    REFERENCES [dbo].[Doctor] ([doctor_id])
    ON DELETE CASCADE;
    
    PRINT '  Re-added foreign key: FK_PayrollRecords_Doctor'
    
    -- Add check constraint: must have exactly one of doctor_id or staff_id
    -- Use dynamic SQL to ensure column exists before creating constraint
    DECLARE @sql2 NVARCHAR(MAX) = N'
    ALTER TABLE [dbo].[PayrollRecords]
    ADD CONSTRAINT [CK_PayrollRecords_OneOwner] CHECK (
        ([doctor_id] IS NOT NULL AND [staff_id] IS NULL) OR 
        ([doctor_id] IS NULL AND [staff_id] IS NOT NULL)
    );';
    EXEC sp_executesql @sql2;
    
    PRINT '  Added constraint: CK_PayrollRecords_OneOwner'
    
    -- Update index to include staff_id
    IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_PayrollRecords_DoctorID' AND object_id = OBJECT_ID('dbo.PayrollRecords'))
        DROP INDEX [IX_PayrollRecords_DoctorID] ON [dbo].[PayrollRecords];
    
    DECLARE @sql_idx3 NVARCHAR(MAX) = N'
    CREATE NONCLUSTERED INDEX [IX_PayrollRecords_DoctorID] ON [dbo].[PayrollRecords]
    (
        [doctor_id] ASC,
        [PeriodStart] ASC,
        [PeriodEnd] ASC
    )
    WHERE ([doctor_id] IS NOT NULL)
    WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY];';
    EXEC sp_executesql @sql_idx3;
    
    DECLARE @sql_idx4 NVARCHAR(MAX) = N'
    CREATE NONCLUSTERED INDEX [IX_PayrollRecords_StaffID] ON [dbo].[PayrollRecords]
    (
        [staff_id] ASC,
        [PeriodStart] ASC,
        [PeriodEnd] ASC
    )
    WHERE ([staff_id] IS NOT NULL)
    WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY];';
    EXEC sp_executesql @sql_idx4;
    
    PRINT '  Updated indexes for PayrollRecords'
    PRINT ''
    
    -- =============================================
    -- Step 3: Modify StaffSalary table
    -- =============================================
    PRINT 'Step 3: Modifying StaffSalary table...'
    
    -- Add staff_id column (nullable)
    ALTER TABLE [dbo].[StaffSalary]
    ADD [staff_id] [int] NULL;
    
    PRINT '  Added column: StaffSalary.staff_id'
    
    -- Drop existing foreign key, check constraint, and unique index
    ALTER TABLE [dbo].[StaffSalary]
    DROP CONSTRAINT [FK_StaffSalary_Doctor];
    
    ALTER TABLE [dbo].[StaffSalary]
    DROP CONSTRAINT [CK_StaffSalary_DoctorID];
    
    DROP INDEX [UQ_StaffSalary_DoctorID] ON [dbo].[StaffSalary];
    
    -- Make doctor_id nullable
    ALTER TABLE [dbo].[StaffSalary]
    ALTER COLUMN [doctor_id] [int] NULL;
    
    PRINT '  Made doctor_id nullable'
    
    -- Add foreign key for staff_id
    ALTER TABLE [dbo].[StaffSalary]
    ADD CONSTRAINT [FK_StaffSalary_Staff] FOREIGN KEY([staff_id])
    REFERENCES [dbo].[Staff] ([staff_id])
    ON DELETE CASCADE;
    
    PRINT '  Added foreign key: FK_StaffSalary_Staff'
    
    -- Re-add foreign key for doctor_id (now nullable)
    ALTER TABLE [dbo].[StaffSalary]
    ADD CONSTRAINT [FK_StaffSalary_Doctor] FOREIGN KEY([doctor_id])
    REFERENCES [dbo].[Doctor] ([doctor_id])
    ON DELETE CASCADE;
    
    PRINT '  Re-added foreign key: FK_StaffSalary_Doctor'
    
    -- Add check constraint: must have exactly one of doctor_id or staff_id
    -- Use dynamic SQL to ensure column exists before creating constraint
    DECLARE @sql3 NVARCHAR(MAX) = N'
    ALTER TABLE [dbo].[StaffSalary]
    ADD CONSTRAINT [CK_StaffSalary_OneOwner] CHECK (
        ([doctor_id] IS NOT NULL AND [staff_id] IS NULL) OR 
        ([doctor_id] IS NULL AND [staff_id] IS NOT NULL)
    );';
    EXEC sp_executesql @sql3;
    
    PRINT '  Added constraint: CK_StaffSalary_OneOwner'
    
    -- Create unique indexes for both doctor_id and staff_id
    DECLARE @sql_idx5 NVARCHAR(MAX) = N'
    CREATE UNIQUE NONCLUSTERED INDEX [UQ_StaffSalary_DoctorID] ON [dbo].[StaffSalary]
    (
        [doctor_id] ASC
    )
    WHERE ([doctor_id] IS NOT NULL)
    WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY];';
    EXEC sp_executesql @sql_idx5;
    
    DECLARE @sql_idx6 NVARCHAR(MAX) = N'
    CREATE UNIQUE NONCLUSTERED INDEX [UQ_StaffSalary_StaffID] ON [dbo].[StaffSalary]
    (
        [staff_id] ASC
    )
    WHERE ([staff_id] IS NOT NULL)
    WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY];';
    EXEC sp_executesql @sql_idx6;
    
    -- Update existing index
    IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_StaffSalary_DoctorID' AND object_id = OBJECT_ID('dbo.StaffSalary'))
        DROP INDEX [IX_StaffSalary_DoctorID] ON [dbo].[StaffSalary];
    
    DECLARE @sql_idx7 NVARCHAR(MAX) = N'
    CREATE NONCLUSTERED INDEX [IX_StaffSalary_DoctorID] ON [dbo].[StaffSalary]
    (
        [doctor_id] ASC
    )
    WHERE ([doctor_id] IS NOT NULL)
    WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY];';
    EXEC sp_executesql @sql_idx7;
    
    DECLARE @sql_idx8 NVARCHAR(MAX) = N'
    CREATE NONCLUSTERED INDEX [IX_StaffSalary_StaffID] ON [dbo].[StaffSalary]
    (
        [staff_id] ASC
    )
    WHERE ([staff_id] IS NOT NULL)
    WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY];';
    EXEC sp_executesql @sql_idx8;
    
    PRINT '  Updated indexes for StaffSalary'
    PRINT ''
    
    COMMIT TRANSACTION;
    
    PRINT 'Table modifications completed successfully!'
    PRINT ''

END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
    
    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
    DECLARE @ErrorState INT = ERROR_STATE();
    
    PRINT 'Migration failed!'
    PRINT 'Error: ' + @ErrorMessage;
    
    RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
END CATCH
GO

-- =============================================
-- Step 4: Create Stored Procedures for Staff
-- (Must be after table modifications are committed)
-- =============================================
PRINT 'Step 4: Creating stored procedures for Staff...'
GO

-- StaffCheckIn
IF OBJECT_ID('dbo.StaffCheckIn', 'P') IS NOT NULL
    DROP PROCEDURE [dbo].[StaffCheckIn];
GO

CREATE PROCEDURE [dbo].[StaffCheckIn]
    @p_staff_id INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Check if already checked in today
    IF EXISTS (
        SELECT 1 FROM AttendanceRecords
        WHERE staff_id = @p_staff_id
          AND CAST(CheckIn AS DATE) = CAST(GETDATE() AS DATE)
    )
    BEGIN
        PRINT N'Staff has already checked in today.';
        RETURN;
    END;

    INSERT INTO AttendanceRecords (staff_id, CheckIn, CreatedAt)
    VALUES (@p_staff_id, GETDATE(), GETDATE());

    PRINT N'Check-in successful at ' + CONVERT(NVARCHAR, GETDATE(), 120);
END;
GO

PRINT '  Created stored procedure: StaffCheckIn'
GO

-- StaffCheckOut
IF OBJECT_ID('dbo.StaffCheckOut', 'P') IS NOT NULL
    DROP PROCEDURE [dbo].[StaffCheckOut];
GO

CREATE PROCEDURE [dbo].[StaffCheckOut]
    @p_staff_id INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @checkin DATETIME;

    -- Get the most recent shift that hasn't been checked out
    SELECT TOP 1 @checkin = CheckIn
    FROM AttendanceRecords
    WHERE staff_id = @p_staff_id AND CheckOut IS NULL
    ORDER BY CheckIn DESC;

    IF @checkin IS NULL
    BEGIN
        PRINT N'Staff has not checked in or has already checked out.';
        RETURN;
    END;

    -- Update checkout time and total hours
    UPDATE AttendanceRecords
    SET CheckOut = GETDATE(),
        TotalHours = ROUND(DATEDIFF(MINUTE, @checkin, GETDATE()) / 60.0, 2),
        Status = N'Completed'
    WHERE staff_id = @p_staff_id AND CheckOut IS NULL;

    PRINT N'Check-out successful at ' + CONVERT(NVARCHAR, GETDATE(), 120);
END;
GO

PRINT '  Created stored procedure: StaffCheckOut'
GO

-- GenerateStaffPayroll
IF OBJECT_ID('dbo.GenerateStaffPayroll', 'P') IS NOT NULL
    DROP PROCEDURE [dbo].[GenerateStaffPayroll];
GO

CREATE PROCEDURE [dbo].[GenerateStaffPayroll]
    @p_staff_id INT,
    @p_start DATE,
    @p_end DATE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE 
        @total_hours FLOAT = 0,
        @rate DECIMAL(10,2) = 20000, -- Default hourly rate for staff
        @salary DECIMAL(12,2) = 0;

    -- Calculate total working hours
    SELECT @total_hours = ISNULL(SUM(TotalHours), 0)
    FROM AttendanceRecords
    WHERE staff_id = @p_staff_id
      AND CheckIn >= @p_start
      AND CheckIn <= DATEADD(DAY, 1, @p_end);

    -- Get specific hourly rate if available
    SELECT @rate = ISNULL(HourlyRate, @rate)
    FROM StaffSalary
    WHERE staff_id = @p_staff_id;

    SET @salary = ROUND(@total_hours * @rate, 2);

    -- Check if record for this month already exists
    IF EXISTS (
        SELECT 1 FROM PayrollRecords
        WHERE staff_id = @p_staff_id
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
        WHERE staff_id = @p_staff_id
          AND MONTH(PeriodStart) = MONTH(@p_start)
          AND YEAR(PeriodStart) = YEAR(@p_start);

        PRINT N'Updated payroll record for current month for staff ' + CAST(@p_staff_id AS NVARCHAR);
    END
    ELSE
    BEGIN
        INSERT INTO PayrollRecords (staff_id, PeriodStart, PeriodEnd, TotalHours, HourlyRate, TotalSalary, CreatedAt)
        VALUES (@p_staff_id, @p_start, @p_end, @total_hours, @rate, @salary, GETDATE());

        PRINT N'Created new payroll record for staff ' + CAST(@p_staff_id AS NVARCHAR);
    END
END;
GO

PRINT '  Created stored procedure: GenerateStaffPayroll'
GO

PRINT ''
PRINT 'Migration completed successfully!'
PRINT ''
PRINT 'Summary of changes:'
PRINT '  ✅ AttendanceRecords: Now supports both Staff and Doctor (one of doctor_id or staff_id required)'
PRINT '  ✅ PayrollRecords: Now supports both Staff and Doctor (one of doctor_id or staff_id required)'
PRINT '  ✅ StaffSalary: Now supports both Staff and Doctor (one of doctor_id or staff_id required)'
PRINT '  ✅ Created stored procedures for Staff: StaffCheckIn, StaffCheckOut, GenerateStaffPayroll'
PRINT '  ✅ Existing Doctor procedures remain: DoctorCheckIn, DoctorCheckOut, GenerateDoctorPayroll'
PRINT ''
PRINT 'Pattern applied: Similar to WorkSchedule table - each record belongs to either Doctor OR Staff'
PRINT ''
PRINT 'Please verify the changes and test the stored procedures.'
PRINT ''
PRINT 'Completion time: ' + CONVERT(NVARCHAR, GETDATE(), 126);
GO

