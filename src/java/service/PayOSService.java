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
    
    // Debug fields to store PayOS API logs
    private String lastPayOSResponse = null;
    private String lastPayOSError = null;
    private String lastPayOSRequest = null;
    
    /**
     * Tạo link thanh toán PayOS
     */
    public String createPaymentLink(int orderId, double amount, String description, String returnUrl, String cancelUrl) {
        try {
            System.out.println("==== PayOSService.createPaymentLink ====");
            
            // Tạm thời bỏ qua kiểm tra config để test
            System.out.println("⚠️ Skipping PayOS config check for testing");
            System.out.println("✅ PayOS is configured (hardcoded)");
            
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
            
            // Store request for debugging
            this.lastPayOSRequest = requestBody;
            
            System.out.println("🌐 Calling PayOS API...");
            String response;
            try {
                response = PayOSUtils.makePayOSRequest("/payment-requests", "POST", requestBody, null);
                System.out.println("🔍 PayOS API call completed, response length: " + (response != null ? response.length() : "NULL"));
            } catch (Exception e) {
                System.err.println("❌ PayOS API call failed: " + e.getMessage());
                e.printStackTrace();
                this.lastPayOSError = e.getMessage();
                this.lastPayOSResponse = null;
                return null;
            }
            
            // Store response for debugging
            this.lastPayOSResponse = response;
            this.lastPayOSError = null;
            
            // Debug: Log response details
            System.out.println("📥 PayOS API Response received:");
            System.out.println("   Length: " + (response != null ? response.length() : "NULL") + " characters");
            System.out.println("   Content: " + (response != null ? response : "NULL"));
            
            // Also log to response for debugging
            if (response != null && !response.isEmpty()) {
                System.out.println("🔍 PayOS Response Analysis:");
                System.out.println("   Response: " + response);
                
                // Check if it's a JSON response
                if (response.trim().startsWith("{")) {
                    System.out.println("   ✅ Valid JSON response");
                } else {
                    System.out.println("   ❌ Non-JSON response");
                }
            }
            
            JsonObject jsonResponse = PayOSUtils.parsePayOSResponse(response);
            
            // Check for error response (only if code is not "00" which means success)
            if (jsonResponse.has("code")) {
                String code = jsonResponse.get("code").getAsString();
                String desc = jsonResponse.has("desc") ? jsonResponse.get("desc").getAsString() : "Unknown error";
                
                // "00" means success in PayOS
                if (!"00".equals(code) && !"200".equals(code)) {
                    System.err.println("❌ PayOS API Error Code: " + code);
                    System.err.println("❌ PayOS API Error Description: " + desc);
                    return null;
                }
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
     * Lấy debug info từ PayOS API call cuối cùng
     */
    public String getLastPayOSResponse() {
        return lastPayOSResponse;
    }
    
    public String getLastPayOSError() {
        return lastPayOSError;
    }
    
    public String getLastPayOSRequest() {
        return lastPayOSRequest;
    }
    
    /**
     * Tạo yêu cầu hoàn tiền qua PayOS và cập nhật trạng thái hệ thống
     */
    public boolean refundPayment(int orderCode, Integer amountVnd, String reason, String type) {
        try {
            System.out.println("==== PayOSService.refundPayment ====");
            System.out.println("orderCode=" + orderCode + ", amountVnd=" + amountVnd + ", reason=" + reason + ", type=" + type);

            // Với dịch vụ spa/boarding: hiện không lưu orderCode PayOS → hoàn tiền nội bộ
            if ("service".equalsIgnoreCase(type)) {
                boolean updated = updateServiceBookingStatus(orderCode, "đã hoàn tiền");
                System.out.println("ℹ️ Service refund is local only. Updated=" + updated);
                return updated;
            }
            if ("boarding".equalsIgnoreCase(type)) {
                boolean updated = updateBoardingPaymentStatus(orderCode, "refunded");
                System.out.println("ℹ️ Boarding refund is local only. Updated=" + updated);
                return updated;
            }

            // Sản phẩm: gọi PayOS
            com.google.gson.JsonObject body = new com.google.gson.JsonObject();
            body.addProperty("orderCode", orderCode);
            if (amountVnd != null && amountVnd > 0) {
                body.addProperty("amount", amountVnd);
            }
            if (reason != null && !reason.trim().isEmpty()) {
                body.addProperty("description", utils.PayOSUtils.normalizeDescription(reason));
            }

            Gson gson = new GsonBuilder().disableHtmlEscaping().create();
            String requestBody = gson.toJson(body);

            this.lastPayOSRequest = requestBody;
            PayOSUtils.logPayOSRequest("/payment-requests/refund", "POST", requestBody);

            String response = PayOSUtils.makePayOSRequest("/payment-requests/refund", "POST", requestBody, null);
            this.lastPayOSResponse = response;
            this.lastPayOSError = null;

            JsonObject json = PayOSUtils.parsePayOSResponse(response);
            if (json.has("code")) {
                String code = json.get("code").getAsString();
                if (!"00".equals(code) && !"200".equals(code)) {
                    this.lastPayOSError = json.has("desc") ? json.get("desc").getAsString() : "Refund failed";
                    System.err.println("❌ Refund API error: code=" + code + ", desc=" + this.lastPayOSError);
                    return false;
                }
            }

            boolean updated = updateRefundStatus(orderCode, "Da hoan tien");
            System.out.println("✅ Refund processed via PayOS. Local status updated=" + updated);
            return updated;

        } catch (Exception e) {
            this.lastPayOSError = e.getMessage();
            e.printStackTrace();
            return false;
        }
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
            System.out.println("🔍 ===== PROCESSING PAYOS WEBHOOK =====");
            System.out.println("📝 Raw webhook data: " + webhookData);
            
            if (webhookData == null || webhookData.trim().isEmpty()) {
                System.err.println("❌ Empty webhook data");
                return false;
            }
            
            JsonObject webhook = JsonParser.parseString(webhookData).getAsJsonObject();
            System.out.println("📋 Parsed webhook JSON: " + webhook.toString());
            
            if (webhook.has("data")) {
                JsonObject data = webhook.getAsJsonObject("data");
                System.out.println("📦 Webhook data object: " + data.toString());
                
                if (!data.has("orderCode")) {
                    System.err.println("❌ Missing 'orderCode' in webhook data");
                    return false;
                }
                
                int orderCode = data.get("orderCode").getAsInt();
                
                // Kiểm tra status hoặc code trong data
                String status = null;
                if (data.has("status")) {
                    status = data.get("status").getAsString();
                } else if (data.has("code")) {
                    // Nếu không có status, dùng code để xác định
                    String code = data.get("code").getAsString();
                    if ("00".equals(code)) {
                        status = "PAID"; // Code "00" nghĩa là thành công
                    }
                }
                
                System.out.println("📦 Order Code: " + orderCode);
                System.out.println("📊 Status: " + status);
                
                if (status != null && ("PAID".equals(status) || "00".equals(status))) {
                    System.out.println("✅ Payment confirmed, updating order status...");
                    
                    // Kiểm tra xem order có tồn tại không trước khi update
                    boolean updated;
                    if (orderExists(orderCode)) {
                        // Cập nhật trạng thái thanh toán trong [Order]
                        updated = updatePaymentStatus(orderCode, "Da thanh toan", new Timestamp(System.currentTimeMillis()));
                    } else {
                        // Không thấy trong [Order] → thử cập nhật cho booking lưu trú
                        System.err.println("ℹ️ Order #" + orderCode + " not found in [Order], trying boarding_bookings...");
                        updated = updateBoardingPaymentStatus(orderCode, "Đã thanh toán");
                    }
                    
                    if (updated) {
                        System.out.println("✅ Payment status updated for code #" + orderCode);
                        System.out.println("🔍 ===== WEBHOOK PROCESSING COMPLETE =====");
                        return true;
                    } else {
                        System.err.println("❌ Failed to update payment for code #" + orderCode);
                        return false;
                    }
                } else {
                    System.out.println("⚠️ Payment not completed yet, status: " + status);
                    System.out.println("ℹ️ Webhook processed but no action needed");
                    return true; // Vẫn return true vì webhook đã được xử lý đúng cách
                }
            } else {
                System.err.println("❌ No 'data' field in webhook");
                System.err.println("📋 Available fields: " + webhook.keySet());
                return false;
            }
            
        } catch (Exception e) {
            System.err.println("❌ EXCEPTION in handleWebhook: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Kiểm tra xem order có tồn tại trong database không
     */
    private boolean orderExists(int orderId) {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                 "SELECT COUNT(*) FROM [Order] WHERE order_id = ?")) {
            
            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int count = rs.getInt(1);
                    System.out.println("🔍 Order #" + orderId + " exists: " + (count > 0));
                    return count > 0;
                }
            }
            
        } catch (Exception e) {
            System.err.println("❌ ERROR checking if order exists: " + e.getMessage());
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
     * Cập nhật trạng thái thanh toán cho booking lưu trú (boarding)
     */
    private boolean updateBoardingPaymentStatus(int bookingId, String status) {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                 "UPDATE dbo.boarding_bookings SET status = ?, updated_at = ? WHERE booking_id = ?")) {
            ps.setString(1, status);
            ps.setTimestamp(2, new Timestamp(System.currentTimeMillis()));
            ps.setInt(3, bookingId);
            int rows = ps.executeUpdate();
            System.out.println("Boarding payment update rows: " + rows);
            return rows > 0;
        } catch (Exception e) {
            System.err.println("ERROR updating boarding payment status: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Cập nhật trạng thái hoàn tiền cho đơn hàng (Order)
     */
    private boolean updateRefundStatus(int orderId, String refundStatus) {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                 "UPDATE [Order] SET payment_status = ?, status = CASE WHEN status = 'Đã xác nhận' THEN 'Đã hủy' ELSE status END, paid_at = paid_at WHERE order_id = ?")) {
            ps.setString(1, refundStatus);
            ps.setInt(2, orderId);
            int rows = ps.executeUpdate();
            System.out.println("Order refund update rows: " + rows);
            return rows > 0;
        } catch (Exception e) {
            System.err.println("ERROR updating order refund status: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Cập nhật trạng thái cho booking Spa/Service (nếu tồn tại theo orderCode)
     */
    private boolean updateServiceBookingStatus(int bookingId, String status) {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                 "UPDATE Booking SET status = ?, updated_at = GETDATE() WHERE booking_id = ?")) {
            ps.setString(1, status);
            ps.setInt(2, bookingId);
            int rows = ps.executeUpdate();
            System.out.println("Service booking refund update rows: " + rows);
            return rows > 0;
        } catch (Exception e) {
            System.err.println("ERROR updating service booking status: " + e.getMessage());
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
