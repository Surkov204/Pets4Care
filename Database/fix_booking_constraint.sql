USE [SHOP_PET_Database]
GO

-- Kiểm tra và sửa default constraint để khớp với check constraint
-- Xóa default constraint cũ nếu có
IF EXISTS (SELECT * FROM sys.default_constraints WHERE name = 'DF_Booking_Status')
BEGIN
    PRINT 'Đang xóa default constraint cũ...'
    ALTER TABLE [dbo].[Booking] DROP CONSTRAINT [DF_Booking_Status]
    PRINT 'Đã xóa default constraint cũ'
END
GO

-- Tạo lại default constraint với chữ hoa đúng
ALTER TABLE [dbo].[Booking] 
ADD CONSTRAINT [DF_Booking_Status]  
DEFAULT (N'Chưa thanh toán') FOR [status]
GO

PRINT '✅ Đã cập nhật default constraint thành: Chưa thanh toán'
GO

-- Kiểm tra constraint check
IF EXISTS (SELECT * FROM sys.check_constraints WHERE name = 'CK_Booking_Status_Allowed')
BEGIN
    PRINT 'Constraint check đã tồn tại'
    PRINT 'Các status được phép:'
    PRINT '  - Chờ xác nhận'
    PRINT '  - Đã xác nhận'
    PRINT '  - Đã thanh toán'
    PRINT '  - Đã hủy'
    PRINT '  - Yêu cầu hoàn tiền'
    PRINT '  - Hoàn thành'
    PRINT '  - Chưa thanh toán'
END
ELSE
BEGIN
    PRINT '⚠️ Constraint check chưa tồn tại, đang tạo...'
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
    PRINT '✅ Đã tạo constraint check'
END
GO

-- Test update với status "Yêu cầu hoàn tiền"
BEGIN TRY
    DECLARE @testBookingId INT = 999999
    -- Kiểm tra xem có booking nào để test không (chỉ test nếu có)
    IF EXISTS (SELECT 1 FROM [dbo].[Booking] WHERE booking_id = @testBookingId)
    BEGIN
        PRINT 'Testing update với status Yêu cầu hoàn tiền...'
        UPDATE [dbo].[Booking] 
        SET status = N'Yêu cầu hoàn tiền' 
        WHERE booking_id = @testBookingId
        PRINT '✅ Test update thành công!'
    END
    ELSE
    BEGIN
        PRINT 'Không có booking test, bỏ qua test update'
    END
END TRY
BEGIN CATCH
    PRINT '❌ Lỗi khi test update:'
    PRINT ERROR_MESSAGE()
END CATCH
GO

PRINT '=== HOÀN TẤT CẬP NHẬT ==='
GO

