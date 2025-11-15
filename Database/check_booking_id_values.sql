SELECT booking_id, COUNT(*) as count
FROM MedicalRecord
GROUP BY booking_id
ORDER BY booking_id;