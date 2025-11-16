-- =============================================
-- Script: Cập nhật trạng thái đơn hàng sau thanh toán
-- Description: 
--   - Thanh toán tiền mặt: "Đang xử lý" -> "Chờ giao hàng"
--   - Thanh toán online thành công: "Đang xử lý" -> "Chờ giao hàng"
--   - Thanh toán online bị hủy: "Đang xử lý" -> "Đã hủy"
-- Date: 2025-11-16
-- =============================================

USE [SHOP_PET_Database]
GO

-- =============================================
-- Cập nhật stored procedure ConfirmAndPayOrder
-- Thay đổi status từ 'Hoàn tất' thành 'Chờ giao hàng'
-- =============================================

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ConfirmAndPayOrder]') AND type in (N'P', N'PC'))
    DROP PROCEDURE [dbo].[ConfirmAndPayOrder]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ConfirmAndPayOrder]
    @p_order_id INT,
    @p_payment_status NVARCHAR(50),
    @p_paid_at DATETIME
AS
BEGIN
    UPDATE [Order]
    SET payment_status = @p_payment_status,
        paid_at = @p_paid_at,
        status = N'Chờ giao hàng'
    WHERE order_id = @p_order_id;
END;
GO

PRINT '✅ Đã cập nhật stored procedure ConfirmAndPayOrder thành công!'
PRINT '   - Status sẽ được cập nhật thành "Chờ giao hàng" sau khi thanh toán'
GO

