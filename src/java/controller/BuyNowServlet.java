package controller;

import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import model.Customer;
import model.Product;
import utils.DBConnection;
import dao.ProductDAO;
import utils.EmailUtils;

@WebServlet(name = "BuyNowServlet", urlPatterns = { "/buynowservlet" })
public class BuyNowServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();

        Customer customer = (Customer) session.getAttribute("currentUser");
        if (customer == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        // Read buy-now params
        String productIdStr = request.getParameter("productId");
        String quantityStr = request.getParameter("quantity");
        String paymentMethod = request.getParameter("payment_method");
        String address = request.getParameter("shipping_address");

        if (productIdStr == null || quantityStr == null || paymentMethod == null || address == null
                || productIdStr.isEmpty() || quantityStr.isEmpty() || paymentMethod.isEmpty() || address.isEmpty()) {
            response.sendRedirect("toy/toy-detail.jsp?id=" + productIdStr + "&error=missing_params");
            return;
        }

        int productId = Integer.parseInt(productIdStr);
        int quantity = Math.max(1, Integer.parseInt(quantityStr));

        // Validate product exists and stock
        Product product = new ProductDAO().getProductById(productId);
        if (product == null || product.getStockQuantity() <= 0) {
            response.sendRedirect("toy/toy-detail.jsp?id=" + productId + "&error=invalid_product");
            return;
        }
        if (quantity > product.getStockQuantity()) {
            quantity = product.getStockQuantity();
        }

        int customerId = customer.getCustomerId();
        int adminId = 1; // default admin

        // Single-item order payload
        JsonArray itemsJson = new JsonArray();
        JsonObject obj = new JsonObject();
        obj.addProperty("toy_id", productId);
        obj.addProperty("quantity", quantity);
        obj.addProperty("unit_price", product.getPrice());
        itemsJson.add(obj);

        try (Connection conn = DBConnection.getConnection()) {
            CallableStatement cs = conn.prepareCall("{call AddOrder(?, ?, ?, ?, ?, ?, ?)}");
            cs.setInt(1, customerId);
            cs.setInt(2, adminId);
            cs.setString(3, paymentMethod);
            cs.setString(4, itemsJson.toString());
            cs.setString(5, address);
            cs.setObject(6, null); // latitude
            cs.setObject(7, null); // longitude

            boolean hasResult;
            int orderId = -1;
            try {
                hasResult = cs.execute();
                boolean more = hasResult;
                while (true) {
                    if (more) {
                        try (ResultSet rs = cs.getResultSet()) {
                            if (rs != null && rs.next()) {
                                try {
                                    orderId = rs.getInt("order_id");
                                } catch (SQLException ex) {
                                    orderId = rs.getInt(1);
                                }
                                break;
                            }
                        }
                    }
                    if (!cs.getMoreResults() && cs.getUpdateCount() == -1) {
                        break;
                    }
                    more = cs.getMoreResults();
                }
            } catch (SQLException ex) {
                ex.printStackTrace();
                session.setAttribute("orderError", "Lỗi khi tạo đơn: " + ex.getMessage());
            }

            if (orderId > 0) {
                // email confirmation
                EmailUtils.sendOrderConfirmation(customer.getEmail(), orderId);

                String encodedMethod = java.net.URLEncoder.encode(paymentMethod, "UTF-8");
                if ("PayOS".equals(paymentMethod)) {
                    response.sendRedirect(request.getContextPath() + "/payos/create-payment?orderId=" + orderId);
                } else {
                    response.sendRedirect("order/order-success.jsp?orderId=" + orderId + "&method=" + encodedMethod);
                }
            } else {
                if (session.getAttribute("orderError") == null) {
                    session.setAttribute("orderError", "Không thể tạo đơn hàng. Vui lòng thử lại sau.");
                }
                response.sendRedirect("toy/toy-detail.jsp?id=" + productId + "&error=order_failed");
            }

        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("orderError", "Lỗi hệ thống khi tạo đơn: " + e.getMessage());
            response.sendRedirect("toy/toy-detail.jsp?id=" + productId + "&error=order_failed");
        }
    }
}


