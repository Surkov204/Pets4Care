package utils;

import vn.payos.PayOS;
import vn.payos.model.v2.paymentRequests.CreatePaymentLinkRequest;
import vn.payos.model.v2.paymentRequests.CreatePaymentLinkResponse;
import vn.payos.model.v2.paymentRequests.PaymentLinkItem;
import vn.payos.model.webhooks.WebhookData;

/**
 * PayOS Manager - Singleton pattern to manage PayOS SDK instance
 * Based on official PayOS Java SDK documentation
 */
public class PayOSManager {
    
    private static PayOSManager instance;
    private PayOS payOS;
    
    /**
     * Private constructor for Singleton pattern
     */
    private PayOSManager() {
        initializePayOS();
    }
    
    /**
     * Get singleton instance
     */
    public static synchronized PayOSManager getInstance() {
        if (instance == null) {
            instance = new PayOSManager();
        }
        return instance;
    }
    
    /**
     * Initialize PayOS SDK with credentials from config
     */
    private void initializePayOS() {
        try {
            String clientId = PayOSConfig.getClientId();
            String apiKey = PayOSConfig.getApiKey();
            String checksumKey = PayOSConfig.getChecksumKey();
            
            System.out.println("🔧 Initializing PayOS SDK...");
            System.out.println("   Client ID: " + clientId);
            System.out.println("   API Key: " + (apiKey != null ? "[SET]" : "[NULL]"));
            System.out.println("   Checksum Key: " + (checksumKey != null ? "[SET]" : "[NULL]"));
            
            if (clientId == null || apiKey == null || checksumKey == null) {
                throw new IllegalStateException("PayOS credentials not configured in payos.properties");
            }
            
            // Initialize PayOS SDK
            this.payOS = new PayOS(clientId, apiKey, checksumKey);
            
            System.out.println("✅ PayOS SDK initialized successfully!");
            
        } catch (Exception e) {
            System.err.println("❌ Failed to initialize PayOS SDK: " + e.getMessage());
            e.printStackTrace();
            throw new RuntimeException("PayOS initialization failed", e);
        }
    }
    
    /**
     * Create payment link using PayOS SDK
     * 
     * @param orderCode Unique order code (use timestamp or order ID)
     * @param amount Amount in VND
     * @param description Payment description
     * @param items List of items (optional but recommended)
     * @param returnUrl URL to redirect after successful payment
     * @param cancelUrl URL to redirect if payment is cancelled
     * @return Payment checkout URL
     */
    public String createPaymentLink(
            long orderCode,
            int amount,
            String description,
            java.util.List<PaymentLinkItem> items,
            String returnUrl,
            String cancelUrl) throws Exception {
        
        System.out.println("💳 Creating payment link with PayOS SDK...");
        System.out.println("   Order Code: " + orderCode);
        System.out.println("   Amount: " + amount + " VND");
        System.out.println("   Description: " + description);
        System.out.println("   Items count: " + (items != null ? items.size() : 0));
        System.out.println("   Return URL: " + returnUrl);
        System.out.println("   Cancel URL: " + cancelUrl);
        
        try {
            // Build payment request using SDK builder
            CreatePaymentLinkRequest.CreatePaymentLinkRequestBuilder builder = 
                CreatePaymentLinkRequest.builder()
                    .orderCode(orderCode)
                    .amount(amount)
                    .description(description)
                    .returnUrl(returnUrl)
                    .cancelUrl(cancelUrl);
            
            // Add items if provided
            if (items != null && !items.isEmpty()) {
                for (PaymentLinkItem item : items) {
                    builder.item(item);
                }
            }
            
            CreatePaymentLinkRequest request = builder.build();
            
            // Call PayOS API using SDK (SDK handles signature automatically)
            CreatePaymentLinkResponse response = payOS.paymentRequests().create(request);
            
            System.out.println("✅ Payment link created successfully!");
            System.out.println("   Payment Link ID: " + response.getPaymentLinkId());
            System.out.println("   Checkout URL: " + response.getCheckoutUrl());
            System.out.println("   QR Code: " + response.getQrCode());
            
            return response.getCheckoutUrl();
            
        } catch (Exception e) {
            System.err.println("❌ Failed to create payment link: " + e.getMessage());
            e.printStackTrace();
            throw e;
        }
    }
    
    /**
     * Verify webhook signature and parse webhook data
     * This is the CORRECT way to handle webhooks according to PayOS docs
     * 
     * @param webhookBody Raw webhook request body (Object or String)
     * @return Verified WebhookData containing payment information
     */
    public WebhookData verifyWebhook(Object webhookBody) throws Exception {
        System.out.println("🔐 Verifying webhook signature with PayOS SDK...");
        
        try {
            // SDK automatically verifies signature and returns data
            WebhookData data = payOS.webhooks().verify(webhookBody);
            
            System.out.println("✅ Webhook verified successfully!");
            System.out.println("   Order Code: " + data.getOrderCode());
            System.out.println("   Amount: " + data.getAmount());
            System.out.println("   Description: " + data.getDescription());
            System.out.println("   Reference: " + data.getReference());
            System.out.println("   Transaction Time: " + data.getTransactionDateTime());
            
            return data;
            
        } catch (Exception e) {
            System.err.println("❌ Webhook verification failed: " + e.getMessage());
            e.printStackTrace();
            throw e;
        }
    }
    
    /**
     * Get payment information by order code
     * 
     * @param orderCode Order code to lookup
     * @return Payment link data
     */
    public Object getPaymentInfo(long orderCode) throws Exception {
        System.out.println("🔍 Getting payment info for order: " + orderCode);
        
        try {
            Object paymentData = payOS.paymentRequests().get(orderCode);
            System.out.println("✅ Payment info retrieved successfully!");
            return paymentData;
            
        } catch (Exception e) {
            System.err.println("❌ Failed to get payment info: " + e.getMessage());
            e.printStackTrace();
            throw e;
        }
    }
    
    /**
     * Cancel payment link
     * 
     * @param orderCode Order code to cancel
     */
    public void cancelPaymentLink(long orderCode, String reason) throws Exception {
        System.out.println("❌ Cancelling payment link: " + orderCode);
        
        try {
            payOS.paymentRequests().cancel(orderCode, reason);
            System.out.println("✅ Payment link cancelled successfully!");
            
        } catch (Exception e) {
            System.err.println("❌ Failed to cancel payment link: " + e.getMessage());
            e.printStackTrace();
            throw e;
        }
    }
    
    /**
     * Get PayOS instance for advanced usage
     */
    public PayOS getPayOS() {
        return this.payOS;
    }
}
