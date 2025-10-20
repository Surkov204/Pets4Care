-- Script xử lý lỗi FOREIGN KEY constraint khi xóa bảng PetService
-- Chạy script này để xóa và tạo lại bảng PetService

USE SHOP_PET_Database;

-- Bước 1: Kiểm tra các bảng đang tham chiếu đến PetService
PRINT '=== KIỂM TRA CÁC BẢNG THAM CHIẾU ===';
SELECT 
    OBJECT_NAME(f.parent_object_id) AS TableName,
    COL_NAME(fc.parent_object_id, fc.parent_column_id) AS ColumnName,
    OBJECT_NAME(f.referenced_object_id) AS ReferencedTableName,
    COL_NAME(fc.referenced_object_id, fc.referenced_column_id) AS ReferencedColumnName,
    f.name AS ForeignKeyName
FROM sys.foreign_keys AS f
INNER JOIN sys.foreign_key_columns AS fc ON f.object_id = fc.constraint_object_id
WHERE OBJECT_NAME(f.referenced_object_id) = 'PetService';

-- Bước 2: Xóa các khóa ngoại tham chiếu đến PetService
PRINT '=== XÓA CÁC KHÓA NGOẠI ===';

-- Xóa khóa ngoại từ BookingService (nếu tồn tại)
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name LIKE '%BookingService%PetService%')
BEGIN
    DECLARE @fk_name NVARCHAR(255);
    SELECT @fk_name = name FROM sys.foreign_keys WHERE name LIKE '%BookingService%PetService%';
    EXEC('ALTER TABLE BookingService DROP CONSTRAINT ' + @fk_name);
    PRINT 'Đã xóa khóa ngoại: ' + @fk_name;
END

-- Xóa khóa ngoại từ BookingServiceItem (nếu tồn tại)
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name LIKE '%BookingServiceItem%PetService%')
BEGIN
    DECLARE @fk_name2 NVARCHAR(255);
    SELECT @fk_name2 = name FROM sys.foreign_keys WHERE name LIKE '%BookingServiceItem%PetService%';
    EXEC('ALTER TABLE BookingServiceItem DROP CONSTRAINT ' + @fk_name2);
    PRINT 'Đã xóa khóa ngoại: ' + @fk_name2;
END

-- Xóa khóa ngoại từ bất kỳ bảng nào khác tham chiếu đến PetService
DECLARE @sql NVARCHAR(MAX) = '';
SELECT @sql = @sql + 'ALTER TABLE ' + OBJECT_NAME(f.parent_object_id) + ' DROP CONSTRAINT ' + f.name + ';' + CHAR(13)
FROM sys.foreign_keys AS f
WHERE OBJECT_NAME(f.referenced_object_id) = 'PetService';

IF @sql != ''
BEGIN
    EXEC sp_executesql @sql;
    PRINT 'Đã xóa tất cả khóa ngoại tham chiếu đến PetService';
END

-- Bước 3: Xóa dữ liệu từ các bảng con (nếu cần)
PRINT '=== XÓA DỮ LIỆU LIÊN QUAN ===';

-- Xóa dữ liệu từ BookingServiceItem (nếu tồn tại)
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'BookingServiceItem')
BEGIN
    DELETE FROM BookingServiceItem WHERE service_id IN (SELECT service_id FROM PetService);
    PRINT 'Đã xóa dữ liệu từ BookingServiceItem';
END

-- Xóa dữ liệu từ BookingService (nếu tồn tại)
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'BookingService')
BEGIN
    DELETE FROM BookingService WHERE service_id IN (SELECT service_id FROM PetService);
    PRINT 'Đã xóa dữ liệu từ BookingService';
END

-- Bước 4: Xóa bảng PetService
PRINT '=== XÓA BẢNG PETSERVICE ===';
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'PetService')
BEGIN
    DROP TABLE PetService;
    PRINT 'Đã xóa bảng PetService';
END
ELSE
BEGIN
    PRINT 'Bảng PetService không tồn tại';
END

