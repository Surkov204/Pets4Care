-- ==========================================
-- THIẾT LẬP LỊCH LÀM VIỆC CHO BÁC SĨ - HOÀN CHỈNH
-- ==========================================
-- Script này sẽ:
-- 1. Tạo bảng Shifts (nếu chưa có)
-- 2. Tạo bảng WorkSchedule (nếu chưa có)
-- 3. Thêm dữ liệu mẫu lịch làm việc cho bác sĩ
-- ==========================================

USE SHOP_PET_Database;
GO

PRINT N'==========================================';
PRINT N'BƯỚC 1: TẠO BẢNG SHIFTS';
PRINT N'==========================================';

-- Kiểm tra và tạo bảng Shifts nếu chưa có
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Shifts')
BEGIN
    PRINT N'→ Tạo bảng Shifts...';
    
    CREATE TABLE Shifts (
        ShiftID INT IDENTITY(1,1) PRIMARY KEY,
        ShiftCode NVARCHAR(20) UNIQUE NOT NULL,
        ShiftName NVARCHAR(100),
        StartTime TIME NOT NULL,
        EndTime TIME NOT NULL,
        BreakMinutes INT DEFAULT 0,
        Location NVARCHAR(255)
    );
    
    -- Thêm dữ liệu mẫu cho các ca
    INSERT INTO Shifts (ShiftCode, ShiftName, StartTime, EndTime, BreakMinutes, Location)
    VALUES
        ('S1', N'Ca sáng', '08:00:00', '12:00:00', 15, N'Phòng khám chính'),
        ('S2', N'Ca chiều', '13:00:00', '17:00:00', 15, N'Phòng khám chính'),
        ('S3', N'Ca tối', '18:00:00', '22:00:00', 15, N'Phòng khám chính');
    
    PRINT N'✅ Đã tạo bảng Shifts với 3 ca làm việc';
END
ELSE
BEGIN
    PRINT N'✓ Bảng Shifts đã tồn tại';
    
    -- Đảm bảo có đủ 3 ca
    IF NOT EXISTS (SELECT * FROM Shifts WHERE ShiftCode = 'S1')
        INSERT INTO Shifts (ShiftCode, ShiftName, StartTime, EndTime, BreakMinutes, Location)
        VALUES ('S1', N'Ca sáng', '08:00:00', '12:00:00', 15, N'Phòng khám chính');
    
    IF NOT EXISTS (SELECT * FROM Shifts WHERE ShiftCode = 'S2')
        INSERT INTO Shifts (ShiftCode, ShiftName, StartTime, EndTime, BreakMinutes, Location)
        VALUES ('S2', N'Ca chiều', '13:00:00', '17:00:00', 15, N'Phòng khám chính');
    
    IF NOT EXISTS (SELECT * FROM Shifts WHERE ShiftCode = 'S3')
        INSERT INTO Shifts (ShiftCode, ShiftName, StartTime, EndTime, BreakMinutes, Location)
        VALUES ('S3', N'Ca tối', '18:00:00', '22:00:00', 15, N'Phòng khám chính');
    
    PRINT N'✓ Đã kiểm tra và bổ sung dữ liệu Shifts';
END
GO

PRINT N'';
PRINT N'==========================================';
PRINT N'BƯỚC 2: TẠO BẢNG WORKSCHEDULE';
PRINT N'==========================================';

-- Kiểm tra và tạo bảng WorkSchedule nếu chưa có
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'WorkSchedule')
BEGIN
    PRINT N'→ Tạo bảng WorkSchedule...';
    
    CREATE TABLE WorkSchedule (
        schedule_id INT IDENTITY(1,1) PRIMARY KEY,
        doctor_id INT NULL,
        staff_id INT NULL,
        shift_id INT NULL,
        work_date DATE NOT NULL,
        start_time TIME NOT NULL,
        end_time TIME NOT NULL,
        status NVARCHAR(50) DEFAULT 'Scheduled',
        note NVARCHAR(MAX),
        created_at DATETIME DEFAULT GETDATE(),
        
        -- Foreign Keys
        CONSTRAINT FK_WorkSchedule_Doctor FOREIGN KEY (doctor_id)
            REFERENCES Doctor(doctor_id)
            ON DELETE CASCADE,
            
        CONSTRAINT FK_WorkSchedule_Staff FOREIGN KEY (staff_id)
            REFERENCES Staff(staff_id)
            ON DELETE CASCADE,
            
        CONSTRAINT FK_WorkSchedule_Shift FOREIGN KEY (shift_id)
            REFERENCES Shifts(ShiftID)
            ON DELETE SET NULL
    );
    
    -- Tạo indexes
    CREATE INDEX idx_workschedule_doctor ON WorkSchedule(doctor_id);
    CREATE INDEX idx_workschedule_staff ON WorkSchedule(staff_id);
    CREATE INDEX idx_workschedule_date ON WorkSchedule(work_date);
    CREATE INDEX idx_workschedule_shift ON WorkSchedule(shift_id);
    
    PRINT N'✅ Đã tạo bảng WorkSchedule và indexes';
