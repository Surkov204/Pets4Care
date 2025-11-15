-- Check all status values in Booking table
SELECT DISTINCT status, COUNT(*) as count
FROM Booking
GROUP BY status;

-- Check completed bookings with different status checks
SELECT COUNT(*) as total_completed
FROM Booking
WHERE status LIKE N'%Hoàn thành%' OR status LIKE '%completed%' OR status = N'Hoàn thành';

-- Check recent completed bookings
SELECT TOP 10 booking_id, status, appointment_start
FROM Booking
WHERE status LIKE N'%Hoàn thành%' OR status LIKE '%completed%'
ORDER BY appointment_start DESC;

-- Check if medical record booking IDs exist in completed bookings
SELECT mr.record_id, mr.booking_id, b.status, b.appointment_start
FROM MedicalRecord mr
LEFT JOIN Booking b ON mr.booking_id = b.booking_id
ORDER BY mr.record_id;