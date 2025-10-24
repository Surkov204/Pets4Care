package controller;

import dao.ShiftDAO;
import dao.WorkScheduleDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.Date;
import java.time.*;
import java.time.format.DateTimeFormatter;
import java.time.format.TextStyle;
import java.util.*;
import model.Shift;
import model.Staff;
import model.WorkSchedule;

@WebServlet("/staff/mySchedule")
public class StaffScheduleController extends HttpServlet {

    private final WorkScheduleDAO workDAO = new WorkScheduleDAO();
    private final ShiftDAO shiftDAO = new ShiftDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        System.out.println("=== DEBUG: StaffScheduleController.doGet() CALLED ===");
        System.out.println("Session staffId = " + session.getAttribute("staffId"));
        System.out.print("hello");

        Integer staffId = (Integer) session.getAttribute("staffId");
        if (staffId == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        int weekOffset = 0;
        try {
            weekOffset = Integer.parseInt(request.getParameter("weekOffset"));
        } catch (Exception ignored) {
        }

        // 🗓️ Tính tuần bắt đầu (thứ 2)
        Locale locale = new Locale("vi", "VN");
        LocalDate today = LocalDate.now();
        DayOfWeek dow = today.getDayOfWeek();
        LocalDate startOfWeek = (dow == DayOfWeek.SUNDAY ? today.minusDays(6) : today.minusDays(dow.getValue() - 1))
                .plusWeeks(weekOffset);

        LocalDate endOfWeek = startOfWeek.plusDays(6);

        // 🟢 Lấy lịch làm việc của nhân viên trong khoảng tuần đó
        List<WorkSchedule> scheduleList = workDAO.getScheduleByStaffAndRange(staffId, startOfWeek, endOfWeek);

        // 🟢 Map theo String (yyyy-MM-dd) -> List<String>
        Map<String, List<String>> registeredMap = new HashMap<>();
        DateTimeFormatter fmt = DateTimeFormatter.ofPattern("yyyy-MM-dd");
        for (WorkSchedule ws : scheduleList) {
            if (ws.getShiftId() != null && ws.getWorkDate() != null) {
                String key = ws.getWorkDate().toLocalDate().format(fmt);
                registeredMap.computeIfAbsent(key, k -> new ArrayList<>())
                        .add(String.valueOf(ws.getShiftId()));
            }
        }

        // 🟢 Tạo danh sách 7 ngày
        List<Map<String, Object>> weekDays = new ArrayList<>();
        for (int i = 0; i < 7; i++) {
            LocalDate day = startOfWeek.plusDays(i);
            String key = day.format(fmt);
            Map<String, Object> map = new HashMap<>();
            map.put("dayName", capitalize(day.getDayOfWeek().getDisplayName(TextStyle.FULL, locale)));
            map.put("date", key);
            map.put("registeredShifts", registeredMap.getOrDefault(key, new ArrayList<>()));
            weekDays.add(map);
        }

        // Gửi dữ liệu
        request.setAttribute("weekDays", weekDays);
        request.setAttribute("weekOffset", weekOffset);
        request.setAttribute("startOfWeek", java.sql.Date.valueOf(startOfWeek));
        request.setAttribute("endOfWeek", java.sql.Date.valueOf(endOfWeek));
        request.setAttribute("shifts", shiftDAO.getAllShifts());
        Map<String, List<String>> commonSchedule = workDAO.getCommonSchedule();
        request.setAttribute("commonSchedule", commonSchedule);
        System.out.println("[DEBUG] mySchedule.doGet() -> staffId = " + staffId);
        List<Staff> list = workDAO.getAllStaffExcept(staffId);
        System.out.println("[DEBUG] Found " + list.size() + " staff in DB");
        request.setAttribute("staffList", list);
        request.setAttribute("staffList", workDAO.getAllStaffExcept(staffId));
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
            if ("register".equals(action) && dayParam != null && shiftType != null) {
                LocalDate workDay = LocalDate.parse(dayParam);
                session.setAttribute("successMessage", "✅ Đăng ký ca thành công!");
                workDAO.addScheduleByShiftType(staffId, workDay, shiftType);
                System.out.println("✅ Đăng ký " + shiftType + " cho ngày " + workDay);
            } else if ("cancel".equals(action) && dayParam != null && shiftType != null) {
                LocalDate workDay = LocalDate.parse(dayParam);
                int shiftId = switch (shiftType) {
                    case "morning" ->
                        1;
                    case "afternoon" ->
                        2;
                    case "evening" ->
                        3;
                    default ->
                        0;
                };
                if (shiftId != 0) {
                    workDAO.deleteScheduleByStaffShiftDate(staffId, shiftId, workDay);
                    System.out.println("🗑 Hủy " + shiftType + " ngày " + workDay);
                }
            } // 🗑 Hủy nhiều ca cùng lúc
            else if ("cancelMultiple".equals(action)) {
                String[] items = request.getParameterValues("cancelItems");
                if (items != null) {
                    for (String item : items) {
                        try {
                            String[] parts = item.split("\\|"); // ✅ đúng
                            LocalDate workDate = LocalDate.parse(parts[0]);
                            int shiftId = Integer.parseInt(parts[1]);
                            workDAO.deleteScheduleByStaffShiftDate(staffId, shiftId, workDate);
                            session.setAttribute("successMessage", "🗑️ Hủy ca thành công!");
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                    }
                    System.out.println("🗑 Đã hủy " + items.length + " ca cho staff " + staffId);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        Map<String, List<String>> commonSchedule = workDAO.getCommonSchedule();
        request.setAttribute("commonSchedule", commonSchedule);

        response.sendRedirect(request.getContextPath() + "/staff/mySchedule");

    }

    private String capitalize(String text) {
        if (text == null || text.isEmpty()) {
            return text;
        }
        return text.substring(0, 1).toUpperCase() + text.substring(1);
    }
}
