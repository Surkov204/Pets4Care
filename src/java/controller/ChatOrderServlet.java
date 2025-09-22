package controller;
//đã sửa
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import model.CartItem;
import model.Customer;
import utils.DBConnection;
import utils.EmailUtils;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.ResultSet;
import java.util.Map;

@WebServlet("/chatorder")
public class ChatOrderServlet extends HttpServlet {

    @Override
    public void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        Customer customer = (Customer) session.getAttribute("currentUser");
        
        if (customer == null) {
            response.getWriter().write("❌ Vui lòng đăng nhập để đặt hàng.");
            return;
        }

        String paymentMethod = request.getParameter("payment_method");
        String address = request.getParameter("address");
        
        Map<Integer, CartItem> cart = (Map<Integer, CartItem>) session.getAttribute("cart");
        if (cart == null || cart.isEmpty()) {
            response.getWriter().write("❌ Giỏ hàng trống.");
            return;
        }

        // Lấy danh sách sản phẩm được chọn nếu có
        java.util.Set<Integer> selectedItems = (java.util.Set<Integer>) session.getAttribute("agentic_selected_items");
        Map<Integer, CartItem> filteredCart = cart;
        if (selectedItems != null && !selectedItems.isEmpty()) {
            filteredCart = new java.util.HashMap<>();
            for (Integer id : selectedItems) {
                if (cart.containsKey(id)) {
                    filteredCart.put(id, cart.get(id));
                }
            }
        }

        if (filteredCart.isEmpty()) {
            response.getWriter().write("❗ Bạn chưa chọn sản phẩm nào để đặt hàng.");
            return;
        }

        JsonArray itemsJson = new JsonArray();
        for (CartItem item : filteredCart.values()) {
            JsonObject obj = new JsonObject();
            obj.addProperty("toy_id", item.getToy().getToyId());
            obj.addProperty("quantity", item.getQuantity());
            obj.addProperty("unit_price", item.getToy().getPrice());
            itemsJson.add(obj);
        }

        try (Connection conn = DBConnection.getConnection()) {
            CallableStatement cs = conn.prepareCall("{call AddOrder(?, ?, ?, ?)}");
            cs.setInt(1, customer.getCustomerId());
            cs.setInt(2, 1); // adminId mặc định
            cs.setString(3, paymentMethod);
            cs.setString(4, itemsJson.toString());

            boolean hasResult = cs.execute();
            int orderId = -1;

            if (hasResult) {
                try (ResultSet rs = cs.getResultSet()) {
                    if (rs.next()) {
                        orderId = rs.getInt("order_id");
                    }
                }
            }

            if (orderId > 0) {
                // Gửi email xác nhận
                EmailUtils.sendOrderConfirmation(customer.getEmail(), orderId);
                
                // Xóa giỏ hàng
                session.removeAttribute("cart");
                
                // Xóa các thuộc tính agentic order
                session.removeAttribute("agentic_order_step");
                session.removeAttribute("agentic_selected_items");
                session.removeAttribute("agentic_order_address");
                session.removeAttribute("agentic_order_payment");
                
                response.getWriter().write("🎉 Đặt hàng thành công! Đã gửi xác nhận về email " + customer.getEmail());
            } else {
                response.getWriter().write("❌ Có lỗi khi đặt hàng. Vui lòng thử lại.");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().write("❌ Có lỗi khi đặt hàng: " + e.getMessage());
        }
    }
}