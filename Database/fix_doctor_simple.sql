-- ==========================================
-- FIX DOCTOR TABLE - Simple Version
-- ==========================================

USE SHOP_PET_Database;
GO

-- Kiểm tra cấu trúc hiện tại
PRINT 'Cấu trúc bảng Doctor hiện tại:'
SELECT COLUMN_NAME, DATA_TYPE 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'Doctor';
GO

-- Thêm cột description nếu chưa có
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'Doctor' AND COLUMN_NAME = 'description')
BEGIN
    ALTER TABLE Doctor ADD description NVARCHAR(MAX) NULL;
    PRINT 'Đã thêm cột description';
END
GO

-- Thêm cột status nếu chưa có
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'Doctor' AND COLUMN_NAME = 'status')
BEGIN
    ALTER TABLE Doctor ADD status NVARCHAR(20) DEFAULT 'active';
    PRINT 'Đã thêm cột status';
END
GO

-- Xóa doctor test cũ nếu có
DELETE FROM Doctor WHERE email = 'doctor@test.com';
GO

-- Tạo doctor test
INSERT INTO Doctor (name, email, password, phone, specialization, description, status)
VALUES (
    N'Bác sĩ Test',
    'doctor@test.com',
    'doctor123',
    '0909123456',
    N'Thú y tổng quát',
    N'Tài khoản test',
    'active'
);
GO

-- Set password cho các doctor cũ
UPDATE Doctor SET password = 'doctor123' WHERE password IS NULL;
UPDATE Doctor SET status = 'active' WHERE status IS NULL;
GO

-- Kiểm tra kết quả
SELECT 
    doctor_id,
    name,
    email,
    password,
    phone,
    specialization,
    status
FROM Doctor;
GO

PRINT ''
PRINT '=========================================='
PRINT 'THÔNG TIN ĐĂNG NHẬP:'
PRINT 'Email: doctor@test.com'
PRINT 'Password: doctor123'
PRINT '=========================================='

