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
            
            // Lấy tham số phân trang và filter
            String customerName = request.getParameter("customerName");
            String paymentStatus = request.getParameter("paymentStatus");
            String pageStr = request.getParameter("page");
            
            int currentPage = 1;
            if (pageStr != null && !pageStr.trim().isEmpty()) {
                try {
                    currentPage = Integer.parseInt(pageStr.trim());
                    if (currentPage < 1) currentPage = 1;
                } catch (NumberFormatException e) {
                    currentPage = 1;
                }
            }
            
            int pageSize = 10; // 10 mục mỗi trang
            int offset = (currentPage - 1) * pageSize;
            
            // Lấy danh sách đơn hàng với phân trang và filter
            List<Order> orders = orderDAO.getOrdersWithPagination(customerName, paymentStatus, pageSize, offset);
            
            // Lấy tổng số đơn hàng để tính số trang
            int totalOrders = orderDAO.getTotalOrdersCount(customerName, paymentStatus);
            int totalPages = (int) Math.ceil((double) totalOrders / pageSize);
            
            request.setAttribute("orders", orders);
            request.setAttribute("customerName", customerName);
            request.setAttribute("paymentStatus", paymentStatus);
            request.setAttribute("currentPage", currentPage);
            request.setAttribute("totalPages", totalPages);
            request.setAttribute("totalOrders", totalOrders);
            
            request.getRequestDispatcher("/staff/viewOrder.jsp").forward(request, response);
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Có lỗi xảy ra khi tải dữ liệu đơn hàng: " + e.getMessage());
            request.getRequestDispatcher("/staff/viewOrder.jsp").forward(request, response);
        }
    }
}
