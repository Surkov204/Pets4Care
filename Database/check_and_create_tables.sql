use SHOP_PET_Database


IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Customer')
BEGIN
    CREATE TABLE Customer (
        customer_id INT IDENTITY(1,1) PRIMARY KEY,
        name NVARCHAR(100) NOT NULL,
        email NVARCHAR(100) UNIQUE NOT NULL,
        password NVARCHAR(255) NOT NULL,
        phone NVARCHAR(20),
        address_Customer NVARCHAR(255),
        google_id NVARCHAR(255),
        status NVARCHAR(20) DEFAULT 'active',
        reset_token NVARCHAR(255),
        reset_token_expiry DATETIME,
        created_at DATETIME DEFAULT GETDATE()
    );
    PRINT 'Customer table created successfully';
END
ELSE
    PRINT 'Customer table already exists';


IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'PET')
BEGIN
    CREATE TABLE PET (
        id INT IDENTITY(1,1) PRIMARY KEY,
        customer_id INT NOT NULL,
        pet_name NVARCHAR(100) NOT NULL,
        species NVARCHAR(50) NOT NULL,
        breed NVARCHAR(100) NOT NULL,
        age INT NOT NULL,
        gender NVARCHAR(10) CHECK (gender IN ('male', 'female')) NOT NULL,
        description NVARCHAR(MAX),
        health_status NVARCHAR(MAX),
        image_path NVARCHAR(255),
        created_at DATETIME DEFAULT GETDATE(),
        updated_at DATETIME DEFAULT GETDATE(),
        CONSTRAINT FK_PET_Customer FOREIGN KEY (customer_id)
            REFERENCES Customer(customer_id)
            ON DELETE CASCADE
    );
    PRINT 'PET table created successfully';
END
ELSE
    PRINT 'PET table already exists';

-- 7. Tạo index
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'idx_pet_customer_id')
BEGIN
    CREATE INDEX idx_pet_customer_id ON PET(customer_id);
    PRINT 'Index idx_pet_customer_id created';
END

-- 8. Tạo trigger
IF NOT EXISTS (
    SELECT * FROM sys.triggers WHERE name = 'trg_UpdatePetTimestamp'
)
BEGIN
    EXEC('
        CREATE TRIGGER trg_UpdatePetTimestamp
        ON PET
        AFTER UPDATE
        AS
        BEGIN
            SET NOCOUNT ON;
            UPDATE p
            SET updated_at = GETDATE()
            FROM PET p
            INNER JOIN inserted i ON p.id = i.id;
        END
    ')
END

-- Tạo bảng Staff
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Staff')
BEGIN
    CREATE TABLE Staff (
        staff_id INT IDENTITY(1,1) PRIMARY KEY,
        name NVARCHAR(100) NOT NULL,
        email NVARCHAR(100) UNIQUE NOT NULL,
        phone NVARCHAR(20),
        password NVARCHAR(255) NOT NULL,
        position NVARCHAR(50) NOT NULL, -- admin, staff, doctor
        created_at DATETIME DEFAULT GETDATE(),
        status NVARCHAR(20) DEFAULT 'active'
    );
    PRINT 'Staff table created successfully';
END
ELSE
    PRINT 'Staff table already exists';

-- Thêm dữ liệu mẫu cho Staff
IF NOT EXISTS (SELECT * FROM Staff WHERE email = 'admin@pets4care.com')
BEGIN
    INSERT INTO Staff (name, email, phone, password, position) 
    VALUES ('Admin', 'admin@pets4care.com', '0123456789', 'admin123', 'admin');
    PRINT 'Admin account created';
END

IF NOT EXISTS (SELECT * FROM Staff WHERE email = 'staff@pets4care.com')
BEGIN
    INSERT INTO Staff (name, email, phone, password, position) 
    VALUES ('Staff', 'staff@pets4care.com', '0123456788', 'staff123', 'staff');
    PRINT 'Staff account created';
END

IF NOT EXISTS (SELECT * FROM Staff WHERE email = 'doctor@pets4care.com')
BEGIN
    INSERT INTO Staff (name, email, phone, password, position) 
    VALUES ('Doctor', 'doctor@pets4care.com', '0123456787', 'doctor123', 'doctor');
    PRINT 'Doctor account created';
END



