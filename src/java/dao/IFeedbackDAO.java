package dao;

import java.util.List;
import model.Feedback;

public interface IFeedbackDAO {
    void addFeedback(Feedback feedback);
    List<Feedback> getFeedbackStats(); // tổng hợp feedback
    List<Feedback> getTopLikedAnswers(int limit);
    List<Feedback> getTopDislikedAnswers(int limit);
} 