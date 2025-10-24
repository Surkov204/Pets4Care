-- Script để cập nhật password cho các doctor có password NULL
-- Chạy script này để có thể đăng nhập với các tài khoản doctor

USE SHOP_PET_Database;

-- Cập nhật password cho doctor có email "placeholder_*@local.test" (doctor_id = 3)
UPDATE Doctor 
SET password = 'placeholder123' 
WHERE doctor_id = 3 AND password IS NULL;

-- Cập nhật password cho doctor có email "a@example.com" (doctor_id = 4)  
UPDATE Doctor 
SET password = 'doctor123' 
WHERE doctor_id = 4 AND password IS NULL;

-- Kiểm tra kết quả
SELECT doctor_id, name, email, password, specialization 
FROM Doctor 
ORDER BY doctor_id;

-- Thông tin đăng nhập cho testing:
-- Doctor B: email = "doctorb@example.com", password = "pass123"
-- Doctor C: email = "doctorc@example.com", password = "pass456" 
-- Doctor D: email = "doctord@example.com", password = "pass789"
-- Doctor A: email = "a@example.com", password = "doctor123" (vừa cập nhật)
-- Placeholder Doctor: email = "placeholder_*@local.test", password = "placeholder123" (vừa cập nhật)
