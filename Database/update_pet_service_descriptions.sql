USE [SHOP_PET_Database]
GO

-- Bước 1: Kiểm tra và đảm bảo cột description có thể chứa mô tả dài
PRINT '=== KIỂM TRA CỘT DESCRIPTION ==='
GO

-- Kiểm tra kích thước hiện tại của cột description
DECLARE @CurrentSize INT
SELECT @CurrentSize = CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'dbo' 
  AND TABLE_NAME = 'PetService' 
  AND COLUMN_NAME = 'description'

IF @CurrentSize IS NOT NULL
BEGIN
    PRINT 'Kích thước hiện tại của cột description: ' + CAST(@CurrentSize AS VARCHAR(10))
    
    -- Nếu không phải MAX thì mở rộng thành NVARCHAR(MAX)
    IF @CurrentSize <> -1
    BEGIN
        ALTER TABLE [dbo].[PetService]
        ALTER COLUMN [description] NVARCHAR(MAX)
        PRINT 'Đã mở rộng cột description thành NVARCHAR(MAX)'
    END
    ELSE
    BEGIN
        PRINT 'Cột description đã là NVARCHAR(MAX)'
    END
END
ELSE
BEGIN
    PRINT 'Không tìm thấy cột description'
END
GO

-- Bước 2: Cập nhật mô tả chi tiết cho các dịch vụ spa phổ biến
PRINT '=== CẬP NHẬT MÔ TẢ CHI TIẾT CHO DỊCH VỤ SPA ==='
GO

-- 1. Tắm rửa cơ bản
UPDATE [dbo].[PetService]
SET [description] = N'🛁 DỊCH VỤ TẮM RỬA CƠ BẢN

✨ QUY TRÌNH: • Tắm rửa toàn thân với sữa tắm chuyên dụng • Vệ sinh kỹ lưỡng các khu vực nhạy cảm • Sấy khô lông bằng máy sấy chuyên nghiệp • Chải lông mượt mà, loại bỏ lông rụng

🧴 SẢN PHẨM: • Sữa tắm chuyên dụng cho thú cưng • Dầu gội dịu nhẹ, không gây kích ứng • Sản phẩm an toàn, tự nhiên • Phù hợp với mọi loại da và lông

⏱️ THỜI GIAN: • Quy trình hoàn chỉnh từ 30-45 phút • Đảm bảo thú cưng sạch sẽ, thơm tho • Chăm sóc nhẹ nhàng, không gây stress'
WHERE ([name] LIKE N'%Tắm%' OR [name] LIKE N'%tắm%')
  AND [service_type] = N'spa'
  AND ([name] NOT LIKE N'%Spa cao cấp%' AND [name] NOT LIKE N'%spa cao cấp%')
GO

-- 2. Tắm rửa cao cấp / Spa cao cấp
UPDATE [dbo].[PetService]
SET [description] = N'✨ DỊCH VỤ SPA CAO CẤP

✨ QUY TRÌNH ĐẦY ĐỦ: • Tắm rửa với sữa tắm cao cấp, có mùi hương dễ chịu • Xông hơi nhẹ nhàng để làm sạch sâu lỗ chân lông • Tẩy tế bào chết dịu nhẹ cho da • Đắp mặt nạ dưỡng da và lông • Massage thư giãn toàn thân • Sấy khô lông bằng máy sấy chuyên nghiệp • Chải lông mượt mà, tạo kiểu đẹp

💎 SẢN PHẨM CAO CẤP: • Sữa tắm nhập khẩu chất lượng cao • Mặt nạ dưỡng da và lông chuyên dụng • Tinh dầu thư giãn tự nhiên • Sản phẩm không gây kích ứng, an toàn

💆 TRẢI NGHIỆM: • Massage thư giãn toàn thân • Môi trường spa sang trọng, yên tĩnh • Chăm sóc tận tình, chuyên nghiệp • Thú cưng được thư giãn, thoải mái

