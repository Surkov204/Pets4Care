USE [SHOP_PET_Database]
GO

-- Kiểm tra constraint hiện tại
IF EXISTS (SELECT * FROM sys.check_constraints WHERE name = 'CK_Booking_Status_Allowed')
BEGIN
    PRINT 'Đang xóa constraint cũ...'
    ALTER TABLE [dbo].[Booking] DROP CONSTRAINT [CK_Booking_Status_Allowed]
    PRINT 'Đã xóa constraint cũ thành công'
END
ELSE
BEGIN
    PRINT 'Constraint cũ không tồn tại, sẽ tạo mới'
END
GO

-- Tạo constraint mới với tất cả các status cần thiết
PRINT 'Đang tạo constraint mới...'
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

PRINT '✅ Constraint đã được cập nhật thành công!'
PRINT 'Các status được phép: Chờ xác nhận, Đã xác nhận, Đã thanh toán, Yêu cầu hoàn tiền, Đã hủy, Hoàn thành, Chưa thanh toán'
GO

-- Kiểm tra xem constraint có hoạt động không
BEGIN TRY
    -- Test với status hợp lệ
    DECLARE @testStatus NVARCHAR(30) = N'Yêu cầu hoàn tiền'
    PRINT '✅ Test status: ' + @testStatus + ' - Hợp lệ'
END TRY
BEGIN CATCH
    PRINT '❌ Lỗi: ' + ERROR_MESSAGE()
END CATCH
GO

