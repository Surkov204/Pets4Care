use SHOP_PET_Database
go

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

	--Tuấn Anh
	---- Thêm Shift_ID ---- cho cái WorkSchedule nếu có rồi thì không cần tạo nữa
ALTER TABLE WorkSchedule
ADD shift_id INT NULL;
---- Udate ----> cho cái WorkSchedule nếu có rồi thì không cần tạo nữa
UPDATE WorkSchedule
SET shift_id = CASE
    WHEN start_time = '08:00:00' AND end_time = '12:00:00' THEN 1
    WHEN start_time = '13:00:00' AND end_time = '17:00:00' THEN 2
    WHEN start_time = '18:00:00' AND end_time = '22:00:00' THEN 3
    ELSE NULL
END;
--- chạy cái này ---
SELECT schedule_id, staff_id, work_date, start_time, end_time, shift_id, status
FROM WorkSchedule
ORDER BY work_date;

--- thêm cái này vào --- nếu như debug nó kêu là có rồi thì bỏ qua đọc cho kĩ nha ----

INSERT INTO Shifts (ShiftCode, ShiftName, StartTime, EndTime, BreakMinutes, Location)
VALUES
('S1', N'Ca sáng', '08:00:00', '12:00:00', 15, N'Phòng khám chính'),
('S2', N'Ca chiều', '13:00:00', '17:00:00', 15, N'Phòng khám chính'),
('S3', N'Ca tối', '18:00:00', '22:00:00', 15, N'Phòng khám chính')

---- update lại cái này ----

UPDATE ws
SET ws.shift_id = s.ShiftID
FROM WorkSchedule ws
JOIN Shifts s
  ON CONVERT(VARCHAR(8), ws.start_time, 108) = CONVERT(VARCHAR(8), s.StartTime, 108)
 AND CONVERT(VARCHAR(8), ws.end_time, 108) = CONVERT(VARCHAR(8), s.EndTime, 108)
WHERE ws.shift_id IS NULL;

---- cái này là xóa hết đám nhân viên cũ nếu có nhân viên thì không cần ----
DELETE FROM Staff;
DBCC CHECKIDENT ('Staff', RESEED, 0);
GO

-- 🧾 Thêm dữ liệu mới (tất cả đều là nhân viên) lưu ý có rồi thì không cần insert nữa
INSERT INTO Staff (name, phone, email, password, position)
VALUES
(N'Nguyễn Văn A', '0911111111', 'vana@petshop.com', 'staff123', N'nhân viên'),
(N'Lê Thị B', '0922222222', 'leb@petshop.com', 'staff123', N'nhân viên'),
(N'Trần Văn C', '0933333333', 'vanc@petshop.com', 'staff123', N'nhân viên'),
(N'Phạm Thị D', '0944444444', 'thid@petshop.com', 'staff123', N'nhân viên'),
(N'Hoàng Văn E', '0955555555', 'vane@petshop.com', 'staff123', N'nhân viên'),
(N'Đặng Thị F', '0966666666', 'thif@petshop.com', 'staff123', N'nhân viên');
GO

-- ✅ Kiểm tra lại dữ liệu
SELECT * FROM Staff;

SELECT ws.work_date, s.name, ws.shift_id, ws.status
FROM WorkSchedule ws
JOIN Staff s ON ws.staff_id = s.staff_id
WHERE ws.status = N'Đã đăng ký';

ALTER TABLE ShiftRequests
ADD 
    FromDate DATE,
    ToDate DATE,
    ToStaffID INT;

ALTER TABLE ShiftRequests
ADD ToNotified BIT DEFAULT 0,  -- Đã gửi thông báo cho B chưa
    AdminNotified BIT DEFAULT 0;  -- Đã gửi thông báo cho admin chưa

	-- Tạo cái bảng này ---
CREATE TABLE Notifications (
    NotificationID INT IDENTITY(1,1) PRIMARY KEY,
    StaffID INT NOT NULL,
    Title NVARCHAR(255),
    Message NVARCHAR(500),
    IsRead BIT DEFAULT 0,
    CreatedAt DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (StaffID) REFERENCES Staff(staff_id)
);
ALTER TABLE Notifications
ADD IsHandled BIT DEFAULT 0;



