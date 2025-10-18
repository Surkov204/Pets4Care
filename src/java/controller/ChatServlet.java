package controller;

import com.google.gson.Gson;
import dao.ChatDAO;
import model.ChatMessage;
import utils.DBConnection;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.util.List;
import java.util.Map;

@WebServlet("/chat")
public class ChatServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        if (action == null) {
            response.sendError(400, "Missing action parameter");
            return;
        }

        switch (action.toLowerCase()) {
            case "get":
                handleGetMessages(request, response);
                break;
            case "getsessions":
                handleGetSessions(request, response);
                break;
            default:
                response.setStatus(HttpServletResponse.SC_NO_CONTENT);
        }
    }

    // ========================= [GET] Load messages =========================
    private void handleGetMessages(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        response.setContentType("text/html;charset=UTF-8");
        int customerId;
        try {
            customerId = Integer.parseInt(request.getParameter("customerId"));
        } catch (Exception e) {
            response.sendError(400, "Invalid customerId");
            return;
        }

        try (Connection conn = DBConnection.getConnection()) {
            if (conn == null) {
                response.sendError(500, "Database connection failed");
                return;
            }

            ChatDAO dao = new ChatDAO(conn);
            List<ChatMessage> messages = dao.getMessagesByCustomer(customerId);

            try (PrintWriter out = response.getWriter()) {
                for (ChatMessage msg : messages) {
                    String cls = msg.getSenderType().equalsIgnoreCase("customer")
                            ? "received"
                            : "sent";
                    out.printf("<div class='message %s'><div class='bubble'>%s</div></div>",
                            cls, escapeHtml(msg.getMessage()));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(500, "Error loading messages: " + e.getMessage());
        }
    }

    // ========================= [GET] Get chat sessions (for staff) =========================
    private void handleGetSessions(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        response.setContentType("application/json;charset=UTF-8");

        try (Connection conn = DBConnection.getConnection()) {
            ChatDAO dao = new ChatDAO(conn);
            List<Map<String, Object>> sessions = dao.getChatSessions();

            new com.google.gson.Gson().toJson(sessions, response.getWriter());
            System.out.println("✅ [ChatServlet] Đã gửi JSON danh sách chat sessions");
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().write("[]");
        }
    }

    // ========================= [POST] Send message =========================
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        if (!"send".equalsIgnoreCase(action)) {
            response.setStatus(HttpServletResponse.SC_NO_CONTENT);
            return;
        }

        try (Connection conn = DBConnection.getConnection()) {
            if (conn == null) {
                response.sendError(500, "Database connection failed");
                return;
            }

            ChatDAO dao = new ChatDAO(conn);
            ChatMessage msg = new ChatMessage();

            msg.setCustomerId(Integer.parseInt(request.getParameter("customerId")));
            String staffIdStr = request.getParameter("staffId");
            msg.setStaffId(staffIdStr != null && !staffIdStr.isEmpty()
                    ? Integer.parseInt(staffIdStr)
                    : null);
            msg.setSenderType(request.getParameter("senderType"));
            msg.setMessage(request.getParameter("message"));

            dao.addMessage(msg);
            response.setStatus(HttpServletResponse.SC_OK);
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(500, e.getMessage());
        }
        

    }

    // ========================= Helper =========================
    private String escapeHtml(String text) {
        if (text == null) {
            return "";
        }
        return text.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;");
    }
}
