package controller;

import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import model.CartItem;
import model.Customer;
import service.IOrderService;
import service.OrderService;
import utils.DBConnection;
import utils.EmailUtils;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.ResultSet;
import java.util.List;
import java.util.Map;

@WebServlet(urlPatterns = {"/orderservlet", "/admin/manage-order"})
public class OrderServlet extends HttpServlet {

    private final IOrderService orderService = new OrderService();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();

        Customer customer = (Customer) session.getAttribute("currentUser");
        if (customer == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        int customerId = customer.getCustomerId();
        int adminId = 1; // Mặc định đơn do admin 1 xử lý
        String paymentMethod = request.getParameter("payment_method");

        // Nhận địa chỉ và tọa độ từ form
        String address = request.getParameter("shipping_address");
        String latitude = request.getParameter("latitude");
        String longitude = request.getParameter("longitude");

        Double lat = (latitude != null && !latitude.isEmpty()) ? Double.valueOf(latitude) : null;
        Double lng = (longitude != null && !longitude.isEmpty()) ? Double.valueOf(longitude) : null;

        Map<Integer, CartItem> cart = (Map<Integer, CartItem>) session.getAttribute("cart");
        if (cart == null || cart.isEmpty()) {
            response.sendRedirect("cart/cart.jsp?error=empty_cart");
            return;
        }

        // Chuyển giỏ hàng thành JSON
        JsonArray itemsJson = new JsonArray();
        for (CartItem item : cart.values()) {
            JsonObject obj = new JsonObject();
            obj.addProperty("product_id", item.getProduct().getProductId());
            obj.addProperty("quantity", item.getQuantity());
            obj.addProperty("unit_price", item.getProduct().getPrice());
            itemsJson.add(obj);
        }

        try (Connection conn = DBConnection.getConnection()) {
            // Gọi stored procedure có 7 tham số
            CallableStatement cs = conn.prepareCall("{call AddOrder(?, ?, ?, ?, ?, ?, ?)}");
            cs.setInt(1, customerId);
            cs.setInt(2, adminId);
            cs.setString(3, paymentMethod);
            cs.setString(4, itemsJson.toString());
            cs.setString(5, address);
            cs.setObject(6, lat); // có thể là null
            cs.setObject(7, lng); // có thể là null

            boolean hasResult = cs.execute();
            int orderId = -1;

            if (hasResult) {
                try (ResultSet rs = cs.getResultSet()) {
                    if (rs.next()) {
                        orderId = rs.getInt("order_id");
                    }
                }
            }

            System.out.println("====== DEBUG ĐẶT HÀNG ======");
            System.out.println("Phương thức thanh toán: " + paymentMethod);
            System.out.println("Địa chỉ: " + address);
            System.out.println("Tọa độ: " + latitude + ", " + longitude);
            System.out.println("orderId: " + orderId);
            System.out.println("============================");

            if (orderId > 0) {
                // Gửi email xác nhận
                EmailUtils.sendOrderConfirmation(customer.getEmail(), orderId);

                session.removeAttribute("cart");

                String encodedMethod = java.net.URLEncoder.encode(paymentMethod, "UTF-8");
                response.sendRedirect("order/order-success.jsp?orderId=" + orderId + "&method=" + encodedMethod);
            } else {
                response.sendRedirect("cart/cart.jsp?error=order_failed");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("cart/cart.jsp?error=order_failed");
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();

        if ("/admin/manage-order".equals(path)) {
            String keyword = req.getParameter("keyword");
            String status = req.getParameter("status");

            List<model.Order> orders;

            if (keyword != null && !keyword.trim().isEmpty()) {
                orders = orderService.searchOrders(keyword);
            } else if (status != null && !"all".equals(status)) {
                orders = orderService.filterOrdersByStatus(status);
            } else {
                orders = orderService.getAllOrders();
            }

            req.setAttribute("orders", orders);
            req.setAttribute("keyword", keyword);
            req.setAttribute("status", status);
            req.getRequestDispatcher("/admin/manage-order.jsp").forward(req, resp);
        } else {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }
}

