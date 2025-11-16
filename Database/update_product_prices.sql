-- Script cập nhật giá sản phẩm bằng một nửa giá thị trường
-- Thực hiện: Cập nhật giá cho tất cả sản phẩm dựa trên giá thị trường thực tế

USE [SHOP_PET_Database]
GO

-- Đồ chơi cho chó
UPDATE [dbo].[Products] 
SET [price] = CAST(25000.00 AS Decimal(18, 2))
WHERE [product_id] = 1 AND [name] = N'Xương cao su';

UPDATE [dbo].[Products] 
SET [price] = CAST(14000.00 AS Decimal(18, 2))
WHERE [product_id] = 6 AND [name] = N'Bóng tennis cho chó';

UPDATE [dbo].[Products] 
SET [price] = CAST(35000.00 AS Decimal(18, 2))
WHERE [product_id] = 8 AND [name] = N'Xương gặm gà sấy';

UPDATE [dbo].[Products] 
SET [price] = CAST(30000.00 AS Decimal(18, 2))
WHERE [product_id] = 13 AND [name] = N'Xương giả có mùi thịt bò';

UPDATE [dbo].[Products] 
SET [price] = CAST(30000.00 AS Decimal(18, 2))
WHERE [product_id] = 15 AND [name] = N'Dây kéo dạng vòng tay';

UPDATE [dbo].[Products] 
SET [price] = CAST(25000.00 AS Decimal(18, 2))
WHERE [product_id] = 18 AND [name] = N'Xương dây thừng 3 nút';

UPDATE [dbo].[Products] 
SET [price] = CAST(30000.00 AS Decimal(18, 2))
WHERE [product_id] = 20 AND [name] = N'Bóng nhựa gai mát xa';

-- Đồ chơi cho mèo
UPDATE [dbo].[Products] 
SET [price] = CAST(27500.00 AS Decimal(18, 2))
WHERE [product_id] = 5 AND [name] = N'Chuột có catnip';

UPDATE [dbo].[Products] 
SET [price] = CAST(10000.00 AS Decimal(18, 2))
WHERE [product_id] = 7 AND [name] = N'Chuông cổ mèo kêu nhẹ';

UPDATE [dbo].[Products] 
SET [price] = CAST(21000.00 AS Decimal(18, 2))
WHERE [product_id] = 9 AND [name] = N'Cần câu lông cho mèo';

UPDATE [dbo].[Products] 
SET [price] = CAST(90000.00 AS Decimal(18, 2))
WHERE [product_id] = 14 AND [name] = N'Đồ chơi mèo chạy pin';

UPDATE [dbo].[Products] 
SET [price] = CAST(20000.00 AS Decimal(18, 2))
WHERE [product_id] = 19 AND [name] = N'Chuột lông mini';

-- Đồ chơi bông
UPDATE [dbo].[Products] 
SET [price] = CAST(35000.00 AS Decimal(18, 2))
WHERE [product_id] = 2 AND [name] = N'Vịt bông kêu';

UPDATE [dbo].[Products] 
SET [price] = CAST(25000.00 AS Decimal(18, 2))
WHERE [product_id] = 11 AND [name] = N'Bóng bông lăn tròn';

UPDATE [dbo].[Products] 
SET [price] = CAST(30000.00 AS Decimal(18, 2))
WHERE [product_id] = 16 AND [name] = N'Đồ chơi cà rốt nhồi bông';

-- Đồ chơi điện tử/thông minh
UPDATE [dbo].[Products] 
SET [price] = CAST(70000.00 AS Decimal(18, 2))
WHERE [product_id] = 10 AND [name] = N'Bóng phát sáng có nhạc';

UPDATE [dbo].[Products] 
SET [price] = CAST(75000.00 AS Decimal(18, 2))
WHERE [product_id] = 17 AND [name] = N'Trứng rung thông minh';

-- Dụng cụ huấn luyện
UPDATE [dbo].[Products] 
SET [price] = CAST(17500.00 AS Decimal(18, 2))
WHERE [product_id] = 4 AND [name] = N'Clicker huấn luyện';

UPDATE [dbo].[Products] 
SET [price] = CAST(87500.00 AS Decimal(18, 2))
WHERE [product_id] = 12 AND [name] = N'Bộ huấn luyện kỷ luật';

-- Đồ chơi tương tác
UPDATE [dbo].[Products] 
SET [price] = CAST(50000.00 AS Decimal(18, 2))
WHERE [product_id] = 3 AND [name] = N'Đồ chơi mồi bánh';

-- Quần áo thú cưng
UPDATE [dbo].[Products] 
SET [price] = CAST(60000.00 AS Decimal(18, 2))
WHERE [product_id] = 21 AND [name] = N'Áo Quần Cho Cún ';

GO

-- Kiểm tra kết quả
SELECT [product_id], [name], [price]
FROM [dbo].[Products]
ORDER BY [product_id];

GO

