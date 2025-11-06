USE [SHOP_PET_Database]
GO

-- Xóa constraint cũ
IF EXISTS (SELECT * FROM sys.check_constraints WHERE name = 'CK_Booking_Status_Allowed')
BEGIN
    ALTER TABLE [dbo].[Booking] DROP CONSTRAINT [CK_Booking_Status_Allowed]
END
GO

-- Tạo constraint mới - cho phép các status: Chờ xác nhận, Đã xác nhận, Đã thanh toán, Yêu cầu hoàn tiền, Đã hủy, Hoàn thành, Chưa thanh toán
ALTER TABLE [dbo].[Booking] 
ADD CONSTRAINT [CK_Booking_Status_Allowed] 
CHECK (
    [status] = N'Chờ xác nhận'
    OR [status] = N'Đã xác nhận'
    OR [status] = N'Đã thanh toán' 
    OR [status] = N'Đã hủy'
    OR [status] = N'Yêu cầu hoàn tiền'
    OR [status] = N'Hoàn thành'
    OR [status] = N'Chưa thanh toán'
)
GO

PRINT 'Constraint đã được cập nhật - cho phép: Chờ xác nhận, Đã xác nhận, Đã thanh toán, Yêu cầu hoàn tiền, Đã hủy, Hoàn thành, Chưa thanh toán'
GO

