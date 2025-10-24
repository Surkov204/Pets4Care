package controller.staff;

import dao.ShiftRequestDAO;
import dao.NotificationDAO;
import dao.WorkScheduleDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.Date;
import model.ShiftRequest;
import model.Staff;

@WebServlet("/staff/passShift")
public class PassShiftController extends HttpServlet {

    private final ShiftRequestDAO shiftDAO = new ShiftRequestDAO();
    private final WorkScheduleDAO workDAO = new WorkScheduleDAO();
    private final NotificationDAO notiDAO = new NotificationDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        Staff staff = (Staff) session.getAttribute("staff");

        if (staff == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        try {
            int staffId = staff.getStaffId();
            Date fromDate = Date.valueOf(request.getParameter("fromDate"));
            int fromShiftId = Integer.parseInt(request.getParameter("fromShiftId"));
            int toStaffId = Integer.parseInt(request.getParameter("toStaffId"));
            String reason = request.getParameter("reason");

            // ✅ Kiểm tra có ca đó thật không
            boolean hasShift = workDAO.hasShift(staffId, fromDate, fromShiftId);
            if (!hasShift) {
                session.setAttribute("errorMessage", "⚠️ Bạn không có ca đó để nhờ làm thay!");
                response.sendRedirect(request.getContextPath() + "/staff/mySchedule");
                return;
            }

            // ✅ Tạo yêu cầu “nhờ làm thay”
            ShiftRequest req = new ShiftRequest();
            req.setEmployeeID(staffId);
            req.setToStaffID(toStaffId);
            req.setType("Leave");               // ⚙️ Đổi lại từ "Extra" sang "Leave" cho đúng nghĩa “nhường ca”
            req.setFromDate(fromDate);
            req.setFromShiftID(fromShiftId);
            req.setReason(reason);
            req.setStatus("Pending");

            shiftDAO.addPassRequest(req);       // ✅ Gọi DAO đã fix có TargetDate

            // ✅ Gửi thông báo đến người được nhờ
            notiDAO.createNotification(
                    toStaffId,
                    "Yêu cầu làm thay",
                    staff.getName() + " nhờ bạn làm thay ca ngày " + fromDate + "."
            );

            session.setAttribute("successMessage", "📨 Gửi yêu cầu nhờ làm thay thành công!");
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("errorMessage", "❌ Lỗi khi gửi yêu cầu làm thay!");
        }

        response.sendRedirect(request.getContextPath() + "/staff/mySchedule");
    }
}