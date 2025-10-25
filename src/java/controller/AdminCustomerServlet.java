package controller;

import dao.CustomerDAO;
import dao.OrderDAO;
import model.Customer;
import model.OrderStats;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/admin/manage-customer")
public class AdminCustomerServlet extends HttpServlet {

    private CustomerDAO customerDAO = new CustomerDAO();
    private OrderDAO orderDAO = new OrderDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String keyword = request.getParameter("keyword");
        String statusFilter = request.getParameter("status");

        List<Customer> customers;

        // Lọc theo điều kiện
        if (keyword != null && !keyword.trim().isEmpty()) {
            customers = customerDAO.searchCustomers(keyword.trim());
        } else if (statusFilter != null && !"all".equals(statusFilter)) {
            customers = customerDAO.getCustomersByStatus(statusFilter);
        } else {
            customers = customerDAO.getAllCustomers();
        }

        // Lấy thống kê đơn hàng cho mỗi khách hàng
        Map<Integer, OrderStats> orderStats = new HashMap<>();
        for (Customer customer : customers) {
            OrderStats stats = orderDAO.getOrderStatsByCustomerId(customer.getCustomerId());
            orderStats.put(customer.getCustomerId(), stats);
        }

        // Đếm số khách hàng theo trạng thái
        int activeCount = customerDAO.getCustomersByStatus("active").size();
        int inactiveCount = customerDAO.getCustomersByStatus("inactive").size();

        request.setAttribute("customers", customers);
        request.setAttribute("orderStats", orderStats);
        request.setAttribute("activeCount", activeCount);
        request.setAttribute("inactiveCount", inactiveCount);
        request.setAttribute("keyword", keyword);
        request.setAttribute("statusFilter", statusFilter);

        request.getRequestDispatcher("/admin/manage-customer.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        if ("toggle-status".equals(action)) {
            int customerId = Integer.parseInt(request.getParameter("customerId"));
            String currentStatus = request.getParameter("currentStatus");

            // Đảo trạng thái
            String newStatus = "active".equals(currentStatus) ? "inactive" : "active";
            customerDAO.updateStatus(customerId, newStatus);
        }

        // Redirect về trang quản lý
        response.sendRedirect("manage-customer");
    }
}

