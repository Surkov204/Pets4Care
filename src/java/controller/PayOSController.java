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
            String paymentUrl = null; // Khai báo paymentUrl ở đây để dùng cho tất cả các loại
            
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
                
                // Giới hạn description <= 25 ký tự cho PayOS
                description = "Thanh toan Boarding #" + orderId;
                if (description.length() > 25) {
                    description = "Boarding #" + orderId;
                }
                if (description.length() > 25) {
                    description = "B#" + orderId;
                }
                
                String baseUrl = buildBaseUrl(request);
                returnUrl = baseUrl + "/payos/return?orderId=" + orderId + "&type=boarding";
                cancelUrl = baseUrl + "/payos/cancel?orderId=" + orderId + "&type=boarding";
                
            } else if ("service".equalsIgnoreCase(type)) {
                // Xử lý service booking
                System.out.println("Processing service payment for booking ID: " + orderId);
                
                // Lấy thông tin booking từ database
                try (Connection conn = DBConnection.getConnection();
                     PreparedStatement ps = conn.prepareStatement(
                         "SELECT b.booking_id, b.order_id, b.status, " +
                         "COALESCE(SUM(bs.unit_price * bs.quantity), 0) as total_amount " +
                         "FROM dbo.Booking b " +
                         "LEFT JOIN dbo.Booking_Service bs ON b.booking_id = bs.booking_id " +
                         "WHERE b.order_id = ? OR b.booking_id = ? " +
                         "GROUP BY b.booking_id, b.order_id, b.status")) {
                    
                    ps.setInt(1, orderId);
                    ps.setInt(2, orderId);
                    
                    try (ResultSet rs = ps.executeQuery()) {
                        double calculatedAmount = 0;
                        if (rs.next()) {
                            // Lấy amount từ total_amount
                            calculatedAmount = rs.getDouble("total_amount");
                            System.out.println("Calculated amount from database: " + calculatedAmount);
                        }
                        
                        // Lấy amount từ nhiều nguồn (database > request param > service calculation)
                        String requestAmount = request.getParameter("amount");
                        
                        if (calculatedAmount > 0) {
                            amount = calculatedAmount;
                            System.out.println("Using calculated amount from database: " + amount);
                        } else if (requestAmount != null && !requestAmount.trim().isEmpty()) {
                            try {
                                amount = Double.parseDouble(requestAmount);
                                System.out.println("Using amount from request parameter: " + amount);
                            } catch (NumberFormatException e) {
                                System.err.println("Invalid amount parameter: " + requestAmount);
                                amount = 0;
                            }
                        } else {
                            // Fallback: lấy từ quantity và serviceId nếu có
                            String serviceIdParam = request.getParameter("serviceId");
                            String quantityParam = request.getParameter("quantity");
                            if (serviceIdParam != null && quantityParam != null) {
                                try {
                                    int serviceId = Integer.parseInt(serviceIdParam);
                                    int quantity = Integer.parseInt(quantityParam);
                                    dao.PetServiceDAO serviceDAO = new dao.PetServiceDAO();
                                    model.PetServiceModel service = serviceDAO.getServiceById(serviceId);
                                    if (service != null) {
                                        amount = service.getPrice().doubleValue() * quantity;
                                        System.out.println("Calculated amount from service: " + amount);
                                    } else {
                                        System.err.println("Service not found: " + serviceId);
                                        amount = 0;
                                    }
                                } catch (NumberFormatException e) {
                                    System.err.println("Invalid serviceId or quantity: " + serviceIdParam + ", " + quantityParam);
                                    amount = 0;
                                }
                            } else {
                                System.err.println("No amount source available - calculated: " + calculatedAmount + 
                                                 ", requestAmount: " + requestAmount + 
                                                 ", serviceId: " + request.getParameter("serviceId") +
                                                 ", quantity: " + request.getParameter("quantity"));
                                amount = 0;
                            }
                        }
                        
                        if (amount <= 0) {
                            System.err.println("ERROR: Cannot determine payment amount for service booking: " + orderId);
                            response.sendRedirect(request.getContextPath() + "/spa-booking?action=cart");
                            return;
                        }
                        
                        // Giới hạn description <= 25 ký tự cho PayOS
                        description = "Thanh toan Spa #" + orderId;
                        if (description.length() > 25) {
                            description = "Spa #" + orderId;
                        }
                        
                        String baseUrl = buildBaseUrl(request);
                        returnUrl = baseUrl + "/payos/return?orderId=" + orderId + "&type=service";
                        cancelUrl = baseUrl + "/payos/cancel?orderId=" + orderId + "&type=service";
                        
                        // Thêm các tham số khác nếu có
                        String serviceId = request.getParameter("serviceId");
                        String quantity = request.getParameter("quantity");
                        if (serviceId != null) {
                            returnUrl += "&serviceId=" + serviceId;
                            cancelUrl += "&serviceId=" + serviceId;
                        }
                        if (quantity != null) {
                            returnUrl += "&quantity=" + quantity;
                            cancelUrl += "&quantity=" + quantity;
                        }
                        if (requestAmount != null || calculatedAmount > 0) {
                            String amountStr = requestAmount != null ? requestAmount : String.valueOf(amount);
                            returnUrl += "&amount=" + amountStr;
                            cancelUrl += "&amount=" + amountStr;
                        }
                    }
                } catch (Exception e) {
                    System.err.println("ERROR getting service booking info: " + e.getMessage());
                    e.printStackTrace();
                    response.sendRedirect(request.getContextPath() + "/spa-booking?action=history");
                    return;
                }
                
            } else {
                // Xử lý order thông thường (product)
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
                // Giới hạn description <= 25 ký tự cho PayOS
                description = "Thanh toan don hang #" + orderId;
                if (description.length() > 25) {
                    description = "Don hang #" + orderId;
                }
                if (description.length() > 25) {
                    description = "DH#" + orderId;
                }

                // Dùng baseUrl hiện tại (localhost hoặc domain đang truy cập) để redirect trình duyệt
                String baseUrl = buildBaseUrl(request);
                returnUrl = baseUrl + "/payos/return?orderId=" + orderId;
                cancelUrl = baseUrl + "/payos/cancel?orderId=" + orderId;
                
                // Tạo PayOS orderCode unique từ timestamp + orderId để tránh trùng
                long timestamp = System.currentTimeMillis();
                int payosOrderCode = (int) ((timestamp % 1000000000) * 1000 + (orderId % 1000));
                if (payosOrderCode < 0) {
                    payosOrderCode = Math.abs(payosOrderCode);
                }
                System.out.println("Generated PayOS orderCode: " + payosOrderCode + " (from timestamp: " + timestamp + ", orderId: " + orderId + ")");
                
                // Retry logic: nếu gặp lỗi 231 (orderCode đã tồn tại), thử lại với orderCode mới
                int maxRetries = 3;
                int retryCount = 0;
                
                while (paymentUrl == null && retryCount < maxRetries) {
                    if (retryCount > 0) {
                        // Tạo orderCode mới cho retry
                        timestamp = System.currentTimeMillis();
                        payosOrderCode = (int) ((timestamp % 1000000000) * 1000 + ((orderId * (retryCount + 1)) % 1000));
                        if (payosOrderCode < 0) {
                            payosOrderCode = Math.abs(payosOrderCode);
                        }
                        System.out.println("Retry #" + retryCount + " with new PayOS orderCode: " + payosOrderCode);
                    }
                    
                    paymentUrl = payOSService.createPaymentLink(payosOrderCode, amount, description, returnUrl, cancelUrl);
                    
                    if (paymentUrl == null) {
                        String lastError = payOSService.getLastPayOSError();
                        if (lastError != null && lastError.contains("231")) {
                            // OrderCode đã tồn tại, retry với orderCode mới
                            System.out.println("OrderCode " + payosOrderCode + " already exists, retrying...");
                            retryCount++;
                        } else {
                            // Lỗi khác, không retry
                            break;
                        }
                    }
                }
                
                System.out.println("Final PayOS orderCode used: " + payosOrderCode);
                System.out.println("Amount: " + amount);
                System.out.println("Description: " + description);
                System.out.println("Return URL: " + returnUrl);
                System.out.println("Cancel URL: " + cancelUrl);
                
                // Lưu PayOS orderCode vào database để có thể tra cứu sau này
                if (paymentUrl != null && payosOrderCode != orderId) {
                    try (Connection conn = DBConnection.getConnection();
                         PreparedStatement ps = conn.prepareStatement(
                             "UPDATE [Order] SET note = ? WHERE order_id = ?")) {
                        // Lưu PayOS orderCode vào note field hoặc tạo cột mới nếu cần
                        String note = "PayOS OrderCode: " + payosOrderCode;
                        ps.setString(1, note);
                        ps.setInt(2, orderId);
                        ps.executeUpdate();
                        System.out.println("Saved PayOS orderCode " + payosOrderCode + " for order " + orderId);
                    } catch (Exception e) {
                        System.err.println("Failed to save PayOS orderCode: " + e.getMessage());
                        // Không fail payment nếu không lưu được note
                    }
                }
            }
            
            // Với service hoặc boarding, tạo paymentUrl nếu chưa có
            if (paymentUrl == null && ("service".equalsIgnoreCase(type) || "boarding".equalsIgnoreCase(type))) {
                System.out.println("Creating payment link for service/boarding...");
                System.out.println("Amount: " + amount);
                System.out.println("Description: " + description);
                System.out.println("Return URL: " + returnUrl);
                System.out.println("Cancel URL: " + cancelUrl);
                
                paymentUrl = payOSService.createPaymentLink(orderId, amount, description, returnUrl, cancelUrl);
            }
            
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
     */
    private void handlePaymentReturn(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        try {
            int orderId = Integer.parseInt(request.getParameter("orderId"));
            String type = request.getParameter("type"); // boarding | null
            
            if ("boarding".equalsIgnoreCase(type)) {
                // Với boarding: redirect tới invoice success
                response.sendRedirect(request.getContextPath() + "/order/invoice.jsp?bookingId=" + orderId + "&type=boarding&method=PayOS");
                return;
            } else if ("service".equalsIgnoreCase(type)) {
                // Service: Verify payment status từ PayOS và cập nhật nếu đã thanh toán
                System.out.println("🔍 Verifying payment status for service booking orderId: " + orderId);
                
                // Lấy PayOS orderCode từ database (có thể lưu trong note hoặc dùng order_id trực tiếp)
                int payosOrderCode = orderId; // Có thể cần query từ database để lấy PayOS orderCode thật
                
                try (java.sql.Connection conn = utils.DBConnection.getConnection();
                     java.sql.PreparedStatement ps = conn.prepareStatement(
                         "SELECT order_id, note FROM dbo.Booking WHERE order_id = ? OR booking_id = ?")) {
                    ps.setInt(1, orderId);
                    ps.setInt(2, orderId);
                    try (java.sql.ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            // Ưu tiên dùng order_id làm PayOS orderCode
                            int dbOrderId = rs.getInt("order_id");
                            if (dbOrderId > 0) {
                                payosOrderCode = dbOrderId;
                            }
                            // Hoặc parse từ note nếu có
                            String note = rs.getString("note");
                            if (note != null && note.contains("PayOS OrderCode:")) {
                                try {
                                    String codeStr = note.substring(note.indexOf("PayOS OrderCode:") + "PayOS OrderCode:".length()).trim().split(" ")[0];
                                    payosOrderCode = Integer.parseInt(codeStr);
                                } catch (Exception e) {
                                    // Ignore parsing error
                                }
                            }
                        }
                    }
                }
                
                // Verify payment status từ PayOS
                String payosStatus = payOSService.getPaymentStatusFromPayOS(payosOrderCode);
                if ("PAID".equalsIgnoreCase(payosStatus)) {
                    // Nếu đã thanh toán, cập nhật status trong database
                    System.out.println("✅ Payment verified as PAID, updating booking status...");
                    payOSService.updateServiceBookingPaymentStatus(payosOrderCode, "Đã thanh toán");
                }
                
                // Service: chuyển nguyên query tới invoice (kèm method)
                String qs = request.getQueryString();
                String sep = (qs != null && qs.contains("method=")) ? "" : "&method=PayOS";
                response.sendRedirect(request.getContextPath() + "/order/invoice.jsp?" + (qs != null ? qs : ("orderId=" + orderId + "&type=service")) + sep);
                return;
            }
            
            // Kiểm tra trạng thái thanh toán trong database (đơn hàng sản phẩm)
            if (isPaymentCompleted(orderId)) {
                response.sendRedirect(request.getContextPath() + "/order/invoice.jsp?orderId=" + orderId + "&type=product&method=PayOS");
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
            String type = request.getParameter("type");
            
            if ("service".equalsIgnoreCase(type)) {
                // Cập nhật status booking thành "Hủy" nếu là service booking
                try (java.sql.Connection conn = utils.DBConnection.getConnection();
                     java.sql.PreparedStatement ps = conn.prepareStatement(
                         "UPDATE dbo.Booking SET status = N'Hủy', updated_at = GETDATE() " +
                         "WHERE order_id = ? OR booking_id = ?")) {
                    
                    ps.setInt(1, orderId);
                    ps.setInt(2, orderId);
                    int rows = ps.executeUpdate();
                    if (rows > 0) {
                        System.out.println("✅ Đã cập nhật booking status thành 'Hủy' cho orderId: " + orderId);
                    } else {
                        // Nếu không tìm thấy theo order_id, thử tìm booking mới nhất của customer hiện tại
                        jakarta.servlet.http.HttpSession session = request.getSession(false);
                        if (session != null) {
                            model.Customer customer = (model.Customer) session.getAttribute("currentUser");
                            if (customer != null) {
                                try (java.sql.PreparedStatement ps2 = conn.prepareStatement(
                                    "UPDATE b SET b.status = N'Hủy', b.updated_at = GETDATE() " +
                                    "FROM (SELECT TOP 1 booking_id FROM dbo.Booking " +
                                    "WHERE customer_id = ? AND status IN (N'Chưa thanh toán', N'Chờ xác nhận', N'pending') " +
                                    "ORDER BY created_at DESC) t " +
                                    "INNER JOIN dbo.Booking b ON b.booking_id = t.booking_id")) {
                                    ps2.setInt(1, customer.getCustomerId());
                                    int rows2 = ps2.executeUpdate();
                                    if (rows2 > 0) {
                                        System.out.println("✅ Đã cập nhật booking status thành 'Hủy' cho customer: " + customer.getCustomerId());
                                    }
                                }
                            }
                        }
                    }
                } catch (Exception e) {
                    System.err.println("❌ Lỗi khi cập nhật booking status: " + e.getMessage());
                    e.printStackTrace();
                }
                
                String qs = request.getQueryString();
                String sep = (qs != null && qs.contains("method=")) ? "" : "&method=PayOS";
                response.sendRedirect(request.getContextPath() + "/order/invoice-cancelled.jsp?" + (qs != null ? qs : ("orderId=" + orderId + "&type=service")) + sep);
            } else if ("boarding".equalsIgnoreCase(type)) {
                response.sendRedirect(request.getContextPath() + "/order/invoice-cancelled.jsp?bookingId=" + orderId + "&type=boarding&method=PayOS");
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
     * Tạo baseUrl an toàn từ request
     */
    private String buildBaseUrl(HttpServletRequest request) {
        String scheme = request.getScheme();
        String serverName = request.getServerName();
        int port = request.getServerPort();
        String contextPath = request.getContextPath();
        
        // Xử lý contextPath null hoặc rỗng
        if (contextPath == null || contextPath.trim().isEmpty()) {
            contextPath = "";
        }
        
        StringBuilder url = new StringBuilder();
        url.append(scheme).append("://").append(serverName);
        
        // Chỉ thêm port nếu không phải port chuẩn (80 cho http, 443 cho https)
        if ((scheme.equals("http") && port != 80) || (scheme.equals("https") && port != 443)) {
            url.append(":").append(port);
        }
        
        url.append(contextPath);
        
        return url.toString();
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
