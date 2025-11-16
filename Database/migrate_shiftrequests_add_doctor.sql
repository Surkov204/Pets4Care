-- =============================================
-- Migration Script: Add Doctor Support to ShiftRequests Table
-- Description: 
--   Modify ShiftRequests to support both Doctor and Staff (similar to WorkSchedule pattern)
--   Currently: ShiftRequests only supports Staff via EmployeeID
--   After: ShiftRequests supports both Doctor and Staff (one or the other, not both)
-- Date: 2025-11-15
-- =============================================

USE [SHOP_PET_Database]
GO

PRINT 'Starting migration: Adding Doctor support to ShiftRequests table...'
PRINT '  - Currently: ShiftRequests only supports Staff'
PRINT '  - After: ShiftRequests supports both Staff and Doctor (one or the other, not both)'
PRINT ''

BEGIN TRANSACTION;

BEGIN TRY
    -- =============================================
    -- Step 1: Modify ShiftRequests table
    -- =============================================
    PRINT 'Step 1: Modifying ShiftRequests table...'
    
    -- Rename EmployeeID to staff_id for consistency
    IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.ShiftRequests') AND name = 'EmployeeID')
    BEGIN
        EXEC sp_rename 'dbo.ShiftRequests.EmployeeID', 'staff_id', 'COLUMN';
        PRINT '  Renamed column: EmployeeID -> staff_id'
    END
    
    -- Add doctor_id column (nullable)
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.ShiftRequests') AND name = 'doctor_id')
    BEGIN
        ALTER TABLE [dbo].[ShiftRequests]
        ADD [doctor_id] [int] NULL;
        
        PRINT '  Added column: ShiftRequests.doctor_id'
    END
    ELSE
    BEGIN
        PRINT '  Column doctor_id already exists'
    END
    
    -- Make staff_id nullable (since it can be NULL if doctor_id is set)
    ALTER TABLE [dbo].[ShiftRequests]
    ALTER COLUMN [staff_id] [int] NULL;
    
    PRINT '  Made staff_id nullable'
    
    -- Drop existing foreign key
    IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_Request_Employee' AND parent_object_id = OBJECT_ID('dbo.ShiftRequests'))
    BEGIN
        ALTER TABLE [dbo].[ShiftRequests]
        DROP CONSTRAINT [FK_Request_Employee];
        
        PRINT '  Dropped constraint: FK_Request_Employee'
    END
    
    -- Add foreign key for staff_id
    ALTER TABLE [dbo].[ShiftRequests]
    ADD CONSTRAINT [FK_ShiftRequests_Staff] FOREIGN KEY([staff_id])
    REFERENCES [dbo].[Staff] ([staff_id])
    ON DELETE CASCADE;
    
    PRINT '  Added foreign key: FK_ShiftRequests_Staff'
    
    -- Add foreign key for doctor_id
    ALTER TABLE [dbo].[ShiftRequests]
    ADD CONSTRAINT [FK_ShiftRequests_Doctor] FOREIGN KEY([doctor_id])
    REFERENCES [dbo].[Doctor] ([doctor_id])
    ON DELETE CASCADE;
    
    PRINT '  Added foreign key: FK_ShiftRequests_Doctor'
    
    -- Add check constraint: must have exactly one of doctor_id or staff_id
    DECLARE @sql_shiftreq NVARCHAR(MAX) = N'
    ALTER TABLE [dbo].[ShiftRequests]
    ADD CONSTRAINT [CK_ShiftRequests_OneOwner] CHECK (
        ([doctor_id] IS NOT NULL AND [staff_id] IS NULL) OR 
        ([doctor_id] IS NULL AND [staff_id] IS NOT NULL)
    );';
    EXEC sp_executesql @sql_shiftreq;
    
    PRINT '  Added constraint: CK_ShiftRequests_OneOwner'
    
    -- Create indexes for better performance
    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_ShiftRequests_DoctorID' AND object_id = OBJECT_ID('dbo.ShiftRequests'))
    BEGIN
        DECLARE @sql_idx_doc NVARCHAR(MAX) = N'
        CREATE NONCLUSTERED INDEX [IX_ShiftRequests_DoctorID] ON [dbo].[ShiftRequests]
        (
            [doctor_id] ASC,
            [TargetDate] ASC
        )
        WHERE ([doctor_id] IS NOT NULL)
        WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY];';
        EXEC sp_executesql @sql_idx_doc;
        
        PRINT '  Created index: IX_ShiftRequests_DoctorID'
    END
    
    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_ShiftRequests_StaffID' AND object_id = OBJECT_ID('dbo.ShiftRequests'))
    BEGIN
        DECLARE @sql_idx_staff NVARCHAR(MAX) = N'
        CREATE NONCLUSTERED INDEX [IX_ShiftRequests_StaffID] ON [dbo].[ShiftRequests]
        (
            [staff_id] ASC,
            [TargetDate] ASC
        )
        WHERE ([staff_id] IS NOT NULL)
        WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY];';
        EXEC sp_executesql @sql_idx_staff;
        
        PRINT '  Created index: IX_ShiftRequests_StaffID'
    END
    
    PRINT ''
    
    COMMIT TRANSACTION;
    
    PRINT 'Table modifications completed successfully!'
    PRINT ''

END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
    
    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
    DECLARE @ErrorState INT = ERROR_STATE();
    
    PRINT 'Migration failed!'
    PRINT 'Error: ' + @ErrorMessage;
    
    RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
END CATCH
GO

PRINT 'Migration completed successfully!'
PRINT ''
PRINT 'Summary of changes:'
PRINT '  ✅ ShiftRequests: Now supports both Staff and Doctor (one of doctor_id or staff_id required)'
PRINT '  ✅ Renamed EmployeeID to staff_id for consistency'
PRINT '  ✅ Added doctor_id column'
PRINT '  ✅ Added foreign keys: FK_ShiftRequests_Staff, FK_ShiftRequests_Doctor'
PRINT '  ✅ Added constraint: CK_ShiftRequests_OneOwner'
PRINT '  ✅ Created indexes: IX_ShiftRequests_DoctorID, IX_ShiftRequests_StaffID'
PRINT ''
PRINT 'Pattern applied: Similar to WorkSchedule table - each record belongs to either Doctor OR Staff'
PRINT ''
PRINT 'Note: Shifts table is master data and does not need modification.'
PRINT ''
PRINT 'Please verify the changes and update any application code that references EmployeeID.'
PRINT ''
PRINT 'Completion time: ' + CONVERT(NVARCHAR, GETDATE(), 126);
GO



