-- QUICK SCRIPT: Thêm dịch vụ test PayOS 10,000 đồng
-- Copy và chạy trực tiếp trong SQL Server Management Studio

USE [SHOP_PET_Database]

-- Xóa dịch vụ test cũ nếu có
DELETE FROM PetService WHERE name = N'Dịch vụ test PayOS'

-- Thêm dịch vụ test mới
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
)

-- Xem kết quả
SELECT service_id, name, price, service_type, status 
FROM PetService 
WHERE service_type = 'health_check' AND status = 'active'
ORDER BY price

