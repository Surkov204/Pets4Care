package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.logging.Logger;

@WebServlet("/staff/logout")
public class StaffLogoutServlet extends HttpServlet {
    private static final Logger logger = Logger.getLogger(StaffLogoutServlet.class.getName());

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session != null) {
            // Log thông tin đăng xuất
            String staffName = (String) session.getAttribute("staffName");
            logger.info("Staff logout: " + (staffName != null ? staffName : "Unknown"));
            
            // Xóa session
            session.invalidate();
        }
        
        // Chuyển hướng về trang đăng nhập
        response.sendRedirect(request.getContextPath() + "/staff/login");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
