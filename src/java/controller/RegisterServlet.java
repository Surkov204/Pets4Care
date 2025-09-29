package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Customer;
import service.UserService;

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

            // Tạo và đăng ký customer
            Customer customer = new Customer();
            customer.setName(name);
            customer.setPhone(phone);
            customer.setEmail(email);
            customer.setPassword(password);
            customer.setAddressCustomer(address);

            if (userService.registerCustomer(customer)) {
                response.sendRedirect("login.jsp?registerSuccess=true");
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