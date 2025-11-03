USE [SHOP_PET_Database]
GO

-- Xóa constraint cũ nếu tồn tại
IF EXISTS (SELECT * FROM sys.check_constraints WHERE name = 'CK_Booking_Status_Allowed')
BEGIN
    ALTER TABLE [dbo].[Booking] DROP CONSTRAINT [CK_Booking_Status_Allowed]
    PRINT 'Đã xóa constraint CK_Booking_Status_Allowed cũ'
END
GO

IF EXISTS (SELECT * FROM sys.check_constraints WHERE name = 'CK_Booking_Status_4Values')
BEGIN
    ALTER TABLE [dbo].[Booking] DROP CONSTRAINT [CK_Booking_Status_4Values]
    PRINT 'Đã xóa constraint CK_Booking_Status_4Values cũ'
END
GO

-- Tạo constraint mới với status "Đã xác nhận"
ALTER TABLE [dbo].[Booking] 
WITH CHECK ADD CONSTRAINT [CK_Booking_Status_Allowed] 
CHECK (([status]=N'Chờ xác nhận' OR 
        [status]=N'Đã xác nhận' OR 
        [status]=N'Đã thanh toán' OR 
        [status]=N'Hoàn thành' OR 
        [status]=N'Chưa thanh toán'))
GO

ALTER TABLE [dbo].[Booking] CHECK CONSTRAINT [CK_Booking_Status_Allowed]
GO

PRINT 'Đã thêm constraint mới với status "Đã xác nhận"'
GO

-- Cập nhật các booking có status 'confirmed' thành 'Đã xác nhận' (nếu có)
UPDATE [dbo].[Booking] 
SET [status] = N'Đã xác nhận'
WHERE [status] = 'confirmed' OR [status] = 'Confirmed'
GO

PRINT 'Đã cập nhật các booking có status confirmed sang Đã xác nhận'
GO

