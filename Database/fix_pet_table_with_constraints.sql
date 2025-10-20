-- Script sửa bảng Pet với xử lý foreign key constraints
USE [SHOP_PET_Database]
GO

PRINT '=== BẮT ĐẦU SỬA BẢNG PET VỚI XỬ LÝ CONSTRAINTS ==='

-- 1. Kiểm tra các foreign key constraints tham chiếu đến bảng Pet
PRINT 'Kiểm tra các foreign key constraints...'

SELECT 
    fk.name AS constraint_name,
    tp.name AS parent_table,
    cp.name AS parent_column,
    tr.name AS referenced_table,
    cr.name AS referenced_column
FROM sys.foreign_keys fk
INNER JOIN sys.tables tp ON fk.parent_object_id = tp.object_id
INNER JOIN sys.tables tr ON fk.referenced_object_id = tr.object_id
INNER JOIN sys.foreign_key_columns fkc ON fk.object_id = fkc.constraint_object_id
INNER JOIN sys.columns cp ON fkc.parent_object_id = cp.object_id AND fkc.parent_column_id = cp.column_id
INNER JOIN sys.columns cr ON fkc.referenced_object_id = cr.object_id AND fkc.referenced_column_id = cr.column_id
WHERE tr.name = 'Pet'

-- 2. Xóa các foreign key constraints tham chiếu đến bảng Pet
DECLARE @sql NVARCHAR(MAX) = ''

SELECT @sql = @sql + 'ALTER TABLE ' + tp.name + ' DROP CONSTRAINT ' + fk.name + ';' + CHAR(13)
FROM sys.foreign_keys fk
INNER JOIN sys.tables tp ON fk.parent_object_id = tp.object_id
INNER JOIN sys.tables tr ON fk.referenced_object_id = tr.object_id
WHERE tr.name = 'Pet'

IF @sql != ''
BEGIN
    PRINT 'Đang xóa các foreign key constraints...'
    PRINT @sql
    EXEC sp_executesql @sql
    PRINT 'Đã xóa các foreign key constraints'
END
ELSE
BEGIN
    PRINT 'Không có foreign key constraints nào tham chiếu đến bảng Pet'
END

-- 3. Xóa bảng Pet cũ
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Pet')
BEGIN
    PRINT 'Đang xóa bảng Pet cũ...'
    DROP TABLE [Pet]
    PRINT 'Đã xóa bảng Pet cũ'
END

-- 4. Tạo lại bảng Pet mới
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

-- 5. Tạo index cho customer_id
CREATE INDEX idx_pet_customer_id ON Pet(customer_id);
PRINT 'Đã tạo index idx_pet_customer_id'

-- 6. Tạo trigger để tự động cập nhật updated_at
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

-- 7. Thêm dữ liệu mẫu nếu có customer
IF EXISTS (SELECT * FROM Customer)
BEGIN
    DECLARE @customer_id INT
    SELECT TOP 1 @customer_id = customer_id FROM Customer
    
    IF @customer_id IS NOT NULL
    BEGIN
        INSERT INTO Pet (customer_id, pet_name, species, breed, age, gender, description, health_status, image_path)
        VALUES 
            (@customer_id, N'Mít', N'Chó', N'Poodle', 3, 'male', N'Chó con dễ thương, thích chơi đùa', N'Khỏe mạnh', 'images/pets/mit.jpg'),
            (@customer_id, N'Mèo Mun', N'Mèo', N'Mèo ta', 2, 'female', N'Mèo con hiền lành, thích nằm nắng', N'Bị dị ứng nhẹ', 'images/pets/meo_mun.jpg')
        
        PRINT 'Đã thêm dữ liệu mẫu'
    END
END

-- 8. Kiểm tra kết quả
PRINT '=== KIỂM TRA KẾT QUẢ ==='

-- Kiểm tra cấu trúc bảng
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE,
    CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'Pet'
ORDER BY ORDINAL_POSITION

-- Kiểm tra dữ liệu
SELECT COUNT(*) as 'Số lượng pet' FROM Pet

-- Hiển thị dữ liệu
SELECT TOP 5 * FROM Pet

PRINT '=== HOÀN THÀNH SỬA BẢNG PET ==='
