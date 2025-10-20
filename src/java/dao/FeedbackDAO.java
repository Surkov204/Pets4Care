package dao;

import java.sql.*;
import java.util.*;
import model.Feedback;

public class FeedbackDAO implements IFeedbackDAO {
    @Override
    public void addFeedback(Feedback feedback) {
        try (Connection conn = utils.DBConnection.getConnection()) {
            String sql = "INSERT INTO chat_feedback (user_id, question, answer, feedback, created_at) VALUES (?, ?, ?, ?, GETDATE())";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, feedback.getUserId());
                ps.setString(2, feedback.getQuestion());
                ps.setString(3, feedback.getAnswer());
                ps.setString(4, feedback.getFeedback());
                ps.executeUpdate();
            }
        } catch (Exception e) { e.printStackTrace(); }
    }

    @Override
    public List<Feedback> getFeedbackStats() {
        List<Feedback> list = new ArrayList<>();
        try (Connection conn = utils.DBConnection.getConnection()) {
            String sql = "SELECT feedback, COUNT(*) as count FROM chat_feedback GROUP BY feedback";
            try (PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Feedback fb = new Feedback();
                    fb.setFeedback(rs.getString("feedback"));
                    fb.setCount(rs.getInt("count"));
                    list.add(fb);
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    @Override
    public List<Feedback> getTopLikedAnswers(int limit) {
        List<Feedback> list = new ArrayList<>();
        try (Connection conn = utils.DBConnection.getConnection()) {
            String sql = "SELECT TOP " + limit + " answer, COUNT(*) as likes FROM chat_feedback WHERE feedback='like' GROUP BY answer ORDER BY likes DESC";
            try (PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Feedback fb = new Feedback();
                    fb.setAnswer(rs.getString("answer"));
                    fb.setCount(rs.getInt("likes"));
                    list.add(fb);
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    @Override
    public List<Feedback> getTopDislikedAnswers(int limit) {
        List<Feedback> list = new ArrayList<>();
        try (Connection conn = utils.DBConnection.getConnection()) {
            String sql = "SELECT TOP " + limit + " answer, COUNT(*) as dislikes FROM chat_feedback WHERE feedback='dislike' GROUP BY answer ORDER BY dislikes DESC";
            try (PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Feedback fb = new Feedback();
                    fb.setAnswer(rs.getString("answer"));
                    fb.setCount(rs.getInt("dislikes"));
                    list.add(fb);
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }
} 