⏱️ THỜI GIAN: • Quy trình spa hoàn chỉnh từ 60-90 phút • Đảm bảo thú cưng sạch sẽ, mượt mà, thơm tho • Kết quả lâu dài, lông mềm mượt'
WHERE ([name] LIKE N'%Spa cao cấp%' OR [name] LIKE N'%spa cao cấp%' OR [name] LIKE N'%Spa Cao Cấp%')
  AND [service_type] = N'spa'
GO

-- 2.1. Spa mini cho thú cưng
UPDATE [dbo].[PetService]
SET [description] = N'💆 DỊCH VỤ SPA MINI CHO THÚ CƯNG

✨ QUY TRÌNH NHANH:
• Tắm rửa nhanh với sữa tắm chuyên dụng
• Sấy khô lông cơ bản
• Chải lông nhẹ nhàng
• Thư giãn ngắn

🧴 SẢN PHẨM:
• Sữa tắm chuyên dụng
• Sản phẩm an toàn, không gây kích ứng
• Phù hợp cho mọi loại da và lông

💆 TRẢI NGHIỆM:
• Dịch vụ nhanh chóng, tiện lợi
• Môi trường spa thoải mái
• Chăm sóc nhẹ nhàng
• Thú cưng được thư giãn trong thời gian ngắn

⏱️ THỜI GIAN:
• Quy trình hoàn chỉnh từ 10-15 phút
• Phù hợp cho thú cưng bận rộn
• Nhanh chóng, hiệu quả'
WHERE ([name] LIKE N'%Spa mini%' OR [name] LIKE N'%spa mini%' OR [name] LIKE N'%Spa Mini%')
  AND [service_type] = N'spa'
GO

-- 3. Cắt tỉa lông
UPDATE [dbo].[PetService]
SET [description] = N'✂️ DỊCH VỤ CẮT TỈA LÔNG CHUYÊN NGHIỆP

✨ QUY TRÌNH: • Tư vấn kiểu tóc phù hợp với giống và sở thích • Cắt tỉa lông theo yêu cầu hoặc theo tiêu chuẩn giống • Tạo kiểu đẹp mắt, gọn gàng • Tỉa lông ở các vị trí khó như mặt, chân, đuôi • Chải lông mượt mà sau khi cắt

🛠️ KỸ THUẬT: • Sử dụng kéo chuyên dụng cao cấp • Kỹ thuật cắt tỉa chuyên nghiệp • Đảm bảo không làm tổn thương da • Tạo hình đẹp, phù hợp với từng giống

🎨 TẠO KIỂU: • Cắt theo tiêu chuẩn giống • Tạo kiểu theo yêu cầu khách hàng • Tỉa lông ở các vị trí quan trọng • Đảm bảo thú cưng đẹp mắt, gọn gàng

⏱️ THỜI GIAN: • Quy trình hoàn chỉnh từ 45-90 phút tùy giống • Kết quả đẹp mắt, chuyên nghiệp'
WHERE ([name] LIKE N'%Cắt tỉa%' OR [name] LIKE N'%cắt tỉa%' OR [name] LIKE N'%Tỉa lông%' OR [name] LIKE N'%tỉa lông%')
  AND [service_type] = N'spa'
GO

-- 4. Cắt móng
UPDATE [dbo].[PetService]
SET [description] = N'💅 DỊCH VỤ CẮT MÓNG CHUYÊN NGHIỆP

✨ QUY TRÌNH:
• Kiểm tra tình trạng móng của thú cưng
• Cắt móng cẩn thận, đúng kỹ thuật
• Mài móng mịn màng, không góc cạnh
• Xử lý móng quặp, móng quá dài
• Vệ sinh và chăm sóc móng

🛠️ KỸ THUẬT:
• Sử dụng dụng cụ cắt móng chuyên dụng
• Cắt đúng độ dài, tránh cắt vào phần thịt
• Mài móng mịn màng, an toàn
• Xử lý nhẹ nhàng, không gây đau

💅 CHĂM SÓC:
• Kiểm tra và xử lý móng quặp
• Vệ sinh khu vực móng
• Bôi kem dưỡng nếu cần
• Đảm bảo móng sạch sẽ, gọn gàng

