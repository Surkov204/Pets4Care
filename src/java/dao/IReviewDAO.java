package dao;

import model.Review;
import java.util.List;

public interface IReviewDAO {
    List<Review> listByProduct(int productId, int limit);
    void add(Review r);
    boolean hasPurchasedAndCompleted(int customerId, int productId);

}
