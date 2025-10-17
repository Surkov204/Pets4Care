package service;

import model.Product;
import java.util.List;
import model.Review;

public interface IProductService {

    List<Product> getAllProducts();

    List<Product> getProductsByPage(int offset, int limit);

    int countAllProducts();

    Product getProductById(int id);

    boolean checkStockAvailability(int productId, int quantity);

    List<Review> getProductReviews(int productId);

    List<String> searchProductNames(String query);

    List<Product> searchProducts(String keyword);

    List<Product> searchProductsByKeyword(String keyword);

    List<Product> searchProductsByKeywordAndCategory(String keyword, int categoryId);

    List<Product> getProductsByCategoryId(int categoryId);

    List<Product> getProductsByCategory(int categoryId);

    boolean softDelete(int productId);

    int addProduct(Product product);

    int getLastInsertedId();

    boolean deleteProduct(int productId);

    boolean updateProduct(Product product);

    List<Product> searchProductsByNameOrIdAndCategory(String keyword, int categoryId);

    double getAverageRating(int productId);

    List<Product> getSimilarProducts(int categoryId, int excludeProductId, int limit);

    String getProductNameById(int productId);

    List<Review> getReviewsByProductId(int productId);
}

