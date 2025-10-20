-- Script thêm dữ liệu mẫu vào bảng Pet
USE [SHOP_PET_Database]
GO

-- Kiểm tra xem có customer nào không
IF NOT EXISTS (SELECT * FROM Customer)
BEGIN
    PRINT 'Không có customer nào trong database. Vui lòng tạo customer trước.'
    RETURN
END

-- Lấy customer_id đầu tiên
DECLARE @customer_id INT
SELECT TOP 1 @customer_id = customer_id FROM Customer

IF @customer_id IS NULL
BEGIN
    PRINT 'Không tìm thấy customer nào'
    RETURN
END

PRINT 'Sử dụng customer_id: ' + CAST(@customer_id AS VARCHAR(10))

-- Thêm dữ liệu mẫu
INSERT INTO Pet (customer_id, pet_name, species, breed, age, gender, description, health_status, image_path)
VALUES 
    (@customer_id, N'Mít', N'Chó', N'Poodle', 3, 'male', N'Chó con dễ thương, thích chơi đùa', N'Khỏe mạnh', 'images/pets/mit.jpg'),
    (@customer_id, N'Mèo Mun', N'Mèo', N'Mèo ta', 2, 'female', N'Mèo con hiền lành, thích nằm nắng', N'Bị dị ứng nhẹ', 'images/pets/meo_mun.jpg')

PRINT 'Đã thêm dữ liệu mẫu vào bảng Pet'

-- Kiểm tra dữ liệu
SELECT 
    id,
    customer_id,
    pet_name,
    species,
    breed,
    age,
    gender,
    description,
    health_status,
    image_path,
    created_at,
    updated_at
FROM Pet

PRINT 'Hoàn thành thêm dữ liệu mẫu'
