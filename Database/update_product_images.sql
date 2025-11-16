USE [SHOP_PET_Database]
GO

-- Script để cập nhật ảnh cho từng sản phẩm thức ăn
-- Bạn có thể thay đổi URL ảnh tại đây cho từng sản phẩm

-- Thức ăn cho chó
-- Product 22: Thức ăn hạt cho chó trưởng thành (chưa có URL, giữ nguyên Unsplash)
UPDATE Products 
SET image_url = N'https://images.unsplash.com/photo-1605568427561-40dd23c2acea?w=500&h=500&fit=crop'
WHERE product_id = 22;
GO

-- Product 23: Thức ăn hạt cho chó con
UPDATE Products 
SET image_url = N'https://i.postimg.cc/4ytPdWgF/food2.jpg'
WHERE product_id = 23;
GO

-- Product 24: Pate cho chó vị thịt bò
UPDATE Products 
SET image_url = N'https://i.postimg.cc/MHk4dMZ5/food3.jpg'
WHERE product_id = 24;
GO

-- Product 25: Thức ăn khô cho chó lớn tuổi
UPDATE Products 
SET image_url = N'https://i.postimg.cc/KYws8kTX/food4.jpg'
WHERE product_id = 25;
GO

-- Product 26: Xương gặm dinh dưỡng cho chó
UPDATE Products 
SET image_url = N'https://i.postimg.cc/NMRbGNYR/food5.jpg'
WHERE product_id = 26;
GO

-- Thức ăn cho mèo
-- Product 27: Thức ăn hạt cho mèo trưởng thành
UPDATE Products 
SET image_url = N'https://i.postimg.cc/htw0LFtL/food6.jpg'
WHERE product_id = 27;
GO

-- Product 28: Thức ăn hạt cho mèo con
UPDATE Products 
SET image_url = N'https://i.postimg.cc/pTyxgFHd/food7.jpg'
WHERE product_id = 28;
GO

-- Product 29: Pate cho mèo vị cá hồi
UPDATE Products 
SET image_url = N'https://i.postimg.cc/Wpkt3QQH/food8.jpg'
WHERE product_id = 29;
GO

-- Product 30: Thức ăn khô cho mèo lớn tuổi
UPDATE Products 
SET image_url = N'https://i.postimg.cc/7h8H0ZFP/food9.webp'
WHERE product_id = 30;
GO

-- Product 31: Thức ăn ướt cho mèo vị thịt gà
UPDATE Products 
SET image_url = N'https://i.postimg.cc/Y9gkrwhN/food10.webp'
WHERE product_id = 31;
GO

PRINT 'Đã cập nhật thành công URL ảnh cho tất cả sản phẩm thức ăn!';
GO

