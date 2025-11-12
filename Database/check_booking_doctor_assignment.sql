-- Check which doctor the bookings with medical records are assigned to
SELECT b.booking_id, b.doctor_id, b.status, b.appointment_start, mr.record_id
FROM Booking b
JOIN MedicalRecord mr ON b.booking_id = mr.booking_id
ORDER BY b.booking_id;

-- Check all bookings for doctor 1 with their status
SELECT booking_id, status, appointment_start
FROM Booking
WHERE doctor_id = 1
ORDER BY appointment_start DESC
OFFSET 0 ROWS FETCH NEXT 10 ROWS ONLY;