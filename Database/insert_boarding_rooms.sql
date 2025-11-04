-- Script insert dữ liệu mẫu cho bảng BoardingRoom
USE [SHOP_PET_Database]
GO

-- Xóa dữ liệu cũ nếu có (tùy chọn)
-- DELETE FROM [dbo].[BoardingRoom]
-- GO

-- Insert phòng Chó Lớn
IF NOT EXISTS (SELECT 1 FROM [dbo].[BoardingRoom] WHERE room_type = 'dog_large')
BEGIN
    INSERT INTO [dbo].[BoardingRoom] 
    ([room_name], [room_type], [total_rooms], [price_per_day], [description], [status], [created_at], [updated_at])
    VALUES 
    (N'Phòng Chó Lớn', 'dog_large', 5, 400000, 
     N'Phòng rộng rãi, có camera và điều hòa cho chó lớn. Chăm sóc 24/7 với đội ngũ chuyên nghiệp.', 
     'available', GETDATE(), GETDATE())
    PRINT 'Inserted: Phòng Chó Lớn'
END
GO

-- Insert phòng Chó Nhỏ
IF NOT EXISTS (SELECT 1 FROM [dbo].[BoardingRoom] WHERE room_type = 'dog_small')
BEGIN
    INSERT INTO [dbo].[BoardingRoom] 
    ([room_name], [room_type], [total_rooms], [price_per_day], [description], [status], [created_at], [updated_at])
    VALUES 
    (N'Phòng Chó Nhỏ', 'dog_small', 8, 300000, 
     N'Phòng đôi cho chó nhỏ, có giường riêng. Không gian ấm cúng và an toàn.', 
     'available', GETDATE(), GETDATE())
    PRINT 'Inserted: Phòng Chó Nhỏ'
END
GO

-- Insert phòng Mèo Tiêu Chuẩn
IF NOT EXISTS (SELECT 1 FROM [dbo].[BoardingRoom] WHERE room_type = 'cat_standard')
BEGIN
    INSERT INTO [dbo].[BoardingRoom] 
    ([room_name], [room_type], [total_rooms], [price_per_day], [description], [status], [created_at], [updated_at])
    VALUES 
    (N'Phòng Mèo Tiêu Chuẩn', 'cat_standard', 10, 250000, 
     N'Phòng cho mèo, có cát vệ sinh và đồ chơi. Môi trường thoải mái cho mèo.', 
     'available', GETDATE(), GETDATE())
    PRINT 'Inserted: Phòng Mèo Tiêu Chuẩn'
END
GO

-- Insert phòng Mèo VIP
IF NOT EXISTS (SELECT 1 FROM [dbo].[BoardingRoom] WHERE room_type = 'cat_vip')
BEGIN
    INSERT INTO [dbo].[BoardingRoom] 
    ([room_name], [room_type], [total_rooms], [price_per_day], [description], [status], [created_at], [updated_at])
    VALUES 
    (N'Phòng Mèo VIP', 'cat_vip', 3, 350000, 
     N'Phòng VIP cho mèo, có khu chơi riêng và máy lạnh. Dịch vụ cao cấp nhất.', 
     'available', GETDATE(), GETDATE())
    PRINT 'Inserted: Phòng Mèo VIP'
END
GO

-- Kiểm tra dữ liệu đã insert
SELECT room_id, room_name, room_type, total_rooms, price_per_day, status 
FROM [dbo].[BoardingRoom]
ORDER BY room_type
GO

PRINT 'Hoàn tất insert dữ liệu phòng lưu trú!'
GO


