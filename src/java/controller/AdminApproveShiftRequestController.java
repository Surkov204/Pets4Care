
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
        String action = request.getParameter("action"); // ✅ đọc action (approve / reject)

        if (idStr == null || idStr.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/manage-staff.jsp");
            return;
        }

        int requestId = Integer.parseInt(idStr);
        ShiftRequest req = shiftDAO.getById(requestId);
        if (req == null) {
            session.setAttribute("errorMessage", "❌ Không tìm thấy yêu cầu #" + requestId);
            response.sendRedirect(request.getContextPath() + "/admin/manage-staff.jsp");
            return;
        }

        // ✅ Nếu admin bấm “Từ chối”
        if ("reject".equalsIgnoreCase(action)) {
            shiftDAO.updateStatus(requestId, "Rejected");
            notifyDAO.createForAdmin(
                    "❌ Từ chối yêu cầu " + req.getType(),
                    "Yêu cầu #" + requestId + " (" + req.getType() + ") đã bị từ chối bởi quản trị viên."
            );
            session.setAttribute("errorMessage", "❌ Đã từ chối yêu cầu #" + requestId);
            response.sendRedirect(request.getContextPath() + "/admin/manage-staff.jsp");
            return;
        }

        // ✅ Nếu admin bấm “Duyệt”
        boolean success = false;
        if ("Swap".equalsIgnoreCase(req.getType())) {
            success = shiftDAO.swapShift(requestId);
        } else if ("Leave".equalsIgnoreCase(req.getType())) {
            success = shiftDAO.passShift(requestId);
        }

        if (success) {
            shiftDAO.updateStatus(requestId, "Approved"); // cập nhật lại trạng thái gọn gàng
            notifyDAO.createForAdmin(
                    "✅ Duyệt yêu cầu " + req.getType(),
                    "Yêu cầu #" + requestId + " (" + req.getType() + ") đã được phê duyệt thành công."
            );
            session.setAttribute("successMessage",
                    "✅ Đã phê duyệt thành công yêu cầu #" + requestId + " (" + req.getType() + ")");
        } else {
            session.setAttribute("errorMessage", "⚠️ Xử lý thất bại cho yêu cầu #" + requestId);
        }

        response.sendRedirect(request.getContextPath() + "/admin/manage-staff.jsp");
    }
}