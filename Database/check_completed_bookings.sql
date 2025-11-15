SELECT TOP 10 booking_id, status, appointment_start
FROM Booking
WHERE status = N'Hoàn thành'
ORDER BY appointment_start DESC;