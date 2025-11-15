-- Create ShiftRequests table for handling shift registration, cancellation, and swap requests
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'ShiftRequests')
BEGIN
    CREATE TABLE dbo.ShiftRequests (
        RequestID INT IDENTITY(1,1) PRIMARY KEY,
        EmployeeID INT NOT NULL,                    -- ID of the employee making the request
        ToStaffID INT NULL,                         -- ID of the target staff (for swaps/passes)
        Type NVARCHAR(50) NOT NULL,                 -- Type: 'DoctorRegister', 'DoctorCancel', 'DoctorSwap', 'DoctorPass', etc.
        TargetDate DATE NOT NULL,                   -- Target date for the request
        FromDate DATE NOT NULL,                     -- Original shift date
        ToDate DATE NULL,                           -- Target shift date (for swaps)
        FromShiftID INT NULL,                       -- Original shift ID
        ToShiftID INT NULL,                         -- Target shift ID (for swaps)
        Reason NVARCHAR(MAX),                       -- Reason for the request
        Status NVARCHAR(50) NOT NULL DEFAULT 'Pending', -- Status: 'Pending', 'Approved', 'Rejected', etc.
        ApprovedBy INT NULL,                        -- ID of admin who approved
        CreatedAt DATETIME DEFAULT GETDATE(),       -- Creation timestamp
        ToNotified BIT DEFAULT 0,                   -- Whether target staff has been notified
        AdminNotified BIT DEFAULT 0                 -- Whether admin has been notified
    )

    PRINT 'Table ShiftRequests created successfully'
END
ELSE
BEGIN
    PRINT 'Table ShiftRequests already exists'
END
GO

-- Create indexes for better performance
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_ShiftRequests_EmployeeID')
BEGIN
    CREATE INDEX IX_ShiftRequests_EmployeeID ON dbo.ShiftRequests(EmployeeID)
    PRINT 'Index IX_ShiftRequests_EmployeeID created'
END

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_ShiftRequests_Status')
BEGIN
    CREATE INDEX IX_ShiftRequests_Status ON dbo.ShiftRequests(Status)
    PRINT 'Index IX_ShiftRequests_Status created'
END

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_ShiftRequests_Type')
BEGIN
    CREATE INDEX IX_ShiftRequests_Type ON dbo.ShiftRequests(Type)
    PRINT 'Index IX_ShiftRequests_Type created'
END
GO