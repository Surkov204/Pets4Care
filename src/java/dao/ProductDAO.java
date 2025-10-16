package dao;

import model.Product;
import utils.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import model.Review;

public class ProductDAO implements IProductDAO {

    @Override
    public List<Product> getAllProducts() {
        List<Product> products = new ArrayList<>();
        String sql = "SELECT p.product_id, p.name, p.price, p.category_id, p.stock_quantity, p.supplier_id, p.description, p.admin_id, " +
                    "pc.name as category_name, s.name_Company as supplier_name " +
                    "FROM Products p " +
                    "LEFT JOIN ProductCategory pc ON p.category_id = pc.category_id " +
                    "LEFT JOIN Supplier s ON p.supplier_id = s.supplier_id " +
                    "ORDER BY p.product_id";

        try (Connection con = DBConnection.getConnection(); 
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                Product product = mapProductWithDetailsFromResultSet(rs);
                products.add(product);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return products;
    }

    @Override
    public List<Product> getProductsByPage(int offset, int limit) {
        List<Product> products = new ArrayList<>();
        String sql = "SELECT p.product_id, p.name, p.price, p.category_id, p.stock_quantity, p.supplier_id, p.description, p.admin_id, " +
                    "pc.name as category_name, s.name_Company as supplier_name " +
                    "FROM Products p " +
                    "LEFT JOIN ProductCategory pc ON p.category_id = pc.category_id " +
                    "LEFT JOIN Supplier s ON p.supplier_id = s.supplier_id " +
                    "ORDER BY p.product_id OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";

        System.out.println("=== DEBUG getProductsByPage ===");
        System.out.println("SQL: " + sql);
        System.out.println("Offset: " + offset + ", Limit: " + limit);

        try (Connection con = DBConnection.getConnection(); 
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            System.out.println("Connection: " + (con != null ? "SUCCESS" : "FAILED"));
            
            ps.setInt(1, offset);
            ps.setInt(2, limit);
            
            try (ResultSet rs = ps.executeQuery()) {
                System.out.println("Executing query...");
                while (rs.next()) {
                    Product product = mapProductWithDetailsFromResultSet(rs);
                    products.add(product);
                    System.out.println("Added product: " + product.getName());
                }
                System.out.println("Total products found: " + products.size());
            }

        } catch (Exception e) {
            System.err.println("Error in getProductsByPage: " + e.getMessage());
            e.printStackTrace();
        }

        return products;
    }

    @Override
    public Product getProductById(int productId) {
        String sql = "SELECT p.product_id, p.name, p.price, p.category_id, p.stock_quantity, p.supplier_id, p.description, p.admin_id, " +
                    "pc.name as category_name, s.name_Company as supplier_name " +
                    "FROM Products p " +
                    "LEFT JOIN ProductCategory pc ON p.category_id = pc.category_id " +
                    "LEFT JOIN Supplier s ON p.supplier_id = s.supplier_id " +
                    "WHERE p.product_id = ?";

        try (Connection con = DBConnection.getConnection(); 
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setInt(1, productId);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapProductWithDetailsFromResultSet(rs);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }

    @Override
    public List<Product> searchProducts(String keyword) {
        List<Product> products = new ArrayList<>();
        String sql = "SELECT p.product_id, p.name, p.price, p.category_id, p.stock_quantity, p.supplier_id, p.description, p.admin_id, " +
                    "pc.name as category_name, s.name_Company as supplier_name " +
                    "FROM Products p " +
                    "LEFT JOIN ProductCategory pc ON p.category_id = pc.category_id " +
                    "LEFT JOIN Supplier s ON p.supplier_id = s.supplier_id " +
                    "WHERE p.name LIKE ? OR p.description LIKE ?";

        try (Connection con = DBConnection.getConnection(); 
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            String searchPattern = "%" + keyword + "%";
            ps.setString(1, searchPattern);
            ps.setString(2, searchPattern);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Product product = mapProductWithDetailsFromResultSet(rs);
                    products.add(product);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return products;
    }

    @Override
    public List<Product> filterProducts(String category, String priceRange, String sortBy) {
        List<Product> products = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT p.product_id, p.name, p.price, p.category_id, p.stock_quantity, p.supplier_id, p.description, p.admin_id, " +
                    "pc.name as category_name, s.name_Company as supplier_name " +
                    "FROM Products p " +
                    "LEFT JOIN ProductCategory pc ON p.category_id = pc.category_id " +
                    "LEFT JOIN Supplier s ON p.supplier_id = s.supplier_id " +
                    "WHERE 1=1");
        
        if (category != null && !category.isEmpty()) {
            sql.append(" AND p.category_id = ?");
        }
        
        if (priceRange != null && !priceRange.isEmpty()) {
            switch (priceRange) {
                case "0-100000":
                    sql.append(" AND p.price BETWEEN 0 AND 100000");
                    break;
                case "100000-500000":
                    sql.append(" AND p.price BETWEEN 100000 AND 500000");
                    break;
                case "500000+":
                    sql.append(" AND p.price > 500000");
                    break;
            }
        }
        
        if (sortBy != null && !sortBy.isEmpty()) {
            switch (sortBy) {
                case "price_asc":
                    sql.append(" ORDER BY p.price ASC");
                    break;
                case "price_desc":
                    sql.append(" ORDER BY p.price DESC");
                    break;
                case "name":
                    sql.append(" ORDER BY p.name ASC");
                    break;
                default:
                    sql.append(" ORDER BY p.product_id ASC");
                    break;
            }
        } else {
            sql.append(" ORDER BY p.product_id ASC");
        }

        try (Connection con = DBConnection.getConnection(); 
             PreparedStatement ps = con.prepareStatement(sql.toString())) {
            
            int paramIndex = 1;
            if (category != null && !category.isEmpty()) {
                ps.setInt(paramIndex++, Integer.parseInt(category));
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Product product = mapProductWithDetailsFromResultSet(rs);
                    products.add(product);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return products;
    }
    
    public List<Product> filterProductsByStock(String stockStatus) {
        List<Product> products = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT p.product_id, p.name, p.price, p.category_id, p.stock_quantity, p.supplier_id, p.description, p.admin_id, " +
                    "pc.name as category_name, s.name_Company as supplier_name " +
                    "FROM Products p " +
                    "LEFT JOIN ProductCategory pc ON p.category_id = pc.category_id " +
                    "LEFT JOIN Supplier s ON p.supplier_id = s.supplier_id " +
                    "WHERE 1=1");
        
        switch (stockStatus) {
            case "high":
                sql.append(" AND p.stock_quantity > 50");
                break;
            case "low":
                sql.append(" AND p.stock_quantity BETWEEN 1 AND 50");
                break;
            case "out":
                sql.append(" AND p.stock_quantity = 0");
                break;
        }
        
        sql.append(" ORDER BY p.stock_quantity DESC, p.product_id ASC");

        try (Connection con = DBConnection.getConnection(); 
             PreparedStatement ps = con.prepareStatement(sql.toString())) {

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Product product = mapProductWithDetailsFromResultSet(rs);
                    products.add(product);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return products;
    }

    @Override
    public List<Review> getProductReviews(int productId) {
        List<Review> reviews = new ArrayList<>();
        String sql = "SELECT * FROM Review WHERE product_id = ? ORDER BY review_date DESC";

        try (Connection con = DBConnection.getConnection(); 
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setInt(1, productId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Review review = new Review();
                    review.setReviewId(rs.getInt("review_id"));
                    review.setCustomerId(rs.getInt("customer_id"));
                    review.setProductId(rs.getInt("product_id"));
                    review.setRating(rs.getInt("rating"));
                    review.setComment(rs.getString("comment"));
                    review.setCreatedAt(rs.getTimestamp("review_date"));
                    reviews.add(review);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return reviews;
    }

    @Override
    public boolean checkStockAvailability(int productId, int quantity) {
        String sql = "SELECT stock_quantity FROM Products WHERE product_id = ?";

        try (Connection con = DBConnection.getConnection(); 
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setInt(1, productId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int stockQuantity = rs.getInt("stock_quantity");
                    return stockQuantity >= quantity;
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    @Override
    public int countAllProducts() {
        String sql = "SELECT COUNT(*) FROM Products";

        try (Connection con = DBConnection.getConnection(); 
             PreparedStatement ps = con.prepareStatement(sql); 
             ResultSet rs = ps.executeQuery()) {

            if (rs.next()) {
                return rs.getInt(1);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return 0;
    }

    @Override
    public List<String> searchProductNames(String query) {
        List<String> names = new ArrayList<>();
        String sql = "SELECT DISTINCT name FROM Products WHERE name LIKE ? ORDER BY name";

        try (Connection con = DBConnection.getConnection(); 
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, "%" + query + "%");

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
    public Map<Integer, String> getAllCategoriesMap() {
        Map<Integer, String> categories = new HashMap<>();
        String sql = "SELECT category_id, name FROM ProductCategory";

        try (Connection con = DBConnection.getConnection(); 
             PreparedStatement ps = con.prepareStatement(sql); 
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                categories.put(rs.getInt("category_id"), rs.getString("name"));
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return categories;
    }

    @Override
    public List<Product> getProductsByCategory(int categoryId) {
        List<Product> products = new ArrayList<>();
        String sql = "SELECT * FROM Products WHERE category_id = ?";

        try (Connection con = DBConnection.getConnection(); 
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, categoryId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Product product = mapProductFromResultSet(rs);
                    products.add(product);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return products;
    }

    @Override
    public List<Product> searchProductsByKeyword(String keyword) {
        return searchProducts(keyword);
    }

    @Override
    public List<Product> searchProductsByKeywordAndCategory(String keyword, int categoryId) {
        List<Product> products = new ArrayList<>();
        String sql = "SELECT * FROM Products WHERE (name LIKE ? OR description LIKE ?) AND category_id = ?";

        try (Connection con = DBConnection.getConnection(); 
             PreparedStatement ps = con.prepareStatement(sql)) {

            String searchPattern = "%" + keyword + "%";
            ps.setString(1, searchPattern);
            ps.setString(2, searchPattern);
            ps.setInt(3, categoryId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Product product = mapProductFromResultSet(rs);
                    products.add(product);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return products;
    }

    public String getProductNameById(int productId) {
        String sql = "SELECT name FROM Products WHERE product_id = ?";

        try (Connection con = DBConnection.getConnection(); 
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setInt(1, productId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("name");
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return "Unknown Product";
    }

    @Override
    public List<Product> getProductsByCategoryId(int categoryId) {
        return getProductsByCategory(categoryId);
    }

    @Override
    public boolean softDelete(int productId) {
        String sql = "UPDATE Products SET is_deleted = 1 WHERE product_id = ?";
        
        try (Connection con = DBConnection.getConnection(); 
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, productId);
            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    @Override
    public int addProduct(Product product) {
        String sql = "INSERT INTO Products (name, price, category_id, stock_quantity, supplier_id, description, admin_id, image_url) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        
        try (Connection con = DBConnection.getConnection(); 
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setString(1, product.getName());
            ps.setDouble(2, product.getPrice());
            ps.setInt(3, product.getCategoryId());
            ps.setInt(4, product.getStockQuantity());
            ps.setInt(5, product.getSupplierId());
            ps.setString(6, product.getDescription());
            ps.setInt(7, product.getAdminId());
            ps.setString(8, product.getImageUrl());

            int result = ps.executeUpdate();
            
            if (result > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        return rs.getInt(1);
                    }
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return -1;
    }

    @Override
    public int getLastInsertedId() {
        String sql = "SELECT MAX(product_id) FROM Products";
        
        try (Connection con = DBConnection.getConnection(); 
             PreparedStatement ps = con.prepareStatement(sql); 
             ResultSet rs = ps.executeQuery()) {

            if (rs.next()) {
                return rs.getInt(1);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return -1;
    }

    @Override
    public boolean deleteProduct(int productId) {
        String sql = "DELETE FROM Products WHERE product_id = ?";
        
        try (Connection con = DBConnection.getConnection(); 
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, productId);
            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    @Override
    public boolean updateProduct(Product product) {
        String sql = "UPDATE Products SET name = ?, price = ?, category_id = ?, stock_quantity = ?, supplier_id = ?, description = ?, admin_id = ?, image_url = ? WHERE product_id = ?";
        
        try (Connection con = DBConnection.getConnection(); 
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, product.getName());
            ps.setDouble(2, product.getPrice());
            ps.setInt(3, product.getCategoryId());
            ps.setInt(4, product.getStockQuantity());
            ps.setInt(5, product.getSupplierId());
            ps.setString(6, product.getDescription());
            ps.setInt(7, product.getAdminId());
            ps.setString(8, product.getImageUrl());
            ps.setInt(9, product.getProductId());

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    @Override
    public List<Product> searchProductsByNameOrIdAndCategory(String keyword, int categoryId) {
        List<Product> products = new ArrayList<>();
        String sql = "SELECT * FROM Products WHERE (name LIKE ? OR CAST(product_id AS VARCHAR) LIKE ?) AND category_id = ?";

        try (Connection con = DBConnection.getConnection(); 
             PreparedStatement ps = con.prepareStatement(sql)) {

            String searchPattern = "%" + keyword + "%";
            ps.setString(1, searchPattern);
            ps.setString(2, searchPattern);
            ps.setInt(3, categoryId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Product product = mapProductFromResultSet(rs);
                    products.add(product);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return products;
    }

    @Override
    public double getAverageRating(int productId) {
        String sql = "SELECT AVG(CAST(rating AS FLOAT)) FROM Review WHERE product_id = ?";

        try (Connection con = DBConnection.getConnection(); 
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, productId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getDouble(1);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return 0.0;
    }

    @Override
    public List<Product> getSimilarProducts(int categoryId, int excludeProductId, int limit) {
        List<Product> products = new ArrayList<>();
        String sql = "SELECT TOP (?) * FROM Products WHERE category_id = ? AND product_id != ? ORDER BY NEWID()";

        try (Connection con = DBConnection.getConnection(); 
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, limit);
            ps.setInt(2, categoryId);
            ps.setInt(3, excludeProductId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Product product = mapProductFromResultSet(rs);
                    products.add(product);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return products;
    }

    @Override
    public List<Review> getReviewsByProductId(int productId) {
        return getProductReviews(productId);
    }

    private Product mapProductFromResultSet(ResultSet rs) throws SQLException {
        Product product = new Product();
        product.setProductId(rs.getInt("product_id"));
        product.setName(rs.getString("name"));
        product.setPrice(rs.getDouble("price"));
        product.setCategoryId(rs.getInt("category_id"));
        product.setStockQuantity(rs.getInt("stock_quantity"));
        product.setSupplierId(rs.getInt("supplier_id"));
        product.setDescription(rs.getString("description"));
        product.setAdminId(rs.getInt("admin_id"));
        product.setImageUrl(rs.getString("image_url"));
        return product;
    }
    
    private Product mapProductWithDetailsFromResultSet(ResultSet rs) throws SQLException {
        Product product = new Product();
        product.setProductId(rs.getInt("product_id"));
        product.setName(rs.getString("name"));
        product.setPrice(rs.getDouble("price"));
        product.setCategoryId(rs.getInt("category_id"));
        product.setStockQuantity(rs.getInt("stock_quantity"));
        product.setSupplierId(rs.getInt("supplier_id"));
        product.setDescription(rs.getString("description"));
        product.setAdminId(rs.getInt("admin_id"));
        
        // Set additional fields for display
        String categoryName = rs.getString("category_name");
        String supplierName = rs.getString("supplier_name");
        
        System.out.println("Mapping product: " + product.getName() + 
                          ", Category: " + categoryName + 
                          ", Supplier: " + supplierName);
        
        product.setCategoryName(categoryName);
        product.setSupplierName(supplierName);
        
        return product;
    }
}