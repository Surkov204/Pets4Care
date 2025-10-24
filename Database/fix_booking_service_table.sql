USE SHOP_PET_Database
GO

PRINT '=========================================='
PRINT 'FIX BOOKING_SERVICE TABLE'
PRINT '=========================================='
PRINT ''

-- =============================================
-- KIỂM TRA CẤU TRÚC BẢNG HIỆN TẠI
-- =============================================
PRINT '→ Kiểm tra cấu trúc bảng Booking_Service hiện tại...'

SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE,
    CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'Booking_Service'
ORDER BY ORDINAL_POSITION

PRINT ''

-- =============================================
-- KIỂM TRA CÁC CỘT THIẾU
-- =============================================
PRINT '→ Kiểm tra các cột thiếu...'

DECLARE @HasPrice BIT = 0, @HasNote BIT = 0

-- Kiểm tra cột price
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
           WHERE TABLE_NAME = 'Booking_Service' AND COLUMN_NAME = 'price')
    SET @HasPrice = 1

-- Kiểm tra cột note  
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
           WHERE TABLE_NAME = 'Booking_Service' AND COLUMN_NAME = 'note')
    SET @HasNote = 1

IF @HasPrice = 1
    PRINT '  ✓ Cột price: TỒN TẠI'
ELSE
    PRINT '  ❌ Cột price: THIẾU'

IF @HasNote = 1
    PRINT '  ✓ Cột note: TỒN TẠI'
ELSE
    PRINT '  ❌ Cột note: THIẾU'

PRINT ''

-- =============================================
-- THÊM CÁC CỘT THIẾU
-- =============================================
PRINT '→ Thêm các cột thiếu...'

-- Thêm cột price nếu thiếu
IF @HasPrice = 0
BEGIN
    ALTER TABLE Booking_Service 
    ADD price DECIMAL(10,2) NOT NULL DEFAULT 0
    PRINT '  ✓ Đã thêm cột price'
END
ELSE
    PRINT '  ✓ Cột price đã tồn tại'

-- Thêm cột note nếu thiếu
IF @HasNote = 0
BEGIN
    ALTER TABLE Booking_Service 
    ADD note NVARCHAR(MAX) NULL
    PRINT '  ✓ Đã thêm cột note'
END
ELSE
    PRINT '  ✓ Cột note đã tồn tại'

PRINT ''

-- =============================================
-- KIỂM TRA LẠI CẤU TRÚC SAU KHI SỬA
-- =============================================
PRINT '→ Kiểm tra cấu trúc sau khi sửa...'

SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE,
    CHARACTER_MAXIMUM_LENGTH
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
        -- Test insert
        INSERT INTO Booking_Service (
            booking_id, service_id, quantity, price, note
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
