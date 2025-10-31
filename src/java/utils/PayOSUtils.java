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
     * Tạo HTTP request đến PayOS API
     */
    public static String makePayOSRequest(String endpoint, String method, String requestBody, Map<String, String> headers) throws IOException {
        String url = PayOSConfig.getBaseUrl() + endpoint;
        System.out.println("🔗 PayOS URL: " + url);
        System.out.println("📤 Request Method: " + method);
        System.out.println("📋 Request Body: " + requestBody);
        
        HttpURLConnection conn = (HttpURLConnection) new URL(url).openConnection();
        
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

        // 1️⃣ Tạo JSON theo thứ tự alphabet bắt buộc
        java.util.LinkedHashMap<String, Object> sortedMap = new java.util.LinkedHashMap<>();
        sortedMap.put("amount", Integer.parseInt(amount));
        sortedMap.put("cancelUrl", cancelUrl);
        sortedMap.put("description", description);
        sortedMap.put("items", new com.google.gson.JsonArray());
        sortedMap.put("orderCode", Integer.parseInt(orderCode));
        sortedMap.put("returnUrl", returnUrl);

        System.out.println("📋 Sorted Map: " + sortedMap);

        com.google.gson.Gson gson = new com.google.gson.GsonBuilder().disableHtmlEscaping().create();
        String jsonString = gson.toJson(sortedMap).trim();

        System.out.println("🔍 JSON to sign (raw): " + jsonString);
        System.out.println("📏 JSON length: " + jsonString.length() + " characters");
        System.out.println("🔤 JSON bytes: " + java.util.Arrays.toString(jsonString.getBytes(java.nio.charset.StandardCharsets.UTF_8)));

        // 2️⃣ Base64 encode JSON string (PayOS v2.2 requirement)
        String base64Data = java.util.Base64.getEncoder().encodeToString(jsonString.getBytes(java.nio.charset.StandardCharsets.UTF_8));
        System.out.println("🔐 Base64 encoded JSON: " + base64Data);
        System.out.println("📏 Base64 length: " + base64Data.length() + " characters");

        // 3️⃣ Ký HMAC-SHA256 trên Base64(JSON) - PayOS v2.2 standard
        javax.crypto.Mac mac = javax.crypto.Mac.getInstance("HmacSHA256");
        javax.crypto.spec.SecretKeySpec secretKeySpec =
                new javax.crypto.spec.SecretKeySpec(checksumKey.getBytes(java.nio.charset.StandardCharsets.UTF_8), "HmacSHA256");
        mac.init(secretKeySpec);

        byte[] hash = mac.doFinal(base64Data.getBytes(java.nio.charset.StandardCharsets.UTF_8));
        System.out.println("🔐 HMAC hash bytes: " + java.util.Arrays.toString(hash));

        // 4️⃣ Convert sang HEX
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
        return signature;

    } catch (Exception e) {
        System.err.println("❌ ERROR generating checksum: " + e.getMessage());
        e.printStackTrace();
        return null;
    }
}

    
    /**
     * Xác thực webhook signature cho payment-requests
     * Sử dụng thuật toán HMAC_SHA256 với data dạng key1=value1&key2=value2...
     * Dữ liệu sắp xếp theo key thứ tự alphabet
     * Theo tài liệu PayOS: https://payos.vn/docs/webhook
     */
    public static boolean verifyPaymentRequestSignature(JsonObject webhookData, String expectedSignature) {
        try {
            System.out.println("🔐 ===== VERIFYING PAYMENT REQUEST SIGNATURE =====");
            
            if (!webhookData.has("data")) {
                System.err.println("❌ Webhook data missing 'data' field");
                return false;
            }
            
            // Extract signature from webhook data if not provided
            String actualSignature = expectedSignature;
            if ((actualSignature == null || actualSignature.isEmpty()) && webhookData.has("signature")) {
                actualSignature = webhookData.get("signature").getAsString();
            }
            
            if (actualSignature == null || actualSignature.isEmpty()) {
                System.err.println("❌ Webhook signature is missing");
                return false;
            }
            
            JsonObject data = webhookData.getAsJsonObject("data");
            String checksumKey = PayOSConfig.getChecksumKey();
            
            if (checksumKey == null || checksumKey.isEmpty()) {
                System.err.println("❌ Checksum key is not configured");
                return false;
            }
            
            System.out.println("📋 Webhook data: " + data.toString());
            System.out.println("🔑 Expected signature: " + actualSignature);
            
            // Tạo signature từ data object theo chuẩn PayOS
            String computedSignature = generatePaymentRequestSignature(data, checksumKey);
            System.out.println("🔐 Computed signature: " + computedSignature);
            
            boolean isValid = computedSignature != null && computedSignature.equalsIgnoreCase(actualSignature);
            System.out.println("✅ Signature verification result: " + isValid);
            
            if (!isValid) {
                System.err.println("❌ Signature mismatch!");
                System.err.println("   Expected: " + actualSignature);
                System.err.println("   Computed: " + computedSignature);
            }
            
            System.out.println("🔐 ===== PAYMENT REQUEST SIGNATURE VERIFICATION COMPLETE =====");
            
            return isValid;
            
        } catch (Exception e) {
            System.err.println("❌ ERROR verifying payment request signature: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Tạo signature cho payment-requests webhook data
     * Theo tài liệu PayOS: data tạo signature dạng key1=value1&key2=value2...
     * Dữ liệu sắp xếp theo key thứ tự alphabet
     */
    private static String generatePaymentRequestSignature(JsonObject data, String checksumKey) {
        try {
            System.out.println("🔐 ===== GENERATING PAYMENT REQUEST SIGNATURE =====");
            System.out.println("📋 Input data: " + data.toString());
            
            // Sắp xếp keys theo alphabet
            java.util.TreeMap<String, Object> sortedMap = new java.util.TreeMap<>();
            
            for (Map.Entry<String, com.google.gson.JsonElement> entry : data.entrySet()) {
                String key = entry.getKey();
                com.google.gson.JsonElement value = entry.getValue();
                
                Object valueObj;
                if (value.isJsonNull()) {
                    valueObj = "";
                } else if (value.isJsonArray()) {
                    // Xử lý array - sắp xếp các object trong array
                    com.google.gson.JsonArray array = value.getAsJsonArray();
                    java.util.List<Object> sortedArray = new java.util.ArrayList<>();
                    for (com.google.gson.JsonElement element : array) {
                        if (element.isJsonObject()) {
                            java.util.TreeMap<String, Object> sortedElement = new java.util.TreeMap<>();
                            for (Map.Entry<String, com.google.gson.JsonElement> elemEntry : element.getAsJsonObject().entrySet()) {
                                sortedElement.put(elemEntry.getKey(), getValueFromJsonElement(elemEntry.getValue()));
                            }
                            sortedArray.add(sortedElement);
                        } else {
                            sortedArray.add(getValueFromJsonElement(element));
                        }
                    }
                    valueObj = sortedArray;
                } else if (value.isJsonObject()) {
                    // Xử lý nested object - sắp xếp keys
                    java.util.TreeMap<String, Object> sortedNested = new java.util.TreeMap<>();
                    for (Map.Entry<String, com.google.gson.JsonElement> nestedEntry : value.getAsJsonObject().entrySet()) {
                        sortedNested.put(nestedEntry.getKey(), getValueFromJsonElement(nestedEntry.getValue()));
                    }
                    valueObj = sortedNested;
                } else {
                    valueObj = getValueFromJsonElement(value);
                }
                
                sortedMap.put(key, valueObj);
            }
            
            System.out.println("📋 Sorted map: " + sortedMap);
            
            // Tạo query string dạng key1=value1&key2=value2...
            java.util.List<String> queryParts = new java.util.ArrayList<>();
            for (Map.Entry<String, Object> entry : sortedMap.entrySet()) {
                String key = entry.getKey();
                Object value = entry.getValue();
                
                String valueStr;
                if (value == null || "null".equals(String.valueOf(value)) || "undefined".equals(String.valueOf(value))) {
                    valueStr = "";
                } else if (value instanceof java.util.List || value instanceof java.util.Map) {
                    // Convert to JSON string for arrays and objects
                    Gson gson = new GsonBuilder().disableHtmlEscaping().create();
                    valueStr = gson.toJson(value);
                } else {
                    valueStr = String.valueOf(value);
                }
                
                queryParts.add(key + "=" + valueStr);
            }
            
            String queryString = String.join("&", queryParts);
            System.out.println("📝 Query string for signature: " + queryString);
            
            // Tạo HMAC-SHA256 signature
            Mac mac = Mac.getInstance("HmacSHA256");
            SecretKeySpec secretKeySpec = new SecretKeySpec(checksumKey.getBytes(StandardCharsets.UTF_8), "HmacSHA256");
            mac.init(secretKeySpec);
            
            byte[] hash = mac.doFinal(queryString.getBytes(StandardCharsets.UTF_8));
            
            // Convert to hex
            StringBuilder hexString = new StringBuilder();
            for (byte b : hash) {
                String hex = Integer.toHexString(0xff & b);
                if (hex.length() == 1) hexString.append('0');
                hexString.append(hex);
            }
            
            String signature = hexString.toString();
            System.out.println("✅ Generated signature: " + signature);
            System.out.println("🔐 ===== PAYMENT REQUEST SIGNATURE GENERATION COMPLETE =====");
            
            return signature;
            
        } catch (Exception e) {
            System.err.println("❌ ERROR generating payment request signature: " + e.getMessage());
            e.printStackTrace();
            return null;
        }
    }
    
    /**
     * Xác thực webhook signature cho payouts
     * Sử dụng thuật toán HMAC_SHA256 với data dạng key1=value1&key2=value2...
     * Dữ liệu sắp xếp theo key thứ tự alphabet, arrays không được sắp xếp
     * Theo tài liệu PayOS: https://payos.vn/docs/webhook
     */
    public static boolean verifyPayoutSignature(JsonObject webhookData, String expectedSignature) {
        try {
            System.out.println("🔐 ===== VERIFYING PAYOUT SIGNATURE =====");
            
            if (!webhookData.has("data")) {
                System.err.println("❌ Webhook data missing 'data' field");
                return false;
            }
            
            // Extract signature from webhook data if not provided
            String actualSignature = expectedSignature;
            if ((actualSignature == null || actualSignature.isEmpty()) && webhookData.has("signature")) {
                actualSignature = webhookData.get("signature").getAsString();
            }
            
            if (actualSignature == null || actualSignature.isEmpty()) {
                System.err.println("❌ Webhook signature is missing");
                return false;
            }
            
            JsonObject data = webhookData.getAsJsonObject("data");
            String checksumKey = PayOSConfig.getChecksumKey();
            
            if (checksumKey == null || checksumKey.isEmpty()) {
                System.err.println("❌ Checksum key is not configured");
                return false;
            }
            
            System.out.println("📋 Payout data: " + data.toString());
            System.out.println("🔑 Expected signature: " + actualSignature);
            
            // Tạo signature từ data object theo chuẩn PayOS
            String computedSignature = generatePayoutSignature(data, checksumKey);
            System.out.println("🔐 Computed signature: " + computedSignature);
            
            boolean isValid = computedSignature != null && computedSignature.equalsIgnoreCase(actualSignature);
            System.out.println("✅ Signature verification result: " + isValid);
            
            if (!isValid) {
                System.err.println("❌ Signature mismatch!");
                System.err.println("   Expected: " + actualSignature);
                System.err.println("   Computed: " + computedSignature);
            }
            
            System.out.println("🔐 ===== PAYOUT SIGNATURE VERIFICATION COMPLETE =====");
            
            return isValid;
            
        } catch (Exception e) {
            System.err.println("❌ ERROR verifying payout signature: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Tạo signature cho payouts webhook data
     */
    private static String generatePayoutSignature(JsonObject data, String checksumKey) {
        try {
            // Sắp xếp keys theo alphabet, nhưng giữ nguyên thứ tự arrays
            java.util.TreeMap<String, Object> sortedMap = new java.util.TreeMap<>();
            
            for (Map.Entry<String, com.google.gson.JsonElement> entry : data.entrySet()) {
                String key = entry.getKey();
                com.google.gson.JsonElement value = entry.getValue();
                
                Object valueObj;
                if (value.isJsonNull()) {
                    valueObj = "";
                } else if (value.isJsonArray()) {
                    // Xử lý array - KHÔNG sắp xếp các phần tử trong array
                    com.google.gson.JsonArray array = value.getAsJsonArray();
                    java.util.List<Object> arrayList = new java.util.ArrayList<>();
                    for (com.google.gson.JsonElement element : array) {
                        if (element.isJsonObject()) {
                            java.util.TreeMap<String, Object> sortedElement = new java.util.TreeMap<>();
                            for (Map.Entry<String, com.google.gson.JsonElement> elemEntry : element.getAsJsonObject().entrySet()) {
                                sortedElement.put(elemEntry.getKey(), getValueFromJsonElement(elemEntry.getValue()));
                            }
                            arrayList.add(sortedElement);
                        } else {
                            arrayList.add(getValueFromJsonElement(element));
                        }
                    }
                    valueObj = arrayList;
                } else if (value.isJsonObject()) {
                    // Xử lý nested object - sắp xếp keys
                    java.util.TreeMap<String, Object> sortedNested = new java.util.TreeMap<>();
                    for (Map.Entry<String, com.google.gson.JsonElement> nestedEntry : value.getAsJsonObject().entrySet()) {
                        sortedNested.put(nestedEntry.getKey(), getValueFromJsonElement(nestedEntry.getValue()));
                    }
                    valueObj = sortedNested;
                } else {
                    valueObj = getValueFromJsonElement(value);
                }
                
                sortedMap.put(key, valueObj);
            }
            
            // Tạo query string dạng key1=value1&key2=value2... với encodeURI
            java.util.List<String> queryParts = new java.util.ArrayList<>();
            for (Map.Entry<String, Object> entry : sortedMap.entrySet()) {
                String key = entry.getKey();
                Object value = entry.getValue();
                
                String valueStr;
                if (value == null || "null".equals(String.valueOf(value)) || "undefined".equals(String.valueOf(value))) {
                    valueStr = "";
                } else if (value instanceof java.util.List || value instanceof java.util.Map) {
                    // Convert to JSON string for arrays and objects
                    Gson gson = new GsonBuilder().disableHtmlEscaping().create();
                    valueStr = gson.toJson(value);
                } else {
                    valueStr = String.valueOf(value);
                }
                
                // Encode URI components như trong JavaScript
                String encodedKey = java.net.URLEncoder.encode(key, StandardCharsets.UTF_8.toString());
                String encodedValue = java.net.URLEncoder.encode(valueStr, StandardCharsets.UTF_8.toString());
                queryParts.add(encodedKey + "=" + encodedValue);
            }
            
            String queryString = String.join("&", queryParts);
            System.out.println("📝 Query string for payout signature: " + queryString);
            
            // Tạo HMAC-SHA256 signature
            Mac mac = Mac.getInstance("HmacSHA256");
            SecretKeySpec secretKeySpec = new SecretKeySpec(checksumKey.getBytes(StandardCharsets.UTF_8), "HmacSHA256");
            mac.init(secretKeySpec);
            
            byte[] hash = mac.doFinal(queryString.getBytes(StandardCharsets.UTF_8));
            
            // Convert to hex
            StringBuilder hexString = new StringBuilder();
            for (byte b : hash) {
                String hex = Integer.toHexString(0xff & b);
                if (hex.length() == 1) hexString.append('0');
                hexString.append(hex);
            }
            
            return hexString.toString();
            
        } catch (Exception e) {
            System.err.println("❌ ERROR generating payout signature: " + e.getMessage());
            e.printStackTrace();
            return null;
        }
    }
    
    /**
     * Helper method để lấy giá trị từ JsonElement
     */
    private static Object getValueFromJsonElement(com.google.gson.JsonElement element) {
        if (element.isJsonNull()) {
            return "";
        } else if (element.isJsonPrimitive()) {
            com.google.gson.JsonPrimitive primitive = element.getAsJsonPrimitive();
            if (primitive.isString()) {
                return primitive.getAsString();
            } else if (primitive.isNumber()) {
                return primitive.getAsNumber();
            } else if (primitive.isBoolean()) {
                return primitive.getAsBoolean();
            }
        }
        return element.toString();
    }
    
    /**
     * Xác thực webhook signature (backward compatibility)
     * Tự động detect loại webhook và sử dụng phương thức phù hợp
     */
    public static boolean verifyWebhookSignature(String data, String signature) {
        try {
            System.out.println("🔐 ===== VERIFYING WEBHOOK SIGNATURE =====");
            
            JsonObject webhookData = JsonParser.parseString(data).getAsJsonObject();
            
            // Extract signature from webhook data if not provided in header
            String actualSignature = signature;
            if ((actualSignature == null || actualSignature.isEmpty()) && webhookData.has("signature")) {
                actualSignature = webhookData.get("signature").getAsString();
            }
            
            // Kiểm tra xem có phải payout webhook không
            if (webhookData.has("data")) {
                JsonObject dataObj = webhookData.getAsJsonObject("data");
                if (dataObj.has("payouts")) {
                    System.out.println("📊 Detected payout webhook");
                    return verifyPayoutSignature(webhookData, actualSignature);
                } else {
                    System.out.println("💳 Detected payment request webhook");
                    return verifyPaymentRequestSignature(webhookData, actualSignature);
                }
            }
            
            System.err.println("❌ Unknown webhook format");
            return false;
            
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
            
            // PayOS v2 expects amount in VND (convert from logical price format)
            // E.g., amount = 3.99 (logical) → amountInVND = 3990 (actual VND)
            int amountInVND = (int)Math.round(amount * 1000);
            
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
}
