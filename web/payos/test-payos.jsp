<%@ page import="service.PayOSService" %>
<%@ page import="java.util.*" %>
<%
    response.setContentType("text/html;charset=UTF-8");
    out.println("<!DOCTYPE html>");
    out.println("<html>");
    out.println("<head>");
    out.println("<title>Test PayOS</title>");
    out.println("<style>");
    out.println("body { font-family: Arial, sans-serif; margin: 40px; background: #f5f5f5; }");
    out.println(".container { max-width: 600px; margin: 0 auto; background: white; padding: 30px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }");
    out.println("h1 { color: #333; border-bottom: 3px solid #007bff; padding-bottom: 10px; }");
    out.println(".success { color: #28a745; }");
    out.println(".error { color: #dc3545; }");
    out.println(".btn { background: #007bff; color: white; padding: 12px 30px; text-decoration: none; border-radius: 5px; display: inline-block; margin: 10px 5px; }");
    out.println(".btn:hover { background: #0056b3; }");
    out.println("pre { background: #f8f9fa; padding: 15px; border-radius: 5px; overflow-x: auto; }");
    out.println("</style>");
    out.println("</head>");
    out.println("<body>");
    out.println("<div class='container'>");
    
    out.println("<h1>🧪 Test PayOS</h1>");
    
    try {
        // Test với order ID mới (dùng timestamp để unique)
        int orderId = (int)(System.currentTimeMillis() / 1000); // Unix timestamp
        out.println("<h2>Testing Order ID: " + orderId + "</h2>");
        
        PayOSService service = new PayOSService();
        
        // Test parameters (không cần database)
        double amount = 15.74;
        String description = "Test #" + (orderId % 10000); // PayOS chỉ cho phép tối đa 25 ký tự
        String returnUrl = "https://webhook.site/b15f91fa-1b0f-423a-90cf-35c6c0426fe0/return";
        String cancelUrl = "https://webhook.site/b15f91fa-1b0f-423a-90cf-35c6c0426fe0/cancel";
        
        out.println("<h3>Test Parameters:</h3>");
        out.println("<p><strong>Order ID:</strong> " + orderId + "</p>");
        out.println("<p><strong>Amount:</strong> " + amount + " (15740 VND)</p>");
        out.println("<p><strong>Description:</strong> " + description + "</p>");
        
        out.println("<h3>Creating Payment Link...</h3>");
        String paymentUrl = service.createPaymentLink(orderId, amount, description, returnUrl, cancelUrl);
        
        if (paymentUrl != null) {
            out.println("<p class='success'>✅ Payment URL created successfully!</p>");
            out.println("<p><a href='" + paymentUrl + "' target='_blank' class='btn'>🚀 Test Payment</a></p>");
            out.println("<p><strong>Payment URL:</strong> <br><a href='" + paymentUrl + "' target='_blank' style='word-break: break-all;'>" + paymentUrl + "</a></p>");
        } else {
            out.println("<p class='error'>❌ Failed to create payment URL</p>");
            out.println("<p class='error'>PayOS Response: " + (service.getLastPayOSResponse() != null ? service.getLastPayOSResponse() : "NULL") + "</p>");
            
            // Show detailed debug
            if (service.getLastPayOSError() != null) {
                out.println("<h3>Error Details:</h3>");
                out.println("<pre>" + service.getLastPayOSError() + "</pre>");
            }
        }
        
    } catch (Exception e) {
        out.println("<p class='error'>❌ Error: " + e.getMessage() + "</p>");
        out.println("<pre>" + e.toString() + "</pre>");
    }
    
    out.println("</div>");
    out.println("</body>");
    out.println("</html>");
%>
