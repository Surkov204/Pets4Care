/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;

import com.google.gson.Gson;
import dao.NotificationDAO;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 *
 * @author Admin
 */
@WebServlet("/notification")
public class NotificationController extends HttpServlet {

    private final NotificationDAO dao = new NotificationDAO();
    private final Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        response.setContentType("application/json;charset=UTF-8");
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("staff") == null) {
            response.getWriter().write("{\"count\":0}");
            return;
        }

        int staffId = ((model.Staff) session.getAttribute("staff")).getStaffId();
        String action = request.getParameter("action");

        switch (action) {
            case "count" -> {
                int count = dao.getUnreadCount(staffId);
                response.getWriter().write("{\"count\":" + count + "}");
            }
            case "list" -> {
                response.getWriter().write(gson.toJson(dao.getNotifications(staffId)));
            }
            default ->
                response.getWriter().write("{\"error\":\"Invalid action\"}");
        }
    }
}
