package dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import model.CartItem;

import model.Customer;
import model.GoogleUser;
import model.Order;
import model.Toy;
import utils.DBConnection;
import utils.PasswordUtil;

public class UserDAO {

    public Customer loginCustomer(String email, String inputPassword) {
        String sql = "SELECT * FROM Customer WHERE email = ?";

        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, email);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    String storedPassword = rs.getString("password");
                    // Kiểm tra mật khẩu plain text
                    if (inputPassword.equals(storedPassword)) {
                        return mapCustomerFromResultSet(rs);
                    }
                }
            }
        } catch (SQLException ex) {
            System.err.println("Login error: " + ex.getMessage());
        }
        return null;
    }

    public boolean registerCustomer(Customer customer) {
        try (Connection con = DBConnection.getConnection()) {
            // Không mã hóa password
            String sql = "INSERT INTO Customer (name, phone, email, password, address_Customer) VALUES (?, ?, ?, ?, ?)";
            PreparedStatement ps = con.prepareStatement(sql);
            // Dùng setNString cho các trường có thể chứa Unicode
            ps.setNString(1, customer.getName());
            ps.setString(2, customer.getPhone());
            ps.setString(3, customer.getEmail());
            ps.setString(4, customer.getPassword()); // Lưu password plain text
            ps.setNString(5, customer.getAddressCustomer());

            int rows = ps.executeUpdate();
            return rows > 0;
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return false;
    }

    public Customer findOrCreateByGoogle(GoogleUser user) {
        try (Connection con = DBConnection.getConnection()) {
            PreparedStatement ps = con.prepareStatement(
                    "SELECT * FROM Customer WHERE google_id = ?");
            ps.setString(1, user.getId());
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                return new Customer(
                        rs.getInt("customer_id"),
                        rs.getNString("name"),
                        rs.getString("phone"),
                        rs.getString("email"),
                        rs.getString("password"),
                        rs.getString("google_id"),
                        rs.getNString("address_Customer"),
                        rs.getString("status")
                );
            }

            ps = con.prepareStatement(
                    "INSERT INTO Customer (name, email, google_id) VALUES (?, ?, ?)");
            ps.setNString(1, user.getName());
            ps.setString(2, user.getEmail());
            ps.setString(3, user.getId());
            ps.executeUpdate();

            return findOrCreateByGoogle(user);
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    public List<Order> getOrdersByCustomerId(int customerId) {
        List<Order> list = new ArrayList<>();
        String sql = "SELECT order_id, order_date, total_amount, status, payment_method, payment_status "
                + "FROM [Order] WHERE customer_id = ? ORDER BY order_date DESC";

        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, customerId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Order order = new Order();
                order.setOrderId(rs.getInt("order_id"));
                order.setOrderDate(rs.getTimestamp("order_date"));
                order.setTotalAmount(rs.getDouble("total_amount"));
                order.setStatus(rs.getString("status"));
                order.setPaymentMethod(rs.getString("payment_method"));
                order.setPaymentStatus(rs.getString("payment_status"));
                list.add(order);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public List<CartItem> getOrderDetails(int orderId) {
        List<CartItem> items = new ArrayList<>();

        String sql = "SELECT od.toy_id, od.quantity, od.unit_price, t.name, t.description "
                + "FROM Order_Detail od JOIN Toy t ON od.toy_id = t.toy_id "
                + "WHERE od.order_id = ?";

        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, orderId);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Toy toy = new Toy();
                toy.setToyId(rs.getInt("toy_id"));
                toy.setName(rs.getString("name"));
                toy.setDescription(rs.getString("description"));
                toy.setPrice(rs.getDouble("unit_price"));

                CartItem item = new CartItem(toy, rs.getInt("quantity"));
                items.add(item);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return items;
    }

    public Order getOrderById(int orderId) {
        Order order = null;
        String sql = "SELECT * FROM [Order] WHERE order_id = ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, orderId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                order = new Order();
                order.setOrderId(rs.getInt("order_id"));
                order.setOrderDate(rs.getTimestamp("order_date"));
                order.setTotalAmount(rs.getDouble("total_amount"));
                order.setStatus(rs.getString("status"));
                order.setPaymentMethod(rs.getString("payment_method"));
                order.setPaymentStatus(rs.getString("payment_status"));
                order.setPaidAt(rs.getTimestamp("paid_at"));
                order.setCustomerId(rs.getInt("customer_id"));
                order.setAdminId(rs.getInt("admin_id"));
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return order;
    }

    public boolean checkEmailExists(String email) {
        String sql = "SELECT COUNT(*) FROM Customer WHERE email = ?";

        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, email);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (SQLException ex) {
            System.err.println("Check email error: " + ex.getMessage());
        }
        return false;
    }

    public boolean checkPhoneExists(String phone) {
        String sql = "SELECT COUNT(*) FROM Customer WHERE phone = ?";
        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, phone);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return false;
    }

    public boolean resetPassword(String email, String newPassword) {
        String sql = "UPDATE Customer SET password = ? WHERE email = ?";

        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, newPassword); // Không mã hóa
            ps.setString(2, email);

            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            System.err.println("Reset password error: " + ex.getMessage());
        }
        return false;
    }

    private Customer mapCustomerFromResultSet(ResultSet rs) throws SQLException {
        Customer customer = new Customer();
        customer.setCustomerId(rs.getInt("customer_id"));
        customer.setName(rs.getNString("name"));
        customer.setEmail(rs.getString("email"));
        customer.setPassword(rs.getString("password"));
        customer.setAddressCustomer(rs.getNString("address_Customer"));
        customer.setPhone(rs.getString("phone"));
        customer.setStatus(rs.getString("status"));
        return customer;
    }

}
