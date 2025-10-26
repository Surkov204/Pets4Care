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

            if (last != null && last.getCheckOut() == null) {
                success = attendanceDAO.staffCheckOut(staffId);
                out.write(success
                        ? "{\"status\":\"success\",\"message\":\"✅ Checkout thành công! Nghỉ ngơi nhé.\"}"
                        : "{\"status\":\"error\",\"message\":\"❌ Lỗi khi checkout.\"}");
            } else {
                success = attendanceDAO.staffCheckIn(staffId);
                out.write(success
                        ? "{\"status\":\"success\",\"message\":\"✅ Check-in thành công!\"}"
                        : "{\"status\":\"error\",\"message\":\"❌ Lỗi khi check-in.\"}");
            }
        } else if ("generate".equals(action)) {
            LocalDate nowDate = LocalDate.now();
            LocalDate firstDay = nowDate.withDayOfMonth(1);
            success = payrollDAO.generatePayroll(staffId, Date.valueOf(firstDay), Date.valueOf(nowDate));
            out.write(success
                    ? "{\"status\":\"success\",\"message\":\"💰 Đã tính lương tháng này!\"}"
                    : "{\"status\":\"error\",\"message\":\"⚠️ Có lỗi khi tính lương.\"}");
        }
    }
}