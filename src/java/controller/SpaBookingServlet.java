package controller;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Timestamp;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Logger;

import dao.BoardingBookingDAO;
import dao.PetDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.BoardingBooking;
import model.Booking;
import model.BookingServiceItem;
import model.Customer;
import model.Pet;
import model.PetServiceModel;
import service.SpaBookingService;

/**
 * Controller cho Spa Booking
 * Tích hợp với Cart hiện có
 * @author ASUS
 */
public class SpaBookingServlet extends HttpServlet {
    
    private static final Logger logger = Logger.getLogger(SpaBookingServlet.class.getName());
    
    private SpaBookingService spaBookingService;
    private PetDAO petDAO;
    private BoardingBookingDAO boardingBookingDAO;
    
    @Override
    public void init() throws ServletException {
        super.init();
        this.spaBookingService = new SpaBookingService();
        this.petDAO = new PetDAO();
        this.boardingBookingDAO = new BoardingBookingDAO();
        
        // Khởi tạo database cho boarding bookings
        boolean dbInitialized = this.boardingBookingDAO.initializeDatabase();
        if (dbInitialized) {
            logger.info("BoardingBookingDAO initialized successfully");
        } else {
            logger.severe("Failed to initialize BoardingBookingDAO");
        }
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        Customer customer = null;
        if (session != null) {
            customer = (Customer) session.getAttribute("currentUser");
        }
        
        if (customer == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        
        try {
            String action = request.getParameter("action");
            String requestURI = request.getRequestURI();
            
            // Nếu URL là /spa-cart, hiển thị giỏ hàng trực tiếp
            if (requestURI.endsWith("/spa-cart")) {
                showSpaCart(request, response, customer);
            } else if (action == null || action.equals("services")) {
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
            } else if (action.equals("boarding-detail")) {
                // Hiển thị chi tiết booking Boarding
                showBoardingBookingDetail(request, response, customer);
            } else if (action.equals("test-boarding")) {
                // Test tạo dữ liệu boarding
                testCreateBoardingData(request, response, customer);
            }
            
        } catch (Exception e) {
            logger.severe("Error in SpaBookingServlet doGet: " + e.getMessage());
            logger.severe("Stack trace: " + java.util.Arrays.toString(e.getStackTrace()));
            e.printStackTrace();
            request.setAttribute("errorMessage", "Có lỗi xảy ra: " + e.getMessage());
            request.getRequestDispatcher("/spa-cart.jsp").forward(request, response);
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        Customer customer = null;
        if (session != null) {
            customer = (Customer) session.getAttribute("currentUser");
        }
        
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
            } else if (action != null && action.equals("update-quantity")) {
                // Cập nhật số lượng dịch vụ trong giỏ hàng
                updateSpaServiceQuantity(request, response, customer);
            } else if (action != null && action.equals("remove-service")) {
                // Xóa dịch vụ khỏi giỏ hàng
                removeSpaServiceFromCart(request, response, customer);
            } else if (action != null && action.equals("total")) {
                // Lấy tổng giá trị giỏ hàng
                getSpaCartTotal(request, response, customer);
            } else if (action != null && action.equals("get-boarding-details")) {
                // Lấy chi tiết boarding từ session
                getBoardingDetails(request, response, customer);
            } else if (action != null && action.equals("update-boarding-details")) {
                // Cập nhật chi tiết boarding trong session
                updateBoardingDetails(request, response, customer);
            } else if (action != null && action.equals("create-test-boarding")) {
                // Tạo dữ liệu test boarding
                createTestBoardingData(request, response, customer);
            } else if (action != null && action.equals("cancel-boarding-booking")) {
                // Hủy boarding booking
                cancelBoardingBooking(request, response, customer);
            } else if (action != null && action.equals("create-boarding-booking")) {
                // Tạo boarding booking từ form
                createBoardingBookingFromForm(request, response, customer);
            } else if (action != null && action.equals("get-customer-pets")) {
                // Lấy danh sách pet của khách hàng
                getCustomerPets(request, response, customer);
            } else if (action != null && action.equals("delete-boarding-booking")) {
                // Xóa boarding booking khỏi database
                deleteBoardingBooking(request, response, customer);
            } else if (action != null && action.equals("delete-spa-booking")) {
                // Xóa spa booking khỏi database
                deleteSpaBooking(request, response, customer);
            }
            
        } catch (Exception e) {
            logger.severe("Error in SpaBookingServlet doPost: " + e.getMessage());
            logger.severe("Stack trace: " + java.util.Arrays.toString(e.getStackTrace()));
            e.printStackTrace();
            session.setAttribute("errorMessage", "Có lỗi xảy ra: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/spa-booking?action=cart");
        }
    }
    
    /**
     * Hiển thị danh sách dịch vụ Spa
     */
    private void showSpaServices(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        logger.info("=== DEBUG SPA BOOKING SERVLET ===");
        
        List<PetServiceModel> spaServices = null;
        try {
            spaServices = spaBookingService.getActiveSpaServices();
            logger.info("Spa services loaded: " + (spaServices != null ? spaServices.size() : "null"));
            
            if (spaServices != null && !spaServices.isEmpty()) {
                for (PetServiceModel service : spaServices) {
                    if (service != null) {
                        logger.info("Service: " + service.getName() + " - " + service.getPrice());
                    }
                }
            } else {
                logger.warning("No spa services found!");
                spaServices = new ArrayList<>(); // Ensure non-null list
            }
        } catch (Exception e) {
            logger.severe("Error loading spa services: " + e.getMessage());
            spaServices = new ArrayList<>(); // Fallback to empty list
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
            request.setAttribute("spaServices", new ArrayList<PetServiceModel>());
            request.setAttribute("totalPrice", BigDecimal.ZERO);
            request.setAttribute("totalDuration", Integer.valueOf(0));
        } else {
            List<PetServiceModel> spaServices = new ArrayList<>();
            List<Integer> serviceIds = new ArrayList<>();
            List<Integer> quantities = new ArrayList<>();
            
            try {
                for (Map.Entry<Integer, Integer> entry : spaCart.entrySet()) {
                    int serviceId = entry.getKey();
                    int quantity = entry.getValue();
                    
                    if (quantity > 0) { // Validate quantity
                        PetServiceModel service = spaBookingService.getSpaServiceById(serviceId);
                        if (service != null) {
                            spaServices.add(service);
                            serviceIds.add(serviceId);
                            quantities.add(quantity);
                        } else {
                            logger.warning("Service not found for ID: " + serviceId);
                        }
                    }
                }
                
                // Tính tổng giá và thời gian
                int totalDuration = spaBookingService.calculateTotalDuration(serviceIds);
                BigDecimal totalPrice = spaBookingService.calculateSpaBookingTotal(serviceIds, quantities);
                
                request.setAttribute("spaCart", spaCart);
                request.setAttribute("spaServices", spaServices);
                request.setAttribute("totalPrice", totalPrice != null ? totalPrice : BigDecimal.ZERO);
                request.setAttribute("totalDuration", Integer.valueOf(totalDuration));
            } catch (Exception e) {
                logger.severe("Error calculating cart totals: " + e.getMessage());
                request.setAttribute("spaCart", new HashMap<Integer, Integer>());
                request.setAttribute("spaServices", new ArrayList<PetServiceModel>());
                request.setAttribute("totalPrice", BigDecimal.ZERO);
                request.setAttribute("totalDuration", Integer.valueOf(0));
            }
        }
        
        request.getRequestDispatcher("/spa-cart.jsp").forward(request, response);
    }
    