END
ELSE
BEGIN
    PRINT N'✓ Bảng WorkSchedule đã tồn tại';
    
    -- Kiểm tra và thêm cột nếu thiếu
    IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
                   WHERE TABLE_NAME = 'WorkSchedule' AND COLUMN_NAME = 'doctor_id')
    BEGIN
        ALTER TABLE WorkSchedule ADD doctor_id INT NULL;
        PRINT N'  ✓ Đã thêm cột doctor_id';
    END
    
    IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
                   WHERE TABLE_NAME = 'WorkSchedule' AND COLUMN_NAME = 'shift_id')
    BEGIN
        ALTER TABLE WorkSchedule ADD shift_id INT NULL;
        PRINT N'  ✓ Đã thêm cột shift_id';
    END
    
    IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
                   WHERE TABLE_NAME = 'WorkSchedule' AND COLUMN_NAME = 'status')
    BEGIN
        ALTER TABLE WorkSchedule ADD status NVARCHAR(50) DEFAULT 'Scheduled';
        PRINT N'  ✓ Đã thêm cột status';
    END
END
GO

PRINT N'';
PRINT N'==========================================';
PRINT N'BƯỚC 3: TẠO DỮ LIỆU MẪU LỊCH LÀM VIỆC';
PRINT N'==========================================';

-- Xóa lịch cũ của doctor (nếu có)
DELETE FROM WorkSchedule WHERE doctor_id IS NOT NULL;
PRINT N'→ Đã xóa lịch làm việc cũ của bác sĩ';
GO

-- Lấy doctor_id của bác sĩ test (email: doctor@test.com)
DECLARE @doctorId INT;
SELECT @doctorId = doctor_id FROM Doctor WHERE email = 'doctor@test.com';

IF @doctorId IS NULL
BEGIN
    PRINT N'';
    PRINT N'❌ KHÔNG TÌM THẤY BÁC SĨ TEST!';
    PRINT N'   Vui lòng chạy script: Database/fix_doctor_simple.sql';
    PRINT N'   để tạo tài khoản bác sĩ test trước.';
    PRINT N'';
