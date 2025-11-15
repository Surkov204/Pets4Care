package service;

import dao.IProductDAO;
import dao.ProductDAO;
import model.Product;

import java.util.List;
import model.Review;

public class ProductService implements IProductService {

    private IProductDAO productDAO = new ProductDAO();

    @Override
    public List<Product> getAllProducts() {
        return productDAO.getAllProducts();
    }

    @Override
    public List<Product> getProductsByPage(int offset, int limit) {
        return productDAO.getProductsByPage(offset, limit);
    }

    @Override
    public int countAllProducts() {
        return productDAO.countAllProducts();
    }

    @Override
    public Product getProductById(int id) {
        return productDAO.getProductById(id);
    }

    @Override
    public boolean checkStockAvailability(int productId, int quantity) {
        return productDAO.checkStockAvailability(productId, quantity);
    }

    @Override
    public List<Review> getProductReviews(int productId) {
        return productDAO.getProductReviews(productId);
    }

    @Override
    public List<String> searchProductNames(String query) {
        return productDAO.searchProductNames(query);
    }

    @Override
    public List<Product> searchProducts(String keyword) {
        return productDAO.searchProducts(keyword);
    }

    @Override
    public List<Product> searchProductsByKeyword(String keyword) {
        return productDAO.searchProductsByKeyword(keyword);
    }

    @Override
    public List<Product> searchProductsByKeywordAndCategory(String keyword, int categoryId) {
        return productDAO.searchProductsByKeywordAndCategory(keyword, categoryId);
    }

    @Override
    public List<Product> getProductsByCategoryId(int categoryId) {
        return productDAO.getProductsByCategoryId(categoryId);
    }

    @Override
    public List<Product> getProductsByCategory(int categoryId) {
        return productDAO.getProductsByCategory(categoryId);
    }

    @Override
    public boolean softDelete(int productId) {
        return productDAO.softDelete(productId);
    }

    @Override
    public int addProduct(Product product) {
        return productDAO.addProduct(product);
    }

    @Override
    public int getLastInsertedId() {
        return productDAO.getLastInsertedId();
    }

    @Override
    public boolean deleteProduct(int productId) {
        return productDAO.deleteProduct(productId);
    }

    @Override
    public boolean updateProduct(Product product) {
        return productDAO.updateProduct(product);
    }

    @Override
    public List<Product> searchProductsByNameOrIdAndCategory(String keyword, int categoryId) {
        return productDAO.searchProductsByNameOrIdAndCategory(keyword, categoryId);
    }

    @Override
    public double getAverageRating(int productId) {
        return productDAO.getAverageRating(productId);
    }

    @Override
    public List<Product> getSimilarProducts(int categoryId, int excludeProductId, int limit) {
        return productDAO.getSimilarProducts(categoryId, excludeProductId, limit);
    }

    @Override
    public String getProductNameById(int productId) {
        return productDAO.getProductNameById(productId);
    }

    @Override
    public List<Review> getReviewsByProductId(int productId) {
        return productDAO.getReviewsByProductId(productId);
    }

    // Thêm các method còn thiếu cho StaffProductServlet
    public List<Product> searchProducts(String keyword, int offset, int limit) {
        List<Product> allResults = productDAO.searchProducts(keyword);
        int start = Math.min(offset, allResults.size());
        int end = Math.min(offset + limit, allResults.size());
        return allResults.subList(start, end);
    }

    public int countSearchProducts(String keyword) {
        return productDAO.searchProducts(keyword).size();
    }

    public List<Product> filterProducts(String categoryId, String supplierId, String minPrice, String maxPrice, int offset, int limit) {
        // Implement filtering logic here
        List<Product> allProducts = productDAO.getAllProducts();
        // Simple filtering implementation
        return allProducts.subList(offset, Math.min(offset + limit, allProducts.size()));
    }

    public int countFilterProducts(String categoryId, String supplierId, String minPrice, String maxPrice) {
        // Implement counting logic here
        return productDAO.countAllProducts();
    }
}