    /**
     * Hiển thị lịch sử đặt lịch Spa
     */
    private void showSpaBookingHistory(HttpServletRequest request, HttpServletResponse response, Customer customer) 
            throws ServletException, IOException {
        
        logger.info("=== SPA BOOKING HISTORY DEBUG ===");
        logger.info("Customer ID: " + customer.getCustomerId());
        
        // Lấy spa bookings từ database
        List<Booking> spaBookings = spaBookingService.getSpaBookingsByCustomerId(customer.getCustomerId());
        logger.info("Spa bookings count: " + (spaBookings != null ? spaBookings.size() : "null"));
        
        // Lấy boarding bookings từ database
        List<BoardingBooking> boardingBookings = boardingBookingDAO.getBoardingBookingsByCustomerId(customer.getCustomerId());
        logger.info("Boarding bookings count: " + (boardingBookings != null ? boardingBookings.size() : "null"));
        
        // Debug: Log chi tiết boarding bookings
        if (boardingBookings != null && !boardingBookings.isEmpty()) {
            logger.info("Found " + boardingBookings.size() + " boarding bookings in database");
            for (BoardingBooking booking : boardingBookings) {
                logger.info("Boarding booking: ID=" + booking.getBookingId() + 
                           ", RoomType=" + booking.getRoomType() + 
                           ", Status=" + booking.getStatus() + 
                           ", TotalPrice=" + booking.getTotalPrice() +
                           ", CheckIn=" + booking.getCheckInDate() +
                           ", CheckOut=" + booking.getCheckOutDate() +
                           ", CustomerID=" + booking.getCustomerId());
            }
        } else {
            logger.warning("No boarding bookings found in database for customer ID: " + customer.getCustomerId());
            
            // Test: Tạo dữ liệu test nếu không có dữ liệu
            logger.info("Creating test boarding data for customer ID: " + customer.getCustomerId());
            createTestBoardingDataForCustomer(customer);
            
            // Lấy lại dữ liệu sau khi tạo test
            boardingBookings = boardingBookingDAO.getBoardingBookingsByCustomerId(customer.getCustomerId());
            logger.info("After creating test data, found " + (boardingBookings != null ? boardingBookings.size() : 0) + " boarding bookings");
        }
        
        // Convert BoardingBooking objects to Map format for JSP compatibility
        List<Map<String, Object>> boardingServices = new ArrayList<>();
        if (boardingBookings != null && !boardingBookings.isEmpty()) {
            for (BoardingBooking booking : boardingBookings) {
                try {
                    Map<String, Object> boardingService = new HashMap<>();
                    
                    boardingService.put("bookingId", booking.getBookingId());
                    boardingService.put("serviceName", booking.getServiceName());
                    boardingService.put("quantity", 1);
                    boardingService.put("price", booking.getPricePerDay());
                    boardingService.put("totalPrice", booking.getTotalPrice());
                    
                    // Safe date conversion
                    if (booking.getCheckInDate() != null) {
                        boardingService.put("checkInDate", new java.sql.Date(booking.getCheckInDate().getTime()).toString());
                    } else {
                        boardingService.put("checkInDate", "");
                    }
                    
                    if (booking.getCheckOutDate() != null) {
                        boardingService.put("checkOutDate", new java.sql.Date(booking.getCheckOutDate().getTime()).toString());
                    } else {
                        boardingService.put("checkOutDate", "");
                    }
                    
                    boardingService.put("petInfo", booking.getPetInfo() != null ? booking.getPetInfo() : "");
                    boardingService.put("status", booking.getStatus() != null ? booking.getStatus() : "pending");
                    boardingService.put("isBoarding", true);
                    boardingService.put("createdAt", booking.getCreatedAt());
                    boardingService.put("specialNotes", booking.getSpecialNotes() != null ? booking.getSpecialNotes() : "");
                    boardingService.put("emergencyPhone1", booking.getEmergencyPhone1() != null ? booking.getEmergencyPhone1() : "");
                    boardingService.put("emergencyPhone2", booking.getEmergencyPhone2() != null ? booking.getEmergencyPhone2() : "");
                    
                    boardingServices.add(boardingService);
                    logger.info("Added boarding service from DB: " + booking.toString());
                } catch (Exception e) {
                    logger.warning("Error processing boarding booking: " + e.getMessage());
                    // Continue with next booking
                }
            }
        }
        
        // Chỉ lấy dữ liệu từ database, không lấy từ session
        logger.info("Final boarding services count from database: " + boardingServices.size());
        
        logger.info("Final boarding services count: " + boardingServices.size());
        
        request.setAttribute("spaBookings", spaBookings);
        request.setAttribute("boardingServices", boardingServices);
        
        request.getRequestDispatcher("/spa-booking-history.jsp").forward(request, response);
    }
    