⏱️ THỜI GIAN:
• Quy trình hoàn chỉnh từ 15-30 phút
• An toàn, nhẹ nhàng, không gây stress
• Móng được cắt đúng cách, không đau'
WHERE ([name] LIKE N'%Móng%' OR [name] LIKE N'%móng%' OR [name] LIKE N'%Cắt móng%' OR [name] LIKE N'%cắt móng%')
  AND [service_type] = N'spa'
GO

-- 5. Vệ sinh tai
UPDATE [dbo].[PetService]
SET [description] = N'🦷 DỊCH VỤ VỆ SINH TAI CHUYÊN NGHIỆP

✨ QUY TRÌNH:
• Kiểm tra tình trạng tai của thú cưng
• Làm sạch tai bằng dung dịch chuyên dụng
• Loại bỏ bụi bẩn, ráy tai tích tụ
• Kiểm tra và xử lý các vấn đề về tai
• Vệ sinh kỹ lưỡng, đảm bảo an toàn

🧴 SẢN PHẨM:
• Dung dịch vệ sinh tai chuyên dụng
• Không gây kích ứng, an toàn
• Hiệu quả làm sạch cao
• Phù hợp với mọi loại thú cưng

🛠️ KỸ THUẬT:
• Sử dụng dụng cụ vệ sinh chuyên nghiệp
• Làm sạch nhẹ nhàng, cẩn thận
• Kiểm tra kỹ lưỡng các vấn đề về tai
• Xử lý an toàn, không gây đau

⏱️ THỜI GIAN:
• Quy trình hoàn chỉnh từ 15-20 phút
• An toàn, nhẹ nhàng, không gây khó chịu
• Tai được vệ sinh sạch sẽ, thông thoáng'
WHERE ([name] LIKE N'%Tai%' OR [name] LIKE N'%tai%' OR [name] LIKE N'%Vệ sinh tai%' OR [name] LIKE N'%vệ sinh tai%')
  AND [service_type] = N'spa'
GO

-- 6. Vệ sinh răng
UPDATE [dbo].[PetService]
SET [description] = N'🦷 DỊCH VỤ VỆ SINH RĂNG MIỆNG

✨ QUY TRÌNH:
• Kiểm tra tình trạng răng miệng
• Đánh răng với kem đánh răng chuyên dụng
• Loại bỏ cao răng, mảng bám
• Massage nướu nhẹ nhàng
• Kiểm tra và phát hiện các vấn đề về răng

🧴 SẢN PHẨM:
• Kem đánh răng chuyên dụng cho thú cưng
• Bàn chải đánh răng phù hợp
• Dung dịch súc miệng nếu cần
• Sản phẩm an toàn, không độc hại

🛠️ KỸ THUẬT:
• Đánh răng đúng kỹ thuật
• Làm sạch kỹ lưỡng các kẽ răng
• Loại bỏ mảng bám, cao răng
• Massage nướu nhẹ nhàng

⏱️ THỜI GIAN:
• Quy trình hoàn chỉnh từ 20-30 phút
• An toàn, nhẹ nhàng
• Răng miệng sạch sẽ, thơm tho'
WHERE ([name] LIKE N'%Răng%' OR [name] LIKE N'%răng%' OR [name] LIKE N'%Vệ sinh răng%' OR [name] LIKE N'%vệ sinh răng%')
  AND [service_type] = N'spa'
GO

-- 7. Massage thư giãn
UPDATE [dbo].[PetService]
SET [description] = N'💆 DỊCH VỤ MASSAGE THƯ GIÃN

✨ QUY TRÌNH:
• Massage toàn thân nhẹ nhàng, thư giãn
• Xoa bóp các cơ bắp, giảm căng thẳng
• Kích thích tuần hoàn máu
• Thư giãn tinh thần, giảm stress
• Kết hợp với tinh dầu thư giãn

💆 KỸ THUẬT:
• Massage theo kỹ thuật chuyên nghiệp
• Xoa bóp nhẹ nhàng, không gây đau
• Tập trung vào các điểm căng thẳng
• Thư giãn toàn thân

