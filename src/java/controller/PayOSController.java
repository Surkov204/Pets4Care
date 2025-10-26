package controller;

import service.PayOSService;
import utils.DBConnection;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.BufferedReader;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.Map;

public class PayOSController extends HttpServlet {
    
    private final PayOSService payOSService = new PayOSService();
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String pathInfo = request.getPathInfo();
        
        if ("/create-payment".equals(pathInfo)) {
            handleCreatePayment(request, response);
        } else if ("/return".equals(pathInfo)) {
            handlePaymentReturn(request, response);
        } else if ("/cancel".equals(pathInfo)) {
            handlePaymentCancel(request, response);
        } else {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String pathInfo = request.getPathInfo();
        
        if ("/webhook".equals(pathInfo)) {
            handleWebhook(request, response);
        } else {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }
    
    /**
     * Tạo link thanh toán PayOS
     */
    private void handleCreatePayment(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        try {
            int orderId = Integer.parseInt(request.getParameter("orderId"));
            System.out.println("====== PayOS Create Payment ======");
            System.out.println("Order ID: " + orderId);
            
            // Lấy thông tin đơn hàng
            Map<String, Object> orderInfo = payOSService.getOrderInfo(orderId);
            System.out.println("Order Info: " + orderInfo);
            
            if (orderInfo.isEmpty()) {
                System.out.println("ERROR: Order info is empty!");
                response.sendRedirect(request.getContextPath() + "/order/confirm-failed.jsp");
                return;
            }
            
            double amount = (Double) orderInfo.get("totalAmount");
            String description = "Thanh toan don hang #" + orderId;
            
            System.out.println("Amount: " + amount);
            System.out.println("Description: " + description);
            
            // Sử dụng ngrok URL thay vì localhost để PayOS có thể truy cập được
            String ngrokBaseUrl = "https://uninvigorated-unfavorably-dotty.ngrok-free.dev";
            String returnUrl = ngrokBaseUrl + "/Pets4Care/payos/return?orderId=" + orderId;
            String cancelUrl = ngrokBaseUrl + "/Pets4Care/payos/cancel?orderId=" + orderId;
            
            System.out.println("Return URL: " + returnUrl);
            System.out.println("Cancel URL: " + cancelUrl);
            
            // Tạo link thanh toán
            String paymentUrl = payOSService.createPaymentLink(orderId, amount, description, returnUrl, cancelUrl);
            
            System.out.println("Payment URL: " + paymentUrl);
            System.out.println("=============================");
            
            if (paymentUrl != null) {
                response.sendRedirect(paymentUrl);
            } else {
                System.out.println("ERROR: paymentUrl is null!");
                response.sendRedirect(request.getContextPath() + "/order/confirm-failed.jsp");
            }
            
        } catch (Exception e) {
            System.out.println("EXCEPTION in handleCreatePayment: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/order/confirm-failed.jsp");
        }
    }
    
    /**
     * Xử lý khi khách hàng quay lại sau thanh toán thành công
     */
    private void handlePaymentReturn(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        try {
            int orderId = Integer.parseInt(request.getParameter("orderId"));
            
            // Kiểm tra trạng thái thanh toán trong database
            if (isPaymentCompleted(orderId)) {
                response.sendRedirect(request.getContextPath() + "/order/order-success.jsp?orderId=" + orderId + "&method=PayOS");
            } else {
                response.sendRedirect(request.getContextPath() + "/order/order-success.jsp?orderId=" + orderId + "&method=PayOS&status=pending");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/order/confirm-failed.jsp");
        }
    }
    
    /**
     * Xử lý khi khách hàng hủy thanh toán
     */
    private void handlePaymentCancel(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        try {
            int orderId = Integer.parseInt(request.getParameter("orderId"));
            response.sendRedirect(request.getContextPath() + "/order/order-success.jsp?orderId=" + orderId + "&method=Cash on Delivery");
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/order/confirm-failed.jsp");
        }
    }
    
    /**
     * Xử lý webhook từ PayOS
     */
    private void handleWebhook(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        try {
            // Đọc dữ liệu webhook
            StringBuilder jsonBuffer = new StringBuilder();
            try (BufferedReader reader = request.getReader()) {
                String line;
                while ((line = reader.readLine()) != null) {
                    jsonBuffer.append(line);
                }
            }
            
            String webhookData = jsonBuffer.toString();
            String signature = request.getHeader("x-payos-signature");
            
            // Xác thực webhook
            if (payOSService.verifyWebhook(webhookData, signature)) {
                // Xử lý webhook
                if (payOSService.handleWebhook(webhookData)) {
                    response.setStatus(HttpServletResponse.SC_OK);
                    response.getWriter().write("OK");
                } else {
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    response.getWriter().write("Failed to process webhook");
                }
            } else {
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                response.getWriter().write("Invalid signature");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("Internal server error");
        }
    }
    
    /**
     * Kiểm tra xem thanh toán đã hoàn thành chưa
     */
    private boolean isPaymentCompleted(int orderId) {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                 "SELECT payment_status, status FROM [Order] WHERE order_id = ?")) {
            
            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    String paymentStatus = rs.getString("payment_status");
                    String status = rs.getString("status");
                    
                    System.out.println("Checking order #" + orderId);
                    System.out.println("Payment status: " + paymentStatus);
                    System.out.println("Order status: " + status);
                    
                    return "Da thanh toan".equals(paymentStatus);
                } else {
                    System.err.println("Order #" + orderId + " not found!");
                    return false;
                }
            }
            
        } catch (Exception e) {
            System.err.println("ERROR checking payment status: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
}
