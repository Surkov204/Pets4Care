package controller;

import dao.NotificationDAO;
import dao.ShiftRequestDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/staff/respondSwap")
public class RespondSwapController extends HttpServlet {

    private final ShiftRequestDAO dao = new ShiftRequestDAO();
    private final NotificationDAO notiDAO = new NotificationDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int requestId = Integer.parseInt(request.getParameter("id"));
        String action = request.getParameter("action");

        if ("accept".equals(action)) {
            dao.updateStatus(requestId, "AcceptedByTo", null);
            System.out.println("[SWAP] Người nhận đã CHẤP NHẬN yêu cầu.");

            notiDAO.createForAdmin(
                    "Yêu cầu đổi ca đã được chấp nhận",
                    "Nhân viên B đã chấp nhận đổi ca #" + requestId + ". Vui lòng phê duyệt."
            );

        } else {
            dao.updateStatus(requestId, "Rejected", null);
            System.out.println("[SWAP] Người nhận đã TỪ CHỐI yêu cầu.");
        }

        response.sendRedirect(request.getContextPath() + "/staff/dashboard");
    }
}