🌸 TRẢI NGHIỆM:
• Môi trường yên tĩnh, thư giãn
• Tinh dầu thư giãn tự nhiên
• Âm nhạc nhẹ nhàng (nếu có)
• Thú cưng được thư giãn hoàn toàn

⏱️ THỜI GIAN:
• Quy trình massage từ 30-45 phút
• Thú cưng thư giãn, thoải mái
• Giảm căng thẳng, mệt mỏi'
WHERE ([name] LIKE N'%Massage%' OR [name] LIKE N'%massage%' OR [name] LIKE N'%Thư giãn%' OR [name] LIKE N'%thư giãn%')
  AND [service_type] = N'spa'
GO

-- 8. Tẩy lông / Tẩy lông chết
UPDATE [dbo].[PetService]
SET [description] = N'🌿 DỊCH VỤ TẨY LÔNG CHẾT

✨ QUY TRÌNH:
• Chải lông kỹ lưỡng để loại bỏ lông chết
• Tẩy lông bằng dụng cụ chuyên dụng
• Làm sạch lông rụng tích tụ
• Chải lông mượt mà sau khi tẩy
• Kiểm tra và xử lý các vấn đề về da

🛠️ KỸ THUẬT:
• Sử dụng dụng cụ tẩy lông chuyên nghiệp
• Tẩy lông nhẹ nhàng, không gây đau
• Làm sạch kỹ lưỡng, không bỏ sót
• Chải lông mượt mà sau khi tẩy

🌿 LỢI ÍCH:
• Loại bỏ lông chết, giảm rụng lông
• Da thông thoáng, sạch sẽ hơn
• Lông mượt mà, bóng đẹp
• Giảm nguy cơ tắc nghẽn lỗ chân lông

⏱️ THỜI GIAN:
• Quy trình hoàn chỉnh từ 30-45 phút
• Hiệu quả, nhẹ nhàng
• Kết quả lâu dài, lông mượt mà'
WHERE ([name] LIKE N'%Tẩy lông%' OR [name] LIKE N'%tẩy lông%' OR [name] LIKE N'%Lông chết%' OR [name] LIKE N'%lông chết%')
  AND [service_type] = N'spa'
GO

-- 9. Điều trị da / Chăm sóc da
UPDATE [dbo].[PetService]
SET [description] = N'🌿 DỊCH VỤ CHĂM SÓC DA CHUYÊN NGHIỆP

✨ QUY TRÌNH:
• Kiểm tra tình trạng da của thú cưng
• Làm sạch da kỹ lưỡng
• Điều trị các vấn đề về da (nếu có)
• Đắp mặt nạ dưỡng da
• Massage da nhẹ nhàng
• Chăm sóc da bằng sản phẩm chuyên dụng

🧴 SẢN PHẨM:
• Sữa tắm chuyên dụng cho da nhạy cảm
• Mặt nạ dưỡng da chuyên nghiệp
• Kem dưỡng da nếu cần
• Sản phẩm an toàn, không gây kích ứng

🛠️ KỸ THUẬT:
• Điều trị theo từng loại da
• Làm sạch sâu, loại bỏ bụi bẩn
• Dưỡng da, phục hồi độ ẩm
• Chăm sóc nhẹ nhàng, không gây kích ứng

⏱️ THỜI GIAN:
• Quy trình hoàn chỉnh từ 45-60 phút
• Da được chăm sóc kỹ lưỡng
• Kết quả lâu dài, da khỏe mạnh'
WHERE ([name] LIKE N'%Da%' OR [name] LIKE N'%da%' OR [name] LIKE N'%Chăm sóc da%' OR [name] LIKE N'%chăm sóc da%')
  AND [service_type] = N'spa'
  AND [name] NOT LIKE N'%Tẩy lông%'
GO

-- 10. Tẩy giun / Ký sinh trùng
UPDATE [dbo].[PetService]
SET [description] = N'🧴 DỊCH VỤ TẨY GIUN VÀ KÝ SINH TRÙNG

✨ QUY TRÌNH:
• Kiểm tra tình trạng sức khỏe
• Tẩy giun theo phác đồ phù hợp
• Xử lý ký sinh trùng ngoài da (bọ chét, ve)
• Tư vấn chăm sóc và phòng ngừa
• Kiểm tra lại sau điều trị

