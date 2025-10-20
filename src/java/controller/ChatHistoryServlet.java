package controller;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;
import model.ChatHistory;

@WebServlet(name = "ChatHistoryServlet", urlPatterns = {"/chathistory"})
public class ChatHistoryServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/html;charset=UTF-8");
        HttpSession session = request.getSession(false);
        List<ChatHistory> messages = session != null ? (List<ChatHistory>) session.getAttribute("chatMessages") : null;

        try (PrintWriter out = response.getWriter()) {
            if (messages != null) {
                for (ChatHistory chat : messages) {
                    String prefix = chat.isUser() ? "👤" : "🤖";
                    String cls = chat.isUser() ? "user-msg" : "bot-msg";
                    out.printf("<div class='%s'>%s %s</div>%n", cls, prefix, chat.getMessage());
                }
            }
        }
    }
}
