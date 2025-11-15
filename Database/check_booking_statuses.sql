SELECT booking_id, status, appointment_start
FROM Booking
WHERE booking_id IN (13, 1024)
ORDER BY booking_id;