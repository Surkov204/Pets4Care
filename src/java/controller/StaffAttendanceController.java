package controller.staff;

import dao.AttendanceDAO;
import dao.PayrollDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.Date;
import java.time.LocalDate;
import java.util.List;
import model.AttendanceRecord;
import model.PayrollRecord;
import model.Staff;

@WebServlet("/staff/attendance")
public class StaffAttendanceController extends HttpServlet {

    private final AttendanceDAO attendanceDAO = new AttendanceDAO();
    private final PayrollDAO payrollDAO = new PayrollDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        Staff staff = (Staff) session.getAttribute("staff");
        if (staff == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        int staffId = staff.getStaffId();

        // Lấy lịch sử chấm công gần nhất của nhân viên
        AttendanceRecord lastRecord = new AttendanceDAO().getLatestRecord(staffId);
        boolean isCheckedIn = (lastRecord != null && lastRecord.getCheckOut() == null);

        // Gửi trạng thái cho JSP
        request.setAttribute("isCheckedIn", isCheckedIn);
        request.setAttribute("attendanceList", attendanceDAO.getAttendanceByStaff(staffId));
        request.setAttribute("payrollList", payrollDAO.getPayrollHistory(staffId));

        request.getRequestDispatcher("/staff/dashboard.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        Staff staff = (Staff) session.getAttribute("staff");
        if (staff == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        int staffId = staff.getStaffId();
        String action = request.getParameter("action");
        boolean success = false;

        if ("toggle".equals(action)) {
            // Nếu đang check in thì check out, ngược lại thì check in
            AttendanceRecord last = new AttendanceDAO().getLatestRecord(staffId);
            if (last != null && last.getCheckOut() == null) {
                success = attendanceDAO.staffCheckOut(staffId);
                session.setAttribute("attendanceMsg", "👋 Bạn đã kết thúc ca làm. Nghỉ ngơi nhé!");
            } else {
                success = attendanceDAO.staffCheckIn(staffId);
                session.setAttribute("attendanceMsg", "✅ Bắt đầu ca làm! Chúc bạn một ngày tốt lành!");
            }
        } else if ("generate".equals(action)) {
            LocalDate now = LocalDate.now();
            LocalDate firstDay = now.withDayOfMonth(1);
            success = payrollDAO.generatePayroll(staffId, Date.valueOf(firstDay), Date.valueOf(now));
            session.setAttribute("attendanceMsg", success
                    ? "💰 Đã tính lương tháng này!"
                    : "⚠️ Có lỗi khi tính lương.");
        }

        response.sendRedirect(request.getContextPath() + "/staff/attendance");
    }
}
