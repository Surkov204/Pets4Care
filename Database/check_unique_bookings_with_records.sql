-- Check unique booking IDs that have medical records
SELECT DISTINCT booking_id
FROM MedicalRecord
WHERE booking_id IS NOT NULL;

-- Check how many completed bookings exist
SELECT COUNT(*) as completed_bookings_count
FROM Booking
WHERE status LIKE N'%Hoàn thành%' OR status LIKE '%Hoàn%';