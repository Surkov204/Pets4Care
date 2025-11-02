package controller;

import service.PayOSService;
import utils.DBConnection;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.BufferedReader;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.Map;

public class PayOSController extends HttpServlet {
    
    private final PayOSService payOSService = new PayOSService();
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        System.out.println("🚀 PayOSController.doGet() called");
        String pathInfo = request.getPathInfo();
        System.out.println("📝 PathInfo: " + pathInfo);
        
        if ("/create-payment".equals(pathInfo)) {
            System.out.println("✅ Handling create-payment");
            handleCreatePayment(request, response);
        } else if ("/return".equals(pathInfo)) {
            System.out.println("✅ Handling return");
            handlePaymentReturn(request, response);
        } else if ("/cancel".equals(pathInfo)) {
            System.out.println("✅ Handling cancel");
            handlePaymentCancel(request, response);
        } else {
            System.out.println("❌ Path not found: " + pathInfo);
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
            String type = request.getParameter("type"); // boarding | null
            System.out.println("====== PayOS Create Payment ======");
            System.out.println("Order ID: " + orderId);
            System.out.println("Type: " + type);
            
            double amount;
            String description;
            String returnUrl;
            String cancelUrl;
            
            if ("boarding".equalsIgnoreCase(type)) {
                // Xử lý boarding booking
                System.out.println("Processing boarding payment for booking ID: " + orderId);
                
                // Lấy thông tin booking từ database
                dao.BoardingBookingDAO bookingDAO = new dao.BoardingBookingDAO();
                model.BoardingBooking booking = bookingDAO.getBoardingBookingById(orderId);
                
                if (booking == null) {
                    System.out.println("ERROR: Booking not found!");
                    response.sendRedirect(request.getContextPath() + "/spa-booking?action=history");
                    return;
                }
                
                // Lấy amount từ totalPrice hoặc tính toán lại
                if (booking.getTotalPrice() != null && booking.getTotalPrice().compareTo(BigDecimal.ZERO) > 0) {
                    amount = booking.getTotalPrice().doubleValue();
                } else if (booking.getPricePerDay() != null && booking.getBoardingDays() > 0) {
                    // Tính lại nếu totalPrice = 0
                    amount = booking.getPricePerDay().multiply(BigDecimal.valueOf(booking.getBoardingDays())).doubleValue();
                } else {
                    // Fallback: sử dụng calculatedTotalPrice()
                    amount = booking.getCalculatedTotalPrice().doubleValue();
                }
                
                System.out.println("Booking details - PricePerDay: " + booking.getPricePerDay() + 
                                   ", BoardingDays: " + booking.getBoardingDays() + 
                                   ", TotalPrice: " + booking.getTotalPrice() + 
                                   ", Calculated: " + booking.getCalculatedTotalPrice());
                System.out.println("Final amount for PayOS: " + amount);
                
                description = "Thanh toan Boarding #" + orderId;
                
                String baseUrl = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort()
                        + request.getContextPath();
                returnUrl = baseUrl + "/payos/return?orderId=" + orderId + "&type=boarding";
                cancelUrl = baseUrl + "/payos/cancel?orderId=" + orderId + "&type=boarding";
                
            } else {
                // Xử lý order thông thường (product/service)
                System.out.println("Processing regular order for order ID: " + orderId);
                
                // Lấy thông tin đơn hàng
                Map<String, Object> orderInfo = payOSService.getOrderInfo(orderId);
                System.out.println("Order Info: " + orderInfo);
                
                if (orderInfo.isEmpty()) {
                    System.out.println("ERROR: Order info is empty!");
                    response.sendRedirect(request.getContextPath() + "/order/confirm-failed.jsp");
                    return;
                }
                
                amount = (Double) orderInfo.get("totalAmount");
                description = "Thanh toan don hang #" + orderId;

                // Dùng baseUrl hiện tại (localhost hoặc domain đang truy cập) để redirect trình duyệt
                String baseUrl = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort()
                        + request.getContextPath();
                returnUrl = baseUrl + "/payos/return?orderId=" + orderId;
                cancelUrl = baseUrl + "/payos/cancel?orderId=" + orderId;
            }
            
            System.out.println("Amount: " + amount);
            System.out.println("Description: " + description);
            System.out.println("Return URL: " + returnUrl);
            System.out.println("Cancel URL: " + cancelUrl);
            
            // Tạo link thanh toán
            String paymentUrl = payOSService.createPaymentLink(orderId, amount, description, returnUrl, cancelUrl);
            
            System.out.println("Payment URL: " + paymentUrl);
            System.out.println("=============================");
            
            // Debug: Log PayOS response details
            System.out.println("🔍 DEBUG: Payment URL result = " + paymentUrl);
            
            if (paymentUrl != null) {
                response.sendRedirect(paymentUrl);
            } else {
                System.out.println("ERROR: paymentUrl is null!");
                
                // Debug: Show detailed error instead of redirect
                response.setContentType("text/html;charset=UTF-8");
                response.getWriter().write("<html><body><h1>PayOS Debug Info</h1>");
                response.getWriter().write("<h2>Order ID:</h2><p>" + orderId + "</p>");
                response.getWriter().write("<h2>Type:</h2><p>" + type + "</p>");
                response.getWriter().write("<h2>Amount:</h2><p>" + amount + "</p>");
                response.getWriter().write("<h2>Description:</h2><p>" + description + "</p>");
                response.getWriter().write("<h2>Return URL:</h2><p>" + returnUrl + "</p>");
                response.getWriter().write("<h2>Cancel URL:</h2><p>" + cancelUrl + "</p>");
                response.getWriter().write("<h2>Payment URL:</h2><p style='color:red'>NULL</p>");
                
                // Debug PayOS Config
                response.getWriter().write("<h2>PayOS Config Debug:</h2>");
                response.getWriter().write("<p>Client ID: " + utils.PayOSConfig.getClientId() + "</p>");
                response.getWriter().write("<p>API Key: " + (utils.PayOSConfig.getApiKey() != null ? "[SET]" : "[NULL]") + "</p>");
                response.getWriter().write("<p>Checksum Key: " + (utils.PayOSConfig.getChecksumKey() != null ? "[SET]" : "[NULL]") + "</p>");
                response.getWriter().write("<p>Base URL: " + utils.PayOSConfig.getBaseUrl() + "</p>");
                response.getWriter().write("<p>Webhook URL: " + utils.PayOSConfig.getWebhookUrl() + "</p>");
                
                // Debug PayOS API Response - Show logs directly in response
                response.getWriter().write("<h2>PayOS API Debug:</h2>");
                response.getWriter().write("<p style='color:orange'>PayOS API logs will be shown below:</p>");
                
                // Call PayOS API and capture logs
                try {
                    response.getWriter().write("<h3>Calling PayOS API...</h3>");
                    String debugPaymentUrl = payOSService.createPaymentLink(orderId, amount, description, returnUrl, cancelUrl);
                    
                    response.getWriter().write("<h3>PayOS API Result:</h3>");
                    response.getWriter().write("<p><strong>Payment URL:</strong> " + (debugPaymentUrl != null ? debugPaymentUrl : "NULL") + "</p>");
                    
                    // Show detailed debug info
                    response.getWriter().write("<h3>PayOS API Debug Details:</h3>");
                    response.getWriter().write("<p><strong>Request Body:</strong></p>");
                    response.getWriter().write("<pre style='background:#f0f0f0; padding:10px; border:1px solid #ccc;'>" + 
                        (payOSService.getLastPayOSRequest() != null ? payOSService.getLastPayOSRequest() : "NULL") + "</pre>");
                    
                    response.getWriter().write("<p><strong>Response Body:</strong></p>");
                    response.getWriter().write("<pre style='background:#f0f0f0; padding:10px; border:1px solid #ccc;'>" + 
                        (payOSService.getLastPayOSResponse() != null ? payOSService.getLastPayOSResponse() : "NULL") + "</pre>");
                    
                    if (payOSService.getLastPayOSError() != null) {
                        response.getWriter().write("<p><strong>Error:</strong></p>");
                        response.getWriter().write("<pre style='background:#ffe6e6; padding:10px; border:1px solid #ff0000;'>" + payOSService.getLastPayOSError() + "</pre>");
                    }
                    
                    // Show signature debug info
                    response.getWriter().write("<h3>Signature Debug:</h3>");
                    response.getWriter().write("<p><strong>Checksum Key:</strong> " + utils.PayOSConfig.getChecksumKey() + "</p>");
                    response.getWriter().write("<p><strong>Amount:</strong> " + amount + "</p>");
                    response.getWriter().write("<p><strong>Order Code:</strong> " + orderId + "</p>");
                    response.getWriter().write("<p><strong>Return URL:</strong> " + returnUrl + "</p>");
                    response.getWriter().write("<p><strong>Cancel URL:</strong> " + cancelUrl + "</p>");
                    response.getWriter().write("<p><strong>Description:</strong> " + description + "</p>");
                    
                    if (debugPaymentUrl != null) {
                        response.getWriter().write("<p style='color:green'>✅ PayOS API call successful!</p>");
                        response.getWriter().write("<p><a href='" + debugPaymentUrl + "' target='_blank'>Test Payment Link</a></p>");
                    } else {
                        response.getWriter().write("<p style='color:red'>❌ PayOS API call failed - Payment URL is NULL</p>");
                    }
                    
                } catch (Exception e) {
                    response.getWriter().write("<h3>PayOS API Exception:</h3>");
                    response.getWriter().write("<p style='color:red'>❌ Exception: " + e.getMessage() + "</p>");
                    response.getWriter().write("<pre>" + e.toString() + "</pre>");
                }
                
                response.getWriter().write("<p><a href='" + request.getContextPath() + "/order/confirm-failed.jsp'>Back to Error Page</a></p>");
                response.getWriter().write("</body></html>");
            }
            
        } catch (Exception e) {
            System.err.println("❌ EXCEPTION in handleCreatePayment: " + e.getMessage());
            System.err.println("❌ Exception type: " + e.getClass().getName());
            e.printStackTrace();
            
            // Send detailed error to response for debugging
            try {
                response.setContentType("text/html;charset=UTF-8");
                response.getWriter().write("<html><body><h1>Debug Error</h1><p>" + e.getMessage() + "</p><pre>");
                e.printStackTrace(new java.io.PrintWriter(response.getWriter()));
                response.getWriter().write("</pre></body></html>");
            } catch (IOException ignored) {
                // Fall through to error page
            response.sendRedirect(request.getContextPath() + "/order/confirm-failed.jsp");
            }
        }
    }
    
    /**
     * Xử lý khi khách hàng quay lại sau thanh toán thành công
     * Theo tài liệu PayOS: https://payos.vn/docs/du-lieu-tra-ve/return-url
     * 
     * PayOS sẽ redirect về returnUrl với các parameters:
     * - code: Mã kết quả ("00" = thành công)
     * - id: Payment link ID
     * - cancel: "true" nếu hủy thanh toán
     * - status: Trạng thái thanh toán
     * - orderCode: Mã đơn hàng
     */
    private void handlePaymentReturn(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        try {
            // Lấy parameters từ PayOS return URL
            String code = request.getParameter("code");
            String cancel = request.getParameter("cancel");
            String status = request.getParameter("status");
            String orderCodeStr = request.getParameter("orderCode");
            String orderIdStr = request.getParameter("orderId");
            String type = request.getParameter("type"); // boarding | service | null
            
            System.out.println("📥 ===== PAYOS RETURN URL HANDLER =====");
            System.out.println("Code: " + code);
            System.out.println("Cancel: " + cancel);
            System.out.println("Status: " + status);
            System.out.println("OrderCode: " + orderCodeStr);
            System.out.println("OrderId: " + orderIdStr);
            System.out.println("Type: " + type);
            
            // Xác định orderId (ưu tiên orderCode từ PayOS, sau đó orderId từ query)
            int orderId;
            if (orderCodeStr != null && !orderCodeStr.isEmpty()) {
                orderId = Integer.parseInt(orderCodeStr);
            } else if (orderIdStr != null && !orderIdStr.isEmpty()) {
                orderId = Integer.parseInt(orderIdStr);
            } else {
                System.err.println("❌ Missing orderId/orderCode in return URL");
                response.sendRedirect(request.getContextPath() + "/order/confirm-failed.jsp");
                return;
            }
            
            // Kiểm tra nếu user hủy thanh toán
            if ("true".equalsIgnoreCase(cancel) || "cancelled".equalsIgnoreCase(status)) {
                System.out.println("⚠️ Payment was cancelled by user");
                if ("boarding".equalsIgnoreCase(type)) {
                    response.sendRedirect(request.getContextPath() + "/order/invoice-cancelled.jsp?bookingId=" + orderId + "&type=boarding&method=PayOS");
                } else if ("service".equalsIgnoreCase(type)) {
                    String qs = request.getQueryString();
                    response.sendRedirect(request.getContextPath() + "/order/invoice-cancelled.jsp?" + (qs != null ? qs : ("orderId=" + orderId + "&type=service")) + "&method=PayOS");
                } else {
                    response.sendRedirect(request.getContextPath() + "/order/invoice-cancelled.jsp?orderId=" + orderId + "&type=product&method=PayOS");
                }
                return;
            }
            
            // Kiểm tra thanh toán thành công (code = "00")
            boolean paymentSuccess = "00".equals(code) || "success".equalsIgnoreCase(status);
            
            if (paymentSuccess) {
                System.out.println("✅ Payment successful, redirecting to invoice");
                
                if ("boarding".equalsIgnoreCase(type)) {
                    response.sendRedirect(request.getContextPath() + "/order/invoice.jsp?bookingId=" + orderId + "&type=boarding&method=PayOS");
                } else if ("service".equalsIgnoreCase(type)) {
                    String qs = request.getQueryString();
                    String sep = (qs != null && qs.contains("method=")) ? "" : "&method=PayOS";
                    response.sendRedirect(request.getContextPath() + "/order/invoice.jsp?" + (qs != null ? qs : ("orderId=" + orderId + "&type=service")) + sep);
                } else {
                    // Kiểm tra database để xác nhận thanh toán đã được xử lý
                    if (isPaymentCompleted(orderId)) {
                        response.sendRedirect(request.getContextPath() + "/order/invoice.jsp?orderId=" + orderId + "&type=product&method=PayOS");
                    } else {
                        // Thanh toán thành công nhưng webhook chưa cập nhật → redirect với status pending
                        response.sendRedirect(request.getContextPath() + "/order/order-success.jsp?orderId=" + orderId + "&method=PayOS&status=pending");
                    }
                }
            } else {
                System.out.println("⚠️ Payment status unknown or failed");
                response.sendRedirect(request.getContextPath() + "/order/confirm-failed.jsp");
            }
            
        } catch (Exception e) {
            System.err.println("❌ ERROR in handlePaymentReturn: " + e.getMessage());
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
            String type = request.getParameter("type");
            
            if ("boarding".equalsIgnoreCase(type)) {
                response.sendRedirect(request.getContextPath() + "/order/invoice-cancelled.jsp?bookingId=" + orderId + "&type=boarding&method=PayOS");
            } else if ("service".equalsIgnoreCase(type)) {
                String qs = request.getQueryString();
                String sep = (qs != null && qs.contains("method=")) ? "" : "&method=PayOS";
                response.sendRedirect(request.getContextPath() + "/order/invoice-cancelled.jsp?" + (qs != null ? qs : ("orderId=" + orderId + "&type=service")) + sep);
            } else {
                response.sendRedirect(request.getContextPath() + "/order/invoice-cancelled.jsp?orderId=" + orderId + "&type=product&method=PayOS");
            }
            
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
            
            System.out.println("📨 ===== PAYOS WEBHOOK RECEIVED (PayOSController) =====");
            System.out.println("Webhook data: " + webhookData);
            System.out.println("Signature from header: " + signature);
            
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
            System.err.println("❌ EXCEPTION in PayOSController webhook: " + e.getMessage());
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
