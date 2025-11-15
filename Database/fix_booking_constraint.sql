USE [SHOP_PET_Database]
GO

-- Kiểm tra và sửa default constraint để khớp với check constraint
-- Xóa default constraint cũ nếu có
IF EXISTS (SELECT * FROM sys.default_constraints WHERE parent_object_id = OBJECT_ID('dbo.Booking') AND name LIKE '%Status%')
BEGIN
    DECLARE @constraintName NVARCHAR(128)
    SELECT @constraintName = name FROM sys.default_constraints
    WHERE parent_object_id = OBJECT_ID('dbo.Booking') AND name LIKE '%Status%'

    PRINT 'Đang xóa default constraint cũ: ' + @constraintName
    EXEC('ALTER TABLE [dbo].[Booking] DROP CONSTRAINT [' + @constraintName + ']')
    PRINT 'Đã xóa default constraint cũ'
END
ELSE
BEGIN
    PRINT 'Không tìm thấy default constraint cũ trên cột status'
END
GO

-- Tạo lại default constraint với chữ hoa đúng
ALTER TABLE [dbo].[Booking]
ADD CONSTRAINT [DF_Booking_Status]
DEFAULT (N'Hoàn thành') FOR [status]
GO

PRINT '✅ Đã cập nhật default constraint thành: Hoàn thành'
GO

-- Xóa constraint check cũ nếu tồn tại
IF EXISTS (SELECT * FROM sys.check_constraints WHERE parent_object_id = OBJECT_ID('dbo.Booking') AND name LIKE '%Status%')
BEGIN
    DECLARE @checkConstraintName NVARCHAR(128)
    SELECT @checkConstraintName = name FROM sys.check_constraints
    WHERE parent_object_id = OBJECT_ID('dbo.Booking') AND name LIKE '%Status%'

    PRINT 'Đang xóa constraint check cũ: ' + @checkConstraintName
    EXEC('ALTER TABLE [dbo].[Booking] DROP CONSTRAINT [' + @checkConstraintName + ']')
    PRINT '✅ Đã xóa constraint check cũ'
END
GO

-- Cập nhật các status không hợp lệ thành 'Hoàn thành' trước khi tạo constraint mới
PRINT 'Đang cập nhật status không hợp lệ...'
UPDATE [dbo].[Booking]
SET [status] = N'Hoàn thành'
WHERE [status] NOT IN (
    N'Chờ xác nhận',
    N'Đã xác nhận',
    N'Đã thanh toán',
    N'Đã hủy',
    N'Yêu cầu hoàn tiền',
    N'Hoàn thành',
    N'Chưa thanh toán'
)
PRINT '✅ Đã cập nhật status không hợp lệ'
GO

-- Tạo constraint check mới
PRINT 'Đang tạo constraint check mới...'
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
PRINT '✅ Đã tạo constraint check mới'
PRINT 'Các status được phép: Chờ xác nhận, Đã xác nhận, Đã thanh toán, Đã hủy, Yêu cầu hoàn tiền, Hoàn thành, Chưa thanh toán'
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

