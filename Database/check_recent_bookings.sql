USE [SHOP_PET_Database]
GO

SELECT TOP 5 booking_id, status, created_at
FROM Booking
ORDER BY created_at DESC;

SELECT COUNT(*) as total_bookings FROM Booking;
SELECT status, COUNT(*) as count_by_status
FROM Booking
GROUP BY status;