USE [SHOP_PET_Database]
GO

-- Thêm cột image_url vào bảng Products nếu chưa có
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('Products') AND name = 'image_url')
BEGIN
    ALTER TABLE Products ADD image_url NVARCHAR(500) NULL;
    PRINT 'Đã thêm cột image_url vào bảng Products';
END
GO

-- Thêm các sản phẩm thức ăn cho chó và mèo
-- Lưu ý: Cần có category_id phù hợp, hiện tại database có category 1-5 là đồ chơi
-- Có thể cần tạo category mới cho thức ăn hoặc sử dụng category hiện có

-- Kiểm tra xem có category thức ăn chưa, nếu chưa thì tạo mới
IF NOT EXISTS (SELECT 1 FROM ProductCategory WHERE name LIKE N'%thức ăn%' OR name LIKE N'%Thức ăn%')
BEGIN
    -- Thêm category mới cho thức ăn
    SET IDENTITY_INSERT ProductCategory ON;
    INSERT INTO ProductCategory (category_id, name) VALUES (6, N'Thức ăn cho chó');
    INSERT INTO ProductCategory (category_id, name) VALUES (7, N'Thức ăn cho mèo');
    SET IDENTITY_INSERT ProductCategory OFF;
END
GO

-- Thêm sản phẩm thức ăn cho chó
-- Kiểm tra và thêm sản phẩm nếu chưa tồn tại
IF NOT EXISTS (SELECT 1 FROM Products WHERE product_id = 22)
BEGIN
    SET IDENTITY_INSERT Products ON;
    INSERT INTO Products (product_id, name, price, stock_quantity, description, supplier_id, category_id, admin_id, image_url) 
    VALUES (22, N'Thức ăn hạt cho chó trưởng thành', CAST(150000.00 AS Decimal(18, 2)), 100, 
            N'Thức ăn hạt đầy đủ dinh dưỡng cho chó trưởng thành, giàu protein và vitamin', 1, 6, 1,
            N'https://images.unsplash.com/photo-1605568427561-40dd23c2acea?w=500&h=500&fit=crop');
    SET IDENTITY_INSERT Products OFF;
END
ELSE
BEGIN
    -- Cập nhật sản phẩm nếu đã tồn tại
    UPDATE Products 
    SET name = N'Thức ăn hạt cho chó trưởng thành',
        price = CAST(150000.00 AS Decimal(18, 2)),
        stock_quantity = 100,
        description = N'Thức ăn hạt đầy đủ dinh dưỡng cho chó trưởng thành, giàu protein và vitamin',
        supplier_id = 1,
        category_id = 6,
        admin_id = 1,
        image_url = N'https://images.unsplash.com/photo-1605568427561-40dd23c2acea?w=500&h=500&fit=crop'
    WHERE product_id = 22;
END
GO

IF NOT EXISTS (SELECT 1 FROM Products WHERE product_id = 23)
BEGIN
    SET IDENTITY_INSERT Products ON;
    INSERT INTO Products (product_id, name, price, stock_quantity, description, supplier_id, category_id, admin_id, image_url) 
    VALUES (23, N'Thức ăn hạt cho chó con', CAST(180000.00 AS Decimal(18, 2)), 80, 
            N'Thức ăn hạt chuyên biệt cho chó con, hỗ trợ phát triển xương và cơ bắp', 1, 6, 1,
            N'https://i.postimg.cc/4ytPdWgF/food2.jpg');
    SET IDENTITY_INSERT Products OFF;
END
ELSE
BEGIN
    UPDATE Products SET name = N'Thức ăn hạt cho chó con', price = CAST(180000.00 AS Decimal(18, 2)), stock_quantity = 80,
        description = N'Thức ăn hạt chuyên biệt cho chó con, hỗ trợ phát triển xương và cơ bắp',
        supplier_id = 1, category_id = 6, admin_id = 1,
        image_url = N'https://i.postimg.cc/4ytPdWgF/food2.jpg'
    WHERE product_id = 23;
END
GO

IF NOT EXISTS (SELECT 1 FROM Products WHERE product_id = 24)
BEGIN
    SET IDENTITY_INSERT Products ON;
    INSERT INTO Products (product_id, name, price, stock_quantity, description, supplier_id, category_id, admin_id, image_url) 
    VALUES (24, N'Pate cho chó vị thịt bò', CAST(35000.00 AS Decimal(18, 2)), 120, 
            N'Pate mềm thơm ngon vị thịt bò, dễ tiêu hóa cho chó mọi lứa tuổi', 2, 6, 1,
            N'https://i.postimg.cc/MHk4dMZ5/food3.jpg');
    SET IDENTITY_INSERT Products OFF;
