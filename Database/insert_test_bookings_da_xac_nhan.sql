USE [SHOP_PET_Database]
GO

-- ============================================
-- Tạo dữ liệu test: Booking với status "Đã xác nhận" cho customer Nguyễn Văn A
-- ============================================

DECLARE @customerId INT;
DECLARE @petId1 INT;
DECLARE @petId2 INT;
DECLARE @serviceId1 INT;
DECLARE @serviceId2 INT;
DECLARE @bookingId1 INT;
DECLARE @bookingId2 INT;
DECLARE @bookingId3 INT;
DECLARE @appointmentStart1 DATETIME;
DECLARE @appointmentEnd1 DATETIME;
DECLARE @appointmentStart2 DATETIME;
DECLARE @appointmentEnd2 DATETIME;
DECLARE @appointmentStart3 DATETIME;
DECLARE @appointmentEnd3 DATETIME;

-- Bước 1: Kiểm tra hoặc tạo Customer "Nguyễn Văn A"
IF NOT EXISTS (SELECT 1 FROM Customer WHERE name = N'Nguyễn Văn A')
BEGIN
    INSERT INTO Customer (name, phone, email, password, address_Customer, status)
    VALUES (N'Nguyễn Văn A', '0901234567', 'nguyenvana@example.com', 
            '$2a$10$example_hash_password', N'123 Đường ABC, Quận 1, TP.HCM', 'active');
    
    SET @customerId = SCOPE_IDENTITY();
    PRINT N'Đã tạo customer mới: Nguyễn Văn A (ID: ' + CAST(@customerId AS NVARCHAR) + ')';
END
ELSE
BEGIN
    SELECT @customerId = customer_id FROM Customer WHERE name = N'Nguyễn Văn A';
    PRINT N'Customer Nguyễn Văn A đã tồn tại (ID: ' + CAST(@customerId AS NVARCHAR) + ')';
END

-- Bước 2: Kiểm tra hoặc tạo Pet cho customer
IF NOT EXISTS (SELECT 1 FROM Pet WHERE customer_id = @customerId)
BEGIN
    -- Pet 1
    INSERT INTO Pet (customer_id, pet_name, species, breed, age, gender, description, created_at, updated_at)
    VALUES (@customerId, N'Cún Vàng', N'Chó', N'Golden Retriever', 2, N'Đực', N'Thú cưng dễ thương', GETDATE(), GETDATE());
    SET @petId1 = SCOPE_IDENTITY();
    
    -- Pet 2
    INSERT INTO Pet (customer_id, pet_name, species, breed, age, gender, description, created_at, updated_at)
    VALUES (@customerId, N'Mèo Tím', N'Mèo', N'Persian', 1, N'Cái', N'Mèo lông dài', GETDATE(), GETDATE());
    SET @petId2 = SCOPE_IDENTITY();
    
    PRINT N'Đã tạo 2 pet cho customer (ID: ' + CAST(@petId1 AS NVARCHAR) + ', ' + CAST(@petId2 AS NVARCHAR) + ')';
END
ELSE
BEGIN
    SELECT TOP 1 @petId1 = id FROM Pet WHERE customer_id = @customerId ORDER BY id;
    SELECT TOP 1 @petId2 = id FROM Pet WHERE customer_id = @customerId ORDER BY id DESC;
    IF @petId2 IS NULL SET @petId2 = @petId1; -- Nếu chỉ có 1 pet
    PRINT N'Đã sử dụng pet có sẵn (ID: ' + CAST(@petId1 AS NVARCHAR) + ', ' + CAST(@petId2 AS NVARCHAR) + ')';
END

-- Bước 3: Lấy hoặc tạo Service Spa
SELECT TOP 1 @serviceId1 = service_id FROM PetService WHERE service_type = 'spa' AND status = 'active' ORDER BY service_id;

IF @serviceId1 IS NULL
BEGIN
    -- Tạo service spa 1
    INSERT INTO PetService (name, service_type, description, price, duration, status, created_at, updated_at)
    VALUES (N'Tắm spa cho chó', 'spa', N'Dịch vụ tắm spa cao cấp cho chó', 200000, 60, 'active', GETDATE(), GETDATE());
    SET @serviceId1 = SCOPE_IDENTITY();
END

SELECT TOP 1 @serviceId2 = service_id FROM PetService 
WHERE service_type = 'spa' AND status = 'active' AND service_id != @serviceId1 
ORDER BY service_id;

IF @serviceId2 IS NULL
BEGIN
    -- Tạo service spa 2
    INSERT INTO PetService (name, service_type, description, price, duration, status, created_at, updated_at)
    VALUES (N'Cắt tỉa lông', 'spa', N'Cắt tỉa lông chuyên nghiệp', 150000, 45, 'active', GETDATE(), GETDATE());
    SET @serviceId2 = SCOPE_IDENTITY();
END

PRINT N'Service spa (ID: ' + CAST(@serviceId1 AS NVARCHAR) + ', ' + CAST(@serviceId2 AS NVARCHAR) + ')';

