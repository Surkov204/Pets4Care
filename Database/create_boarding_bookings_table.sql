-- Script tạo bảng boarding_bookings cho SQL Server
USE [SHOP_PET_Database]
GO

-- Tạo bảng boarding_bookings nếu chưa tồn tại
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'boarding_bookings')
BEGIN
    CREATE TABLE dbo.boarding_bookings (
        booking_id INT IDENTITY(1,1) PRIMARY KEY,
        customer_id INT NOT NULL,
        room_type NVARCHAR(100) NOT NULL,
        price_per_day DECIMAL(10,2) NOT NULL,
        boarding_days INT NOT NULL,
        check_in_date DATE NOT NULL,
        check_out_date DATE NOT NULL,
        check_in_time NVARCHAR(10) DEFAULT '08:00',
        check_out_time NVARCHAR(10) DEFAULT '17:00',
        pet_info NVARCHAR(MAX),
        special_notes NVARCHAR(MAX),
        emergency_phone1 NVARCHAR(20) NOT NULL,
        emergency_phone2 NVARCHAR(20),
        total_price DECIMAL(10,2) NOT NULL DEFAULT 0,
        status NVARCHAR(20) DEFAULT 'pending',
        created_at DATETIME2 DEFAULT GETDATE(),
        updated_at DATETIME2 DEFAULT GETDATE()
    )
    
    PRINT 'Table boarding_bookings created successfully'
END
ELSE
BEGIN
    PRINT 'Table boarding_bookings already exists'
    
    -- Thêm cột total_price nếu chưa có
    IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
                   WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'boarding_bookings' AND COLUMN_NAME = 'total_price')
    BEGIN
        ALTER TABLE dbo.boarding_bookings
        ADD total_price DECIMAL(10,2) NOT NULL DEFAULT 0
        
        PRINT 'Column total_price added successfully'
    END
    ELSE
    BEGIN
        PRINT 'Column total_price already exists'
    END
END
GO

-- Tạo foreign key constraint nếu chưa có
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'fk_boarding_customer')
BEGIN
    ALTER TABLE dbo.boarding_bookings
    ADD CONSTRAINT fk_boarding_customer
    FOREIGN KEY (customer_id) REFERENCES dbo.Customer(customer_id)
    ON DELETE CASCADE ON UPDATE CASCADE
    
    PRINT 'Foreign key constraint fk_boarding_customer added successfully'
END
ELSE
BEGIN
    PRINT 'Foreign key constraint fk_boarding_customer already exists'
END
GO

-- Tạo trigger để tự động cập nhật updated_at
IF NOT EXISTS (SELECT * FROM sys.triggers WHERE name = 'tr_boarding_bookings_update')
BEGIN
    EXEC('
    CREATE TRIGGER tr_boarding_bookings_update
    ON dbo.boarding_bookings
    AFTER UPDATE
    AS
    BEGIN
        SET NOCOUNT ON;
        UPDATE dbo.boarding_bookings
        SET updated_at = GETDATE()
        FROM dbo.boarding_bookings bb
        INNER JOIN inserted i ON bb.booking_id = i.booking_id
    END
    ')
    
    PRINT 'Trigger tr_boarding_bookings_update created successfully'
END
ELSE
BEGIN
    PRINT 'Trigger tr_boarding_bookings_update already exists'
END
GO

-- Kiểm tra bảng đã tạo thành công
SELECT 
    TABLE_NAME,
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE,
    COLUMN_DEFAULT
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_SCHEMA = 'dbo' 
AND TABLE_NAME = 'boarding_bookings'
ORDER BY ORDINAL_POSITION

PRINT 'Script completed successfully'