END
ELSE
BEGIN
    UPDATE Products SET name = N'Pate cho chó vị thịt bò', price = CAST(35000.00 AS Decimal(18, 2)), stock_quantity = 120,
        description = N'Pate mềm thơm ngon vị thịt bò, dễ tiêu hóa cho chó mọi lứa tuổi',
        supplier_id = 2, category_id = 6, admin_id = 1,
        image_url = N'https://i.postimg.cc/MHk4dMZ5/food3.jpg'
    WHERE product_id = 24;
END
GO

IF NOT EXISTS (SELECT 1 FROM Products WHERE product_id = 25)
BEGIN
    SET IDENTITY_INSERT Products ON;
    INSERT INTO Products (product_id, name, price, stock_quantity, description, supplier_id, category_id, admin_id, image_url) 
    VALUES (25, N'Thức ăn khô cho chó lớn tuổi', CAST(200000.00 AS Decimal(18, 2)), 60, 
            N'Thức ăn đặc biệt cho chó lớn tuổi, dễ nhai và tiêu hóa, bổ sung canxi', 3, 6, 2,
            N'https://i.postimg.cc/KYws8kTX/food4.jpg');
    SET IDENTITY_INSERT Products OFF;
END
ELSE
BEGIN
    UPDATE Products SET name = N'Thức ăn khô cho chó lớn tuổi', price = CAST(200000.00 AS Decimal(18, 2)), stock_quantity = 60,
        description = N'Thức ăn đặc biệt cho chó lớn tuổi, dễ nhai và tiêu hóa, bổ sung canxi',
        supplier_id = 3, category_id = 6, admin_id = 2,
        image_url = N'https://i.postimg.cc/KYws8kTX/food4.jpg'
    WHERE product_id = 25;
END
GO

IF NOT EXISTS (SELECT 1 FROM Products WHERE product_id = 26)
BEGIN
    SET IDENTITY_INSERT Products ON;
    INSERT INTO Products (product_id, name, price, stock_quantity, description, supplier_id, category_id, admin_id, image_url) 
    VALUES (26, N'Xương gặm dinh dưỡng cho chó', CAST(45000.00 AS Decimal(18, 2)), 90, 
            N'Xương gặm có bổ sung dinh dưỡng, giúp làm sạch răng và cung cấp canxi', 1, 6, 1,
            N'https://i.postimg.cc/NMRbGNYR/food5.jpg');
    SET IDENTITY_INSERT Products OFF;
END
ELSE
BEGIN
    UPDATE Products SET name = N'Xương gặm dinh dưỡng cho chó', price = CAST(45000.00 AS Decimal(18, 2)), stock_quantity = 90,
        description = N'Xương gặm có bổ sung dinh dưỡng, giúp làm sạch răng và cung cấp canxi',
        supplier_id = 1, category_id = 6, admin_id = 1,
        image_url = N'https://i.postimg.cc/NMRbGNYR/food5.jpg'
    WHERE product_id = 26;
END
GO

-- Thức ăn cho mèo
IF NOT EXISTS (SELECT 1 FROM Products WHERE product_id = 27)
BEGIN
    SET IDENTITY_INSERT Products ON;
    INSERT INTO Products (product_id, name, price, stock_quantity, description, supplier_id, category_id, admin_id, image_url) 
    VALUES (27, N'Thức ăn hạt cho mèo trưởng thành', CAST(140000.00 AS Decimal(18, 2)), 100, 
            N'Thức ăn hạt đầy đủ dinh dưỡng cho mèo trưởng thành, giàu protein từ cá', 2, 7, 1,
            N'https://i.postimg.cc/htw0LFtL/food6.jpg');
    SET IDENTITY_INSERT Products OFF;
END
ELSE
BEGIN
    UPDATE Products SET name = N'Thức ăn hạt cho mèo trưởng thành', price = CAST(140000.00 AS Decimal(18, 2)), stock_quantity = 100,
        description = N'Thức ăn hạt đầy đủ dinh dưỡng cho mèo trưởng thành, giàu protein từ cá',
        supplier_id = 2, category_id = 7, admin_id = 1,
        image_url = N'https://i.postimg.cc/htw0LFtL/food6.jpg'
    WHERE product_id = 27;
END
GO

IF NOT EXISTS (SELECT 1 FROM Products WHERE product_id = 28)
BEGIN
    SET IDENTITY_INSERT Products ON;
    INSERT INTO Products (product_id, name, price, stock_quantity, description, supplier_id, category_id, admin_id, image_url) 
    VALUES (28, N'Thức ăn hạt cho mèo con', CAST(170000.00 AS Decimal(18, 2)), 85, 
            N'Thức ăn hạt chuyên biệt cho mèo con, hỗ trợ phát triển toàn diện', 2, 7, 1,
            N'https://i.postimg.cc/pTyxgFHd/food7.jpg');
    SET IDENTITY_INSERT Products OFF;
