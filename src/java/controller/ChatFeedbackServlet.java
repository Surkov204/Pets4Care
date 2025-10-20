package controller;

import dao.FeedbackDAO;
import model.Customer;
import model.Feedback;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.time.LocalDateTime;

@WebServlet(name = "ChatFeedbackServlet", urlPatterns = {"/chatfeedback"})
public class ChatFeedbackServlet extends HttpServlet {
    private final FeedbackDAO feedbackDAO = new FeedbackDAO();
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        String question = request.getParameter("question");
        String answer = request.getParameter("answer");
        String feedback = request.getParameter("feedback");
        String userId = "anonymous";
        if (request.getSession(false) != null && request.getSession(false).getAttribute("currentUser") != null) {
            Customer c = (Customer) request.getSession(false).getAttribute("currentUser");
            userId = String.valueOf(c.getCustomerId());
        }
        Feedback fb = new Feedback();
        fb.setUserId(userId);
        fb.setQuestion(question);
        fb.setAnswer(answer);
        fb.setFeedback(feedback);
        fb.setCreatedAt(LocalDateTime.now());
        feedbackDAO.addFeedback(fb);
        response.getWriter().write("OK");
    }
}