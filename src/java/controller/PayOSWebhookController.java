package controller;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import service.PayOSServiceV2;

import java.io.BufferedReader;
import java.io.IOException;

/**
 * PayOS Webhook Controller - Receives payment notifications from PayOS
 * This endpoint should be registered in PayOS dashboard at: https://my.payos.vn
 * 
 * Webhook URL format: http://your-domain.com/Pets4Care/payos/webhook
 * 
 * IMPORTANT: For local development, use ngrok to expose your localhost:
 * 1. Download ngrok from https://ngrok.com
 * 2. Run: ngrok http 9998
 * 3. Copy the ngrok URL (e.g., https://abc123.ngrok.io)
 * 4. Set webhook URL in PayOS dashboard: https://abc123.ngrok.io/Pets4Care/payos/webhook
 */
@WebServlet("/payos/webhook")
public class PayOSWebhookController extends HttpServlet {
    
    private final PayOSServiceV2 payOSService = new PayOSServiceV2();
    private final Gson gson = new Gson();
    
    /**
     * Handle POST webhook from PayOS
     * PayOS sends payment status updates to this endpoint
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        System.out.println("====== PAYOS WEBHOOK RECEIVED ======");
        System.out.println("Timestamp: " + System.currentTimeMillis());
        System.out.println("Remote IP: " + request.getRemoteAddr());
        
        try {
            // Read raw request body
            StringBuilder requestBody = new StringBuilder();
            try (BufferedReader reader = request.getReader()) {
                String line;
                while ((line = reader.readLine()) != null) {
                    requestBody.append(line);
                }
            }
            
            String rawBody = requestBody.toString();
            System.out.println("Raw webhook body: " + rawBody);
            
            if (rawBody.isEmpty()) {
                System.err.println("❌ Empty webhook body");
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write("{\"error\":\"Empty request body\"}");
                return;
            }
            
            // Parse JSON to Object (required by PayOS SDK)
            JsonObject webhookData = gson.fromJson(rawBody, JsonObject.class);
            
            // Process webhook using PayOSServiceV2
            // SDK will automatically verify signature
            boolean success = payOSService.handleWebhook(webhookData);
            
            if (success) {
                System.out.println("✅ Webhook processed successfully");
                
                // IMPORTANT: Return 2XX status to PayOS to confirm webhook received
                response.setStatus(HttpServletResponse.SC_OK);
                response.setContentType("application/json");
                response.getWriter().write("{\"success\":true,\"message\":\"Webhook processed\"}");
            } else {
                System.err.println("❌ Webhook processing failed");
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                response.getWriter().write("{\"error\":\"Processing failed\"}");
            }
            
        } catch (Exception e) {
            System.err.println("❌ EXCEPTION in webhook handler: " + e.getMessage());
            e.printStackTrace();
            
            // Still return 200 to PayOS to avoid retry storms
            // But log the error for debugging
            response.setStatus(HttpServletResponse.SC_OK);
            response.setContentType("application/json");
            response.getWriter().write("{\"error\":\"" + e.getMessage() + "\"}");
            
        } finally {
            System.out.println("====================================");
        }
    }
    
    /**
     * Handle GET request - For testing webhook endpoint
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("text/html;charset=UTF-8");
        response.getWriter().println("<!DOCTYPE html>");
        response.getWriter().println("<html>");
        response.getWriter().println("<head><title>PayOS Webhook Endpoint</title></head>");
        response.getWriter().println("<body>");
        response.getWriter().println("<h1>PayOS Webhook Endpoint</h1>");
        response.getWriter().println("<p>This endpoint is ready to receive PayOS webhooks.</p>");
        response.getWriter().println("<p><strong>Webhook URL:</strong> " + 
            request.getScheme() + "://" + request.getServerName() + ":" + 
            request.getServerPort() + request.getContextPath() + "/payos/webhook</p>");
        response.getWriter().println("<h2>Setup Instructions:</h2>");
        response.getWriter().println("<ol>");
        response.getWriter().println("<li>For <strong>local development</strong>:");
        response.getWriter().println("   <ul>");
        response.getWriter().println("       <li>Download and install <a href='https://ngrok.com' target='_blank'>ngrok</a></li>");
        response.getWriter().println("       <li>Run: <code>ngrok http 9998</code></li>");
        response.getWriter().println("       <li>Copy the HTTPS URL (e.g., https://abc123.ngrok.io)</li>");
        response.getWriter().println("       <li>Webhook URL: <code>https://abc123.ngrok.io/Pets4Care/payos/webhook</code></li>");
        response.getWriter().println("   </ul>");
        response.getWriter().println("</li>");
        response.getWriter().println("<li>For <strong>production</strong>:");
        response.getWriter().println("   <ul>");
        response.getWriter().println("       <li>Use your production domain</li>");
        response.getWriter().println("       <li>Webhook URL: <code>https://yourdomain.com/Pets4Care/payos/webhook</code></li>");
        response.getWriter().println("   </ul>");
        response.getWriter().println("</li>");
        response.getWriter().println("<li>Register webhook URL at <a href='https://my.payos.vn' target='_blank'>PayOS Dashboard</a></li>");
        response.getWriter().println("</ol>");
        response.getWriter().println("<hr>");
        response.getWriter().println("<p><a href='../payos/'>← Back to PayOS Tools</a></p>");
        response.getWriter().println("</body>");
        response.getWriter().println("</html>");
    }
}
