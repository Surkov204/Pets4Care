-- Fix: Xóa bản trùng lặp và đảm bảo dịch vụ test hiển thị đúng
USE [SHOP_PET_Database]
GO

-- Xóa tất cả dịch vụ test cũ
DELETE FROM PetService WHERE name = N'Dịch vụ test PayOS';
GO

-- Thêm lại 1 dịch vụ test duy nhất
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
GO

-- Đảm bảo tất cả dịch vụ health_check đều active
UPDATE PetService 
SET status = 'active'
WHERE service_type = 'health_check' AND status IS NULL;
GO

-- Kiểm tra kết quả - phải thấy dịch vụ test
SELECT 
    service_id,
    name,
    price,
    service_type,
    status,
    CASE 
        WHEN status = 'active' AND service_type = 'health_check' THEN '✅ Sẽ hiển thị'
        ELSE '❌ Không hiển thị'
    END AS 'Trạng thái hiển thị'
FROM PetService
WHERE service_type = 'health_check'
ORDER BY price ASC;
GO

PRINT '========================================';
PRINT '✅ Đã fix xong!';
PRINT '📋 Vui lòng:';
PRINT '   1. Restart server (NetBeans/Tomcat)';
PRINT '   2. Refresh trang web /health-check-booking';
PRINT '   3. Kiểm tra dropdown "Chọn dịch vụ khám"';
PRINT '========================================';
GO

