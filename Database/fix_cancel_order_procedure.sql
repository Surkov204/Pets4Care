-- =============================================
-- Script: Sửa lỗi stored procedure CancelOrder
-- Description: 
--   - Sửa từ toy_id sang product_id
--   - Sửa từ bảng Toy sang bảng Products
--   - Thêm điều kiện product_id IS NOT NULL
-- Date: 2025-11-16
-- =============================================

USE [SHOP_PET_Database]
GO

-- =============================================
-- Sửa stored procedure CancelOrder
-- =============================================

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CancelOrder]') AND type in (N'P', N'PC'))
    DROP PROCEDURE [dbo].[CancelOrder]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CancelOrder]
    @p_order_id INT
AS
BEGIN
    UPDATE [Order] SET status = N'Đã hủy', payment_status = 'REFUNDED' WHERE order_id = @p_order_id;

    DECLARE @product_id INT, @quantity INT;

    DECLARE cur CURSOR FOR
        SELECT product_id, quantity FROM Order_Detail WHERE order_id = @p_order_id AND product_id IS NOT NULL;

    OPEN cur;
    FETCH NEXT FROM cur INTO @product_id, @quantity;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        UPDATE Products
        SET stock_quantity = stock_quantity + @quantity
        WHERE product_id = @product_id;

        FETCH NEXT FROM cur INTO @product_id, @quantity;
    END

    CLOSE cur;
    DEALLOCATE cur;
END;
GO

PRINT '✅ Đã sửa stored procedure CancelOrder thành công!'
PRINT '   - Đã thay đổi từ toy_id sang product_id'
PRINT '   - Đã thay đổi từ bảng Toy sang bảng Products'
PRINT '   - Đã sửa payment_status từ N''Hủy'' sang ''REFUNDED'' (theo constraint)'
GO

