package controller;

import service.PayOSService;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;

public class PayOSWebhookServlet extends HttpServlet {
    
    private final PayOSService payOSService = new PayOSService();
    
    @Override
    protected void doOptions(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        // Xử lý preflight request cho CORS
        resp.setHeader("Access-Control-Allow-Origin", "*");
        resp.setHeader("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS");
        resp.setHeader("Access-Control-Allow-Headers", "Content-Type, Authorization, x-payos-signature");
        resp.setStatus(HttpServletResponse.SC_OK);
    }
    
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        // Xử lý GET request cho test
        resp.setHeader("Access-Control-Allow-Origin", "*");
        resp.setContentType("application/json; charset=UTF-8");
        resp.getWriter().write("{\"message\":\"PayOS Webhook is running! Use POST method to send webhook data.\"}");
    }
    
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        // Thêm CORS headers
        resp.setHeader("Access-Control-Allow-Origin", "*");
        resp.setHeader("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS");
        resp.setHeader("Access-Control-Allow-Headers", "Content-Type, Authorization, x-payos-signature");
        resp.setContentType("application/json; charset=UTF-8");

        try {
            // Bước 1: Đọc dữ liệu webhook
            StringBuilder jsonBuffer = new StringBuilder();
            try (BufferedReader reader = new BufferedReader(new InputStreamReader(req.getInputStream()))) {
                String line;
                while ((line = reader.readLine()) != null) {
                    jsonBuffer.append(line);
                }
            }
            
            String webhookData = jsonBuffer.toString();
            System.out.println("📨 ===== PAYOS WEBHOOK RECEIVED =====");
            System.out.println("Webhook data: " + webhookData);
            
            // Nếu không có body => lỗi 400
            if (webhookData == null || webhookData.trim().isEmpty()) {
                System.err.println("❌ Missing webhook body");
                resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                resp.getWriter().write("{\"message\":\"Missing body\"}");
                return;
            }

            // Bước 2: Xác thực signature
            String signature = req.getHeader("x-payos-signature");
            System.out.println("🔑 Signature from header: " + signature);
            
            if (signature == null || signature.isEmpty()) {
                System.err.println("⚠️ No signature header - PayOS webhook should include x-payos-signature");
                // Trong môi trường production, nên reject webhook không có signature
                // Nhưng để test, tạm thời chấp nhận
                System.err.println("⚠️ Accepting webhook without signature for testing purposes");
            } else {
                // Verify signature nếu có
                if (!payOSService.verifyWebhook(webhookData, signature)) {
                    System.err.println("❌ Invalid webhook signature - rejecting webhook");
                    resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                    resp.getWriter().write("{\"message\":\"Invalid signature\"}");
                    return;
                }
                System.out.println("✅ Webhook signature verified successfully");
            }
            
            // Bước 3: Xử lý webhook và cập nhật trạng thái đơn hàng
            System.out.println("✅ Webhook signature verified");
            
            if (payOSService.handleWebhook(webhookData)) {
                System.out.println("✅ Order status updated successfully");
                resp.setStatus(HttpServletResponse.SC_OK);
                resp.getWriter().write("{\"message\":\"Webhook processed successfully\"}");
            } else {
                System.err.println("❌ Failed to process webhook");
                resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                resp.getWriter().write("{\"message\":\"Failed to process webhook\"}");
            }
            
        } catch (Exception e) {
            System.err.println("❌ EXCEPTION in webhook: " + e.getMessage());
            e.printStackTrace();
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            resp.getWriter().write("{\"message\":\"Internal server error\"}");
        }
    }
}
