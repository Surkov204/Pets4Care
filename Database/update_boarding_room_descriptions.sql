USE [SHOP_PET_Database]
GO

-- Bước 1: Kiểm tra và mở rộng cột description nếu cần
PRINT '=== KIỂM TRA VÀ MỞ RỘNG CỘT DESCRIPTION ==='
GO

-- Kiểm tra kích thước hiện tại của cột description
DECLARE @CurrentSize INT
SELECT @CurrentSize = CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'dbo' 
  AND TABLE_NAME = 'BoardingRoom' 
  AND COLUMN_NAME = 'description'

PRINT 'Kích thước hiện tại của cột description: ' + CAST(@CurrentSize AS VARCHAR(10))
GO

-- Mở rộng cột description thành NVARCHAR(MAX) để chứa mô tả dài
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
           WHERE TABLE_SCHEMA = 'dbo' 
             AND TABLE_NAME = 'BoardingRoom' 
             AND COLUMN_NAME = 'description')
BEGIN
    ALTER TABLE [dbo].[BoardingRoom]
    ALTER COLUMN [description] NVARCHAR(MAX)
    PRINT 'Đã mở rộng cột description thành NVARCHAR(MAX)'
END
ELSE
BEGIN
    PRINT 'Không tìm thấy cột description'
END
GO

-- Bước 2: Cập nhật mô tả chi tiết cho các phòng lưu trú
-- Mô tả bao gồm: tiện nghi, không gian, dịch vụ, đặc điểm nổi bật

PRINT '=== CẬP NHẬT MÔ TẢ CHI TIẾT CHO PHÒNG LƯU TRÚ ==='
GO

-- 1. Phòng Chó Lớn (Dog Large)
UPDATE [dbo].[BoardingRoom]
SET [description] = N'🏠 PHÒNG LƯU TRÚ CAO CẤP CHO CHÓ LỚN

✨ TIỆN NGHI:
• Hệ thống điều hòa không khí hiện đại
• Camera giám sát 24/7 đảm bảo an toàn
• Sàn chống trượt an toàn cho thú cưng
• Chuồng ngủ riêng biệt cho từng thú cưng
• Cửa sổ lớn đón ánh sáng tự nhiên

🏃 KHÔNG GIAN:
• Không gian rộng rãi, thoáng mát
• Khu vực vận động riêng cho chó lớn
• Khu vực ăn uống và nghỉ ngơi tách biệt
• Thiết kế phù hợp với các giống chó lớn

🧹 DỊCH VỤ:
• Vệ sinh và dọn dẹp hàng ngày
• Môi trường sạch sẽ, thông gió tốt
• Chăm sóc chuyên nghiệp bởi đội ngũ giàu kinh nghiệm'
WHERE [room_type] = N'dog_large'
GO

-- 2. Phòng Chó Nhỏ (Dog Small)
UPDATE [dbo].[BoardingRoom]
SET [description] = N'🏠 PHÒNG LƯU TRÚ ẤM CÚNG CHO CHÓ NHỎ

✨ TIỆN NGHI:
• Hệ thống điều hòa và sưởi ấm mùa đông
• Camera giám sát 24/7
• Chuồng ngủ ấm áp, khăn lót êm ái
• Không gian nhỏ gọn, riêng tư

🎮 KHU VỰC VUI CHƠI:
• Khu vực vui chơi nhỏ gọn phù hợp
• Đồ chơi đa dạng cho chó nhỏ
• Khu vực ăn uống riêng biệt
• Thiết kế an toàn, không góc cạnh

🔇 MÔI TRƯỜNG:
• Yên tĩnh, tránh tiếng ồn
• Phù hợp cho chó nhỏ nhạy cảm
• Tạo cảm giác an toàn và thoải mái

🧹 DỊCH VỤ:
• Vệ sinh và dọn dẹp hàng ngày
• Không gian luôn sạch sẽ, thơm tho
• Chăm sóc tận tình, chu đáo'
WHERE [room_type] = N'dog_small'
GO

-- 3. Phòng Mèo Lớn (Cat Large)
UPDATE [dbo].[BoardingRoom]
SET [description] = N'🏠 PHÒNG LƯU TRÚ CAO CẤP CHO MÈO LỚN

✨ TIỆN NGHI:
• Hệ thống kệ leo trèo đa tầng cao cấp
• Hộp cát vệ sinh riêng biệt cho từng mèo
• Khu vực nghỉ ngơi cao ráo, thoải mái
• Cửa sổ có lưới an toàn
• Hệ thống điều hòa không khí
• Camera giám sát 24/7
• Đèn chiếu sáng tự nhiên

🎮 KHU VỰC VUI CHƠI:
• Đồ chơi đa dạng, phong phú
• Cây cào móng cao cấp
• Nơi ẩn nấp riêng tư cho mèo
• Không gian rộng rãi để vận động

