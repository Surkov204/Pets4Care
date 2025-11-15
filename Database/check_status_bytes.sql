-- Check the actual status values with their byte representation
SELECT booking_id, status,
       CAST(status AS VARBINARY(MAX)) as status_bytes
FROM Booking
WHERE booking_id IN (13, 1024, 3)
ORDER BY booking_id;