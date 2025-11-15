package controller;

import com.google.gson.Gson;
import dao.NotificationDAO;
import java.io.IOException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Staff;

@WebServlet("/notification")
public class NotificationController extends HttpServlet {

    private final NotificationDAO dao = new NotificationDAO();
    private final Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        response.setContentType("application/json;charset=UTF-8");

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("staff") == null) {
            response.getWriter().write("{\"count\":0}");
            return;
        }

        int staffId = ((Staff) session.getAttribute("staff")).getStaffId();
        String action = request.getParameter("action");

        switch (action) {
            case "count" -> {
                int count = dao.countUnread(staffId);
                response.getWriter().write("{\"count\":" + count + "}");
            }
            case "list" -> {
                // ✅ chỉ lấy thông báo chưa đọc & chưa xử lý
                response.getWriter().write(gson.toJson(dao.getUnread(staffId)));
            }
            case "markAllRead" -> {
                dao.markAsRead(staffId);
                response.getWriter().write("{\"status\":\"ok\"}");
            }
            default -> {
                response.getWriter().write("{\"error\":\"Invalid action\"}");
            }
        }
    }
}