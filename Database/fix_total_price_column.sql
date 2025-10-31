-- Fix total_price column for boarding_bookings table
-- Run this SQL script to add missing total_price column and update existing data

USE [SHOP_PET_Database]
GO

-- 1. Add total_price column if not exists
IF NOT EXISTS (
    SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_SCHEMA = 'dbo' 
    AND TABLE_NAME = 'boarding_bookings' 
    AND COLUMN_NAME = 'total_price'
)
BEGIN
    ALTER TABLE dbo.boarding_bookings
    ADD total_price DECIMAL(10,2) NOT NULL DEFAULT 0;
    
    PRINT 'Added total_price column to boarding_bookings table';
END
ELSE
BEGIN
    PRINT 'total_price column already exists';
END
GO

-- 2. Update total_price for existing records (simple calculation for now)
-- This will be recalculated properly when retrieved from database
UPDATE dbo.boarding_bookings
SET total_price = price_per_day * boarding_days
WHERE total_price = 0 AND price_per_day > 0 AND boarding_days > 0;
GO

-- 3. For records with same-day check-in/check-out, recalculate based on hours
-- This handles the case where customer sends pet from 8h to 12h (4 hours)
UPDATE dbo.boarding_bookings
SET total_price = 
    CASE 
        WHEN check_in_date = check_out_date THEN
            -- Same day: calculate based on hours difference
            CASE 
                WHEN DATEDIFF(HOUR, CAST(check_in_time AS TIME), CAST(check_out_time AS TIME)) <= 4 THEN
                    price_per_day * 0.125  -- 4 hours = 12.5% of daily price
                WHEN DATEDIFF(HOUR, CAST(check_in_time AS TIME), CAST(check_out_time AS TIME)) <= 8 THEN
                    price_per_day * 0.25   -- 8 hours = 25% of daily price
                WHEN DATEDIFF(HOUR, CAST(check_in_time AS TIME), CAST(check_out_time AS TIME)) <= 12 THEN
                    price_per_day * 0.375  -- 12 hours = 37.5% of daily price
                ELSE
                    price_per_day * 0.5    -- 12+ hours = 50% of daily price
            END
        ELSE
            -- Multi-day: already calculated correctly by price_per_day * boarding_days
            total_price
    END
WHERE total_price > 0 AND check_in_date = check_out_date;
GO

PRINT 'Updated total_price for existing bookings';
GO

-- 4. Show updated data
SELECT 
    booking_id,
    room_type,
    price_per_day,
    boarding_days,
    check_in_date,
    check_out_date,
    check_in_time,
    check_out_time,
    total_price,
    CASE 
        WHEN check_in_date = check_out_date THEN 
            DATEDIFF(HOUR, CAST(check_in_time AS TIME), CAST(check_out_time AS TIME))
        ELSE 
            DATEDIFF(DAY, check_in_date, check_out_date) * 24
    END AS calculated_hours
FROM dbo.boarding_bookings
ORDER BY booking_id DESC;
GO

