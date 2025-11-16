USE [SHOP_PET_Database]
GO

-- Script để cập nhật ảnh cho từng sản phẩm thức ăn
-- VẤN ĐỀ: URL postimg.cc hiện tại không phải là direct image URL
-- GIẢI PHÁP: Cần lấy direct image URL từ postimg.cc
-- 
-- Cách lấy direct image URL từ postimg.cc:
-- 1. Mở link postimg.cc (ví dụ: https://postimg.cc/9wmZgtzG)
-- 2. Click chuột phải vào ảnh và chọn "Copy image address" 
--    hoặc click vào ảnh để mở rộng, sau đó copy URL
-- 3. URL trực tiếp thường có format: https://i.postimg.cc/xxxxx/filename.jpg
--    hoặc https://postimg.cc/gallery/xxxxx/image.jpg
--
-- Sau khi có direct URL, thay thế các URL dưới đây:

-- Thức ăn cho chó
-- Product 22: Thức ăn hạt cho chó trưởng thành
UPDATE Products 
SET image_url = N'https://images.unsplash.com/photo-1605568427561-40dd23c2acea?w=500&h=500&fit=crop'
WHERE product_id = 22;
GO

-- Product 23: Thức ăn hạt cho chó con
-- THAY URL NÀY: https://postimg.cc/9wmZgtzG -> Lấy direct image URL
UPDATE Products 
SET image_url = N'PASTE_DIRECT_IMAGE_URL_HERE_23'
WHERE product_id = 23;
GO

-- Product 24: Pate cho chó vị thịt bò
-- THAY URL NÀY: https://postimg.cc/ftKBbb9S -> Lấy direct image URL
UPDATE Products 
SET image_url = N'PASTE_DIRECT_IMAGE_URL_HERE_24'
WHERE product_id = 24;
GO

-- Product 25: Thức ăn khô cho chó lớn tuổi
-- THAY URL NÀY: https://postimg.cc/7C1NBLXX -> Lấy direct image URL
UPDATE Products 
SET image_url = N'PASTE_DIRECT_IMAGE_URL_HERE_25'
WHERE product_id = 25;
GO

-- Product 26: Xương gặm dinh dưỡng cho chó
-- THAY URL NÀY: https://postimg.cc/qhM2jxN7 -> Lấy direct image URL
UPDATE Products 
SET image_url = N'PASTE_DIRECT_IMAGE_URL_HERE_26'
WHERE product_id = 26;
GO

-- Thức ăn cho mèo
-- Product 27: Thức ăn hạt cho mèo trưởng thành
-- THAY URL NÀY: https://postimg.cc/3kXphcpN -> Lấy direct image URL
UPDATE Products 
SET image_url = N'PASTE_DIRECT_IMAGE_URL_HERE_27'
WHERE product_id = 27;
GO

-- Product 28: Thức ăn hạt cho mèo con
-- THAY URL NÀY: https://postimg.cc/cgqV366q -> Lấy direct image URL
UPDATE Products 
SET image_url = N'PASTE_DIRECT_IMAGE_URL_HERE_28'
WHERE product_id = 28;
GO

-- Product 29: Pate cho mèo vị cá hồi
-- THAY URL NÀY: https://postimg.cc/kD77YhMQ -> Lấy direct image URL
UPDATE Products 
SET image_url = N'PASTE_DIRECT_IMAGE_URL_HERE_29'
WHERE product_id = 29;
GO

-- Product 30: Thức ăn khô cho mèo lớn tuổi
-- THAY URL NÀY: https://postimg.cc/Hcz1CdWF -> Lấy direct image URL
UPDATE Products 
SET image_url = N'PASTE_DIRECT_IMAGE_URL_HERE_30'
WHERE product_id = 30;
GO

-- Product 31: Thức ăn ướt cho mèo vị thịt gà
-- THAY URL NÀY: https://postimg.cc/Ppt0y9bN -> Lấy direct image URL
UPDATE Products 
SET image_url = N'PASTE_DIRECT_IMAGE_URL_HERE_31'
WHERE product_id = 31;
GO

PRINT 'Đã cập nhật URL ảnh! Kiểm tra lại các URL trực tiếp đã được thay thế chưa.';
GO

