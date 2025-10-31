package controller.staff;

import dao.PayrollDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;
import model.PayrollRecord;
import model.Staff;

@WebServlet("/staff/dashboard")
public class StaffDashboardController extends HttpServlet {

    private final PayrollDAO payrollDAO = new PayrollDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        Staff staff = (Staff) session.getAttribute("staff");

        // ✅ Kiểm tra đăng nhập
        if (staff == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        int staffId = staff.getStaffId();

        // ✅ Lấy danh sách phiếu lương
        List<PayrollRecord> payrollList = payrollDAO.getPayrollHistory(staffId);
        System.out.println("[DEBUG] Payroll list size = " + payrollList.size());
        request.setAttribute("payrollList", payrollList);

        // ✅ Chuyển tiếp sang dashboard.jsp
        request.getRequestDispatcher("/staff/dashboard.jsp").forward(request, response);
    }
}
