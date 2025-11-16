use SHOP_PET_Database
go

drop table MedicalRecord

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'MedicalRecord')
BEGIN
    CREATE TABLE dbo.MedicalRecord (
        record_id INT IDENTITY(1,1) PRIMARY KEY,
        booking_id INT NOT NULL,
        pet_id INT NOT NULL,
        doctor_id INT NOT NULL,
        customer_id INT NOT NULL,
        
        -- Thông tin khám bệnh
        examination_date DATETIME2 NOT NULL DEFAULT GETDATE(),
        symptoms NVARCHAR(MAX), -- Triệu chứng
        diagnosis NVARCHAR(MAX), -- Chẩn đoán
        treatment NVARCHAR(MAX), -- Phương pháp điều trị
        prescription NVARCHAR(MAX), -- Đơn thuốc
        
        -- Thông tin sức khỏe
        weight DECIMAL(5,2), -- Cân nặng (kg)
        temperature DECIMAL(4,2), -- Nhiệt độ (°C)
        heart_rate INT, -- Nhịp tim (bpm)
        blood_pressure NVARCHAR(20), -- Huyết áp
        
        -- Ghi chú và theo dõi
        notes NVARCHAR(MAX), -- Ghi chú chung
        follow_up_date DATE, -- Ngày tái khám
        follow_up_notes NVARCHAR(MAX), -- Ghi chú tái khám
        
        -- Metadata
        created_at DATETIME2 DEFAULT GETDATE(),
        updated_at DATETIME2 DEFAULT GETDATE(),
        
        -- Foreign Keys
        CONSTRAINT FK_MedicalRecord_Booking FOREIGN KEY (booking_id) 
            REFERENCES dbo.Booking(booking_id) ON DELETE CASCADE,
        CONSTRAINT FK_MedicalRecord_Pet FOREIGN KEY (pet_id) 
            REFERENCES dbo.Pet(id) ON DELETE NO ACTION,
        CONSTRAINT FK_MedicalRecord_Doctor FOREIGN KEY (doctor_id) 
            REFERENCES dbo.Doctor(doctor_id) ON DELETE NO ACTION,
        CONSTRAINT FK_MedicalRecord_Customer FOREIGN KEY (customer_id) 
            REFERENCES dbo.Customer(customer_id) ON DELETE NO ACTION
    )
    
    PRINT 'Table MedicalRecord created successfully'
END
ELSE
BEGIN
    PRINT 'Table MedicalRecord already exists'
END
GO

-- Tạo indexes để tăng hiệu suất truy vấn
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_MedicalRecord_BookingId')
BEGIN
    CREATE INDEX IX_MedicalRecord_BookingId ON dbo.MedicalRecord(booking_id)
    PRINT 'Index IX_MedicalRecord_BookingId created'
END

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_MedicalRecord_PetId')
BEGIN
    CREATE INDEX IX_MedicalRecord_PetId ON dbo.MedicalRecord(pet_id)
    PRINT 'Index IX_MedicalRecord_PetId created'
END

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_MedicalRecord_DoctorId')
BEGIN
    CREATE INDEX IX_MedicalRecord_DoctorId ON dbo.MedicalRecord(doctor_id)
    PRINT 'Index IX_MedicalRecord_DoctorId created'
END

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_MedicalRecord_CustomerId')
BEGIN
    CREATE INDEX IX_MedicalRecord_CustomerId ON dbo.MedicalRecord(customer_id)
    PRINT 'Index IX_MedicalRecord_CustomerId created'
END
GO

