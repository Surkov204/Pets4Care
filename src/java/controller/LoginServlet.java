package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Cookie;
import model.Customer;
import service.UserService;

import java.io.IOException;


@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    private UserService userService = new UserService();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String rememberMe = request.getParameter("rememberMe");

        Customer customer = userService.loginCustomer(email, password);

        if (customer != null) {
            // Đăng nhập thành công
            HttpSession session = request.getSession();
            session.setAttribute("currentUser", customer);
            session.setAttribute("role", "customer");

            // Luôn lưu email để tiện lợi
            Cookie emailCookie = new Cookie("remembered_email", email);
            emailCookie.setMaxAge(30 * 24 * 60 * 60); // 30 ngày
            emailCookie.setPath("/");
            response.addCookie(emailCookie);

            // Xử lý Remember Me - chỉ lưu password khi được check
            if ("on".equals(rememberMe)) {
                // Tạo cookie cho password (30 ngày)
                Cookie passwordCookie = new Cookie("remembered_password", password);
                passwordCookie.setMaxAge(30 * 24 * 60 * 60); // 30 ngày
                passwordCookie.setPath("/");
                response.addCookie(passwordCookie);
                
                System.out.println("Remember Me enabled - password saved for: " + email);
            } else {
                // Xóa cookie password nếu không check Remember Me
                Cookie passwordCookie = new Cookie("remembered_password", "");
                passwordCookie.setMaxAge(0); // Xóa cookie ngay lập tức
                passwordCookie.setPath("/");
                response.addCookie(passwordCookie);
                
                System.out.println("Remember Me disabled - password removed for: " + email);
            }

            // Chuyển về home.jsp
            response.sendRedirect("home");
        } else {
            // Đăng nhập thất bại
            request.setAttribute("error", "Email hoặc mật khẩu không đúng.");
            request.getRequestDispatcher("login.jsp").forward(request, response);
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
