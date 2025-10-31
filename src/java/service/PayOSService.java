package service;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import utils.DBConnection;
import utils.PayOSConfig;
import utils.PayOSUtils;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.sql.CallableStatement;
import java.util.HashMap;
import java.util.Map;

public class PayOSService {
    
    /**
     * Tạo link thanh toán PayOS
     */
    public String createPaymentLink(int orderId, double amount, String description, String returnUrl, String cancelUrl) {
        try {
            System.out.println("==== PayOSService.createPaymentLink ====");
            
            if (!PayOSUtils.isPayOSConfigured()) {
                System.err.println("❌ PayOS chưa được cấu hình đúng cách!");
                return null;
            }
            System.out.println("✅ PayOS is configured");
            
            JsonObject paymentData = PayOSUtils.createPaymentRequest(orderId, amount, description, returnUrl, cancelUrl);
            
            if (paymentData == null || paymentData.size() == 0) {
                System.err.println("❌ Failed to create payment data");
                return null;
            }
            
            System.out.println("📤 Payment data: " + paymentData.toString());
            
            // Serialize with the SAME Gson configuration used for signing
            // This ensures disableHtmlEscaping() is applied consistently
            Gson gson = new GsonBuilder().disableHtmlEscaping().create();
            String requestBody = gson.toJson(paymentData).trim();
            
            System.out.println("📋 Request body to send: " + requestBody);
            
            PayOSUtils.logPayOSRequest("/payment-requests", "POST", requestBody);
            
            System.out.println("🌐 Calling PayOS API...");
            String response = PayOSUtils.makePayOSRequest("/payment-requests", "POST", requestBody, null);
            
            PayOSUtils.logPayOSResponse(response);
            
            if (response == null || response.isEmpty()) {
                System.err.println("❌ Empty response from PayOS");
                return null;
            }
            
            JsonObject jsonResponse = PayOSUtils.parsePayOSResponse(response);
            
            // Check for error response
            if (jsonResponse.has("code")) {
                String code = jsonResponse.get("code").getAsString();
                String desc = jsonResponse.has("desc") ? jsonResponse.get("desc").getAsString() : "Unknown error";
                System.err.println("❌ PayOS API Error Code: " + code);
                System.err.println("❌ PayOS API Error Description: " + desc);
                return null;
            }
            
            if (jsonResponse.has("error")) {
                System.err.println("❌ PayOS Error: " + jsonResponse.get("error"));
                return null;
            }
            
            // Check if data exists and is not null
            if (jsonResponse.has("data") && !jsonResponse.get("data").isJsonNull()) {
                JsonObject data = jsonResponse.getAsJsonObject("data");
                if (data.has("checkoutUrl")) {
                    String checkoutUrl = data.get("checkoutUrl").getAsString();
                    System.out.println("✅ Payment link created: " + checkoutUrl);
                    return checkoutUrl;
                }
            }
            
            System.err.println("❌ No checkoutUrl in response");
            System.err.println("Response: " + response);
            return null;
            
        } catch (Exception e) {
            System.err.println("❌ EXCEPTION in createPaymentLink: " + e.getMessage());
            e.printStackTrace();
        }
        
        return null;
    }
    
    /**
     * Xác thực webhook từ PayOS
     */
    public boolean verifyWebhook(String data, String signature) {
        return PayOSUtils.verifyWebhookSignature(data, signature);
    }
    
    /**
     * Xử lý webhook từ PayOS
     */
    public boolean handleWebhook(String webhookData) {
        try {
            System.out.println("🔍 Processing webhook...");
            
            JsonObject webhook = JsonParser.parseString(webhookData).getAsJsonObject();
            
            if (webhook.has("data")) {
                JsonObject data = webhook.getAsJsonObject("data");
                
                // Kiểm tra webhook structure theo tài liệu PayOS
                if (data.has("orderCode")) {
                    // Payment request webhook
                    int orderCode = data.get("orderCode").getAsInt();
                    String code = data.has("code") ? data.get("code").getAsString() : null;
                    String desc = data.has("desc") ? data.get("desc").getAsString() : "";
                    
                    System.out.println("📦 Order Code: " + orderCode);
                    System.out.println("📊 Code: " + code);
                    System.out.println("📋 Description: " + desc);
                    
                    // PayOS trả về code="00" khi thanh toán thành công
                    if ("00".equals(code)) {
                        System.out.println("✅ Payment confirmed (code 00), updating order status...");
                        // Cập nhật trạng thái thanh toán trong database
                        boolean updated = updatePaymentStatus(orderCode, "Da thanh toan", new Timestamp(System.currentTimeMillis()));
                        
                        if (updated) {
                            System.out.println("✅ Order #" + orderCode + " updated to 'Da thanh toan'");
                        } else {
                            System.err.println("❌ Failed to update order #" + orderCode);
                        }
                        
                        return updated;
                    } else {
                        System.out.println("⚠️ Payment not completed yet, code: " + code + ", desc: " + desc);
                    }
                } else if (data.has("payouts")) {
                    // Payout webhook - not implemented yet
                    System.out.println("📊 Payout webhook received but not handled");
                    return true; // Return true to acknowledge receipt
                } else {
                    System.err.println("❌ Unknown webhook data structure");
                }
            } else {
                System.err.println("❌ No 'data' field in webhook");
            }
            
        } catch (Exception e) {
            System.err.println("❌ EXCEPTION in handleWebhook: " + e.getMessage());
            e.printStackTrace();
        }
        
        return false;
    }
    
    /**
     * Cập nhật trạng thái thanh toán trong database
     */
    private boolean updatePaymentStatus(int orderId, String paymentStatus, Timestamp paidAt) {
        try (Connection conn = DBConnection.getConnection();
             java.sql.CallableStatement cs = conn.prepareCall("{call ConfirmAndPayOrder(?, ?, ?)}")) {
            
            System.out.println("Updating payment status for order #" + orderId);
            System.out.println("Payment status: " + paymentStatus);
            System.out.println("Paid at: " + paidAt);
            
            cs.setInt(1, orderId);
            cs.setString(2, paymentStatus);
            cs.setTimestamp(3, paidAt);
            
            int result = cs.executeUpdate();
            System.out.println("Stored procedure executed. Rows affected: " + result);
            
            return result > 0;
            
        } catch (Exception e) {
            System.err.println("ERROR updating payment status: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Lấy thông tin đơn hàng
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
    
}
