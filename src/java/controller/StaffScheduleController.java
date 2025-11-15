package controller;

import dao.ShiftDAO;
import dao.WorkScheduleDAO;
import dao.SystemSettingDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.time.*;
import java.time.format.DateTimeFormatter;
import java.time.format.TextStyle;
import java.util.*;
import model.Staff;
import model.WorkSchedule;

@WebServlet("/staff/mySchedule")
public class StaffScheduleController extends HttpServlet {
    private final WorkScheduleDAO workDAO = new WorkScheduleDAO();
    private final ShiftDAO shiftDAO = new ShiftDAO();
    private final SystemSettingDAO settingDAO = new SystemSettingDAO(); // ✅ thêm

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        Integer staffId = (Integer) session.getAttribute("staffId");
        if (staffId == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        int weekOffset = 0;
        try {
            weekOffset = Integer.parseInt(request.getParameter("weekOffset"));
        } catch (Exception e) {
            weekOffset = 0;
        }
        // 🗓️ Xem lịch = tuần hiện tại
        Locale locale = new Locale("vi", "VN");
        LocalDate today = LocalDate.now();
        LocalDate startOfWeek = today.with(DayOfWeek.MONDAY).plusWeeks(weekOffset);
        LocalDate endOfWeek = startOfWeek.plusDays(6);

        // 🟢 Lịch hiện tại
        List<WorkSchedule> scheduleList = workDAO.getScheduleByStaffAndRange(staffId, startOfWeek, endOfWeek);
        Map<String, List<String>> registeredMap = new HashMap<>();
        DateTimeFormatter fmt = DateTimeFormatter.ofPattern("yyyy-MM-dd");
        for (WorkSchedule ws : scheduleList) {
            if (ws.getShiftId() != null && ws.getWorkDate() != null) {
                String key = ws.getWorkDate().toLocalDate().format(fmt);
                registeredMap.computeIfAbsent(key, k -> new ArrayList<>())
                        .add(String.valueOf(ws.getShiftId()));
            }
        }

        // 🗓️ Danh sách ngày trong tuần
        List<Map<String, Object>> weekDays = new ArrayList<>();
        for (int i = 0; i < 7; i++) {
            LocalDate day = startOfWeek.plusDays(i);
            Map<String, Object> map = new HashMap<>();
            map.put("dayName", capitalize(day.getDayOfWeek().getDisplayName(TextStyle.FULL, locale)));
            map.put("date", day.format(fmt));
            map.put("registeredShifts", registeredMap.getOrDefault(day.format(fmt), new ArrayList<>()));
            weekDays.add(map);
        }

        // 🗓️ Tuần sau (cho đăng ký)
        LocalDate nextWeekStart = startOfWeek.plusWeeks(1);
        List<Map<String, Object>> nextWeekDays = new ArrayList<>();
        for (int i = 0; i < 7; i++) {
            LocalDate day = nextWeekStart.plusDays(i);
            Map<String, Object> map = new HashMap<>();
            map.put("dayName", capitalize(day.getDayOfWeek().getDisplayName(TextStyle.FULL, locale)));
            map.put("date", day.format(fmt));
            nextWeekDays.add(map);
        }

        // ✅ Kiểm tra admin đã mở đăng ký chưa
        boolean canRegister = settingDAO.isShiftRegistrationEnabled();
        request.setAttribute("canRegister", canRegister);

        // ✅ Gửi dữ liệu ra JSP
        request.setAttribute("weekDays", weekDays);
        request.setAttribute("nextWeekDays", nextWeekDays);
        request.setAttribute("startOfWeek", java.sql.Date.valueOf(startOfWeek));
        request.setAttribute("endOfWeek", java.sql.Date.valueOf(endOfWeek)); 
        request.setAttribute("weekOffset", weekOffset);
        
        request.setAttribute("commonSchedule", workDAO.getCommonSchedule(startOfWeek, endOfWeek));
        request.setAttribute("staffList", workDAO.getAllStaffExcept(staffId));
        request.setAttribute("shifts", shiftDAO.getAllShifts());

        request.getRequestDispatcher("/staff/mySchedule.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        Integer staffId = (Integer) session.getAttribute("staffId");
        if (staffId == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String action = request.getParameter("action");
        String dayParam = request.getParameter("day");
        String shiftType = request.getParameter("shift");

        try {
            switch (action) {
                case "register" -> {
                    // ✅ Chỉ kiểm tra khi đăng ký ca
                    if (!settingDAO.isShiftRegistrationEnabled()) {
                        session.setAttribute("errorMessage", "⏰ Admin chưa mở đăng ký ca!");
                        response.sendRedirect(request.getContextPath() + "/staff/mySchedule");
                        return;
                    }

                    LocalDate workDay = LocalDate.parse(dayParam);
                    LocalDate nextMonday = LocalDate.now().with(DayOfWeek.MONDAY).plusWeeks(1);
                    LocalDate nextSunday = nextMonday.plusDays(6);

                    if (workDay.isBefore(nextMonday) || workDay.isAfter(nextSunday)) {
                        session.setAttribute("errorMessage", "❌ Chỉ được đăng ký ca trong tuần kế tiếp!");
                        response.sendRedirect(request.getContextPath() + "/staff/mySchedule");
                        return;
                    }

                    workDAO.addScheduleByShiftType(staffId, workDay, shiftType);
                    session.setAttribute("successMessage", "✅ Đăng ký ca thành công!");
                }
                case "cancelMultiple" -> {
                    String[] items = request.getParameterValues("cancelItems");
                    if (items != null) {
                        for (String item : items) {
                            String[] parts = item.split("\\|");
                            LocalDate workDate = LocalDate.parse(parts[0]);
                            int shiftId = Integer.parseInt(parts[1]);
                            workDAO.deleteScheduleByStaffShiftDate(staffId, shiftId, workDate);
                        }
                        session.setAttribute("successMessage", "🗑️ Hủy ca thành công!");
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("errorMessage", "❌ Có lỗi xảy ra khi xử lý yêu cầu!");
        }

        response.sendRedirect(request.getContextPath() + "/staff/mySchedule");
    }

    private String capitalize(String text) {
        if (text == null || text.isEmpty()) return text;
        return text.substring(0, 1).toUpperCase() + text.substring(1);
    }
}