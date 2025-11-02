<%@ page import="service.PayOSService" %>
<%@ page import="utils.PayOSConfig" %>
<!DOCTYPE html>
<html>
<head>
    <title>PayOS Debug Test</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .success { color: green; }
        .error { color: red; }
        .btn { 
            display: inline-block;
            padding: 10px 20px;
            margin: 10px 5px;
            background: #007bff;
            color: white;
            text-decoration: none;
            border-radius: 5px;
        }
        .btn:hover { background: #0056b3; }
        pre { background: #f4f4f4; padding: 10px; overflow-x: auto; }
    </style>
</head>
<body>
<%
    out.println("<h1>PayOS Debug Test</h1>");
    out.println("<div style='margin: 20px 0;'>");
    out.println("<a href='test-payos-connectivity.jsp' class='btn'>🔧 Test Connectivity</a>");
    out.println("<a href='../home.jsp' class='btn'>🏠 Home</a>");
    out.println("</div>");
    
    try {
        out.println("<h2>1. PayOS Config Test:</h2>");
        out.println("<p>Client ID: " + PayOSConfig.getClientId() + "</p>");
        out.println("<p>API Key: " + (PayOSConfig.getApiKey() != null ? "[SET]" : "[NULL]") + "</p>");
        out.println("<p>Checksum Key: " + (PayOSConfig.getChecksumKey() != null ? "[SET]" : "[NULL]") + "</p>");
        out.println("<p>Base URL: " + PayOSConfig.getBaseUrl() + "</p>");
        out.println("<p>Webhook URL: " + PayOSConfig.getWebhookUrl() + "</p>");
        
        out.println("<h2>2. PayOS Service Test:</h2>");
        PayOSService service = new PayOSService();
        
        out.println("<h3>2.1 Test getOrderInfo:</h3>");
        java.util.Map<String, Object> orderInfo = service.getOrderInfo(12);
        out.println("<p>Order Info: " + orderInfo + "</p>");
        
        if (!orderInfo.isEmpty()) {
            out.println("<h3>2.2 Test createPaymentLink:</h3>");
            double amount = (Double) orderInfo.get("totalAmount");
            String description = "Test order #12";
            String returnUrl = "https://recent-giada-aimfully.ngrok-free.dev/Pets4Care/payos/return?orderId=12";
            String cancelUrl = "https://recent-giada-aimfully.ngrok-free.dev/Pets4Care/payos/cancel?orderId=12";
            
            out.println("<p>Amount: " + amount + "</p>");
            out.println("<p>Description: " + description + "</p>");
            out.println("<p>Return URL: " + returnUrl + "</p>");
            out.println("<p>Cancel URL: " + cancelUrl + "</p>");
            
            String paymentUrl = service.createPaymentLink(12, amount, description, returnUrl, cancelUrl);
            
            if (paymentUrl != null) {
                out.println("<p style='color:green'>✅ Payment URL: " + paymentUrl + "</p>");
                out.println("<p><a href='" + paymentUrl + "' target='_blank'>Test Payment Link</a></p>");
            } else {
                out.println("<p style='color:red'>❌ Payment URL is NULL</p>");
            }
        } else {
            out.println("<p style='color:red'>❌ Order info is empty</p>");
        }
        
    } catch (Exception e) {
        out.println("<h2 style='color:red'>❌ Exception:</h2>");
        out.println("<p>" + e.getMessage() + "</p>");
        out.println("<pre>" + e.toString() + "</pre>");
        java.io.StringWriter sw = new java.io.StringWriter();
        java.io.PrintWriter pw = new java.io.PrintWriter(sw);
        e.printStackTrace(pw);
        out.println("<pre>" + sw.toString() + "</pre>");
    }
%>
</body>
</html>
