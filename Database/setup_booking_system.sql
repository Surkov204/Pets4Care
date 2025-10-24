USE SHOP_PET_Database
GO

PRINT '=========================================='
PRINT 'SETUP HỆ THỐNG BOOKING - VỚI XỬ LÝ FOREIGN KEY'
PRINT '=========================================='
PRINT ''

-- =============================================
-- BƯỚC 1: TẮT FOREIGN KEY CONSTRAINTS
-- =============================================
PRINT '→ Tắt tất cả Foreign Key Constraints...'
EXEC sp_MSforeachtable 'ALTER TABLE ? NOCHECK CONSTRAINT ALL'
PRINT '  ✓ Đã tắt constraints'
PRINT ''

-- =============================================
-- BƯỚC 2: XÓA CÁC BẢNG CŨ (THEO THỨ TỰ)
-- =============================================
PRINT '→ Xóa các bảng cũ nếu tồn tại...'

-- Xóa bảng con trước (có foreign key)
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Booking_Service')
BEGIN
    DROP TABLE Booking_Service
    PRINT '  ✓ Đã xóa bảng Booking_Service'
END

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Booking')
BEGIN
    DROP TABLE Booking
    PRINT '  ✓ Đã xóa bảng Booking'
END

-- Xóa bảng cha sau
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'PetService')
BEGIN
    DROP TABLE PetService
    PRINT '  ✓ Đã xóa bảng PetService'
END

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Doctor')
BEGIN
    DROP TABLE Doctor
    PRINT '  ✓ Đã xóa bảng Doctor'
END

PRINT ''

-- =============================================
-- BƯỚC 3: TẠO BẢNG DOCTOR
-- =============================================
PRINT '→ Tạo bảng Doctor...'

CREATE TABLE Doctor (
    doctor_id INT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(100) NOT NULL,
    email NVARCHAR(100) UNIQUE,
    phone NVARCHAR(20),
    specialization NVARCHAR(100),
    description NVARCHAR(MAX),
    status NVARCHAR(20) DEFAULT 'active',
    created_at DATETIME DEFAULT GETDATE()
)

PRINT '  ✓ Bảng Doctor đã được tạo'
PRINT ''
GO

-- =============================================
-- BƯỚC 4: TẠO BẢNG PETSERVICE
-- =============================================
PRINT '→ Tạo bảng PetService...'

CREATE TABLE PetService (
    service_id INT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(200) NOT NULL,
    description NVARCHAR(MAX),
    price DECIMAL(10,2) NOT NULL,
    duration INT NOT NULL,
    service_type NVARCHAR(50) NOT NULL,
    status NVARCHAR(20) DEFAULT 'active',
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE()
)

PRINT '  ✓ Bảng PetService đã được tạo'
PRINT ''
GO

-- =============================================
-- BƯỚC 5: TẠO BẢNG BOOKING
-- =============================================
PRINT '→ Tạo bảng Booking...'

CREATE TABLE Booking (
    booking_id INT IDENTITY(1,1) PRIMARY KEY,
    customer_id INT NOT NULL,
    pet_id INT NOT NULL,
    appointment_start DATETIME NOT NULL,
    appointment_end DATETIME NOT NULL,
    status NVARCHAR(50) NOT NULL DEFAULT 'pending',
    note NVARCHAR(MAX),
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE(),
    doctor_id INT NULL,
    staff_id INT NULL,
    order_id INT NULL,
    
    CONSTRAINT FK_Booking_Customer FOREIGN KEY (customer_id)
        REFERENCES Customer(customer_id)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,
    
    CONSTRAINT FK_Booking_Pet FOREIGN KEY (pet_id)
        REFERENCES PET(id)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,
        
    CONSTRAINT FK_Booking_Doctor FOREIGN KEY (doctor_id)
        REFERENCES Doctor(doctor_id)
        ON DELETE SET NULL
        ON UPDATE NO ACTION,
        
    CONSTRAINT FK_Booking_Staff FOREIGN KEY (staff_id)
        REFERENCES Staff(staff_id)
        ON DELETE SET NULL
        ON UPDATE NO ACTION
)

-- Tạo indexes
CREATE INDEX idx_booking_customer_id ON Booking(customer_id)
CREATE INDEX idx_booking_pet_id ON Booking(pet_id)
CREATE INDEX idx_booking_status ON Booking(status)
CREATE INDEX idx_booking_appointment ON Booking(appointment_start, appointment_end)
CREATE INDEX idx_booking_doctor_id ON Booking(doctor_id)

