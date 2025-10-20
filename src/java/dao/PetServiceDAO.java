package dao;

import model.PetServiceModel;
import utils.DBConnection;

import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * PetServiceDAO implementation
 * @author ASUS
 */
public class PetServiceDAO {
    
    private static final java.util.logging.Logger logger = 
            java.util.logging.Logger.getLogger(PetServiceDAO.class.getName());

    // =========================
    // EXISTING METHODS
    // =========================
    
    public String getServiceNameById(int serviceId) throws SQLException {
        String sql = "SELECT name FROM PetService WHERE service_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, serviceId);
            
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("name");
                }
            }
        }
        
        return null;
    }
    
    public double getServicePriceById(int serviceId) throws SQLException {
        String sql = "SELECT price FROM PetService WHERE service_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, serviceId);
            
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getDouble("price");
                }
            }
        }
        
        return 0.0;
    }

    // =========================
    // NEW METHODS
    // =========================

    /**
     * Lấy tất cả dịch vụ
     */
    public List<PetServiceModel> getAllServices() {
        List<PetServiceModel> services = new ArrayList<>();
        String sql = "SELECT * FROM PetService ORDER BY service_type, name";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                PetServiceModel service = mapResultSetToPetService(rs);
                services.add(service);
            }
        } catch (SQLException e) {
            logger.severe("Error getting all services: " + e.getMessage());
            e.printStackTrace();
        }

        return services;
    }

    /**
     * Lấy dịch vụ theo ID
     */
    public PetServiceModel getServiceById(int serviceId) {
        String sql = "SELECT * FROM PetService WHERE service_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, serviceId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToPetService(rs);
                }
            }
        } catch (SQLException e) {
            logger.severe("Error getting service by ID: " + e.getMessage());
            e.printStackTrace();
        }

        return null;
    }

    /**
     * Lấy dịch vụ theo loại
     */
    public List<PetServiceModel> getServicesByType(String serviceType) {
        List<PetServiceModel> services = new ArrayList<>();
        String sql = "SELECT * FROM PetService WHERE service_type = ? ORDER BY name";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, serviceType);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    PetServiceModel service = mapResultSetToPetService(rs);
                    services.add(service);
                }
            }
        } catch (SQLException e) {
            logger.severe("Error getting services by type: " + e.getMessage());
            e.printStackTrace();
        }

        return services;
    }

    /**
     * Lấy dịch vụ đang hoạt động
     */
    public List<PetServiceModel> getActiveServices() {
        List<PetServiceModel> services = new ArrayList<>();
        String sql = "SELECT * FROM PetService WHERE status = 'active' ORDER BY service_type, name";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                PetServiceModel service = mapResultSetToPetService(rs);
                services.add(service);
            }
        } catch (SQLException e) {
            logger.severe("Error getting active services: " + e.getMessage());
            e.printStackTrace();
        }

        return services;
    }

    /**
     * Lấy dịch vụ đang hoạt động theo loại
     */
    public List<PetServiceModel> getActiveServicesByType(String serviceType) {
        List<PetServiceModel> services = new ArrayList<>();
        String sql = "SELECT * FROM PetService WHERE service_type = ? AND status = 'active' ORDER BY name";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, serviceType);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    PetServiceModel service = mapResultSetToPetService(rs);
                    services.add(service);
                }
            }
        } catch (SQLException e) {
            logger.severe("Error getting active services by type: " + e.getMessage());
            e.printStackTrace();
        }

        return services;
    }

    /**
     * Tìm kiếm dịch vụ theo tên
     */
    public List<PetServiceModel> searchServices(String keyword) {
        List<PetServiceModel> services = new ArrayList<>();
        String sql = "SELECT * FROM PetService WHERE name LIKE ? OR description LIKE ? ORDER BY name";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            String searchPattern = "%" + keyword + "%";
            ps.setString(1, searchPattern);
            ps.setString(2, searchPattern);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    PetServiceModel service = mapResultSetToPetService(rs);
                    services.add(service);
                }
            }
        } catch (SQLException e) {
            logger.severe("Error searching services: " + e.getMessage());
            e.printStackTrace();
        }

        return services;
    }

    /**
     * Thêm dịch vụ mới
     */
    public boolean addService(PetServiceModel service) {
        String sql = "INSERT INTO PetService (name, service_type, description, price, duration, status, created_at, updated_at) " +
                    "VALUES (?, ?, ?, ?, ?, ?, GETDATE(), GETDATE())";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setString(1, service.getName());
            ps.setString(2, service.getServiceType());
            ps.setString(3, service.getDescription());
            ps.setBigDecimal(4, service.getPrice());
            ps.setInt(5, service.getDuration());
            ps.setString(6, service.getStatus());

            int rows = ps.executeUpdate();
            if (rows > 0) {
                try (ResultSet keys = ps.getGeneratedKeys()) {
                    if (keys.next()) {
                        service.setServiceId(keys.getInt(1));
                    }
                }
                logger.info("Successfully added service: " + service.getName());
                return true;
            }
        } catch (SQLException e) {
            logger.severe("Error adding service: " + e.getMessage());
            e.printStackTrace();
        }

        return false;
    }

    /**
     * Cập nhật dịch vụ
     */
    public boolean updateService(PetServiceModel service) {
        String sql = "UPDATE PetService SET name = ?, service_type = ?, description = ?, price = ?, " +
                    "duration = ?, status = ?, updated_at = GETDATE() WHERE service_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, service.getName());
            ps.setString(2, service.getServiceType());
            ps.setString(3, service.getDescription());
            ps.setBigDecimal(4, service.getPrice());
            ps.setInt(5, service.getDuration());
            ps.setString(6, service.getStatus());
            ps.setInt(7, service.getServiceId());

            int rows = ps.executeUpdate();
            return rows > 0;
        } catch (SQLException e) {
            logger.severe("Error updating service: " + e.getMessage());
            e.printStackTrace();
        }

        return false;
    }

    /**
     * Cập nhật trạng thái dịch vụ
     */
    public boolean updateServiceStatus(int serviceId, String status) {
        String sql = "UPDATE PetService SET status = ?, updated_at = GETDATE() WHERE service_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, status);
            ps.setInt(2, serviceId);

            int rows = ps.executeUpdate();
            return rows > 0;
        } catch (SQLException e) {
            logger.severe("Error updating service status: " + e.getMessage());
            e.printStackTrace();
        }

        return false;
    }

    /**
     * Xóa dịch vụ
     */
    public boolean deleteService(int serviceId) {
        String sql = "DELETE FROM PetService WHERE service_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, serviceId);

            int rows = ps.executeUpdate();
            return rows > 0;
        } catch (SQLException e) {
            logger.severe("Error deleting service: " + e.getMessage());
            e.printStackTrace();
        }

        return false;
    }

    /**
     * Đếm số lượng dịch vụ theo loại
     */
    public int countServicesByType(String serviceType) {
        String sql = "SELECT COUNT(*) FROM PetService WHERE service_type = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, serviceType);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            logger.severe("Error counting services by type: " + e.getMessage());
            e.printStackTrace();
        }

        return 0;
    }

    /**
     * Lấy thống kê dịch vụ
     */
    public Map<String, Integer> getServiceStatistics() {
        Map<String, Integer> statistics = new HashMap<>();
        String sql = "SELECT service_type, COUNT(*) as count FROM PetService GROUP BY service_type ORDER BY count DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                statistics.put(rs.getString("service_type"), rs.getInt("count"));
            }
        } catch (SQLException e) {
            logger.severe("Error getting service statistics: " + e.getMessage());
            e.printStackTrace();
        }

        return statistics;
    }

    /**
     * Helper method để map ResultSet thành PetService object
     */
    private PetServiceModel mapResultSetToPetService(ResultSet rs) throws SQLException {
        PetServiceModel service = new PetServiceModel();
        service.setServiceId(rs.getInt("service_id"));
        service.setName(rs.getString("name"));
        service.setServiceType(rs.getString("service_type"));
        service.setDescription(rs.getString("description"));
        service.setPrice(rs.getBigDecimal("price"));
        service.setDuration(rs.getInt("duration"));
        service.setStatus(rs.getString("status"));
        service.setCreatedAt(rs.getTimestamp("created_at"));
        service.setUpdatedAt(rs.getTimestamp("updated_at"));
        // image_path không có trong schema nên bỏ qua
        // service.setImagePath(rs.getString("image_path"));
        return service;
    }
}
