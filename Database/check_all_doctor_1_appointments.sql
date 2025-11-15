-- Check all appointments for doctor 1 in date range, regardless of status
SELECT COUNT(*) as total_appointments
FROM Booking
WHERE doctor_id = 1
AND CAST(appointment_start AS date) BETWEEN DATEADD(MONTH, -6, GETDATE()) AND DATEADD(MONTH, 3, GETDATE());

-- Check appointments by status for doctor 1
SELECT 
    CASE 
        WHEN status LIKE '%Hoàn%' THEN 'Completed'
        WHEN status LIKE '%pending%' OR status LIKE '%Chờ%' THEN 'Pending'  
        WHEN status LIKE '%confirmed%' OR status LIKE '%Đã%' THEN 'Confirmed'
        ELSE 'Other'
    END as status_category,
    COUNT(*) as count
FROM Booking
WHERE doctor_id = 1
AND CAST(appointment_start AS date) BETWEEN DATEADD(MONTH, -6, GETDATE()) AND DATEADD(MONTH, 3, GETDATE())
GROUP BY 
    CASE 
        WHEN status LIKE '%Hoàn%' THEN 'Completed'
        WHEN status LIKE '%pending%' OR status LIKE '%Chờ%' THEN 'Pending'
        WHEN status LIKE '%confirmed%' OR status LIKE '%Đã%' THEN 'Confirmed'
        ELSE 'Other'
    END;