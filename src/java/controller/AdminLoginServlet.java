package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Staff;
import dao.StaffDAO;

import java.io.IOException;
import java.util.logging.Logger;

@WebServlet("/admin-login")
public class AdminLoginServlet extends HttpServlet {
    private StaffDAO staffDAO = new StaffDAO();
    private static final Logger logger = Logger.getLogger(AdminLoginServlet.class.getName());

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Kiểm tra nếu đã đăng nhập
        HttpSession session = request.getSession();
        Staff staff = (Staff) session.getAttribute("staff");
        if (staff != null) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }
        
        request.getRequestDispatcher("login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String accountType = request.getParameter("accountType");
        
        logger.info("=== STAFF LOGIN ATTEMPT ===");
        logger.info("Email: " + email);
        logger.info("Account Type: " + accountType);
        logger.info("Password length: " + (password != null ? password.length() : "null"));
        
        // Validation
        if (email == null || email.trim().isEmpty()) {
            logger.warning("Email is null or empty");
            request.setAttribute("error", "Email không được để trống");
            request.getRequestDispatcher("login.jsp").forward(request, response);
            return;
        }
        
        if (password == null || password.trim().isEmpty()) {
            logger.warning("Password is null or empty");
            request.setAttribute("error", "Mật khẩu không được để trống");
            request.getRequestDispatcher("login.jsp").forward(request, response);
            return;
        }
        
        if (accountType == null || accountType.trim().isEmpty()) {
            logger.warning("Account type is null or empty");
            request.setAttribute("error", "Vui lòng chọn loại tài khoản");
            request.getRequestDispatcher("login.jsp").forward(request, response);
            return;
        }

        try {
            // Xác thực staff
            boolean isAuthenticated = staffDAO.authenticateStaff(email.trim(), password.trim());
            
            if (isAuthenticated) {
                // Lấy thông tin staff
                Staff staff = staffDAO.findByEmail(email.trim());
                
                if (staff != null) {
                    // Kiểm tra loại tài khoản có khớp không
                    boolean typeMatches = false;
                    switch (accountType) {
                        case "admin":
                            typeMatches = "quản lý".equalsIgnoreCase(staff.getPosition()) || 
                                        "admin".equalsIgnoreCase(staff.getPosition());
                            break;
                        case "staff":
                            typeMatches = "nhân viên".equalsIgnoreCase(staff.getPosition()) || 
                                        "staff".equalsIgnoreCase(staff.getPosition());
                            break;
                        case "doctor":
                            typeMatches = "bác sĩ thú y".equalsIgnoreCase(staff.getPosition()) || 
                                        "doctor".equalsIgnoreCase(staff.getPosition());
                            break;
                    }
                    
                    if (typeMatches) {
                        // Tạo session
                        HttpSession session = request.getSession();
                        session.setAttribute("staff", staff);
                        session.setAttribute("staffId", staff.getStaffId());
                        session.setAttribute("staffName", staff.getName());
                        session.setAttribute("staffPosition", staff.getPosition());
                        session.setAttribute("staffEmail", staff.getEmail());
                        
                        // Thêm thông báo đăng nhập thành công
                        session.setAttribute("loginSuccess", "Đăng nhập thành công! Chào mừng " + staff.getName());
                        
                        logger.info("Staff login successful: " + staff.getName() + " (" + staff.getPosition() + ")");
                        
                        // Chuyển hướng về trang home
                        response.sendRedirect(request.getContextPath() + "/home");
                    } else {
                        logger.warning("Account type mismatch. Expected: " + accountType + ", Actual: " + staff.getPosition());
                        request.setAttribute("error", "Loại tài khoản không khớp với thông tin đăng nhập");
                        request.getRequestDispatcher("login.jsp").forward(request, response);
                    }
                } else {
                    logger.warning("Staff not found: " + email);
                    request.setAttribute("error", "Không tìm thấy tài khoản staff");
                    request.getRequestDispatcher("login.jsp").forward(request, response);
                }
            } else {
                logger.warning("Invalid staff login credentials: " + email);
                request.setAttribute("error", "Email hoặc mật khẩu không đúng");
                request.getRequestDispatcher("login.jsp").forward(request, response);
            }
        } catch (Exception e) {
            logger.severe("Error during staff login: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "Lỗi hệ thống: " + e.getMessage());
            request.getRequestDispatcher("login.jsp").forward(request, response);
        }
    }
}
