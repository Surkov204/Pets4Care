package controller;

import dao.StaffDAO;
import model.Admin;
import model.Staff;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet("/admin/view-staff")
public class ViewStaffServlet extends HttpServlet {

    private StaffDAO staffDAO = new StaffDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Kiểm tra đăng nhập admin
        HttpSession session = request.getSession();
        Admin admin = (Admin) session.getAttribute("admin");
        if (admin == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        try {
            // Lấy ID nhân viên từ parameter
            String idParam = request.getParameter("id");
            if (idParam == null || idParam.trim().isEmpty()) {
                response.sendRedirect("manage-staff");
                return;
            }

            int staffId = Integer.parseInt(idParam);

            // Lấy thông tin nhân viên
            Staff staff = staffDAO.findById(staffId);
            if (staff == null) {
                request.setAttribute("error", "Không tìm thấy nhân viên");
                response.sendRedirect("manage-staff");
                return;
            }

            // Set attributes
            request.setAttribute("staff", staff);

            // Forward đến trang view-staff.jsp
            request.getRequestDispatcher("/admin/view-staff.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            response.sendRedirect("manage-staff");
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Có lỗi xảy ra: " + e.getMessage());
            response.sendRedirect("manage-staff");
        }
    }
}

