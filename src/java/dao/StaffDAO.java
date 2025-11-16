package dao;

import model.Staff;
import utils.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Logger;

public class StaffDAO {

    private static final Logger logger = Logger.getLogger(StaffDAO.class.getName());

    public Staff findByEmail(String email) {
        // Sử dụng LOWER để so sánh case-insensitive và TRIM để loại bỏ khoảng trắng
        String sql = "SELECT * FROM Staff WHERE LOWER(LTRIM(RTRIM(email))) = LOWER(LTRIM(RTRIM(?)))";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            String trimmedEmail = email != null ? email.trim() : "";
            ps.setString(1, trimmedEmail);
            
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

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

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
        // Sử dụng LOWER để so sánh case-insensitive và TRIM để loại bỏ khoảng trắng
        String sql = "SELECT * FROM Staff WHERE LOWER(LTRIM(RTRIM(email))) = LOWER(LTRIM(RTRIM(?))) AND password = ?";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            String trimmedEmail = email != null ? email.trim() : "";
            String trimmedPassword = password != null ? password.trim() : "";
            
            logger.info("Authenticating staff - Email: [" + trimmedEmail + "], Password length: " + trimmedPassword.length());
            
            ps.setString(1, trimmedEmail);
            ps.setString(2, trimmedPassword);
            
            try (ResultSet rs = ps.executeQuery()) {
                boolean found = rs.next();
                if (found) {
                    logger.info("Staff authentication successful for email: " + trimmedEmail);
                } else {
                    logger.warning("Staff authentication failed for email: " + trimmedEmail);
                    // Debug: Kiểm tra xem email có tồn tại không
                    String checkEmailSql = "SELECT email, password FROM Staff WHERE LOWER(LTRIM(RTRIM(email))) = LOWER(LTRIM(RTRIM(?)))";
                    try (PreparedStatement checkPs = conn.prepareStatement(checkEmailSql)) {
                        checkPs.setString(1, trimmedEmail);
                        try (ResultSet checkRs = checkPs.executeQuery()) {
                            if (checkRs.next()) {
                                String dbEmail = checkRs.getString("email");
                                String dbPassword = checkRs.getString("password");
                                logger.warning("Email exists but password mismatch. DB email: [" + dbEmail + "], DB password: [" + dbPassword + "]");
                            } else {
                                logger.warning("Email does not exist in database: " + trimmedEmail);
                            }
                        }
                    }
                }
                return found;
            }
        } catch (SQLException e) {
            logger.severe("Error authenticating staff: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    public boolean hasPermission(int staffId, String requiredPosition) {
        String sql = "SELECT position FROM Staff WHERE staff_id = ?";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

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
        // Avatar column không tồn tại trong bảng Staff, kiểm tra metadata trước khi đọc
        try {
            rs.findColumn("Avatar");
            staff.setAvatar(rs.getString("Avatar"));
        } catch (SQLException e) {
            // Cột Avatar không tồn tại, set null
            staff.setAvatar(null);
        }
        return staff;
    }

    public boolean updateStaff(Staff staff) {
        String sql = "UPDATE Staff SET name = ?, email = ?, phone = ?, password = ?, schedule_note = ? WHERE staff_id = ?";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, staff.getName());
            ps.setString(2, staff.getEmail());
            ps.setString(3, staff.getPhone());
            ps.setString(4, staff.getPassword());
            //    ps.setString(5, staff.getScheduleNote());
            ps.setInt(6, staff.getStaffId());

            int rowsAffected = ps.executeUpdate();
            return rowsAffected > 0;

        } catch (SQLException e) {
            logger.severe("Error updating staff: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    public Staff getStaffByEmail(String email) {
        String sql = "SELECT * FROM Staff WHERE email = ?";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapStaffFromResultSet(rs);
                }
            }
        } catch (SQLException e) {
            logger.severe("Error getting staff by email: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }

    public List<Staff> getAllStaff() {
        List<Staff> list = new ArrayList<>();
        String sql = "SELECT * FROM Staff ORDER BY staff_id DESC";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                list.add(mapStaffFromResultSet(rs));
            }
        } catch (SQLException e) {
            logger.severe("Error getting all staff: " + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }

    public List<Staff> getStaffByPosition(String position) {
        List<Staff> list = new ArrayList<>();
        String sql = "SELECT * FROM Staff WHERE LOWER(position) LIKE LOWER(?)";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, "%" + position + "%");
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapStaffFromResultSet(rs));
                }
            }
        } catch (SQLException e) {
            logger.severe("Error getting staff by position: " + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }

    public List<Staff> searchStaff(String keyword) {
        List<Staff> list = new ArrayList<>();
        String sql = """
        SELECT * FROM Staff 
        WHERE LOWER(name) LIKE LOWER(?) 
           OR LOWER(email) LIKE LOWER(?) 
           OR LOWER(phone) LIKE LOWER(?) 
           OR LOWER(position) LIKE LOWER(?) 
        ORDER BY staff_id DESC
        """;
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            String kw = "%" + keyword + "%";
            ps.setString(1, kw);
            ps.setString(2, kw);
            ps.setString(3, kw);
            ps.setString(4, kw);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapStaffFromResultSet(rs));
                }
            }
        } catch (SQLException e) {
            logger.severe("Error searching staff: " + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }

    public boolean deleteStaff(int staffId) {
        String sql = "DELETE FROM Staff WHERE staff_id = ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, staffId);
            int rows = ps.executeUpdate();
            return rows > 0;
        } catch (SQLException e) {
            logger.severe("Error deleting staff: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    public int countByPosition(String position) {
        String sql = "SELECT COUNT(*) FROM Staff WHERE LOWER(position) LIKE LOWER(?)";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, "%" + position + "%");
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            logger.severe("Error counting staff by position: " + e.getMessage());
            e.printStackTrace();
        }
        return 0;
    }
    public boolean updateProfile(Staff staff) {
        // Avatar column không tồn tại trong bảng Staff, không update cột này
        String sql = "UPDATE Staff SET name=?, email=?, phone=?, password=? WHERE staff_id=?";
        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, staff.getName());
            ps.setString(2, staff.getEmail());
            ps.setString(3, staff.getPhone());
            ps.setString(4, staff.getPassword());
            ps.setInt(5, staff.getStaffId());

            int rows = ps.executeUpdate();
            System.out.println("[StaffDAO] ✅ Updated rows: " + rows);
            return rows > 0;
        } catch (SQLException e) {
            System.err.println("[StaffDAO] ❌ updateProfile failed: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
}
