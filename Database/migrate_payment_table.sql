-- Migration: Tạo bảng Payment chung cho toàn bộ hệ thống
USE [SHOP_PET_Database]
GO

-- Tạo bảng Payment để lưu thông tin thanh toán cho tất cả loại dịch vụ
-- Hỗ trợ: health_check, spa, boarding, order (product)
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Payment]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[Payment](
        [payment_id] [int] IDENTITY(1,1) NOT NULL,
        [payment_type] [nvarchar](50) NOT NULL, -- 'health_check', 'spa', 'boarding', 'order'
        [reference_id] [int] NULL, -- order_id, booking_id, hoặc service_id tùy theo payment_type
        [customer_id] [int] NOT NULL,
        [amount] [decimal](10, 2) NOT NULL,
        [payment_method] [nvarchar](50) NULL, -- 'PayOS', 'CASH', 'BANK_TRANSFER'
        [payment_status] [nvarchar](20) NULL, -- 'pending', 'paid', 'cancelled', 'failed', 'refunded'
        [payos_order_code] [int] NULL,
        [transaction_code] [nvarchar](100) NULL,
        [transaction_ref] [nvarchar](255) NULL,
        [created_at] [datetime] NULL,
        [paid_at] [datetime] NULL,
        [note] [nvarchar](max) NULL,
        CONSTRAINT [PK_Payment] PRIMARY KEY CLUSTERED 
        (
            [payment_id] ASC
        )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
    ) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
    
    -- Thêm default values
    ALTER TABLE [dbo].[Payment] ADD CONSTRAINT [DF_Payment_created_at] DEFAULT (GETDATE()) FOR [created_at]
    ALTER TABLE [dbo].[Payment] ADD CONSTRAINT [DF_Payment_payment_status] DEFAULT ('pending') FOR [payment_status]
    
    -- Tạo index để tìm kiếm nhanh
    CREATE NONCLUSTERED INDEX [IX_Payment_Customer] ON [dbo].[Payment] ([customer_id])
    CREATE NONCLUSTERED INDEX [IX_Payment_Type_Reference] ON [dbo].[Payment] ([payment_type], [reference_id])
    CREATE NONCLUSTERED INDEX [IX_Payment_PayOS_Code] ON [dbo].[Payment] ([payos_order_code])
    
    PRINT 'Bảng Payment đã được tạo thành công!'
END
ELSE
BEGIN
    PRINT 'Bảng Payment đã tồn tại!'
END
GO

