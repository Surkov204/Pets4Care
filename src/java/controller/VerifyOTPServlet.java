package controller;

import dao.CustomerDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/verifyotp")
public class VerifyOTPServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String otp = request.getParameter("otp");
        HttpSession session = request.getSession();
        String email = (String) session.getAttribute("otpEmail");
        
        if (email == null) {
            String otpType = (String) session.getAttribute("otpType");
            if ("register".equals(otpType)) {
                session.setAttribute("message_register", "Phiên làm việc đã hết hạn. Vui lòng đăng ký lại.");
                session.setAttribute("messageType", "error");
                response.sendRedirect("register.jsp");
            } else {
                session.setAttribute("message_forgotpass", "Phiên làm việc đã hết hạn. Vui lòng thực hiện lại.");
                session.setAttribute("messageType", "error");
                response.sendRedirect("forgot-password.jsp");
            }
            return;
        }
        
        CustomerDAO customerDAO = new CustomerDAO();
        boolean isValid = customerDAO.verifyOTP(email, otp);
        
        if (isValid) {
            // Xóa OTP sau khi xác thực thành công
            customerDAO.clearOTP(email);
            
            // Kiểm tra loại OTP (đăng ký hay reset password)
            String otpType = (String) session.getAttribute("otpType");
            
            if ("register".equals(otpType)) {
                // Xử lý đăng ký: Kích hoạt tài khoản
                if (customerDAO.activateCustomer(email)) {
                    // Tạo session mới để tránh fixation attack
                    session.invalidate();
                    HttpSession newSession = request.getSession(true);
                    newSession.setAttribute("message_register", "Đăng ký thành công! Vui lòng đăng nhập.");
                    newSession.setAttribute("messageType", "success");
                    response.sendRedirect("login.jsp?registerSuccess=true");
                } else {
                    session.setAttribute("message_verify", "Kích hoạt tài khoản thất bại. Vui lòng thử lại.");
                    session.setAttribute("messageType", "error");
                    response.sendRedirect("verify-otp.jsp");
                }
            } else {
                // Xử lý reset password (logic cũ)
                // Tạo session mới để tránh fixation attack
                session.invalidate();
                HttpSession newSession = request.getSession(true);
                newSession.setAttribute("verifiedEmail", email);
                
                response.sendRedirect("resetpassword.jsp");
            }
        } else {
            // Giữ nguyên session nhưng tăng số lần thử sai
            Integer attempt = (Integer) session.getAttribute("otpAttempt");
            if (attempt == null) attempt = 1;
            else attempt++;
            
            session.setAttribute("otpAttempt", attempt);
            
            if (attempt >= 3) {
                customerDAO.clearOTP(email);
                
                // Xử lý khác nhau tùy theo loại OTP
                String otpType = (String) session.getAttribute("otpType");
                if ("register".equals(otpType)) {
                    // Xóa customer tạm thời nếu nhập sai OTP quá 3 lần
                    customerDAO.deleteTempCustomer(email);
                    session.invalidate();
                    response.sendRedirect("register.jsp?error=max_attempt");
                } else {
                    session.invalidate();
                    response.sendRedirect("forgot-password.jsp?error=max_attempt");
                }
                return;
            }
            
            session.setAttribute("message_verify", "Mã OTP không đúng hoặc đã hết hạn. Bạn còn " + (3 - attempt) + " lần thử.");
            session.setAttribute("messageType", "error");
            response.sendRedirect("verify-otp.jsp");
        }
    }
}