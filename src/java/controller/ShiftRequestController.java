package controller;

import dao.ShiftRequestDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.Date;
import java.util.List;
import model.ShiftRequest;

@WebServlet("/shift-request")
public class ShiftRequestController extends HttpServlet {

    private ShiftRequestDAO dao = new ShiftRequestDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        if (action == null || action.equals("list")) {
            // ✅ Hiển thị danh sách yêu cầu
            List<ShiftRequest> list = dao.getAllRequests();
            request.setAttribute("requestList", list);

            // 🔧 Sửa đúng đường dẫn tới JSP thật
            request.getRequestDispatcher("/admin/manageRequest.jsp").forward(request, response);
        }

        else if (action.equals("approve")) {
            int id = Integer.parseInt(request.getParameter("id"));
            dao.updateStatus(id, "approved", 1); // Giả sử admin ID = 1
            response.sendRedirect(request.getContextPath() + "/shift-request?action=list");
        }

        else if (action.equals("deny")) {
            int id = Integer.parseInt(request.getParameter("id"));
            dao.updateStatus(id, "denied", 1);
            response.sendRedirect(request.getContextPath() + "/shift-request?action=list");
        }

        else if (action.equals("delete")) {
            int id = Integer.parseInt(request.getParameter("id"));
            dao.deleteRequest(id);
            response.sendRedirect(request.getContextPath() + "/shift-request?action=list");
        }

        else if (action.equals("new")) {
            // ✅ Forward đến form thêm yêu cầu (nếu có)
            request.getRequestDispatcher("/admin/shiftRequestForm.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        // ✅ Lấy dữ liệu từ form
        ShiftRequest r = new ShiftRequest();
        r.setEmployeeID(Integer.parseInt(request.getParameter("employeeID")));
        r.setType(request.getParameter("type"));
        r.setTargetDate(Date.valueOf(request.getParameter("targetDate")));
        r.setFromShiftID(Integer.parseInt(request.getParameter("fromShiftID")));
        r.setToShiftID(Integer.parseInt(request.getParameter("toShiftID")));
        r.setReason(request.getParameter("reason"));
        r.setStatus("pending");
        r.setApprovedBy(null);

        dao.addRequest(r);

        // 🔁 Quay lại danh sách yêu cầu
        response.sendRedirect(request.getContextPath() + "/shift-request?action=list");
    }
}