-- Tạo trigger để tự động cập nhật updated_at
IF NOT EXISTS (SELECT * FROM sys.triggers WHERE name = 'tr_MedicalRecord_Update')
BEGIN
    EXEC('
    CREATE TRIGGER tr_MedicalRecord_Update
    ON dbo.MedicalRecord
    AFTER UPDATE
    AS
    BEGIN
        SET NOCOUNT ON;
        UPDATE dbo.MedicalRecord
        SET updated_at = GETDATE()
        FROM dbo.MedicalRecord mr
        INNER JOIN inserted i ON mr.record_id = i.record_id
    END
    ')
    
    PRINT 'Trigger tr_MedicalRecord_Update created successfully'
END
ELSE
BEGIN
    PRINT 'Trigger tr_MedicalRecord_Update already exists'
END
GO

-- Kiểm tra cấu trúc bảng
SELECT 
    TABLE_NAME,
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE,
    COLUMN_DEFAULT
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_SCHEMA = 'dbo' 
AND TABLE_NAME = 'MedicalRecord'
ORDER BY ORDINAL_POSITION
GO

PRINT 'Medical Record table setup completed successfully'




drop table Doctor


-- Đổi tên cột 'doctor_id' → 'doctorId' cho đồng bộ
EXEC sp_rename 'Doctor.doctor_id', 'doctorId', 'COLUMN';

-- Gỡ default constraint và xóa cột 'status' an toàn
DECLARE @ConstraintName NVARCHAR(128);

-- Tìm tên constraint mặc định gắn với cột 'status'
SELECT @ConstraintName = dc.name
FROM sys.default_constraints dc
JOIN sys.columns c 
    ON c.default_object_id = dc.object_id
WHERE dc.parent_object_id = OBJECT_ID('dbo.Doctor')
  AND c.name = 'status';

-- Nếu có constraint thì xóa
IF @ConstraintName IS NOT NULL
BEGIN
    DECLARE @sql NVARCHAR(300);
    SET @sql = 'ALTER TABLE dbo.Doctor DROP CONSTRAINT ' + @ConstraintName;
    EXEC(@sql);
END

-- Sau khi gỡ constraint, xóa luôn cột 'status'
ALTER TABLE dbo.Doctor DROP COLUMN status;

-- Gỡ constraint và xóa cột 'created_at' an toàn
DECLARE @ConstraintName2 NVARCHAR(128);

-- Tìm tên constraint mặc định của cột 'created_at'
SELECT @ConstraintName2 = dc.name
FROM sys.default_constraints dc
JOIN sys.columns c 
    ON c.default_object_id = dc.object_id
WHERE dc.parent_object_id = OBJECT_ID('dbo.Doctor')
  AND c.name = 'created_at';

-- Nếu có constraint thì xóa
IF @ConstraintName2 IS NOT NULL
BEGIN
    DECLARE @sql2 NVARCHAR(300);
    SET @sql2 = 'ALTER TABLE dbo.Doctor DROP CONSTRAINT ' + @ConstraintName2;
    EXEC(@sql2);
END

-- Sau khi gỡ constraint, xóa luôn cột 'created_at'
ALTER TABLE dbo.Doctor DROP COLUMN created_at;

ALTER TABLE Doctor
ADD 
    password NVARCHAR(255),
    scheduleNote NVARCHAR(255);

	EXEC sp_help Doctor;

	ALTER TABLE Doctor DROP COLUMN description;

	UPDATE Doctor
SET 
    password = '123456',
    scheduleNote = 'Làm việc từ Thứ 2 đến Thứ 6, 8:00–17:00';

	UPDATE Customer
SET password = '123456'
WHERE customer_id IN (7, 8);


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

CREATE OR ALTER PROCEDURE GenerateDoctorPayroll
    @p_doctor_id INT,
    @p_start DATE,
    @p_end DATE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE 
        @daysWorked INT = 0,
        @standardDays INT = 26,
        @monthlyBase DECIMAL(12,2) = 15000000,  -- Default 15 triệu / tháng
        @totalSalary DECIMAL(12,2);

    --------------------------------------------------------
    -- 1️⃣ Tính số ngày làm việc (ngày nào có cả check-in + check-out)
    --------------------------------------------------------
    SELECT @daysWorked = COUNT(*)
    FROM DoctorAttendanceRecords
    WHERE DoctorID = @p_doctor_id
      AND CheckIn >= @p_start
      AND CheckIn < DATEADD(DAY, 1, @p_end)
      AND CheckOut IS NOT NULL;

    --------------------------------------------------------
    -- 2️⃣ Lấy lương tháng và số ngày công chuẩn trong DoctorSalary
    --------------------------------------------------------
    SELECT 
        @monthlyBase = ISNULL(MonthlyBaseSalary, @monthlyBase),
        @standardDays = ISNULL(StandardWorkingDays, @standardDays)
    FROM DoctorSalary
    WHERE DoctorID = @p_doctor_id;

    --------------------------------------------------------
    -- 3️⃣ Tính tổng lương
    --------------------------------------------------------
    SET @totalSalary = ROUND(@monthlyBase * (@daysWorked * 1.0 / @standardDays), 0);

    --------------------------------------------------------
    -- 4️⃣ Nếu tháng đó đã có phiếu lương → UPDATE
    --------------------------------------------------------
    IF EXISTS (
        SELECT 1 FROM DoctorPayrollRecords
        WHERE DoctorID = @p_doctor_id
          AND MONTH(PeriodStart) = MONTH(@p_start)
          AND YEAR(PeriodStart) = YEAR(@p_start)
    )
    BEGIN
        UPDATE DoctorPayrollRecords
        SET 
            PeriodStart = @p_start,
            PeriodEnd = @p_end,
            DaysWorked = @daysWorked,
            StandardWorkingDays = @standardDays,
            MonthlyBaseSalary = @monthlyBase,
            TotalSalary = @totalSalary,
            CreatedAt = GETDATE()
        WHERE DoctorID = @p_doctor_id
          AND MONTH(PeriodStart) = MONTH(@p_start)
          AND YEAR(PeriodStart) = YEAR(@p_start);

        PRINT N'🔄 Đã cập nhật bảng lương tháng cho bác sĩ ' + CAST(@p_doctor_id AS NVARCHAR);
    END
    ELSE
    BEGIN
        --------------------------------------------------------
        -- 5️⃣ Nếu chưa có thì INSERT bản ghi mới
        --------------------------------------------------------
        INSERT INTO DoctorPayrollRecords
        (
            DoctorID, PeriodStart, PeriodEnd,
            TotalSalary, CreatedAt,
            DaysWorked, StandardWorkingDays, MonthlyBaseSalary
        )
        VALUES
        (
            @p_doctor_id, @p_start, @p_end,
            @totalSalary, GETDATE(),
            @daysWorked, @standardDays, @monthlyBase
        );

        PRINT N'✅ Đã tạo phiếu lương tháng mới cho bác sĩ ' + CAST(@p_doctor_id AS NVARCHAR);
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

--sửa bảng DOCTOR


ALTER TABLE WorkSchedule DROP CONSTRAINT FK_WorkSchedule_Doctor;
ALTER TABLE Booking DROP CONSTRAINT FK_Booking_Doctor;
ALTER TABLE MedicalRecord DROP CONSTRAINT FK_MedicalRecord_Doctor;

IF OBJECT_ID('dbo.Doctor','U') IS NOT NULL
    DROP TABLE dbo.Doctor;
GO
CREATE TABLE dbo.Doctor (
    doctor_id      INT IDENTITY(1,1) PRIMARY KEY,
    name           NVARCHAR(120)   NOT NULL,
    email          NVARCHAR(255)   NOT NULL,
    phone          NVARCHAR(20)    NULL,
    [password]     NVARCHAR(255)   NULL,      -- BCrypt ~60 ký tự, để 255 cho thoải mái
    specialization NVARCHAR(200)   NULL,
    schedule_note  NVARCHAR(500)   NULL,
    CONSTRAINT UX_Doctor_Email UNIQUE (email)
);

ALTER TABLE WorkSchedule
ADD CONSTRAINT FK_WorkSchedule_Doctor
FOREIGN KEY (doctor_id) REFERENCES Doctor(doctor_id);

ALTER TABLE Booking
ADD CONSTRAINT FK_Booking_Doctor
FOREIGN KEY (doctor_id) REFERENCES Doctor(doctor_id);

ALTER TABLE MedicalRecord
ADD CONSTRAINT FK_MedicalRecord_Doctor
FOREIGN KEY (doctor_id) REFERENCES Doctor(doctor_id);


INSERT INTO Doctor (name, email, phone, [password], specialization, schedule_note)
VALUES
(N'BS. Nguyễn Minh Anh', 'minhanh.nguyen@pets4care.com', '0901234561', 123456, N'Da liễu & chăm sóc da', NULL),
(N'BS. Trần Văn Cường', 'vancuong.tran@pets4care.com', '0901234562', 123456, N'Phẫu thuật & chỉnh hình', NULL),
(N'BS. Lê Thị Mai', 'thimai.le@pets4care.com', '0901234563', 123456, N'Tim mạch & hô hấp', NULL),
(N'BS. Phạm Đức Minh', 'ducminh.pham@pets4care.com', '0901234564', 123456, N'Tiêu hóa & dinh dưỡng', NULL),
(N'BS. Võ Thị Hương', 'thihuong.vo@pets4care.com', '0901234565', 123456, N'Sản khoa & sinh sản', NULL),
(N'BS. Đặng Văn Tùng', 'vantung.dang@pets4care.com', '0901234566', 123456, N'Thần kinh & hành vi', NULL);


 USE SHOP_PET_Database
GO

-- Remove scheduleNote from Doctor table
-- Doctor will use WorkSchedule table instead

DECLARE @ConstraintName NVARCHAR(128);

-- Find and drop default constraint if exists
SELECT @ConstraintName = dc.name
FROM sys.default_constraints dc
JOIN sys.columns c 
    ON c.default_object_id = dc.object_id
WHERE dc.parent_object_id = OBJECT_ID('dbo.Doctor')
  AND c.name = 'scheduleNote';

IF @ConstraintName IS NOT NULL
BEGIN
    DECLARE @sql NVARCHAR(300);
    SET @sql = 'ALTER TABLE dbo.Doctor DROP CONSTRAINT ' + @ConstraintName;
    EXEC(@sql);
    PRINT N'✅ Dropped constraint: ' + @ConstraintName;
END

-- Drop the scheduleNote column
IF EXISTS (
    SELECT 1 FROM sys.columns 
    WHERE object_id = OBJECT_ID('dbo.Doctor') 
    AND name = 'scheduleNote'
)
BEGIN
    ALTER TABLE dbo.Doctor DROP COLUMN scheduleNote;
    PRINT N'✅ Dropped column scheduleNote from Doctor table';
END
ELSE
BEGIN
    PRINT N'⚠️ Column scheduleNote does not exist in Doctor table';
END
GO

PRINT N'✅ Doctor table updated - now using WorkSchedule system'
GO

ALTER TABLE DoctorSalary DROP COLUMN HourlyRate;

ALTER TABLE DoctorSalary
ADD MonthlyBaseSalary DECIMAL(12,2) DEFAULT 15000000,  -- ví dụ 15 triệu / tháng
    StandardWorkingDays INT DEFAULT 26;

	DECLARE @ConstraintName NVARCHAR(128);

SELECT @ConstraintName = dc.name
FROM sys.default_constraints dc
JOIN sys.columns c 
    ON c.default_object_id = dc.object_id
WHERE dc.parent_object_id = OBJECT_ID('dbo.DoctorSalary')
  AND c.name = 'HourlyRate';

SELECT @ConstraintName AS ConstraintName;  -- xem thử tên

ALTER TABLE DoctorSalary 
DROP CONSTRAINT DF__DoctorSal__Hourl__4944D3CA;

ALTER TABLE DoctorSalary DROP COLUMN HourlyRate;

ALTER TABLE DoctorSalary
ADD MonthlyBaseSalary DECIMAL(12,2) DEFAULT 15000000,  -- ví dụ 15 triệu / tháng
    StandardWorkingDays INT DEFAULT 26;

	IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('DoctorPayrollRecords') AND name = 'TotalHours')
    ALTER TABLE DoctorPayrollRecords DROP COLUMN TotalHours;

IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('DoctorPayrollRecords') AND name = 'HourlyRate')
    ALTER TABLE DoctorPayrollRecords DROP COLUMN HourlyRate;


ALTER TABLE DoctorPayrollRecords
ADD 
    DaysWorked INT NULL,
    StandardWorkingDays INT NULL,
    MonthlyBaseSalary DECIMAL(12,2) NULL;

SELECT COLUMN_NAME 
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'DoctorPayrollRecords';

EXEC GenerateDoctorPayroll 1, '2025-11-01', '2025-11-30';