package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import service.PayOSService;
import service.BookingService;
import dao.BookingDAO;
import model.Booking;
import model.Customer;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

@WebServlet("/api/payment-status")
public class PaymentStatusServlet extends HttpServlet {

    private final PayOSService payOSService = new PayOSService();
    private final BookingDAO bookingDAO = new BookingDAO();
    private final BookingService bookingService = new BookingService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        try {
            int orderId = Integer.parseInt(request.getParameter("orderId"));
            String type = request.getParameter("type");

            if ("service".equalsIgnoreCase(type)) {
                // Check booking status in database first
                Booking booking = bookingDAO.getBookingById(orderId);
                if (booking != null) {
                    String status = booking.getStatus();
                    if ("Hoàn thành".equals(status) || "completed".equals(status)) {
                        out.print("{\"status\":\"completed\"}");
                    } else if ("pending".equals(status)) {
                        out.print("{\"status\":\"pending\"}");
                    } else {
                        out.print("{\"status\":\"failed\"}");
                    }
                } else {
                    // Booking doesn't exist, check PayOS payment status
                    String payosStatus = payOSService.getPaymentStatusFromPayOS(orderId);
                    if ("PAID".equalsIgnoreCase(payosStatus)) {
                        // Payment completed, create booking from session data
                        HttpSession session = request.getSession();
                        Booking pendingBooking = (Booking) session.getAttribute("pendingBooking");
                        List<Integer> serviceIds = (List<Integer>) session.getAttribute("pendingServiceIds");
                        List<Integer> quantities = (List<Integer>) session.getAttribute("pendingQuantities");
                        Integer tempOrderId = (Integer) session.getAttribute("tempOrderId");

                        if (pendingBooking != null && serviceIds != null && quantities != null && tempOrderId != null && tempOrderId == orderId) {
                            // Set order_id for the booking
                            pendingBooking.setOrderId(orderId);

                            // Create the booking
                            boolean success = bookingService.createBooking(pendingBooking, serviceIds, quantities);
                            if (success) {
                                // Clear session data
                                session.removeAttribute("pendingBooking");
                                session.removeAttribute("pendingServiceIds");
                                session.removeAttribute("pendingQuantities");
                                session.removeAttribute("tempOrderId");

                                out.print("{\"status\":\"completed\"}");
                            } else {
                                out.print("{\"status\":\"failed\"}");
                            }
                        } else {
                            out.print("{\"status\":\"not_found\"}");
                        }
                    } else if ("PENDING".equalsIgnoreCase(payosStatus)) {
                        out.print("{\"status\":\"pending\"}");
                    } else {
                        out.print("{\"status\":\"failed\"}");
                    }
                }
            } else {
                out.print("{\"status\":\"invalid_type\"}");
            }

        } catch (Exception e) {
            e.printStackTrace();
            out.print("{\"status\":\"error\"}");
        }
    }
}