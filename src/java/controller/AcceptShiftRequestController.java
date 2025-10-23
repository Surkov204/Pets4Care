package controller;

import dao.ShiftRequestDAO;
import dao.NotificationDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import model.Staff;

@WebServlet("/staff/acceptShiftRequest")
public class AcceptShiftRequestController extends HttpServlet {

    private final ShiftRequestDAO shiftDAO = new ShiftRequestDAO();
    private final NotificationDAO notifyDAO = new NotificationDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("staff") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String idStr = request.getParameter("requestId");
        if (idStr == null || idStr.isEmpty()) {
            session.setAttribute("swapSuccess", "⚠️ Thiếu thông tin yêu cầu đổi ca.");
            response.sendRedirect(request.getContextPath() + "/staff/dashboard.jsp");
            return;
        }

        int requestId = Integer.parseInt(idStr);

        // ✅ B cập nhật trạng thái “AcceptedByTo” (chuẩn với DB)
        shiftDAO.updateStatus(requestId, "AcceptedByTo");

        // ✅ Lấy thông tin nhân viên hiện tại (người B)
        Staff staff = (Staff) session.getAttribute("staff");
        String staffName = (staff != null) ? staff.getName() : "Nhân viên không xác định";

        // ✅ Gửi thông báo cho admin để phê duyệt
        notifyDAO.createForAdmin(
            "Yêu cầu đổi ca chờ duyệt",
            staffName + " đã chấp nhận yêu cầu đổi ca #" + requestId + ". Vui lòng kiểm tra và phê duyệt."
        );

        // ✅ Báo kết quả cho người B
        session.setAttribute("swapSuccess", "✅ Bạn đã chấp nhận yêu cầu đổi ca. Chờ admin duyệt nhé!");

        // ✅ Redirect về dashboard
        response.sendRedirect(request.getContextPath() + "/staff/dashboard.jsp");
    }
}