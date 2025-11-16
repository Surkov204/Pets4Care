-- CÁCH 1: Update giá dịch vụ hiện có thành 10,000 đồng để test
-- (Nhanh hơn, không cần tạo mới)

USE [SHOP_PET_Database]
GO

-- Update giá dịch vụ "Tư vấn dinh dưỡng" (service_id = 5) thành 10,000 đồng
UPDATE PetService 
SET price = 10000.00,
    description = N'Tư vấn dinh dưỡng - Giá test 10,000 đồng',
    updated_at = GETDATE()
WHERE service_id = 5 AND service_type = 'health_check';
GO

-- Hoặc tạo dịch vụ mới nếu muốn
IF NOT EXISTS (SELECT * FROM PetService WHERE name = N'Dịch vụ test PayOS')
BEGIN
    INSERT INTO PetService (name, description, price, duration, service_type, status, created_at, updated_at)
    VALUES (
        N'Dịch vụ test PayOS',
        N'Dịch vụ test thanh toán PayOS - Giá 10,000 đồng',
        10000.00,
        15,
        'health_check',
        'active',
        GETDATE(),
        GETDATE()
    );
END
GO

-- Kiểm tra kết quả
SELECT 
    service_id,
    name AS 'Tên dịch vụ',
    price AS 'Giá (₫)',
    service_type AS 'Loại',
    status AS 'Trạng thái'
FROM PetService
WHERE service_type = 'health_check' AND status = 'active'
ORDER BY price ASC;
GO

PRINT '✅ Hoàn tất! Vui lòng restart server để thấy dịch vụ mới trong web.';
GO

