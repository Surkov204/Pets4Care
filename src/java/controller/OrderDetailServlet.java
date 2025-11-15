package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import dao.OrderDAO;
import dao.OrderDetailDAO;
import dao.CustomerDAO;
import dao.ProductDAO;
import dao.PetServiceDAO;
import model.Order;
import model.OrderDetail;
import model.Staff;

import java.io.IOException;
import java.util.List;

@WebServlet("/staff/orderDetail")
public class OrderDetailServlet extends HttpServlet {
    
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
            String orderIdStr = request.getParameter("id");
            if (orderIdStr == null || orderIdStr.trim().isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/staff/viewOrder");
                return;
            }
            
            int orderId = Integer.parseInt(orderIdStr);
            
            OrderDAO orderDAO = new OrderDAO();
            OrderDetailDAO orderDetailDAO = new OrderDetailDAO();
            CustomerDAO customerDAO = new CustomerDAO();
            ProductDAO productDAO = new ProductDAO();
            PetServiceDAO petServiceDAO = new PetServiceDAO();
            
            // Lấy thông tin đơn hàng
            Order order = orderDAO.getOrderById(orderId);
            if (order == null) {
                response.sendRedirect(request.getContextPath() + "/staff/viewOrder");
                return;
            }
            
            // Lấy thông tin khách hàng
            String customerName = customerDAO.getCustomerNameById(order.getCustomerId());
            order.setCustomerName(customerName);
            
            // Lấy chi tiết đơn hàng
            List<OrderDetail> orderDetails = orderDetailDAO.getOrderDetailsByOrderId(orderId);
            
            // Thêm thông tin sản phẩm và dịch vụ cho mỗi chi tiết
            for (OrderDetail detail : orderDetails) {
                if (detail.getProductId() != null) {
                    // Là sản phẩm
                    try {
                        String productName = productDAO.getProductNameById(detail.getProductId());
                        detail.setProductName(productName);
                    } catch (Exception e) {
                        detail.setProductName("Sản phẩm không xác định");
                    }
                } else if (detail.getServiceId() != null) {
                    // Là dịch vụ
                    try {
                        String serviceName = petServiceDAO.getServiceNameById(detail.getServiceId());
                        detail.setServiceName(serviceName);
                    } catch (Exception e) {
                        detail.setServiceName("Dịch vụ không xác định");
                    }
                }
            }
            
            request.setAttribute("order", order);
            request.setAttribute("orderDetails", orderDetails);
            
            request.getRequestDispatcher("/staff/orderDetail.jsp").forward(request, response);
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Có lỗi xảy ra khi tải chi tiết đơn hàng: " + e.getMessage());
            request.getRequestDispatcher("/staff/viewOrder.jsp").forward(request, response);
        }
    }
}