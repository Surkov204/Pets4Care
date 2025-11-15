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

// Quá sớm
            if (now.isBefore(earlyAllowed)) {
                out.write("{\"status\":\"error\",\"message\":\"⏰ Bạn đến quá sớm. Ca làm bắt đầu lúc " + start + "\"}");
                return;
            }

// Đi muộn
            boolean isLate = false;
            if (now.isAfter(lateAllowed) && now.isBefore(end)) {
                isLate = true;
            }

// Hết ca
            if (now.isAfter(end)) {
                out.write("{\"status\":\"error\",\"message\":\"⏰ Ca làm đã kết thúc.\"}");
                return;
            }

// Lấy record hôm nay
            AttendanceRecord today = attendanceDAO.getTodayRecord(staffId);

// CHECK-OUT
            if (today != null && today.getCheckOut() == null) {
                success = attendanceDAO.staffCheckOut(staffId);
                if (success) {
                    session.setAttribute("isCheckedIn", false);
                }

                out.write(success
                        ? "{\"status\":\"success\",\"message\":\"✅ Checkout thành công!\"}"
                        : "{\"status\":\"error\",\"message\":\"❌ Lỗi khi checkout.\"}");
                return;
            }

// Không cho check-in lại trong ngày
            if (today != null && today.getCheckOut() != null) {
                out.write("{\"status\":\"error\",\"message\":\"Bạn đã hoàn thành ca hôm nay.\"}");
                return;
            }

// CHECK-IN
            success = attendanceDAO.staffCheckIn(staffId, isLate);

            if (success) {
                session.setAttribute("isCheckedIn", true);
            }

            out.write(success
                    ? (isLate
                            ? "{\"status\":\"success\",\"message\":\"⏰ Đi muộn! Đã check-in.\"}"
                            : "{\"status\":\"success\",\"message\":\"✅ Check-in thành công!\"}")
                    : "{\"status\":\"error\",\"message\":\"❌ Lỗi khi check-in.\"}");
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
