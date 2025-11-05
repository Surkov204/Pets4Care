package dao;

import java.sql.*;

public class SystemSettingDAO {

    private final String JDBC_URL = "jdbc:sqlserver://localhost:1433;databaseName=SHOP_PET_Database;encrypt=false";
    private final String USER = "sa";
    private final String PASSWORD = "12345";

    private Connection getConnection() throws SQLException {
        return DriverManager.getConnection(JDBC_URL, USER, PASSWORD);
    }

    // ✅ Lấy trạng thái cho phép đăng ký ca
    public boolean isShiftRegistrationEnabled() {
        String sql = "SELECT SettingValue FROM SystemSettings WHERE SettingKey = 'ShiftRegistration'";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return "ON".equalsIgnoreCase(rs.getString("SettingValue"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // ✅ Admin có thể bật/tắt đăng ký ca
    public void setShiftRegistration(boolean enabled) {
        String value = enabled ? "ON" : "OFF";
        String sql = "UPDATE SystemSettings SET SettingValue = ? WHERE SettingKey = 'ShiftRegistration'";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, value);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}
