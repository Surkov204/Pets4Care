package service;

import dao.ProductDAO;
import model.Product;
import model.Review;
import java.util.List;

public class ProductService {
    
    private ProductDAO productDAO = new ProductDAO();

    // Lấy tất cả sản phẩm
    public List<Product> getAllProducts() {
        return productDAO.getAllProducts();
    }

    // Lấy sản phẩm với phân trang
    public List<Product> getProductsByPage(int offset, int limit) {
        return productDAO.getProductsByPage(offset, limit);
    }

    // Đếm tổng số sản phẩm
    public int countAllProducts() {
        return productDAO.countAllProducts();
    }

    // Lấy sản phẩm theo ID
    public Product getProductById(int productId) {
        return productDAO.getProductById(productId);
    }

    // Tìm kiếm sản phẩm với phân trang
    public List<Product> searchProducts(String keyword, int offset, int limit) {
        return productDAO.searchProducts(keyword, offset, limit);
    }

    // Đếm kết quả tìm kiếm
    public int countSearchProducts(String keyword) {
        return productDAO.countSearchProducts(keyword);
    }

    // Lọc sản phẩm với phân trang
    public List<Product> filterProducts(String categoryId, String supplierId, String minPrice, String maxPrice, int offset, int limit) {
        return productDAO.filterProducts(categoryId, supplierId, minPrice, maxPrice, offset, limit);
    }

    // Đếm kết quả lọc
    public int countFilterProducts(String categoryId, String supplierId, String minPrice, String maxPrice) {
        return productDAO.countFilterProducts(categoryId, supplierId, minPrice, maxPrice);
    }

    // Lấy đánh giá sản phẩm
    public List<Review> getProductReviews(int productId) {
        return productDAO.getProductReviews(productId);
    }

    // Kiểm tra tồn kho
    public boolean checkStockAvailability(int productId, int quantity) {
        return productDAO.checkStockAvailability(productId, quantity);
    }
}

