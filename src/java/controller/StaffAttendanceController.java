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
        boolean success = false;

        // ✅ Lấy ca hiện tại theo thời gian thực
        WorkSchedule currentShift = workDAO.getCurrentShiftForToday(staffId);
        LocalTime now = LocalTime.now();

        if (currentShift == null) {
            out.write("{\"status\":\"error\",\"message\":\"⚠️ Hôm nay bạn không có ca làm nào đang diễn ra.\"}");
            return;
        }

        if (now.isAfter(currentShift.getEndTime().toLocalTime())) {
            out.write("{\"status\":\"error\",\"message\":\"⏰ Ca làm của bạn đã kết thúc.\"}");
            return;
        }

        if ("toggle".equals(action)) {
            AttendanceRecord last = attendanceDAO.getLatestRecord(staffId);
            LocalTime nowTime = LocalTime.now();

            // ✅ Nếu không có ca làm hôm nay hoặc đã kết thúc
            if (currentShift == null) {
                out.write("{\"status\":\"error\",\"message\":\"⚠️ Hôm nay bạn không có ca làm nào đang diễn ra.\"}");
                return;
            }
            if (nowTime.isAfter(currentShift.getEndTime().toLocalTime())) {
                out.write("{\"status\":\"error\",\"message\":\"⏰ Ca làm của bạn đã kết thúc.\"}");
                return;
            }

            // ✅ Nếu đã có record và chưa checkout → cho phép checkout
            if (last != null && last.getCheckOut() == null) {
                success = attendanceDAO.staffCheckOut(staffId);
                if (success) {
                    session.setAttribute("isCheckedIn", false);
                }
                out.write(success
                        ? "{\"status\":\"success\",\"message\":\"✅ Checkout thành công! Nghỉ ngơi nhé.\"}"
                        : "{\"status\":\"error\",\"message\":\"❌ Lỗi khi checkout.\"}");
            } // ✅ Nếu đã có record checkout trong cùng ca → KHÔNG cho check-in lại
            else if (last != null
                    && last.getCheckOut() != null
                    && last.getCheckIn().toLocalDateTime().toLocalDate().equals(LocalDate.now())
                    && nowTime.isAfter(currentShift.getStartTime().toLocalTime())
                    && nowTime.isBefore(currentShift.getEndTime().toLocalTime())) {
                out.write("{\"status\":\"error\",\"message\":\"⚠️ Bạn đã hoàn thành ca này, không thể check-in lại.\"}");
            } // ✅ Còn lại: cho check-in bình thường
            else {
                success = attendanceDAO.staffCheckIn(staffId);
                if (success) {
                    session.setAttribute("isCheckedIn", true);
                }
                out.write(success
                        ? "{\"status\":\"success\",\"message\":\"✅ Check-in thành công!\"}"
                        : "{\"status\":\"error\",\"message\":\"❌ Lỗi khi check-in.\"}");
            }
        } else if ("generate".equals(action)) {
            LocalDate nowDate = LocalDate.now();
            LocalDate firstDay = nowDate.withDayOfMonth(1);
            System.out.println("[DEBUG] Generating payroll for staffID = " + staffId);
            success = payrollDAO.generatePayroll(staffId, Date.valueOf(firstDay), Date.valueOf(nowDate));
            System.out.println("[DEBUG] Payroll generate success? " + success);

            if (success) {
                response.sendRedirect(request.getContextPath() + "/staff/dashboard");
                return;
            } else {
                out.write("{\"status\":\"error\",\"message\":\"⚠️ Có lỗi khi tính lương.\"}");
            }
        }
    }
}
