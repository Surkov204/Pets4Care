package utils;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.text.Normalizer;
import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.util.Base64;
import java.util.Map;
import java.util.stream.Collectors;

public class PayOSUtils {
    
    /**
     * Tạo HTTP request đến PayOS API (dùng base URL mặc định từ config)
     */
    public static String makePayOSRequest(String endpoint, String method, String requestBody, Map<String, String> headers) throws IOException {
        String url = PayOSConfig.getBaseUrl() + endpoint;
        System.out.println("🔗 PayOS URL: " + url);
        System.out.println("📤 Request Method: " + method);
        System.out.println("📋 Request Body: " + requestBody);
        
        HttpURLConnection conn = null;
        try {
            conn = (HttpURLConnection) new URL(url).openConnection();
            
            // Set timeouts to avoid hanging indefinitely
            conn.setConnectTimeout(15000); // 15 seconds
            conn.setReadTimeout(15000); // 15 seconds
            
            conn.setRequestMethod(method);
            conn.setRequestProperty("Content-Type", "application/json");
            conn.setRequestProperty("x-client-id", PayOSConfig.getClientId());
            conn.setRequestProperty("x-api-key", PayOSConfig.getApiKey());
            
            System.out.println("🔑 x-client-id: " + PayOSConfig.getClientId());
            System.out.println("🔑 x-api-key: " + (PayOSConfig.getApiKey() != null ? PayOSConfig.getApiKey().substring(0, Math.min(10, PayOSConfig.getApiKey().length())) + "..." : "NULL"));
            
            // Thêm custom headers nếu có
            if (headers != null) {
                for (Map.Entry<String, String> entry : headers.entrySet()) {
                    conn.setRequestProperty(entry.getKey(), entry.getValue());
                }
            }
            
            if ("POST".equals(method) && requestBody != null) {
                conn.setDoOutput(true);
                try (OutputStream os = conn.getOutputStream()) {
                    byte[] input = requestBody.getBytes(StandardCharsets.UTF_8);
                    System.out.println("📤 Sending " + input.length + " bytes to PayOS");
                    os.write(input, 0, input.length);
                }
            }
            
            int responseCode = conn.getResponseCode();
            System.out.println("📥 PayOS Response Code: " + responseCode);
            
            StringBuilder response = new StringBuilder();
            
            try (BufferedReader br = new BufferedReader(new InputStreamReader(
                    responseCode >= 200 && responseCode < 300 ? conn.getInputStream() : conn.getErrorStream()))) {
                String line;
                while ((line = br.readLine()) != null) {
                    response.append(line);
                }
            }
            
            String responseBody = response.toString();
            System.out.println("📥 PayOS Response Body: " + responseBody);
            
            if (responseCode >= 200 && responseCode < 300) {
                System.out.println("✅ PayOS request successful");
                return responseBody;
            } else {
                System.err.println("❌ PayOS API Error: " + responseCode + " - " + responseBody);
                throw new IOException("PayOS API Error: " + responseCode + " - " + responseBody);
            }
        } catch (java.net.UnknownHostException e) {
            String errorMsg = "DNS Resolution Failed - Cannot resolve hostname: " + e.getMessage() + 
                             "\nPossible causes: No internet connection, DNS server issues, or incorrect domain name";
            System.err.println("❌ " + errorMsg);
            e.printStackTrace();
            throw new IOException(errorMsg, e);
        } catch (java.net.SocketTimeoutException e) {
            String errorMsg = "Connection Timeout - PayOS API did not respond within 15 seconds: " + e.getMessage();
            System.err.println("❌ " + errorMsg);
            e.printStackTrace();
            throw new IOException(errorMsg, e);
        } catch (java.net.ConnectException e) {
            String errorMsg = "Connection Refused - Cannot connect to PayOS API: " + e.getMessage() + 
                             "\nPossible causes: Firewall blocking, VPN issues, or PayOS API is down";
            System.err.println("❌ " + errorMsg);
            e.printStackTrace();
            throw new IOException(errorMsg, e);
        } catch (javax.net.ssl.SSLException e) {
            String errorMsg = "SSL/TLS Error - Certificate validation failed: " + e.getMessage();
            System.err.println("❌ " + errorMsg);
            e.printStackTrace();
            throw new IOException(errorMsg, e);
        } catch (IOException e) {
            String errorMsg = "I/O Error - " + e.getClass().getSimpleName() + ": " + e.getMessage();
            System.err.println("❌ " + errorMsg);
            e.printStackTrace();
            throw new IOException(errorMsg, e);
        } finally {
            if (conn != null) {
                conn.disconnect();
            }
        }
    }

