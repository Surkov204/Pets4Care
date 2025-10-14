package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import service.IToyService;
import service.ToyService;
import model.Toy;

import java.io.IOException;
import java.util.List;

@WebServlet("/staff-home")
public class StaffHomeServlet extends HttpServlet {
    
    private IToyService toyService;
    private static final int PAGE_SIZE = 12;

    @Override
    public void init() throws ServletException {
        toyService = new ToyService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Xử lý phân trang
        int page = 1;
        String pageRaw = request.getParameter("page");
        if (pageRaw != null) {
            try {
                page = Integer.parseInt(pageRaw);
                if (page < 1) page = 1;
            } catch (NumberFormatException e) {
                page = 1;
            }
        }

        int offset = (page - 1) * PAGE_SIZE;
        int totalToys = toyService.countAllToys();
        int totalPages = (int) Math.ceil((double) totalToys / PAGE_SIZE);

        List<Toy> toys = toyService.getToysByPage(offset, PAGE_SIZE);

        request.setAttribute("toys", toys);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);

        request.getRequestDispatcher("staff/dashboard.jsp").forward(request, response);
    }
}

