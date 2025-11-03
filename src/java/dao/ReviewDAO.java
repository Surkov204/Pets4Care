package dao;

import model.Review;
import utils.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ReviewDAO implements IReviewDAO {

    @Override
    public List<Review> listByProduct(int productId, int limit) {
        List<Review> list = new ArrayList<>();
        String sql = """
            SELECT TOP (?) r.*, c.name AS customer_name
            FROM   Review r
            JOIN   Customer c ON r.customer_id = c.customer_id
            WHERE  r.product_id = ?
            ORDER  BY r.created_at DESC""";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, limit);
            ps.setInt(2, productId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    @Override
    public void add(Review r) {
        String sql;
        // Nếu có serviceId và bookingId (review cho service)
        if (r.getServiceId() > 0) {
            sql = "INSERT INTO Review(customer_id,service_id,booking_id,rating,comment) VALUES(?,?,?,?,?)";
        } else {
            // Review cho product
            sql = "INSERT INTO Review(customer_id,product_id,rating,comment) VALUES(?,?,?,?)";
        }
        
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, r.getCustomerId());
            if (r.getServiceId() > 0) {
                ps.setInt(2, r.getServiceId());
                if (r.getBookingId() > 0) {
                    ps.setInt(3, r.getBookingId());
                } else {
                    ps.setNull(3, java.sql.Types.INTEGER);
                }
                ps.setInt(4, r.getRating());
                ps.setString(5, r.getComment());
            } else {
                ps.setInt(2, r.getProductId());
                ps.setInt(3, r.getRating());
                ps.setString(4, r.getComment());
            }
            ps.executeUpdate();
        } catch (SQLException e) { e.printStackTrace(); }
    }

    @Override
    public List<Review> listByService(int serviceId, int limit) {
        List<Review> list = new ArrayList<>();
        String sql = """
            SELECT TOP (?) r.*, c.name AS customer_name
            FROM   Review r
            JOIN   Customer c ON r.customer_id = c.customer_id
            WHERE  r.service_id = ?
            ORDER  BY r.created_at DESC""";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, limit);
            ps.setInt(2, serviceId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    /* helper */
    private Review mapRow(ResultSet rs) throws SQLException {
        Review r = new Review();
        r.setReviewId   (rs.getInt("review_id"));
        r.setCustomerId (rs.getInt("customer_id"));
        if (rs.getObject("product_id") != null) {
            r.setProductId(rs.getInt("product_id"));
        }
        if (rs.getObject("service_id") != null) {
            r.setServiceId(rs.getInt("service_id"));
        }
        if (rs.getObject("booking_id") != null) {
            r.setBookingId(rs.getInt("booking_id"));
        }
        r.setRating     (rs.getInt("rating"));
        r.setComment    (rs.getString("comment"));
        r.setCreatedAt  (rs.getTimestamp("created_at"));
        r.setCustomerName(rs.getString("customer_name"));
        return r;
    }
    
    @Override
    public boolean hasPurchasedAndCompleted(int customerId, int productId) {
        String sql = "SELECT COUNT(*) FROM [Order] o " +
             "JOIN Order_Detail od ON o.order_id = od.order_id " +
             "WHERE o.customer_id = ? AND od.product_id = ? AND o.status = N'Hoàn tất'";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            ps.setInt(2, productId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1) > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    @Override
    public boolean hasCompletedBooking(int customerId, int serviceId, int bookingId) {
        String sql = """
            SELECT COUNT(*) 
            FROM Booking b
            JOIN Booking_Service bs ON b.booking_id = bs.booking_id
            WHERE b.customer_id = ? 
              AND bs.service_id = ? 
              AND b.booking_id = ?
              AND (b.status = N'Hoàn thành' OR b.status = 'completed' 
                   OR b.status = N'Đã thanh toán' OR b.status = N'Chờ xác nhận' 
                   OR b.status = N'Đã xác nhận')
            """;

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            ps.setInt(2, serviceId);
            ps.setInt(3, bookingId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1) > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    @Override
    public Review getReviewByBooking(int bookingId, int serviceId, int customerId) {
        String sql = """
            SELECT r.*, c.name AS customer_name
            FROM Review r
            JOIN Customer c ON r.customer_id = c.customer_id
            WHERE r.booking_id = ? AND r.service_id = ? AND r.customer_id = ?
            """;

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, bookingId);
            ps.setInt(2, serviceId);
            ps.setInt(3, customerId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return mapRow(rs);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

}
