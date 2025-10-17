package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import dao.BookingDAO;
import dao.IBookingDAO;
import model.Booking;
import model.Staff;

import java.io.IOException;
import java.util.List;

@WebServlet("/staff/services-booking")
public class ServicesBookingServlet extends HttpServlet {
    
    private IBookingDAO bookingDAO = new BookingDAO();
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        Staff staff = (Staff) session.getAttribute("staff");
        
        if (staff == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        
        try {
            String action = request.getParameter("action");
            String keyword = request.getParameter("keyword");
            String status = request.getParameter("status");
            
            List<Booking> bookings = null;
            
            if (action != null && action.equals("view")) {
                // Xem chi tiết booking
                String bookingIdStr = request.getParameter("id");
                if (bookingIdStr != null) {
                    int bookingId = Integer.parseInt(bookingIdStr);
                    Booking booking = bookingDAO.getBookingById(bookingId);
                    if (booking != null) {
                        request.setAttribute("booking", booking);
                        request.getRequestDispatcher("/staff/booking-detail.jsp").forward(request, response);
                        return;
                    }
                }
            }
            
            // Lấy danh sách booking theo điều kiện
            if (keyword != null && !keyword.trim().isEmpty()) {
                bookings = bookingDAO.searchBookings(keyword.trim());
            } else if (status != null && !status.trim().isEmpty()) {
                bookings = bookingDAO.getBookingsByStatus(status.trim());
            } else {
                bookings = bookingDAO.getAllBookings();
            }
            
            request.setAttribute("bookings", bookings);
            request.setAttribute("keyword", keyword);
            request.setAttribute("status", status);
            
            request.getRequestDispatcher("/staff/services-booking.jsp").forward(request, response);
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Có lỗi xảy ra khi tải dữ liệu: " + e.getMessage());
            request.getRequestDispatcher("/staff/services-booking.jsp").forward(request, response);
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        Staff staff = (Staff) session.getAttribute("staff");
        
        if (staff == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        
        try {
            String action = request.getParameter("action");
            
            if (action != null && action.equals("update_status")) {
                String bookingIdStr = request.getParameter("bookingId");
                String newStatus = request.getParameter("status");
                
                if (bookingIdStr != null && newStatus != null) {
                    int bookingId = Integer.parseInt(bookingIdStr);
                    boolean success = bookingDAO.updateBookingStatus(bookingId, newStatus);
                    
                    if (success) {
                        request.setAttribute("success", "Cập nhật trạng thái thành công!");
                    } else {
                        request.setAttribute("error", "Cập nhật trạng thái thất bại!");
                    }
                }
            }
            
            // Redirect về GET để refresh trang
            response.sendRedirect(request.getContextPath() + "/staff/services-booking");
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Có lỗi xảy ra: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/staff/services-booking");
        }
    }
}
