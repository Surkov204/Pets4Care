package dao;

import model.Review;
import utils.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ReviewDAO implements IReviewDAO {

    @Override
    public List<Review> listByToy(int toyId, int limit) {
        List<Review> list = new ArrayList<>();
        String sql = """
            SELECT TOP (?) r.*, c.name AS customer_name
            FROM   Review r
            JOIN   Customer c ON r.customer_id = c.customer_id
            WHERE  r.toy_id = ?
            ORDER  BY r.created_at DESC""";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, limit);
            ps.setInt(2, toyId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    @Override
    public void add(Review r) {
        String sql = "INSERT INTO Review(customer_id,toy_id,rating,comment) VALUES(?,?,?,?)";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt   (1, r.getCustomerId());
            ps.setInt   (2, r.getToyId());
            ps.setInt   (3, r.getRating());
            ps.setString(4, r.getComment());
            ps.executeUpdate();
        } catch (SQLException e) { e.printStackTrace(); }
    }

    /* helper */
    private Review mapRow(ResultSet rs) throws SQLException {
        Review r = new Review();
        r.setReviewId   (rs.getInt("review_id"));
        r.setCustomerId (rs.getInt("customer_id"));
        r.setToyId      (rs.getInt("toy_id"));
        r.setRating     (rs.getInt("rating"));
        r.setComment    (rs.getString("comment"));
        r.setCreatedAt  (rs.getTimestamp("created_at"));
        r.setCustomerName(rs.getString("customer_name"));
        return r;
    }
    
    @Override
    public boolean hasPurchasedAndCompleted(int customerId, int toyId) {
        String sql = "SELECT COUNT(*) FROM [Order] o " +
             "JOIN Order_Detail od ON o.order_id = od.order_id " +
             "WHERE o.customer_id = ? AND od.toy_id = ? AND o.status = N'Hoàn tất'";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            ps.setInt(2, toyId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1) > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

}
