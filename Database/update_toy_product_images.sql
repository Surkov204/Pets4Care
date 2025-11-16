USE [SHOP_PET_Database]
GO

-- Script để cập nhật ảnh cho các sản phẩm đồ chơi (product_id 1-15)

-- Product 1: Xương cao su
UPDATE Products 
SET image_url = N'https://i.postimg.cc/15s5J4jp/toy_1.jpg'
WHERE product_id = 1;
GO

-- Product 2: Vịt bông kêu
UPDATE Products 
SET image_url = N'https://i.postimg.cc/jSNpmYkw/toy-2.jpg'
WHERE product_id = 2;
GO

-- Product 3
UPDATE Products 
SET image_url = N'https://i.postimg.cc/C1vXkhzw/toy-3.jpg'
WHERE product_id = 3;
GO

-- Product 4
UPDATE Products 
SET image_url = N'https://i.postimg.cc/WpHx41BY/toy-4.jpg'
WHERE product_id = 4;
GO

-- Product 5
UPDATE Products 
SET image_url = N'https://i.postimg.cc/BvpVfS5y/toy-5.jpg'
WHERE product_id = 5;
GO

-- Product 6
UPDATE Products 
SET image_url = N'https://i.postimg.cc/VvrGtXxT/toy-6.jpg'
WHERE product_id = 6;
GO

-- Product 7
UPDATE Products 
SET image_url = N'https://i.postimg.cc/7Y7D8z5W/toy-7.jpg'
WHERE product_id = 7;
GO

-- Product 8
UPDATE Products 
SET image_url = N'https://i.postimg.cc/N0GwHPpV/toy-8.jpg'
WHERE product_id = 8;
GO

-- Product 9
UPDATE Products 
SET image_url = N'https://i.postimg.cc/k4zrLMq3/toy-9.jpg'
WHERE product_id = 9;
GO

-- Product 10
UPDATE Products 
SET image_url = N'https://i.postimg.cc/dQZcrCmN/toy-10.jpg'
WHERE product_id = 10;
GO

-- Product 11
UPDATE Products 
SET image_url = N'https://i.postimg.cc/zG5sscmd/toy-11.jpg'
WHERE product_id = 11;
GO

-- Product 12
UPDATE Products 
SET image_url = N'https://i.postimg.cc/8CXxrkFs/toy-12.jpg'
WHERE product_id = 12;
GO

-- Product 13
UPDATE Products 
SET image_url = N'https://i.postimg.cc/PJY7cmS1/toy-13.jpg'
WHERE product_id = 13;
GO

-- Product 14
UPDATE Products 
SET image_url = N'https://i.postimg.cc/MK04mmMx/toy-14.jpg'
WHERE product_id = 14;
GO

-- Product 15
UPDATE Products 
SET image_url = N'https://i.postimg.cc/nLWwhd5b/toy-15.jpg'
WHERE product_id = 15;
GO

PRINT 'Đã cập nhật thành công URL ảnh cho các sản phẩm đồ chơi (product_id 1-15)!';
GO

