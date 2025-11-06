package controller;

import dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/admin/updateRole")
public class UpdateRoleServlet extends HttpServlet {
    private UserDAO userDAO = new UserDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        int customerId = Integer.parseInt(req.getParameter("customerId"));
        String newRole = req.getParameter("role");

        boolean success = userDAO.updateRole(customerId, newRole);

        HttpSession session = req.getSession();
        if (success) {
            session.setAttribute("flashMessage", "✅ Cập nhật quyền thành công!");
        } else {
            session.setAttribute("flashMessage", "❌ Cập nhật quyền thất bại!");
        }

        // Redirect về lại trang manage-customer (load lại list mới)
        resp.sendRedirect(req.getContextPath() + "/admin/customer");
    }
}

