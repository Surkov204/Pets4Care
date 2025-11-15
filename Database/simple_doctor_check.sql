SELECT b.booking_id, b.doctor_id, b.status, mr.record_id
FROM Booking b
JOIN MedicalRecord mr ON b.booking_id = mr.booking_id;