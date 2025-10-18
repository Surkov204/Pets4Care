/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import java.util.ArrayList;
import java.util.List;
import model.Customer;
import utils.DBConnection;
import java.sql.*;
import utils.PasswordUtil;
import java.util.logging.Logger;

/**
 *
 * @author ASUS
 */
public class CustomerDAO implements ICustomerDAO {
    private static final Logger logger = Logger.getLogger(CustomerDAO.class.getName());

    @Override
    public List<Customer> getAllCustomers() {
        List<Customer> list = new ArrayList<>();
        String sql = "SELECT * FROM Customer";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Customer c = new Customer(
                        rs.getInt("customer_id"),
                        rs.getString("name"),
                        rs.getString("phone"),
                        rs.getString("email"),
                        rs.getString("password"),
                        rs.getString("google_id"),
                        rs.getString("address_Customer"),
                        rs.getString("status")
                );
                list.add(c);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    @Override
    public List<Customer> searchCustomers(String keyword) {
        List<Customer> list = new ArrayList<>();
        String sql = "SELECT * FROM Customer WHERE name LIKE ? OR email LIKE ?";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            String kw = "%" + keyword + "%";
            ps.setString(1, kw);
            ps.setString(2, kw);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Customer c = new Customer(
                            rs.getInt("customer_id"),
                            rs.getString("name"),
                            rs.getString("phone"),
                            rs.getString("email"),
                            rs.getString("password"),
                            rs.getString("google_id"),
                            rs.getString("address_Customer"),
                            rs.getString("status")
                    );
                    list.add(c);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    @Override
    public Customer getCustomerById(int customerId) {
        String sql = "SELECT * FROM Customer WHERE customer_id = ?";
        
        try (Connection conn = DBConnection.getConnection(); 
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, customerId);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new Customer(
                            rs.getInt("customer_id"),
                            rs.getString("name"),
                            rs.getString("phone"),
                            rs.getString("email"),
                            rs.getString("password"),
                            rs.getString("google_id"),
                            rs.getString("address_Customer"),
                            rs.getString("status")
                    );
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        
        return null;
    }
    
    public String getCustomerNameById(int customerId) throws SQLException {
        String sql = "SELECT name FROM Customer WHERE customer_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, customerId);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("name");
                }
            }
        }
        