🔇 MÔI TRƯỜNG:
• Yên tĩnh, tránh stress
• Phù hợp với tính cách độc lập của mèo
• Không gian thoải mái, tự do

🧹 DỊCH VỤ:
• Vệ sinh hộp cát 2-3 lần/ngày
• Dọn dẹp phòng hàng ngày
• Không gian luôn sạch sẽ, không có mùi'
WHERE [room_type] = N'cat_large'
GO

-- 4. Phòng Mèo Nhỏ (Cat Small)
UPDATE [dbo].[BoardingRoom]
SET [description] = N'🏠 PHÒNG LƯU TRÚ YÊN TĨNH CHO MÈO NHỎ

✨ TIỆN NGHI:
• Kệ leo trèo phù hợp với mèo nhỏ
• Hộp cát vệ sinh riêng biệt
• Khu vực nghỉ ngơi ấm áp, êm ái
• Nơi ẩn nấp riêng tư
• Hệ thống điều hòa và sưởi ấm
• Camera giám sát 24/7
• Đèn chiếu sáng dịu nhẹ

🎮 KHU VỰC VUI CHƠI:
• Đồ chơi phù hợp với mèo nhỏ
• Cây cào móng nhỏ gọn
• Nơi quan sát bên ngoài an toàn
• Không gian nhỏ gọn, ấm cúng

🔇 MÔI TRƯỜNG:
• Cực kỳ yên tĩnh, tránh mọi tiếng ồn
• Phù hợp cho mèo nhỏ nhạy cảm
• Tạo cảm giác an toàn, thoải mái

🧹 DỊCH VỤ:
• Vệ sinh thường xuyên
• Dọn dẹp hàng ngày
• Không gian luôn sạch sẽ, thơm tho, an toàn'
WHERE [room_type] = N'cat_small'
GO

-- 5. Phòng Mèo VIP (Cat VIP)
UPDATE [dbo].[BoardingRoom]
SET [description] = N'🏠 PHÒNG LƯU TRÚ VIP CAO CẤP CHO MÈO

✨ TIỆN NGHI CAO CẤP:
• Hệ thống điều hòa không khí cao cấp
• Camera giám sát HD 24/7
• Cửa sổ lớn có lưới an toàn, đón ánh sáng tự nhiên
• Kệ leo trèo đa tầng cao cấp
• Hộp cát vệ sinh tự động
• Giường ngủ sang trọng, êm ái
• Nơi ẩn nấp riêng tư, cao cấp

🎮 KHU VỰC VUI CHƠI:
• Đồ chơi cao cấp, đa dạng
• Cây cào móng đa dạng, chất lượng
• Khu vực quan sát bên ngoài rộng rãi
• Không gian rộng rãi, thoáng mát

🔇 MÔI TRƯỜNG:
• Yên tĩnh tuyệt đối
• Âm thanh nhẹ nhàng, dễ chịu
• Phù hợp cho mèo VIP

⭐ DỊCH VỤ ĐẶC BIỆT:
• Vệ sinh hộp cát nhiều lần/ngày
• Dọn dẹp phòng 2 lần/ngày
• Kiểm tra sức khỏe hàng ngày
• Chế độ ăn uống cao cấp
• Chăm sóc tận tình, chu đáo'
WHERE [room_type] = N'cat_vip'
GO

-- 6. Phòng Mèo Tiêu Chuẩn (Cat Standard)
UPDATE [dbo].[BoardingRoom]
SET [description] = N'🏠 PHÒNG LƯU TRÚ TIÊU CHUẨN CHO MÈO

✨ TIỆN NGHI:
• Hệ thống điều hòa không khí
• Camera giám sát 24/7
• Đèn chiếu sáng tự nhiên
• Kệ leo trèo đa dạng
• Hộp cát vệ sinh riêng biệt
• Giường ngủ thoải mái
• Nơi ẩn nấp riêng tư

🎮 KHU VỰC VUI CHƠI:
• Đồ chơi đa dạng, phong phú
• Cây cào móng chất lượng
• Khu vực vui chơi và quan sát
• Không gian vừa phải, thoáng mát

🔇 MÔI TRƯỜNG:
• Yên tĩnh, phù hợp với tính cách mèo
• Không gian thoải mái, tự do
• Môi trường an toàn, sạch sẽ

🧹 DỊCH VỤ:
• Vệ sinh hộp cát 2 lần/ngày
• Dọn dẹp phòng hàng ngày
• Không gian luôn sạch sẽ, thơm tho
• Chế độ ăn uống phù hợp
• Nước uống sạch luôn có sẵn'
WHERE [room_type] = N'cat_standard'
GO

PRINT '=== HOÀN THÀNH CẬP NHẬT MÔ TẢ ==='
GO

-- Kiểm tra kết quả
SELECT [room_id], [room_name], [room_type], 
       LEFT([description], 100) + '...' as [description_preview]
FROM [dbo].[BoardingRoom]
ORDER BY [room_id]
GO

