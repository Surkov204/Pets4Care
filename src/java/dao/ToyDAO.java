package dao;

import model.Toy;
import utils.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import model.Review;
import model.Toy;
import static org.apache.http.conn.util.DnsUtils.normalize;

public class ToyDAO implements IToyDAO {

    @Override
    public List<Toy> getAllToys() {
        List<Toy> toys = new ArrayList<>();
        String sql = "SELECT * FROM Toy ";

        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Toy toy = new Toy();
                toy.setToyId(rs.getInt("toy_id"));
                toy.setName(rs.getString("name"));
                toy.setPrice(rs.getDouble("price"));
                toy.setCategoryId(rs.getInt("category_id"));
                toy.setStockQuantity(rs.getInt("stock_quantity"));
                toy.setSupplierId(rs.getInt("supplier_id"));
                toy.setDescription(rs.getString("description"));

                toys.add(toy);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return toys;
    }

    @Override
    public List<Toy> getToysByPage(int offset, int limit) {
        List<Toy> toys = new ArrayList<>();
        String sql = "SELECT toy_id, name, price, category_id, stock_quantity, supplier_id, description FROM Toy ORDER BY toy_id OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";

        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, offset);
            ps.setInt(2, limit);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Toy toy = new Toy();
                    toy.setToyId(rs.getInt("toy_id"));
                    toy.setName(rs.getString("name"));
                    toy.setPrice(rs.getDouble("price"));
                    toy.setCategoryId(rs.getInt("category_id"));
                    toy.setStockQuantity(rs.getInt("stock_quantity"));
                    toy.setSupplierId(rs.getInt("supplier_id"));
                    toy.setDescription(rs.getString("description"));

