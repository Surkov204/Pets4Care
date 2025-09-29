package dao;

import model.Review;
import java.util.List;

public interface IReviewDAO {
    List<Review> listByToy(int toyId, int limit);
    void add(Review r);
    boolean hasPurchasedAndCompleted(int customerId, int toyId);

}
