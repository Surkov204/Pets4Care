import dao.ShiftRequestDAO;
import dao.NotificationDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import model.ShiftRequest;

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

        // ✅ Lấy thông tin request từ DB
        ShiftRequest req = shiftDAO.getById(requestId);
        if (req == null) {
            session.setAttribute("errorMessage", "❌ Không tìm thấy yêu cầu #" + requestId);
            response.sendRedirect(request.getContextPath() + "/shift-request");
            return;
        }

        boolean success = false;

        // ✅ Phân nhánh xử lý
        if ("Swap".equalsIgnoreCase(req.getType())) {
            success = shiftDAO.swapShift(requestId);
        } else if ("Leave".equalsIgnoreCase(req.getType())) {
            success = shiftDAO.passShift(requestId);
        }

        // ✅ Gửi thông báo & phản hồi UI
        if (success) {
            notifyDAO.createForAdmin(
                    "✅ Duyệt yêu cầu " + req.getType(),
                    "Yêu cầu #" + requestId + " (" + req.getType() + ") đã được phê duyệt thành công."
            );
            session.setAttribute("successMessage", "✅ Đã phê duyệt thành công yêu cầu #" + requestId + " (" + req.getType() + ")");
        } else {
            session.setAttribute("errorMessage", "⚠️ Xử lý thất bại cho yêu cầu #" + requestId);
        }

        response.sendRedirect(request.getContextPath() + "/shift-request");
    }
}