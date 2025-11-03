package service;

import dao.IReviewDAO;
import dao.ReviewDAO;
import model.Review;

import java.util.List;

public class ReviewService implements IReviewService {

    private final IReviewDAO dao = new ReviewDAO();

    @Override
    public List<Review> listByProduct(int productId, int limit) {
        return dao.listByProduct(productId, limit);
    }

    @Override
    public void add(Review r) {
        dao.add(r);
    }
    
    @Override
    public boolean hasPurchasedAndCompleted(int customerId, int productId) {
        return dao.hasPurchasedAndCompleted(customerId, productId);
    }

    @Override
    public List<Review> listByService(int serviceId, int limit) {
        return dao.listByService(serviceId, limit);
    }

    @Override
    public boolean hasCompletedBooking(int customerId, int serviceId, int bookingId) {
        return dao.hasCompletedBooking(customerId, serviceId, bookingId);
    }

    @Override
    public Review getReviewByBooking(int bookingId, int serviceId, int customerId) {
        return dao.getReviewByBooking(bookingId, serviceId, customerId);
    }
    
}
