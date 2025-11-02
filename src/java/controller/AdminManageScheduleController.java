/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;

import dao.WorkScheduleDAO;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/admin/manageSchedule")
public class AdminManageScheduleController extends HttpServlet {

    private final WorkScheduleDAO dao = new WorkScheduleDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        String action = req.getParameter("action");

        switch (action) {
            case "assign" -> {
                int staffId = Integer.parseInt(req.getParameter("staffId"));
                String date = req.getParameter("date");
                int shiftId = Integer.parseInt(req.getParameter("shiftType"));
                dao.assignShift(staffId, date, shiftId);
            }
            case "unassign" -> {
                int scheduleId = Integer.parseInt(req.getParameter("scheduleId"));
                dao.deleteSchedule(scheduleId);
            }
        }

        resp.sendRedirect(req.getContextPath() + "/admin/manage-staff.jsp?tab=worktable");
    }
}
