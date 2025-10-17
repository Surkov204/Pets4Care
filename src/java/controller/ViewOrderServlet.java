package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import dao.OrderDAO;
import dao.CustomerDAO;
import model.Order;
import model.Staff;

import java.io.IOException;
import java.util.List;

@WebServlet("/staff/viewOrder")
public class ViewOrderServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        Staff staff = (Staff) session.getAttribute("staff");
        
        // Tạm thời comment authentication để test
        /*
        if (staff == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        */
        
        try {
            OrderDAO orderDAO = new OrderDAO();
            CustomerDAO customerDAO = new CustomerDAO();
            
            // Lấy tham số tìm kiếm
            String orderIdStr = request.getParameter("orderId");
            String customerName = request.getParameter("customerName");
            String status = request.getParameter("status");
            
            List<Order> orders = null;
            
            if (orderIdStr != null && !orderIdStr.trim().isEmpty()) {
                // Tìm theo Order ID
                try {
                    int orderId = Integer.parseInt(orderIdStr.trim());
                    Order order = orderDAO.getOrderById(orderId);
                    if (order != null) {
                        orders = List.of(order);
                    } else {
                        orders = List.of();
                    }
                } catch (NumberFormatException e) {
                    orders = List.of();
                }
            } else if (customerName != null && !customerName.trim().isEmpty()) {
                // Tìm theo tên khách hàng
                orders = orderDAO.searchOrders(customerName.trim());
            } else if (status != null && !status.trim().isEmpty()) {
                // Tìm theo trạng thái
                orders = orderDAO.filterByStatus(status.trim());
            } else {
                // Lấy tất cả đơn hàng
                orders = orderDAO.getAllOrders();
            }
            
            // Thông tin khách hàng đã được lấy từ getAllOrders() với JOIN
            // Không cần lấy lại từ CustomerDAO
            
            request.setAttribute("orders", orders);
            request.setAttribute("orderId", orderIdStr);
            request.setAttribute("customerName", customerName);
            request.setAttribute("status", status);
            
            request.getRequestDispatcher("/staff/viewOrder.jsp").forward(request, response);
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Có lỗi xảy ra khi tải dữ liệu đơn hàng: " + e.getMessage());
            request.getRequestDispatcher("/staff/viewOrder.jsp").forward(request, response);
        }
    }
}
