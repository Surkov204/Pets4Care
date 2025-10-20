package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import service.SpaBookingService;
import model.Customer;
import model.Booking;
import model.BookingServiceItem;

import java.io.IOException;
import java.sql.Timestamp;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Logger;
import model.PetServiceModel;

/**
 * Controller cho Spa Booking
 * Tích hợp với Cart hiện có
 * @author ASUS
 */
@WebServlet("/spa-booking")
public class SpaBookingServlet extends HttpServlet {
    
    private static final Logger logger = Logger.getLogger(SpaBookingServlet.class.getName());
    
    private SpaBookingService spaBookingService;
    
    @Override
    public void init() throws ServletException {
        super.init();
        this.spaBookingService = new SpaBookingService();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        Customer customer = (Customer) session.getAttribute("currentUser");
        
        if (customer == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        
        try {
            String action = request.getParameter("action");
            
            if (action == null || action.equals("services")) {
                // Hiển thị danh sách dịch vụ Spa
                showSpaServices(request, response);
            } else if (action.equals("cart")) {
                // Hiển thị giỏ hàng Spa
                showSpaCart(request, response, customer);
            } else if (action.equals("history")) {
                // Hiển thị lịch sử đặt lịch Spa
                showSpaBookingHistory(request, response, customer);
            } else if (action.equals("detail")) {
                // Hiển thị chi tiết booking Spa
                showSpaBookingDetail(request, response, customer);
            }
            
        } catch (Exception e) {
            logger.severe("Error in SpaBookingServlet doGet: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "Có lỗi xảy ra: " + e.getMessage());
            request.getRequestDispatcher("/error.jsp").forward(request, response);
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        Customer customer = (Customer) session.getAttribute("currentUser");
        
        if (customer == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        
        try {
            String action = request.getParameter("action");
            
            if (action != null && action.equals("add-to-cart")) {
                // Thêm dịch vụ Spa vào giỏ hàng
                addSpaServiceToCart(request, response, customer);
            } else if (action != null && action.equals("create-booking")) {
                // Tạo booking Spa từ giỏ hàng
                createSpaBookingFromCart(request, response, customer);
            } else if (action != null && action.equals("cancel")) {
                // Hủy booking Spa
                cancelSpaBooking(request, response, customer);
            }
            
        } catch (Exception e) {
            logger.severe("Error in SpaBookingServlet doPost: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "Có lỗi xảy ra: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/spa-booking?action=cart");
        }
    }
    
    /**
     * Hiển thị danh sách dịch vụ Spa
     */
    private void showSpaServices(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        logger.info("=== DEBUG SPA BOOKING SERVLET ===");
        List<PetServiceModel> spaServices = spaBookingService.getActiveSpaServices();
        logger.info("Spa services loaded: " + (spaServices != null ? spaServices.size() : "null"));
        
        if (spaServices != null && !spaServices.isEmpty()) {
            for (PetServiceModel service : spaServices) {
                logger.info("Service: " + service.getName() + " - " + service.getPrice());
            }
        } else {
            logger.warning("No spa services found!");
        }
        
        request.setAttribute("spaServices", spaServices);
        
        request.getRequestDispatcher("/spa-service.jsp").forward(request, response);
    }
    
    /**
     * Hiển thị giỏ hàng Spa
     */
    private void showSpaCart(HttpServletRequest request, HttpServletResponse response, Customer customer) 
            throws ServletException, IOException {
        
        // Lấy giỏ hàng Spa từ session
        @SuppressWarnings("unchecked")
        Map<Integer, Integer> spaCart = (Map<Integer, Integer>) request.getSession().getAttribute("spaCart");
        
        if (spaCart == null || spaCart.isEmpty()) {
            request.setAttribute("spaCart", new HashMap<Integer, Integer>());
            request.setAttribute("spaServices", new ArrayList<model.PetServiceModel>());
            request.setAttribute("totalPrice", 0);
            request.setAttribute("totalDuration", 0);
        } else {
            List<model.PetServiceModel> spaServices = new ArrayList<>();
            List<Integer> serviceIds = new ArrayList<>();
            List<Integer> quantities = new ArrayList<>();
            
            for (Map.Entry<Integer, Integer> entry : spaCart.entrySet()) {
                int serviceId = entry.getKey();
                int quantity = entry.getValue();
                
                model.PetServiceModel service = spaBookingService.getSpaServiceById(serviceId);
                if (service != null) {
                    spaServices.add(service);
                    serviceIds.add(serviceId);
                    quantities.add(quantity);
                }
            }
            
            // Tính tổng giá và thời gian
            int totalDuration = spaBookingService.calculateTotalDuration(serviceIds);
            java.math.BigDecimal totalPrice = spaBookingService.calculateSpaBookingTotal(serviceIds, quantities);
            
            request.setAttribute("spaCart", spaCart);
            request.setAttribute("spaServices", spaServices);
            request.setAttribute("totalPrice", totalPrice);
            request.setAttribute("totalDuration", totalDuration);
        }
        
        request.getRequestDispatcher("/spa-cart.jsp").forward(request, response);
    }
    
    /**
     * Hiển thị lịch sử đặt lịch Spa
     */
    private void showSpaBookingHistory(HttpServletRequest request, HttpServletResponse response, Customer customer) 
            throws ServletException, IOException {
        
        List<Booking> spaBookings = spaBookingService.getSpaBookingsByCustomerId(customer.getCustomerId());
        
        request.setAttribute("spaBookings", spaBookings);
        
        request.getRequestDispatcher("/spa-booking-history.jsp").forward(request, response);
    }
    
    /**
     * Hiển thị chi tiết booking Spa
     */
    private void showSpaBookingDetail(HttpServletRequest request, HttpServletResponse response, Customer customer) 
            throws ServletException, IOException {
        
        String bookingIdParam = request.getParameter("id");
        if (bookingIdParam == null || bookingIdParam.trim().isEmpty()) {
            request.setAttribute("error", "Không tìm thấy booking");
            response.sendRedirect(request.getContextPath() + "/spa-booking?action=history");
            return;
        }
        
        try {
            int bookingId = Integer.parseInt(bookingIdParam);
            Booking booking = spaBookingService.getSpaBookingsByCustomerId(customer.getCustomerId())
                    .stream()
                    .filter(b -> b.getBookingId() == bookingId)
                    .findFirst()
                    .orElse(null);
            
            if (booking == null) {
                request.setAttribute("error", "Không tìm thấy booking hoặc bạn không có quyền xem");
                response.sendRedirect(request.getContextPath() + "/spa-booking?action=history");
                return;
            }
            
            // Lấy chi tiết dịch vụ Spa
            List<BookingServiceItem> spaBookingDetails = spaBookingService.getSpaBookingDetails(bookingId);
            
            request.setAttribute("booking", booking);
            request.setAttribute("spaBookingDetails", spaBookingDetails);
            
            request.getRequestDispatcher("/spa-booking-detail.jsp").forward(request, response);
            
        } catch (NumberFormatException e) {
            request.setAttribute("error", "ID booking không hợp lệ");
            response.sendRedirect(request.getContextPath() + "/spa-booking?action=history");
        }
    }
    
    /**
     * Thêm dịch vụ Spa vào giỏ hàng
     */
    private void addSpaServiceToCart(HttpServletRequest request, HttpServletResponse response, Customer customer) 
            throws ServletException, IOException {
        
        try {
            String serviceIdParam = request.getParameter("serviceId");
            String quantityParam = request.getParameter("quantity");
            
            if (serviceIdParam == null || quantityParam == null) {
                request.setAttribute("error", "Thiếu thông tin dịch vụ");
                response.sendRedirect(request.getContextPath() + "/spa-booking?action=services");
                return;
            }
            
            int serviceId = Integer.parseInt(serviceIdParam);
            int quantity = Integer.parseInt(quantityParam);
            
            if (quantity <= 0) {
                request.setAttribute("error", "Số lượng phải lớn hơn 0");
                response.sendRedirect(request.getContextPath() + "/spa-booking?action=services");
                return;
            }
            
            // Validate dịch vụ Spa
            if (!spaBookingService.validateSpaService(serviceId)) {
                request.setAttribute("error", "Dịch vụ không hợp lệ hoặc không còn hoạt động");
                response.sendRedirect(request.getContextPath() + "/spa-booking?action=services");
                return;
            }
            
            // Lấy giỏ hàng Spa từ session
            @SuppressWarnings("unchecked")
            Map<Integer, Integer> spaCart = (Map<Integer, Integer>) request.getSession().getAttribute("spaCart");
            
            if (spaCart == null) {
                spaCart = new HashMap<>();
            }
            
            // Thêm hoặc cập nhật số lượng
            spaCart.put(serviceId, quantity);
            request.getSession().setAttribute("spaCart", spaCart);
            
            request.setAttribute("success", "Đã thêm dịch vụ vào giỏ hàng Spa");
            response.sendRedirect(request.getContextPath() + "/spa-booking?action=cart");
            
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Dữ liệu không hợp lệ");
            response.sendRedirect(request.getContextPath() + "/spa-booking?action=services");
        }
    }
    
    /**
     * Tạo booking Spa từ giỏ hàng
     */
    private void createSpaBookingFromCart(HttpServletRequest request, HttpServletResponse response, Customer customer) 
            throws ServletException, IOException {
        
        try {
            // Lấy giỏ hàng Spa từ session
            @SuppressWarnings("unchecked")
            Map<Integer, Integer> spaCart = (Map<Integer, Integer>) request.getSession().getAttribute("spaCart");
            
            if (spaCart == null || spaCart.isEmpty()) {
                request.setAttribute("error", "Giỏ hàng Spa trống");
                response.sendRedirect(request.getContextPath() + "/spa-booking?action=cart");
                return;
            }
            
            // Lấy thông tin đặt lịch
            String appointmentDate = request.getParameter("appointmentDate");
            String appointmentTime = request.getParameter("appointmentTime");
            String note = request.getParameter("note");
            
            if (appointmentDate == null || appointmentTime == null) {
                request.setAttribute("error", "Vui lòng chọn ngày và giờ hẹn");
                response.sendRedirect(request.getContextPath() + "/spa-booking?action=cart");
                return;
            }
            
            // Parse thời gian hẹn
            SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm");
            Timestamp appointmentStart;
            try {
                appointmentStart = new Timestamp(dateFormat.parse(appointmentDate + " " + appointmentTime).getTime());
            } catch (ParseException e) {
                request.setAttribute("error", "Thời gian hẹn không hợp lệ");
                response.sendRedirect(request.getContextPath() + "/spa-booking?action=cart");
                return;
            }
            
            // Tạo booking
            boolean success = spaBookingService.createSpaBookingFromCart(customer, spaCart, appointmentStart, note);
            
            if (success) {
                // Xóa giỏ hàng Spa sau khi đặt lịch thành công
                request.getSession().removeAttribute("spaCart");
                request.setAttribute("success", "Đặt lịch Spa thành công! Chúng tôi sẽ liên hệ lại để xác nhận.");
                response.sendRedirect(request.getContextPath() + "/spa-booking?action=history");
            } else {
                request.setAttribute("error", "Đặt lịch Spa thất bại. Vui lòng thử lại.");
                response.sendRedirect(request.getContextPath() + "/spa-booking?action=cart");
            }
            
        } catch (Exception e) {
            logger.severe("Error creating spa booking from cart: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "Có lỗi xảy ra khi đặt lịch: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/spa-booking?action=cart");
        }
    }
    
    /**
     * Hủy booking Spa
     */
    private void cancelSpaBooking(HttpServletRequest request, HttpServletResponse response, Customer customer) 
            throws ServletException, IOException {
        
        String bookingIdParam = request.getParameter("bookingId");
        if (bookingIdParam == null || bookingIdParam.trim().isEmpty()) {
            request.setAttribute("error", "Không tìm thấy booking");
            response.sendRedirect(request.getContextPath() + "/spa-booking?action=history");
            return;
        }
        
        try {
            int bookingId = Integer.parseInt(bookingIdParam);
            
            // Kiểm tra quyền sở hữu
            List<Booking> customerBookings = spaBookingService.getSpaBookingsByCustomerId(customer.getCustomerId());
            boolean hasBooking = customerBookings.stream()
                    .anyMatch(b -> b.getBookingId() == bookingId);
            
            if (!hasBooking) {
                request.setAttribute("error", "Không tìm thấy booking hoặc bạn không có quyền hủy");
                response.sendRedirect(request.getContextPath() + "/spa-booking?action=history");
                return;
            }
            
            // Kiểm tra có thể hủy không
            if (!spaBookingService.canCancelSpaBooking(bookingId)) {
                request.setAttribute("error", "Không thể hủy booking này");
                response.sendRedirect(request.getContextPath() + "/spa-booking?action=history");
                return;
            }
            
            // Hủy booking
            boolean success = spaBookingService.cancelSpaBooking(bookingId);
            
            if (success) {
                request.setAttribute("success", "Hủy đặt lịch Spa thành công");
            } else {
                request.setAttribute("error", "Hủy đặt lịch Spa thất bại");
            }
            
            response.sendRedirect(request.getContextPath() + "/spa-booking?action=history");
            
        } catch (NumberFormatException e) {
            request.setAttribute("error", "ID booking không hợp lệ");
            response.sendRedirect(request.getContextPath() + "/spa-booking?action=history");
        }
    }
}