PRINT '  ✓ Bảng Booking đã được tạo'
PRINT '  ✓ Indexes đã được tạo'
PRINT ''
GO

-- =============================================
-- BƯỚC 6: TẠO BẢNG BOOKING_SERVICE
-- =============================================
PRINT '→ Tạo bảng Booking_Service...'

CREATE TABLE Booking_Service (
    booking_service_id INT IDENTITY(1,1) PRIMARY KEY,
    booking_id INT NOT NULL,
    service_id INT NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    price DECIMAL(10,2) NOT NULL,
    note NVARCHAR(MAX),
    
    CONSTRAINT FK_BookingService_Booking FOREIGN KEY (booking_id)
        REFERENCES Booking(booking_id)
        ON DELETE CASCADE
        ON UPDATE NO ACTION,
        
    CONSTRAINT FK_BookingService_Service FOREIGN KEY (service_id)
        REFERENCES PetService(service_id)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION
)

-- Tạo indexes
CREATE INDEX idx_booking_service_booking_id ON Booking_Service(booking_id)
CREATE INDEX idx_booking_service_service_id ON Booking_Service(service_id)

PRINT '  ✓ Bảng Booking_Service đã được tạo'
PRINT '  ✓ Indexes đã được tạo'
PRINT ''
GO

-- =============================================
-- BƯỚC 7: BẬT LẠI FOREIGN KEY CONSTRAINTS
-- =============================================
PRINT '→ Bật lại Foreign Key Constraints...'
EXEC sp_MSforeachtable 'ALTER TABLE ? WITH CHECK CHECK CONSTRAINT ALL'
PRINT '  ✓ Đã bật constraints'
PRINT ''
GO

-- =============================================
-- BƯỚC 8: TẠO TRIGGERS
-- =============================================
PRINT '→ Tạo triggers...'

-- Xóa trigger cũ nếu tồn tại
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_UpdateBookingTimestamp')
    DROP TRIGGER trg_UpdateBookingTimestamp
GO

-- Tạo trigger mới cho Booking
CREATE TRIGGER trg_UpdateBookingTimestamp
ON Booking
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE b
    SET updated_at = GETDATE()
    FROM Booking b
    INNER JOIN inserted i ON b.booking_id = i.booking_id
END
GO

PRINT '  ✓ Trigger trg_UpdateBookingTimestamp đã được tạo'

-- Xóa trigger cũ nếu tồn tại
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_UpdatePetServiceTimestamp')
    DROP TRIGGER trg_UpdatePetServiceTimestamp
GO

-- Tạo trigger mới cho PetService
CREATE TRIGGER trg_UpdatePetServiceTimestamp
ON PetService
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE ps
    SET updated_at = GETDATE()
    FROM PetService ps
    INNER JOIN inserted i ON ps.service_id = i.service_id
END
GO

PRINT '  ✓ Trigger trg_UpdatePetServiceTimestamp đã được tạo'
PRINT ''

-- =============================================
-- BƯỚC 9: INSERT DỮ LIỆU MẪU
-- =============================================
PRINT '→ Thêm dữ liệu mẫu...'
PRINT ''

-- Insert Doctors
PRINT '  → Thêm bác sĩ...'
INSERT INTO Doctor (name, email, phone, specialization, description, status) VALUES
(N'BS. Nguyễn Minh Anh', 'minhanh.nguyen@pets4care.com', '0901234561', N'Da liễu & chăm sóc lông', N'10 năm kinh nghiệm điều trị bệnh da và lông', 'active'),
(N'BS. Trần Văn Cường', 'vancuong.tran@pets4care.com', '0901234562', N'Phẫu thuật & chỉnh hình', N'15 năm kinh nghiệm phẫu thuật', 'active'),
(N'BS. Lê Thị Mai', 'thimai.le@pets4care.com', '0901234563', N'Tim mạch & hô hấp', N'8 năm kinh nghiệm tim mạch', 'active'),
(N'BS. Phạm Đức Minh', 'ducminh.pham@pets4care.com', '0901234564', N'Tiêu hóa & dinh dưỡng', N'12 năm kinh nghiệm tiêu hóa', 'active'),
(N'BS. Võ Thị Hương', 'thihuong.vo@pets4care.com', '0901234565', N'Sản khoa & sinh sản', N'10 năm kinh nghiệm sản khoa', 'active'),
(N'BS. Đặng Văn Tùng', 'vantung.dang@pets4care.com', '0901234566', N'Thần kinh & hành vi', N'7 năm kinh nghiệm thần kinh', 'active')
PRINT '    ✓ Đã thêm 6 bác sĩ'

