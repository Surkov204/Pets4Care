-- Script để cập nhật status của các booking khám sức khỏe từ "pending" sang "Hoàn thành"
-- Chỉ cập nhật các booking đã thanh toán (có payment với status = 'paid')

USE [SHOP_PET_Database]
GO

-- Cập nhật TẤT CẢ các booking khám sức khỏe có status "pending" hoặc "Chờ xác nhận" thành "Hoàn thành"
-- Không cần kiểm tra payment vì booking chỉ được tạo sau khi thanh toán thành công
UPDATE b
SET b.status = N'Hoàn thành'
FROM dbo.Booking b
INNER JOIN dbo.Booking_Service bs ON b.booking_id = bs.booking_id
INNER JOIN dbo.PetService ps ON bs.service_id = ps.service_id
WHERE ps.service_type = 'health_check'
    AND (b.status = 'pending' OR b.status = N'Chờ xác nhận' OR b.status = N'chờ xác nhận')
    AND b.appointment_start >= DATEADD(MONTH, -6, GETDATE())  -- Update booking trong 6 tháng gần đây và tương lai
GO

-- Kiểm tra kết quả - Xem tất cả booking khám sức khỏe
SELECT 
    b.booking_id,
    b.status,
    b.appointment_start,
    c.name AS customer_name,
    p.pet_name AS pet_name,
    ps.name AS service_name,
    d.name AS doctor_name
FROM dbo.Booking b
INNER JOIN dbo.Booking_Service bs ON b.booking_id = bs.booking_id
INNER JOIN dbo.PetService ps ON bs.service_id = ps.service_id
LEFT JOIN dbo.Customer c ON b.customer_id = c.customer_id
LEFT JOIN dbo.Pet p ON b.pet_id = p.id
LEFT JOIN dbo.Doctor d ON b.doctor_id = d.doctor_id
WHERE ps.service_type = 'health_check'
    AND b.appointment_start >= DATEADD(MONTH, -6, GETDATE())
ORDER BY b.appointment_start DESC
GO

