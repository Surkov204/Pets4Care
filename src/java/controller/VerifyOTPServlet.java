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
            session.setAttribute("message_forgotpass", "Phiên làm việc đã hết hạn. Vui lòng thực hiện lại.");
            session.setAttribute("messageType", "error");
            response.sendRedirect("forgot-password.jsp");
            return;
        }
        
        CustomerDAO customerDAO = new CustomerDAO();
        boolean isValid = customerDAO.verifyOTP(email, otp);
        
        if (isValid) {
            // Xóa OTP sau khi xác thực thành công
            customerDAO.clearOTP(email);
            
            // Tạo session mới để tránh fixation attack
            session.invalidate();
            HttpSession newSession = request.getSession(true);
            newSession.setAttribute("verifiedEmail", email);
            
            response.sendRedirect("resetpassword.jsp");
        } else {
            // Giữ nguyên session nhưng tăng số lần thử sai
            Integer attempt = (Integer) session.getAttribute("otpAttempt");
            if (attempt == null) attempt = 1;
            else attempt++;
            
            session.setAttribute("otpAttempt", attempt);
            
            if (attempt >= 3) {
                customerDAO.clearOTP(email);
                session.invalidate();
                response.sendRedirect("forgot-password.jsp?error=max_attempt");
                return;
            }
            
            session.setAttribute("message_verify", "Mã OTP không đúng hoặc đã hết hạn. Bạn còn " + (3 - attempt) + " lần thử.");
            session.setAttribute("messageType", "error");
            response.sendRedirect("verify-otp.jsp");
        }
    }
}