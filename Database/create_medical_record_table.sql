-- Script tạo bảng MedicalRecord cho SQL Server
-- Bảng này lưu thông tin chi tiết về hồ sơ y tế của thú cưng sau mỗi lần khám

USE [SHOP_PET_Database]
GO

-- Tạo bảng MedicalRecord nếu chưa tồn tại
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

