package dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import model.Product;
import model.Review;
import utils.DBConnection;

public class ProductDAO {

    // Phương thức để map ResultSet thành Product object
    private Product mapProductFromResultSet(ResultSet rs) throws SQLException {
        Product product = new Product();
        product.setProductId(rs.getInt("product_id"));
        product.setName(rs.getString("name"));
        product.setProductType(rs.getString("product_type"));
        product.setPrice(rs.getDouble("price"));
        product.setStockQuantity(rs.getInt("stock_quantity"));
        product.setExpiryDate(rs.getDate("expiry_date"));
        product.setSupplierId(rs.getInt("supplier_id"));
        product.setDescription(rs.getString("description"));
        product.setCategoryId(rs.getInt("category_id"));
        product.setMaterial(rs.getString("material"));
        product.setUsage(rs.getString("usage"));
        product.setSize(rs.getString("size"));
        
        // Nếu có category_name và supplier_name trong query
        try {
            product.setCategoryName(rs.getString("category_name"));
        } catch (SQLException e) {
            // Column không tồn tại, bỏ qua
        }
        
        try {
            product.setSupplierName(rs.getString("supplier_name"));
        } catch (SQLException e) {
            // Column không tồn tại, bỏ qua
        }
        
        return product;
    }

    // Lấy tất cả sản phẩm
    public List<Product> getAllProducts() {
        List<Product> products = new ArrayList<>();
        String sql = "SELECT * FROM Products ORDER BY product_id DESC";

        try (Connection con = DBConnection.getConnection(); 
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                products.add(mapProductFromResultSet(rs));
            }
        } catch (SQLException ex) {
            System.err.println("Get all products error: " + ex.getMessage());
        }
        return products;
    }

    // Lấy sản phẩm với phân trang
    public List<Product> getProductsByPage(int offset, int limit) {
        List<Product> products = new ArrayList<>();
        String sql = "SELECT p.*, pc.name AS category_name, s.name_Company AS supplier_name " +
                    "FROM Products p " +
                    "LEFT JOIN ProductCategory pc ON p.category_id = pc.category_id " +
                    "LEFT JOIN Supplier s ON p.supplier_id = s.supplier_id " +
                    "ORDER BY p.product_id DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";

        try (Connection con = DBConnection.getConnection(); 
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setInt(1, offset);
            ps.setInt(2, limit);
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    products.add(mapProductFromResultSet(rs));
                }
            }
        } catch (SQLException ex) {
            System.err.println("Get products by page error: " + ex.getMessage());
            ex.printStackTrace();
        }
        return products;
    }

    // Đếm tổng số sản phẩm
    public int countAllProducts() {
        String sql = "SELECT COUNT(*) FROM Products";

        try (Connection con = DBConnection.getConnection(); 
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException ex) {
            System.err.println("Count products error: " + ex.getMessage());
        }
        return 0;
    }

    // Lấy sản phẩm theo ID
    public Product getProductById(int productId) {
        String sql = "SELECT p.*, pc.name AS category_name, s.name_Company AS supplier_name " +
                    "FROM Products p " +
                    "LEFT JOIN ProductCategory pc ON p.category_id = pc.category_id " +
                    "LEFT JOIN Supplier s ON p.supplier_id = s.supplier_id " +
                    "WHERE p.product_id = ?";

        try (Connection con = DBConnection.getConnection(); 
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setInt(1, productId);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapProductFromResultSet(rs);
                }
            }
        } catch (SQLException ex) {
            System.err.println("Get product by ID error: " + ex.getMessage());
        }
        return null;
    }

    // Tìm kiếm sản phẩm với phân trang
    public List<Product> searchProducts(String keyword, int offset, int limit) {
        List<Product> products = new ArrayList<>();
        String sql = "SELECT p.*, pc.name AS category_name, s.name_Company AS supplier_name " +
                    "FROM Products p " +
                    "LEFT JOIN ProductCategory pc ON p.category_id = pc.category_id " +
                    "LEFT JOIN Supplier s ON p.supplier_id = s.supplier_id " +
                    "WHERE p.name LIKE ? OR p.description LIKE ? OR p.product_type LIKE ? OR pc.name LIKE ? " +
                    "ORDER BY p.product_id DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";

        try (Connection con = DBConnection.getConnection(); 
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            String searchPattern = "%" + keyword + "%";
            ps.setString(1, searchPattern);
            ps.setString(2, searchPattern);
            ps.setString(3, searchPattern);
            ps.setString(4, searchPattern);
            ps.setInt(5, offset);
            ps.setInt(6, limit);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    products.add(mapProductFromResultSet(rs));
                }
            }
        } catch (SQLException ex) {
            System.err.println("Search products error: " + ex.getMessage());
        }
        return products;
    }

    // Đếm kết quả tìm kiếm
    public int countSearchProducts(String keyword) {
        String sql = "SELECT COUNT(*) FROM Products p " +
                    "LEFT JOIN ProductCategory pc ON p.category_id = pc.category_id " +
                    "WHERE p.name LIKE ? OR p.description LIKE ? OR p.product_type LIKE ? OR pc.name LIKE ?";

        try (Connection con = DBConnection.getConnection(); 
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            String searchPattern = "%" + keyword + "%";
            ps.setString(1, searchPattern);
            ps.setString(2, searchPattern);
            ps.setString(3, searchPattern);
            ps.setString(4, searchPattern);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException ex) {
            System.err.println("Count search products error: " + ex.getMessage());
        }
        return 0;
    }

    // Lọc sản phẩm với phân trang
    public List<Product> filterProducts(String categoryId, String supplierId, String minPrice, String maxPrice, int offset, int limit) {
        List<Product> products = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT p.*, pc.name AS category_name, s.name_company AS supplier_name " +
                                            "FROM Products p " +
                                            "LEFT JOIN ProductCategory pc ON p.category_id = pc.category_id " +
                                            "LEFT JOIN Supplier s ON p.supplier_id = s.supplier_id " +
                                            "WHERE 1=1");

        if (categoryId != null && !categoryId.trim().isEmpty()) {
            sql.append(" AND p.category_id = ?");
        }
        if (supplierId != null && !supplierId.trim().isEmpty()) {
            sql.append(" AND p.supplier_id = ?");
        }
        if (minPrice != null && !minPrice.trim().isEmpty()) {
            sql.append(" AND p.price >= ?");
        }
        if (maxPrice != null && !maxPrice.trim().isEmpty()) {
            sql.append(" AND p.price <= ?");
        }

        sql.append(" ORDER BY p.product_id DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");

        try (Connection con = DBConnection.getConnection(); 
             PreparedStatement ps = con.prepareStatement(sql.toString())) {
            
            int paramIndex = 1;

            if (categoryId != null && !categoryId.trim().isEmpty()) {
                ps.setInt(paramIndex++, Integer.parseInt(categoryId));
            }
            if (supplierId != null && !supplierId.trim().isEmpty()) {
                ps.setInt(paramIndex++, Integer.parseInt(supplierId));
            }
            if (minPrice != null && !minPrice.trim().isEmpty()) {
                ps.setDouble(paramIndex++, Double.parseDouble(minPrice));
            }
            if (maxPrice != null && !maxPrice.trim().isEmpty()) {
                ps.setDouble(paramIndex++, Double.parseDouble(maxPrice));
            }

            ps.setInt(paramIndex++, offset);
            ps.setInt(paramIndex++, limit);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    products.add(mapProductFromResultSet(rs));
                }
            }
        } catch (SQLException ex) {
            System.err.println("Filter products error: " + ex.getMessage());
        }
        return products;
    }

    // Đếm kết quả lọc
    public int countFilterProducts(String categoryId, String supplierId, String minPrice, String maxPrice) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM Products p WHERE 1=1");

        if (categoryId != null && !categoryId.trim().isEmpty()) {
            sql.append(" AND p.category_id = ?");
        }
        if (supplierId != null && !supplierId.trim().isEmpty()) {
            sql.append(" AND p.supplier_id = ?");
        }
        if (minPrice != null && !minPrice.trim().isEmpty()) {
            sql.append(" AND p.price >= ?");
        }
        if (maxPrice != null && !maxPrice.trim().isEmpty()) {
            sql.append(" AND p.price <= ?");
        }

        try (Connection con = DBConnection.getConnection(); 
             PreparedStatement ps = con.prepareStatement(sql.toString())) {
            
            int paramIndex = 1;

            if (categoryId != null && !categoryId.trim().isEmpty()) {
                ps.setInt(paramIndex++, Integer.parseInt(categoryId));
            }
            if (supplierId != null && !supplierId.trim().isEmpty()) {
                ps.setInt(paramIndex++, Integer.parseInt(supplierId));
            }
            if (minPrice != null && !minPrice.trim().isEmpty()) {
                ps.setDouble(paramIndex++, Double.parseDouble(minPrice));
            }
            if (maxPrice != null && !maxPrice.trim().isEmpty()) {
                ps.setDouble(paramIndex++, Double.parseDouble(maxPrice));
            }

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException ex) {
            System.err.println("Count filter products error: " + ex.getMessage());
        }
        return 0;
    }

    // Lấy đánh giá sản phẩm (nếu có bảng Review liên kết với Products)
    public List<Review> getProductReviews(int productId) {
        List<Review> reviews = new ArrayList<>();
        String sql = "SELECT r.review_id, r.customer_id, r.rating, r.comment, r.created_at, c.name as customer_name " +
                    "FROM Review r " +
                    "JOIN Customer c ON r.customer_id = c.customer_id " +
                    "WHERE r.product_id = ? " +
                    "ORDER BY r.created_at DESC";

        try (Connection con = DBConnection.getConnection(); 
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setInt(1, productId);

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
            System.err.println("Get product reviews error: " + e.getMessage());
        }
        return reviews;
    }

    // Kiểm tra tồn kho
    public boolean checkStockAvailability(int productId, int quantity) {
        String sql = "SELECT stock_quantity FROM Products WHERE product_id = ?";

        try (Connection con = DBConnection.getConnection(); 
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setInt(1, productId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("stock_quantity") >= quantity;
                }
            }
        } catch (SQLException ex) {
            System.err.println("Check stock availability error: " + ex.getMessage());
        }
        return false;
    }
}

