-- Script tạo lại bảng Pet cho khớp với model
USE [SHOP_PET_Database]
GO

-- Xóa bảng Pet cũ nếu tồn tại
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Pet')
BEGIN
    PRINT 'Đang xóa bảng Pet cũ...'
    DROP TABLE [Pet]
    PRINT 'Đã xóa bảng Pet cũ'
END

-- Tạo lại bảng Pet mới cho khớp với model
CREATE TABLE [Pet] (
    [id] INT IDENTITY(1,1) PRIMARY KEY,
    [customer_id] INT NOT NULL,
    [pet_name] NVARCHAR(100) NOT NULL,
    [species] NVARCHAR(50) NOT NULL,
    [breed] NVARCHAR(100) NOT NULL,
    [age] INT NOT NULL,
    [gender] NVARCHAR(10) CHECK (gender IN ('male', 'female')) NOT NULL,
    [description] NVARCHAR(MAX),
    [health_status] NVARCHAR(MAX),
    [image_path] NVARCHAR(255),
    [created_at] DATETIME DEFAULT GETDATE(),
    [updated_at] DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Pet_Customer FOREIGN KEY (customer_id)
        REFERENCES Customer(customer_id)
        ON DELETE CASCADE
);

PRINT 'Đã tạo bảng Pet mới'

-- Tạo index cho customer_id
CREATE INDEX idx_pet_customer_id ON Pet(customer_id);
PRINT 'Đã tạo index idx_pet_customer_id'

-- Tạo trigger để tự động cập nhật updated_at
IF NOT EXISTS (
    SELECT * FROM sys.triggers WHERE name = 'trg_UpdatePetTimestamp'
)
BEGIN
    EXEC('
        CREATE TRIGGER trg_UpdatePetTimestamp
        ON Pet
        AFTER UPDATE
        AS
        BEGIN
            SET NOCOUNT ON;
            UPDATE p
            SET updated_at = GETDATE()
            FROM Pet p
            INNER JOIN inserted i ON p.id = i.id;
        END
    ')
    PRINT 'Đã tạo trigger trg_UpdatePetTimestamp'
END

-- Kiểm tra cấu trúc bảng mới
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE,
    CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'Pet'
ORDER BY ORDINAL_POSITION

PRINT 'Hoàn thành tạo lại bảng Pet'
