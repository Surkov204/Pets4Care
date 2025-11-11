package controller;

import dao.ShiftDAO;
import dao.WorkScheduleDAO;
import dao.ShiftRequestDAO;
import dao.NotificationDAO;
import dao.SystemSettingDAO;
import dao.DoctorDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import model.Doctor;
import model.WorkSchedule;
import model.ShiftRequest;

import java.io.IOException;
import java.sql.Date;
import java.time.*;
import java.time.format.DateTimeFormatter;
import java.time.format.TextStyle;
import java.util.*;

@WebServlet("/doctor/work-schedule")
public class DoctorScheduleController extends HttpServlet {
    private final WorkScheduleDAO workDAO = new WorkScheduleDAO();
    private final ShiftDAO shiftDAO = new ShiftDAO();
    private final ShiftRequestDAO shiftReqDAO = new ShiftRequestDAO();
    private final NotificationDAO notiDAO = new NotificationDAO();
    private final SystemSettingDAO settingDAO = new SystemSettingDAO();
    private final DoctorDAO doctorDAO = new DoctorDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        Doctor doctor = (Doctor) session.getAttribute("doctor");
        
        if (doctor == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        
        int doctorId = doctor.getDoctorId();
        
        int weekOffset = 0;
        try {
            weekOffset = Integer.parseInt(request.getParameter("weekOffset"));
        } catch (Exception e) {
            weekOffset = 0;
        }
        
        Locale locale = new Locale("vi", "VN");
        LocalDate today = LocalDate.now();
        LocalDate startOfWeek = today.with(DayOfWeek.MONDAY).plusWeeks(weekOffset);
        LocalDate endOfWeek = startOfWeek.plusDays(6);

        List<WorkSchedule> scheduleList = workDAO.getScheduleByDoctorAndRange(doctorId, startOfWeek, endOfWeek);
        Map<String, List<String>> registeredMap = new HashMap<>();
        DateTimeFormatter fmt = DateTimeFormatter.ofPattern("yyyy-MM-dd");
        
        for (WorkSchedule ws : scheduleList) {
            if (ws.getShiftId() != null && ws.getWorkDate() != null) {
                String key = ws.getWorkDate().toLocalDate().format(fmt);
                registeredMap.computeIfAbsent(key, k -> new ArrayList<>())
                        .add(String.valueOf(ws.getShiftId()));
            }
        }

        List<Map<String, Object>> weekDays = new ArrayList<>();
        for (int i = 0; i < 7; i++) {
            LocalDate day = startOfWeek.plusDays(i);
            Map<String, Object> map = new HashMap<>();
            map.put("dayName", capitalize(day.getDayOfWeek().getDisplayName(TextStyle.FULL, locale)));
            map.put("date", day.format(fmt));
            map.put("registeredShifts", registeredMap.getOrDefault(day.format(fmt), new ArrayList<>()));
            weekDays.add(map);
        }

        LocalDate nextWeekStart = startOfWeek.plusWeeks(1);
        List<Map<String, Object>> nextWeekDays = new ArrayList<>();
        for (int i = 0; i < 7; i++) {
            LocalDate day = nextWeekStart.plusDays(i);
            Map<String, Object> map = new HashMap<>();
            map.put("dayName", capitalize(day.getDayOfWeek().getDisplayName(TextStyle.FULL, locale)));
            map.put("date", day.format(fmt));
            nextWeekDays.add(map);
        }

        request.setAttribute("weekDays", weekDays);
        request.setAttribute("nextWeekDays", nextWeekDays);
        request.setAttribute("startOfWeek", java.sql.Date.valueOf(startOfWeek));
        request.setAttribute("endOfWeek", java.sql.Date.valueOf(endOfWeek)); 
        request.setAttribute("weekOffset", weekOffset);
        request.setAttribute("shifts", shiftDAO.getAllShifts());
        request.setAttribute("todaySchedule", workDAO.getTodayScheduleForDoctor(doctorId));
        request.setAttribute("upcomingSchedules", workDAO.getUpcomingScheduleForDoctor(doctorId, 7));
        request.setAttribute("canRegister", settingDAO.isShiftRegistrationEnabled());
        request.setAttribute("otherDoctors", doctorDAO.getAllExcept(doctorId));

        request.getRequestDispatcher("/doctor/work-schedule.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        Doctor doctor = (Doctor) session.getAttribute("doctor");
        
        if (doctor == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        
        int doctorId = doctor.getDoctorId();
        String action = request.getParameter("action");
        String dayParam = request.getParameter("day");
        String shiftType = request.getParameter("shift");

        try {
            switch (action) {
                case "register" -> {
                    if (!settingDAO.isShiftRegistrationEnabled()) {
                        session.setAttribute("errorMessage", "⏰ Admin chưa mở đăng ký ca!");
                        break;
                    }
                    if (dayParam == null || shiftType == null) {
                        session.setAttribute("errorMessage", "⚠️ Thiếu thông tin ngày hoặc ca đăng ký.");
                        break;
                    }
                    LocalDate workDay = LocalDate.parse(dayParam);
                    LocalDate nextMonday = LocalDate.now().with(DayOfWeek.MONDAY).plusWeeks(1);
                    LocalDate nextSunday = nextMonday.plusDays(6);
                    if (workDay.isBefore(nextMonday) || workDay.isAfter(nextSunday)) {
                        session.setAttribute("errorMessage", "❌ Chỉ được gửi yêu cầu cho tuần kế tiếp.");
                        break;
                    }
                    int shiftId = resolveShiftId(shiftType);
                    if (shiftId == -1) {
                        session.setAttribute("errorMessage", "⚠️ Ca làm không hợp lệ.");
                        break;
                    }
                    String reason = Optional.ofNullable(request.getParameter("reason")).orElse("Bác sĩ đăng ký ca mới");

                    ShiftRequest req = new ShiftRequest();
                    req.setEmployeeID(doctorId);
                    req.setToStaffID(0);
                    req.setType("DoctorRegister");
                    req.setFromDate(Date.valueOf(workDay));
                    req.setFromShiftID(shiftId);
                    req.setReason(reason);
                    req.setStatus("Pending");
                    shiftReqDAO.addPassRequest(req);
                    notiDAO.createNotification(1, "Yêu cầu đăng ký ca (Doctor)", "Bác sĩ " + doctor.getName() + " xin đăng ký ca mới.");
                    session.setAttribute("successMessage", "✅ Đã gửi yêu cầu đăng ký ca, chờ admin duyệt!");
                    break;
                }
                case "cancelMultiple" -> {
                    String[] items = request.getParameterValues("cancelItems");
                    if (items == null || items.length == 0) {
                        session.setAttribute("errorMessage", "⚠️ Vui lòng chọn ít nhất một ca để gửi yêu cầu.");
                        break;
                    }
                    String reason = Optional.ofNullable(request.getParameter("cancelReason")).orElse("Bác sĩ yêu cầu hủy ca");
                    int count = 0;
                    for (String item : items) {
                        String[] parts = item.split("\\|");
                        Date workDate = Date.valueOf(parts[0]);
                        int shiftId = Integer.parseInt(parts[1]);

                        ShiftRequest req = new ShiftRequest();
                        req.setEmployeeID(doctorId);
                        req.setToStaffID(0);
                        req.setType("DoctorCancel");
                        req.setFromDate(workDate);
                        req.setFromShiftID(shiftId);
                        req.setReason(reason);
                        req.setStatus("Pending");
                        shiftReqDAO.addPassRequest(req);
                        count++;
                    }
                    notiDAO.createNotification(1, "Yêu cầu hủy ca (Doctor)", "Bác sĩ " + doctor.getName() + " đã gửi " + count + " yêu cầu hủy ca.");
                    session.setAttribute("successMessage", "🗑 Đã gửi " + count + " yêu cầu hủy ca, chờ duyệt!");
                    break;
                }
                case "swap" -> {
                    String fromDateParam = request.getParameter("swapFromDate");
                    String toDateParam = request.getParameter("swapToDate");
                    String fromShiftParam = request.getParameter("swapFromShiftId");
                    String toShiftParam = request.getParameter("swapToShiftId");
                    String toDoctorParam = request.getParameter("swapToDoctorId");
                    if (fromDateParam == null || toDateParam == null || fromShiftParam == null || toShiftParam == null || toDoctorParam == null) {
                        session.setAttribute("errorMessage", "⚠️ Thiếu thông tin đổi ca.");
                        break;
                    }
                    Date fromDate = Date.valueOf(fromDateParam);
                    Date toDate = Date.valueOf(toDateParam);
                    int fromShiftId = Integer.parseInt(fromShiftParam);
                    int toShiftId = Integer.parseInt(toShiftParam);
                    int targetDoctorId = Integer.parseInt(toDoctorParam);
                    if (!workDAO.hasDoctorShift(doctorId, fromDate, fromShiftId)) {
                        session.setAttribute("errorMessage", "⚠️ Bạn không có ca cần đổi.");
                        break;
                    }
                    if (!workDAO.hasDoctorShift(targetDoctorId, toDate, toShiftId)) {
                        session.setAttribute("errorMessage", "⚠️ Bác sĩ được chọn không có ca tương ứng.");
                        break;
                    }
                    if (!workDAO.canDoctorSwapShift(doctorId, targetDoctorId, fromDate, toDate, fromShiftId, toShiftId)) {
                        session.setAttribute("errorMessage", "⚠️ Không thể đổi ca do trùng lịch.");
                        break;
                    }
                    String reason = Optional.ofNullable(request.getParameter("swapReason")).orElse("Bác sĩ yêu cầu đổi ca");
                    ShiftRequest req = new ShiftRequest();
                    req.setEmployeeID(doctorId);
                    req.setToStaffID(targetDoctorId);
                    req.setType("DoctorSwap");
                    req.setFromDate(fromDate);
                    req.setToDate(toDate);
                    req.setFromShiftID(fromShiftId);
                    req.setToShiftID(toShiftId);
                    req.setReason(reason);
                    req.setStatus("Pending");
                    shiftReqDAO.addRequest(req);
                    session.setAttribute("successMessage", "🔁 Đã gửi yêu cầu đổi ca, chờ duyệt!");
                    break;
                }
                case "pass" -> {
                    String dateParam = request.getParameter("passDate");
                    String shiftParam = request.getParameter("passShiftId");
                    String toDoctorParam = request.getParameter("passToDoctorId");
                    if (dateParam == null || shiftParam == null || toDoctorParam == null) {
                        session.setAttribute("errorMessage", "⚠️ Thiếu thông tin nhờ làm thay.");
                        break;
                    }
                    Date workDate = Date.valueOf(dateParam);
                    int shiftId = Integer.parseInt(shiftParam);
                    int targetDoctorId = Integer.parseInt(toDoctorParam);
                    if (!workDAO.hasDoctorShift(doctorId, workDate, shiftId)) {
                        session.setAttribute("errorMessage", "⚠️ Bạn không có ca này để nhờ làm thay.");
                        break;
                    }
                    if (workDAO.hasDoctorShift(targetDoctorId, workDate, shiftId)) {
                        session.setAttribute("errorMessage", "⚠️ Bác sĩ được chọn đã có ca trùng giờ.");
                        break;
                    }
                    String reason = Optional.ofNullable(request.getParameter("passReason")).orElse("Bác sĩ nhờ làm thay");
                    ShiftRequest req = new ShiftRequest();
                    req.setEmployeeID(doctorId);
                    req.setToStaffID(targetDoctorId);
                    req.setType("DoctorPass");
                    req.setFromDate(workDate);
                    req.setFromShiftID(shiftId);
                    req.setReason(reason);
                    req.setStatus("Pending");
                    shiftReqDAO.addPassRequest(req);
                    session.setAttribute("successMessage", "📨 Đã gửi yêu cầu nhờ làm thay, chờ duyệt!");
                    break;
                }
                default -> session.setAttribute("errorMessage", "⚠️ Hành động không hợp lệ.");
            }
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("errorMessage", "❌ Có lỗi xảy ra khi xử lý yêu cầu!");
        }

        response.sendRedirect(request.getContextPath() + "/doctor/work-schedule");
    }

    private int resolveShiftId(String shiftType) {
        if (shiftType == null) {
            return -1;
        }
        switch (shiftType) {
            case "morning":
                return 1;
            case "afternoon":
                return 2;
            case "evening":
                return 3;
            default:
                try {
                    return Integer.parseInt(shiftType);
                } catch (NumberFormatException e) {
                    return -1;
                }
        }
    }

    private String capitalize(String text) {
        if (text == null || text.isEmpty()) return text;
        return text.substring(0, 1).toUpperCase() + text.substring(1);
    }
}
