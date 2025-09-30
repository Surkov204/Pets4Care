package utils;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import model.GoogleUser;

import java.io.*;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.stream.Collectors;

public class GoogleUtils {

    public static String getToken(String code) throws IOException {
        URL url = new URL("https://oauth2.googleapis.com/token");
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();

        String params = "code=" + code
                + "&client_id=" + GoogleConstants.CLIENT_ID
                + "&client_secret=" + GoogleConstants.CLIENT_SECRET
                + "&redirect_uri=" + GoogleConstants.REDIRECT_URI
                + "&grant_type=authorization_code";

        conn.setDoOutput(true);
        conn.setRequestMethod("POST");

        try (OutputStream os = conn.getOutputStream()) {
            os.write(params.getBytes(StandardCharsets.UTF_8)); // gửi UTF-8
        }

        String response = new BufferedReader(
                new InputStreamReader(conn.getInputStream(), StandardCharsets.UTF_8) // đọc UTF-8
        ).lines().collect(Collectors.joining());

        JsonObject json = JsonParser.parseString(response).getAsJsonObject();
        return json.get("access_token").getAsString();
    }

    public static GoogleUser getUserInfo(String accessToken) throws IOException {
        URL url = new URL("https://www.googleapis.com/oauth2/v2/userinfo?access_token=" + accessToken);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("GET");

        String response = new BufferedReader(
                new InputStreamReader(conn.getInputStream(), StandardCharsets.UTF_8) // đọc UTF-8
        ).lines().collect(Collectors.joining());

        return new Gson().fromJson(response, GoogleUser.class);
    }
}