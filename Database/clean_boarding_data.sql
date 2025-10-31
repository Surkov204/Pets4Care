-- Script để xóa dữ liệu test cũ và tạo lại bảng sạch
USE [SHOP_PET_Database]
GO

-- Xóa dữ liệu cũ trong bảng boarding_bookings
DELETE FROM dbo.boarding_bookings
GO

-- Xóa dữ liệu cũ trong bảng Boarding_History (nếu có)
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'Boarding_History')
BEGIN
    DELETE FROM dbo.Boarding_History
    PRINT 'Cleaned Boarding_History table'
END
ELSE
BEGIN
    PRINT 'Boarding_History table does not exist'
END
GO

-- Reset identity counter cho bảng boarding_bookings
DBCC CHECKIDENT ('dbo.boarding_bookings', RESEED, 0)
GO

-- Kiểm tra bảng boarding_bookings có tồn tại và có cấu trúc đúng không
SELECT 
    TABLE_NAME,
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE,
    COLUMN_DEFAULT
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_SCHEMA = 'dbo' 
AND TABLE_NAME = 'boarding_bookings'
ORDER BY ORDINAL_POSITION

PRINT 'Database cleaned successfully'
PRINT 'Ready for new test data'