    /**
     * Tạo HTTP request đến PayOS API với base URL truyền vào (dùng cho fallback domain)
     */
    public static String makePayOSRequestWithBase(String baseUrl, String endpoint, String method, String requestBody, Map<String, String> headers) throws IOException {
        String url = baseUrl + endpoint;
        System.out.println("🔗 PayOS URL (custom base): " + url);
        System.out.println("📤 Request Method: " + method);
        System.out.println("📋 Request Body: " + requestBody);

        HttpURLConnection conn = null;
        try {
            conn = (HttpURLConnection) new URL(url).openConnection();
            
            // Set timeouts
            conn.setConnectTimeout(15000);
            conn.setReadTimeout(15000);
            
            conn.setRequestMethod(method);
            conn.setRequestProperty("Content-Type", "application/json");
            conn.setRequestProperty("x-client-id", PayOSConfig.getClientId());
            conn.setRequestProperty("x-api-key", PayOSConfig.getApiKey());

            if (headers != null) {
                for (Map.Entry<String, String> entry : headers.entrySet()) {
                    conn.setRequestProperty(entry.getKey(), entry.getValue());
                }
            }

            if ("POST".equals(method) && requestBody != null) {
                conn.setDoOutput(true);
                try (OutputStream os = conn.getOutputStream()) {
                    byte[] input = requestBody.getBytes(StandardCharsets.UTF_8);
                    os.write(input, 0, input.length);
                }
            }

            int responseCode = conn.getResponseCode();
            StringBuilder response = new StringBuilder();
            try (BufferedReader br = new BufferedReader(new InputStreamReader(
                    responseCode >= 200 && responseCode < 300 ? conn.getInputStream() : conn.getErrorStream()))) {
                String line;
                while ((line = br.readLine()) != null) {
                    response.append(line);
                }
            }
            String responseBody = response.toString();
            if (responseCode >= 200 && responseCode < 300) {
                return responseBody;
            }
            throw new IOException("PayOS API Error: " + responseCode + " - " + responseBody);
        } catch (java.net.UnknownHostException e) {
            String errorMsg = "DNS Resolution Failed - Cannot resolve hostname: " + e.getMessage();
            System.err.println("❌ " + errorMsg);
            throw new IOException(errorMsg, e);
        } catch (java.net.SocketTimeoutException e) {
            String errorMsg = "Connection Timeout: " + e.getMessage();
            System.err.println("❌ " + errorMsg);
            throw new IOException(errorMsg, e);
        } catch (java.net.ConnectException e) {
            String errorMsg = "Connection Refused: " + e.getMessage();
            System.err.println("❌ " + errorMsg);
            throw new IOException(errorMsg, e);
        } catch (javax.net.ssl.SSLException e) {
            String errorMsg = "SSL/TLS Error: " + e.getMessage();
            System.err.println("❌ " + errorMsg);
            throw new IOException(errorMsg, e);
        } finally {
            if (conn != null) {
                conn.disconnect();
            }
        }
    }
    
