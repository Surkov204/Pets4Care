-- Script đơn giản để xóa và tạo lại bảng PetService
-- Chạy script này nếu gặp lỗi FOREIGN KEY constraint

USE SHOP_PET_Database;

-- Xóa tất cả khóa ngoại tham chiếu đến PetService
DECLARE @sql NVARCHAR(MAX) = '';
SELECT @sql = @sql + 'ALTER TABLE ' + OBJECT_NAME(f.parent_object_id) + ' DROP CONSTRAINT ' + f.name + ';' + CHAR(13)
FROM sys.foreign_keys AS f
WHERE OBJECT_NAME(f.referenced_object_id) = 'PetService';

IF @sql != ''
BEGIN
    EXEC sp_executesql @sql;
    PRINT 'Đã xóa các khóa ngoại tham chiếu đến PetService';
END

-- Xóa bảng PetService
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'PetService')
BEGIN
    DROP TABLE PetService;
    PRINT 'Đã xóa bảng PetService';
END

-- Tạo lại bảng PetService
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

-- Thêm dữ liệu mẫu
INSERT INTO PetService (name, service_type, description, price, duration, status) VALUES
-- Dịch vụ Spa
('Spa Tắm Gội Cơ Bản', 'spa', 'Dịch vụ tắm gội cơ bản với dầu gội chuyên dụng', 150000, 30, 'active'),
('Spa Tắm Gội Cao Cấp', 'spa', 'Dịch vụ tắm gội cao cấp với massage và chăm sóc da', 250000, 45, 'active'),
('Cắt Tỉa Lông', 'spa', 'Dịch vụ cắt tỉa lông theo phong cách hiện đại', 200000, 60, 'active'),
('Cắt Móng Chân', 'spa', 'Dịch vụ cắt móng chân an toàn và chuyên nghiệp', 80000, 15, 'active'),
('Vệ Sinh Tai', 'spa', 'Dịch vụ vệ sinh tai và kiểm tra sức khỏe tai', 100000, 20, 'active'),
('Vệ Sinh Răng', 'spa', 'Dịch vụ vệ sinh răng và massage nướu', 120000, 25, 'active'),
('Massage Thư Giãn', 'spa', 'Dịch vụ massage thư giãn giúp thú cưng thoải mái', 180000, 40, 'active'),
('Spa Package VIP', 'spa', 'Gói spa VIP bao gồm tất cả dịch vụ chăm sóc cao cấp', 500000, 120, 'active'),

-- Dịch vụ Khám sức khỏe
('Khám Sức Khỏe Tổng Quát', 'health_check', 'Khám sức khỏe tổng quát cho thú cưng', 200000, 30, 'active'),
('Khám Chuyên Sâu', 'health_check', 'Khám sức khỏe chuyên sâu với xét nghiệm', 400000, 60, 'active'),
('Tiêm Phòng', 'health_check', 'Dịch vụ tiêm phòng các loại vaccine', 150000, 20, 'active'),
('Xét Nghiệm Máu', 'health_check', 'Xét nghiệm máu để kiểm tra sức khỏe', 300000, 45, 'active'),
('Siêu Âm', 'health_check', 'Dịch vụ siêu âm kiểm tra nội tạng', 350000, 40, 'active');

-- Kiểm tra kết quả
SELECT 'Spa Services' AS Type, COUNT(*) AS Count FROM PetService WHERE service_type = 'spa'
UNION ALL
SELECT 'Health Check Services' AS Type, COUNT(*) AS Count FROM PetService WHERE service_type = 'health_check';

PRINT 'Hoàn thành! Đã tạo lại bảng PetService với ' + CAST((SELECT COUNT(*) FROM PetService) AS VARCHAR) + ' dịch vụ';
