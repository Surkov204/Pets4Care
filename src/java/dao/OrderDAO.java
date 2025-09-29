package dao;

import model.Order;
import model.OrderDetail;
import model.OrderItem;
import model.OrderStats;
import utils.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class OrderDAO implements IOrderDAO {

    @Override
    public Order getOrderById(int orderId) {
        String sql = "SELECT o.*, c.name FROM [Order] o JOIN Customer c ON o.customer_id = c.customer_id WHERE o.order_id = ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, orderId);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                Order order = new Order();
                order.setOrderId(rs.getInt("order_id"));
                order.setOrderDate(rs.getTimestamp("order_date"));
                order.setCustomerId(rs.getInt("customer_id"));
                order.setStatus(rs.getString("status"));
                order.setTotalAmount(rs.getDouble("total_amount"));
                order.setAdminId(rs.getInt("admin_id"));
                order.setPaymentMethod(rs.getString("payment_method"));
                order.setPaymentStatus(rs.getString("payment_status"));
                order.setPaidAt(rs.getTimestamp("paid_at"));
                order.setCustomerName(rs.getString("name"));
                order.setShippingAddress(rs.getString("shipping_address"));
                order.setLatitude(rs.getObject("latitude") != null ? rs.getDouble("latitude") : null);
                order.setLongitude(rs.getObject("longitude") != null ? rs.getDouble("longitude") : null);
                // Thêm từ phiên bản mới
                return order;
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    @Override
    public List<OrderDetail> getOrderDetailsByOrderId(int orderId) {
        List<OrderDetail> list = new ArrayList<>();
        String sql = "SELECT * FROM Order_Detail WHERE order_id = ?";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, orderId);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                OrderDetail detail = new OrderDetail();
                detail.setDetailId(rs.getInt("detail_id"));
                detail.setOrderId(rs.getInt("order_id"));
                detail.setToyId(rs.getInt("toy_id"));
                detail.setQuantity(rs.getInt("quantity"));
                detail.setUnitPrice(rs.getDouble("unit_price"));
                list.add(detail);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    @Override
    public List<Order> getOrdersByCustomerId(int customerId) {
        List<Order> orders = new ArrayList<>();
        String sql = "SELECT * FROM [Order] WHERE customer_id = ?";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, customerId);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Order order = new Order();
                order.setOrderId(rs.getInt("order_id"));
                order.setOrderDate(rs.getTimestamp("order_date"));
                order.setCustomerId(rs.getInt("customer_id"));
                order.setStatus(rs.getString("status"));
                order.setTotalAmount(rs.getDouble("total_amount"));
                order.setPaymentMethod(rs.getString("payment_method"));
                order.setPaymentStatus(rs.getString("payment_status"));
                orders.add(order);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return orders;
    }

    @Override
    public OrderStats getOrderStatsByCustomerId(int customerId) {
        String sql = """
        SELECT COUNT(*) AS totalOrders,
               ISNULL(SUM(total_amount), 0) AS totalAmount,
               (
                   SELECT TOP 1 status
                   FROM [Order]
                   WHERE customer_id = ?
                   ORDER BY order_date DESC
               ) AS latestStatus
        FROM [Order]
        WHERE customer_id = ?
        """;

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, customerId);
            ps.setInt(2, customerId);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                return new OrderStats(
                        rs.getInt("totalOrders"),
                        rs.getDouble("totalAmount"),
                        rs.getString("latestStatus")
                );
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return new OrderStats(0, 0.0, "Không có đơn");
    }

    @Override
    public List<Order> getAllOrders() {
        List<Order> list = new ArrayList<>();
        String sql = "SELECT o.*, c.name AS customer_name FROM [Order] o JOIN Customer c ON o.customer_id = c.customer_id";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Order order = new Order();
                order.setOrderId(rs.getInt("order_id"));
                order.setOrderDate(rs.getTimestamp("order_date"));
                order.setCustomerId(rs.getInt("customer_id"));
                order.setStatus(rs.getString("status"));
                order.setTotalAmount(rs.getDouble("total_amount"));
                order.setPaymentMethod(rs.getString("payment_method"));
                order.setPaymentStatus(rs.getString("payment_status"));
                order.setCustomerName(rs.getString("customer_name"));
                list.add(order);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    @Override
    public List<Order> searchOrders(String keyword) {
        List<Order> list = new ArrayList<>();
        String sql = "SELECT o.*, c.name AS customer_name FROM [Order] o JOIN Customer c ON o.customer_id = c.customer_id "
                + "WHERE c.name LIKE ? OR o.order_id LIKE ?";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, "%" + keyword + "%");
            ps.setString(2, "%" + keyword + "%");

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Order order = new Order();
                order.setOrderId(rs.getInt("order_id"));
                order.setOrderDate(rs.getTimestamp("order_date"));
                order.setCustomerId(rs.getInt("customer_id"));
                order.setStatus(rs.getString("status"));
                order.setTotalAmount(rs.getDouble("total_amount"));
                order.setPaymentMethod(rs.getString("payment_method"));
                order.setPaymentStatus(rs.getString("payment_status"));
                order.setCustomerName(rs.getString("customer_name"));
                list.add(order);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    @Override
    public List<Order> filterByStatus(String status) {
        List<Order> list = new ArrayList<>();
        String sql = """
            SELECT o.*, c.name AS customer_name
            FROM [Order] o
            JOIN Customer c ON o.customer_id = c.customer_id
            WHERE o.status = ?
            """;

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, status);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Order order = new Order();
                order.setOrderId(rs.getInt("order_id"));
                order.setOrderDate(rs.getTimestamp("order_date"));
                order.setCustomerId(rs.getInt("customer_id"));
                order.setStatus(rs.getString("status"));
                order.setTotalAmount(rs.getDouble("total_amount"));
                order.setPaymentMethod(rs.getString("payment_method"));
                order.setPaymentStatus(rs.getString("payment_status"));
                order.setCustomerName(rs.getString("customer_name"));
                list.add(order);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    @Override
    public List<OrderItem> getOrderItems(int orderId) {
        List<OrderItem> list = new ArrayList<>();
        String sql = """
        SELECT oi.toy_id, t.name AS toy_name, oi.quantity, oi.unit_price
        FROM Order_Detail oi
        JOIN Toy t ON oi.toy_id = t.toy_id
        WHERE oi.order_id = ?
        """;

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, orderId);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                OrderItem item = new OrderItem();
                item.setToyId(rs.getInt("toy_id"));
                item.setToyName(rs.getString("toy_name"));
                item.setQuantity(rs.getInt("quantity"));
                item.setUnitPrice(rs.getDouble("unit_price"));
                item.getTotalPrice();
                list.add(item);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
    /////////////////
    ///
    ///
    /// @param orderId
    /// @param newStatus
    /// @return 
    ///
   
    @Override
public boolean updateOrderStatus(int orderId, String newStatus) {
    String sql = "UPDATE [Order] SET status = ? WHERE order_id = ?";
    
    try (Connection conn = DBConnection.getConnection();
         PreparedStatement ps = conn.prepareStatement(sql)) {
        
        ps.setString(1, newStatus);
        ps.setInt(2, orderId);
        
        int affectedRows = ps.executeUpdate();
        return affectedRows > 0;
        
    } catch (SQLException e) {
        e.printStackTrace();
        return false;
    }
}

}

