-- Script test đơn giản để kiểm tra PetService
-- Chạy script này để test nhanh

USE SHOP_PET_Database;

-- Test 1: Kiểm tra bảng có tồn tại không
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'PetService')
    PRINT '✓ Bảng PetService tồn tại'
ELSE
    PRINT '✗ Bảng PetService KHÔNG tồn tại';

-- Test 2: Kiểm tra dữ liệu spa
DECLARE @spaCount INT;
SELECT @spaCount = COUNT(*) FROM PetService WHERE service_type = 'spa' AND status = 'active';

IF @spaCount > 0
    PRINT '✓ Có ' + CAST(@spaCount AS VARCHAR) + ' dịch vụ spa đang hoạt động'
ELSE
    PRINT '✗ KHÔNG có dịch vụ spa nào';

-- Test 3: Hiển thị 5 dịch vụ spa đầu tiên
SELECT TOP 5 
    service_id,
    name,
    price,
    duration,
    status
FROM PetService 
WHERE service_type = 'spa' 
ORDER BY service_id;

-- Test 4: Kiểm tra health_check services
DECLARE @healthCount INT;
SELECT @healthCount = COUNT(*) FROM PetService WHERE service_type = 'health_check' AND status = 'active';

IF @healthCount > 0
    PRINT '✓ Có ' + CAST(@healthCount AS VARCHAR) + ' dịch vụ health_check đang hoạt động'
ELSE
    PRINT '✗ KHÔNG có dịch vụ health_check nào';

-- Test 5: Tổng kết
SELECT 
    'Tổng kết' AS 'Test',
    COUNT(*) AS 'Tổng dịch vụ',
    SUM(CASE WHEN service_type = 'spa' AND status = 'active' THEN 1 ELSE 0 END) AS 'Spa hoạt động',
    SUM(CASE WHEN service_type = 'health_check' AND status = 'active' THEN 1 ELSE 0 END) AS 'Health check hoạt động'
FROM PetService;
