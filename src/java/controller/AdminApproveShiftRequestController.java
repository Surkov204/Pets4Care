package controller;

import dao.ShiftRequestDAO;
import dao.NotificationDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/admin/approveShiftRequest")
public class AdminApproveShiftRequestController extends HttpServlet {

    private final ShiftRequestDAO shiftDAO = new ShiftRequestDAO();
    private final NotificationDAO notifyDAO = new NotificationDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        String idStr = request.getParameter("id");
        
        if (idStr == null || idStr.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/shift-request");
            return;
        }

        int requestId = Integer.parseInt(idStr);
        boolean swapped = shiftDAO.swapShift(requestId);
        
        if (swapped) {
            notifyDAO.createForAdmin(
                    "✅ Đã phê duyệt đổi ca",
                    "Yêu cầu #" + requestId + " đã được admin phê duyệt và hoán đổi ca thành công."
            );
           // session.setAttribute("successMessage", "✅ Đổi ca thành công cho yêu cầu #" + requestId);
        } 
        response.sendRedirect(request.getContextPath() + "/shift-request");
    }
}