-- Bước 3.5: Thêm status "Đã xác nhận" vào bảng BookingStatus nếu chưa có
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'BookingStatus')
BEGIN
    IF NOT EXISTS (SELECT 1 FROM BookingStatus WHERE status_code = N'Đã xác nhận')
    BEGIN
        INSERT INTO BookingStatus (status_code)
        VALUES (N'Đã xác nhận');
        PRINT N'Đã thêm status "Đã xác nhận" vào bảng BookingStatus';
    END
    ELSE
    BEGIN
        PRINT N'Status "Đã xác nhận" đã tồn tại trong BookingStatus';
    END
END

-- Bước 4: Tạo các Booking với status "Đã xác nhận"
-- Booking 1: Hôm nay lúc 10:00
SET @appointmentStart1 = CAST(GETDATE() AS DATE);
SET @appointmentStart1 = DATEADD(HOUR, 10, @appointmentStart1); -- 10:00
SET @appointmentEnd1 = DATEADD(MINUTE, 60, @appointmentStart1); -- 11:00

INSERT INTO Booking (customer_id, pet_id, appointment_start, appointment_end, status, note, created_at, updated_at)
VALUES (@customerId, @petId1, @appointmentStart1, @appointmentEnd1, N'Đã xác nhận', 
        N'Booking test - Đã xác nhận bởi nhân viên', GETDATE(), GETDATE());

SET @bookingId1 = SCOPE_IDENTITY();
PRINT N'Đã tạo booking 1 (ID: ' + CAST(@bookingId1 AS NVARCHAR) + ') - Status: Đã xác nhận';

-- Booking 2: Ngày mai lúc 14:00
SET @appointmentStart2 = DATEADD(DAY, 1, CAST(GETDATE() AS DATE));
SET @appointmentStart2 = DATEADD(HOUR, 14, @appointmentStart2); -- 14:00
SET @appointmentEnd2 = DATEADD(MINUTE, 60, @appointmentStart2); -- 15:00

INSERT INTO Booking (customer_id, pet_id, appointment_start, appointment_end, status, note, created_at, updated_at)
VALUES (@customerId, @petId2, @appointmentStart2, @appointmentEnd2, N'Đã xác nhận', 
        N'Booking test - Đã xác nhận bởi nhân viên', GETDATE(), GETDATE());

SET @bookingId2 = SCOPE_IDENTITY();
PRINT N'Đã tạo booking 2 (ID: ' + CAST(@bookingId2 AS NVARCHAR) + ') - Status: Đã xác nhận';

-- Booking 3: Ngày kia lúc 09:00
SET @appointmentStart3 = DATEADD(DAY, 2, CAST(GETDATE() AS DATE));
SET @appointmentStart3 = DATEADD(HOUR, 9, @appointmentStart3); -- 09:00
SET @appointmentEnd3 = DATEADD(MINUTE, 45, @appointmentStart3); -- 09:45

INSERT INTO Booking (customer_id, pet_id, appointment_start, appointment_end, status, note, created_at, updated_at)
VALUES (@customerId, @petId1, @appointmentStart3, @appointmentEnd3, N'Đã xác nhận', 
        N'Booking test - Đã xác nhận bởi nhân viên', GETDATE(), GETDATE());

SET @bookingId3 = SCOPE_IDENTITY();
PRINT N'Đã tạo booking 3 (ID: ' + CAST(@bookingId3 AS NVARCHAR) + ') - Status: Đã xác nhận';

-- Bước 5: Tạo Booking_Service cho mỗi booking
INSERT INTO Booking_Service (booking_id, service_id, quantity, unit_price, duration_min, created_at)
VALUES (@bookingId1, @serviceId1, 1, 200000, 60, GETDATE());

INSERT INTO Booking_Service (booking_id, service_id, quantity, unit_price, duration_min, created_at)
VALUES (@bookingId2, @serviceId2, 1, 150000, 45, GETDATE());

INSERT INTO Booking_Service (booking_id, service_id, quantity, unit_price, duration_min, created_at)
VALUES (@bookingId3, @serviceId1, 2, 200000, 60, GETDATE()); -- quantity = 2

PRINT N'Đã tạo 3 booking_service records';

-- Kiểm tra kết quả
SELECT 
    b.booking_id,
    c.name AS customer_name,
    p.pet_name,
    ps.name AS service_name,
    b.status,
    b.appointment_start,
    b.appointment_end,
    bs.quantity,
    bs.unit_price
FROM Booking b
JOIN Customer c ON b.customer_id = c.customer_id
JOIN Pet p ON b.pet_id = p.id
JOIN Booking_Service bs ON b.booking_id = bs.booking_id
JOIN PetService ps ON bs.service_id = ps.service_id
WHERE c.name = N'Nguyễn Văn A' AND b.status = N'Đã xác nhận'
ORDER BY b.appointment_start;

PRINT N'Hoàn tất! Đã tạo booking với status "Đã xác nhận"';
GO

