USE [SHOP_PET_Database]
GO

-- Check current check constraints on Booking table
SELECT
    cc.name AS constraint_name,
    cc.definition
FROM sys.check_constraints cc
WHERE cc.parent_object_id = OBJECT_ID('dbo.Booking')

-- Check current default constraints on Booking table
SELECT
    dc.name AS constraint_name,
    dc.definition,
    c.name AS column_name
FROM sys.default_constraints dc
JOIN sys.columns c ON dc.parent_object_id = c.object_id AND dc.parent_column_id = c.column_id
WHERE dc.parent_object_id = OBJECT_ID('dbo.Booking')