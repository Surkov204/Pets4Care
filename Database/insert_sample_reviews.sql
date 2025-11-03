USE [SHOP_PET_Database]
GO

-- Script để thêm CỰC NHIỀU reviews cho các dịch vụ Spa
-- Tạo 1000+ reviews với phân bố rating tự nhiên

-- Lấy danh sách service_id và customer_id có sẵn
DECLARE @serviceIds TABLE (id INT IDENTITY(1,1), service_id INT);
DECLARE @customerIds TABLE (id INT IDENTITY(1,1), customer_id INT);

-- Lấy tất cả service_id từ bảng PetService (spa services)
INSERT INTO @serviceIds (service_id)
SELECT service_id FROM PetService WHERE service_type = 'spa' AND status = 'active';

-- Lấy tất cả customer_id từ bảng Customer
INSERT INTO @customerIds (customer_id)
SELECT customer_id FROM Customer;

-- Kiểm tra xem có dữ liệu không
IF NOT EXISTS (SELECT 1 FROM @serviceIds) OR NOT EXISTS (SELECT 1 FROM @customerIds)
BEGIN
    PRINT 'Lỗi: Không tìm thấy service_id hoặc customer_id nào!';
    RETURN;
END

PRINT 'Đang tạo reviews... (Có thể mất vài phút)';

-- Tạo nhiều reviews bằng cách loop và insert
DECLARE @counter INT = 0;
DECLARE @maxReviews INT = 1000; -- Tạo 1000 reviews
DECLARE @serviceId INT;
DECLARE @customerId INT;
DECLARE @rating INT;
DECLARE @comment NVARCHAR(1000);
DECLARE @daysOffset INT;

-- Comments mẫu theo rating (nhiều biến thể)
DECLARE @comments5 TABLE (comment NVARCHAR(1000));
INSERT INTO @comments5 VALUES
(N'Dịch vụ tuyệt vời! Thú cưng rất thích, nhân viên chuyên nghiệp và tận tâm. Tôi sẽ quay lại!'),
(N'Xuất sắc! Thú cưng được chăm sóc rất kỹ lưỡng, không gian sạch sẽ.'),
(N'Rất hài lòng! Dịch vụ đúng như mô tả, chất lượng cao, giá cả hợp lý.'),
(N'Tuyệt vời nhất! Nhân viên thân thiện, thú cưng rất thoải mái.'),
(N'Dịch vụ tốt nhất tôi từng dùng! Sẽ giới thiệu cho bạn bè.'),
(N'Hoàn hảo! Thú cưng trông đẹp hơn rất nhiều sau khi dùng dịch vụ.');

DECLARE @comments4 TABLE (comment NVARCHAR(1000));
INSERT INTO @comments4 VALUES
(N'Dịch vụ khá tốt, chất lượng ổn. Nhìn chung hài lòng, sẽ quay lại lần sau.'),
(N'Tốt nhưng còn một số điểm cần cải thiện. Nhân viên chuyên nghiệp.'),
(N'Chất lượng dịch vụ ổn, giá cả hợp lý. Thời gian phục vụ hơi lâu một chút.'),
(N'Khá hài lòng. Có thể cải thiện thêm về không gian và trang thiết bị.'),
(N'Tốt, đáng giá tiền. Thú cưng được chăm sóc tốt.');

DECLARE @comments3 TABLE (comment NVARCHAR(1000));
INSERT INTO @comments3 VALUES
(N'Dịch vụ bình thường, không có gì nổi bật. Cần cải thiện thêm một số điểm.'),
(N'Ổn nhưng không như mong đợi. Thời gian phục vụ hơi lâu.'),
(N'Dịch vụ tạm được, giá cả hợp lý nhưng chất lượng cần cải thiện.'),
(N'Không tệ nhưng cũng không tốt lắm. Nhân viên cần chuyên nghiệp hơn.'),
(N'Bình thường, không có ấn tượng đặc biệt.');

DECLARE @comments2 TABLE (comment NVARCHAR(1000));
INSERT INTO @comments2 VALUES
(N'Không hài lòng lắm. Thời gian phục vụ hơi lâu, nhân viên thiếu chuyên nghiệp.'),
(N'Cần cải thiện nhiều. Dịch vụ không đúng như mong đợi.'),
(N'Thất vọng một chút. Chất lượng dịch vụ không tốt như quảng cáo.'),
(N'Cần nâng cao chất lượng. Thời gian phục vụ quá lâu.');

