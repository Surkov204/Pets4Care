
package controller;

import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.util.Map;
import service.IStatisticService;
import service.StatisticService;

@WebServlet(name = "StatisticServlet", urlPatterns = {"/admin/statistics"})
public class StatisticServlet extends HttpServlet {

    private final IStatisticService service = new StatisticService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String type = request.getParameter("type"); // "day", "month", "year"
        Map<String, Double> data;

        switch (type != null ? type : "day") {
            case "year":
                data = service.getYearlyRevenue();
                break;
            case "month":
                data = service.getMonthlyRevenue();
                break;
            default:
                data = service.getDailyRevenue();
                break;
        }

        // Tính tổng doanh thu
        double totalRevenue = data.values().stream().mapToDouble(Double::doubleValue).sum();

        request.setAttribute("revenueData", data);
        request.setAttribute("type", type);
        // Trong StatisticServlet.java
        request.setAttribute("totalRevenueFormatted", String.format("%,.0f", totalRevenue));
        request.getRequestDispatcher("/admin/statistic.jsp").forward(request, response);

    }

}