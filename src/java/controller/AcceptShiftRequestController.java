package controller;

import dao.ShiftRequestDAO;
import dao.NotificationDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import model.ShiftRequest;
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
            session.setAttribute("swapSuccess", "⚠️ Thiếu thông tin yêu cầu ca.");
            response.sendRedirect(request.getContextPath() + "/staff/dashboard.jsp");
            return;
        }

        int requestId = Integer.parseInt(idStr);
        ShiftRequest req = shiftDAO.getById(requestId);
        if (req == null) {
            session.setAttribute("swapSuccess", "⚠️ Không tìm thấy yêu cầu này.");
            response.sendRedirect(request.getContextPath() + "/staff/dashboard.jsp");
            return;
        }

        Staff staff = (Staff) session.getAttribute("staff");
        String staffName = (staff != null) ? staff.getName() : "Nhân viên không xác định";

        // ✅ 1️⃣ Nếu là yêu cầu “Đổi ca”
        if ("Swap".equalsIgnoreCase(req.getType())) {
            shiftDAO.updateStatus(requestId, "AcceptedByTo");

            notifyDAO.createForAdmin(
                "Yêu cầu đổi ca chờ duyệt",
                staffName + " đã chấp nhận yêu cầu đổi ca #" + requestId + ". Vui lòng kiểm tra và phê duyệt."
            );

            session.setAttribute("swapSuccess", "✅ Bạn đã chấp nhận yêu cầu đổi ca. Chờ admin duyệt nhé!");
        }

        // ✅ 2️⃣ Nếu là yêu cầu “Pass ca”
        else if ("Pass".equalsIgnoreCase(req.getType())) {
            shiftDAO.updateStatus(requestId, "AcceptedByTo");

            notifyDAO.createForAdmin(
                "Yêu cầu pass ca chờ duyệt",
                staffName + " đã đồng ý nhận ca làm thay #" + requestId + ". Vui lòng kiểm tra và phê duyệt."
            );

            session.setAttribute("swapSuccess", "✅ Bạn đã đồng ý nhận ca làm thay. Chờ admin duyệt nhé!");
        }

        // ✅ Đánh dấu thông báo của nhân viên đã xử lý (nếu có)
        String notifyIdStr = request.getParameter("notificationId");
        if (notifyIdStr != null && !notifyIdStr.isEmpty()) {
            try {
                int notifyId = Integer.parseInt(notifyIdStr);
                notifyDAO.markAsHandled(notifyId);
            } catch (NumberFormatException e) {
                System.err.println("[AcceptShiftRequest] ⚠️ notificationId không hợp lệ: " + notifyIdStr);
            }
        }

        // ✅ Redirect về dashboard
        response.sendRedirect(request.getContextPath() + "/staff/dashboard.jsp");
    }
}