-- Bước 5: Tạo lại bảng PetService
PRINT '=== TẠO LẠI BẢNG PETSERVICE ===';
CREATE TABLE PetService (
    service_id INT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(255) NOT NULL,
    service_type NVARCHAR(50) NOT NULL,
    description NVARCHAR(MAX),
    price DECIMAL(10,2) NOT NULL,
    duration INT NOT NULL,
    status NVARCHAR(20) DEFAULT 'active',
    image_path NVARCHAR(255),
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE()
);

-- Tạo index để tối ưu truy vấn
CREATE INDEX IX_PetService_Type ON PetService(service_type);
CREATE INDEX IX_PetService_Status ON PetService(status);
CREATE INDEX IX_PetService_Type_Status ON PetService(service_type, status);

PRINT 'Đã tạo lại bảng PetService với indexes';

-- Bước 6: Thêm dữ liệu mẫu
PRINT '=== THÊM DỮ LIỆU MẪU ===';

-- Thêm dịch vụ Spa
INSERT INTO PetService (name, service_type, description, price, duration, status) VALUES
('Spa Tắm Gội Cơ Bản', 'spa', 'Dịch vụ tắm gội cơ bản với dầu gội chuyên dụng cho thú cưng', 150000, 30, 'active'),
('Spa Tắm Gội Cao Cấp', 'spa', 'Dịch vụ tắm gội cao cấp với massage và chăm sóc da', 250000, 45, 'active'),
('Cắt Tỉa Lông', 'spa', 'Dịch vụ cắt tỉa lông theo phong cách hiện đại', 200000, 60, 'active'),
('Cắt Móng Chân', 'spa', 'Dịch vụ cắt móng chân an toàn và chuyên nghiệp', 80000, 15, 'active'),
('Vệ Sinh Tai', 'spa', 'Dịch vụ vệ sinh tai và kiểm tra sức khỏe tai', 100000, 20, 'active'),
('Vệ Sinh Răng', 'spa', 'Dịch vụ vệ sinh răng và massage nướu', 120000, 25, 'active'),
('Massage Thư Giãn', 'spa', 'Dịch vụ massage thư giãn giúp thú cưng thoải mái', 180000, 40, 'active'),
('Spa Package VIP', 'spa', 'Gói spa VIP bao gồm tất cả dịch vụ chăm sóc cao cấp', 500000, 120, 'active'),
('Tắm Thuốc Diệt Ký Sinh', 'spa', 'Dịch vụ tắm thuốc diệt ký sinh trùng', 300000, 35, 'active'),
('Chăm Sóc Da & Lông', 'spa', 'Dịch vụ chăm sóc da và lông chuyên sâu', 220000, 50, 'active');

-- Thêm dịch vụ Khám sức khỏe
INSERT INTO PetService (name, service_type, description, price, duration, status) VALUES
('Khám Sức Khỏe Tổng Quát', 'health_check', 'Khám sức khỏe tổng quát cho thú cưng', 200000, 30, 'active'),
('Khám Chuyên Sâu', 'health_check', 'Khám sức khỏe chuyên sâu với xét nghiệm', 400000, 60, 'active'),
('Tiêm Phòng', 'health_check', 'Dịch vụ tiêm phòng các loại vaccine', 150000, 20, 'active'),
('Xét Nghiệm Máu', 'health_check', 'Xét nghiệm máu để kiểm tra sức khỏe', 300000, 45, 'active'),
('Siêu Âm', 'health_check', 'Dịch vụ siêu âm kiểm tra nội tạng', 350000, 40, 'active');

PRINT 'Đã thêm ' + CAST(@@ROWCOUNT AS VARCHAR) + ' dịch vụ';

-- Bước 7: Tạo lại khóa ngoại (nếu cần)
PRINT '=== TẠO LẠI KHÓA NGOẠI ===';

-- Tạo khóa ngoại cho BookingServiceItem (nếu bảng tồn tại)
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'BookingServiceItem')
BEGIN
    IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_BookingServiceItem_PetService')
    BEGIN
        ALTER TABLE BookingServiceItem 
        ADD CONSTRAINT FK_BookingServiceItem_PetService 
        FOREIGN KEY (service_id) REFERENCES PetService(service_id)
        ON DELETE CASCADE;
        PRINT 'Đã tạo lại khóa ngoại FK_BookingServiceItem_PetService';
    END
END


