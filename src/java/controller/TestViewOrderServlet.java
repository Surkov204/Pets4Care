package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import dao.OrderDAO;
import model.Order;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

@WebServlet("/staff/test-vieworder")
public class TestViewOrderServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();
        
        try {
            OrderDAO orderDAO = new OrderDAO();
            List<Order> orders = orderDAO.getAllOrders();
            
            out.println("<html><head><title>Test View Order</title></head><body>");
            out.println("<h1>Test View Order - Total: " + orders.size() + "</h1>");
            
            if (orders.isEmpty()) {
                out.println("<p>Không có đơn hàng nào được tìm thấy 🐶</p>");
            } else {
                out.println("<table border='1' style='border-collapse: collapse; width: 100%;'>");
                out.println("<thead>");
                out.println("<tr><th>Order ID</th><th>Customer</th><th>Status</th><th>Total</th><th>Actions</th></tr>");
                out.println("</thead>");
                out.println("<tbody>");
                
                for (Order order : orders) {
                    out.println("<tr>");
                    out.println("<td>#" + order.getOrderId() + "</td>");
                    out.println("<td>" + (order.getCustomerName() != null ? order.getCustomerName() : "N/A") + "</td>");
                    out.println("<td>" + order.getStatus() + "</td>");
                    out.println("<td>" + order.getTotalAmount() + "</td>");
                    out.println("<td><a href='/Pets4Care/staff/orderDetail?id=" + order.getOrderId() + "'>View</a></td>");
                    out.println("</tr>");
                }
                
                out.println("</tbody>");
                out.println("</table>");
            }
            
            out.println("</body></html>");
            
        } catch (Exception e) {
            out.println("<html><head><title>Error</title></head><body>");
            out.println("<h1>Error: " + e.getMessage() + "</h1>");
            out.println("<pre>");
            e.printStackTrace(out);
            out.println("</pre>");
            out.println("</body></html>");
        }
    }
}
