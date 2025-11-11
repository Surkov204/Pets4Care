
import dao.ShiftRequestDAO;
import dao.NotificationDAO;
import dao.WorkScheduleDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.time.LocalDate;
import model.ShiftRequest;

@WebServlet("/admin/approveShiftRequest")
public class AdminApproveShiftRequestController extends HttpServlet {

    private final ShiftRequestDAO shiftDAO = new ShiftRequestDAO();
    private final NotificationDAO notifyDAO = new NotificationDAO();
    private final WorkScheduleDAO workDAO = new WorkScheduleDAO();

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

        boolean success = false;
        String type = req.getType();
        if ("Swap".equalsIgnoreCase(type)) {
            success = shiftDAO.swapShift(requestId);
        } else if ("Leave".equalsIgnoreCase(type)) {
            success = shiftDAO.passShift(requestId);
        } else if ("Cancel".equalsIgnoreCase(type)) {
            int staffId = req.getEmployeeID();
            int shiftId = req.getFromShiftID();
            LocalDate workDate = req.getFromDate().toLocalDate();
            success = workDAO.deleteScheduleByStaffShift(staffId, shiftId, workDate);
        } else if ("DoctorSwap".equalsIgnoreCase(type)) {
            success = workDAO.swapDoctorShifts(
                    req.getEmployeeID(),
                    req.getToStaffID(),
                    req.getFromDate(),
                    req.getToDate(),
                    req.getFromShiftID(),
                    req.getToShiftID()
            );
        } else if ("DoctorPass".equalsIgnoreCase(type)) {
            success = workDAO.reassignDoctorShift(
                    req.getEmployeeID(),
                    req.getToStaffID(),
                    req.getFromDate(),
                    req.getFromShiftID()
            );
        } else if ("DoctorCancel".equalsIgnoreCase(type)) {
            success = workDAO.deleteScheduleByDoctorShiftDate(
                    req.getEmployeeID(),
                    req.getFromShiftID(),
                    req.getFromDate().toLocalDate()
            );
        } else if ("DoctorRegister".equalsIgnoreCase(type)) {
            String shiftKey = resolveDoctorShiftKey(req.getFromShiftID());
            if (shiftKey != null) {
                success = workDAO.addScheduleForDoctor(
                        req.getEmployeeID(),
                        req.getFromDate().toLocalDate(),
                        shiftKey
                );
            }
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

    private String resolveDoctorShiftKey(int shiftId) {
        switch (shiftId) {
            case 1:
                return "morning";
            case 2:
                return "afternoon";
            case 3:
                return "evening";
            default:
                return null;
        }
    }
}
