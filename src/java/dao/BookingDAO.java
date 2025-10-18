package dao;

import model.Booking;
import utils.DBConnection;

import java.sql.*;
import java.util.*;

public class BookingDAO implements IBookingDAO {
    private static final java.util.logging.Logger logger =
            java.util.logging.Logger.getLogger(BookingDAO.class.getName());

    // =========================
    // LIST ALL
    // =========================
    @Override

public List<Booking> getAllBookings() {
    List<Booking> bookings = new ArrayList<>();

    // 1) Có tên dịch vụ (nếu bảng/quan hệ tồn tại)
    final String SQL_WITH_SERVICES =
        "SELECT b.*, " +
        "       c.name AS customer_name, c.phone AS customer_phone, c.email AS customer_email, " +
        "       p.name AS pet_name,      p.species AS pet_type, " +
        "       s.name AS staff_name, " +
        "       d.name AS doctor_name, " +
        "       svc.service_names " +
        "FROM dbo.Booking b " +
        "LEFT JOIN dbo.Customer c ON b.customer_id = c.customer_id " +
        "LEFT JOIN dbo.Pet      p ON b.pet_id      = p.pet_id " +
        "LEFT JOIN dbo.Staff    s ON b.staff_id    = s.staff_id " +
        "LEFT JOIN dbo.Doctor   d ON b.doctor_id   = d.doctor_id " +
        "OUTER APPLY ( " +
        "   SELECT STRING_AGG(CONVERT(nvarchar(200), ps.name), ', ') " +
        "          WITHIN GROUP (ORDER BY ps.name) AS service_names " +
        "   FROM dbo.Booking_Service bs " +
        "   JOIN dbo.PetService ps ON ps.service_id = bs.service_id " +
        "   WHERE bs.booking_id = b.booking_id " +
        ") svc " +
        "ORDER BY b.appointment_start DESC";

    // 2) Cơ bản (không tên dịch vụ) – dùng khi câu số 1 lỗi
    final String SQL_BASE =
        "SELECT b.*, " +
        "       c.name AS customer_name, c.phone AS customer_phone, c.email AS customer_email, " +
        "       p.name AS pet_name,      p.species AS pet_type, " +
        "       s.name AS staff_name, " +
        "       d.name AS doctor_name " +
        "FROM dbo.Booking b " +
        "LEFT JOIN dbo.Customer c ON b.customer_id = c.customer_id " +
        "LEFT JOIN dbo.Pet      p ON b.pet_id      = p.pet_id " +
        "LEFT JOIN dbo.Staff    s ON b.staff_id    = s.staff_id " +
        "LEFT JOIN dbo.Doctor   d ON b.doctor_id   = d.doctor_id " +
        "ORDER BY b.appointment_start DESC";

    // Helper chạy query
    java.util.function.Function<String, List<Booking>> exec = (sql) -> {
        List<Booking> out = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) out.add(mapBookingFromResultSet(rs));
        } catch (SQLException e) {
            logger.severe("getAllBookings SQL error with query:\n" + sql + "\n=> " + e.getMessage());
            throw new RuntimeException(e);
        }
        return out;
    };

    try {
        // Thử câu đầy đủ
        bookings = exec.apply(SQL_WITH_SERVICES);
    } catch (RuntimeException ex) {
        // Fallback sang câu cơ bản
        logger.warning("Falling back to base query without service_names due to: " + ex.getCause().getMessage());
        bookings = exec.apply(SQL_BASE);
    }

    System.out.println("DEBUG >>> getAllBookings(): " + bookings.size());
    return bookings;
}


    // =========================
    // GET BY ID
    // =========================
    @Override
    public Booking getBookingById(int bookingId) {
        String sql =
            "SELECT b.*, " +
            "       c.name  AS customer_name, c.phone AS customer_phone, c.email AS customer_email, " +
            "       p.name  AS pet_name,      p.species AS pet_type, " +
            "       s.name  AS staff_name, " +
            "       d.name  AS doctor_name, " +
            "       (SELECT STRING_AGG(ps.name, ', ') " +
            "          FROM dbo.Booking_Service bs " +
            "          JOIN dbo.PetService ps ON ps.service_id = bs.service_id " +
            "         WHERE bs.booking_id = b.booking_id) AS service_names " +
            "FROM dbo.Booking b " +
            "LEFT JOIN dbo.Customer c ON b.customer_id = c.customer_id " +
            "LEFT JOIN dbo.Pet      p ON b.pet_id      = p.pet_id " +
            "LEFT JOIN dbo.Staff    s ON b.staff_id    = s.staff_id " +
            "LEFT JOIN dbo.Doctor   d ON b.doctor_id   = d.doctor_id " +
            "WHERE b.booking_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, bookingId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Booking bk = mapBookingFromResultSet(rs);
                    try {
                        bk.setServiceNames(rs.getString("service_names"));
                    } catch (SQLException e) {
                        // service_names có thể null
                    }
                    return bk;
                }
            }
        } catch (SQLException e) {
            logger.severe("Error getting booking by ID: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }

    // =========================
    // GET BY CUSTOMER
    // =========================
    @Override
    public List<Booking> getBookingsByCustomerId(int customerId) {
        List<Booking> bookings = new ArrayList<>();
        String sql =
            "SELECT b.*, " +
            "       c.name  AS customer_name, c.phone AS customer_phone, c.email AS customer_email, " +
            "       p.name  AS pet_name,      p.species AS pet_type, " +
            "       s.name  AS staff_name, " +
            "       d.name  AS doctor_name, " +
            "       (SELECT STRING_AGG(sv.name, ', ') " +
            "          FROM dbo.BookingService bs " +
            "          JOIN dbo.Service sv ON sv.service_id = bs.service_id " +
            "         WHERE bs.booking_id = b.booking_id) AS service_names " +
            "FROM dbo.Booking b " +
            "LEFT JOIN dbo.Customer c ON b.customer_id = c.customer_id " +
            "LEFT JOIN dbo.Pet      p ON b.pet_id      = p.pet_id " +
            "LEFT JOIN dbo.Staff    s ON b.staff_id    = s.staff_id " +
            "LEFT JOIN dbo.Doctor   d ON b.doctor_id   = d.doctor_id " +
            "WHERE b.customer_id = ? " +
            "ORDER BY b.appointment_start DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Booking bk = mapBookingFromResultSet(rs);
                    bk.setServiceNames(rs.getString("service_names"));
                    bookings.add(bk);
                }
            }
        } catch (SQLException e) {
            logger.severe("Error getting bookings by customer ID: " + e.getMessage());
            e.printStackTrace();
        }
        return bookings;
    }

    // =========================
    // GET BY STAFF
    // =========================
    @Override
    public List<Booking> getBookingsByStaffId(int staffId) {
        List<Booking> bookings = new ArrayList<>();
        String sql =
            "SELECT b.*, " +
            "       c.name  AS customer_name, c.phone AS customer_phone, c.email AS customer_email, " +
            "       p.name  AS pet_name,      p.species AS pet_type, " +
            "       s.name  AS staff_name, " +
            "       d.name  AS doctor_name, " +
            "       (SELECT STRING_AGG(sv.name, ', ') " +
            "          FROM dbo.BookingService bs " +
            "          JOIN dbo.Service sv ON sv.service_id = bs.service_id " +
            "         WHERE bs.booking_id = b.booking_id) AS service_names " +
            "FROM dbo.Booking b " +
            "LEFT JOIN dbo.Customer c ON b.customer_id = c.customer_id " +
            "LEFT JOIN dbo.Pet      p ON b.pet_id      = p.pet_id " +
            "LEFT JOIN dbo.Staff    s ON b.staff_id    = s.staff_id " +
            "LEFT JOIN dbo.Doctor   d ON b.doctor_id   = d.doctor_id " +
            "WHERE b.staff_id = ? " +
            "ORDER BY b.appointment_start DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, staffId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Booking bk = mapBookingFromResultSet(rs);
                    bk.setServiceNames(rs.getString("service_names"));
                    bookings.add(bk);
                }
            }
        } catch (SQLException e) {
            logger.severe("Error getting bookings by staff ID: " + e.getMessage());
            e.printStackTrace();
        }
        return bookings;
    }

    // =========================
    // GET BY STATUS
    // =========================
    @Override
    public List<Booking> getBookingsByStatus(String status) {
        List<Booking> bookings = new ArrayList<>();
        String sql =
            "SELECT b.*, " +
            "       c.name  AS customer_name, c.phone AS customer_phone, c.email AS customer_email, " +
            "       p.name  AS pet_name,      p.species AS pet_type, " +
            "       s.name  AS staff_name, " +
            "       (SELECT STRING_AGG(sv.name, ', ') " +
            "          FROM dbo.BookingService bs " +
            "          JOIN dbo.Service sv ON sv.service_id = bs.service_id " +
            "         WHERE bs.booking_id = b.booking_id) AS service_names " +
            "FROM dbo.Booking b " +
            "LEFT JOIN dbo.Customer c ON b.customer_id = c.customer_id " +
            "LEFT JOIN dbo.Pet      p ON b.pet_id      = p.pet_id " +
            "LEFT JOIN dbo.Staff    s ON b.staff_id    = s.staff_id " +
            "WHERE b.status = ? " +
            "ORDER BY b.appointment_start DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Booking bk = mapBookingFromResultSet(rs);
                    bk.setServiceNames(rs.getString("service_names"));
                    bookings.add(bk);
                }
            }
        } catch (SQLException e) {
            logger.severe("Error getting bookings by status: " + e.getMessage());
            e.printStackTrace();
        }
        return bookings;
    }

    // =========================
    // GET BY DATE (one day)
    // =========================
    @Override
    public List<Booking> getBookingsByDate(java.sql.Date date) {
        List<Booking> bookings = new ArrayList<>();
        String sql =
            "SELECT b.*, " +
            "       c.name  AS customer_name, c.phone AS customer_phone, c.email AS customer_email, " +
            "       p.name  AS pet_name,      p.species AS pet_type, " +
            "       s.name  AS staff_name, " +
            "       d.name  AS doctor_name, " +
            "       (SELECT STRING_AGG(sv.name, ', ') " +
            "          FROM dbo.BookingService bs " +
            "          JOIN dbo.Service sv ON sv.service_id = bs.service_id " +
            "         WHERE bs.booking_id = b.booking_id) AS service_names " +
            "FROM dbo.Booking b " +
            "LEFT JOIN dbo.Customer c ON b.customer_id = c.customer_id " +
            "LEFT JOIN dbo.Pet      p ON b.pet_id      = p.pet_id " +
            "LEFT JOIN dbo.Staff    s ON b.staff_id    = s.staff_id " +
            "LEFT JOIN dbo.Doctor   d ON b.doctor_id   = d.doctor_id " +
            "WHERE CAST(b.appointment_start AS date) = ? " +
            "ORDER BY b.appointment_start ASC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setDate(1, date);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Booking bk = mapBookingFromResultSet(rs);
                    bk.setServiceNames(rs.getString("service_names"));
                    bookings.add(bk);
                }
            }
        } catch (SQLException e) {
            logger.severe("Error getting bookings by date: " + e.getMessage());
            e.printStackTrace();
        }
        return bookings;
    }

    // =========================
    // GET BY DATE RANGE
    // =========================
    @Override
    public List<Booking> getBookingsByDateRange(java.sql.Date startDate, java.sql.Date endDate) {
        List<Booking> bookings = new ArrayList<>();
        String sql =
            "SELECT b.*, " +
            "       c.name  AS customer_name, c.phone AS customer_phone, c.email AS customer_email, " +
            "       p.name  AS pet_name,      p.species AS pet_type, " +
            "       s.name  AS staff_name, " +
            "       d.name  AS doctor_name, " +
            "       (SELECT STRING_AGG(sv.name, ', ') " +
            "          FROM dbo.BookingService bs " +
            "          JOIN dbo.Service sv ON sv.service_id = bs.service_id " +
            "         WHERE bs.booking_id = b.booking_id) AS service_names " +
            "FROM dbo.Booking b " +
            "LEFT JOIN dbo.Customer c ON b.customer_id = c.customer_id " +
            "LEFT JOIN dbo.Pet      p ON b.pet_id      = p.pet_id " +
            "LEFT JOIN dbo.Staff    s ON b.staff_id    = s.staff_id " +
            "LEFT JOIN dbo.Doctor   d ON b.doctor_id   = d.doctor_id " +
            "WHERE CAST(b.appointment_start AS date) BETWEEN ? AND ? " +
            "ORDER BY b.appointment_start ASC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setDate(1, startDate);
            ps.setDate(2, endDate);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Booking bk = mapBookingFromResultSet(rs);
                    bk.setServiceNames(rs.getString("service_names"));
                    bookings.add(bk);
                }
            }
        } catch (SQLException e) {
            logger.severe("Error getting bookings by date range: " + e.getMessage());
            e.printStackTrace();
        }
        return bookings;
    }

    // =========================
    // SEARCH
    // =========================
    @Override
    public List<Booking> searchBookings(String keyword) {
        List<Booking> bookings = new ArrayList<>();
        String sql =
            "SELECT b.*, " +
            "       c.name  AS customer_name, c.phone AS customer_phone, c.email AS customer_email, " +
            "       p.name  AS pet_name,      p.species AS pet_type, " +
            "       s.name  AS staff_name, " +
            "       d.name  AS doctor_name, " +
            "       (SELECT STRING_AGG(sv.name, ', ') " +
            "          FROM dbo.BookingService bs " +
            "          JOIN dbo.Service sv ON sv.service_id = bs.service_id " +
            "         WHERE bs.booking_id = b.booking_id) AS service_names " +
            "FROM dbo.Booking b " +
            "LEFT JOIN dbo.Customer c ON b.customer_id = c.customer_id " +
            "LEFT JOIN dbo.Pet      p ON b.pet_id      = p.pet_id " +
            "LEFT JOIN dbo.Staff    s ON b.staff_id    = s.staff_id " +
            "LEFT JOIN dbo.Doctor   d ON b.doctor_id   = d.doctor_id " +
            "WHERE c.name  LIKE ? OR c.phone LIKE ? OR c.email LIKE ? OR p.name LIKE ? OR b.note LIKE ? " +
            "ORDER BY b.appointment_start DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            String pattern = "%" + keyword + "%";
            ps.setString(1, pattern);
            ps.setString(2, pattern);
            ps.setString(3, pattern);
            ps.setString(4, pattern);
            ps.setString(5, pattern);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Booking bk = mapBookingFromResultSet(rs);
                    bk.setServiceNames(rs.getString("service_names"));
                    bookings.add(bk);
                }
            }
        } catch (SQLException e) {
            logger.severe("Error searching bookings: " + e.getMessage());
            e.printStackTrace();
        }
        return bookings;
    }

    // =========================
    // INSERT
    // =========================
    @Override
    public boolean addBooking(Booking booking) {
        String sql =
            "INSERT INTO dbo.Booking " +
            " (customer_id, pet_id, appointment_start, appointment_end, status, note, doctor_id, staff_id, order_id, created_at) " +
            "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setInt(1, booking.getCustomerId());
            ps.setInt(2, booking.getPetId());
            ps.setTimestamp(3, booking.getAppointmentStart());
            ps.setTimestamp(4, booking.getAppointmentEnd());
            ps.setString(5, booking.getStatus());
            ps.setString(6, booking.getNote());
            ps.setInt(7, booking.getDoctorId());
            ps.setInt(8, booking.getStaffId());
            ps.setInt(9, booking.getOrderId());
            ps.setTimestamp(10, booking.getCreatedAt());

            int rows = ps.executeUpdate();
            if (rows > 0) {
                try (ResultSet keys = ps.getGeneratedKeys()) {
                    if (keys.next()) booking.setBookingId(keys.getInt(1));
                }
                return true;
            }
        } catch (SQLException e) {
            logger.severe("Error adding booking: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    // =========================
    // UPDATE
    // =========================
    @Override
    public boolean updateBooking(Booking booking) {
        String sql =
            "UPDATE dbo.Booking " +
            "SET customer_id = ?, pet_id = ?, appointment_start = ?, appointment_end = ?, " +
            "    status = ?, note = ?, doctor_id = ?, staff_id = ?, order_id = ? " +
            "WHERE booking_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, booking.getCustomerId());
            ps.setInt(2, booking.getPetId());
            ps.setTimestamp(3, booking.getAppointmentStart());
            ps.setTimestamp(4, booking.getAppointmentEnd());
            ps.setString(5, booking.getStatus());
            ps.setString(6, booking.getNote());
            ps.setInt(7, booking.getDoctorId());
            ps.setInt(8, booking.getStaffId());
            ps.setInt(9, booking.getOrderId());
            ps.setInt(10, booking.getBookingId());

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.severe("Error updating booking: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    // =========================
    // UPDATE STATUS
    // =========================
    @Override
    public boolean updateBookingStatus(int bookingId, String status) {
        String sql = "UPDATE dbo.Booking SET status = ? WHERE booking_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, bookingId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.severe("Error updating booking status: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    // =========================
    // DELETE
    // =========================
    @Override
    public boolean deleteBooking(int bookingId) {
        String sql = "DELETE FROM dbo.Booking WHERE booking_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, bookingId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.severe("Error deleting booking: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    // =========================
    // COUNT BY STATUS
    // =========================
    @Override
    public int countBookingsByStatus(String status) {
        String sql = "SELECT COUNT(*) FROM dbo.Booking WHERE status = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            logger.severe("Error counting bookings by status: " + e.getMessage());
            e.printStackTrace();
        }
        return 0;
    }

    // =========================
    // RECENT (TOP N)
    // =========================
    @Override
    public List<Booking> getRecentBookings(int limit) {
        int safeLimit = Math.max(1, Math.min(limit, 1000));

        String sql =
            "SELECT TOP " + safeLimit + " b.*, " +
            "       c.name  AS customer_name, c.phone AS customer_phone, c.email AS customer_email, " +
            "       p.name  AS pet_name,      p.species AS pet_type, " +
            "       s.name  AS staff_name, " +
            "       d.name  AS doctor_name, " +
            "       (SELECT STRING_AGG(sv.name, ', ') " +
            "          FROM dbo.BookingService bs " +
            "          JOIN dbo.Service sv ON sv.service_id = bs.service_id " +
            "         WHERE bs.booking_id = b.booking_id) AS service_names " +
            "FROM dbo.Booking b " +
            "LEFT JOIN dbo.Customer c ON b.customer_id = c.customer_id " +
            "LEFT JOIN dbo.Pet      p ON b.pet_id      = p.pet_id " +
            "LEFT JOIN dbo.Staff    s ON b.staff_id    = s.staff_id " +
            "LEFT JOIN dbo.Doctor   d ON b.doctor_id   = d.doctor_id " +
            "ORDER BY b.appointment_start DESC";

        List<Booking> bookings = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Booking bk = mapBookingFromResultSet(rs);
                bk.setServiceNames(rs.getString("service_names"));
                bookings.add(bk);
            }
        } catch (SQLException e) {
            logger.severe("Error getting recent bookings: " + e.getMessage());
            e.printStackTrace();
        }
        return bookings;
    }

    // =========================
    // STATS
    // =========================
    @Override
    public Map<String, Integer> getBookingStats() {
        Map<String, Integer> stats = new HashMap<>();
        String sql = "SELECT status, COUNT(*) AS count FROM dbo.Booking GROUP BY status";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) stats.put(rs.getString("status"), rs.getInt("count"));
        } catch (SQLException e) {
            logger.severe("Error getting booking stats: " + e.getMessage());
            e.printStackTrace();
        }
        return stats;
    }

    // =========================
    // MAP ROW
    // =========================
    private Booking mapBookingFromResultSet(ResultSet rs) throws SQLException {
    Booking booking = new Booking();
    booking.setBookingId(rs.getInt("booking_id"));
    booking.setCustomerId(rs.getInt("customer_id"));
    booking.setPetId(rs.getInt("pet_id"));
    booking.setAppointmentStart(rs.getTimestamp("appointment_start"));
    booking.setAppointmentEnd(rs.getTimestamp("appointment_end"));
    booking.setStatus(rs.getString("status"));
    booking.setNote(rs.getString("note"));
    booking.setCreatedAt(rs.getTimestamp("created_at"));
    booking.setDoctorId(rs.getInt("doctor_id"));
    booking.setStaffId(rs.getInt("staff_id"));
    booking.setOrderId(rs.getInt("order_id"));

    booking.setCustomerName(rs.getString("customer_name"));
    booking.setCustomerPhone(rs.getString("customer_phone"));
    booking.setCustomerEmail(rs.getString("customer_email"));
    booking.setPetName(rs.getString("pet_name"));
    booking.setPetType(rs.getString("pet_type"));
    booking.setStaffName(rs.getString("staff_name"));
    booking.setDoctorName(rs.getString("doctor_name"));

    // cột này chỉ có khi dùng SQL_WITH_SERVICES
    try { booking.setServiceNames(rs.getString("service_names")); } catch (SQLException ignore) {}

    return booking;
}

    // =========================
    // AUTO CANCEL EXPIRED DEPOSIT BOOKINGS
    // =========================
    public int autoCancelExpiredDepositBookings() {
        String sql = """
            UPDATE b 
            SET b.status = 'cancelled'
            FROM dbo.Booking b
            INNER JOIN dbo.[Order] o ON b.order_id = o.order_id
            WHERE b.status IN ('pending', 'confirmed')
            AND o.payment_status = 'paid'
            AND b.appointment_start < GETDATE()
            """;
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            int rowsAffected = ps.executeUpdate();
            if (rowsAffected > 0) {
                logger.info("Auto-cancelled " + rowsAffected + " expired deposit bookings");
            }
            return rowsAffected;
            
        } catch (SQLException e) {
            logger.severe("Error auto-cancelling expired deposit bookings: " + e.getMessage());
            e.printStackTrace();
            return 0;
        }
    }
}

