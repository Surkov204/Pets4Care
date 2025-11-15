-- Simple check for completed status
SELECT TOP 5 booking_id, status
FROM Booking
WHERE status = N'Hoàn thành';

-- Check with substring
SELECT TOP 5 booking_id, status
FROM Booking
WHERE CHARINDEX(N'Hoàn thành', status) > 0;