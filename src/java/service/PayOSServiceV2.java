package service;

import utils.DBConnection;
import utils.PayOSManager;
import vn.payos.model.v2.paymentRequests.PaymentLinkItem;
import vn.payos.model.webhooks.WebhookData;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * PayOS Service V2 - Using Official PayOS SDK
 * This replaces the old manual implementation with SDK-based approach
 */
public class PayOSServiceV2 {
    
    private final PayOSManager payOSManager;
    
    public PayOSServiceV2() {
        this.payOSManager = PayOSManager.getInstance();
    }
    
    /**
     * Create payment link for an order
     * 
     * @param orderId Order ID from database
     * @param amount Total amount in VND
     * @param description Payment description
     * @param returnUrl Success return URL
     * @param cancelUrl Cancel URL
     * @return Payment checkout URL
     */
    public String createPaymentLink(int orderId, double amount, String description, 
                                     String returnUrl, String cancelUrl) {
        try {
            System.out.println("==== PayOSServiceV2.createPaymentLink ====");
            System.out.println("Order ID: " + orderId);
            System.out.println("Amount: " + amount);
            System.out.println("Description: " + description);
            
            // Convert amount to VND integer (PayOS requires integer)
            int amountInVND = (int) Math.round(amount);
            
            // Use order ID as order code (must be unique and positive)
            long orderCode = orderId;
            
            // Get order items from database
            List<PaymentLinkItem> items = getOrderItems(orderId, amountInVND);
            
            // Normalize description (remove Vietnamese accents)
            String normalizedDescription = normalizeDescription(description);
            
            // Create payment link using SDK
            String checkoutUrl = payOSManager.createPaymentLink(
                orderCode,
                amountInVND,
                normalizedDescription,
                items,
                returnUrl,
                cancelUrl
            );
            
            System.out.println("✅ Payment link created: " + checkoutUrl);
            System.out.println("=============================");
            
            return checkoutUrl;
            
        } catch (Exception e) {
            System.err.println("❌ EXCEPTION in createPaymentLink: " + e.getMessage());
            e.printStackTrace();
            return null;
        }
    }
    
    /**
     * Handle webhook notification from PayOS
     * This is called when PayOS sends payment status update
     * 
     * @param webhookBody Raw webhook request body
     * @return true if webhook processed successfully
     */
    public boolean handleWebhook(Object webhookBody) {
        try {
            System.out.println("==== PayOSServiceV2.handleWebhook ====");
            
            // Verify webhook signature and parse data using SDK
            WebhookData webhookData = payOSManager.verifyWebhook(webhookBody);
            
            // Extract payment information
            long orderCode = webhookData.getOrderCode();
            int amount = webhookData.getAmount();
            String reference = webhookData.getReference();
            String status = webhookData.getCode(); // "00" = success
            
            System.out.println("Webhook Data:");
            System.out.println("   Order Code: " + orderCode);
            System.out.println("   Amount: " + amount);
            System.out.println("   Reference: " + reference);
            System.out.println("   Status Code: " + status);
            
            // Update order status in database
            if ("00".equals(status)) {
                updateOrderStatus((int)orderCode, "PAID", reference);
                System.out.println("✅ Order #" + orderCode + " marked as PAID");
            } else {
                System.out.println("⚠️ Payment status code: " + status);
            }
            
            System.out.println("=============================");
            return true;
            
        } catch (Exception e) {
            System.err.println("❌ EXCEPTION in handleWebhook: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Get order items from database to send to PayOS
     * Items array is optional but recommended for better tracking
     */
    private List<PaymentLinkItem> getOrderItems(int orderId, int totalAmount) {
        List<PaymentLinkItem> items = new ArrayList<>();
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                 "SELECT p.product_name, od.quantity, od.unit_price " +
                 "FROM OrderDetails od " +
                 "JOIN Product p ON od.product_id = p.product_id " +
                 "WHERE od.order_id = ?")) {
            
            ps.setInt(1, orderId);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                String productName = rs.getString("product_name");
                int quantity = rs.getInt("quantity");
                int unitPrice = (int) rs.getDouble("unit_price");
                
                PaymentLinkItem item = PaymentLinkItem.builder()
                    .name(productName)
                    .quantity(quantity)
                    .price(unitPrice)
                    .build();
                
                items.add(item);
            }
            
        } catch (Exception e) {
            System.err.println("⚠️ Could not fetch order items: " + e.getMessage());
            // If cannot get items, create a single item with total amount
            items.add(PaymentLinkItem.builder()
                .name("Don hang #" + orderId)
                .quantity(1)
                .price(totalAmount)
                .build());
        }
        
        return items;
    }
    
    /**
     * Update order payment status in database
     */
    private void updateOrderStatus(int orderId, String status, String transactionRef) {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                 "UPDATE [Order] SET payment_status = ?, transaction_ref = ?, payment_date = GETDATE() " +
                 "WHERE order_id = ?")) {
            
            ps.setString(1, status);
            ps.setString(2, transactionRef);
            ps.setInt(3, orderId);
            
            int updated = ps.executeUpdate();
            System.out.println("✅ Updated " + updated + " order(s) to status: " + status);
            
        } catch (Exception e) {
            System.err.println("❌ Failed to update order status: " + e.getMessage());
            e.printStackTrace();
        }
    }
    
    /**
     * Get order information from database
     */
    public Map<String, Object> getOrderInfo(int orderId) {
        Map<String, Object> orderInfo = new HashMap<>();
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                 "SELECT order_id, total_amount, payment_status, order_date FROM [Order] WHERE order_id = ?")) {
            
            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    orderInfo.put("orderId", rs.getInt("order_id"));
                    orderInfo.put("totalAmount", rs.getDouble("total_amount"));
                    orderInfo.put("paymentStatus", rs.getString("payment_status"));
                    orderInfo.put("createdAt", rs.getTimestamp("order_date"));
                }
            }
            
        } catch (Exception e) {
            e.printStackTrace();
        }
        
        return orderInfo;
    }
    
    /**
     * Normalize Vietnamese text by removing accents
     * PayOS requires this for description field
     */
    private String normalizeDescription(String text) {
        if (text == null || text.isEmpty()) {
            return "";
        }
        
        // Replace đ/Đ first
        String normalized = text.replace('đ', 'd').replace('Đ', 'D');
        
        // Remove accents
        normalized = java.text.Normalizer.normalize(normalized, java.text.Normalizer.Form.NFD);
        normalized = normalized.replaceAll("\\p{InCombiningDiacriticalMarks}+", "");
        
        // Keep only alphanumeric, space, and #
        normalized = normalized.replaceAll("[^a-zA-Z0-9 #]", "");
        
        return normalized.trim();
    }
    
    /**
     * Cancel payment link
     */
    public boolean cancelPaymentLink(int orderId) {
        try {
            payOSManager.cancelPaymentLink(orderId, "Customer cancelled order");
            return true;
        } catch (Exception e) {
            System.err.println("❌ Failed to cancel payment link: " + e.getMessage());
            return false;
        }
    }
}
