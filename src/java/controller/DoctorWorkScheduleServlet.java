package controller;

import dao.WorkScheduleDAO;
import model.Doctor;
import model.WorkSchedule;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.temporal.TemporalAdjusters;
import java.util.*;

@WebServlet("/doctor/work-schedule")
public class DoctorWorkScheduleServlet extends HttpServlet {
    
    private WorkScheduleDAO workScheduleDAO = new WorkScheduleDAO();
    private DateTimeFormatter dateFormatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");
    private DateTimeFormatter displayFormatter = DateTimeFormatter.ofPattern("dd/MM/yyyy");

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        Doctor doctor = (Doctor) session.getAttribute("doctor");
        
        // Kiểm tra đăng nhập
        if (doctor == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        // Lấy tuần offset (mặc định 0 = tuần hiện tại)
        int weekOffset = 0;
        String weekParam = request.getParameter("weekOffset");
        if (weekParam != null) {
            try {
                weekOffset = Integer.parseInt(weekParam);
            } catch (NumberFormatException e) {
                weekOffset = 0;
            }
        }

        // Tính toán ngày bắt đầu tuần (thứ 2)
        LocalDate today = LocalDate.now();
        LocalDate startOfWeek = today.with(TemporalAdjusters.previousOrSame(DayOfWeek.MONDAY))
                                     .plusWeeks(weekOffset);
        LocalDate endOfWeek = startOfWeek.plusDays(6);

        // Lấy lịch làm việc từ database
        List<WorkSchedule> schedules = workScheduleDAO.getScheduleByDoctorAndRange(
            doctor.getDoctorId(), startOfWeek, endOfWeek
        );

        // Tạo Map để dễ tra cứu: date -> List<WorkSchedule>
        Map<String, List<WorkSchedule>> scheduleMap = new LinkedHashMap<>();
        for (WorkSchedule ws : schedules) {
            String dateKey = ws.getWorkDate().toLocalDate().format(dateFormatter);
            scheduleMap.computeIfAbsent(dateKey, k -> new ArrayList<>()).add(ws);
        }

        // Tạo danh sách 7 ngày trong tuần
        List<Map<String, Object>> weekDays = new ArrayList<>();
        for (int i = 0; i < 7; i++) {
            LocalDate day = startOfWeek.plusDays(i);
            String dateKey = day.format(dateFormatter);
            
            Map<String, Object> dayInfo = new HashMap<>();
            dayInfo.put("date", day);
            dayInfo.put("dateKey", dateKey);
            dayInfo.put("dayNumber", day.getDayOfMonth());
            dayInfo.put("dayOfWeek", getDayOfWeekInVietnamese(day.getDayOfWeek()));
            dayInfo.put("isToday", day.equals(today));
            
            List<WorkSchedule> daySchedules = scheduleMap.getOrDefault(dateKey, new ArrayList<>());
            dayInfo.put("schedules", daySchedules);
            dayInfo.put("scheduleCount", daySchedules.size());
            dayInfo.put("hasSchedule", !daySchedules.isEmpty());
            
            weekDays.add(dayInfo);
        }

        // Thống kê ca làm việc
        Map<String, Integer> shiftStats = new LinkedHashMap<>();
        shiftStats.put("morning", 0);
        shiftStats.put("afternoon", 0);
        shiftStats.put("evening", 0);
        shiftStats.put("total", 0);

        for (WorkSchedule ws : schedules) {
            String shiftName = ws.getShiftName();
            if (shiftName != null) {
                if (shiftName.toLowerCase().contains("sáng")) {
                    shiftStats.put("morning", shiftStats.get("morning") + 1);
                } else if (shiftName.toLowerCase().contains("chiều")) {
                    shiftStats.put("afternoon", shiftStats.get("afternoon") + 1);
                } else if (shiftName.toLowerCase().contains("tối")) {
                    shiftStats.put("evening", shiftStats.get("evening") + 1);
                }
                shiftStats.put("total", shiftStats.get("total") + 1);
            }
        }

        // Set attributes
        request.setAttribute("weekDays", weekDays);
        request.setAttribute("weekOffset", weekOffset);
        request.setAttribute("startDate", startOfWeek.format(displayFormatter));
        request.setAttribute("endDate", endOfWeek.format(displayFormatter));
        request.setAttribute("shiftStats", shiftStats);
        request.setAttribute("allSchedules", schedules);

        // Forward to JSP
        request.getRequestDispatcher("/doctor/work-schedule.jsp").forward(request, response);
    }

    private String getDayOfWeekInVietnamese(DayOfWeek dayOfWeek) {
        return switch (dayOfWeek) {
            case MONDAY -> "Thứ 2";
            case TUESDAY -> "Thứ 3";
            case WEDNESDAY -> "Thứ 4";
            case THURSDAY -> "Thứ 5";
            case FRIDAY -> "Thứ 6";
            case SATURDAY -> "Thứ 7";
            case SUNDAY -> "Chủ nhật";
        };
    }
}

