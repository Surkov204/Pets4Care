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
        String sql = "SELECT o.*, c.name FROM [Order] o LEFT JOIN Customer c ON o.customer_id = c.customer_id WHERE o.order_id = ?";
        try (Connection conn = DBConnection.getConnection(); 
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, orderId);
            
            try (ResultSet rs = ps.executeQuery()) {
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
                    // Bỏ qua shipping_address vì cột không tồn tại trong database
                    // order.setShippingAddress(rs.getString("shipping_address"));
                    // Bỏ qua latitude và longitude vì có thể không tồn tại
                    // order.setLatitude(rs.getObject("latitude") != null ? rs.getDouble("latitude") : null);
                    // order.setLongitude(rs.getObject("longitude") != null ? rs.getDouble("longitude") : null);
                    return order;
                }
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
                detail.setProductId(rs.getInt("product_id"));
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
        String sql = "SELECT o.*, c.name AS customer_name FROM [Order] o LEFT JOIN Customer c ON o.customer_id = c.customer_id";

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
        SELECT oi.product_id, p.name AS product_name, oi.quantity, oi.unit_price
        FROM Order_Detail oi
        JOIN Products p ON oi.product_id = p.product_id
        WHERE oi.order_id = ?
        """;

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, orderId);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                OrderItem item = new OrderItem();
                item.setProductId(rs.getInt("product_id"));
                item.setProductName(rs.getString("product_name"));
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

    public List<Order> getOrdersWithPagination(String customerName, String paymentStatus, int pageSize, int offset) {
        List<Order> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder();
        
        // Sử dụng TOP thay vì OFFSET/FETCH cho SQL Server cũ hơn
        if (offset == 0) {
            sql.append("SELECT TOP ").append(pageSize).append(" ");
        } else {
            sql.append("SELECT ");
        }
        
        sql.append("o.*, c.name AS customer_name FROM [Order] o ");
        sql.append("LEFT JOIN Customer c ON o.customer_id = c.customer_id ");
        sql.append("WHERE 1=1 ");
        
        List<Object> parameters = new ArrayList<>();
        
        if (customerName != null && !customerName.trim().isEmpty()) {
            sql.append("AND c.name LIKE ? ");
            parameters.add("%" + customerName.trim() + "%");
        }
        
        if (paymentStatus != null && !paymentStatus.trim().isEmpty()) {
            sql.append("AND o.payment_status = ? ");
            parameters.add(paymentStatus.trim());
        }
        
        sql.append("ORDER BY o.order_date DESC ");
        
        System.out.println("=== DEBUG: Final SQL Query ===");
        System.out.println("SQL: " + sql.toString());
        System.out.println("Parameters: " + parameters);
        System.out.println("Page Size: " + pageSize + ", Offset: " + offset);
        
        try (Connection conn = DBConnection.getConnection(); 
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            
            System.out.println("Database connection successful");
            
            int paramIndex = 1;
            for (Object param : parameters) {
                ps.setObject(paramIndex++, param);
            }
            
            try (ResultSet rs = ps.executeQuery()) {
                System.out.println("Query executed successfully");
                int count = 0;
                int skipped = 0;
                while (rs.next()) {
                    count++;
                    
                    // Skip rows if offset > 0
                    if (offset > 0 && skipped < offset) {
                        skipped++;
                        continue;
                    }
                    
                    // Stop if we have enough rows for this page
                    if (list.size() >= pageSize) {
                        break;
                    }
                    
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
                    order.setCustomerName(rs.getString("customer_name"));
                    // Bỏ qua shipping_address vì cột không tồn tại trong database
                    // order.setShippingAddress(rs.getString("shipping_address"));
                    // Bỏ qua latitude và longitude vì có thể không tồn tại
                    // order.setLatitude(rs.getObject("latitude") != null ? rs.getDouble("latitude") : null);
                    // order.setLongitude(rs.getObject("longitude") != null ? rs.getDouble("longitude") : null);
                    list.add(order);
                }
                System.out.println("Rows processed: " + count + ", Skipped: " + skipped + ", Added to list: " + list.size());
            }
        } catch (Exception e) {
            System.out.println("ERROR in getOrdersWithPagination: " + e.getMessage());
            e.printStackTrace();
        }
        
        System.out.println("Returning " + list.size() + " orders");
        System.out.println("=== END DEBUG ===");
        return list;
    }
    
    public int getTotalOrdersCount(String customerName, String paymentStatus) {
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT COUNT(*) FROM [Order] o ");
        sql.append("LEFT JOIN Customer c ON o.customer_id = c.customer_id ");
        sql.append("WHERE 1=1 ");
        
        List<Object> parameters = new ArrayList<>();
        
        if (customerName != null && !customerName.trim().isEmpty()) {
            sql.append("AND c.name LIKE ? ");
            parameters.add("%" + customerName.trim() + "%");
        }
        
        if (paymentStatus != null && !paymentStatus.trim().isEmpty()) {
            sql.append("AND o.payment_status = ? ");
            parameters.add(paymentStatus.trim());
        }
        
        System.out.println("=== DEBUG: Count SQL Query ===");
        System.out.println("Count SQL: " + sql.toString());
        System.out.println("Count Parameters: " + parameters);
        
        try (Connection conn = DBConnection.getConnection(); 
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            
            System.out.println("Count query - Database connection successful");
            
            int paramIndex = 1;
            for (Object param : parameters) {
                ps.setObject(paramIndex++, param);
            }
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int count = rs.getInt(1);
                    System.out.println("Total count result: " + count);
                    return count;
                }
            }
        } catch (Exception e) {
            System.out.println("ERROR in getTotalOrdersCount: " + e.getMessage());
            e.printStackTrace();
        }
        
        System.out.println("Returning 0 for total count");
        return 0;
    }

}

