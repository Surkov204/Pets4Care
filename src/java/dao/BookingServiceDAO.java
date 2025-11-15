package dao;

import model.BookingServiceItem;
import utils.DBConnection;

import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * BookingServiceDAO implementation
 * Xử lý bảng trung gian Booking_Service
 * @author ASUS
 */
public class BookingServiceDAO {
    
    private static final java.util.logging.Logger logger = 
            java.util.logging.Logger.getLogger(BookingServiceDAO.class.getName());

    /**
     * Lấy tất cả chi tiết booking service
     */
    public List<BookingServiceItem> getAllBookingServices() {
        List<BookingServiceItem> bookingServices = new ArrayList<>();
        String sql = "SELECT bs.*, ps.name as service_name, ps.service_type, ps.duration as service_duration " +
                    "FROM Booking_Service bs " +
                    "LEFT JOIN PetService ps ON bs.service_id = ps.service_id " +
                    "ORDER BY bs.booking_id, bs.service_id";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                BookingServiceItem bookingService = mapResultSetToBookingService(rs);
                bookingServices.add(bookingService);
            }
        } catch (SQLException e) {
            logger.severe("Error getting all booking services: " + e.getMessage());
            e.printStackTrace();
        }

        return bookingServices;
    }

    /**
     * Lấy chi tiết booking service theo ID
     */
    public BookingServiceItem getBookingServiceById(int bookingServiceId) {
        String sql = "SELECT bs.*, ps.name as service_name, ps.service_type, ps.duration as service_duration " +
                    "FROM Booking_Service bs " +
                    "LEFT JOIN PetService ps ON bs.service_id = ps.service_id " +
                    "WHERE bs.booking_service_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, bookingServiceId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToBookingService(rs);
                }
            }
        } catch (SQLException e) {
            logger.severe("Error getting booking service by ID: " + e.getMessage());
            e.printStackTrace();
        }

        return null;
    }

    /**
     * Lấy chi tiết booking service theo booking ID
     */
    public List<BookingServiceItem> getBookingServicesByBookingId(int bookingId) {
        List<BookingServiceItem> bookingServices = new ArrayList<>();
        String sql = "SELECT bs.*, ps.name as service_name, ps.service_type, ps.duration as service_duration " +
                    "FROM Booking_Service bs " +
                    "LEFT JOIN PetService ps ON bs.service_id = ps.service_id " +
                    "WHERE bs.booking_id = ? " +
                    "ORDER BY bs.booking_id, bs.service_id";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, bookingId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    BookingServiceItem bookingService = mapResultSetToBookingService(rs);
                    bookingServices.add(bookingService);
                }
            }
        } catch (SQLException e) {
            logger.severe("Error getting booking services by booking ID: " + e.getMessage());
            e.printStackTrace();
        }

        return bookingServices;
    }

    /**
     * Lấy chi tiết booking service theo service ID
     */
    public List<BookingServiceItem> getBookingServicesByServiceId(int serviceId) {
        List<BookingServiceItem> bookingServices = new ArrayList<>();
        String sql = "SELECT bs.*, ps.name as service_name, ps.service_type, ps.duration as service_duration " +
                    "FROM Booking_Service bs " +
                    "LEFT JOIN PetService ps ON bs.service_id = ps.service_id " +
                    "WHERE bs.service_id = ? " +
                    "ORDER BY bs.booking_id, bs.service_id";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, serviceId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    BookingServiceItem bookingService = mapResultSetToBookingService(rs);
                    bookingServices.add(bookingService);
                }
            }
        } catch (SQLException e) {
            logger.severe("Error getting booking services by service ID: " + e.getMessage());
            e.printStackTrace();
        }

        return bookingServices;
    }

    /**
     * Thêm chi tiết booking service mới
     */
    public boolean addBookingService(BookingServiceItem bookingService) {
        // Hỗ trợ PK dạng (booking_id, service_id): nếu đã tồn tại thì cập nhật thay vì lỗi trùng khóa
        final String SQL_EXISTS = "SELECT 1 FROM Booking_Service WHERE booking_id = ? AND service_id = ?";
        final String SQL_INSERT = "INSERT INTO Booking_Service (booking_id, service_id, quantity, unit_price, duration_min, created_at, note) VALUES (?, ?, ?, ?, ?, ?, ?)";
        final String SQL_UPDATE = "UPDATE Booking_Service SET quantity = quantity + ?, unit_price = ?, duration_min = ?, note = ? WHERE booking_id = ? AND service_id = ?";

        try (Connection conn = DBConnection.getConnection()) {
            logger.info("=== addBookingService START ===");
            logger.info("Booking ID: " + bookingService.getBookingId() + ", Service ID: " + bookingService.getServiceId());
            
            boolean exists = false;
            try (PreparedStatement chk = conn.prepareStatement(SQL_EXISTS)) {
                chk.setInt(1, bookingService.getBookingId());
                chk.setInt(2, bookingService.getServiceId());
                try (ResultSet rs = chk.executeQuery()) { 
                    exists = rs.next(); 
                }
            }
            logger.info("Record exists: " + exists);

            if (!exists) {
                try (PreparedStatement ps = conn.prepareStatement(SQL_INSERT)) {
                    java.sql.Timestamp createdAt = bookingService.getCreatedAt();
                    if (createdAt == null) {
                        createdAt = new java.sql.Timestamp(System.currentTimeMillis());
                        bookingService.setCreatedAt(createdAt);
                    }

                    ps.setInt(1, bookingService.getBookingId());
                    ps.setInt(2, bookingService.getServiceId());
                    ps.setInt(3, Math.max(1, bookingService.getQuantity()));
                    ps.setBigDecimal(4, bookingService.getPrice() != null ? bookingService.getPrice() : java.math.BigDecimal.ZERO);
                    if (bookingService.getServiceDuration() > 0) {
                        ps.setInt(5, bookingService.getServiceDuration());
                    } else {
                        ps.setNull(5, java.sql.Types.INTEGER);
                    }
                    ps.setTimestamp(6, createdAt);
                    ps.setString(7, bookingService.getNote() != null ? bookingService.getNote() : "");
                    
                    logger.info("Executing INSERT with values: bookingId=" + bookingService.getBookingId() + 
                               ", serviceId=" + bookingService.getServiceId() + 
                               ", quantity=" + Math.max(1, bookingService.getQuantity()) + 
                               ", price=" + (bookingService.getPrice() != null ? bookingService.getPrice() : java.math.BigDecimal.ZERO) + 
                               ", duration=" + bookingService.getServiceDuration() + 
                               ", createdAt=" + createdAt);
                    
                    int rows = ps.executeUpdate();
                    if (rows > 0) {
                        logger.info("=== addBookingService SUCCESS ===");
                        logger.info("Successfully added booking service: booking_id=" + bookingService.getBookingId() + ", service_id=" + bookingService.getServiceId());
                        return true;
                    } else {
                        logger.warning("INSERT executed but no rows affected");
                    }
                } catch (SQLException insertEx) {
                    logger.severe("SQL Exception during INSERT: " + insertEx.getMessage());
                    logger.severe("SQL State: " + insertEx.getSQLState());
                    logger.severe("Error Code: " + insertEx.getErrorCode());
                    insertEx.printStackTrace();
                    throw insertEx; // Re-throw to be caught by outer catch
                }
            } else {
                try (PreparedStatement ps = conn.prepareStatement(SQL_UPDATE)) {
                    ps.setInt(1, Math.max(1, bookingService.getQuantity()));
                    ps.setBigDecimal(2, bookingService.getPrice() != null ? bookingService.getPrice() : java.math.BigDecimal.ZERO);
                    if (bookingService.getServiceDuration() > 0) {
                        ps.setInt(3, bookingService.getServiceDuration());
                    } else {
                        ps.setNull(3, java.sql.Types.INTEGER);
                    }
                    ps.setString(4, bookingService.getNote() != null ? bookingService.getNote() : "");
                    ps.setInt(5, bookingService.getBookingId());
                    ps.setInt(6, bookingService.getServiceId());
                    
                    logger.info("Executing UPDATE...");
                    int rows = ps.executeUpdate();
                    if (rows > 0) {
                        logger.info("=== addBookingService SUCCESS (UPDATE) ===");
                        logger.info("Updated existing booking service: booking_id=" + bookingService.getBookingId() + ", service_id=" + bookingService.getServiceId());
                        return true;
                    } else {
                        logger.warning("UPDATE executed but no rows affected");
                    }
                } catch (SQLException updateEx) {
                    logger.severe("SQL Exception during UPDATE: " + updateEx.getMessage());
                    logger.severe("SQL State: " + updateEx.getSQLState());
                    logger.severe("Error Code: " + updateEx.getErrorCode());
                    updateEx.printStackTrace();
                    throw updateEx; // Re-throw to be caught by outer catch
                }
            }
        } catch (SQLException e) {
            logger.severe("=== addBookingService SQL EXCEPTION ===");
            logger.severe("Error adding/updating booking service: " + e.getMessage());
            logger.severe("SQL State: " + e.getSQLState());
            logger.severe("Error Code: " + e.getErrorCode());
            e.printStackTrace();
        } catch (Exception e) {
            logger.severe("=== addBookingService GENERAL EXCEPTION ===");
            logger.severe("Unexpected error: " + e.getMessage());
            e.printStackTrace();
        }

        logger.warning("=== addBookingService FAILED ===");
        return false;
    }

    /**
     * Cập nhật chi tiết booking service
     */
    public boolean updateBookingService(BookingServiceItem bookingService) {
        String sql = "UPDATE Booking_Service SET service_id = ?, quantity = ?, price = ?, note = ? " +
                    "WHERE booking_service_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, bookingService.getServiceId());
            ps.setInt(2, bookingService.getQuantity());
            ps.setBigDecimal(3, bookingService.getPrice());
            ps.setString(4, bookingService.getNote());
            ps.setInt(5, bookingService.getBookingServiceId());

            int rows = ps.executeUpdate();
            return rows > 0;
        } catch (SQLException e) {
            logger.severe("Error updating booking service: " + e.getMessage());
            e.printStackTrace();
        }

        return false;
    }

    /**
     * Xóa chi tiết booking service
     */
    public boolean deleteBookingService(int bookingServiceId) {
        String sql = "DELETE FROM Booking_Service WHERE booking_service_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, bookingServiceId);

            int rows = ps.executeUpdate();
            return rows > 0;
        } catch (SQLException e) {
            logger.severe("Error deleting booking service: " + e.getMessage());
            e.printStackTrace();
        }

        return false;
    }

    /**
     * Xóa tất cả chi tiết booking service theo booking ID
     */
    public boolean deleteBookingServicesByBookingId(int bookingId) {
        String sql = "DELETE FROM Booking_Service WHERE booking_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, bookingId);

            int rows = ps.executeUpdate();
            return rows > 0;
        } catch (SQLException e) {
            logger.severe("Error deleting booking services by booking ID: " + e.getMessage());
            e.printStackTrace();
        }

        return false;
    }

    /**
     * Đếm số lượng chi tiết booking service theo booking ID
     */
    public int countBookingServicesByBookingId(int bookingId) {
        String sql = "SELECT COUNT(*) FROM Booking_Service WHERE booking_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, bookingId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            logger.severe("Error counting booking services by booking ID: " + e.getMessage());
            e.printStackTrace();
        }

        return 0;
    }

    /**
     * Tính tổng giá trị booking service theo booking ID
     */
    public BigDecimal getTotalPriceByBookingId(int bookingId) {
        String sql = "SELECT SUM(price * quantity) FROM Booking_Service WHERE booking_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, bookingId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    BigDecimal total = rs.getBigDecimal(1);
                    return total != null ? total : BigDecimal.ZERO;
                }
            }
        } catch (SQLException e) {
            logger.severe("Error getting total price by booking ID: " + e.getMessage());
            e.printStackTrace();
        }

        return BigDecimal.ZERO;
    }

    /**
     * Helper method để map ResultSet thành BookingService object
     */
    private BookingServiceItem mapResultSetToBookingService(ResultSet rs) throws SQLException {
        BookingServiceItem bookingService = new BookingServiceItem();
        bookingService.setBookingServiceId(rs.getInt("booking_service_id"));
        bookingService.setBookingId(rs.getInt("booking_id"));
        bookingService.setServiceId(rs.getInt("service_id"));
        bookingService.setQuantity(rs.getInt("quantity"));
        bookingService.setPrice(rs.getBigDecimal("unit_price")); // Sử dụng unit_price thay vì price
        bookingService.setNote(rs.getString("note"));
        
        // Lấy created_at nếu có
        try {
            bookingService.setCreatedAt(rs.getTimestamp("created_at"));
        } catch (SQLException e) {
            // Cột created_at có thể không tồn tại
        }
        
        // Thông tin bổ sung từ JOIN
        try {
            bookingService.setServiceName(rs.getString("service_name"));
            bookingService.setServiceType(rs.getString("service_type"));
            bookingService.setServiceDuration(rs.getInt("service_duration"));
        } catch (SQLException e) {
            // Các trường này có thể không tồn tại nếu không có JOIN
        }
        
        return bookingService;
    }
}
