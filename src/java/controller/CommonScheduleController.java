package controller;

import dao.WorkScheduleDAO;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.Map;
import java.util.List;

@WebServlet("/staff/commonSchedule")
public class CommonScheduleController extends HttpServlet {
    private final WorkScheduleDAO workDAO = new WorkScheduleDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Map<String, List<String>> commonSchedule = workDAO.getCommonSchedule();
        request.setAttribute("commonSchedule", commonSchedule);
        request.getRequestDispatcher("/staff/commonSchedule.jsp").forward(request, response);
    }
}
