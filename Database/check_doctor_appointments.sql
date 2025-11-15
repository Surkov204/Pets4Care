-- Check appointments for doctor 1 in the date range
SELECT COUNT(*) as total_appointments_for_doctor_1
FROM Booking
WHERE doctor_id = 1
AND CAST(appointment_start AS date) BETWEEN DATEADD(MONTH, -6, GETDATE()) AND DATEADD(MONTH, 3, GETDATE());

-- Check completed appointments for doctor 1
SELECT COUNT(*) as completed_appointments_for_doctor_1
FROM Booking
WHERE doctor_id = 1
AND status LIKE N'%Hoàn thành%'
AND CAST(appointment_start AS date) BETWEEN DATEADD(MONTH, -6, GETDATE()) AND DATEADD(MONTH, 3, GETDATE());

-- Check which completed appointments have medical records
SELECT b.booking_id, b.status, b.appointment_start,
       CASE WHEN mr.record_id IS NOT NULL THEN 'Has Record' ELSE 'No Record' END as has_record
FROM Booking b
LEFT JOIN MedicalRecord mr ON b.booking_id = mr.booking_id
WHERE b.doctor_id = 1
AND b.status LIKE N'%Hoàn thành%'
AND CAST(b.appointment_start AS date) BETWEEN DATEADD(MONTH, -6, GETDATE()) AND DATEADD(MONTH, 3, GETDATE())
ORDER BY b.appointment_start DESC;