                    toys.add(toy);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return toys;
    }

    @Override
    public int countAllToys() {
        String sql = "SELECT COUNT(*) FROM Toy";
        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    @Override
    public Toy getToyById(int id) {
        Toy toy = null;
        String sql = "SELECT toy_id, name, price, category_id, stock_quantity, supplier_id, description FROM Toy WHERE toy_id = ?";

        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    toy = new Toy();
                    toy.setToyId(rs.getInt("toy_id"));
                    toy.setName(rs.getString("name"));
                    toy.setPrice(rs.getDouble("price"));
                    toy.setCategoryId(rs.getInt("category_id"));
                    toy.setStockQuantity(rs.getInt("stock_quantity"));
                    toy.setSupplierId(rs.getInt("supplier_id"));
                    toy.setDescription(rs.getString("description"));
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return toy;
    }

    @Override
    public boolean checkStockAvailability(int toyId, int quantity) {
        String sql = "SELECT stock_quantity FROM Toy WHERE toy_id = ?";

        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, toyId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int stockQuantity = rs.getInt("stock_quantity");
                    return stockQuantity >= quantity; // Kiểm tra trực tiếp trong Java
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    @Override
    public List<Review> getToyReviews(int toyId) {
        List<Review> reviews = new ArrayList<>();
        String sql = "SELECT review_id, customer_id, toy_id, rating, comment, created_at FROM Review WHERE toy_id = ?";

        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, toyId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Review r = new Review();
                    r.setReviewId(rs.getInt("review_id"));
                    r.setCustomerId(rs.getInt("customer_id"));
                    r.setToyId(rs.getInt("toy_id"));
                    r.setRating(rs.getInt("rating"));
                    r.setComment(rs.getString("comment"));
                    r.setCreatedAt(rs.getTimestamp("created_at"));
                    reviews.add(r);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return reviews;
    }

    @Override
    public List<String> searchToyNames(String query) {
        List<String> names = new ArrayList<>();
        String sql = "SELECT name FROM Toy WHERE LOWER(name) LIKE ? COLLATE Latin1_General_CI_AI"; // sửa tại đây nếu dùng SQL Server

        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, "%" + query.toLowerCase() + "%");
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    names.add(rs.getString("name"));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return names;
    }

    @Override
    public List<Toy> searchToys(String keyword) {
        List<Toy> toys = new ArrayList<>();
        String sql = "SELECT * FROM Toy WHERE name LIKE ?";

        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, "%" + keyword + "%");
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Toy toy = new Toy();
                    toy.setToyId(rs.getInt("toy_id"));
                    toy.setName(rs.getString("name"));
                    toy.setDescription(rs.getString("description"));
                    toy.setPrice(rs.getDouble("price"));
                    toy.setStockQuantity(rs.getInt("stock_quantity"));
                    // Gán các thuộc tính khác nếu cần
                    toys.add(toy);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return toys;
    }

    @Override
    public List<Toy> getToysByCategorySlug(String slug) {
        List<Toy> list = new ArrayList<>();
        String sql = "SELECT * FROM Toys WHERE category_slug = ?";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, slug);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Toy toy = new Toy();
                    toy.setToyId(rs.getInt("toy_id"));
                    toy.setName(rs.getString("name"));
                    toy.setPrice(rs.getDouble("price"));
                    toy.setStockQuantity(rs.getInt("stock_quantity"));
                    toy.setCategorySlug(rs.getString("category_slug"));
                    list.add(toy);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    @Override
    public List<Toy> getToysByCategoryId(int categoryId) {
        List<Toy> list = new ArrayList<>();
        String sql = "SELECT * FROM Toy WHERE category_id = ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, categoryId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Toy toy = new Toy();
                    toy.setToyId(rs.getInt("toy_id"));
                    toy.setName(rs.getString("name"));
                    toy.setPrice(rs.getDouble("price"));
                    toy.setStockQuantity(rs.getInt("stock_quantity"));
                    list.add(toy);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public boolean softDelete(int toyId) {
        String sql = "UPDATE Toy SET is_deleted = 1 WHERE toy_id = ?";
        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, toyId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    @Override
    public int addToy(Toy toy) {
        String sql = "INSERT INTO Toy (name, price, category_id, stock_quantity, supplier_id, description, admin_id) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?)";

        int generatedId = -1;

        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setString(1, toy.getName());
            ps.setDouble(2, toy.getPrice());
            ps.setInt(3, toy.getCategoryId());
            ps.setInt(4, toy.getStockQuantity());
            ps.setInt(5, toy.getSupplierId());
            ps.setString(6, toy.getDescription());
            ps.setInt(7, toy.getAdminId());

            int affectedRows = ps.executeUpdate();

            if (affectedRows > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        generatedId = rs.getInt(1);  // Lấy toy_id vừa insert
                    }
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return generatedId;
    }

    @Override
    public int getLastInsertedId() {
        String sql = "SELECT IDENT_CURRENT('Toy') AS last_id";
        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt("last_id");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return -1;
    }

    @Override
    public boolean deleteToy(int toyId) {
        String sql = "DELETE FROM Toy WHERE toy_id = ?";
        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, toyId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    @Override
    public boolean updateToy(Toy toy) {
        String sql = "UPDATE Toy SET name = ?, price = ?, category_id = ?, stock_quantity = ?, supplier_id = ?, description = ?, admin_id = ? WHERE toy_id = ?";

        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, toy.getName());
            ps.setDouble(2, toy.getPrice());
            ps.setInt(3, toy.getCategoryId());
            ps.setInt(4, toy.getStockQuantity());
            ps.setInt(5, toy.getSupplierId());
            ps.setString(6, toy.getDescription());
            ps.setInt(7, toy.getAdminId());  // admin cập nhật cuối
            ps.setInt(8, toy.getToyId());

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    @Override
    public List<Toy> searchToysByNameOrIdAndCategory(String keyword, int categoryId) {
        List<Toy> toys = new ArrayList<>();

        StringBuilder sql = new StringBuilder("SELECT * FROM Toy WHERE 1=1");

        if (categoryId != -1) {
            sql.append(" AND category_id = ?");
        }

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (LOWER(name) LIKE ? OR toy_id = ?)");
        }

        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql.toString())) {
            int paramIndex = 1;

            if (categoryId != -1) {
                ps.setInt(paramIndex++, categoryId);
            }

            if (keyword != null && !keyword.trim().isEmpty()) {
                ps.setString(paramIndex++, "%" + keyword.toLowerCase() + "%");

                int toyIdSearch;
                try {
                    toyIdSearch = Integer.parseInt(keyword);
                } catch (NumberFormatException e) {
                    toyIdSearch = -1; // Không match toy_id nào
                }
                ps.setInt(paramIndex++, toyIdSearch);
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Toy toy = extractToyFromResultSet(rs);
                    toys.add(toy);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return toys;
    }

    private Toy extractToyFromResultSet(ResultSet rs) throws SQLException {
        Toy toy = new Toy();
        toy.setToyId(rs.getInt("toy_id"));
        toy.setName(rs.getString("name"));
        toy.setPrice(rs.getDouble("price"));
        toy.setCategoryId(rs.getInt("category_id"));
        toy.setStockQuantity(rs.getInt("stock_quantity"));
        toy.setSupplierId(rs.getInt("supplier_id"));
        toy.setDescription(rs.getString("description"));
        return toy;
    }

    /* Lấy sản phẩm theo category_id */
    @Override
    public List<Toy> getToysByCategory(int categoryId) {
        List<Toy> toys = new ArrayList<>();
        String sql = """
            SELECT toy_id, name, price, category_id, stock_quantity,
                   supplier_id, description
            FROM Toy
            WHERE category_id = ?
        """;

        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, categoryId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    toys.add(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return toys;
    }

    /*  Helper: Convert ResultSet -> Toy */
    private Toy mapRow(ResultSet rs) throws SQLException {
        Toy t = new Toy();
        t.setToyId(rs.getInt("toy_id"));
        t.setName(rs.getString("name"));
        t.setPrice(rs.getDouble("price"));
        t.setCategoryId(rs.getInt("category_id"));
        t.setStockQuantity(rs.getInt("stock_quantity"));
        t.setSupplierId(rs.getInt("supplier_id"));
        t.setDescription(rs.getString("description"));
        return t;
    }

    /* Tìm kiếm sản phẩm theo tên */
    @Override
public List<Toy> searchToysByKeyword(String keyword) {
    List<Toy> toys = new ArrayList<>();
    if (keyword == null || keyword.trim().isEmpty()) return toys;

    String searchPattern = "%" + keyword.toLowerCase() + "%";

    String sql = """
        SELECT t.*, tc.name AS category_name
        FROM Toy t
        LEFT JOIN ToyCategory tc ON t.category_id = tc.category_id
        WHERE 
            LOWER(tc.name) COLLATE Vietnamese_CI_AI LIKE ? 
            OR LOWER(t.name) COLLATE Vietnamese_CI_AI LIKE ? 
            OR LOWER(t.description) COLLATE Vietnamese_CI_AI LIKE ?
        ORDER BY 
            CASE 
                WHEN LOWER(tc.name) COLLATE Vietnamese_CI_AI LIKE ? THEN 1
                WHEN LOWER(t.name) COLLATE Vietnamese_CI_AI LIKE ? THEN 2
                WHEN LOWER(t.description) COLLATE Vietnamese_CI_AI LIKE ? THEN 3
                ELSE 4
            END
    """;

    try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
        for (int i = 1; i <= 6; i++) {
            ps.setString(i, searchPattern);
        }

        try (ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                toys.add(mapRow(rs));
            }
        }
    } catch (SQLException e) {
        e.printStackTrace();
    }

    return toys;
}



private String removeVietnameseAccents(String str) {
    String temp = java.text.Normalizer.normalize(str, java.text.Normalizer.Form.NFD);
    return temp.replaceAll("\\p{InCombiningDiacriticalMarks}+", "");
}

private int levenshtein(String a, String b) {
    int[] costs = new int[b.length() + 1];
    for (int j = 0; j < costs.length; j++) {
        costs[j] = j;
    }
    for (int i = 1; i <= a.length(); i++) {
        costs[0] = i;
        int nw = i - 1;
        for (int j = 1; j <= b.length(); j++) {
            int cj = Math.min(1 + Math.min(costs[j], costs[j - 1]),
                    a.charAt(i - 1) == b.charAt(j - 1) ? nw : nw + 1);
            nw = costs[j];
            costs[j] = cj;
        }
    }
    return costs[b.length()];
}


    @Override
    public List<Toy> searchToysByKeywordAndCategory(String keyword, int categoryId) {
        List<Toy> toys = new ArrayList<>();
        if (keyword == null || keyword.trim().isEmpty()) {
            return toys;
        }

        String sql = """
        SELECT t.* 
        FROM Toy t
        LEFT JOIN ToyCategory tc ON t.category_id = tc.category_id
        WHERE (LOWER(t.name) COLLATE Vietnamese_CI_AI LIKE ? 
           OR LOWER(t.description) COLLATE Vietnamese_CI_AI LIKE ? 
           OR LOWER(tc.name) COLLATE Vietnamese_CI_AI LIKE ?)
           AND t.category_id = ?
        """;

        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            String searchPattern = "%" + keyword.toLowerCase() + "%";
            ps.setString(1, searchPattern);
            ps.setString(2, searchPattern);
            ps.setString(3, searchPattern);
            ps.setInt(4, categoryId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    toys.add(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return toys;
    }


    /* Điểm đánh giá trung bình (gọi hàm UDF)*/
    @Override
    public double getAverageRating(int toyId) {
        String sql = "SELECT dbo.GetAverageRating(?) AS avg_rating";
        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, toyId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getDouble("avg_rating") : 0.0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return 0.0;
        }
    }

    /* Sản phẩm tương tự (random TOP n khác toy hiện tại)*/
    @Override
    public List<Toy> getSimilarToys(int categoryId, int excludeToyId, int limit) {
        List<Toy> list = new ArrayList<>();
        String sql = """
            SELECT TOP (?) toy_id, name, price, category_id, stock_quantity,
                           supplier_id, description
            FROM   Toy
            WHERE  category_id = ? AND toy_id <> ?
            ORDER BY NEWID()""";   // random

        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, limit);
            ps.setInt(2, categoryId);
            ps.setInt(3, excludeToyId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // Lấy tên sản phẩm từ toy_id
    @Override
    public String getToyNameById(int toyId) {
        String sql = "SELECT name FROM Toy WHERE toy_id = ?";
        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, toyId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("name");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return "Không rõ";
    }

    @Override
    public List<Review> getReviewsByToyId(int toyId) {
        List<Review> reviews = new ArrayList<>();
        String sql = """
        SELECT r.review_id, r.customer_id, r.rating, r.comment, r.created_at, c.name as customer_name
        FROM Review r
        JOIN Customer c ON r.customer_id = c.customer_id
        WHERE r.toy_id = ?
        ORDER BY r.created_at DESC
    """;

        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, toyId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Review review = new Review();
                    review.setReviewId(rs.getInt("review_id"));
                    review.setCustomerId(rs.getInt("customer_id"));
                    review.setRating(rs.getInt("rating"));
                    review.setComment(rs.getString("comment"));
                    review.setCreatedAt(rs.getTimestamp("created_at"));
                    review.setCustomerName(rs.getString("customer_name"));
                    reviews.add(review);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return reviews;
    }

    @Override
    public Map<Integer, String> getAllCategoriesMap() {
        Map<Integer, String> categories = new HashMap<>();
        String sql = "SELECT category_id, name FROM ToyCategory";

        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                categories.put(rs.getInt("category_id"), rs.getString("name"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return categories;
    }

}