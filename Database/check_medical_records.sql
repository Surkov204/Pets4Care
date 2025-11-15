SELECT COUNT(*) as total_medical_records FROM MedicalRecord;
SELECT TOP 5 record_id, booking_id, examination_date FROM MedicalRecord ORDER BY examination_date DESC;