    /**
     * Tạo checksum cho PayOS sử dụng HMAC-SHA256
     * PayOS yêu cầu ký theo format: amount|orderCode|returnUrl|cancelUrl|description
     */
   /**
 * ✅ Tạo checksum (signature) theo chuẩn PayOS API v2.2
 * - Dữ liệu ký là JSON (các key sắp xếp theo alphabet)
 * - Sau đó Base64 encode JSON string
 * - Cuối cùng ký HMAC-SHA256 bằng checksum key
 */
public static String generateChecksum(String amount, String orderCode, String returnUrl, String cancelUrl, String description) {
    try {
        System.out.println("🔐 ===== GENERATING CHECKSUM =====");
        System.out.println("📝 Input parameters:");
        System.out.println("   amount: " + amount);
        System.out.println("   orderCode: " + orderCode);
        System.out.println("   returnUrl: " + returnUrl);
        System.out.println("   cancelUrl: " + cancelUrl);
        System.out.println("   description: " + description);
        
        String checksumKey = PayOSConfig.getChecksumKey();
        System.out.println("🔑 Checksum Key: " + (checksumKey != null ? checksumKey.substring(0, Math.min(10, checksumKey.length())) + "..." : "NULL"));

        // 1️⃣ Tạo signature theo format PayOS: key1=value1&key2=value2... (sắp xếp theo alphabet)
        java.util.TreeMap<String, String> sortedMap = new java.util.TreeMap<>();
        sortedMap.put("amount", amount);
        sortedMap.put("cancelUrl", cancelUrl);
        sortedMap.put("description", description);
        sortedMap.put("orderCode", orderCode);
        sortedMap.put("returnUrl", returnUrl);

        System.out.println("📋 Sorted Map: " + sortedMap);

        // Tạo string theo format key=value&key=value
        StringBuilder signatureData = new StringBuilder();
        boolean first = true;
        for (java.util.Map.Entry<String, String> entry : sortedMap.entrySet()) {
            if (!first) {
                signatureData.append('&');
            }
            signatureData.append(entry.getKey()).append('=').append(entry.getValue());
            first = false;
        }
        
        System.out.println("📋 Signature Data: " + signatureData.toString());
        System.out.println("📏 Signature Data length: " + signatureData.length() + " characters");

        // 2️⃣ Ký HMAC-SHA256 trên signature data
        javax.crypto.Mac mac = javax.crypto.Mac.getInstance("HmacSHA256");
        javax.crypto.spec.SecretKeySpec secretKeySpec =
                new javax.crypto.spec.SecretKeySpec(checksumKey.getBytes(java.nio.charset.StandardCharsets.UTF_8), "HmacSHA256");
        mac.init(secretKeySpec);

        byte[] hash = mac.doFinal(signatureData.toString().getBytes(java.nio.charset.StandardCharsets.UTF_8));
        System.out.println("🔐 HMAC hash bytes: " + java.util.Arrays.toString(hash));

        // 3️⃣ Convert sang HEX (theo tài liệu PayOS)
        StringBuilder hexString = new StringBuilder();
        for (byte b : hash) {
            String hex = Integer.toHexString(0xff & b);
            if (hex.length() == 1) hexString.append('0');
            hexString.append(hex);
        }
        String signature = hexString.toString();
        System.out.println("✅ Generated HMAC-SHA256 signature (HEX): " + signature);
        System.out.println("📏 Signature length: " + signature.length() + " characters");
        System.out.println("🔐 ===== CHECKSUM GENERATION COMPLETE =====");
        
        // Debug: Log all steps for verification
        System.out.println("🔍 DEBUG SIGNATURE GENERATION:");
        System.out.println("   1. Signature Data: " + signatureData);
        System.out.println("   2. Checksum Key: " + (checksumKey != null ? checksumKey.substring(0, Math.min(20, checksumKey.length())) + "..." : "NULL"));
        System.out.println("   3. Final Signature: " + signature);
        
        return signature;

    } catch (Exception e) {
        System.err.println("❌ ERROR generating checksum: " + e.getMessage());
        e.printStackTrace();
        return null;
    }
}

    
    /**
     * Xác thực webhook signature từ PayOS
     * Theo tài liệu PayOS: https://payos.vn/docs/tich-hop-webhook/kiem-tra-du-lieu-voi-signature
     * 
     * Cách tính signature:
     * 1. Lấy data object từ webhook (không bao gồm signature field)
     * 2. Sắp xếp keys theo alphabet
     * 3. Tạo query string: key1=value1&key2=value2&...
     * 4. HMAC-SHA256 với checksum key
     * 5. Convert sang hex string
     * 
     * @param webhookBody Raw webhook JSON string từ PayOS
     * @param signatureHeader Signature từ header x-payos-signature (có thể null)
     * @return true nếu signature hợp lệ
     */
    public static boolean verifyWebhookSignature(String webhookBody, String signatureHeader) {
        try {
            System.out.println("🔐 ===== VERIFYING WEBHOOK SIGNATURE =====");
            System.out.println("📝 Webhook body: " + webhookBody);
            System.out.println("🔑 Signature from header: " + signatureHeader);
            
            if (webhookBody == null || webhookBody.trim().isEmpty()) {
                System.err.println("❌ Empty webhook body");
                return false;
            }
            
            // Parse JSON để lấy signature và data
            JsonObject webhookJson = JsonParser.parseString(webhookBody).getAsJsonObject();
            
            // Extract signature từ JSON body hoặc header
            String signature = signatureHeader;
            if ((signature == null || signature.isEmpty()) && webhookJson.has("signature")) {
                signature = webhookJson.get("signature").getAsString();
                System.out.println("📋 Using signature from JSON body");
            }
            
            if (signature == null || signature.trim().isEmpty()) {
                System.err.println("❌ No signature found (neither in header nor JSON body)");
                return false;
            }
            
            // Lấy data object (không bao gồm signature, code, desc, success ở top level)
            if (!webhookJson.has("data")) {
                System.err.println("❌ No 'data' field in webhook");
                return false;
            }
            
            JsonObject dataObject = webhookJson.getAsJsonObject("data");
            
            String checksumKey = PayOSConfig.getChecksumKey();
            if (checksumKey == null || checksumKey.trim().isEmpty()) {
                System.err.println("❌ Checksum key not configured");
                return false;
            }
            
            System.out.println("🔑 Using checksum key: " + (checksumKey.length() > 10 ? checksumKey.substring(0, 10) + "..." : checksumKey));
            System.out.println("📦 Data object: " + dataObject.toString());
            
            // Bước 1: Sắp xếp keys theo alphabet
            java.util.TreeMap<String, String> sortedMap = new java.util.TreeMap<>();
            for (java.util.Map.Entry<String, com.google.gson.JsonElement> entry : dataObject.entrySet()) {
                String key = entry.getKey();
                com.google.gson.JsonElement value = entry.getValue();
                
                // Convert value to string (xử lý các loại JSON element)
                String valueStr;
                if (value.isJsonPrimitive()) {
                    valueStr = value.getAsString();
                } else if (value.isJsonNull()) {
                    valueStr = "";
                } else {
                    // Đối với object/array, convert sang JSON string
                    valueStr = value.toString();
                }
                sortedMap.put(key, valueStr);
            }
            
            // Bước 2: Tạo query string: key1=value1&key2=value2&...
            StringBuilder signatureData = new StringBuilder();
            boolean first = true;
            for (java.util.Map.Entry<String, String> entry : sortedMap.entrySet()) {
                if (!first) {
                    signatureData.append('&');
                }
                signatureData.append(entry.getKey()).append('=').append(entry.getValue());
                first = false;
            }
            
            System.out.println("📋 Signature data string: " + signatureData.toString());
            
            // Bước 3: HMAC-SHA256 với checksum key
            javax.crypto.Mac mac = javax.crypto.Mac.getInstance("HmacSHA256");
            javax.crypto.spec.SecretKeySpec secretKeySpec = 
                new javax.crypto.spec.SecretKeySpec(checksumKey.getBytes(java.nio.charset.StandardCharsets.UTF_8), "HmacSHA256");
            mac.init(secretKeySpec);
            
            byte[] hash = mac.doFinal(signatureData.toString().getBytes(java.nio.charset.StandardCharsets.UTF_8));
            
            // Bước 4: Convert sang hex string
            StringBuilder hexString = new StringBuilder();
            for (byte b : hash) {
                String hex = Integer.toHexString(0xff & b);
                if (hex.length() == 1) hexString.append('0');
                hexString.append(hex);
            }
            
            String calculatedSignature = hexString.toString();
            System.out.println("🔐 Calculated signature: " + calculatedSignature);
            System.out.println("🔐 PayOS signature: " + signature);
            
            // Bước 5: So sánh (case-insensitive để tránh lỗi)
            boolean isValid = calculatedSignature.equalsIgnoreCase(signature);
            System.out.println("✅ Signature verification result: " + isValid);
            System.out.println("🔐 ===== WEBHOOK SIGNATURE VERIFICATION COMPLETE =====");
            
            return isValid;
            
        } catch (Exception e) {
            System.err.println("❌ ERROR verifying webhook signature: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Parse JSON response từ PayOS
     */
    public static JsonObject parsePayOSResponse(String response) {
        try {
            return JsonParser.parseString(response).getAsJsonObject();
        } catch (Exception e) {
            e.printStackTrace();
            return new JsonObject();
        }
    }
    
    /**
     * Tạo payment request data
     */
    public static JsonObject createPaymentRequest(int orderId, double amount, String description, String returnUrl, String cancelUrl) {
        try {
            System.out.println("🚀 ===== CREATING PAYMENT REQUEST =====");
            System.out.println("📋 Input parameters:");
            System.out.println("   orderId: " + orderId);
            System.out.println("   amount: " + amount);
            System.out.println("   description: " + description);
            System.out.println("   returnUrl: " + returnUrl);
            System.out.println("   cancelUrl: " + cancelUrl);
            
            // PayOS v2 expects amount in VND (use actual amount directly)
            // E.g., amount = 100000 (actual price) → amountInVND = 100000 (VND)
            int amountInVND = (int)Math.round(amount);
            
            System.out.println("💰 Amount conversion: " + amount + " → " + amountInVND + " VND");
            
            // Configure Gson to NOT escape characters (disable HTML escaping)
            // Without this, Gson escapes = as \u003d, causing signature mismatch
            Gson gson = new GsonBuilder().disableHtmlEscaping().create();
            
            // Generate checksum using PayOS format: amount|orderCode|returnUrl|cancelUrl|description
            // IMPORTANT: Normalize description to remove accents (PayOS requirement)
            System.out.println("🧹 Normalizing description...");
            System.out.println("   Original: " + description);
            String cleanDescription = normalizeDescription(description);
            System.out.println("   Normalized: " + cleanDescription);
            
            // Create the data object for signing with EXACT key order required by PayOS v2
            // Order: amount, cancelUrl, description, items, orderCode, returnUrl
            // CRITICAL: Use cleanDescription (normalized) for both signing and sending to PayOS
            System.out.println("📝 Creating JSON object for signing...");
            JsonObject dataToSign = new JsonObject();
            dataToSign.addProperty("amount", amountInVND);
            dataToSign.addProperty("cancelUrl", cancelUrl);
            dataToSign.addProperty("description", cleanDescription);
            dataToSign.add("items", new JsonArray());
            dataToSign.addProperty("orderCode", orderId);
            dataToSign.addProperty("returnUrl", returnUrl);
            
            System.out.println("📋 JSON object before sorting: " + dataToSign.toString());
            
            String amountStr = String.valueOf(amountInVND);
            String orderCodeStr = String.valueOf(orderId);
            
            System.out.println("🔐 Generating checksum with parameters:");
            System.out.println("   amountStr: " + amountStr);
            System.out.println("   orderCodeStr: " + orderCodeStr);
            System.out.println("   returnUrl: " + returnUrl);
            System.out.println("   cancelUrl: " + cancelUrl);
            System.out.println("   cleanDescription: " + cleanDescription);
            
            String checksum = generateChecksum(
                amountStr,
                orderCodeStr,
                returnUrl,
                cancelUrl,
                cleanDescription
            );
            
            if (checksum == null) {
                System.err.println("❌ ERROR: Failed to generate checksum");
                return new JsonObject();
            }
            
            System.out.println("✅ Checksum generated successfully: " + checksum);
            
            // Sort keys alphabetically for final JSON
            System.out.println("🔄 Sorting JSON keys alphabetically...");
            JsonObject sortedData = sortJsonByKey(dataToSign);
            System.out.println("📋 JSON object after sorting: " + sortedData.toString());
            
            // Add signature to the sorted object (must be last field)
            sortedData.addProperty("signature", checksum);
            
            System.out.println("📤 Final JSON with signature: " + sortedData.toString());
            System.out.println("🚀 ===== PAYMENT REQUEST CREATION COMPLETE =====");
            
            return sortedData;
            
        } catch (Exception e) {
            System.out.println("ERROR creating payment request: " + e.getMessage());
            e.printStackTrace();
            return new JsonObject();
        }
    }
    
    /**
     * Kiểm tra cấu hình PayOS
     */
    public static boolean isPayOSConfigured() {
        return PayOSConfig.isConfigured();
    }
    
    /**
     * Log PayOS request/response
     */
    public static void logPayOSRequest(String endpoint, String method, String requestBody) {
        System.out.println("====== PAYOS REQUEST ======");
        System.out.println("Endpoint: " + endpoint);
        System.out.println("Method: " + method);
        System.out.println("Request Body: " + requestBody);
        System.out.println("============================");
    }
    
    public static void logPayOSResponse(String response) {
        System.out.println("====== PAYOS RESPONSE ======");
        System.out.println("Response: " + response);
        System.out.println("============================");
    }
    
    /**
     * Sort JSON keys alphabetically (PayOS v2.1 requirement)
     * This ensures canonical JSON format for signature calculation
     */
    private static JsonObject sortJsonByKey(JsonObject input) {
        JsonObject sorted = new JsonObject();
        input.entrySet().stream()
             .sorted(Map.Entry.comparingByKey())
             .forEach(entry -> sorted.add(entry.getKey(), entry.getValue()));
        return sorted;
    }
    
    /**
     * Normalize Vietnamese text by removing accents and special characters
     * PayOS requires this for signature calculation to match their backend
     */
    public static String normalizeDescription(String text) {
        System.out.println("🧹 ===== NORMALIZING DESCRIPTION =====");
        System.out.println("📝 Input text: " + text);
        
        if (text == null || text.isEmpty()) {
            System.out.println("⚠️ Input text is null or empty, returning empty string");
            return "";
        }
        
        // Step 1: Replace special Vietnamese letters before stripping diacritics
        // This prevents đ/Đ from being completely removed during normalization
        String step1 = text.replace('đ', 'd').replace('Đ', 'D');
        System.out.println("🔄 Step 1 (đ→d, Đ→D): " + step1);
        
        // Step 2: Normalize NFD (decomposed form) to separate base characters and combining marks
        String step2 = Normalizer.normalize(step1, Normalizer.Form.NFD);
        System.out.println("🔄 Step 2 (NFD normalize): " + step2);
        
        // Step 3: Remove all combining diacritical marks (Vietnamese accents)
        String step3 = step2.replaceAll("\\p{InCombiningDiacriticalMarks}+", "");
        System.out.println("🔄 Step 3 (remove accents): " + step3);
        
        // Step 4: Keep only letters, numbers, spaces, and #
        String step4 = step3.replaceAll("[^a-zA-Z0-9 #]", "");
        System.out.println("🔄 Step 4 (keep alphanumeric + space + #): " + step4);
        
        // Step 5: Trim whitespace
        String finalResult = step4.trim();
        System.out.println("✅ Final normalized result: " + finalResult);
        System.out.println("🧹 ===== DESCRIPTION NORMALIZATION COMPLETE =====");
        
        return finalResult;
    }
    
    /**
     * Diagnostic utility to test connectivity to PayOS API
     * This helps identify if the issue is DNS, firewall, SSL, or API-related
     */
    public static void diagnosePayOSConnectivity() {
        System.out.println("\n🔧 ===== PAYOS CONNECTIVITY DIAGNOSTIC =====");
        
        String hostname = "api.payos.vn";
        String baseUrl = PayOSConfig.getBaseUrl();
        
        // Test 1: DNS Resolution
        System.out.println("\n1️⃣ Testing DNS Resolution for " + hostname + "...");
        try {
            java.net.InetAddress address = java.net.InetAddress.getByName(hostname);
            System.out.println("   ✅ DNS Resolution successful");
            System.out.println("   📍 IP Address: " + address.getHostAddress());
        } catch (java.net.UnknownHostException e) {
            System.err.println("   ❌ DNS Resolution FAILED: " + e.getMessage());
            System.err.println("   💡 Possible causes:");
            System.err.println("      - No internet connection");
            System.err.println("      - DNS server issues");
            System.err.println("      - Firewall blocking DNS queries");
            return; // Can't continue if DNS fails
        }
        
        // Test 2: TCP Connection
        System.out.println("\n2️⃣ Testing TCP connection to " + hostname + ":443...");
        try {
            java.net.Socket socket = new java.net.Socket();
            socket.connect(new java.net.InetSocketAddress(hostname, 443), 10000);
            System.out.println("   ✅ TCP Connection successful");
            socket.close();
        } catch (Exception e) {
            System.err.println("   ❌ TCP Connection FAILED: " + e.getMessage());
            System.err.println("   💡 Possible causes:");
            System.err.println("      - Firewall blocking HTTPS traffic");
            System.err.println("      - VPN/Proxy issues");
            System.err.println("      - PayOS API is down");
            return;
        }
        
        // Test 3: HTTPS Connection
        System.out.println("\n3️⃣ Testing HTTPS connection to " + baseUrl + "...");
        try {
            java.net.URL url = new java.net.URL(baseUrl);
            javax.net.ssl.HttpsURLConnection conn = (javax.net.ssl.HttpsURLConnection) url.openConnection();
            conn.setConnectTimeout(10000);
            conn.setReadTimeout(10000);
            conn.setRequestMethod("GET");
            
            int responseCode = conn.getResponseCode();
            System.out.println("   ✅ HTTPS Connection successful");
            System.out.println("   📡 Response Code: " + responseCode);
            conn.disconnect();
        } catch (javax.net.ssl.SSLException e) {
            System.err.println("   ❌ SSL/TLS FAILED: " + e.getMessage());
            System.err.println("   💡 Possible causes:");
            System.err.println("      - SSL certificate validation failed");
            System.err.println("      - Outdated Java version");
            System.err.println("      - Corporate SSL inspection");
            return;
        } catch (Exception e) {
            System.err.println("   ❌ HTTPS Connection FAILED: " + e.getMessage());
            e.printStackTrace();
            return;
        }
        
        // Test 4: PayOS API Endpoint
        System.out.println("\n4️⃣ Testing PayOS API authentication...");
        try {
            String testUrl = baseUrl + "/v2/payment-requests";
            java.net.HttpURLConnection conn = (java.net.HttpURLConnection) new java.net.URL(testUrl).openConnection();
            conn.setConnectTimeout(10000);
            conn.setReadTimeout(10000);
            conn.setRequestMethod("POST");
            conn.setRequestProperty("Content-Type", "application/json");
            conn.setRequestProperty("x-client-id", PayOSConfig.getClientId());
            conn.setRequestProperty("x-api-key", PayOSConfig.getApiKey());
            
            // Send empty body (will fail but shows if auth works)
            conn.setDoOutput(true);
            conn.getOutputStream().write("{}".getBytes());
            
            int responseCode = conn.getResponseCode();
            BufferedReader br = new BufferedReader(new InputStreamReader(
                responseCode >= 200 && responseCode < 300 ? conn.getInputStream() : conn.getErrorStream()));
            StringBuilder response = new StringBuilder();
            String line;
            while ((line = br.readLine()) != null) {
                response.append(line);
            }
            br.close();
            
            System.out.println("   📡 Response Code: " + responseCode);
            System.out.println("   📥 Response Body: " + response.toString());
            
            if (responseCode == 401 || responseCode == 403) {
                System.err.println("   ❌ Authentication FAILED");
                System.err.println("   💡 Check your Client ID and API Key in payos.properties");
            } else if (responseCode >= 200 && responseCode < 500) {
                System.out.println("   ✅ PayOS API is reachable and responding");
            }
            
            conn.disconnect();
        } catch (Exception e) {
            System.err.println("   ❌ PayOS API Test FAILED: " + e.getMessage());
            e.printStackTrace();
        }
        
        System.out.println("\n🔧 ===== DIAGNOSTIC COMPLETE =====\n");
    }
}
