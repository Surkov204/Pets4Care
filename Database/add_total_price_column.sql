-- Script để thêm cột total_price vào bảng boarding_bookings
-- Chạy script này trong SQL Server Management Studio

USE SHOP_PET_Database;
GO

-- Kiểm tra xem cột total_price đã tồn tại chưa
IF NOT EXISTS (
    SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_NAME = 'boarding_bookings' 
    AND COLUMN_NAME = 'total_price'
)
BEGIN
    -- Thêm cột total_price
    ALTER TABLE dbo.boarding_bookings 
    ADD total_price DECIMAL(10,2) NOT NULL DEFAULT 0;
    
    PRINT 'Đã thêm cột total_price vào bảng boarding_bookings';
END
ELSE
BEGIN
    PRINT 'Cột total_price đã tồn tại trong bảng boarding_bookings';
END
GO

-- Kiểm tra cấu trúc bảng sau khi thêm
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE,
    COLUMN_DEFAULT
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'boarding_bookings'
ORDER BY ORDINAL_POSITION;
GO

-- Cập nhật giá trị total_price cho các record hiện có
UPDATE dbo.boarding_bookings 
SET total_price = price_per_day * boarding_days
WHERE total_price = 0 OR total_price IS NULL;

PRINT 'Đã cập nhật giá trị total_price cho các record hiện có';
GO

