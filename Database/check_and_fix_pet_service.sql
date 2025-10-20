-- Script kiểm tra và tạo dữ liệu PetService
-- Chạy script này để kiểm tra và tạo dữ liệu spa services

USE SHOP_PET_Database;

-- Kiểm tra xem bảng PetService có tồn tại không
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'PetService')
BEGIN
    PRINT 'Bảng PetService đã tồn tại';
    
    -- Kiểm tra dữ liệu hiện có
    SELECT 'Dữ liệu hiện có:' AS Status;
    SELECT service_id, name, service_type, price, status FROM PetService ORDER BY service_type, name;
    
    -- Đếm số lượng dịch vụ theo loại
    SELECT 
        service_type AS 'Loại dịch vụ',
        COUNT(*) AS 'Số lượng',
        SUM(CASE WHEN status = 'active' THEN 1 ELSE 0 END) AS 'Đang hoạt động'
    FROM PetService 
    GROUP BY service_type;
END
ELSE
BEGIN
    PRINT 'Bảng PetService không tồn tại - đang tạo mới...';
    
    -- Tạo bảng PetService
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
    
    PRINT 'Đã tạo bảng PetService';
END

-- Kiểm tra xem có dữ liệu spa không
IF NOT EXISTS (SELECT * FROM PetService WHERE service_type = 'spa')
BEGIN
    PRINT 'Không có dữ liệu spa - đang thêm...';
    
    -- Thêm dịch vụ Spa
    INSERT INTO PetService (name, service_type, description, price, duration, status) VALUES
    ('Spa Tắm Gội Cơ Bản', 'spa', 'Dịch vụ tắm gội cơ bản với dầu gội chuyên dụng', 150000, 30, 'active'),
    ('Spa Tắm Gội Cao Cấp', 'spa', 'Dịch vụ tắm gội cao cấp với massage và chăm sóc da', 250000, 45, 'active'),
    ('Cắt Tỉa Lông', 'spa', 'Dịch vụ cắt tỉa lông theo phong cách hiện đại', 200000, 60, 'active'),
    ('Cắt Móng Chân', 'spa', 'Dịch vụ cắt móng chân an toàn và chuyên nghiệp', 80000, 15, 'active'),
    ('Vệ Sinh Tai', 'spa', 'Dịch vụ vệ sinh tai và kiểm tra sức khỏe tai', 100000, 20, 'active'),
    ('Vệ Sinh Răng', 'spa', 'Dịch vụ vệ sinh răng và massage nướu', 120000, 25, 'active'),
    ('Massage Thư Giãn', 'spa', 'Dịch vụ massage thư giãn giúp thú cưng thoải mái', 180000, 40, 'active'),
    ('Spa Package VIP', 'spa', 'Gói spa VIP bao gồm tất cả dịch vụ chăm sóc cao cấp', 500000, 120, 'active');
    
    PRINT 'Đã thêm ' + CAST(@@ROWCOUNT AS VARCHAR) + ' dịch vụ spa';
END
ELSE
BEGIN
    PRINT 'Đã có dữ liệu spa';
END

-- Kiểm tra xem có dữ liệu health_check không
IF NOT EXISTS (SELECT * FROM PetService WHERE service_type = 'health_check')
BEGIN
    PRINT 'Không có dữ liệu health_check - đang thêm...';
    
    -- Thêm dịch vụ Khám sức khỏe
    INSERT INTO PetService (name, service_type, description, price, duration, status) VALUES
    ('Khám Sức Khỏe Tổng Quát', 'health_check', 'Khám sức khỏe tổng quát cho thú cưng', 200000, 30, 'active'),
    ('Khám Chuyên Sâu', 'health_check', 'Khám sức khỏe chuyên sâu với xét nghiệm', 400000, 60, 'active'),
    ('Tiêm Phòng', 'health_check', 'Dịch vụ tiêm phòng các loại vaccine', 150000, 20, 'active'),
    ('Xét Nghiệm Máu', 'health_check', 'Xét nghiệm máu để kiểm tra sức khỏe', 300000, 45, 'active'),
    ('Siêu Âm', 'health_check', 'Dịch vụ siêu âm kiểm tra nội tạng', 350000, 40, 'active');
    
    PRINT 'Đã thêm ' + CAST(@@ROWCOUNT AS VARCHAR) + ' dịch vụ health_check';
END
ELSE
BEGIN
    PRINT 'Đã có dữ liệu health_check';
END

-- Hiển thị kết quả cuối cùng
PRINT '=== KẾT QUẢ CUỐI CÙNG ===';
SELECT 
    service_type AS 'Loại dịch vụ',
    COUNT(*) AS 'Tổng số',
    SUM(CASE WHEN status = 'active' THEN 1 ELSE 0 END) AS 'Đang hoạt động',
    MIN(price) AS 'Giá thấp nhất',
    MAX(price) AS 'Giá cao nhất'
FROM PetService 
GROUP BY service_type
ORDER BY service_type;

-- Test query để kiểm tra spa services
PRINT '=== KIỂM TRA SPA SERVICES ===';
SELECT service_id, name, price, duration, status 
FROM PetService 
WHERE service_type = 'spa' AND status = 'active'
ORDER BY name;

PRINT 'Hoàn thành! Tổng số dịch vụ: ' + CAST((SELECT COUNT(*) FROM PetService) AS VARCHAR);
