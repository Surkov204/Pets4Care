package controller.staff;

import dao.BoardingBookingDAO;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;
import model.BoardingBooking;

@WebServlet("/staff/boarding-management")
public class BoardingManagementServlet extends HttpServlet {

    private final BoardingBookingDAO dao = new BoardingBookingDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String status = req.getParameter("status");
        String keyword = req.getParameter("keyword");

        List<BoardingBooking> bookings = dao.getBookings(status, keyword);
        req.setAttribute("bookings", bookings);

        req.getRequestDispatcher("/staff/boarding-management.jsp").forward(req, resp);
    }
}