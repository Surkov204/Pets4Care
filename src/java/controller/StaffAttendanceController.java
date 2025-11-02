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
import java.util.List;
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
        boolean success = false;

        if ("toggle".equals(action)) {
            // ✅ Chỉ check shift khi toggle
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

            AttendanceRecord last = attendanceDAO.getLatestRecord(staffId);
            LocalTime nowTime = LocalTime.now();

            if (last != null && last.getCheckOut() == null) {
                success = attendanceDAO.staffCheckOut(staffId);
                if (success) {
                    session.setAttribute("isCheckedIn", false);
                }
                out.write(success
                        ? "{\"status\":\"success\",\"message\":\"✅ Checkout thành công! Nghỉ ngơi nhé.\"}"
                        : "{\"status\":\"error\",\"message\":\"❌ Lỗi khi checkout.\"}");
            } else if (last != null
                    && last.getCheckOut() != null
                    && last.getCheckIn().toLocalDateTime().toLocalDate().equals(LocalDate.now())
                    && nowTime.isAfter(currentShift.getStartTime().toLocalTime())
                    && nowTime.isBefore(currentShift.getEndTime().toLocalTime())) {
                out.write("{\"status\":\"error\",\"message\":\"⚠️ Bạn đã hoàn thành ca này, không thể check-in lại.\"}");
            } else {
                success = attendanceDAO.staffCheckIn(staffId);
                if (success) {
                    session.setAttribute("isCheckedIn", true);
                }
                out.write(success
                        ? "{\"status\":\"success\",\"message\":\"✅ Check-in thành công!\"}"
                        : "{\"status\":\"error\",\"message\":\"❌ Lỗi khi check-in.\"}");
            }

        } else if ("generate".equals(action)) {
            // ✅ KHÔNG kiểm tra shift hiện tại — chỉ cần tính lương theo tháng
            LocalDate nowDate = LocalDate.now();
            LocalDate firstDay = nowDate.withDayOfMonth(1);
            LocalDate lastDay = nowDate.withDayOfMonth(nowDate.lengthOfMonth()); // 👈 ngày cuối tháng

            System.out.println("[DEBUG] Generating payroll for staffID = " + staffId);
            success = payrollDAO.generatePayroll(
                    staffId,
                    Date.valueOf(firstDay),
                    Date.valueOf(lastDay) // 👈 truyền ngày cuối tháng
            );
            System.out.println("[DEBUG] Payroll generate success? " + success);

            if (success) {
                PayrollRecord latest = payrollDAO.getLatestPayroll(staffId);
                session.setAttribute("latestPayroll", latest);

                out.write("{\"status\":\"success\",\"message\":\"💰 Lương tháng này đã được tính thành công!\"}");
            } else {
                out.write("{\"status\":\"error\",\"message\":\"⚠️ Có lỗi khi tính lương.\"}");
            }
        }
    }
}
