package controller;

import dao.ShiftRequestDAO;
import dao.WorkScheduleDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import model.ShiftRequest;
import java.util.Locale;

@WebServlet("/admin/approveSwap")
public class ApproveSwapController extends HttpServlet {
    private final ShiftRequestDAO reqDAO = new ShiftRequestDAO();
    private final WorkScheduleDAO workDAO = new WorkScheduleDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        String action = request.getParameter("action");
        HttpSession session = request.getSession();
        Integer adminId = (Integer) session.getAttribute("adminId");

        ShiftRequest req = reqDAO.getById(id);
        if (req == null) {
            response.sendRedirect(request.getContextPath() + "/admin/shiftRequests");
            return;
        }

        if ("approve".equals(action)) {
            // ✅ Đổi ca thật trong bảng WorkSchedule
            workDAO.swapShifts(req.getEmployeeID(), req.getToShiftID(),
                    req.getFromShiftID(), req.getTargetDate().toLocalDate());
            reqDAO.updateStatus(id, "ApprovedByAdmin", adminId);
            System.out.println("[ADMIN] ✅ Phê duyệt đổi ca #" + id);
        } else {
            reqDAO.updateStatus(id, "Rejected", adminId);
            System.out.println("[ADMIN] ❌ Từ chối đổi ca #" + id);
        }

        response.sendRedirect(request.getContextPath() + "/admin/shiftRequests");
    }
}