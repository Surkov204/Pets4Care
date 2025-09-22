package controller;

import dao.CustomerDAO;
import model.Customer;
import utils.EmailUtils;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Timestamp;

@WebServlet("/forgotpasswordservlet")
public class ForgotPasswordServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    String email = request.getParameter("email");
    HttpSession session = request.getSession();
    
    try {
        CustomerDAO customerDAO = new CustomerDAO();
        Customer customer = customerDAO.getCustomerByEmail(email);

        if (customer != null) {
            // Tạo mã OTP 6 số ngẫu nhiên
            String otp = String.format("%06d", new java.util.Random().nextInt(999999));
            
            // Lưu OTP vào database
            customerDAO.saveOTP(email, otp);
            
            // Gửi email chứa OTP
            boolean emailSent = EmailUtils.sendOTPEmail(
                customer.getEmail(), 
                otp,
                customer.getName()
            );

            if (emailSent) {
                session.setAttribute("otpEmail", email);
                session.setAttribute("message_forgotpass", "Mã xác nhận đã được gửi đến email của bạn. Mã có hiệu lực trong 5 phút.");
                session.setAttribute("messageType", "success");
                response.sendRedirect("verify-otp.jsp");
            } else {
                session.setAttribute("message_forgotpass", "Đã có lỗi khi gửi email. Vui lòng thử lại sau.");
                session.setAttribute("messageType", "error");
                response.sendRedirect("forgot-password.jsp");
            }
        } else {
            session.setAttribute("message_forgotpass", "Email không tồn tại trong hệ thống.");
            session.setAttribute("messageType", "error");
            response.sendRedirect("forgot-password.jsp");
        }
    } catch (Exception e) {
        e.printStackTrace();
        session.setAttribute("message_forgotpass", "Đã xảy ra lỗi hệ thống.");
        session.setAttribute("messageType", "error");
        response.sendRedirect("forgot-password.jsp");
    }
}
}
    