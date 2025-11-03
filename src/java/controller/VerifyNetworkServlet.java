package controller.staff;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/staff/verifyNetwork")
public class VerifyNetworkServlet extends HttpServlet {

    private static final String COMPANY_WIFI_PREFIX = "192.168.1.";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        String clientIp = request.getRemoteAddr();

        // ✅ Nếu chạy local (Tomcat + Browser cùng máy)
        if ("127.0.0.1".equals(clientIp) || "0:0:0:0:0:0:0:1".equals(clientIp)) {
            clientIp = getLocalIp(); // Lấy IP thật của máy (192.168.x.x)
        }

        boolean isCompanyNetwork = clientIp.startsWith(COMPANY_WIFI_PREFIX);

        System.out.println("[DEBUG] Client IP: " + clientIp + " | isCompanyNetwork = " + isCompanyNetwork);

        response.setContentType("application/json;charset=UTF-8");
        response.getWriter().write(String.format(
                "{\"status\":\"ok\",\"ip\":\"%s\",\"isCompanyNetwork\":%b}",
                clientIp, isCompanyNetwork
        ));
    }

    // 🔍 Hàm lấy IP thật của máy trong mạng LAN
    private String getLocalIp() {
        try {
            return java.net.InetAddress.getLocalHost().getHostAddress();
        } catch (Exception e) {
            return "unknown";
        }
    }
}