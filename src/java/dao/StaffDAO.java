package dao;

import model.Staff;
import utils.DBConnection;
import java.sql.*;
import java.util.logging.Logger;

public class StaffDAO {
    private static final Logger logger = Logger.getLogger(StaffDAO.class.getName());

    public Staff findByEmail(String email) {
        String sql = "SELECT * FROM Staff WHERE email = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapStaffFromResultSet(rs);
                }
            }
        } catch (SQLException e) {
            logger.severe("Error finding staff by email: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }

    public Staff findById(int staffId) {
        String sql = "SELECT * FROM Staff WHERE staff_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, staffId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapStaffFromResultSet(rs);
                }
            }
        } catch (SQLException e) {
            logger.severe("Error finding staff by ID: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }

    public boolean authenticateStaff(String email, String password) {
        String sql = "SELECT * FROM Staff WHERE email = ? AND password = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, email);
            ps.setString(2, password);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            logger.severe("Error authenticating staff: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    public boolean hasPermission(int staffId, String requiredPosition) {
        String sql = "SELECT position FROM Staff WHERE staff_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, staffId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    String staffPosition = rs.getString("position");
                    // Admin có tất cả quyền
                    if ("admin".equalsIgnoreCase(staffPosition) || "quản lý".equalsIgnoreCase(staffPosition)) {
                        return true;
                    }
                    // Manager có quyền xem booking
                    if ("manager".equalsIgnoreCase(staffPosition) || "quản lý".equalsIgnoreCase(staffPosition)) {
                        return true;
                    }
                    // Staff chỉ có quyền cơ bản
                    if ("staff".equalsIgnoreCase(staffPosition) || "nhân viên".equalsIgnoreCase(staffPosition)) {
                        return true;
                    }
                }
            }
        } catch (SQLException e) {
            logger.severe("Error checking staff permission: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    private Staff mapStaffFromResultSet(ResultSet rs) throws SQLException {
        Staff staff = new Staff();
        staff.setStaffId(rs.getInt("staff_id"));
        staff.setName(rs.getString("name"));
        staff.setEmail(rs.getString("email"));
        staff.setPhone(rs.getString("phone"));
        staff.setPassword(rs.getString("password"));
        staff.setPosition(rs.getString("position"));
        return staff;
    }
}
