package controller;

import dao.WorkScheduleDAO;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.time.LocalDate;
import java.time.DayOfWeek;
import java.util.*;

@WebServlet("/staff/commonSchedule")
public class CommonScheduleController extends HttpServlet {
    private final WorkScheduleDAO workDAO = new WorkScheduleDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 🧭 Đọc weekOffset (0 = tuần hiện tại)
        int weekOffset = 0;
        try {
            weekOffset = Integer.parseInt(request.getParameter("weekOffset"));
        } catch (Exception e) {
            weekOffset = 0;
        }

        // 🗓️ Xác định khoảng tuần
        LocalDate today = LocalDate.now();
        LocalDate startOfWeek = today.with(DayOfWeek.MONDAY).plusWeeks(weekOffset);
        LocalDate endOfWeek = startOfWeek.plusDays(6);

        // 🟢 Lấy lịch chung trong tuần đó
        Map<String, List<String>> commonSchedule = workDAO.getCommonSchedule(startOfWeek, endOfWeek);

        // ✅ Gửi sang JSP
        request.setAttribute("commonSchedule", commonSchedule);
        request.setAttribute("startOfWeek", java.sql.Date.valueOf(startOfWeek));
        request.setAttribute("endOfWeek", java.sql.Date.valueOf(endOfWeek));
        request.setAttribute("weekOffset", weekOffset);

        request.getRequestDispatcher("/staff/commonSchedule.jsp").forward(request, response);
    }
}
