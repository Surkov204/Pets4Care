-- Script đơn giản: Thêm dịch vụ test PayOS 10,000 đồng
-- Chạy script này trong SQL Server Management Studio

USE [SHOP_PET_Database]
GO

-- Xóa dịch vụ test cũ nếu có
DELETE FROM dbo.PetService WHERE name LIKE N'%test PayOS%';
GO

-- Thêm dịch vụ test mới
INSERT INTO dbo.PetService (name, description, price, duration, service_type, status, created_at, updated_at)
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

-- Kiểm tra kết quả
SELECT 
    service_id AS 'ID',
    name AS 'Tên dịch vụ',
    price AS 'Giá',
    service_type AS 'Loại',
    status AS 'Trạng thái'
FROM dbo.PetService
WHERE service_type = 'health_check' AND status = 'active'
ORDER BY price ASC;
GO

