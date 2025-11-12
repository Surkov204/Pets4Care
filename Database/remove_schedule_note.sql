USE SHOP_PET_Database
GO

-- Remove scheduleNote from Doctor table
-- Doctor will use WorkSchedule table instead

DECLARE @ConstraintName NVARCHAR(128);

-- Find and drop default constraint if exists
SELECT @ConstraintName = dc.name
FROM sys.default_constraints dc
JOIN sys.columns c 
    ON c.default_object_id = dc.object_id
WHERE dc.parent_object_id = OBJECT_ID('dbo.Doctor')
  AND c.name = 'scheduleNote';

IF @ConstraintName IS NOT NULL
BEGIN
    DECLARE @sql NVARCHAR(300);
    SET @sql = 'ALTER TABLE dbo.Doctor DROP CONSTRAINT ' + @ConstraintName;
    EXEC(@sql);
    PRINT N'✅ Dropped constraint: ' + @ConstraintName;
END

-- Drop the scheduleNote column
IF EXISTS (
    SELECT 1 FROM sys.columns 
    WHERE object_id = OBJECT_ID('dbo.Doctor') 
    AND name = 'scheduleNote'
)
BEGIN
    ALTER TABLE dbo.Doctor DROP COLUMN scheduleNote;
    PRINT N'✅ Dropped column scheduleNote from Doctor table';
END
ELSE
BEGIN
    PRINT N'⚠️ Column scheduleNote does not exist in Doctor table';
END
GO

PRINT N'✅ Doctor table updated - now using WorkSchedule system'
GO
