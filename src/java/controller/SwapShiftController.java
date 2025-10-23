package controller;

import dao.NotificationDAO;
import dao.ShiftRequestDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.Date;
import model.ShiftRequest;
import model.Staff;

@WebServlet("/staff/swapShift")
public class SwapShiftController extends HttpServlet {
    private final ShiftRequestDAO shiftDAO = new ShiftRequestDAO();
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

            // 🧭 Lấy dữ liệu từ form
            Date fromDate = Date.valueOf(request.getParameter("fromDate"));
            Date toDate = Date.valueOf(request.getParameter("toDate"));
            int fromShiftId = Integer.parseInt(request.getParameter("fromShiftId"));
            int toShiftId = Integer.parseInt(request.getParameter("toShiftId"));
            int toStaffId = Integer.parseInt(request.getParameter("toStaffId"));
            String reason = request.getParameter("reason");

            // 🧱 Tạo yêu cầu đổi ca
            ShiftRequest req = new ShiftRequest();
            req.setEmployeeID(staffId);
            req.setToStaffID(toStaffId);
            req.setType("Swap");
            req.setFromDate(fromDate);
            req.setToDate(toDate);
            req.setFromShiftID(fromShiftId);
            req.setToShiftID(toShiftId);
            req.setReason(reason);
            req.setStatus("Pending");

            // 💾 Lưu vào DB
            shiftDAO.addRequest(req);
            System.out.println("[SwapShiftController] ✅ Insert ShiftRequest thành công cho StaffID=" + staffId);

            // 🔔 Tạo thông báo cho người được đổi
            notiDAO.createNotification(
                toStaffId,
                "Yêu cầu đổi ca mới",
                "Nhân viên " + staff.getName() + " đã gửi yêu cầu đổi ca với bạn."
            );

            session.setAttribute("swapSuccess", "Yêu cầu đổi ca đã được gửi!");
            response.sendRedirect(request.getContextPath() + "/staff/mySchedule");

        } catch (Exception e) {
            System.err.println("[SwapShiftController] ❌ Lỗi khi gửi yêu cầu đổi ca:");
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/staff/mySchedule?error=true");
        }
    }
}