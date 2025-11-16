-- Thêm dịch vụ test với giá 10,000 đồng để test PayOS
USE [SHOP_PET_Database]
GO

-- Xóa dịch vụ test cũ nếu có (để tránh trùng lặp)
DELETE FROM dbo.PetService WHERE name = N'Dịch vụ test PayOS' AND price = 10000.00;
GO

-- Thêm dịch vụ test mới
INSERT INTO dbo.PetService (name, description, price, duration, service_type, status, created_at, updated_at)
VALUES (
    N'Dịch vụ test PayOS',
    N'Dịch vụ test thanh toán PayOS - Giá 10,000 đồng',
    CAST(10000.00 AS Decimal(10, 2)),
    15,
    N'health_check',
    N'active',
    GETDATE(),
    GETDATE()
);
GO

PRINT '✅ Đã tạo dịch vụ test PayOS với giá 10,000 đồng!';
GO

-- Hiển thị tất cả dịch vụ health_check để kiểm tra
SELECT 
    service_id,
    name,
    price,
    service_type,
    status,
    created_at
FROM dbo.PetService
WHERE service_type = 'health_check' AND status = 'active'
ORDER BY price ASC;
GO