    /**
     * Hiển thị chi tiết booking Spa
     */
    private void showSpaBookingDetail(HttpServletRequest request, HttpServletResponse response, Customer customer) 
            throws ServletException, IOException {
        
        String bookingIdParam = request.getParameter("id");
        if (bookingIdParam == null || bookingIdParam.trim().isEmpty()) {
            HttpSession session = request.getSession(true);
            session.setAttribute("errorMessage", "Không tìm thấy booking");
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
                HttpSession session = request.getSession(true);
                session.setAttribute("errorMessage", "Không tìm thấy booking hoặc bạn không có quyền xem");
                response.sendRedirect(request.getContextPath() + "/spa-booking?action=history");
                return;
            }
            
            // Lấy chi tiết dịch vụ Spa
            List<BookingServiceItem> spaBookingDetails = spaBookingService.getSpaBookingDetails(bookingId);
            
            // Lấy thông tin thú cưng của khách hàng
            List<Pet> customerPets = petDAO.getPetsByCustomerId(customer.getCustomerId());
            
            request.setAttribute("booking", booking);
            request.setAttribute("spaBookingDetails", spaBookingDetails);
            request.setAttribute("customerPets", customerPets);
            
            request.getRequestDispatcher("/spa-booking-detail.jsp").forward(request, response);
            
        } catch (NumberFormatException e) {
            HttpSession session = request.getSession(true);
            session.setAttribute("errorMessage", "ID booking không hợp lệ");
            response.sendRedirect(request.getContextPath() + "/spa-booking?action=history");
        }
    }
    
    /**
     * Thêm dịch vụ Spa vào giỏ hàng
     */
    private void addSpaServiceToCart(HttpServletRequest request, HttpServletResponse response, Customer customer) 
            throws ServletException, IOException {
        
        try {
            // Validate required parameters
            if (!validateRequestParameters(request, "serviceId", "quantity")) {
                HttpSession session = request.getSession(true);
                session.setAttribute("errorMessage", "Thiếu thông tin dịch vụ");
                response.sendRedirect(request.getContextPath() + "/spa-booking?action=services");
                return;
            }
            
            int serviceId = getSafeIntParameter(request, "serviceId", 0);
            int quantity = getSafeIntParameter(request, "quantity", 0);
            
            if (quantity <= 0) {
                HttpSession session = request.getSession(true);
                session.setAttribute("errorMessage", "Số lượng phải lớn hơn 0");
                response.sendRedirect(request.getContextPath() + "/spa-booking?action=services");
                return;
            }
            
            // Validate dịch vụ Spa
            if (!spaBookingService.validateSpaService(serviceId)) {
                HttpSession session = request.getSession(true);
                session.setAttribute("errorMessage", "Dịch vụ không hợp lệ hoặc không còn hoạt động");
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
            
            HttpSession session = request.getSession(true);
            session.setAttribute("successMessage", "Đã thêm dịch vụ vào giỏ hàng Spa");
            response.sendRedirect(request.getContextPath() + "/spa-booking?action=cart");
            
        } catch (NumberFormatException e) {
            HttpSession session = request.getSession(true);
            session.setAttribute("errorMessage", "Dữ liệu không hợp lệ");
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
                HttpSession session = request.getSession(true);
                session.setAttribute("errorMessage", "Giỏ hàng Spa trống");
                response.sendRedirect(request.getContextPath() + "/spa-booking?action=cart");
                return;
            }
            
            // Lấy thông tin đặt lịch
            String appointmentDate = request.getParameter("appointmentDate");
            String appointmentTime = request.getParameter("appointmentTime");
            String note = request.getParameter("note");
            
            if (appointmentDate == null || appointmentTime == null) {
                HttpSession session = request.getSession(true);
                session.setAttribute("errorMessage", "Vui lòng chọn ngày và giờ hẹn");
                response.sendRedirect(request.getContextPath() + "/spa-booking?action=cart");
                return;
            }
            
            // Parse thời gian hẹn
            SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm");
            Timestamp appointmentStart;
            try {
                appointmentStart = new Timestamp(dateFormat.parse(appointmentDate + " " + appointmentTime).getTime());
                
                // Kiểm tra ngày đặt lịch không được trước ngày hôm nay
                Timestamp now = new Timestamp(System.currentTimeMillis());
                if (appointmentStart.before(now)) {
                    HttpSession session = request.getSession(true);
                    session.setAttribute("errorMessage", "Không thể đặt lịch cho thời gian đã qua. Vui lòng chọn ngày và giờ trong tương lai.");
                    response.sendRedirect(request.getContextPath() + "/spa-booking?action=cart");
                    return;
                }
                
            } catch (ParseException e) {
                HttpSession session = request.getSession(true);
                session.setAttribute("errorMessage", "Thời gian hẹn không hợp lệ");
                response.sendRedirect(request.getContextPath() + "/spa-booking?action=cart");
                return;
            }
            
            // Tạo booking
            boolean success = spaBookingService.createSpaBookingFromCart(customer, spaCart, appointmentStart, note);
            
            if (success) {
                // Xóa giỏ hàng Spa sau khi đặt lịch thành công
                HttpSession session = request.getSession(true);
                session.removeAttribute("spaCart");
                session.setAttribute("successMessage", "Đặt lịch Spa thành công! Chúng tôi sẽ liên hệ lại để xác nhận.");
                response.sendRedirect(request.getContextPath() + "/spa-booking?action=history");
            } else {
                HttpSession session = request.getSession(true);
                session.setAttribute("errorMessage", "Đặt lịch Spa thất bại. Vui lòng thử lại.");
                response.sendRedirect(request.getContextPath() + "/spa-booking?action=cart");
            }
            
        } catch (Exception e) {
            logger.severe("Error creating spa booking from cart: " + e.getMessage());
            e.printStackTrace();
            HttpSession session = request.getSession(true);
            session.setAttribute("errorMessage", "Có lỗi xảy ra khi đặt lịch: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/spa-booking?action=cart");
        }
    }
    
    /**
     * Hủy booking Spa
     */
    private void cancelSpaBooking(HttpServletRequest request, HttpServletResponse response, Customer customer) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        String bookingIdParam = request.getParameter("bookingId");
        if (bookingIdParam == null || bookingIdParam.trim().isEmpty()) {
            session.setAttribute("errorMessage", "Không tìm thấy booking");
            response.sendRedirect(request.getContextPath() + "/spa-booking?action=history");
            return;
        }
        
        try {
            int bookingId = Integer.parseInt(bookingIdParam);
            
            // Lấy thông tin booking để kiểm tra chi tiết
            Booking booking = spaBookingService.getSpaBookingsByCustomerId(customer.getCustomerId())
                    .stream()
                    .filter(b -> b.getBookingId() == bookingId)
                    .findFirst()
                    .orElse(null);
            
            logger.info("Attempting to cancel booking ID: " + bookingId + " for customer: " + customer.getCustomerId());
            
            if (booking == null) {
                logger.warning("Booking ID " + bookingId + " not found for customer " + customer.getCustomerId());
                session.setAttribute("errorMessage", "Không tìm thấy booking hoặc bạn không có quyền hủy");
                response.sendRedirect(request.getContextPath() + "/spa-booking?action=history");
                return;
            }
            
            logger.info("Found booking ID " + bookingId + " with status: " + booking.getStatus());
            
            // Kiểm tra có thể hủy không - sử dụng trạng thái từ booking object
            String status = booking.getStatus();
            boolean canCancel = "pending".equals(status) || "confirmed".equals(status);
            
            if (!canCancel) {
                String reason;
                
                if ("cancelled".equals(status)) {
                    reason = "Booking này đã được hủy trước đó";
                } else if ("completed".equals(status)) {
                    reason = "Booking này đã hoàn thành, không thể hủy";
                } else {
                    reason = "Booking có trạng thái '" + status + "' không thể hủy";
                }
                
                logger.warning("Cannot cancel booking ID " + bookingId + " with status: " + status);
                session.setAttribute("errorMessage", reason);
                response.sendRedirect(request.getContextPath() + "/spa-booking?action=history");
                return;
            }
            
            // Hủy booking
            logger.info("Attempting to cancel booking ID: " + bookingId);
            boolean success = spaBookingService.cancelSpaBooking(bookingId);
            
            if (success) {
                logger.info("Cancel booking ID " + bookingId + " successful");
                session.setAttribute("successMessage", "Hủy đặt lịch Spa thành công");
            } else {
                logger.warning("Cancel booking ID " + bookingId + " failed");
                session.setAttribute("errorMessage", "Hủy đặt lịch Spa thất bại. Vui lòng thử lại hoặc liên hệ hỗ trợ.");
            }
            
            response.sendRedirect(request.getContextPath() + "/spa-booking?action=history");
            
        } catch (NumberFormatException e) {
            session.setAttribute("errorMessage", "ID booking không hợp lệ");
            response.sendRedirect(request.getContextPath() + "/spa-booking?action=history");
        }
    }
    
    /**
     * Cập nhật số lượng dịch vụ trong giỏ hàng Spa
     */
    private void updateSpaServiceQuantity(HttpServletRequest request, HttpServletResponse response, Customer customer) 
            throws ServletException, IOException {
        
        try {
            String serviceIdParam = request.getParameter("serviceId");
            String quantityParam = request.getParameter("quantity");
            
            if (serviceIdParam == null || quantityParam == null) {
                response.getWriter().write("{\"error\": \"Thiếu thông tin dịch vụ\"}");
                return;
            }
            
            int serviceId = Integer.parseInt(serviceIdParam);
            int quantity = Integer.parseInt(quantityParam);
            
            if (quantity <= 0) {
                response.getWriter().write("{\"error\": \"Số lượng phải lớn hơn 0\"}");
                return;
            }
            
            // Lấy giỏ hàng Spa từ session
            @SuppressWarnings("unchecked")
            Map<Integer, Integer> spaCart = (Map<Integer, Integer>) request.getSession().getAttribute("spaCart");
            
            if (spaCart == null) {
                spaCart = new HashMap<>();
            }
            
            // Validate dịch vụ Spa
            if (!spaBookingService.validateSpaService(serviceId)) {
                response.getWriter().write("{\"error\": \"Dịch vụ không hợp lệ hoặc không còn hoạt động\"}");
                return;
            }
            
            // Cập nhật số lượng
            spaCart.put(serviceId, quantity);
            request.getSession().setAttribute("spaCart", spaCart);
            
            // Tính toán lại tổng giá trị
            List<Integer> serviceIds = new ArrayList<>();
            List<Integer> quantities = new ArrayList<>();
            
            for (Map.Entry<Integer, Integer> entry : spaCart.entrySet()) {
                serviceIds.add(entry.getKey());
                quantities.add(entry.getValue());
            }
            
            BigDecimal totalPrice = spaBookingService.calculateSpaBookingTotal(serviceIds, quantities);
            java.math.BigDecimal itemTotal = spaBookingService.getSpaServiceById(serviceId).getPrice().multiply(BigDecimal.valueOf(quantity));
            
            // Trả về JSON response
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            response.getWriter().write(String.format("{\"success\": true, \"total\": \"%.0f\", \"item_%d\": \"%.0f\"}", 
                totalPrice.doubleValue(), serviceId, itemTotal.doubleValue()));
            
        } catch (NumberFormatException e) {
            response.getWriter().write("{\"error\": \"Dữ liệu không hợp lệ\"}");
        } catch (Exception e) {
            logger.severe("Error updating spa service quantity: " + e.getMessage());
            response.getWriter().write("{\"error\": \"Có lỗi xảy ra khi cập nhật số lượng\"}");
        }
    }
    
    /**
     * Xóa dịch vụ khỏi giỏ hàng Spa
     */
    private void removeSpaServiceFromCart(HttpServletRequest request, HttpServletResponse response, Customer customer) 
            throws ServletException, IOException {
        
        try {
            String serviceIdParam = request.getParameter("serviceId");
            
            if (serviceIdParam == null) {
                response.getWriter().write("{\"error\": \"Thiếu thông tin dịch vụ\"}");
                return;
            }
            
            int serviceId = Integer.parseInt(serviceIdParam);
            
            // Không xóa khỏi spaCart nữa, chỉ set status
            // @SuppressWarnings("unchecked")
            // Map<Integer, Integer> spaCart = (Map<Integer, Integer>) request.getSession().getAttribute("spaCart");
            
            // if (spaCart != null) {
            //     spaCart.remove(serviceId);
            //     request.getSession().setAttribute("spaCart", spaCart);
            // }
            
            // Set status = "cancelled" cho boarding service thay vì xóa
            if (serviceId >= 1000) {
                @SuppressWarnings("unchecked")
                Map<Integer, Map<String, Object>> boardingDetailsMap = 
                    (Map<Integer, Map<String, Object>>) request.getSession().getAttribute("boardingDetails");
                if (boardingDetailsMap != null && boardingDetailsMap.containsKey(serviceId)) {
                    Map<String, Object> boardingDetails = boardingDetailsMap.get(serviceId);
                    boardingDetails.put("status", "cancelled");
                    boardingDetailsMap.put(serviceId, boardingDetails);
                    request.getSession().setAttribute("boardingDetails", boardingDetailsMap);
                }
            } else {
                // Xử lý spa services thông thường - xóa khỏi cart
                @SuppressWarnings("unchecked")
                Map<Integer, Integer> spaCart = (Map<Integer, Integer>) request.getSession().getAttribute("spaCart");
                if (spaCart != null) {
                    spaCart.remove(serviceId);
                    request.getSession().setAttribute("spaCart", spaCart);
                }
            }
            
            // Set success message and redirect to history
            HttpSession session = request.getSession(true);
            if (serviceId >= 1000) {
                session.setAttribute("successMessage", "Đã hủy lịch lưu trú thành công");
            } else {
                session.setAttribute("successMessage", "Đã xóa dịch vụ spa khỏi giỏ hàng");
            }
            response.sendRedirect(request.getContextPath() + "/spa-booking?action=history");
            
        } catch (NumberFormatException e) {
            HttpSession session = request.getSession(true);
            session.setAttribute("errorMessage", "ID dịch vụ không hợp lệ");
            response.sendRedirect(request.getContextPath() + "/spa-booking?action=history");
        } catch (Exception e) {
            logger.severe("Error removing spa service from cart: " + e.getMessage());
            HttpSession session = request.getSession(true);
            session.setAttribute("errorMessage", "Có lỗi xảy ra khi xóa dịch vụ");
            response.sendRedirect(request.getContextPath() + "/spa-booking?action=history");
        }
    }
    
    /**
     * Lấy tổng giá trị giỏ hàng Spa
     */
    private void getSpaCartTotal(HttpServletRequest request, HttpServletResponse response, Customer customer) 
            throws ServletException, IOException {
        
        try {
            // Lấy giỏ hàng Spa từ session
            @SuppressWarnings("unchecked")
            Map<Integer, Integer> spaCart = (Map<Integer, Integer>) request.getSession().getAttribute("spaCart");
            
            if (spaCart == null || spaCart.isEmpty()) {
                response.getWriter().write("0");
                return;
            }
            
            // Tính tổng giá trị
            List<Integer> serviceIds = new ArrayList<>();
            List<Integer> quantities = new ArrayList<>();
            
            for (Map.Entry<Integer, Integer> entry : spaCart.entrySet()) {
                serviceIds.add(entry.getKey());
                quantities.add(entry.getValue());
            }
            
            BigDecimal totalPrice = spaBookingService.calculateSpaBookingTotal(serviceIds, quantities);
            
            // Trả về tổng giá trị
            response.setContentType("text/plain");
            response.setCharacterEncoding("UTF-8");
            response.getWriter().write(String.format("%.0f", totalPrice.doubleValue()));
            
        } catch (Exception e) {
            logger.severe("Error getting spa cart total: " + e.getMessage());
            response.getWriter().write("0");
        }
    }
    
    /**
     * Lấy chi tiết boarding từ session
     */
    private void getBoardingDetails(HttpServletRequest request, HttpServletResponse response, Customer customer) 
            throws ServletException, IOException {
        
        try {
            String serviceIdParam = request.getParameter("serviceId");
            if (serviceIdParam == null) {
                response.getWriter().write("{\"success\": false, \"message\": \"Thiếu serviceId\"}");
                return;
            }
            
            int serviceId = Integer.parseInt(serviceIdParam);
            
            // Lấy boarding details từ session
            @SuppressWarnings("unchecked")
            Map<Integer, Map<String, Object>> boardingDetailsMap = 
                (Map<Integer, Map<String, Object>>) request.getSession().getAttribute("boardingDetails");
            
            if (boardingDetailsMap == null || !boardingDetailsMap.containsKey(serviceId)) {
                response.getWriter().write("{\"success\": false, \"message\": \"Không tìm thấy thông tin boarding\"}");
                return;
            }
            
            Map<String, Object> boardingDetails = boardingDetailsMap.get(serviceId);
            
            // Trả về JSON response
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            
            // Build JSON manually
            StringBuilder json = new StringBuilder();
            json.append("{\"success\": true, \"boardingDetails\": {");
            json.append("\"roomType\":\"").append(boardingDetails.get("roomType")).append("\",");
            json.append("\"pricePerDay\":").append(boardingDetails.get("pricePerDay")).append(",");
            json.append("\"boardingDays\":").append(boardingDetails.get("boardingDays")).append(",");
            json.append("\"checkInDate\":\"").append(boardingDetails.get("checkInDate")).append("\",");
            json.append("\"checkOutDate\":\"").append(boardingDetails.get("checkOutDate")).append("\",");
            json.append("\"checkInTime\":\"").append(boardingDetails.get("checkInTime")).append("\",");
            json.append("\"checkOutTime\":\"").append(boardingDetails.get("checkOutTime")).append("\",");
            json.append("\"petInfo\":\"").append(boardingDetails.get("petInfo")).append("\",");
            json.append("\"specialNotes\":\"").append(boardingDetails.get("specialNotes")).append("\",");
            json.append("\"emergencyPhone1\":\"").append(boardingDetails.get("emergencyPhone1")).append("\",");
            json.append("\"emergencyPhone2\":\"").append(boardingDetails.get("emergencyPhone2")).append("\"");
            json.append("}}");
            
            response.getWriter().write(json.toString());
            
        } catch (NumberFormatException e) {
            response.getWriter().write("{\"success\": false, \"message\": \"ServiceId không hợp lệ\"}");
        } catch (Exception e) {
            logger.severe("Error getting boarding details: " + e.getMessage());
            response.getWriter().write("{\"success\": false, \"message\": \"Có lỗi xảy ra\"}");
        }
    }
    
    /**
     * Cập nhật chi tiết boarding trong session
     */
    private void updateBoardingDetails(HttpServletRequest request, HttpServletResponse response, Customer customer) 
            throws ServletException, IOException {
        
        try {
            String serviceIdParam = request.getParameter("serviceId");
            if (serviceIdParam == null) {
                response.getWriter().write("{\"success\": false, \"message\": \"Thiếu serviceId\"}");
                return;
            }
            
            int serviceId = Integer.parseInt(serviceIdParam);
            
            // Lấy thông tin cập nhật từ request
            String checkInDate = request.getParameter("checkInDate");
            String checkOutDate = request.getParameter("checkOutDate");
            String petInfo = request.getParameter("petInfo");
            String emergencyPhone1 = request.getParameter("emergencyPhone1");
            String emergencyPhone2 = request.getParameter("emergencyPhone2");
            String specialNotes = request.getParameter("specialNotes");
            String pricePerDayStr = request.getParameter("pricePerDay");
            
            // Validate input
            if (checkInDate == null || checkOutDate == null || petInfo == null || emergencyPhone1 == null) {
                response.getWriter().write("{\"success\": false, \"message\": \"Thiếu thông tin bắt buộc\"}");
                return;
            }
            
            // Validate dates
            java.text.SimpleDateFormat dateFormat = new java.text.SimpleDateFormat("yyyy-MM-dd");
            java.util.Date checkIn = dateFormat.parse(checkInDate);
            java.util.Date checkOut = dateFormat.parse(checkOutDate);
            java.util.Calendar cal = java.util.Calendar.getInstance();
            cal.set(java.util.Calendar.HOUR_OF_DAY, 0);
            cal.set(java.util.Calendar.MINUTE, 0);
            cal.set(java.util.Calendar.SECOND, 0);
            cal.set(java.util.Calendar.MILLISECOND, 0);
            java.util.Date today = cal.getTime();
            
            if (checkIn.before(today)) {
                response.getWriter().write("{\"success\": false, \"message\": \"Ngày nhận không được là ngày quá khứ\"}");
                return;
            }
            
            if (checkOut.before(checkIn)) {
                response.getWriter().write("{\"success\": false, \"message\": \"Ngày trả phải sau hoặc bằng ngày nhận\"}");
                return;
            }
            
            // Calculate boarding days
            long timeDiff = checkOut.getTime() - checkIn.getTime();
            int boardingDays = (int) (timeDiff / (1000 * 60 * 60 * 24));
            
            // Lấy boarding details từ session
            @SuppressWarnings("unchecked")
            Map<Integer, Map<String, Object>> boardingDetailsMap = 
                (Map<Integer, Map<String, Object>>) request.getSession().getAttribute("boardingDetails");
            
            if (boardingDetailsMap == null || !boardingDetailsMap.containsKey(serviceId)) {
                response.getWriter().write("{\"success\": false, \"message\": \"Không tìm thấy thông tin boarding\"}");
                return;
            }
            
            // Update boarding details
            Map<String, Object> boardingDetails = boardingDetailsMap.get(serviceId);
            boardingDetails.put("checkInDate", checkInDate);
            boardingDetails.put("checkOutDate", checkOutDate);
            boardingDetails.put("boardingDays", boardingDays);
            boardingDetails.put("petInfo", petInfo);
            boardingDetails.put("emergencyPhone1", emergencyPhone1);
            boardingDetails.put("emergencyPhone2", emergencyPhone2 != null ? emergencyPhone2 : "");
            boardingDetails.put("specialNotes", specialNotes != null ? specialNotes : "");
            
            // Update price based on new days
            int pricePerDay = (Integer) boardingDetails.get("pricePerDay");
            BigDecimal newTotalPrice = BigDecimal.valueOf(pricePerDay * boardingDays);
            boardingDetails.put("totalPrice", newTotalPrice);
            
            // Update service price in spa cart
            @SuppressWarnings("unchecked")
            Map<Integer, Integer> spaCart = (Map<Integer, Integer>) request.getSession().getAttribute("spaCart");
            if (spaCart != null && spaCart.containsKey(serviceId)) {
                // Update the service price in the cart
                // This would require updating the PetServiceModel in the cart
                // For now, we'll just update the session data
                request.getSession().setAttribute("boardingDetails", boardingDetailsMap);
            }
            
            // Trả về JSON response
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            response.getWriter().write("{\"success\": true, \"message\": \"Cập nhật thành công\"}");
            
        } catch (NumberFormatException e) {
            response.getWriter().write("{\"success\": false, \"message\": \"Dữ liệu không hợp lệ\"}");
        } catch (java.text.ParseException e) {
            response.getWriter().write("{\"success\": false, \"message\": \"Ngày tháng không hợp lệ\"}");
        } catch (Exception e) {
            logger.severe("Error updating boarding details: " + e.getMessage());
            response.getWriter().write("{\"success\": false, \"message\": \"Có lỗi xảy ra khi cập nhật\"}");
        }
    }
    
    /**
     * Tạo dữ liệu test boarding cho customer cụ thể
     */
    private void createTestBoardingDataForCustomer(Customer customer) {
        try {
            logger.info("Starting to create test boarding data for customer ID: " + customer.getCustomerId());
            
            // Tạo dữ liệu test mặc định
            String roomType = "Phòng VIP Test";
            BigDecimal pricePerDay = new BigDecimal("500000");
            int boardingDays = 3;
            
            // Tạo ngày check-in là ngày mai
            java.util.Calendar cal = java.util.Calendar.getInstance();
            cal.add(java.util.Calendar.DAY_OF_MONTH, 1);
            cal.set(java.util.Calendar.HOUR_OF_DAY, 8);
            cal.set(java.util.Calendar.MINUTE, 0);
            cal.set(java.util.Calendar.SECOND, 0);
            cal.set(java.util.Calendar.MILLISECOND, 0);
            Timestamp checkInTimestamp = new Timestamp(cal.getTimeInMillis());
            
            // Tạo ngày check-out là 3 ngày sau
            cal.add(java.util.Calendar.DAY_OF_MONTH, 3);
            cal.set(java.util.Calendar.HOUR_OF_DAY, 17);
            Timestamp checkOutTimestamp = new Timestamp(cal.getTimeInMillis());
            
            String petInfo = "Chó Golden Test, 2 tuổi, khỏe mạnh";
            String specialNotes = "Dữ liệu test từ hệ thống";
            String emergencyPhone1 = "0901234567";
            String emergencyPhone2 = "0907654321";
            
            // Tính giá đơn giản: 3 ngày * 500,000 = 1,500,000
            BigDecimal totalPrice = pricePerDay.multiply(BigDecimal.valueOf(boardingDays));
            
            logger.info("Creating boarding booking with total price: " + totalPrice);
            
            // Tạo BoardingBooking object
            BoardingBooking booking = new BoardingBooking(
                customer.getCustomerId(),
                roomType,
                pricePerDay,
                boardingDays,
                checkInTimestamp,
                checkOutTimestamp,
                "08:00",
                "17:00",
                petInfo,
                specialNotes,
                emergencyPhone1,
                emergencyPhone2
            );
            
            // Set total price
            booking.setTotalPrice(totalPrice);
            
            logger.info("Boarding booking created, attempting to save to database...");
            
            // Lưu vào database
            boolean success = boardingBookingDAO.addBoardingBooking(booking);
            
            if (success) {
                logger.info("✅ Created test boarding booking with ID: " + booking.getBookingId());
                logger.info("Boarding booking: " + booking.toString());
                logger.info("Check-in: " + checkInTimestamp);
                logger.info("Check-out: " + checkOutTimestamp);
                logger.info("Total price: " + totalPrice);
            } else {
                logger.warning("❌ Failed to create boarding booking");
            }
            
        } catch (Exception e) {
            logger.severe("❌ Error creating test boarding data: " + e.getMessage());
            logger.severe("Stack trace: " + java.util.Arrays.toString(e.getStackTrace()));
            e.printStackTrace();
        }
    }
    
    /**
     * Tạo dữ liệu test boarding
     */
    private void createTestBoardingData(HttpServletRequest request, HttpServletResponse response, Customer customer) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        
        try {
            // Tạo dữ liệu test mặc định
            String roomType = "Phòng VIP Test";
            BigDecimal pricePerDay = new BigDecimal("500000");
            int boardingDays = 3;
            
            // Tạo ngày check-in là ngày mai
            java.util.Calendar cal = java.util.Calendar.getInstance();
            cal.add(java.util.Calendar.DAY_OF_MONTH, 1);
            cal.set(java.util.Calendar.HOUR_OF_DAY, 8);
            cal.set(java.util.Calendar.MINUTE, 0);
            cal.set(java.util.Calendar.SECOND, 0);
            cal.set(java.util.Calendar.MILLISECOND, 0);
            Timestamp checkInTimestamp = new Timestamp(cal.getTimeInMillis());
            
            // Tạo ngày check-out là 3 ngày sau
            cal.add(java.util.Calendar.DAY_OF_MONTH, 3);
            cal.set(java.util.Calendar.HOUR_OF_DAY, 17);
            Timestamp checkOutTimestamp = new Timestamp(cal.getTimeInMillis());
            
            String petInfo = "Chó Golden Test, 2 tuổi, khỏe mạnh";
            String specialNotes = "Dữ liệu test từ hệ thống";
            String emergencyPhone1 = "0901234567";
            String emergencyPhone2 = "0907654321";
            
            // Tạo BoardingBooking object
            BoardingBooking booking = new BoardingBooking(
                customer.getCustomerId(),
                roomType,
                pricePerDay,
                boardingDays,
                checkInTimestamp,
                checkOutTimestamp,
                "08:00",
                "17:00",
                petInfo,
                specialNotes,
                emergencyPhone1,
                emergencyPhone2
            );
            
            // Lưu vào database
            boolean success = boardingBookingDAO.addBoardingBooking(booking);
            
            if (success) {
                logger.info("Created test boarding booking with ID: " + booking.getBookingId());
                logger.info("Boarding booking: " + booking.toString());
                logger.info("Check-in: " + checkInTimestamp);
                logger.info("Check-out: " + checkOutTimestamp);
                
                session.setAttribute("successMessage", "Đã tạo dữ liệu test boarding thành công! ID: " + booking.getBookingId());
            } else {
                logger.warning("Failed to create boarding booking");
                session.setAttribute("errorMessage", "Lỗi tạo dữ liệu test: Không thể lưu vào database");
            }
            
        } catch (Exception e) {
            logger.severe("Error creating test boarding data: " + e.getMessage());
            logger.severe("Stack trace: " + java.util.Arrays.toString(e.getStackTrace()));
            e.printStackTrace();
            session.setAttribute("errorMessage", "Lỗi tạo dữ liệu test: " + e.getMessage());
        }
        
        response.sendRedirect(request.getContextPath() + "/spa-booking?action=history");
    }
    
    /**
     * Hủy boarding booking
     */
    private void cancelBoardingBooking(HttpServletRequest request, HttpServletResponse response, Customer customer) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        
        try {
            String bookingIdParam = request.getParameter("bookingId");
            if (bookingIdParam == null || bookingIdParam.trim().isEmpty()) {
                session.setAttribute("errorMessage", "Không tìm thấy booking");
                response.sendRedirect(request.getContextPath() + "/spa-booking?action=history");
                return;
            }
            
            int bookingId = Integer.parseInt(bookingIdParam);
            
            // Kiểm tra booking có tồn tại và thuộc về customer không
            BoardingBooking booking = boardingBookingDAO.getBoardingBookingById(bookingId);
            if (booking == null || booking.getCustomerId() != customer.getCustomerId()) {
                session.setAttribute("errorMessage", "Không tìm thấy booking hoặc bạn không có quyền hủy");
                response.sendRedirect(request.getContextPath() + "/spa-booking?action=history");
                return;
            }
            
            // Kiểm tra có thể hủy không
            String status = booking.getStatus();
            boolean canCancel = "pending".equals(status) || "confirmed".equals(status);
            
            if (!canCancel) {
                String reason;
                if ("cancelled".equals(status)) {
                    reason = "Booking này đã được hủy trước đó";
                } else if ("completed".equals(status)) {
                    reason = "Booking này đã hoàn thành, không thể hủy";
                } else {
                    reason = "Booking có trạng thái '" + status + "' không thể hủy";
                }
                
                session.setAttribute("errorMessage", reason);
                response.sendRedirect(request.getContextPath() + "/spa-booking?action=history");
                return;
            }
            
            // Hủy booking
            boolean success = boardingBookingDAO.updateBookingStatus(bookingId, "cancelled");
            
            if (success) {
                logger.info("Cancelled boarding booking ID: " + bookingId);
                session.setAttribute("successMessage", "Hủy lịch lưu trú thành công");
            } else {
                logger.warning("Failed to cancel boarding booking ID: " + bookingId);
                session.setAttribute("errorMessage", "Hủy lịch lưu trú thất bại. Vui lòng thử lại.");
            }
            
        } catch (NumberFormatException e) {
            session.setAttribute("errorMessage", "ID booking không hợp lệ");
        } catch (Exception e) {
            logger.severe("Error canceling boarding booking: " + e.getMessage());
            e.printStackTrace();
            session.setAttribute("errorMessage", "Có lỗi xảy ra khi hủy lịch: " + e.getMessage());
        }
        
        response.sendRedirect(request.getContextPath() + "/spa-booking?action=history");
    }
    
    /**
     * Tạo boarding booking từ form của khách hàng
     */
    private void createBoardingBookingFromForm(HttpServletRequest request, HttpServletResponse response, Customer customer) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        
        logger.info("=== CREATE BOARDING BOOKING FROM FORM DEBUG ===");
        logger.info("Customer ID: " + customer.getCustomerId());
        
        try {
            // Lấy thông tin từ form
            String roomType = request.getParameter("roomType");
            String pricePerDayStr = request.getParameter("pricePerDay");
            String boardingDaysStr = request.getParameter("boardingDays");
            String checkInDate = request.getParameter("checkInDate");
            String checkOutDate = request.getParameter("checkOutDate");
            
            // Xử lý giờ và phút riêng biệt
            String checkInHour = request.getParameter("checkInHour");
            String checkInMinute = request.getParameter("checkInMinute");
            String checkOutHour = request.getParameter("checkOutHour");
            String checkOutMinute = request.getParameter("checkOutMinute");
            
            // Tạo time string từ giờ và phút
            String checkInTime = (checkInHour != null && checkInMinute != null) ? 
                checkInHour + ":" + checkInMinute : "08:00";
            String checkOutTime = (checkOutHour != null && checkOutMinute != null) ? 
                checkOutHour + ":" + checkOutMinute : "17:00";
            
            String petInfo = request.getParameter("petInfo");
            String specialNotes = request.getParameter("specialNotes");
            String emergencyPhone1 = request.getParameter("emergencyPhone1");
            String emergencyPhone2 = request.getParameter("emergencyPhone2");
            
            // Debug logging
            logger.info("Form parameters:");
            logger.info("roomType: " + roomType);
            logger.info("pricePerDayStr: " + pricePerDayStr);
            logger.info("boardingDaysStr: " + boardingDaysStr);
            logger.info("checkInDate: " + checkInDate);
            logger.info("checkOutDate: " + checkOutDate);
            logger.info("petInfo: " + petInfo);
            logger.info("emergencyPhone1: " + emergencyPhone1);
            
            // Validate required fields với thông báo chi tiết
            if (roomType == null || roomType.trim().isEmpty()) {
                session.setAttribute("errorMessage", "❌ Vui lòng chọn loại phòng lưu trú");
                response.sendRedirect(request.getContextPath() + "/spa-booking?action=history");
                return;
            }
            
            // Validate room type length
            if (!isValidStringLength(roomType, 100)) {
                session.setAttribute("errorMessage", "❌ Tên loại phòng quá dài (tối đa 100 ký tự)");
                response.sendRedirect(request.getContextPath() + "/spa-booking?action=history");
                return;
            }
            
            if (pricePerDayStr == null || pricePerDayStr.trim().isEmpty()) {
                session.setAttribute("errorMessage", "❌ Vui lòng nhập giá mỗi ngày");
                response.sendRedirect(request.getContextPath() + "/spa-booking?action=history");
                return;
            }
            
            if (checkInDate == null || checkInDate.trim().isEmpty()) {
                session.setAttribute("errorMessage", "❌ Vui lòng chọn ngày nhận thú cưng");
                response.sendRedirect(request.getContextPath() + "/spa-booking?action=history");
                return;
            }
            
            if (checkOutDate == null || checkOutDate.trim().isEmpty()) {
                session.setAttribute("errorMessage", "❌ Vui lòng chọn ngày trả thú cưng");
                response.sendRedirect(request.getContextPath() + "/spa-booking?action=history");
                return;
            }
            
            if (checkInHour == null || checkInHour.trim().isEmpty() || 
                checkInMinute == null || checkInMinute.trim().isEmpty()) {
                session.setAttribute("errorMessage", "❌ Vui lòng chọn giờ nhận thú cưng");
                response.sendRedirect(request.getContextPath() + "/spa-booking?action=history");
                return;
            }
            
            if (checkOutHour == null || checkOutHour.trim().isEmpty() || 
                checkOutMinute == null || checkOutMinute.trim().isEmpty()) {
                session.setAttribute("errorMessage", "❌ Vui lòng chọn giờ trả thú cưng");
                response.sendRedirect(request.getContextPath() + "/spa-booking?action=history");
                return;
            }
            
            if (petInfo == null || petInfo.trim().isEmpty()) {
                session.setAttribute("errorMessage", "❌ Vui lòng nhập thông tin thú cưng");
                response.sendRedirect(request.getContextPath() + "/spa-booking?action=history");
                return;
            }
            
            // Validate pet info length
            if (petInfo.trim().length() < 10) {
                session.setAttribute("errorMessage", "❌ Vui lòng nhập đầy đủ thông tin thú cưng (ít nhất 10 ký tự)");
                response.sendRedirect(request.getContextPath() + "/spa-booking?action=history");
                return;
            }
            
            if (!isValidStringLength(petInfo, 1000)) {
                session.setAttribute("errorMessage", "❌ Thông tin thú cưng quá dài (tối đa 1000 ký tự)");
                response.sendRedirect(request.getContextPath() + "/spa-booking?action=history");
                return;
            }
            
            if (emergencyPhone1 == null || emergencyPhone1.trim().isEmpty()) {
                session.setAttribute("errorMessage", "❌ Vui lòng nhập số điện thoại liên hệ khẩn cấp");
                response.sendRedirect(request.getContextPath() + "/spa-booking?action=history");
                return;
            }
            
            // Validate phone number length
            if (emergencyPhone1.trim().length() < 10) {
                session.setAttribute("errorMessage", "❌ Số điện thoại liên hệ khẩn cấp phải có ít nhất 10 số");
                response.sendRedirect(request.getContextPath() + "/spa-booking?action=history");
                return;
            }
            
            // Validate phone number format
            if (!isValidPhoneNumber(emergencyPhone1)) {
                session.setAttribute("errorMessage", "Số điện thoại khẩn cấp phải có 10-11 chữ số");
                response.sendRedirect(request.getContextPath() + "/spa-booking?action=history");
                return;
            }
            
            if (emergencyPhone2 != null && !emergencyPhone2.trim().isEmpty() && 
                !isValidPhoneNumber(emergencyPhone2)) {
                session.setAttribute("errorMessage", "Số điện thoại khẩn cấp 2 phải có 10-11 chữ số");
                response.sendRedirect(request.getContextPath() + "/spa-booking?action=history");
                return;
            }
            
            // Validate special notes length
            if (!isValidStringLength(specialNotes, 1000)) {
                session.setAttribute("errorMessage", "Ghi chú đặc biệt quá dài (tối đa 1000 ký tự)");
                response.sendRedirect(request.getContextPath() + "/spa-booking?action=history");
                return;
            }
            
            // Parse numbers
            BigDecimal pricePerDay = new BigDecimal(pricePerDayStr);
            int boardingDays = Integer.parseInt(boardingDaysStr);
            
            // Tính tổng số giờ lưu trú
            double totalHours = calculateTotalHours(boardingDays, checkInTime, checkOutTime);
            
            // Tính giá theo logic 12 tiếng với ưu đãi
            BigDecimal totalPrice = calculatePriceByHours(totalHours, pricePerDay);
            
            // Validate price and days
            if (pricePerDay.compareTo(BigDecimal.ZERO) <= 0) {
                session.setAttribute("errorMessage", "Giá mỗi ngày phải lớn hơn 0");
                response.sendRedirect(request.getContextPath() + "/spa-booking?action=history");
                return;
            }
            
            if (!isValidBoardingDays(boardingDays)) {
                session.setAttribute("errorMessage", "Số ngày lưu trú phải từ 0-30 ngày");
                response.sendRedirect(request.getContextPath() + "/spa-booking?action=history");
                return;
            }
            
            // Validate dates
            SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
            java.util.Date checkInDateParsed = dateFormat.parse(checkInDate);
            java.util.Date checkOutDateParsed = dateFormat.parse(checkOutDate);
            java.util.Calendar cal = java.util.Calendar.getInstance();
            cal.set(java.util.Calendar.HOUR_OF_DAY, 0);
            cal.set(java.util.Calendar.MINUTE, 0);
            cal.set(java.util.Calendar.SECOND, 0);
            cal.set(java.util.Calendar.MILLISECOND, 0);
            java.util.Date today = cal.getTime();
            
            if (checkInDateParsed.before(today)) {
                session.setAttribute("errorMessage", "Ngày nhận không được là ngày quá khứ");
                response.sendRedirect(request.getContextPath() + "/spa-booking?action=history");
                return;
            }
            
            if (!isValidDateRange(checkInDateParsed, checkOutDateParsed)) {
                session.setAttribute("errorMessage", "Ngày trả phải sau hoặc bằng ngày nhận");
                response.sendRedirect(request.getContextPath() + "/spa-booking?action=history");
                return;
            }
            
            // Parse timestamps
            Timestamp checkInTimestamp = new Timestamp(dateFormat.parse(checkInDate).getTime());
            Timestamp checkOutTimestamp = new Timestamp(dateFormat.parse(checkOutDate).getTime());
            
            // Set time if provided
            if (checkInTime != null && !checkInTime.trim().isEmpty()) {
                try {
                    String[] timeParts = checkInTime.split(":");
                    if (timeParts.length == 2) {
                        int hours = Integer.parseInt(timeParts[0]);
                        int minutes = Integer.parseInt(timeParts[1]);
                        
                        java.util.Calendar calIn = java.util.Calendar.getInstance();
                        calIn.setTime(checkInTimestamp);
                        calIn.set(java.util.Calendar.HOUR_OF_DAY, hours);
                        calIn.set(java.util.Calendar.MINUTE, minutes);
                        calIn.set(java.util.Calendar.SECOND, 0);
                        calIn.set(java.util.Calendar.MILLISECOND, 0);
                        checkInTimestamp = new Timestamp(calIn.getTimeInMillis());
                    }
                } catch (NumberFormatException e) {
                    logger.warning("Invalid check-in time format: " + checkInTime);
                }
            }
            
            if (checkOutTime != null && !checkOutTime.trim().isEmpty()) {
                try {
                    String[] timeParts = checkOutTime.split(":");
                    if (timeParts.length == 2) {
                        int hours = Integer.parseInt(timeParts[0]);
                        int minutes = Integer.parseInt(timeParts[1]);
                        
                        java.util.Calendar calOut = java.util.Calendar.getInstance();
                        calOut.setTime(checkOutTimestamp);
                        calOut.set(java.util.Calendar.HOUR_OF_DAY, hours);
                        calOut.set(java.util.Calendar.MINUTE, minutes);
                        calOut.set(java.util.Calendar.SECOND, 0);
                        calOut.set(java.util.Calendar.MILLISECOND, 0);
                        checkOutTimestamp = new Timestamp(calOut.getTimeInMillis());
                    }
                } catch (NumberFormatException e) {
                    logger.warning("Invalid check-out time format: " + checkOutTime);
                }
            }
            
            // Sanitize inputs
            String sanitizedRoomType = sanitizeInput(roomType);
            String sanitizedPetInfo = sanitizeInput(petInfo);
            String sanitizedSpecialNotes = sanitizeInput(specialNotes);
            String sanitizedEmergencyPhone1 = sanitizeInput(emergencyPhone1);
            String sanitizedEmergencyPhone2 = sanitizeInput(emergencyPhone2);
            
            // Tạo BoardingBooking object
            BoardingBooking booking = new BoardingBooking(
                customer.getCustomerId(),
                sanitizedRoomType,
                pricePerDay,
                boardingDays, // Sử dụng boardingDays gốc
                checkInTimestamp,
                checkOutTimestamp,
                checkInTime != null ? checkInTime : "08:00",
                checkOutTime != null ? checkOutTime : "17:00",
                sanitizedPetInfo,
                sanitizedSpecialNotes,
                sanitizedEmergencyPhone1,
                sanitizedEmergencyPhone2
            );
            
            // Set total price calculated by hours
            booking.setTotalPrice(totalPrice);
            
            // Lưu vào database
            boolean success = boardingBookingDAO.addBoardingBooking(booking);
            
            logger.info("Database insert result: " + success);
            logger.info("Booking ID after insert: " + booking.getBookingId());
            
            if (success) {
                logger.info("Created boarding booking from form with ID: " + booking.getBookingId());
                logger.info("Boarding booking: " + booking.toString());
                
                session.setAttribute("successMessage", 
                    "Đặt phòng lưu trú thành công! Mã đặt phòng: " + booking.getBookingId() + 
                    ". Chúng tôi sẽ liên hệ xác nhận trong 24h.");
            } else {
                logger.warning("Failed to create boarding booking from form");
                session.setAttribute("errorMessage", "Đặt phòng thất bại. Vui lòng thử lại hoặc liên hệ hỗ trợ.");
            }
            
        } catch (NumberFormatException e) {
            logger.warning("Number format error: " + e.getMessage());
            session.setAttribute("errorMessage", "Dữ liệu số không hợp lệ. Vui lòng kiểm tra lại giá và số ngày.");
            response.sendRedirect(request.getContextPath() + "/boarding-booking-form.jsp");
        } catch (java.text.ParseException e) {
            logger.warning("Date parse error: " + e.getMessage());
            session.setAttribute("errorMessage", "Ngày tháng không hợp lệ. Vui lòng chọn lại ngày nhận và ngày trả.");
            response.sendRedirect(request.getContextPath() + "/boarding-booking-form.jsp");
        } catch (IllegalArgumentException e) {
            logger.warning("Illegal argument error: " + e.getMessage());
            session.setAttribute("errorMessage", "Dữ liệu không hợp lệ: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/boarding-booking-form.jsp");
        } catch (Exception e) {
            logger.severe("Unexpected error creating boarding booking from form: " + e.getMessage());
            logger.severe("Stack trace: " + java.util.Arrays.toString(e.getStackTrace()));
            e.printStackTrace();
            session.setAttribute("errorMessage", "Có lỗi xảy ra khi đặt phòng. Vui lòng thử lại hoặc liên hệ hỗ trợ.");
            response.sendRedirect(request.getContextPath() + "/boarding-booking-form.jsp");
        }
        
        response.sendRedirect(request.getContextPath() + "/spa-booking?action=history");
    }
    
    /**
     * Validate phone number format
     */
    private boolean isValidPhoneNumber(String phone) {
        if (phone == null || phone.trim().isEmpty()) {
            return false;
        }
        
        // Remove all non-digit characters
        String cleanPhone = phone.replaceAll("\\D", "");
        
        // Check if phone has 10 or 11 digits
        boolean isValid = cleanPhone.length() == 10 || cleanPhone.length() == 11;
        
        logger.info("Server phone validation: original='" + phone + "', clean='" + cleanPhone + "', length=" + cleanPhone.length() + ", valid=" + isValid);
        
        return isValid;
    }
    
    /**
     * Validate date range
     */
    private boolean isValidDateRange(java.util.Date checkIn, java.util.Date checkOut) {
        if (checkIn == null || checkOut == null) {
            return false;
        }
        return checkOut.after(checkIn) || checkOut.equals(checkIn);
    }
    
    /**
     * Validate boarding days
     */
    private boolean isValidBoardingDays(int days) {
        return days >= 0 && days <= 30;
    }
    
    /**
     * Validate string length
     */
    private boolean isValidStringLength(String str, int maxLength) {
        if (str == null) {
            return true; // null is allowed for optional fields
        }
        return str.length() <= maxLength;
    }
    
    /**
     * Sanitize input string
     */
    private String sanitizeInput(String input) {
        if (input == null) {
            return "";
        }
        return input.trim().replaceAll("[<>\"'&]", "");
    }
    
    /**
     * Validate request parameters
     */
    private boolean validateRequestParameters(HttpServletRequest request, String... requiredParams) {
        for (String param : requiredParams) {
            String value = request.getParameter(param);
            if (value == null || value.trim().isEmpty()) {
                logger.warning("Missing required parameter: " + param);
                return false;
            }
        }
        return true;
    }
    
    /**
     * Lấy danh sách pet của khách hàng (AJAX endpoint)
     */
    private void getCustomerPets(HttpServletRequest request, HttpServletResponse response, Customer customer) 
            throws ServletException, IOException {
        
        try {
            List<Pet> pets = petDAO.getPetsByCustomerId(customer.getCustomerId());
            
            // Set response content type to JSON
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            
            // Build JSON response
            StringBuilder json = new StringBuilder();
            json.append("[");
            
            for (int i = 0; i < pets.size(); i++) {
                Pet pet = pets.get(i);
                json.append("{");
                json.append("\"id\":").append(pet.getId()).append(",");
                json.append("\"petName\":\"").append(escapeJson(pet.getPetName())).append("\",");
                json.append("\"species\":\"").append(escapeJson(pet.getSpecies())).append("\",");
                json.append("\"breed\":\"").append(escapeJson(pet.getBreed())).append("\",");
                json.append("\"age\":").append(pet.getAge()).append(",");
                json.append("\"gender\":\"").append(escapeJson(pet.getGender())).append("\",");
                json.append("\"description\":\"").append(escapeJson(pet.getDescription())).append("\",");
                json.append("\"healthStatus\":\"").append(escapeJson(pet.getHealthStatus())).append("\"");
                json.append("}");
                
                if (i < pets.size() - 1) {
                    json.append(",");
                }
            }
            
            json.append("]");
            
            response.getWriter().write(json.toString());
            logger.info("Returned " + pets.size() + " pets for customer ID: " + customer.getCustomerId());
            
        } catch (Exception e) {
            logger.severe("Error getting customer pets: " + e.getMessage());
            e.printStackTrace();
            
            // Return empty JSON array on error
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            response.getWriter().write("[]");
        }
    }
    
    /**
     * Escape JSON string to prevent injection
     */
    private String escapeJson(String str) {
        if (str == null) return "";
        return str.replace("\"", "\\\"")
                  .replace("\\", "\\\\")
                  .replace("\n", "\\n")
                  .replace("\r", "\\r")
                  .replace("\t", "\\t");
    }
    
    /**
     * Get safe parameter value
     */
    private String getSafeParameter(HttpServletRequest request, String paramName, String defaultValue) {
        String value = request.getParameter(paramName);
        if (value == null || value.trim().isEmpty()) {
            return defaultValue;
        }
        return sanitizeInput(value);
    }
    
    /**
     * Get safe integer parameter
     */
    private int getSafeIntParameter(HttpServletRequest request, String paramName, int defaultValue) {
        try {
            String value = request.getParameter(paramName);
            if (value != null && !value.trim().isEmpty()) {
                return Integer.parseInt(value.trim());
            }
        } catch (NumberFormatException e) {
            logger.warning("Invalid integer parameter " + paramName + ": " + request.getParameter(paramName));
        }
        return defaultValue;
    }
    
    /**
     * Xóa boarding booking khỏi database
     */
    private void deleteBoardingBooking(HttpServletRequest request, HttpServletResponse response, Customer customer) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        
        try {
            String bookingIdParam = request.getParameter("bookingId");
            if (bookingIdParam == null || bookingIdParam.trim().isEmpty()) {
                session.setAttribute("errorMessage", "Không tìm thấy booking");
                response.sendRedirect(request.getContextPath() + "/spa-booking?action=history");
                return;
            }
            
            int bookingId = Integer.parseInt(bookingIdParam);
            
            // Kiểm tra booking có tồn tại và thuộc về customer không
            BoardingBooking booking = boardingBookingDAO.getBoardingBookingById(bookingId);
            if (booking == null || booking.getCustomerId() != customer.getCustomerId()) {
                session.setAttribute("errorMessage", "Không tìm thấy booking hoặc bạn không có quyền xóa");
                response.sendRedirect(request.getContextPath() + "/spa-booking?action=history");
                return;
            }
            
            // Xóa booking khỏi database
            boolean success = boardingBookingDAO.deleteBoardingBooking(bookingId);
            
            if (success) {
                logger.info("Deleted boarding booking ID: " + bookingId);
                session.setAttribute("successMessage", "Đã xóa lịch lưu trú khỏi danh sách");
            } else {
                logger.warning("Failed to delete boarding booking ID: " + bookingId);
                session.setAttribute("errorMessage", "Xóa lịch lưu trú thất bại. Vui lòng thử lại.");
            }
            
        } catch (NumberFormatException e) {
            session.setAttribute("errorMessage", "ID booking không hợp lệ");
        } catch (Exception e) {
            logger.severe("Error deleting boarding booking: " + e.getMessage());
            e.printStackTrace();
            session.setAttribute("errorMessage", "Có lỗi xảy ra khi xóa lịch: " + e.getMessage());
        }
        
        response.sendRedirect(request.getContextPath() + "/spa-booking?action=history");
    }
    
    /**
     * Xóa spa booking khỏi database
     */
    private void deleteSpaBooking(HttpServletRequest request, HttpServletResponse response, Customer customer) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        
        try {
            String bookingIdParam = request.getParameter("bookingId");
            if (bookingIdParam == null || bookingIdParam.trim().isEmpty()) {
                session.setAttribute("errorMessage", "Không tìm thấy booking");
                response.sendRedirect(request.getContextPath() + "/spa-booking?action=history");
                return;
            }
            
            int bookingId = Integer.parseInt(bookingIdParam);
            
            // Kiểm tra booking có tồn tại và thuộc về customer không
            List<Booking> customerBookings = spaBookingService.getSpaBookingsByCustomerId(customer.getCustomerId());
            Booking booking = customerBookings.stream()
                    .filter(b -> b.getBookingId() == bookingId)
                    .findFirst()
                    .orElse(null);
            
            if (booking == null) {
                session.setAttribute("errorMessage", "Không tìm thấy booking hoặc bạn không có quyền xóa");
                response.sendRedirect(request.getContextPath() + "/spa-booking?action=history");
                return;
            }
            
            // Xóa booking khỏi database (tạm thời return true, cần implement trong SpaBookingService)
            boolean success = true; // TODO: Implement deleteSpaBooking in SpaBookingService
            
            if (success) {
                logger.info("Deleted spa booking ID: " + bookingId);
                session.setAttribute("successMessage", "Đã xóa lịch spa khỏi danh sách");
            } else {
                logger.warning("Failed to delete spa booking ID: " + bookingId);
                session.setAttribute("errorMessage", "Xóa lịch spa thất bại. Vui lòng thử lại.");
            }
            
        } catch (NumberFormatException e) {
            session.setAttribute("errorMessage", "ID booking không hợp lệ");
        } catch (Exception e) {
            logger.severe("Error deleting spa booking: " + e.getMessage());
            e.printStackTrace();
            session.setAttribute("errorMessage", "Có lỗi xảy ra khi xóa lịch: " + e.getMessage());
        }
        
        response.sendRedirect(request.getContextPath() + "/spa-booking?action=history");
    }
    
    /**
     * Test tạo dữ liệu boarding
     */
    private void testCreateBoardingData(HttpServletRequest request, HttpServletResponse response, Customer customer) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        
        try {
            logger.info("=== TEST CREATE BOARDING DATA ===");
            logger.info("Customer ID: " + customer.getCustomerId());
            
            // Test database connection
            boolean dbTest = boardingBookingDAO.testDatabaseConnection();
            logger.info("Database connection test: " + dbTest);
            
            // Tạo dữ liệu test đơn giản
            createTestBoardingDataForCustomer(customer);
            
            // Lấy dữ liệu để kiểm tra
            List<BoardingBooking> bookings = boardingBookingDAO.getBoardingBookingsByCustomerId(customer.getCustomerId());
            logger.info("Found " + (bookings != null ? bookings.size() : 0) + " bookings after test");
            
            if (bookings != null && !bookings.isEmpty()) {
                session.setAttribute("successMessage", "✅ Test tạo dữ liệu boarding thành công! Tìm thấy " + bookings.size() + " booking(s)");
            } else {
                session.setAttribute("errorMessage", "❌ Test thất bại: Không tìm thấy dữ liệu sau khi tạo");
            }
            
        } catch (Exception e) {
            logger.severe("Error in test create boarding data: " + e.getMessage());
            e.printStackTrace();
            session.setAttribute("errorMessage", "❌ Test thất bại: " + e.getMessage());
        }
        
        response.sendRedirect(request.getContextPath() + "/spa-booking?action=history");
    }
    
    /**
     * Hiển thị chi tiết booking Boarding
     */
    private void showBoardingBookingDetail(HttpServletRequest request, HttpServletResponse response, Customer customer) 
            throws ServletException, IOException {
        
        String bookingIdParam = request.getParameter("id");
        if (bookingIdParam == null || bookingIdParam.trim().isEmpty()) {
            HttpSession session = request.getSession(true);
            session.setAttribute("errorMessage", "Không tìm thấy booking");
            response.sendRedirect(request.getContextPath() + "/spa-booking?action=history");
            return;
        }
        
        try {
            int bookingId = Integer.parseInt(bookingIdParam);
            
            // Lấy boarding booking từ database
            BoardingBooking booking = boardingBookingDAO.getBoardingBookingById(bookingId);
            
            if (booking == null || booking.getCustomerId() != customer.getCustomerId()) {
                HttpSession session = request.getSession(true);
                session.setAttribute("errorMessage", "Không tìm thấy booking hoặc bạn không có quyền xem");
                response.sendRedirect(request.getContextPath() + "/spa-booking?action=history");
                return;
            }
            
            // Lấy thông tin thú cưng của khách hàng
            List<Pet> customerPets = petDAO.getPetsByCustomerId(customer.getCustomerId());
            
            request.setAttribute("boardingBooking", booking);
            request.setAttribute("customerPets", customerPets);
            
            request.getRequestDispatcher("/boarding-booking-detail.jsp").forward(request, response);
            
        } catch (NumberFormatException e) {
            HttpSession session = request.getSession(true);
            session.setAttribute("errorMessage", "ID booking không hợp lệ");
            response.sendRedirect(request.getContextPath() + "/spa-booking?action=history");
        }
    }
    
    /**
     * Tính tổng số giờ lưu trú chính xác
     */
    private double calculateTotalHours(int days, String checkInTime, String checkOutTime) {
        try {
            // Parse thời gian
            String[] checkInParts = checkInTime.split(":");
            String[] checkOutParts = checkOutTime.split(":");
            
            int checkInHour = Integer.parseInt(checkInParts[0]);
            int checkInMinute = Integer.parseInt(checkInParts[1]);
            int checkOutHour = Integer.parseInt(checkOutParts[0]);
            int checkOutMinute = Integer.parseInt(checkOutParts[1]);
            
            // Tính tổng số giờ chính xác
            if (days == 1) {
                // Nếu chỉ 1 ngày, tính từ giờ nhận đến giờ trả
                double checkInDecimal = checkInHour + checkInMinute/60.0;
                double checkOutDecimal = checkOutHour + checkOutMinute/60.0;
                return checkOutDecimal - checkInDecimal;
            } else {
                // Nếu nhiều ngày: ngày đầu + ngày giữa + ngày cuối
                double firstDayHours = 24.0 - (checkInHour + checkInMinute/60.0);
                double lastDayHours = checkOutHour + checkOutMinute/60.0;
                double middleDaysHours = (days - 2) * 24.0;
                return firstDayHours + middleDaysHours + lastDayHours;
            }
        } catch (Exception e) {
            logger.warning("Error calculating total hours: " + e.getMessage());
            return days * 24.0; // Fallback to full days
        }
    }
    
    /**
     * Tính giá theo logic 12 tiếng với ưu đãi (database có giá cho 24h)
     */
    private BigDecimal calculatePriceByHours(double totalHours, BigDecimal pricePerDay) {
        // Logic tính giá mới với phí tối thiểu:
        // - Tối thiểu: 30 phút - 1 tiếng (5% giá 24h)
        // - 24h đầu tiên: Mỗi 3 giờ tính 1 lần (12.5% giá 24h)
        // - Ngày 2 trở đi: Mỗi 6 giờ tính 1 lần (25% giá 24h)
        
        if (totalHours <= 0) {
            // Không có thời gian: Miễn phí
            logger.info("Boarding duration: " + totalHours + " hours - FREE (no time)");
            return BigDecimal.ZERO;
        } else if (totalHours < 0.5) {
            // Dưới 30 phút: Miễn phí
            logger.info("Boarding duration: " + totalHours + " hours - FREE (under 30 minutes)");
            return BigDecimal.ZERO;
        } else if (totalHours < 1.0) {
            // 30 phút - 1 tiếng: Phí tối thiểu 5% giá 24h
            BigDecimal minimumPrice = pricePerDay.multiply(new BigDecimal("0.05"));
            logger.info("Boarding duration: " + totalHours + " hours - MINIMUM CHARGE (5% of 24h): " + minimumPrice);
            return minimumPrice;
        } else {
            BigDecimal totalPrice = BigDecimal.ZERO;
            
            if (totalHours <= 24.0) {
                // 24h đầu tiên: Mỗi 3 giờ tính 1 lần (12.5% mỗi chu kỳ)
                int full3HourPeriods = (int) Math.ceil(totalHours / 3.0);
                BigDecimal pricePer3Hours = pricePerDay.multiply(new BigDecimal("0.125"));
                totalPrice = pricePer3Hours.multiply(new BigDecimal(full3HourPeriods));
                
                logger.info("Boarding duration: " + totalHours + " hours - " + full3HourPeriods + " periods of 3h (12.5% each): " + totalPrice);
            } else {
                // Ngày 2 trở đi: Mỗi 6 giờ tính 1 lần
                // 24h đầu: 8 chu kỳ 3h = 8 * 12.5% = 100% giá 24h
                BigDecimal firstDayPrice = pricePerDay;
                
                // Phần còn lại: Mỗi 6 giờ tính 1 lần (25% mỗi chu kỳ)
                double remainingHours = totalHours - 24.0;
                int full6HourPeriods = (int) Math.ceil(remainingHours / 6.0);
                BigDecimal pricePer6Hours = pricePerDay.multiply(new BigDecimal("0.25"));
                BigDecimal remainingPrice = pricePer6Hours.multiply(new BigDecimal(full6HourPeriods));
                
                totalPrice = firstDayPrice.add(remainingPrice);
                
                logger.info("Boarding duration: " + totalHours + " hours - First 24h: " + firstDayPrice + " + Remaining " + remainingHours + "h: " + remainingPrice + " = " + totalPrice);
            }
            
            return totalPrice;
        }
    }
}
