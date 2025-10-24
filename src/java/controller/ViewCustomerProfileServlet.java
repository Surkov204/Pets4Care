package controller;

import dao.CustomerDAO;
import dao.OrderDAO;
import model.Admin;
import model.Customer;
import model.OrderStats;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet("/admin/view-customer")
public class ViewCustomerProfileServlet extends HttpServlet {

    private CustomerDAO customerDAO = new CustomerDAO();
    private OrderDAO orderDAO = new OrderDAO();

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

            // Lấy thống kê đơn hàng
            OrderStats orderStats = orderDAO.getOrderStatsByCustomerId(customerId);

            // Set attributes
            request.setAttribute("customer", customer);
            request.setAttribute("orderStats", orderStats);

            // Forward đến trang customer-profile.jsp
            request.getRequestDispatcher("/admin/customer-profile.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            response.sendRedirect("manage-customer");
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Có lỗi xảy ra: " + e.getMessage());
            response.sendRedirect("manage-customer");
        }
    }
}

