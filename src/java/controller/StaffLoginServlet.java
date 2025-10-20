package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import dao.StaffDAO;
import model.Staff;

import java.io.IOException;
import java.util.logging.Logger;

@WebServlet("/staff/login")
public class StaffLoginServlet extends HttpServlet {
    private StaffDAO staffDAO = new StaffDAO();
    private static final Logger logger = Logger.getLogger(StaffLoginServlet.class.getName());

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Kiểm tra nếu đã đăng nhập
        HttpSession session = request.getSession();
        Staff staff = (Staff) session.getAttribute("staff");
        if (staff != null) {
            response.sendRedirect(request.getContextPath() + "/staff/viewOrder");
            return;
        }
        
        response.sendRedirect(request.getContextPath() + "/login.jsp?tab=admin");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String email = request.getParameter("email");
        String password = request.getParameter("password");

        logger.info("Staff login attempt for email: " + email);

        // Validation
        if (email == null || email.trim().isEmpty() || password == null || password.trim().isEmpty()) {
            request.setAttribute("error", "Vui lòng nhập đầy đủ thông tin");
            response.sendRedirect(request.getContextPath() + "/login.jsp?tab=admin");
            return;
        }

        try {
            // Xác thực staff
            boolean isAuthenticated = staffDAO.authenticateStaff(email.trim(), password.trim());
            
            if (isAuthenticated) {
                // Lấy thông tin staff
                Staff staff = staffDAO.findByEmail(email.trim());
                
                if (staff != null) {
                    // Tạo session
                    HttpSession session = request.getSession();
                    session.setAttribute("staff", staff);
                    session.setAttribute("staffId", staff.getStaffId());
                    session.setAttribute("staffName", staff.getName());
                    session.setAttribute("staffPosition", staff.getPosition());
                    
                    logger.info("Staff login successful: " + staff.getName() + " (" + staff.getPosition() + ")");
                    
                    // Chuyển hướng đến trang viewOrder
                    response.sendRedirect(request.getContextPath() + "/staff/viewOrder");
                } else {
                    logger.warning("Staff not found: " + email);
                    request.setAttribute("error", "Không tìm thấy tài khoản staff");
                    response.sendRedirect(request.getContextPath() + "/login.jsp?tab=admin");
                }
            } else {
                logger.warning("Invalid staff login credentials: " + email);
                request.setAttribute("error", "Email hoặc mật khẩu không đúng");
                response.sendRedirect(request.getContextPath() + "/login.jsp?tab=admin");
            }
        } catch (Exception e) {
            logger.severe("Error during staff login: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "Có lỗi xảy ra trong quá trình đăng nhập");
            response.sendRedirect(request.getContextPath() + "/login.jsp?tab=admin");
        }
    }
}
