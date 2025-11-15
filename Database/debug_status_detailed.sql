-- Check detailed status info
SELECT TOP 3 booking_id,
       status,
       LEN(status) as status_length,
       ASCII(SUBSTRING(status, 1, 1)) as first_char_ascii,
       ASCII(SUBSTRING(status, LEN(status), 1)) as last_char_ascii
FROM Booking
WHERE booking_id IN (13, 1024, 3);

-- Check if there are trailing spaces
SELECT booking_id,
       status,
       LEN(status) as length_with_spaces,
       LEN(LTRIM(RTRIM(status))) as length_trimmed
FROM Booking
WHERE booking_id IN (13, 1024, 3);

-- Try different ways to match
SELECT COUNT(*) as exact_match
FROM Booking
WHERE status = N'Hoàn thành';

SELECT COUNT(*) as like_match
FROM Booking
WHERE status LIKE N'Hoàn thành';

SELECT COUNT(*) as contains_check
FROM Booking
WHERE CHARINDEX(N'Hoàn thành', status) > 0;