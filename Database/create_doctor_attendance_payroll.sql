USE SHOP_PET_Database
GO

-- =====================================================
-- Tạo bảng chấm công cho Doctor (tương tự Staff)
-- =====================================================

-- Bảng chấm công Doctor
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'DoctorAttendanceRecords')
BEGIN
    CREATE TABLE dbo.DoctorAttendanceRecords (
        AttendanceID INT IDENTITY(1,1) PRIMARY KEY,
        DoctorID INT NOT NULL,
        CheckIn DATETIME NOT NULL,
        CheckOut DATETIME NULL,
        TotalHours FLOAT NULL,
        Status NVARCHAR(50) DEFAULT N'Đang làm',
        CreatedAt DATETIME DEFAULT GETDATE(),
        CONSTRAINT FK_DoctorAttendance_Doctor FOREIGN KEY (DoctorID) 
            REFERENCES dbo.Doctor(doctor_id) ON DELETE CASCADE
    )
    PRINT 'Table DoctorAttendanceRecords created successfully'
END
ELSE
BEGIN
    PRINT 'Table DoctorAttendanceRecords already exists'
END
GO

-- Bảng lương Doctor
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'DoctorSalary')
BEGIN
    CREATE TABLE dbo.DoctorSalary (
        SalaryID INT IDENTITY(1,1) PRIMARY KEY,
        DoctorID INT NOT NULL UNIQUE,
        HourlyRate DECIMAL(10,2) DEFAULT 25000, -- Bác sĩ lương cao hơn staff
        UpdatedAt DATETIME DEFAULT GETDATE(),
        CONSTRAINT FK_DoctorSalary_Doctor FOREIGN KEY (DoctorID) 
            REFERENCES dbo.Doctor(doctor_id) ON DELETE CASCADE
    )
    PRINT 'Table DoctorSalary created successfully'
END
ELSE
BEGIN
    PRINT 'Table DoctorSalary already exists'
END
GO

-- Bảng phiếu lương Doctor
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'DoctorPayrollRecords')
BEGIN
    CREATE TABLE dbo.DoctorPayrollRecords (
        PayrollID INT IDENTITY(1,1) PRIMARY KEY,
        DoctorID INT NOT NULL,
        PeriodStart DATE NOT NULL,
        PeriodEnd DATE NOT NULL,
        TotalHours FLOAT,
        HourlyRate DECIMAL(10,2),
        TotalSalary DECIMAL(12,2),
        CreatedAt DATETIME DEFAULT GETDATE(),
        CONSTRAINT FK_DoctorPayroll_Doctor FOREIGN KEY (DoctorID) 
            REFERENCES dbo.Doctor(doctor_id) ON DELETE CASCADE
    )
    PRINT 'Table DoctorPayrollRecords created successfully'
END
ELSE
BEGIN
    PRINT 'Table DoctorPayrollRecords already exists'
END
GO

-- =====================================================
-- Stored Procedures cho Doctor
-- =====================================================

-- Procedure Check-in cho Doctor
CREATE OR ALTER PROCEDURE DoctorCheckIn
    @p_doctor_id INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Kiểm tra đã check-in hôm nay chưa
    IF EXISTS (
        SELECT 1 FROM DoctorAttendanceRecords
        WHERE DoctorID = @p_doctor_id
          AND CAST(CheckIn AS DATE) = CAST(GETDATE() AS DATE)
    )
    BEGIN
        PRINT N'❌ Bác sĩ đã check-in hôm nay.';
        RETURN;
    END;

    INSERT INTO DoctorAttendanceRecords (DoctorID, CheckIn)
    VALUES (@p_doctor_id, GETDATE());

    PRINT N'✅ Check-in thành công lúc ' + CONVERT(NVARCHAR, GETDATE(), 120);
END;
GO

