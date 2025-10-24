/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;

import dao.ShiftRequestDAO;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/staff/rejectShiftRequest")
public class RejectShiftRequestController extends HttpServlet {

    private final ShiftRequestDAO shiftDAO = new ShiftRequestDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        int requestId = Integer.parseInt(request.getParameter("requestId"));
        shiftDAO.updateStatus(requestId, "RejectedByTo", null);
        HttpSession session = request.getSession();
        session.setAttribute("swapSuccess", "Bạn đã từ chối yêu cầu đổi ca.");
        response.sendRedirect(request.getContextPath() + "/staff/dashboard.jsp");
    }
}
