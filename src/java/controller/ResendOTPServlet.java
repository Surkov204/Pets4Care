package controller;

import dao.CustomerDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.Random;
import utils.EmailUtils;

@WebServlet("/resendotp")
public class ResendOTPServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        String email = (String) session.getAttribute("otpEmail");
        
        if (email == null) {
            session.setAttribute("message_forgotpass", "Phiên làm việc đã hết hạn");
            session.setAttribute("messageType", "error");
            response.sendRedirect("forgot-password.jsp");
            return;
        }
        
        try {
            CustomerDAO customerDAO = new CustomerDAO();
            // Tạo mã OTP mới 6 số
            String newOTP = String.format("%06d", new Random().nextInt(999999));
            
            // Lưu OTP mới vào database
            customerDAO.saveOTP(email, newOTP);
            
            // Gửi email chứa OTP mới
            boolean emailSent = EmailUtils.sendOTPEmail(
                email, 
                newOTP,
                customerDAO.getCustomerByEmail(email).getName()
            );
            
            if (emailSent) {
                session.setAttribute("message_verify", "Đã gửi lại mã OTP mới đến email của bạn");
                session.setAttribute("messageType", "success");
            } else {
                session.setAttribute("message_verify", "Gửi lại OTP thất bại. Vui lòng thử lại");
                session.setAttribute("messageType", "error");
            }
            
            response.sendRedirect("verify-otp.jsp");
            
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("message_verify", "Lỗi hệ thống: " + e.getMessage());
            session.setAttribute("messageType", "error");
            response.sendRedirect("verify-otp.jsp");
        }
    }
}