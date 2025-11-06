USE [SHOP_PET_Database]
GO

-- Bước 0: Kiểm tra dữ liệu hiện tại
PRINT '=== KIỂM TRA DỮ LIỆU HIỆN TẠI ==='
SELECT [status], COUNT(*) as [Số lượng]
FROM [dbo].[boarding_bookings]
GROUP BY [status]
ORDER BY [status]
GO

-- Bước 1: Xóa constraint cũ nếu tồn tại (trước khi cập nhật dữ liệu)
-- Tìm và xóa constraint CHECK trên cột status của bảng boarding_bookings
DECLARE @ConstraintName NVARCHAR(200)
DECLARE @SQL NVARCHAR(MAX)

-- Tìm constraint CHECK trên cột status
SELECT @ConstraintName = cc.name
FROM sys.check_constraints cc
INNER JOIN sys.columns c ON cc.parent_column_id = c.column_id 
    AND cc.parent_object_id = c.object_id
WHERE cc.parent_object_id = OBJECT_ID('dbo.boarding_bookings')
  AND c.name = 'status'

IF @ConstraintName IS NOT NULL
BEGIN
    BEGIN TRY
        SET @SQL = 'ALTER TABLE [dbo].[boarding_bookings] DROP CONSTRAINT [' + @ConstraintName + ']'
        EXEC sp_executesql @SQL
        PRINT 'Đã xóa constraint cũ: ' + @ConstraintName
    END TRY
    BEGIN CATCH
        PRINT 'Lỗi khi xóa constraint ' + @ConstraintName + ': ' + ERROR_MESSAGE()
    END CATCH
END
ELSE
BEGIN
    PRINT 'Không tìm thấy constraint CHECK trên cột status - có thể không tồn tại'
END
GO

-- Bước 2: Cập nhật dữ liệu cũ để phù hợp với constraint mới
-- Cập nhật các status cũ sang status mới
PRINT '=== CẬP NHẬT DỮ LIỆU ==='

-- Các status tương đương với "Đang ở" (ưu tiên cập nhật trước)
UPDATE [dbo].[boarding_bookings]
SET [status] = N'Đang ở'
WHERE [status] IN (N'Đang thuê', N'in_progress', N'Đang ở')
GO

-- Các status tương đương với "Đã nhận về"
UPDATE [dbo].[boarding_bookings]
SET [status] = N'Đã nhận về'
WHERE [status] IN (N'completed', N'Hoàn thành', N'Đã thanh toán', N'Đã nhận về', N'Đã trả')
GO

-- Các status tương đương với "Đã hủy"
UPDATE [dbo].[boarding_bookings]
SET [status] = N'Đã hủy'
WHERE [status] IN (N'cancelled', N'Đã hủy')
GO

-- Các status tương đương với "Chờ xác nhận" (cập nhật sau cùng để bắt tất cả các status còn lại)
-- CHÚ Ý: Không cập nhật "Chưa nhận thú cưng" vì đó là status hợp lệ mới
UPDATE [dbo].[boarding_bookings]
SET [status] = N'Chờ xác nhận'
WHERE [status] IN (
    N'pending', 
    N'Chưa thanh toán', 
    N'Đã xác nhận', 
    N'confirmed',
    N'Chờ xác nhận'
)
GO

-- Cập nhật các status không xác định, null hoặc không hợp lệ thành "Chờ xác nhận"
-- Chỉ cập nhật những status không nằm trong danh sách status hợp lệ
UPDATE [dbo].[boarding_bookings]
SET [status] = N'Chờ xác nhận'
WHERE [status] IS NULL 
   OR LTRIM(RTRIM([status])) = ''
   OR [status] NOT IN (
       N'Chờ xác nhận', 
       N'Chưa nhận thú cưng', 
       N'Đang ở', 
       N'Đã nhận về', 
       N'Hoàn thành', 
       N'Đã trả', 
       N'Đã hủy'
       -- KHÔNG bao gồm "Đã thanh toán" và "Chưa thanh toán" vì đã được cập nhật ở trên
   )
GO

-- Bước 3: Kiểm tra lại dữ liệu sau khi cập nhật
PRINT '=== KIỂM TRA DỮ LIỆU SAU KHI CẬP NHẬT ==='
SELECT [status], COUNT(*) as [Số lượng]
FROM [dbo].[boarding_bookings]
GROUP BY [status]
ORDER BY [status]
GO

-- Bước 4: Thêm constraint mới với các status mới
PRINT '=== THÊM CONSTRAINT MỚI ==='
ALTER TABLE [dbo].[boarding_bookings] 
ADD CONSTRAINT [CK_boarding_bookings_Status] 
CHECK ([status] IN (
    N'Chờ xác nhận', 
    N'Chưa nhận thú cưng', 
    N'Đang ở', 
    N'Đã nhận về', 
    N'Hoàn thành', 
    N'Đã trả', 
    N'Đã thanh toán', 
    N'Chưa thanh toán', 
    N'Đã hủy'
))
GO

PRINT 'Đã thêm constraint mới CK_boarding_bookings_Status thành công'
GO

-- Bước 5: Kiểm tra kết quả cuối cùng
PRINT '=== KẾT QUẢ CUỐI CÙNG ==='
SELECT [status], COUNT(*) as [Số lượng]
FROM [dbo].[boarding_bookings]
GROUP BY [status]
ORDER BY [status]
GO