💊 THUỐC:
• Thuốc tẩy giun an toàn, hiệu quả
• Thuốc diệt ký sinh trùng chuyên dụng
• Sản phẩm được bác sĩ thú y khuyên dùng
• Đảm bảo an toàn cho thú cưng

🛠️ KỸ THUẬT:
• Điều trị theo độ tuổi và cân nặng
• Xử lý kỹ lưỡng, không bỏ sót
• Theo dõi sau điều trị
• Tư vấn phòng ngừa hiệu quả

⏱️ THỜI GIAN:
• Quy trình hoàn chỉnh từ 30-45 phút
• An toàn, hiệu quả
• Tư vấn chăm sóc sau điều trị'
WHERE ([name] LIKE N'%Giun%' OR [name] LIKE N'%giun%' OR [name] LIKE N'%Ký sinh%' OR [name] LIKE N'%ký sinh%')
  AND [service_type] = N'spa'
GO

-- 11. Dịch vụ spa combo (nếu có)
UPDATE [dbo].[PetService]
SET [description] = N'✨ DỊCH VỤ SPA COMBO TOÀN DIỆN

✨ GỒM NHỮNG GÌ:
• Tắm rửa cao cấp với sữa tắm chuyên dụng
• Cắt tỉa lông chuyên nghiệp
• Cắt móng và mài móng
• Vệ sinh tai và răng miệng
• Tẩy lông chết, chải lông mượt mà
• Massage thư giãn toàn thân
• Chăm sóc da và lông

💎 SẢN PHẨM CAO CẤP:
• Sữa tắm và dầu gội nhập khẩu
• Mặt nạ dưỡng da và lông
• Tinh dầu thư giãn tự nhiên
• Sản phẩm chăm sóc chuyên nghiệp

💆 TRẢI NGHIỆM:
• Môi trường spa sang trọng
• Chăm sóc toàn diện, chuyên nghiệp
• Thú cưng được thư giãn hoàn toàn
• Kết quả lâu dài, đẹp mắt

⏱️ THỜI GIAN:
• Quy trình spa combo từ 90-120 phút
• Đảm bảo thú cưng sạch sẽ, đẹp mắt, thơm tho
• Chăm sóc toàn diện, chất lượng cao'
WHERE ([name] LIKE N'%Combo%' OR [name] LIKE N'%combo%' OR [name] LIKE N'%Toàn diện%' OR [name] LIKE N'%toàn diện%')
  AND [service_type] = N'spa'
GO

-- 12. Cập nhật mô tả mặc định cho các dịch vụ spa khác chưa có mô tả
UPDATE [dbo].[PetService]
SET [description] = N'✨ DỊCH VỤ SPA CHUYÊN NGHIỆP

✨ QUY TRÌNH:
• Kiểm tra tình trạng thú cưng
• Thực hiện dịch vụ theo quy trình chuyên nghiệp
• Chăm sóc nhẹ nhàng, an toàn
• Đảm bảo chất lượng dịch vụ

💎 CHẤT LƯỢNG:
• Đội ngũ kỹ thuật viên giàu kinh nghiệm
• Sản phẩm chăm sóc an toàn, chất lượng
• Quy trình chuyên nghiệp, đảm bảo
• Chăm sóc tận tình, chu đáo

⏱️ THỜI GIAN:
• Quy trình hoàn chỉnh, đảm bảo chất lượng
• Thú cưng được chăm sóc tốt nhất
• Kết quả đẹp mắt, hài lòng'
WHERE [description] IS NULL 
  OR [description] = ''
  OR LEN(LTRIM(RTRIM([description]))) = 0
  AND [service_type] = N'spa'
GO

PRINT '=== HOÀN THÀNH CẬP NHẬT MÔ TẢ DỊCH VỤ SPA ==='
GO

-- Kiểm tra kết quả
SELECT [service_id], [name], [service_type], 
       LEFT([description], 100) + '...' as [description_preview]
FROM [dbo].[PetService]
WHERE [service_type] = N'spa'
ORDER BY [name]
GO

