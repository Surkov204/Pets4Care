package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Customer;
import model.Staff;
import service.UserService;
import dao.CustomerDAO;
import dao.StaffDAO;
import utils.EmailUtils;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.logging.Logger;
import utils.DBConnection;

@WebServlet("/register")
public class RegisterServlet extends HttpServlet {
    private UserService userService = new UserService();
    private StaffDAO staffDAO = new StaffDAO();
    private static final Logger logger = Logger.getLogger(RegisterServlet.class.getName());

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Lấy thông tin từ form
        String name = request.getParameter("name");
        String phone = request.getParameter("phone");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String address = request.getParameter("address");
        String accountType = request.getParameter("accountType");

        // Log thông tin đầu vào
        logger.info("=== BẮT ĐẦU QUÁ TRÌNH ĐĂNG KÝ ===");
        logger.info("Name: " + name);
        logger.info("Phone: " + phone);
        logger.info("Email: " + email);
        logger.info("Address: " + address);
        logger.info("Account Type: " + accountType);
        logger.info("Password length: " + (password != null ? password.length() : "null"));

        // Validation input
        if (name == null || name.trim().isEmpty()) {
            logger.warning("Name is null or empty");
            request.setAttribute("error", "Tên không được để trống");
            forwardWithAttributes(request, response, name, phone, email, address);
            return;
        }
        if (phone == null || phone.trim().isEmpty()) {
            logger.warning("Phone is null or empty");
            request.setAttribute("error", "Số điện thoại không được để trống");
            forwardWithAttributes(request, response, name, phone, email, address);
            return;
        }
        if (email == null || email.trim().isEmpty()) {
            logger.warning("Email is null or empty");
            request.setAttribute("error", "Email không được để trống");
            forwardWithAttributes(request, response, name, phone, email, address);
            return;
        }
        if (password == null || password.trim().isEmpty()) {
            logger.warning("Password is null or empty");
            request.setAttribute("error", "Mật khẩu không được để trống");
            forwardWithAttributes(request, response, name, phone, email, address);
            return;
        }
        if (address == null || address.trim().isEmpty()) {
            logger.warning("Address is null or empty");
            request.setAttribute("error", "Địa chỉ không được để trống");
            forwardWithAttributes(request, response, name, phone, email, address);
            return;
        }

        try {
            // Xử lý theo loại tài khoản
            if ("customer".equals(accountType)) {
                handleCustomerRegistration(request, response, name, phone, email, password, address);
            } else if ("doctor".equals(accountType) || "staff".equals(accountType) || "admin".equals(accountType)) {
                handleStaffRegistration(request, response, name, phone, email, password, address, accountType);
            } else {
                logger.warning("Loại tài khoản không hợp lệ: " + accountType);
                request.setAttribute("error", "Loại tài khoản không hợp lệ");
                forwardWithAttributes(request, response, name, phone, email, address);
            }
        } catch (Exception e) {
            logger.severe("LỖI TRONG QUÁ TRÌNH ĐĂNG KÝ: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "Lỗi hệ thống: " + e.getMessage());
            forwardWithAttributes(request, response, name, phone, email, address);
        }
    }