DECLARE @comments1 TABLE (comment NVARCHAR(1000));
INSERT INTO @comments1 VALUES
(N'Rất thất vọng với dịch vụ. Chất lượng kém, nhân viên thiếu chuyên nghiệp.'),
(N'Dịch vụ tệ. Không đúng như quảng cáo, thất vọng.'),
(N'Không hài lòng. Chất lượng kém, cần cải thiện ngay.'),
(N'Thất vọng hoàn toàn. Dịch vụ không đạt yêu cầu.');

WHILE @counter < @maxReviews
BEGIN
    -- Random service_id
    SELECT TOP 1 @serviceId = service_id 
    FROM @serviceIds 
    ORDER BY NEWID();
    
    -- Random customer_id
    SELECT TOP 1 @customerId = customer_id 
    FROM @customerIds 
    ORDER BY NEWID();
    
    -- Random rating với phân bố thực tế (nhiều 5 sao, ít 1 sao)
    DECLARE @rand FLOAT = RAND();
    IF @rand < 0.35
        SET @rating = 5;
    ELSE IF @rand < 0.60
        SET @rating = 4;
    ELSE IF @rand < 0.80
        SET @rating = 3;
    ELSE IF @rand < 0.92
        SET @rating = 2;
    ELSE
        SET @rating = 1;
    
    -- Chọn comment ngẫu nhiên theo rating
    IF @rating = 5
        SELECT TOP 1 @comment = comment FROM @comments5 ORDER BY NEWID();
    ELSE IF @rating = 4
        SELECT TOP 1 @comment = comment FROM @comments4 ORDER BY NEWID();
    ELSE IF @rating = 3
        SELECT TOP 1 @comment = comment FROM @comments3 ORDER BY NEWID();
    ELSE IF @rating = 2
        SELECT TOP 1 @comment = comment FROM @comments2 ORDER BY NEWID();
    ELSE
        SELECT TOP 1 @comment = comment FROM @comments1 ORDER BY NEWID();
    
    -- Thêm số thứ tự để comment khác nhau
    SET @comment = @comment + N' [' + CAST(@counter AS NVARCHAR(10)) + N']';
    
    -- Random ngày trong 60 ngày qua
    SET @daysOffset = CAST(RAND() * 60 AS INT);
    
    -- Insert review
    BEGIN TRY
        INSERT INTO Review (rating, comment, service_id, customer_id, created_at)
        VALUES (
            @rating, 
            @comment, 
            @serviceId, 
            @customerId, 
            DATEADD(DAY, -@daysOffset, SYSDATETIME())
        );
        
        SET @counter = @counter + 1;
        
        -- Log mỗi 100 reviews
        IF @counter % 100 = 0
            PRINT 'Đã tạo ' + CAST(@counter AS VARCHAR(10)) + ' reviews...';
    END TRY
    BEGIN CATCH
        -- Bỏ qua lỗi duplicate hoặc constraint và tiếp tục
    END CATCH
END

PRINT 'Hoàn thành! Đã tạo ' + CAST(@counter AS VARCHAR(10)) + ' reviews.';

-- Hiển thị thống kê reviews theo service và rating
SELECT 
    s.service_id,
    s.name AS service_name,
    r.rating,
    COUNT(*) as review_count,
    CAST(AVG(CAST(r.rating AS FLOAT)) AS DECIMAL(3,2)) as avg_rating
FROM Review r
INNER JOIN PetService s ON r.service_id = s.service_id
WHERE r.service_id IS NOT NULL
GROUP BY s.service_id, s.name, r.rating
ORDER BY s.service_id, r.rating DESC;

-- Tổng kết
SELECT 
    'Tổng số reviews' AS thong_ke,
    COUNT(*) AS so_luong
FROM Review
WHERE service_id IS NOT NULL
UNION ALL
SELECT 
    'Đánh giá trung bình',
    CAST(AVG(CAST(rating AS FLOAT)) AS INT)
FROM Review
WHERE service_id IS NOT NULL;

GO
