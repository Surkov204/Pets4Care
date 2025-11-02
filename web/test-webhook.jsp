<%@ page import="java.net.*" %>
<%@ page import="java.io.*" %>
<%
    response.setContentType("text/html;charset=UTF-8");
    out.println("<!DOCTYPE html>");
    out.println("<html>");
    out.println("<head>");
    out.println("<title>Test PayOS Webhook</title>");
    out.println("<style>");
    out.println("body { font-family: Arial, sans-serif; margin: 40px; background: #f5f5f5; }");
    out.println(".container { max-width: 800px; margin: 0 auto; background: white; padding: 30px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }");
    out.println("h1 { color: #333; border-bottom: 3px solid #007bff; padding-bottom: 10px; }");
    out.println(".success { color: #28a745; }");
    out.println(".error { color: #dc3545; }");
    out.println("pre { background: #f8f9fa; padding: 15px; border-radius: 5px; overflow-x: auto; }");
    out.println("</style>");
    out.println("</head>");
    out.println("<body>");
    out.println("<div class='container'>");
    
    out.println("<h1>🧪 Test PayOS Webhook</h1>");
    
    out.println("<h2>Webhook URL:</h2>");
    out.println("<p><strong>Local:</strong> http://localhost:8080/Pets4Care/payos/webhook</p>");
    out.println("<p><strong>Public (via ngrok):</strong> https://recent-giada-aimfully.ngrok-free.dev/Pets4Care/payos/webhook</p>");
    out.println("<p><strong>Monitor:</strong> https://webhook.site/b15f91fa-1b0f-423a-90cf-35c6c0426fe0</p>");
    
    // Test webhook endpoint
    try {
        String webhookUrl = "http://localhost:8080/Pets4Care/payos/webhook";
        out.println("<h2>Test Webhook Endpoint:</h2>");
        
        // Sample webhook data from PayOS
        String sampleWebhook = "{\"code\":\"00\",\"desc\":\"success\",\"data\":{\"orderCode\":1761538995,\"amount\":15740,\"description\":\"Test 8995\",\"accountNumber\":\"VQRQAEYZH1265\",\"reference\":\"\",\"transactionDateTime\":\"2025-10-27 12:00:00\",\"currency\":\"VND\",\"paymentLinkId\":\"eeb6f273c7ef48a3b90fe617c050e91f\",\"code\":\"00\",\"desc\":\"Thành công\",\"counterAccountBankId\":\"\",\"counterAccountBankName\":\"\",\"counterAccountName\":\"PHAN NHAT TOAN\",\"counterAccountNumber\":\"\",\"virtualAccountName\":\"PHAN NHAT TOAN\",\"virtualAccountNumber\":\"VQRQAEYZH1265\",\"status\":\"PAID\"},\"signature\":\"143bcce6812ca98e5f239bdd7aa6cea4f5d388b93eef76037017cf520884eb61\"}";
        
        out.println("<h3>Sample Webhook Data:</h3>");
        out.println("<pre>" + sampleWebhook + "</pre>");
        
        out.println("<h3>Test Options:</h3>");
        out.println("<ol>");
        out.println("<li>PayOS will send webhook to: https://webhook.site/b15f91fa-1b0f-423a-90cf-35c6c0426fe0</li>");
        out.println("<li>Monitor webhook data at: <a href='https://webhook.site/b15f91fa-1b0f-423a-90cf-35c6c0426fe0' target='_blank'>webhook.site</a></li>");
        out.println("<li>When payment is completed, PayOS will send webhook notification</li>");
        out.println("<li>Check the webhook.site page to see the webhook data from PayOS</li>");
        out.println("</ol>");
        
        out.println("<h3>Expected Webhook Structure:</h3>");
        out.println("<pre>{\n");
        out.println("  \"code\": \"00\",\n");
        out.println("  \"desc\": \"success\",\n");
        out.println("  \"data\": {\n");
        out.println("    \"orderCode\": 1761538995,\n");
        out.println("    \"amount\": 15740,\n");
        out.println("    \"description\": \"Test 8995\",\n");
        out.println("    \"status\": \"PAID\",\n");
        out.println("    \"paymentLinkId\": \"...\",\n");
        out.println("    \"transactionDateTime\": \"...\"\n");
        out.println("  },\n");
        out.println("  \"signature\": \"...\"\n");
        out.println("}</pre>");
        
    } catch (Exception e) {
        out.println("<p class='error'>❌ Error: " + e.getMessage() + "</p>");
    }
    
    out.println("</div>");
    out.println("</body>");
    out.println("</html>");
%>


