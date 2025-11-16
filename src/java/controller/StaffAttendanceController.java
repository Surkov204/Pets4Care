package controller.staff;

import dao.AttendanceDAO;
import dao.PayrollDAO;
import dao.WorkScheduleDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Date;
import java.time.LocalDate;
import java.time.LocalTime;
import model.AttendanceRecord;
import model.PayrollRecord;
import model.Staff;
import model.WorkSchedule;

@WebServlet("/staff/attendance")
public class StaffAttendanceController extends HttpServlet {

    private final AttendanceDAO attendanceDAO = new AttendanceDAO();
    private final PayrollDAO payrollDAO = new PayrollDAO();
    private final WorkScheduleDAO workDAO = new WorkScheduleDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();
        HttpSession session = request.getSession();

        Staff staff = (Staff) session.getAttribute("staff");
        if (staff == null) {
            out.write("{\"status\":\"error\",\"message\":\"Bạn chưa đăng nhập.\"}");
            return;
        }

        int staffId = staff.getStaffId();
        String action = request.getParameter("action");

        // ========== FIX QUAN TRỌNG ==========
        if (action == null || action.trim().isEmpty()) {
            out.write("{\"status\":\"error\",\"message\":\"Thiếu action trong request.\"}");
            return;
        }
        // ====================================

        boolean success;

        // ========================== CHECK-IN / CHECK-OUT ==========================
        if ("toggle".equals(action)) {

            WorkSchedule shift = workDAO.getTodayShift(staffId);
            LocalTime now = LocalTime.now();

            if (shift == null) {
                out.write("{\"status\":\"error\",\"message\":\"⚠️ Hôm nay bạn không có ca làm.\"}");
                return;
            }

            LocalTime start = shift.getStartTime().toLocalTime();
            LocalTime end = shift.getEndTime().toLocalTime();

            LocalTime earlyAllowed = start.minusMinutes(15);
            LocalTime lateAllowed = start.plusMinutes(15);

            if (now.isBefore(earlyAllowed)) {
                out.write("{\"status\":\"error\",\"message\":\"⏰ Bạn đến quá sớm. Ca làm bắt đầu lúc " + start + "\"}");
                return;
            }

            boolean isLate = now.isAfter(lateAllowed) && now.isBefore(end);

            if (now.isAfter(end)) {
                out.write("{\"status\":\"error\",\"message\":\"⏰ Ca làm đã kết thúc.\"}");
                return;
            }

            AttendanceRecord today = attendanceDAO.getTodayRecord(staffId);

            // CHECK-OUT
            if (today != null && today.getCheckOut() == null) {

                success = attendanceDAO.staffCheckOut(staffId);

                if (success) {
                    session.setAttribute("isCheckedIn", false);
                    out.write("{\"status\":\"success\",\"message\":\"✅ Checkout thành công!\"}");
                } else {
                    out.write("{\"status\":\"error\",\"message\":\"❌ Lỗi khi checkout.\"}");
                }
                return;
            }

            // Đã check-out rồi
            if (today != null && today.getCheckOut() != null) {
                out.write("{\"status\":\"error\",\"message\":\"Bạn đã hoàn thành ca hôm nay.\"}");
                return;
            }

            // CHECK-IN
            success = attendanceDAO.staffCheckIn(staffId, isLate);

            if (success) {
                session.setAttribute("isCheckedIn", true);
                if (isLate) {
                    out.write("{\"status\":\"success\",\"message\":\"⏰ Đi muộn! Đã check-in.\"}");
                } else {
                    out.write("{\"status\":\"success\",\"message\":\"✅ Check-in thành công!\"}");
                }
            } else {
                out.write("{\"status\":\"error\",\"message\":\"❌ Lỗi khi check-in.\"}");
            }
            return;
        }

        // ========================== GENERATE PAYROLL ==========================
        if ("generate".equals(action)) {

            LocalDate nowDate = LocalDate.now();
            LocalDate firstDay = nowDate.withDayOfMonth(1);
            LocalDate lastDay = nowDate.withDayOfMonth(nowDate.lengthOfMonth());

            System.out.println("[DEBUG] Generating payroll for staffID = " + staffId);

            success = payrollDAO.generatePayroll(
                    staffId,
                    Date.valueOf(firstDay),
                    Date.valueOf(lastDay)
            );

            System.out.println("[DEBUG] Payroll generate success? " + success);

            if (success) {
                PayrollRecord latest = payrollDAO.getLatestPayroll(staffId);
                session.setAttribute("latestPayroll", latest);

                out.write("{\"status\":\"success\",\"message\":\"💰 Lương tháng này đã được tính thành công!\"}");
            } else {
                out.write("{\"status\":\"error\",\"message\":\"⚠️ Có lỗi khi tính lương.\"}");
            }
            return;
        }

        // ==================== ACTION KHÔNG HỢP LỆ — TRẢ JSON =====================
        out.write("{\"status\":\"error\",\"message\":\"Invalid action: " + action + "\"}");
    }
}