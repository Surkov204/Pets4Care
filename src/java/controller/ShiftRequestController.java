package controller;

import dao.ShiftRequestDAO;
import dao.WorkScheduleDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import model.ShiftRequest;

@WebServlet("/shift-request")
public class ShiftRequestController extends HttpServlet {

    private final ShiftRequestDAO reqDAO = new ShiftRequestDAO();
    private final WorkScheduleDAO workDAO = new WorkScheduleDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        String idParam = request.getParameter("id");

        if (action == null) {
            // ✅ Nếu không có action => load danh sách yêu cầu
            request.setAttribute("requestList", reqDAO.getAllRequests());
            request.getRequestDispatcher("/admin/manageRequest.jsp").forward(request, response);
            return;
        }

        // ✅ Nếu có action => xử lý duyệt hoặc từ chối
        try {
            int id = Integer.parseInt(idParam);
            ShiftRequest req = reqDAO.getById(id);

            if (req == null) {
                response.sendRedirect(request.getContextPath() + "/shift-request");
                return;
            }

            if ("approve".equalsIgnoreCase(action)) {
                // 🔁 Đổi ca thật trong WorkSchedule
                workDAO.swapShifts(
                        req.getEmployeeID(),
                        req.getToShiftID(),
                        req.getFromShiftID(),
                        req.getTargetDate().toLocalDate() // ⚠️ nếu bạn dùng java.sql.Date → .toLocalDate()
                );
                reqDAO.updateStatus(id, "ApprovedByAdmin", null);
                System.out.println("[ADMIN] ✅ Đã duyệt yêu cầu đổi ca #" + id);

            } else if ("deny".equalsIgnoreCase(action)) {
                reqDAO.updateStatus(id, "Rejected", null);
                System.out.println("[ADMIN] ❌ Đã từ chối yêu cầu đổi ca #" + id);
            }

            // Quay lại trang quản lý
            response.sendRedirect(request.getContextPath() + "/shift-request");

        } catch (NumberFormatException e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/shift-request");
        }
    }
}