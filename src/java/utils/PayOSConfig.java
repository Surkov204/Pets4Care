package utils;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;

public class PayOSConfig {
    
    private static final String CONFIG_FILE = "payos.properties";
    private static Properties properties;
    
    static {
        loadConfig();
    }
    
    private static void loadConfig() {
        properties = new Properties();
        InputStream input = null;
        
        // Try multiple locations for the config file
        
        // 1. Try from classpath (for JAR/WAR deployment)
        input = PayOSConfig.class.getClassLoader().getResourceAsStream(CONFIG_FILE);
        if (input != null) {
            try {
                System.out.println("✅ Loading PayOS config from classpath: " + CONFIG_FILE);
                properties.load(input);
                input.close();
                logConfigLoaded();
                return;
            } catch (IOException e) {
                System.err.println("⚠️ Failed to load from classpath, trying fallback locations...");
            }
        }
        
        // 2. Try from WEB-INF/classes (for exploded WAR in NetBeans)
        try {
            String webInfPath = System.getProperty("user.dir") + File.separator + "web" + File.separator + "WEB-INF" + File.separator + "classes" + File.separator + CONFIG_FILE;
            File webInfFile = new File(webInfPath);
            if (webInfFile.exists()) {
                System.out.println("✅ Loading PayOS config from: " + webInfPath);
                try (FileInputStream fis = new FileInputStream(webInfFile)) {
                    properties.load(fis);
                    logConfigLoaded();
                    return;
                }
            }
        } catch (Exception e) {
            System.err.println("⚠️ Failed to load from WEB-INF/classes: " + e.getMessage());
        }
        
        // 3. Try from src/main/resources
        try {
            String srcPath = System.getProperty("user.dir") + File.separator + "src" + File.separator + "main" + File.separator + "resources" + File.separator + CONFIG_FILE;
            File srcFile = new File(srcPath);
            if (srcFile.exists()) {
                System.out.println("✅ Loading PayOS config from: " + srcPath);
                try (FileInputStream fis = new FileInputStream(srcFile)) {
                    properties.load(fis);
                    logConfigLoaded();
                    return;
                }
            }
        } catch (Exception e) {
            System.err.println("⚠️ Failed to load from src/main/resources: " + e.getMessage());
        }
        
        // 4. Try from src root (for NetBeans)
        try {
            String srcRootPath = System.getProperty("user.dir") + File.separator + "src" + File.separator + CONFIG_FILE;
            File srcRootFile = new File(srcRootPath);
            if (srcRootFile.exists()) {
                System.out.println("✅ Loading PayOS config from: " + srcRootPath);
                try (FileInputStream fis = new FileInputStream(srcRootFile)) {
                    properties.load(fis);
                    logConfigLoaded();
                    return;
                }
            }
        } catch (Exception e) {
            System.err.println("⚠️ Failed to load from src root: " + e.getMessage());
        }
        
        // If all attempts failed, use default values
        System.err.println("❌ PayOS config file not found in any location");
        System.err.println("❌ Using default values");
        setDefaultValues();
    }
    
    private static void logConfigLoaded() {
        System.out.println("✅ PayOS config loaded successfully");
        System.out.println("  - Client ID: " + properties.getProperty("payos.client.id"));
        System.out.println("  - API Key: " + (properties.getProperty("payos.api.key") != null ? "[SET]" : "[NULL]"));
        System.out.println("  - Checksum Key: " + (properties.getProperty("payos.checksum.key") != null ? "[SET]" : "[NULL]"));
    }
    
    private static void setDefaultValues() {
        properties.setProperty("payos.client.id", "your_client_id");
        properties.setProperty("payos.api.key", "your_api_key");
        properties.setProperty("payos.checksum.key", "your_checksum_key");
        properties.setProperty("payos.base.url", "https://api-merchant.payos.vn/v2");
        properties.setProperty("payos.webhook.url", "https://your-domain.com/payos/webhook");
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
