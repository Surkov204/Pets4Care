USE SHOP_PET_Database
GO

PRINT '=========================================='
PRINT 'FIX BOOKING_SERVICE TABLE - FINAL'
PRINT '=========================================='
PRINT ''

-- =============================================
-- KIỂM TRA CẤU TRÚC HIỆN TẠI
-- =============================================
PRINT '→ Kiểm tra cấu trúc bảng Booking_Service hiện tại...'

SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'Booking_Service'
ORDER BY ORDINAL_POSITION

PRINT ''

-- =============================================
-- THÊM CỘT NOTE NẾU THIẾU
-- =============================================
PRINT '→ Thêm cột note nếu thiếu...'

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
               WHERE TABLE_NAME = 'Booking_Service' AND COLUMN_NAME = 'note')
BEGIN
    ALTER TABLE Booking_Service 
    ADD note NVARCHAR(MAX) NULL
    PRINT '  ✓ Đã thêm cột note'
END
ELSE
    PRINT '  ✓ Cột note đã tồn tại'

PRINT ''

-- =============================================
-- KIỂM TRA LẠI CẤU TRÚC
-- =============================================
PRINT '→ Kiểm tra cấu trúc sau khi sửa...'

SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'Booking_Service'
ORDER BY ORDINAL_POSITION

PRINT ''

-- =============================================
-- TEST INSERT BOOKING_SERVICE
-- =============================================
PRINT '→ Test insert Booking_Service...'

-- Lấy booking_id đầu tiên (nếu có)
DECLARE @TestBookingId INT
SELECT TOP 1 @TestBookingId = booking_id FROM Booking

-- Lấy service_id đầu tiên (nếu có)
DECLARE @TestServiceId INT
SELECT TOP 1 @TestServiceId = service_id FROM PetService

IF @TestBookingId IS NOT NULL AND @TestServiceId IS NOT NULL
BEGIN
    BEGIN TRY
        -- Test insert với unit_price (cột thực tế)
        INSERT INTO Booking_Service (
            booking_id, service_id, quantity, unit_price, note
        ) VALUES (
            @TestBookingId, @TestServiceId, 1, 200000, 'Test booking service'
        )
        
        DECLARE @NewBookingServiceId INT = SCOPE_IDENTITY()
        PRINT '  ✅ SUCCESS: Test Booking_Service created with ID=' + CAST(@NewBookingServiceId AS VARCHAR)
        
        -- Xóa test data
        DELETE FROM Booking_Service WHERE booking_service_id = @NewBookingServiceId
        PRINT '  ✓ Test data cleaned up'
        
    END TRY
    BEGIN CATCH
        PRINT '  ❌ ERROR inserting test Booking_Service: ' + ERROR_MESSAGE()
    END CATCH
END
ELSE
BEGIN
    PRINT '  ⚠️ Không có dữ liệu để test (cần có Booking và PetService)'
END

PRINT ''
PRINT '=========================================='
PRINT 'END FIX'
PRINT '=========================================='
