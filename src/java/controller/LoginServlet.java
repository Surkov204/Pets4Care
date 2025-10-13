package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Cookie;
import model.Customer;
import model.Staff;
import model.Admin;
import service.UserService;
import dao.StaffDAO;
import dao.AdminDAO;

import java.io.IOException;
import java.util.logging.Logger;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    private UserService userService = new UserService();
    private StaffDAO staffDAO = new StaffDAO();
    private AdminDAO adminDAO = new AdminDAO();
    private static final Logger logger = Logger.getLogger(LoginServlet.class.getName());

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String rememberMe = request.getParameter("rememberMe");

        logger.info("Login attempt for email: " + email);

        // Validation
        if (email == null || email.trim().isEmpty() || password == null || password.trim().isEmpty()) {
            request.setAttribute("error", "Vui lòng nhập đầy đủ thông tin");
            request.getRequestDispatcher("login.jsp").forward(request, response);
            return;
        }

        try {
            // Ưu tiên xác thực Staff/Admin trước (qua bảng Staff và position)
            boolean isStaffAuthenticated = staffDAO.authenticateStaff(email.trim(), password.trim());
            if (isStaffAuthenticated) {
                Staff staff = staffDAO.findByEmail(email.trim());
                if (staff != null) {
                    handleStaffLogin(request, response, staff, email, rememberMe);
                    return;
                }
            }

            // Không phải Staff → kiểm tra Admin (bảng admin)
            Admin admin = adminDAO.loginByEmail(email.trim(), password.trim());
            if (admin == null) {
                // fallback: cho phép dùng username trong trường email (nếu admin nhập username)
                admin = adminDAO.login(email.trim(), password.trim());
            }
            if (admin != null) {
                handleAdminLogin(request, response, admin, email, rememberMe);
                return;
            }

            // Nếu không phải Staff/Admin, thử đăng nhập Customer
            Customer customer = userService.loginCustomer(email.trim(), password.trim());
            if (customer != null) {
                handleCustomerLogin(request, response, customer, email, rememberMe);
                return;
            }

            // Đăng nhập thất bại
            logger.warning("Login failed for email: " + email);
            request.setAttribute("error", "Email hoặc mật khẩu không đúng.");
            request.getRequestDispatcher("login.jsp").forward(request, response);

        } catch (Exception e) {
            logger.severe("Error during login: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "Có lỗi xảy ra trong quá trình đăng nhập");
            request.getRequestDispatcher("login.jsp").forward(request, response);
        }
    }

    private void handleAdminLogin(HttpServletRequest request, HttpServletResponse response,
                                  Admin admin, String email, String rememberMe)
            throws IOException {

        HttpSession session = request.getSession();
        session.setAttribute("admin", admin);
        session.setAttribute("role", "admin");
        session.setAttribute("adminId", admin.getAdmin_id());
        session.setAttribute("adminName", admin.getName());
        session.setAttribute("adminUsername", admin.getUsername());

        logger.info("Admin login successful: " + admin.getName() + " (" + admin.getUsername() + ")");

        handleRememberMe(response, email, rememberMe);

        response.sendRedirect(request.getContextPath() + "/admin/dashboard.jsp");
    }

    private void handleCustomerLogin(HttpServletRequest request, HttpServletResponse response, 
                                   Customer customer, String email, String rememberMe) 
                                   throws IOException {
        
        HttpSession session = request.getSession();
        session.setAttribute("currentUser", customer);
        session.setAttribute("role", "customer");
        session.setAttribute("userId", customer.getCustomerId());
        session.setAttribute("userName", customer.getName());

        logger.info("Customer login successful: " + customer.getName());

        // Xử lý Remember Me
        handleRememberMe(response, email, rememberMe);

        // Chuyển về trang chủ cho customer
        response.sendRedirect(request.getContextPath() + "/home");
    }

    private void handleStaffLogin(HttpServletRequest request, HttpServletResponse response, 
                                Staff staff, String email, String rememberMe) 
                                throws IOException {
        
        HttpSession session = request.getSession();
        session.setAttribute("staff", staff);
        String position = staff.getPosition() == null ? "" : staff.getPosition().toLowerCase();
        boolean isAdminRole = "admin".equals(position) || "quản lý".equals(position);
        session.setAttribute("role", isAdminRole ? "admin" : "staff");
        session.setAttribute("staffId", staff.getStaffId());
        session.setAttribute("staffName", staff.getName());
        session.setAttribute("staffPosition", staff.getPosition());

        logger.info("Staff login successful: " + staff.getName() + " (" + staff.getPosition() + ")");

        // Xử lý Remember Me
        handleRememberMe(response, email, rememberMe);

        // Chuyển hướng dựa trên role/position
        if (isAdminRole) {
            response.sendRedirect(request.getContextPath() + "/admin/dashboard.jsp");
            return;
        }
        String redirectUrl = determineStaffRedirectUrl(staff.getPosition());
        response.sendRedirect(request.getContextPath() + "/" + redirectUrl);
    }

    private String determineStaffRedirectUrl(String position) {
        switch (position.toLowerCase()) {
            case "admin":
            case "quản lý":
                return "staff/dashboard.jsp";
            case "staff":
            case "nhân viên":
                return "staff/bookings";
            case "doctor":
            case "bác sĩ thú y":
                return "staff/bookings";
            default:
                return "staff/bookings";
        }
    }

    private void handleRememberMe(HttpServletResponse response, String email, String rememberMe) {
        // Luôn lưu email để tiện lợi
        Cookie emailCookie = new Cookie("remembered_email", email);
        emailCookie.setMaxAge(30 * 24 * 60 * 60); // 30 ngày
        emailCookie.setPath("/");
        response.addCookie(emailCookie);

        // Xử lý Remember Me - chỉ lưu password khi được check
        if ("on".equals(rememberMe)) {
            // Tạo cookie cho password (30 ngày)
            Cookie passwordCookie = new Cookie("remembered_password", "");
            passwordCookie.setMaxAge(30 * 24 * 60 * 60); // 30 ngày
            passwordCookie.setPath("/");
            response.addCookie(passwordCookie);
            
            logger.info("Remember Me enabled for: " + email);
        } else {
            // Xóa cookie password nếu không check Remember Me
            Cookie passwordCookie = new Cookie("remembered_password", "");
            passwordCookie.setMaxAge(0); // Xóa cookie ngay lập tức
            passwordCookie.setPath("/");
            response.addCookie(passwordCookie);
            
            logger.info("Remember Me disabled for: " + email);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Kiểm tra cookies "remembered_email" và "remembered_password"
        Cookie[] cookies = request.getCookies();
        String rememberedEmail = null;
        String rememberedPassword = null;

        if (cookies != null) {
            for (Cookie cookie : cookies) {
                if (cookie.getName().equals("remembered_email")) {
                    rememberedEmail = cookie.getValue();
                }
                if (cookie.getName().equals("remembered_password")) {
                    rememberedPassword = cookie.getValue();
                }
            }
        }

        // Nếu có cookie nhớ đăng nhập thì tự động điền vào form
        if (rememberedEmail != null) {
            request.setAttribute("rememberedEmail", rememberedEmail);
            
            // Chỉ điền password nếu có và không rỗng
            if (rememberedPassword != null && !rememberedPassword.isEmpty()) {
                request.setAttribute("rememberedPassword", rememberedPassword);
            }
        }

        request.getRequestDispatcher("login.jsp").forward(request, response);
    }
}
