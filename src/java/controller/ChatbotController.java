package controller;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.*;
import org.json.JSONObject;
import service.ChatbotService;

@WebServlet("/chatbot")
public class ChatbotController extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        response.setContentType("application/json;charset=UTF-8");
        String userMessage = request.getReader().lines().reduce("", (acc, line) -> acc + line);

        // ✅ Lấy API key từ context
        ServletContext context = getServletContext();
        String apiKey = getServletContext().getInitParameter("GEMINI_API_KEY");

        // ✅ Gọi service với key
        String aiReply = ChatbotService.ask(userMessage, apiKey);

        JSONObject json = new JSONObject();
        json.put("reply", aiReply);
        response.getWriter().write(json.toString());

        System.out.println("🔑 API Key: " + apiKey);
    }
}
