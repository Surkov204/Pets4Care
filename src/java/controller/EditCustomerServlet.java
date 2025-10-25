package controller;

import dao.CustomerDAO;
import model.Admin;
import model.Customer;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet("/admin/edit-customer")
public class EditCustomerServlet extends HttpServlet {

    private CustomerDAO customerDAO = new CustomerDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Kiểm tra đăng nhập admin
        HttpSession session = request.getSession();
        Admin admin = (Admin) session.getAttribute("admin");
        if (admin == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        try {
            // Lấy ID khách hàng từ parameter
            String idParam = request.getParameter("id");
            if (idParam == null || idParam.trim().isEmpty()) {
                response.sendRedirect("manage-customer");
                return;
            }

            int customerId = Integer.parseInt(idParam);

            // Lấy thông tin khách hàng
            Customer customer = customerDAO.getCustomerById(customerId);
            if (customer == null) {
                request.setAttribute("error", "Không tìm thấy khách hàng");
                response.sendRedirect("manage-customer");
                return;
            }

            // Set attributes
            request.setAttribute("customer", customer);

            // Forward đến trang edit-customer.jsp
            request.getRequestDispatcher("/admin/edit-customer.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            response.sendRedirect("manage-customer");
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Có lỗi xảy ra: " + e.getMessage());
            response.sendRedirect("manage-customer");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Kiểm tra đăng nhập admin
        HttpSession session = request.getSession();
        Admin admin = (Admin) session.getAttribute("admin");
        if (admin == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        try {
            // Lấy thông tin từ form
            int customerId = Integer.parseInt(request.getParameter("customerId"));
            String name = request.getParameter("name");
            String phone = request.getParameter("phone");
            String address = request.getParameter("address");
            String status = request.getParameter("status");

            // Validate
            if (name == null || name.trim().isEmpty()) {
                request.setAttribute("error", "Tên khách hàng không được để trống");
                doGet(request, response);
                return;
            }

            if (phone == null || phone.trim().isEmpty() || phone.length() < 10 || phone.length() > 11) {
                request.setAttribute("error", "Số điện thoại không hợp lệ");
                doGet(request, response);
                return;
            }

            if (address == null || address.trim().isEmpty()) {
                request.setAttribute("error", "Địa chỉ không được để trống");
                doGet(request, response);
                return;
            }

            // Lấy thông tin khách hàng hiện tại
            Customer customer = customerDAO.getCustomerById(customerId);
            if (customer == null) {
                request.setAttribute("error", "Không tìm thấy khách hàng");
                response.sendRedirect("manage-customer");
                return;
            }

            // Cập nhật thông tin
            customer.setName(name.trim());
            customer.setPhone(phone.trim());
            customer.setAddressCustomer(address.trim());
            customer.setStatus(status);

            // Lưu vào database
            boolean success = customerDAO.updateCustomer(customer);

            if (success) {
                // Redirect về trang chi tiết với thông báo thành công
                response.sendRedirect("view-customer?id=" + customerId + "&success=true");
            } else {
                request.setAttribute("error", "Không thể cập nhật thông tin khách hàng");
                request.setAttribute("customer", customer);
                request.getRequestDispatcher("/admin/edit-customer.jsp").forward(request, response);
            }

        } catch (NumberFormatException e) {
            request.setAttribute("error", "Dữ liệu không hợp lệ");
            doGet(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Có lỗi xảy ra: " + e.getMessage());
            doGet(request, response);
        }
    }
}

