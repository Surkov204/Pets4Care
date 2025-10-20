package model;
import java.time.LocalDateTime;

public class Feedback {
    private String userId;
    private String question;
    private String answer;
    private String feedback;
    private LocalDateTime createdAt;
    private int count;

    // Getters & Setters
    public String getUserId() { return userId; }
    public void setUserId(String userId) { this.userId = userId; }
    public String getQuestion() { return question; }
    public void setQuestion(String question) { this.question = question; }
    public String getAnswer() { return answer; }
    public void setAnswer(String answer) { this.answer = answer; }
    public String getFeedback() { return feedback; }
    public void setFeedback(String feedback) { this.feedback = feedback; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    public int getCount() { return count; }
    public void setCount(int count) { this.count = count; }
} 