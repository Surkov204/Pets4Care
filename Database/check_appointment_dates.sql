SELECT booking_id, appointment_start, 
       CAST(appointment_start AS date) as appointment_date
FROM Booking
WHERE booking_id IN (3, 13, 1024)
ORDER BY booking_id;