package service;

import dao.IReviewDAO;
import dao.ReviewDAO;
import model.Review;

import java.util.List;

public class ReviewService1 implements IReviewService {

    private final IReviewDAO dao = new ReviewDAO();

    @Override
    public List<Review> listByToy(int toyId, int limit) {
        return dao.listByToy(toyId, limit);
    }

    @Override
    public void add(Review r) {
        dao.add(r);
    }
    
    @Override
    public boolean hasPurchasedAndCompleted(int customerId, int toyId) {
        return dao.hasPurchasedAndCompleted(customerId, toyId);
    }

    
}
