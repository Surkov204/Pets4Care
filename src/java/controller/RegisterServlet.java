package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Customer;
import service.UserService;
import dao.CustomerDAO;
import utils.EmailUtils;

import java.io.IOException;

@WebServlet("/register")
public class RegisterServlet extends HttpServlet {
    private UserService userService = new UserService();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Lấy thông tin từ form
        String name = request.getParameter("name");
        String phone = request.getParameter("phone");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String address = request.getParameter("address");

        try {
            // Kiểm tra trùng lặp
            if (userService.checkEmailExists(email)) {
                request.setAttribute("emailError", "Email đã tồn tại");
                forwardWithAttributes(request, response, name, phone, email, address);
                return;
            }

            if (userService.checkPhoneExists(phone)) {
                request.setAttribute("phoneError", "Số điện thoại đã tồn tại");
                forwardWithAttributes(request, response, name, phone, email, address);
                return;
            }

            // Tạo customer tạm thời với status "pending" để lưu vào database
            Customer tempCustomer = new Customer();
            tempCustomer.setName(name);
            tempCustomer.setPhone(phone);
            tempCustomer.setEmail(email);
            tempCustomer.setPassword(password);
            tempCustomer.setAddressCustomer(address);
            tempCustomer.setStatus("pending"); // Trạng thái chờ xác thực
            
            // Lưu customer tạm thời vào database
            CustomerDAO customerDAO = new CustomerDAO();
            if (customerDAO.registerTempCustomer(tempCustomer)) {
                // Tạo mã OTP 6 số ngẫu nhiên
                String otp = String.format("%06d", new java.util.Random().nextInt(999999));
                
                // Lưu OTP vào database
                customerDAO.saveOTP(email, otp);
                
                // Gửi email chứa OTP
                boolean emailSent = EmailUtils.sendRegisterOTPEmail(email, otp, name);
                
                if (emailSent) {
                    HttpSession session = request.getSession();
                    session.setAttribute("otpEmail", email);
                    session.setAttribute("otpType", "register"); // Đánh dấu đây là OTP cho đăng ký
                    session.setAttribute("message_forgotpass", "Mã xác nhận đã được gửi đến email của bạn. Mã có hiệu lực trong 5 phút.");
                    session.setAttribute("messageType", "success");
                    response.sendRedirect("verify-otp.jsp");
                } else {
                    // Xóa customer tạm thời nếu gửi email thất bại
                    customerDAO.deleteTempCustomer(email);
                    request.setAttribute("error", "Đã có lỗi khi gửi email. Vui lòng thử lại sau.");
                    forwardWithAttributes(request, response, name, phone, email, address);
                }
            } else {
                request.setAttribute("error", "Đăng ký thất bại do lỗi hệ thống");
                forwardWithAttributes(request, response, name, phone, email, address);
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Lỗi hệ thống: " + e.getMessage());
            forwardWithAttributes(request, response, name, phone, email, address);
        }
    }

    private void forwardWithAttributes(HttpServletRequest request, HttpServletResponse response,
                                     String name, String phone, String email, String address)
            throws ServletException, IOException {
        request.setAttribute("nameValue", name);
        request.setAttribute("phoneValue", phone);
        request.setAttribute("emailValue", email);
        request.setAttribute("addressValue", address);
        request.getRequestDispatcher("register.jsp").forward(request, response);
    }
}