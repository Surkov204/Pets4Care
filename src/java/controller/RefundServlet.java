package controller;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import utils.DBConnection;
import utils.PayOSConfig;
import utils.PayOSUtils;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.Timestamp;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.Date;

@WebServlet("/api/refund")
public class RefundServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();
        Gson gson = new Gson();

        StringBuilder sb = new StringBuilder();
        try (BufferedReader reader = request.getReader()) {
            String line;
            while ((line = reader.readLine()) != null) {
                sb.append(line);
            }
        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.write("{\"message\": \"Lỗi đọc dữ liệu\"}");
            return;
        }
        String body = sb.toString();

        JsonObject jsonReq;
        try {
            jsonReq = gson.fromJson(body, JsonObject.class);
        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.write("{\"message\": \"Dữ liệu JSON không hợp lệ\"}");
            return;
        }

        // Nhánh 1: Refund nội bộ theo orderId (string) nếu có
        if (jsonReq.has("orderId") && jsonReq.get("orderId").isJsonPrimitive() && jsonReq.get("orderId").getAsJsonPrimitive().isString()) {
            String orderId = jsonReq.get("orderId").getAsString();
            Double amount = jsonReq.has("amount") ? jsonReq.get("amount").getAsDouble() : null;
            String reason = jsonReq.has("reason") ? jsonReq.get("reason").getAsString() : "Refund nội bộ";

            if (orderId == null || orderId.trim().isEmpty() || amount == null || amount <= 0) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.write("{\"message\": \"orderId và amount là bắt buộc, amount > 0\"}");
                return;
            }

            try (Connection conn = DBConnection.getConnection()) {
                String sqlInsert = "INSERT INTO dbo.Refunds (order_id, amount, payos_payout_id, reason, created_at) VALUES (?, ?, ?, ?, ?)";
                try (PreparedStatement psI = conn.prepareStatement(sqlInsert)) {
                    psI.setString(1, orderId);
                    psI.setDouble(2, amount);
                    psI.setString(3, null);
                    psI.setString(4, reason + " | internal");
                    psI.setTimestamp(5, new Timestamp(new Date().getTime()));
                    int inserted = psI.executeUpdate();
                    if (inserted > 0) {
                        response.setStatus(HttpServletResponse.SC_OK);
                        out.write("{\"message\": \"Refund nội bộ thành công\", \"orderId\": " + gson.toJson(orderId) + ", \"amount\": " + gson.toJson(amount) + "}");
                    } else {
                        response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                        out.write("{\"message\": \"Không ghi được log Refund vào DB\"}");
                    }
                    return;
                }
            } catch (SQLException e) {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                out.write("{\"message\": \"Lỗi DB khi refund nội bộ\", \"error\": " + gson.toJson(e.getMessage()) + "}");
                return;
            }
        }

        // Nhánh 2: Refund qua PayOS theo orderCode (int) như trước
        Integer orderCode = null;
        Double amount = null;
        String reason = "Hoàn tiền đơn hàng";
        try {
            if(jsonReq.has("orderCode")) orderCode = jsonReq.get("orderCode").getAsInt();
            if(jsonReq.has("amount")) amount = jsonReq.get("amount").getAsDouble();
            if(jsonReq.has("reason")) reason = jsonReq.get("reason").getAsString();
        } catch(Exception e){
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.write("{\"message\": \"Trường orderCode hoặc amount/reason không hợp lệ (sai kiểu dữ liệu)\"}");
            return;
        }

        if(orderCode == null || orderCode <= 0 || amount == null || amount <= 0){
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.write("{\"message\": \"orderCode và amount là bắt buộc, phải > 0\"}");
            return;
        }

        JsonObject refundPayload = new JsonObject();
        refundPayload.addProperty("orderCode", orderCode);
        refundPayload.addProperty("amount", amount.intValue());
        refundPayload.addProperty("description", reason);

        String refundResponseStr = null;
        JsonObject refundRespJson = null;
        String refundId = null;
        String lastError = null;
        boolean refundSuccess = false;
        String baseUsed = null;
        String refundEndpointUsed = null;

        String configuredEndpoint = PayOSConfig.getRefundEndpoint();
        String[] candidateEndpoints = new String[] {
            configuredEndpoint,
            "/payment-requests/refund",
            "/refunds",
            "/payment-requests/" + orderCode + "/refund"
        };
        String[] candidateBases = new String[] {
            PayOSConfig.getBaseUrl(),
            PayOSConfig.BASE_URL_PRIMARY,
            PayOSConfig.BASE_URL_FALLBACK
        };

        outer:
        for (String base : candidateBases) {
            for (String ep : candidateEndpoints) {
                try {
                    String payloadToSend = gson.toJson(refundPayload);
                    if (ep.contains("/payment-requests/" + orderCode + "/refund")) {
                        JsonObject alt = new JsonObject();
                        alt.addProperty("amount", amount.intValue());
                        alt.addProperty("description", reason);
                        payloadToSend = gson.toJson(alt);
                    }
                    refundResponseStr = PayOSUtils.makePayOSRequestWithBase(base, ep, "POST", payloadToSend, null);
                    refundRespJson = gson.fromJson(refundResponseStr, JsonObject.class);

                    String payosCode = refundRespJson.has("code") ? refundRespJson.get("code").getAsString() : null;
                    if (payosCode != null && (payosCode.equals("00") || payosCode.equals("200"))) {
                        refundSuccess = true;
                        baseUsed = base;
                        refundEndpointUsed = ep;
                        if (refundRespJson.has("data")) {
                            JsonObject data = refundRespJson.getAsJsonObject("data");
                            if (data.has("refundTransactionId")) {
                                refundId = data.get("refundTransactionId").getAsString();
                            } else if (data.has("payoutId")) {
                                refundId = data.get("payoutId").getAsString();
                            }
                        }
                        if (refundId == null) {
                            refundId = refundRespJson.has("transactionId") ? refundRespJson.get("transactionId").getAsString() : null;
                        }
                        break outer;
                    }
                    lastError = refundRespJson.has("desc") ? refundRespJson.get("desc").getAsString() : "Refund failed";
                } catch (Exception ex) {
                    lastError = ex.getMessage();
                }
            }
        }

        if (!refundSuccess) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            JsonObject dbg = new JsonObject();
            dbg.addProperty("message", "Hoàn tiền thất bại: Lỗi gọi PayOS");
            dbg.addProperty("baseUrl", PayOSConfig.getBaseUrl());
            dbg.addProperty("refundEndpointConfigured", configuredEndpoint);
            dbg.addProperty("baseTried", String.join(", ", candidateBases));
            dbg.addProperty("error", lastError != null ? lastError : "Unknown error");
            StringBuilder tried = new StringBuilder();
            for (int i = 0; i < candidateEndpoints.length; i++) {
                if (i > 0) tried.append(", ");
                tried.append(candidateEndpoints[i]);
            }
            dbg.addProperty("endpointsTried", tried.toString());
            dbg.addProperty("payload", refundPayload.toString());
            out.write(gson.toJson(dbg));
            return;
        }

        boolean dbOk = false;
        try (Connection conn = DBConnection.getConnection()) {
            String sql = "INSERT INTO dbo.Refunds (order_id, amount, payos_payout_id, reason, created_at) VALUES (?, ?, ?, ?, ?)";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, String.valueOf(orderCode));
                ps.setDouble(2, amount);
                ps.setString(3, refundId);
                ps.setString(4, reason + (baseUsed != null ? (" | base=" + baseUsed) : "") + (refundEndpointUsed != null ? (" | ep=" + refundEndpointUsed) : ""));
                ps.setTimestamp(5, new Timestamp(new Date().getTime()));
                int inserted = ps.executeUpdate();
                dbOk = inserted > 0;
            }
        } catch (SQLException dbEx) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.write("{\"message\": \"Hoàn tiền đã thành công trên PayOS nhưng lưu DB Refund bị lỗi!\", \"error\": " + gson.toJson(dbEx.getMessage()) + ", \"refundId\": " + gson.toJson(refundId) + "}");
            return;
        }

        if (dbOk) {
            response.setStatus(HttpServletResponse.SC_OK);
            JsonObject ok = new JsonObject();
            ok.addProperty("message", "Hoàn tiền thành công");
            ok.addProperty("refundId", refundId);
            if (baseUsed != null) ok.addProperty("baseUsed", baseUsed);
            if (refundEndpointUsed != null) ok.addProperty("endpointUsed", refundEndpointUsed);
            out.write(gson.toJson(ok));
        } else {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.write("{\"message\": \"Hoàn tiền PayOS thành công nhưng lưu DB thất bại\", \"refundId\": " + gson.toJson(refundId) + "}");
        }
    }
}