    private void handleCustomerRegistration(HttpServletRequest request, HttpServletResponse response,
                                          String name, String phone, String email, String password, String address)
            throws ServletException, IOException {
        
        // Kiểm tra trùng lặp
        logger.info("Kiểm tra email trùng lặp...");
        boolean emailExists = false;
        try {
            emailExists = userService.checkEmailExists(email);
        } catch (Exception e) {
            logger.severe("Lỗi khi kiểm tra email exists: " + e.getMessage());
            request.setAttribute("error", "Lỗi kiểm tra email: " + e.getMessage());
            forwardWithAttributes(request, response, name, phone, email, address);
            return;
        }
        
        if (emailExists) {
            logger.warning("Email đã tồn tại: " + email);
            request.setAttribute("emailError", "Email đã tồn tại");
            forwardWithAttributes(request, response, name, phone, email, address);
            return;
        }
        logger.info("Email không trùng lặp - OK");

        logger.info("Kiểm tra số điện thoại trùng lặp...");
        boolean phoneExists = false;
        try {
            phoneExists = userService.checkPhoneExists(phone);
        } catch (Exception e) {
            logger.severe("Lỗi khi kiểm tra phone exists: " + e.getMessage());
            request.setAttribute("error", "Lỗi kiểm tra số điện thoại: " + e.getMessage());
            forwardWithAttributes(request, response, name, phone, email, address);
            return;
        }
        
        if (phoneExists) {
            logger.warning("Số điện thoại đã tồn tại: " + phone);
                request.setAttribute("phoneError", "Số điện thoại đã tồn tại");
                forwardWithAttributes(request, response, name, phone, email, address);
                return;
            }
        logger.info("Số điện thoại không trùng lặp - OK");

            // Tạo customer tạm thời với status "pending" để lưu vào database
        logger.info("Tạo đối tượng Customer tạm thời...");
            Customer tempCustomer = new Customer();
            tempCustomer.setName(name);
            tempCustomer.setPhone(phone);
            tempCustomer.setEmail(email);
            tempCustomer.setPassword(password);
            tempCustomer.setAddressCustomer(address);
            tempCustomer.setStatus("pending"); // Trạng thái chờ xác thực
        logger.info("Customer object created successfully");
            
            // Lưu customer tạm thời vào database
        logger.info("Bắt đầu lưu customer vào database...");
            CustomerDAO customerDAO = new CustomerDAO();
        boolean registerResult = customerDAO.registerTempCustomer(tempCustomer);
        logger.info("Kết quả lưu customer: " + registerResult);
        
        if (registerResult) {
            logger.info("Lưu customer thành công, bắt đầu tạo OTP...");
                // Tạo mã OTP 6 số ngẫu nhiên
                String otp = String.format("%06d", new java.util.Random().nextInt(999999));
            logger.info("OTP được tạo: " + otp);
                
                // Lưu OTP vào database
            logger.info("Lưu OTP vào database...");
            try {
                customerDAO.saveOTP(email, otp);
                logger.info("OTP đã được lưu vào database");
            } catch (Exception e) {
                logger.severe("Lỗi khi lưu OTP: " + e.getMessage());
                // Xóa customer tạm thời nếu lưu OTP thất bại
                customerDAO.deleteTempCustomer(email);
                request.setAttribute("error", "Lỗi lưu mã xác nhận: " + e.getMessage());
                forwardWithAttributes(request, response, name, phone, email, address);
                return;
            }
                
                // Gửi email chứa OTP
            logger.info("Bắt đầu gửi email OTP...");
            boolean emailSent = false;
            try {
                emailSent = EmailUtils.sendRegisterOTPEmail(email, otp, name);
                logger.info("Kết quả gửi email: " + emailSent);
            } catch (Exception e) {
                logger.severe("Lỗi khi gửi email: " + e.getMessage());
                emailSent = false;
            }
                
                if (emailSent) {
                logger.info("Email gửi thành công, chuyển hướng đến trang verify OTP");
                    HttpSession session = request.getSession();
                    session.setAttribute("otpEmail", email);
                    session.setAttribute("otpType", "register"); // Đánh dấu đây là OTP cho đăng ký
                    session.setAttribute("message_forgotpass", "Mã xác nhận đã được gửi đến email của bạn. Mã có hiệu lực trong 5 phút.");
                    session.setAttribute("messageType", "success");
                    response.sendRedirect("verify-otp.jsp");
                } else {
                logger.warning("Gửi email thất bại, xóa customer tạm thời");
                    // Xóa customer tạm thời nếu gửi email thất bại
                try {
                    customerDAO.deleteTempCustomer(email);
                } catch (Exception e) {
                    logger.severe("Lỗi khi xóa customer tạm thời: " + e.getMessage());
                }
                    request.setAttribute("error", "Đã có lỗi khi gửi email. Vui lòng thử lại sau.");
                    forwardWithAttributes(request, response, name, phone, email, address);
                }
            } else {
            logger.severe("Lưu customer vào database THẤT BẠI");
                request.setAttribute("error", "Đăng ký thất bại do lỗi hệ thống");
                forwardWithAttributes(request, response, name, phone, email, address);
            }
    }

    private void handleStaffRegistration(HttpServletRequest request, HttpServletResponse response,
                                       String name, String phone, String email, String password, 
                                       String address, String accountType)
            throws ServletException, IOException {
        
        logger.info("Bắt đầu đăng ký staff với loại: " + accountType);
        
        // Kiểm tra email đã tồn tại trong Staff
        Staff existingStaff = staffDAO.findByEmail(email);
        if (existingStaff != null) {
            logger.warning("Email staff đã tồn tại: " + email);
            request.setAttribute("error", "Email đã được sử dụng cho tài khoản staff");
            forwardWithAttributes(request, response, name, phone, email, address);
            return;
        }
        
        // Kiểm tra email đã tồn tại trong Customer
        boolean customerEmailExists = userService.checkEmailExists(email);
        if (customerEmailExists) {
            logger.warning("Email đã tồn tại trong customer: " + email);
            request.setAttribute("error", "Email đã được sử dụng cho tài khoản khách hàng");
            forwardWithAttributes(request, response, name, phone, email, address);
            return;
        }
        
        // Tạo staff mới
        Staff newStaff = new Staff();
        newStaff.setName(name);
        newStaff.setEmail(email);
        newStaff.setPhone(phone);
        newStaff.setPassword(password);
        
        // Chuyển đổi accountType thành position
        String position = "";
        switch (accountType) {
            case "doctor":
                position = "bác sĩ thú y";
                break;
            case "staff":
                position = "nhân viên";
                break;
            case "admin":
                position = "quản lý";
                break;
            default:
                position = "nhân viên";
        }
        newStaff.setPosition(position);
        
        logger.info("Tạo staff với position: " + position);
        
        // Lưu staff vào database (cần tạo method addStaff trong StaffDAO)
        boolean success = addStaff(newStaff);
        
        if (success) {
            logger.info("Đăng ký staff thành công: " + name);
            request.setAttribute("message_register", "Đăng ký tài khoản " + position + " thành công! Bạn có thể đăng nhập ngay.");
            request.setAttribute("messageType", "success");
            forwardWithAttributes(request, response, name, phone, email, address);
        } else {
            logger.severe("Đăng ký staff thất bại");
            request.setAttribute("error", "Đăng ký thất bại do lỗi hệ thống");
            forwardWithAttributes(request, response, name, phone, email, address);
        }
    }

    private boolean addStaff(Staff staff) {
        String sql = "INSERT INTO Staff (name, email, phone, password, position) VALUES (?, ?, ?, ?, ?)";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, staff.getName());
            ps.setString(2, staff.getEmail());
            ps.setString(3, staff.getPhone());
            ps.setString(4, staff.getPassword());
            ps.setString(5, staff.getPosition());
            
            int rowsAffected = ps.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException e) {
            logger.severe("Error adding staff: " + e.getMessage());
            e.printStackTrace();
            return false;
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