-- Procedure Check-out cho Doctor
CREATE OR ALTER PROCEDURE DoctorCheckOut
    @p_doctor_id INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @checkin DATETIME;

    -- Lấy ca làm gần nhất chưa check-out
    SELECT TOP 1 @checkin = CheckIn
    FROM DoctorAttendanceRecords
    WHERE DoctorID = @p_doctor_id AND CheckOut IS NULL
    ORDER BY CheckIn DESC;

    IF @checkin IS NULL
    BEGIN
        PRINT N'❌ Bác sĩ chưa check-in hoặc đã check-out.';
        RETURN;
    END;

    -- Cập nhật giờ ra và tổng số giờ
    UPDATE DoctorAttendanceRecords
    SET CheckOut = GETDATE(),
        TotalHours = ROUND(DATEDIFF(MINUTE, @checkin, GETDATE()) / 60.0, 2),
        Status = N'Hoàn tất'
    WHERE DoctorID = @p_doctor_id AND CheckOut IS NULL;

    PRINT N'✅ Check-out thành công lúc ' + CONVERT(NVARCHAR, GETDATE(), 120);
END;
GO

-- Procedure tính lương cho Doctor
CREATE OR ALTER PROCEDURE GenerateDoctorPayroll
    @p_doctor_id INT,
    @p_start DATE,
    @p_end DATE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE 
        @total_hours FLOAT = 0,
        @rate DECIMAL(10,2) = 25000, -- Mức lương mặc định cho bác sĩ
        @salary DECIMAL(12,2) = 0;

    -- ✅ Tính tổng số giờ làm việc
    SELECT @total_hours = ISNULL(SUM(TotalHours), 0)
    FROM DoctorAttendanceRecords
    WHERE DoctorID = @p_doctor_id
      AND CheckIn >= @p_start
      AND CheckIn <= DATEADD(DAY, 1, @p_end);

    -- ✅ Lấy mức lương/giờ riêng nếu có
    SELECT @rate = ISNULL(HourlyRate, @rate)
    FROM DoctorSalary
    WHERE DoctorID = @p_doctor_id;

    SET @salary = ROUND(@total_hours * @rate, 2);

    -- ✅ Kiểm tra xem tháng này đã có record chưa (theo tháng/năm)
    IF EXISTS (
        SELECT 1 FROM DoctorPayrollRecords
        WHERE DoctorID = @p_doctor_id
          AND MONTH(PeriodStart) = MONTH(@p_start)
          AND YEAR(PeriodStart) = YEAR(@p_start)
    )
    BEGIN
        UPDATE DoctorPayrollRecords
        SET TotalHours = @total_hours,
            HourlyRate = @rate,
            TotalSalary = @salary,
            PeriodStart = @p_start,
            PeriodEnd = @p_end,
            CreatedAt = GETDATE()
        WHERE DoctorID = @p_doctor_id
          AND MONTH(PeriodStart) = MONTH(@p_start)
          AND YEAR(PeriodStart) = YEAR(@p_start);

        PRINT N'🔁 Đã cập nhật phiếu lương tháng hiện tại cho bác sĩ ' + CAST(@p_doctor_id AS NVARCHAR);
    END
    ELSE
    BEGIN
        INSERT INTO DoctorPayrollRecords (DoctorID, PeriodStart, PeriodEnd, TotalHours, HourlyRate, TotalSalary, CreatedAt)
        VALUES (@p_doctor_id, @p_start, @p_end, @total_hours, @rate, @salary, GETDATE());

        PRINT N'💰 Đã tạo phiếu lương mới cho bác sĩ ' + CAST(@p_doctor_id AS NVARCHAR);
    END
END;
GO

-- =====================================================
-- Insert default salary rates for existing doctors
-- =====================================================
INSERT INTO DoctorSalary (DoctorID, HourlyRate)
SELECT doctor_id, 25000
FROM Doctor
WHERE doctor_id NOT IN (SELECT DoctorID FROM DoctorSalary)
GO

PRINT '✅ Doctor attendance and payroll system created successfully!'
GO

