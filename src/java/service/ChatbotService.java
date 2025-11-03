package service;

import java.io.*;
import java.net.*;
import org.json.*;

public class ChatbotService {

    // Model Gemini miễn phí, nhanh và ổn định
    private static final String API_URL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent";

    public static String ask(String userMessage, String apiKey) {
        try {
            // Gửi request đến Gemini API
            URL url = new URL(API_URL + "?key=" + apiKey);
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("POST");
            conn.setRequestProperty("Content-Type", "application/json; charset=UTF-8");
            conn.setDoOutput(true);

            // Body JSON
            JSONObject textPart = new JSONObject().put("text", userMessage);
            JSONObject content = new JSONObject().put("parts", new JSONArray().put(textPart));
            JSONObject requestBody = new JSONObject().put("contents", new JSONArray().put(content));

            try (OutputStream os = conn.getOutputStream()) {
                byte[] input = requestBody.toString().getBytes("utf-8");
                os.write(input, 0, input.length);
            }

            int status = conn.getResponseCode();
            BufferedReader br;
            if (status >= 200 && status < 300) {
                br = new BufferedReader(new InputStreamReader(conn.getInputStream(), "utf-8"));
            } else {
                br = new BufferedReader(new InputStreamReader(conn.getErrorStream(), "utf-8"));
                System.err.println("⚠️ Gemini API Error - HTTP " + status);
            }

            StringBuilder response = new StringBuilder();
            String line;
            while ((line = br.readLine()) != null) response.append(line.trim());
            br.close();

            // In response ra log (để debug)
            System.out.println("🧠 Gemini Raw Response: " + response.toString());

            if (status >= 200 && status < 300) {
                JSONObject json = new JSONObject(response.toString());
                String reply = json.getJSONArray("candidates")
                        .getJSONObject(0)
                        .getJSONObject("content")
                        .getJSONArray("parts")
                        .getJSONObject(0)
                        .getString("text");
                return reply.trim();
            } else {
                return "⚠️ Lỗi từ Gemini API: " + response;
            }

        } catch (Exception e) {
            e.printStackTrace();
            return "❌ Không thể kết nối đến Gemini API: " + e.getMessage();
        }
    }
}