-- Bảng chấm công từng nhân viên 
-- Tạo cái bảng này ---
CREATE TABLE AttendanceRecords (
    AttendanceID INT IDENTITY(1,1) PRIMARY KEY,
    StaffID INT NOT NULL,
    CheckIn DATETIME NOT NULL,
    CheckOut DATETIME NULL,
    TotalHours FLOAT NULL,
    Status NVARCHAR(50) DEFAULT N'Đang làm',
    CreatedAt DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (StaffID) REFERENCES Staff(staff_id)
);
GO
-- Tạo cái bảng này ---
CREATE TABLE StaffSalary (
    SalaryID INT IDENTITY(1,1) PRIMARY KEY,
    StaffID INT NOT NULL UNIQUE,
    HourlyRate DECIMAL(10,2) DEFAULT 15000,
    UpdatedAt DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (StaffID) REFERENCES Staff(staff_id)
);
GO
-- Tạo cái bảng này ---
CREATE TABLE PayrollRecords (
    PayrollID INT IDENTITY(1,1) PRIMARY KEY,
    StaffID INT NOT NULL,
    PeriodStart DATE NOT NULL,
    PeriodEnd DATE NOT NULL,
    TotalHours FLOAT,
    HourlyRate DECIMAL(10,2),
    TotalSalary DECIMAL(12,2),
    CreatedAt DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (StaffID) REFERENCES Staff(staff_id)
);
GO
--  cái này là các procedure không cần chạy ---
CREATE OR ALTER PROCEDURE StaffCheckIn
    @p_staff_id INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Kiểm tra đã check-in hôm nay chưa
    IF EXISTS (
        SELECT 1 FROM AttendanceRecords
        WHERE StaffID = @p_staff_id
          AND CAST(CheckIn AS DATE) = CAST(GETDATE() AS DATE)
    )
    BEGIN
        PRINT N'❌ Nhân viên đã check-in hôm nay.';
        RETURN;
    END;

    INSERT INTO AttendanceRecords (StaffID, CheckIn)
    VALUES (@p_staff_id, GETDATE());

    PRINT N'✅ Check-in thành công lúc ' + CONVERT(NVARCHAR, GETDATE(), 120);
END;
GO

CREATE OR ALTER PROCEDURE StaffCheckOut
    @p_staff_id INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @checkin DATETIME;

    -- Lấy ca làm gần nhất chưa check-out
    SELECT TOP 1 @checkin = CheckIn
    FROM AttendanceRecords
    WHERE StaffID = @p_staff_id AND CheckOut IS NULL
    ORDER BY CheckIn DESC;

    IF @checkin IS NULL
    BEGIN
        PRINT N'❌ Nhân viên chưa check-in hoặc đã check-out.';
        RETURN;
    END;

    -- Cập nhật giờ ra và tổng số giờ
    UPDATE AttendanceRecords
    SET CheckOut = GETDATE(),
        TotalHours = ROUND(DATEDIFF(MINUTE, @checkin, GETDATE()) / 60.0, 2),
        Status = N'Hoàn tất'
    WHERE StaffID = @p_staff_id AND CheckOut IS NULL;

    PRINT N'✅ Check-out thành công lúc ' + CONVERT(NVARCHAR, GETDATE(), 120);
END;
GO

CREATE OR ALTER PROCEDURE GeneratePayroll
    @p_staff_id INT,
    @p_start DATE,
    @p_end DATE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE 
        @total_hours FLOAT = 0,
        @rate DECIMAL(10,2) = 15000,
        @salary DECIMAL(12,2) = 0;

    -- ✅ Tính tổng số giờ làm việc
    SELECT @total_hours = ISNULL(SUM(TotalHours), 0)
    FROM AttendanceRecords
    WHERE StaffID = @p_staff_id
      AND CheckIn >= @p_start
AND CheckIn <= DATEADD(DAY, 1, @p_end);

    -- ✅ Lấy mức lương/giờ riêng nếu có
    SELECT @rate = ISNULL(HourlyRate, @rate)
    FROM StaffSalary
    WHERE StaffID = @p_staff_id;

    SET @salary = ROUND(@total_hours * @rate, 2);

    -- ✅ Kiểm tra xem tháng này đã có record chưa (theo tháng/năm)
    IF EXISTS (
        SELECT 1 FROM PayrollRecords
        WHERE StaffID = @p_staff_id
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
        WHERE StaffID = @p_staff_id
          AND MONTH(PeriodStart) = MONTH(@p_start)
          AND YEAR(PeriodStart) = YEAR(@p_start);

        PRINT N'🔁 Đã cập nhật phiếu lương tháng hiện tại cho nhân viên ' + CAST(@p_staff_id AS NVARCHAR);
    END
    ELSE
    BEGIN
        INSERT INTO PayrollRecords (StaffID, PeriodStart, PeriodEnd, TotalHours, HourlyRate, TotalSalary, CreatedAt)
        VALUES (@p_staff_id, @p_start, @p_end, @total_hours, @rate, @salary, GETDATE());

        PRINT N'💰 Đã tạo phiếu lương mới cho nhân viên ' + CAST(@p_staff_id AS NVARCHAR);
    END
END;
GO
-----------------------------------------------------------
-- Tạo cai bảng này ---
CREATE TABLE SystemSettings (
    SettingKey NVARCHAR(100) PRIMARY KEY,
    SettingValue NVARCHAR(100) NOT NULL
);

-- ⚙️ Mặc định tắt đăng ký ca
-- Thêm cái đống dữ liệu này vào SystemSettings ---
INSERT INTO SystemSettings (SettingKey, SettingValue)
VALUES ('ShiftRegistration', 'OFF');
-- Thêm cái đống dữ liệu này vào Staff Salary ---
INSERT INTO StaffSalary (StaffID, HourlyRate, UpdatedAt)
VALUES 
(1, 18000, GETDATE()),
(2, 20000, GETDATE()),
(3, 25000, GETDATE());
