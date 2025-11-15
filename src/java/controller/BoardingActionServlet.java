package controller.staff;

import dao.BoardingBookingDAO;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.Timestamp;
import java.time.LocalDateTime;

@WebServlet("/boarding-action")
public class BoardingActionServlet extends HttpServlet {

    private final BoardingBookingDAO dao = new BoardingBookingDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String action = req.getParameter("action");
        int bookingId = Integer.parseInt(req.getParameter("bookingId"));

        boolean success = false;

        switch (action) {
            case "accept":
                success = dao.updateStatus(bookingId, "Chờ nhận");
                break;

            case "cancel":
                success = dao.updateStatus(bookingId, "Đã hủy");
                break;

            case "checkin":
                success = dao.updateStatus(bookingId, "Đang sử dụng");
                break;

            case "checkout":
                String date = req.getParameter("actualCheckoutDate");
                Timestamp actualDate = Timestamp.valueOf(date + " 12:00:00");
                success = dao.checkoutEarly(bookingId, actualDate);
                break;
        }

        if (success)
            resp.sendRedirect(req.getContextPath() + "/staff/boarding-management?success=1");
        else
            resp.sendRedirect(req.getContextPath() + "/staff/boarding-management?error=1");
    }
}