END
ELSE
BEGIN
    PRINT N'✓ Tìm thấy Doctor ID: ' + CAST(@doctorId AS NVARCHAR(10));
    PRINT N'';
    
    -- Tạo lịch làm việc cho tuần này và tuần sau
    DECLARE @currentDate DATE = CAST(GETDATE() AS DATE);
    DECLARE @startOfWeek DATE;
    
    -- Tính ngày thứ 2 tuần này
    SET @startOfWeek = DATEADD(DAY, 1 - DATEPART(WEEKDAY, @currentDate), @currentDate);
    
    PRINT N'📅 Tuần bắt đầu: ' + CAST(@startOfWeek AS NVARCHAR(20));
    PRINT N'→ Đang tạo lịch làm việc...';
    PRINT N'';
    
    -- ==========================================
    -- TUẦN 1: Tuần hiện tại
    -- ==========================================
    
    -- Thứ 2, 4, 6 - Ca sáng (8h-12h)
    INSERT INTO WorkSchedule (doctor_id, shift_id, work_date, start_time, end_time, status, note)
    VALUES 
        (@doctorId, 1, @startOfWeek, '08:00:00', '12:00:00', 'Scheduled', N'Ca sáng thứ 2'),
        (@doctorId, 1, DATEADD(DAY, 2, @startOfWeek), '08:00:00', '12:00:00', 'Scheduled', N'Ca sáng thứ 4'),
        (@doctorId, 1, DATEADD(DAY, 4, @startOfWeek), '08:00:00', '12:00:00', 'Scheduled', N'Ca sáng thứ 6');
    
    PRINT N'  ✓ Đã tạo 3 ca sáng (Thứ 2, 4, 6)';
    
    -- Thứ 3, 5 - Ca chiều (13h-17h)
    INSERT INTO WorkSchedule (doctor_id, shift_id, work_date, start_time, end_time, status, note)
    VALUES 
        (@doctorId, 2, DATEADD(DAY, 1, @startOfWeek), '13:00:00', '17:00:00', 'Scheduled', N'Ca chiều thứ 3'),
        (@doctorId, 2, DATEADD(DAY, 3, @startOfWeek), '13:00:00', '17:00:00', 'Scheduled', N'Ca chiều thứ 5');
    
    PRINT N'  ✓ Đã tạo 2 ca chiều (Thứ 3, 5)';
    
    -- Thứ 7 - Ca sáng + chiều (8h-12h, 13h-17h)
    INSERT INTO WorkSchedule (doctor_id, shift_id, work_date, start_time, end_time, status, note)
    VALUES 
        (@doctorId, 1, DATEADD(DAY, 5, @startOfWeek), '08:00:00', '12:00:00', 'Scheduled', N'Ca sáng thứ 7'),
        (@doctorId, 2, DATEADD(DAY, 5, @startOfWeek), '13:00:00', '17:00:00', 'Scheduled', N'Ca chiều thứ 7');
    
    PRINT N'  ✓ Đã tạo 2 ca cho thứ 7 (Sáng + Chiều)';
    PRINT N'  → Tổng tuần 1: 7 ca làm việc';
    PRINT N'';
    
    -- ==========================================
    -- TUẦN 2: Tuần sau
    -- ==========================================
    
    DECLARE @nextWeek DATE = DATEADD(WEEK, 1, @startOfWeek);
    PRINT N'📅 Tuần sau bắt đầu: ' + CAST(@nextWeek AS NVARCHAR(20));
    PRINT N'→ Đang tạo lịch cho tuần sau...';
    PRINT N'';
    
    INSERT INTO WorkSchedule (doctor_id, shift_id, work_date, start_time, end_time, status, note)
    VALUES 
        -- Thứ 2 - Ca sáng
        (@doctorId, 1, @nextWeek, '08:00:00', '12:00:00', 'Scheduled', N'Ca sáng thứ 2'),
        -- Thứ 3 - Ca chiều
        (@doctorId, 2, DATEADD(DAY, 1, @nextWeek), '13:00:00', '17:00:00', 'Scheduled', N'Ca chiều thứ 3'),
        -- Thứ 4 - Ca sáng
        (@doctorId, 1, DATEADD(DAY, 2, @nextWeek), '08:00:00', '12:00:00', 'Scheduled', N'Ca sáng thứ 4'),
        -- Thứ 5 - Ca tối
        (@doctorId, 3, DATEADD(DAY, 3, @nextWeek), '18:00:00', '22:00:00', 'Scheduled', N'Ca tối thứ 5'),
        -- Thứ 6 - Ca chiều
        (@doctorId, 2, DATEADD(DAY, 4, @nextWeek), '13:00:00', '17:00:00', 'Scheduled', N'Ca chiều thứ 6');
    
    PRINT N'  ✓ Đã tạo 5 ca cho tuần sau';
    PRINT N'  → Tổng tuần 2: 5 ca làm việc';
    PRINT N'';
    PRINT N'✅ Tổng cộng: 12 ca làm việc cho 2 tuần';
END
GO

PRINT N'';
PRINT N'==========================================';
PRINT N'BƯỚC 4: HIỂN THỊ LỊCH ĐÃ TẠO';
PRINT N'==========================================';

-- Hiển thị lịch đã tạo
SELECT 
    ws.schedule_id AS [ID],
    d.name AS [Bác sĩ],
    FORMAT(ws.work_date, 'dd/MM/yyyy (dddd)', 'vi-VN') AS [Ngày làm việc],
    s.ShiftName AS [Ca làm],
    CONVERT(VARCHAR(5), ws.start_time, 108) AS [Giờ bắt đầu],
    CONVERT(VARCHAR(5), ws.end_time, 108) AS [Giờ kết thúc],
    ws.status AS [Trạng thái],
    ws.note AS [Ghi chú]
FROM WorkSchedule ws
JOIN Doctor d ON ws.doctor_id = d.doctor_id
LEFT JOIN Shifts s ON ws.shift_id = s.ShiftID
WHERE ws.doctor_id IS NOT NULL
ORDER BY ws.work_date, ws.start_time;

PRINT N'';
PRINT N'==========================================';
PRINT N'✅ HOÀN TẤT THIẾT LẬP!';
PRINT N'==========================================';
PRINT N'';
PRINT N'📋 Thông tin đăng nhập:';
PRINT N'   Email: doctor@test.com';
PRINT N'   Password: doctor123';
PRINT N'';
PRINT N'🌐 Truy cập trang lịch làm việc:';
PRINT N'   URL: /doctor/work-schedule';
PRINT N'';
PRINT N'📝 Bước tiếp theo:';
PRINT N'   1. Build project: ant clean dist';
PRINT N'   2. Run server: ant run';
PRINT N'   3. Login và test chức năng';
PRINT N'';
PRINT N'==========================================';

