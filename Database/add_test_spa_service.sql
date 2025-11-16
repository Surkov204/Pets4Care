-- Thêm dịch vụ spa test với giá 10,000 đồng để test PayOS
USE [SHOP_PET_Database]
GO

-- Xóa dịch vụ spa test cũ nếu có (để tránh trùng lặp)
DELETE FROM dbo.PetService WHERE name = N'Dịch vụ spa test PayOS' AND price = 10000.00 AND service_type = 'spa';
GO

-- Thêm dịch vụ spa test mới
INSERT INTO dbo.PetService (name, description, price, duration, service_type, status, created_at, updated_at)
VALUES (
    N'Dịch vụ spa test PayOS',
    N'Dịch vụ spa test thanh toán PayOS - Giá 10,000 đồng',
    CAST(10000.00 AS Decimal(10, 2)),
    30,
    N'spa',
    N'active',
    GETDATE(),
    GETDATE()
);
GO

PRINT '✅ Đã tạo dịch vụ spa test PayOS với giá 10,000 đồng!';
GO

-- Hiển thị tất cả dịch vụ spa để kiểm tra
SELECT
    service_id,
    name,
    price,
    service_type,
    status,
    duration,
    created_at
FROM dbo.PetService
WHERE service_type = 'spa' AND status = 'active'
ORDER BY price ASC;
GO

