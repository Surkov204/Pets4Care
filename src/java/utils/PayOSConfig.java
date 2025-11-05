package utils;

import java.util.Properties;

public class PayOSConfig {
    
    private static Properties properties;
    public static final String BASE_URL_PRIMARY = "https://api.payos.vn/v2";
    public static final String BASE_URL_FALLBACK = "https://api-merchant.payos.vn/v2";
    public static final String REFUND_ENDPOINT_DEFAULT = "/payment-requests/refund"; // có thể được PayOS thay đổi theo merchant
    
    static {
        loadConfig();
    }
    
    private static void loadConfig() {
        properties = new Properties();
        
           // HARDCODE PAYOS CONFIG - CREDENTIALS MỚI
           System.out.println("⚠️ Using HARDCODED PayOS config values - NEW CREDENTIALS");
           properties.setProperty("payos.client.id", "aa93b610-c20b-4ffa-8c08-d006e01df689");
           properties.setProperty("payos.api.key", "0d00713c-3627-4033-a87e-ba646b371a95");
           properties.setProperty("payos.checksum.key", "d94677a139bd68e80dc67adf1fd3945db9c43679928823bfdf72f86d70d4ffd2");
           properties.setProperty("payos.base.url", BASE_URL_PRIMARY);
           properties.setProperty("payos.webhook.url", "https://webhook.site/b15f91fa-1b0f-423a-90cf-35c6c0426fe0");
           // Endpoint refund có thể thay đổi theo tài liệu/phiên bản
           properties.setProperty("payos.refund.endpoint", REFUND_ENDPOINT_DEFAULT);
        logConfigLoaded();
        return;
    }
    
    private static void logConfigLoaded() {
        System.out.println("✅ PayOS config loaded successfully");
        System.out.println("  - Client ID: " + properties.getProperty("payos.client.id"));
        System.out.println("  - API Key: " + (properties.getProperty("payos.api.key") != null ? "[SET]" : "[NULL]"));
        System.out.println("  - Checksum Key: " + (properties.getProperty("payos.checksum.key") != null ? "[SET]" : "[NULL]"));
        System.out.println("  - Base URL: " + properties.getProperty("payos.base.url"));
        System.out.println("  - Refund Endpoint: " + properties.getProperty("payos.refund.endpoint"));
    }
    
    public static String getClientId() {
        return properties.getProperty("payos.client.id");
    }
    
    public static String getApiKey() {
        return properties.getProperty("payos.api.key");
    }
    
    public static String getChecksumKey() {
        return properties.getProperty("payos.checksum.key");
    }
    
    public static String getBaseUrl() {
        return properties.getProperty("payos.base.url");
    }
    
    public static String getWebhookUrl() {
        return properties.getProperty("payos.webhook.url");
    }

    public static String getRefundEndpoint() {
        return properties.getProperty("payos.refund.endpoint", REFUND_ENDPOINT_DEFAULT);
    }
    
    public static boolean isConfigured() {
        String clientId = getClientId();
        String apiKey = getApiKey();
        String checksumKey = getChecksumKey();
        
        boolean configured = !"your_client_id".equals(clientId) && 
                           !"your_api_key".equals(apiKey) && 
                           !"your_checksum_key".equals(checksumKey);
        
        System.out.println("🔍 PayOS Configuration Check:");
        System.out.println("  - Client ID: " + clientId);
        System.out.println("  - API Key: " + (apiKey != null && !apiKey.equals("your_api_key") ? "[CONFIGURED]" : "[NOT CONFIGURED]"));
        System.out.println("  - Checksum Key: " + (checksumKey != null && !checksumKey.equals("your_checksum_key") ? "[CONFIGURED]" : "[NOT CONFIGURED]"));
        System.out.println("  - Is Configured: " + configured);
        
        return configured;
    }
}