-- Insert Health Check Services
PRINT '  → Thêm dịch vụ khám sức khỏe...'
INSERT INTO PetService (name, description, price, duration, service_type, status) VALUES
(N'Khám sức khỏe tổng quát', N'Kiểm tra sức khỏe tổng quát: khám lâm sàng, đo nhiệt độ, mạch, nhịp thở', 200000, 30, 'health_check', 'active'),
(N'Khám chuyên sâu', N'Khám chuyên sâu: xét nghiệm máu, nước tiểu, X-quang', 500000, 60, 'health_check', 'active'),
(N'Khám định kỳ', N'Khám định kỳ 6 tháng/1 lần: kiểm tra cơ bản', 150000, 20, 'health_check', 'active'),
(N'Tiêm phòng cơ bản', N'Tiêm phòng: dại, viêm gan, parvo, distemper', 300000, 20, 'health_check', 'active'),
(N'Tư vấn dinh dưỡng', N'Tư vấn chế độ dinh dưỡng phù hợp', 100000, 30, 'health_check', 'active')
PRINT '    ✓ Đã thêm 5 dịch vụ khám sức khỏe'

-- Insert Spa Services
PRINT '  → Thêm dịch vụ spa...'
INSERT INTO PetService (name, description, price, duration, service_type, status) VALUES
(N'Tắm + Vệ sinh cơ bản', N'Tắm, sấy, cắt móng, vệ sinh tai', 150000, 45, 'spa', 'active'),
(N'Cắt tỉa lông chuyên nghiệp', N'Cắt tỉa lông theo kiểu dáng chuyên nghiệp', 300000, 90, 'spa', 'active'),
(N'Spa cao cấp', N'Spa: tắm tinh dầu, massage, dưỡng lông', 500000, 120, 'spa', 'active'),
(N'Vệ sinh răng miệng', N'Vệ sinh răng miệng, lấy cao răng', 200000, 30, 'spa', 'active')
PRINT '    ✓ Đã thêm 4 dịch vụ spa'

PRINT ''
PRINT '=========================================='
PRINT '✅ HOÀN THÀNH SETUP HỆ THỐNG BOOKING'
PRINT '=========================================='
PRINT ''

-- =============================================
-- BƯỚC 10: KIỂM TRA KẾT QUẢ
-- =============================================
PRINT '📊 THỐNG KÊ DỮ LIỆU:'

DECLARE @DoctorCount INT, @ServiceCount INT, @HealthCheckCount INT, @SpaCount INT

SELECT @DoctorCount = COUNT(*) FROM Doctor
SELECT @ServiceCount = COUNT(*) FROM PetService
SELECT @HealthCheckCount = COUNT(*) FROM PetService WHERE service_type = 'health_check'
SELECT @SpaCount = COUNT(*) FROM PetService WHERE service_type = 'spa'

PRINT '  → Bác sĩ: ' + CAST(@DoctorCount AS VARCHAR) + ' records'
PRINT '  → Tổng dịch vụ: ' + CAST(@ServiceCount AS VARCHAR) + ' records'
PRINT '  → Dịch vụ khám: ' + CAST(@HealthCheckCount AS VARCHAR) + ' records'
PRINT '  → Dịch vụ spa: ' + CAST(@SpaCount AS VARCHAR) + ' records'

PRINT ''
PRINT '=========================================='
PRINT '🎉 SẴN SÀNG SỬ DỤNG!'
PRINT '=========================================='
PRINT ''
PRINT '📝 BƯỚC TIẾP THEO:'
PRINT '  1. Clean and Build project trong NetBeans'
PRINT '  2. Restart server'
PRINT '  3. Test chức năng đặt lịch'
PRINT ''

-- Hiển thị dữ liệu
PRINT '📋 DANH SÁCH BÁC SĨ:'
SELECT doctor_id, name, specialization, phone FROM Doctor ORDER BY doctor_id
PRINT ''

PRINT '📋 DANH SÁCH DỊCH VỤ:'
SELECT service_id, name, price, duration, service_type FROM PetService ORDER BY service_type, service_id
PRINT ''

PRINT '=========================================='
PRINT 'KẾT THÚC SCRIPT'
PRINT '=========================================='