END
ELSE
BEGIN
    UPDATE Products SET name = N'Thức ăn hạt cho mèo con', price = CAST(170000.00 AS Decimal(18, 2)), stock_quantity = 85,
        description = N'Thức ăn hạt chuyên biệt cho mèo con, hỗ trợ phát triển toàn diện',
        supplier_id = 2, category_id = 7, admin_id = 1,
        image_url = N'https://i.postimg.cc/pTyxgFHd/food7.jpg'
    WHERE product_id = 28;
END
GO

IF NOT EXISTS (SELECT 1 FROM Products WHERE product_id = 29)
BEGIN
    SET IDENTITY_INSERT Products ON;
    INSERT INTO Products (product_id, name, price, stock_quantity, description, supplier_id, category_id, admin_id, image_url) 
    VALUES (29, N'Pate cho mèo vị cá hồi', CAST(32000.00 AS Decimal(18, 2)), 110, 
            N'Pate mềm thơm ngon vị cá hồi, giàu omega-3 tốt cho lông mèo', 3, 7, 2,
            N'https://i.postimg.cc/Wpkt3QQH/food8.jpg');
    SET IDENTITY_INSERT Products OFF;
END
ELSE
BEGIN
    UPDATE Products SET name = N'Pate cho mèo vị cá hồi', price = CAST(32000.00 AS Decimal(18, 2)), stock_quantity = 110,
        description = N'Pate mềm thơm ngon vị cá hồi, giàu omega-3 tốt cho lông mèo',
        supplier_id = 3, category_id = 7, admin_id = 2,
        image_url = N'https://i.postimg.cc/Wpkt3QQH/food8.jpg'
    WHERE product_id = 29;
END
GO

IF NOT EXISTS (SELECT 1 FROM Products WHERE product_id = 30)
BEGIN
    SET IDENTITY_INSERT Products ON;
    INSERT INTO Products (product_id, name, price, stock_quantity, description, supplier_id, category_id, admin_id, image_url) 
    VALUES (30, N'Thức ăn khô cho mèo lớn tuổi', CAST(190000.00 AS Decimal(18, 2)), 65, 
            N'Thức ăn đặc biệt cho mèo lớn tuổi, dễ nhai, hỗ trợ tiêu hóa và sức khỏe thận', 1, 7, 1,
            N'https://i.postimg.cc/7h8H0ZFP/food9.webp');
    SET IDENTITY_INSERT Products OFF;
END
ELSE
BEGIN
    UPDATE Products SET name = N'Thức ăn khô cho mèo lớn tuổi', price = CAST(190000.00 AS Decimal(18, 2)), stock_quantity = 65,
        description = N'Thức ăn đặc biệt cho mèo lớn tuổi, dễ nhai, hỗ trợ tiêu hóa và sức khỏe thận',
        supplier_id = 1, category_id = 7, admin_id = 1,
        image_url = N'https://i.postimg.cc/7h8H0ZFP/food9.webp'
    WHERE product_id = 30;
END
GO

IF NOT EXISTS (SELECT 1 FROM Products WHERE product_id = 31)
BEGIN
    SET IDENTITY_INSERT Products ON;
    INSERT INTO Products (product_id, name, price, stock_quantity, description, supplier_id, category_id, admin_id, image_url) 
    VALUES (31, N'Thức ăn ướt cho mèo vị thịt gà', CAST(28000.00 AS Decimal(18, 2)), 95, 
            N'Thức ăn ướt mềm vị thịt gà, giàu protein, phù hợp cho mèo kén ăn', 2, 7, 1,
            N'https://i.postimg.cc/Y9gkrwhN/food10.webp');
    SET IDENTITY_INSERT Products OFF;
END
ELSE
BEGIN
    UPDATE Products SET name = N'Thức ăn ướt cho mèo vị thịt gà', price = CAST(28000.00 AS Decimal(18, 2)), stock_quantity = 95,
        description = N'Thức ăn ướt mềm vị thịt gà, giàu protein, phù hợp cho mèo kén ăn',
        supplier_id = 2, category_id = 7, admin_id = 1,
        image_url = N'https://i.postimg.cc/Y9gkrwhN/food10.webp'
    WHERE product_id = 31;
END
GO

PRINT 'Đã thêm thành công các sản phẩm thức ăn cho chó và mèo!';
GO