        return null;
    }

    @Override
    public List<Customer> getCustomersByStatus(String status) {
        List<Customer> list = new ArrayList<>();
        String sql = "SELECT * FROM Customer WHERE status = ?";

        try (Connection conn = DBConnection.getConnection(); 
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, status);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Customer c = new Customer(
                            rs.getInt("customer_id"),
                            rs.getString("name"),
                            rs.getString("phone"),
                            rs.getString("email"),
                            rs.getString("password"),
                            rs.getString("google_id"),
                            rs.getString("address_Customer"),
                            rs.getString("status")
                    );
                    list.add(c);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    @Override
    public boolean updateCustomer(Customer customer) {
        String sql = "UPDATE Customer SET name = ?, phone = ?, email = ?, address_Customer = ?, status = ? WHERE customer_id = ?";
        
        try (Connection conn = DBConnection.getConnection(); 
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, customer.getName());
            ps.setString(2, customer.getPhone());
            ps.setString(3, customer.getEmail());
            ps.setString(4, customer.getAddressCustomer());
            ps.setString(5, customer.getStatus());
            ps.setInt(6, customer.getCustomerId());

            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        
        return false;
    }

    @Override
    public void updateStatus(int customerId, String status) {
    String sql = "UPDATE Customer SET status = ? WHERE customer_id = ?";

    try (Connection conn = DBConnection.getConnection();
         PreparedStatement ps = conn.prepareStatement(sql)) {
        ps.setString(1, status);
        ps.setInt(2, customerId);
        ps.executeUpdate();
    } catch (Exception e) {
        e.printStackTrace();
    }
}

    // lưu token thôi
    public void savePasswordResetToken(int customerId, String token) {
        String sql = "UPDATE Customer SET reset_token = ?, reset_token_expiry = ? WHERE customer_id = ?";

        try (Connection conn = DBConnection.getConnection(); 
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, token);
            ps.setTimestamp(2, new Timestamp(System.currentTimeMillis() + 3600000)); // Token hết hạn sau 1 giờ
            ps.setInt(3, customerId);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    // lấy mail
    public Customer getCustomerByEmail(String email) {
        String sql = "SELECT * FROM Customer WHERE email = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new Customer(
                            rs.getInt("customer_id"),
                            rs.getString("name"),
                            rs.getString("phone"),
                            rs.getString("email"),
                            rs.getString("password"),
                            rs.getString("google_id"),
                            rs.getString("address_Customer"),
                            rs.getString("status")
                    );
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
    
//---------------------------------------------------------------------------------
 
    
    // Lưu mã OTP và thời hạn (5 phút)
public void saveOTP(String email, String otp) {
    String sql = "UPDATE Customer SET otp_code = ?, otp_expiry = DATEADD(minute, 5, GETDATE()) WHERE email = ?";
    
    try (Connection conn = DBConnection.getConnection();
         PreparedStatement ps = conn.prepareStatement(sql)) {
        ps.setString(1, otp);
        ps.setString(2, email);
        ps.executeUpdate();
    } catch (SQLException e) {
        e.printStackTrace();
    }
}

// Kiểm tra mã OTP có hợp lệ không
public boolean verifyOTP(String email, String otp) {
    String sql = "SELECT 1 FROM Customer WHERE email = ? AND otp_code = ? AND otp_expiry > GETDATE()";
    
    try (Connection conn = DBConnection.getConnection();
         PreparedStatement ps = conn.prepareStatement(sql)) {
        ps.setString(1, email);
        ps.setString(2, otp);
        
        try (ResultSet rs = ps.executeQuery()) {
            return rs.next();
        }
    } catch (SQLException e) {
        e.printStackTrace();
        return false;
    }
}

public void clearOTP(String email) {
    String sql = "UPDATE Customer SET otp_code = NULL, otp_expiry = NULL WHERE email = ?";
    
    try (Connection conn = DBConnection.getConnection();
         PreparedStatement ps = conn.prepareStatement(sql)) {
        ps.setString(1, email);
        ps.executeUpdate();
    } catch (SQLException e) {
        e.printStackTrace();
    }
}
    
    
public boolean updatePassword(int customerId, String newPassword) {
    String hashedPassword = PasswordUtil.hashPassword(newPassword);  // Mã hóa mật khẩu mới
    String sql = "UPDATE Customer SET password = ? WHERE customer_id = ?";
    
    try (Connection conn = DBConnection.getConnection();
         PreparedStatement ps = conn.prepareStatement(sql)) {
        ps.setString(1, hashedPassword);
        ps.setInt(2, customerId);
        int rowsUpdated = ps.executeUpdate();
        return rowsUpdated > 0;  // Trả về true nếu thành công
    } catch (SQLException e) {
        e.printStackTrace();
        return false;  // Nếu có lỗi, trả về false
    }
}

// Đăng ký customer tạm thời với status "pending"
public boolean registerTempCustomer(Customer customer) {
    logger.info("=== BẮT ĐẦU REGISTER TEMP CUSTOMER ===");
    logger.info("Customer name: " + customer.getName());
    logger.info("Customer email: " + customer.getEmail());
    logger.info("Customer phone: " + customer.getPhone());
    logger.info("Customer address: " + customer.getAddressCustomer());
    
    String hashedPassword = PasswordUtil.hashPassword(customer.getPassword());
    logger.info("Password hashed successfully");
    
    String sql = "INSERT INTO Customer (name, phone, email, password, address_Customer, status) VALUES (?, ?, ?, ?, ?, ?)";
    logger.info("SQL query: " + sql);
    
    try (Connection conn = DBConnection.getConnection()) {
        if (conn == null) {
            logger.severe("KẾT NỐI DATABASE THẤT BẠI - Connection is null");
            return false;
        }
        logger.info("Kết nối database thành công");
        
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, customer.getName());
            ps.setString(2, customer.getPhone());
            ps.setString(3, customer.getEmail());
            ps.setString(4, hashedPassword);
            ps.setString(5, customer.getAddressCustomer());
            ps.setString(6, "pending");
            
            logger.info("PreparedStatement parameters set successfully");
            int rowsInserted = ps.executeUpdate();
            logger.info("Rows inserted: " + rowsInserted);
            
            boolean result = rowsInserted > 0;
            logger.info("Register temp customer result: " + result);
            return result;
        }
    } catch (SQLException e) {
        logger.severe("SQL EXCEPTION trong registerTempCustomer: " + e.getMessage());
        logger.severe("SQL State: " + e.getSQLState());
        logger.severe("Error Code: " + e.getErrorCode());
        e.printStackTrace();
        return false;
    } catch (Exception e) {
        logger.severe("GENERAL EXCEPTION trong registerTempCustomer: " + e.getMessage());
        e.printStackTrace();
        return false;
    }
}

// Xóa customer tạm thời nếu đăng ký thất bại
public boolean deleteTempCustomer(String email) {
    String sql = "DELETE FROM Customer WHERE email = ? AND status = 'pending'";
    
    try (Connection conn = DBConnection.getConnection();
         PreparedStatement ps = conn.prepareStatement(sql)) {
        ps.setString(1, email);
        int rowsDeleted = ps.executeUpdate();
        return rowsDeleted > 0;
    } catch (SQLException e) {
        e.printStackTrace();
        return false;
    }
}

// Kích hoạt tài khoản sau khi verify OTP thành công
public boolean activateCustomer(String email) {
    String sql = "UPDATE Customer SET status = 'active' WHERE email = ? AND status = 'pending'";
    
    try (Connection conn = DBConnection.getConnection();
         PreparedStatement ps = conn.prepareStatement(sql)) {
        ps.setString(1, email);
        int rowsUpdated = ps.executeUpdate();
        return rowsUpdated > 0;
    } catch (SQLException e) {
        e.printStackTrace();
        return false;
    }
}
    
}
