SELECT doctor_id, COUNT(*) as count FROM MedicalRecord GROUP BY doctor_id;
SELECT record_id, booking_id, doctor_id, examination_date FROM MedicalRecord ORDER BY record_id DESC;