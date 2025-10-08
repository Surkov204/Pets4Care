package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import dao.BookingDAO;
import dao.StaffDAO;
import model.Booking;
import model.Staff;

import java.io.IOException;
import java.sql.Date;
import java.util.List;
import java.util.Map;
import java.util.logging.Logger;

@WebServlet("/staff/bookings")
public class BookingServlet extends HttpServlet {
    private BookingDAO bookingDAO = new BookingDAO();
    private StaffDAO staffDAO = new StaffDAO();
    private static final Logger logger = Logger.getLogger(BookingServlet.class.getName());

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Kiểm tra xác thực staff
        if (!isStaffAuthenticated(request)) {
            response.sendRedirect(request.getContextPath() + "/login.jsp?error=staff_required");
            return;
        }

        try {
            String action = request.getParameter("action");
            if (action == null) {
                action = "list";
            }

            switch (action) {
                case "list":
                    handleListBookings(request, response);
                    break;
                case "view":
                    // Nếu có id thì xem chi tiết, không có thì xem danh sách
                    String bookingId = request.getParameter("id");
                    if (bookingId != null && !bookingId.isEmpty()) {
                        handleViewBooking(request, response);
                    } else {
                        handleListBookings(request, response);
                    }
                    break;
                case "search":
                    handleSearchBookings(request, response);
                    break;
                case "filter":
                    handleFilterBookings(request, response);
                    break;
                default:
                    handleListBookings(request, response);
                    break;
            }
        } catch (Exception e) {
            logger.severe("Error in BookingServlet: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "Có lỗi xảy ra: " + e.getMessage());
            request.getRequestDispatcher("/staff/booking-list.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Kiểm tra xác thực staff
        if (!isStaffAuthenticated(request)) {
            response.sendRedirect(request.getContextPath() + "/login.jsp?error=staff_required");
            return;
        }

        try {
            String action = request.getParameter("action");
            if (action == null) {
                response.sendRedirect(request.getContextPath() + "/staff/bookings");
                return;
            }

            switch (action) {
                case "update_status":
                    handleUpdateStatus(request, response);
                    break;
                case "assign_staff":
                    handleAssignStaff(request, response);
                    break;
                default:
                    response.sendRedirect(request.getContextPath() + "/staff/bookings");
                    break;
            }
        } catch (Exception e) {
            logger.severe("Error in BookingServlet POST: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "Có lỗi xảy ra: " + e.getMessage());
            request.getRequestDispatcher("/staff/booking-list.jsp").forward(request, response);
        }
    }

    private boolean isStaffAuthenticated(HttpServletRequest request) {
        HttpSession session = request.getSession();
        Staff staff = (Staff) session.getAttribute("staff");
        return staff != null;
    }

   private void handleListBookings(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {

    logger.info("Handling list bookings request");

    int page = 1;
    int limit = 10;

    try {
        String p = request.getParameter("page");
        String l = request.getParameter("limit");
        if (p != null) page = Integer.parseInt(p);
        if (l != null) limit = Integer.parseInt(l);
    } catch (NumberFormatException ignore) {}

    if (page < 1) page = 1;
    if (limit < 1) limit = 10;

    List<Booking> bookings = bookingDAO.getAllBookings();
    int totalBookings = bookings.size();

    if (totalBookings == 0) {
        request.setAttribute("bookings", java.util.Collections.emptyList());
        request.setAttribute("currentPage", 1);
        request.setAttribute("totalPages", 1);
        request.setAttribute("totalBookings", 0);
        request.setAttribute("action", "list");
        request.getRequestDispatcher("/staff/booking-list.jsp").forward(request, response);
        return;
    }

    int totalPages = (int) Math.ceil(totalBookings / (double) limit);
    if (page > totalPages) page = totalPages;

    int startIndex = (page - 1) * limit;
    int endIndex = Math.min(startIndex + limit, totalBookings);

    List<Booking> pagedBookings = bookings.subList(startIndex, endIndex);

    request.setAttribute("bookings", pagedBookings);
    request.setAttribute("currentPage", page);
    request.setAttribute("totalPages", totalPages);
    request.setAttribute("totalBookings", totalBookings);
    request.setAttribute("action", "list");

    request.getRequestDispatcher("/staff/booking-list.jsp").forward(request, response);
}

    private void handleViewBooking(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String bookingIdStr = request.getParameter("id");
        if (bookingIdStr == null || bookingIdStr.isEmpty()) {
            request.setAttribute("error", "ID booking không hợp lệ");
            request.getRequestDispatcher("/staff/booking-list.jsp").forward(request, response);
            return;
        }

        try {
            int bookingId = Integer.parseInt(bookingIdStr);
            Booking booking = bookingDAO.getBookingById(bookingId);
            
            if (booking == null) {
                request.setAttribute("error", "Không tìm thấy booking với ID: " + bookingId);
            } else {
                request.setAttribute("booking", booking);
            }
            
            request.getRequestDispatcher("/staff/booking-detail.jsp").forward(request, response);
        } catch (NumberFormatException e) {
            request.setAttribute("error", "ID booking không hợp lệ");
            request.getRequestDispatcher("/staff/booking-list.jsp").forward(request, response);
        }
    }

    private void handleSearchBookings(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String keyword = request.getParameter("keyword");
        if (keyword == null || keyword.trim().isEmpty()) {
            handleListBookings(request, response);
            return;
        }

        logger.info("Searching bookings with keyword: " + keyword);
        
        List<Booking> bookings = bookingDAO.searchBookings(keyword.trim());

        request.setAttribute("bookings", bookings);
        request.setAttribute("keyword", keyword);
        request.setAttribute("action", "search");

        logger.info("Found " + bookings.size() + " bookings matching keyword: " + keyword);
        
        request.getRequestDispatcher("/staff/booking-list.jsp").forward(request, response);
    }

    private void handleFilterBookings(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String status = request.getParameter("status");
        String dateFrom = request.getParameter("dateFrom");
        String dateTo = request.getParameter("dateTo");
        
        List<Booking> bookings;
        
        if (status != null && !status.isEmpty()) {
            logger.info("Filtering bookings by status: " + status);
            bookings = bookingDAO.getBookingsByStatus(status);
        } else if (dateFrom != null && !dateFrom.isEmpty() && dateTo != null && !dateTo.isEmpty()) {
            logger.info("Filtering bookings by date range: " + dateFrom + " to " + dateTo);
            bookings = bookingDAO.getBookingsByDateRange(Date.valueOf(dateFrom), Date.valueOf(dateTo));
        } else if (dateFrom != null && !dateFrom.isEmpty()) {
            logger.info("Filtering bookings by date: " + dateFrom);
            bookings = bookingDAO.getBookingsByDate(Date.valueOf(dateFrom));
        } else {
            handleListBookings(request, response);
            return;
        }

        request.setAttribute("bookings", bookings);
        request.setAttribute("selectedStatus", status);
        request.setAttribute("selectedDateFrom", dateFrom);
        request.setAttribute("selectedDateTo", dateTo);
        request.setAttribute("action", "filter");

        logger.info("Found " + bookings.size() + " bookings matching filter criteria");
        
        request.getRequestDispatcher("/staff/booking-list.jsp").forward(request, response);
    }


    private void handleUpdateStatus(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String bookingIdStr = request.getParameter("bookingId");
        String newStatus = request.getParameter("status");
        
        if (bookingIdStr == null || newStatus == null) {
            request.setAttribute("error", "Thông tin không đầy đủ");
            handleListBookings(request, response);
            return;
        }

        try {
            int bookingId = Integer.parseInt(bookingIdStr);
            boolean success = bookingDAO.updateBookingStatus(bookingId, newStatus);
            
            if (success) {
                request.setAttribute("success", "Cập nhật trạng thái thành công");
                logger.info("Updated booking " + bookingId + " status to " + newStatus);
            } else {
                request.setAttribute("error", "Cập nhật trạng thái thất bại");
            }
        } catch (NumberFormatException e) {
            request.setAttribute("error", "ID booking không hợp lệ");
        }

        handleListBookings(request, response);
    }

    private void handleAssignStaff(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String bookingIdStr = request.getParameter("bookingId");
        String staffIdStr = request.getParameter("staffId");
        
        if (bookingIdStr == null || staffIdStr == null) {
            request.setAttribute("error", "Thông tin không đầy đủ");
            handleListBookings(request, response);
            return;
        }

        try {
            int bookingId = Integer.parseInt(bookingIdStr);
            int staffId = Integer.parseInt(staffIdStr);
            
            Booking booking = bookingDAO.getBookingById(bookingId);
            if (booking != null) {
                booking.setStaffId(staffId);
                boolean success = bookingDAO.updateBooking(booking);
                
                if (success) {
                    request.setAttribute("success", "Phân công nhân viên thành công");
                    logger.info("Assigned staff " + staffId + " to booking " + bookingId);
                } else {
                    request.setAttribute("error", "Phân công nhân viên thất bại");
                }
            } else {
                request.setAttribute("error", "Không tìm thấy booking");
            }
        } catch (NumberFormatException e) {
            request.setAttribute("error", "ID không hợp lệ");
        }

        handleListBookings(request, response);
    }
}
