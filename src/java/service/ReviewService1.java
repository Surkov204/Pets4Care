package service;

import dao.IReviewDAO;
import dao.ReviewDAO;
import model.Review;

import java.util.List;

public class ReviewService1 implements IReviewService {

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

    
}
