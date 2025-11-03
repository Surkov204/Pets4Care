package service;

import model.Review;
import java.util.List;

public interface IReviewService {
    List<Review> listByProduct(int productId, int limit);
    List<Review> listByService(int serviceId, int limit);
    void add(Review r);
    boolean hasPurchasedAndCompleted(int customerId, int productId);
    boolean hasCompletedBooking(int customerId, int serviceId, int bookingId);
    Review getReviewByBooking(int bookingId, int serviceId, int customerId);
}
