package service;

import model.Review;
import java.util.List;

public interface IReviewService {
    List<Review> listByProduct(int productId, int limit);
    void add(Review r);
    boolean hasPurchasedAndCompleted(int customerId, int productId);

}
