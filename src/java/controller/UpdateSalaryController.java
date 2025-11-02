package controller.admin;

import dao.StaffSalaryDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;

@WebServlet("/admin/updateSalary")
public class UpdateSalaryController extends HttpServlet {
    private final StaffSalaryDAO salaryDAO = new StaffSalaryDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();

        try {
            int staffId = Integer.parseInt(request.getParameter("staffId"));
            double newRate = Double.parseDouble(request.getParameter("hourlyRate"));

            boolean success = salaryDAO.updateHourlyRate(staffId, newRate);
            if (success) {
                out.write("{\"status\":\"success\",\"message\":\"💰 Cập nhật lương thành công!\"}");
            } else {
                out.write("{\"status\":\"error\",\"message\":\"❌ Không thể cập nhật lương.\"}");
            }
        } catch (Exception e) {
            e.printStackTrace();
            out.write("{\"status\":\"error\",\"message\":\"⚠️ Lỗi dữ liệu đầu vào.\"}");
        }
    }
}
