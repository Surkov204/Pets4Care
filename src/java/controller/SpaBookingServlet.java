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
import dao.BookingDAO;
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
import model.Review;
import service.SpaBookingService;
import service.PayOSService;
import service.ReviewService;
import service.IReviewService;

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
    private BookingDAO bookingDAO;
    private PayOSService payOSService;
    private final IReviewService reviewService = new ReviewService();
    
    @Override
    public void init() throws ServletException {
        super.init();
        this.spaBookingService = new SpaBookingService();
        this.petDAO = new PetDAO();
        this.boardingBookingDAO = new BoardingBookingDAO();
        this.bookingDAO = new BookingDAO();
        this.payOSService = new PayOSService();
        
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
                showSpaServices(request, response, customer);
            } else if (action.equals("cart")) {
                // Hiển thị giỏ hàng Spa
                showSpaCart(request, response, customer);
            } else if (action.equals("history")) {
                // Hiển thị lịch sử đặt lịch Spa
                showSpaBookingHistory(request, response, customer);
            } else if (action.equals("detail")) {
                // Hiển thị chi tiết booking Spa
                showSpaBookingDetail(request, response, customer);
            } else if (action.equals("service-detail")) {
                // Hiển thị chi tiết dịch vụ Spa trước khi thêm vào giỏ hàng
                showServiceDetail(request, response, customer);
            } else if (action.equals("boarding-detail")) {
                // Hiển thị chi tiết booking Boarding
                showBoardingBookingDetail(request, response, customer);
            } else if (action.equals("test-boarding")) {
                // Test tạo dữ liệu boarding
                testCreateBoardingData(request, response, customer);
            } else if (action.equals("get-completed-bookings")) {
                // Lấy danh sách bookings đã hoàn thành để review
                getCompletedBookingsForReview(request, response, customer);
            } else if (action.equals("check-review-exists")) {
                // Kiểm tra xem đã review chưa
                checkReviewExists(request, response, customer);
            } else if (action.equals("get-service-reviews")) {
                // Lấy reviews của một service
                getServiceReviews(request, response);
            } else if (action.equals("get-time-slots")) {
                // Lấy danh sách time slots với trạng thái available/occupied
                getTimeSlots(request, response);
            } else if (action.equals("boarding-cart")) {
                // Hiển thị form đặt phòng lưu trú (chuyển đến spa cart)
                showSpaCart(request, response, customer);
            } else if (action.equals("get-boarding-reviews")) {
                // Lấy reviews của boarding booking
                getBoardingReviews(request, response);
            } else if (action.equals("submit-boarding-review")) {
                // Gửi review cho boarding booking
                submitBoardingReview(request, response, customer);
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
        
        // Set encoding sớm để đọc đúng UTF-8 parameters
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");
        
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
            logger.info("doPost action: " + action);
            
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
            } else if (action != null && action.equals("check-availability")) {
                // Kiểm tra khả dụng slot cho giỏ hiện tại
                checkSpaAvailability(request, response, customer);
            } else if (action != null && action.equals("get-boarding-details")) {
                // Lấy chi tiết boarding từ session
                getBoardingDetails(request, response, customer);
            } else if (action != null && action.equals("update-boarding-details")) {
                // Cập nhật chi tiết boarding trong session
                updateBoardingDetails(request, response, customer);
            } else if (action != null && action.equals("check-single-availability")) {
                // Kiểm tra khả dụng cho một dịch vụ
                checkSingleAvailability(request, response);
            } else if (action != null && action.equals("create-single-booking")) {
                // Tạo booking cho một dịch vụ
                createSingleBooking(request, response, customer);
            } else if (action != null && action.equals("create-test-boarding")) {
                // Tạo dữ liệu test boarding
                createTestBoardingData(request, response, customer);
            } else if (action != null && action.equals("initiate-spa-payment")) {
                // Khởi tạo thanh toán PayOS cho dịch vụ spa đơn lẻ
                initiateSpaPayment(request, response, customer);
            } else if (action != null && action.equals("cancel-boarding-booking")) {
                // Hủy boarding booking
                cancelBoardingBooking(request, response, customer);
            } else if (action != null && action.equals("create-boarding-booking")) {
                // Tạo boarding booking từ form
                createBoardingBookingFromForm(request, response, customer);
            } else if (action != null && action.equals("submit-service-review")) {
                // Gửi review cho service
                submitServiceReview(request, response, customer);
            } else if (action != null && action.equals("edit-service-review")) {
                // Sửa review cho service
                editServiceReview(request, response, customer);
            } else if (action != null && action.equals("delete-service-review")) {
                // Xóa review cho service
                deleteServiceReview(request, response, customer);
            } else if (action != null && action.equals("get-customer-pets")) {
                // Lấy danh sách pet của khách hàng
                getCustomerPets(request, response, customer);
            } else if (action != null && action.equals("delete-boarding-booking")) {
                // Xóa boarding booking khỏi database
                deleteBoardingBooking(request, response, customer);
            } else if (action != null && action.equals("delete-spa-booking")) {
                // Xóa spa booking khỏi database
                deleteSpaBooking(request, response, customer);
            } else if (action != null && action.equals("refund-spa-booking")) {
                // Hoàn tiền cho spa booking
                refundSpaBooking(request, response, customer);
            } else if (action != null && action.equals("submit-review")) {
                // Submit review cho service
                submitReview(request, response, customer);
            } else if (action != null && action.equals("confirm-boarding")) {
                // Staff xác nhận boarding booking: Chờ xác nhận → Chưa nhận thú cưng
                confirmBoardingBooking(request, response);
            } else if (action != null && action.equals("check-in-pet")) {
                // Staff nhận thú cưng: Chưa nhận thú cưng → Đang ở
                checkInPet(request, response);
            } else if (action != null && action.equals("check-out-pet")) {
                // Staff trả thú cưng: Đang ở → Đã nhận về
                checkOutPet(request, response);
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
    private void showSpaServices(HttpServletRequest request, HttpServletResponse response, Customer customer) 
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
        List<Booking> spaBookings = spaBookingService.getSpaBookingsByCustomerId(customer.getCustomerId());
        logger.info("Spa bookings count: " + (spaBookings != null ? spaBookings.size() : "null"));
        Map<Integer, String> spaStatusMap = new HashMap<>();
        if (spaBookings != null) {
            for (Booking b : spaBookings) {
                String display;
                String dbStatus = b.getStatus();
                if (dbStatus == null) {
                    display = "Hủy thanh toán";
                } else if (dbStatus.equalsIgnoreCase("completed") || dbStatus.equalsIgnoreCase("hoàn thành")) {
                    display = "Hoàn thành";
                } else if (dbStatus.equals("Đã xác nhận")) {
                    display = "Đã xác nhận";
                } else if (dbStatus.equalsIgnoreCase("đã thanh toán") || dbStatus.equalsIgnoreCase("confirmed")) {
                    display = "Đã thanh toán";
                } else if (dbStatus.equals("Chờ xác nhận") || dbStatus.equals("Chưa thanh toán")) {
                    display = "Hủy thanh toán";
                } else if (dbStatus.equalsIgnoreCase("cancelled") || dbStatus.equalsIgnoreCase("đã hủy") || dbStatus.equals("Đã hủy")) {
                    display = "Đã hủy";
                } else if (dbStatus.equals("Yêu cầu hoàn tiền")) {
                    display = "Đã hủy lịch";
                } else {
                    boolean paid = false;
                    try { if (b.getOrderId() > 0) paid = isOrderPaid(b.getOrderId()); } catch (Exception ignore) {}
                    display = paid ? "Đã thanh toán" : "Hủy thanh toán";
                }
                spaStatusMap.put(b.getBookingId(), display);
            }
        }
        String dateSpaStr = request.getParameter("dateSpa");
        java.sql.Date startDateSpa = null;
        if (dateSpaStr != null && !dateSpaStr.isEmpty()) {
            try { startDateSpa = java.sql.Date.valueOf(dateSpaStr); } catch (Exception e) {}
        }
        // Lọc spaBookings theo ngày nếu có chọn ngày (filter by startDateSpa)
        List<Booking> filteredSpaBookings = new ArrayList<>();
        if (startDateSpa != null && spaBookings != null) {
            for (Booking b : spaBookings) {
                if (b.getAppointmentStart() != null) {
                    java.time.LocalDate bookingDate = b.getAppointmentStart().toLocalDateTime().toLocalDate();
                    if (bookingDate.equals(startDateSpa.toLocalDate())) {
                        filteredSpaBookings.add(b);
                    }
                }
            }
            // Sắp xếp lại sau khi lọc để đảm bảo thứ tự theo thời gian đặt gần nhất
            filteredSpaBookings.sort((b1, b2) -> {
                if (b1.getCreatedAt() == null && b2.getCreatedAt() == null) return 0;
                if (b1.getCreatedAt() == null) return 1;
                if (b2.getCreatedAt() == null) return -1;
                return b2.getCreatedAt().compareTo(b1.getCreatedAt()); // DESC: mới nhất trước
            });
        } else {
            filteredSpaBookings = spaBookings;
        }
        // Lọc boardingBookings độc lập (filter by startDateBoarding)
        String dateBoardingStr = request.getParameter("dateBoarding");
        java.sql.Date startDateBoarding = null;
        if (dateBoardingStr != null && !dateBoardingStr.isEmpty()) {
            try { startDateBoarding = java.sql.Date.valueOf(dateBoardingStr); } catch (Exception e) {}
        }
        List<BoardingBooking> boardingBookings;
        if (startDateBoarding != null) {
            boardingBookings = boardingBookingDAO.getBoardingBookingsByCustomerIdAndDate(
                customer.getCustomerId(), startDateBoarding, startDateBoarding, 0, 100);
        } else {
            boardingBookings = boardingBookingDAO.getBoardingBookingsByCustomerId(customer.getCustomerId());
        }
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
                    if (booking.getCheckInDate() != null)
                        boardingService.put("checkInDate", new java.sql.Date(booking.getCheckInDate().getTime()).toString());
                    else boardingService.put("checkInDate", "");
                    if (booking.getCheckOutDate() != null)
                        boardingService.put("checkOutDate", new java.sql.Date(booking.getCheckOutDate().getTime()).toString());
                    else boardingService.put("checkOutDate", "");
                    boardingService.put("checkInTime", booking.getCheckInTime() != null ? booking.getCheckInTime() : "");
                    boardingService.put("checkOutTime", booking.getCheckOutTime() != null ? booking.getCheckOutTime() : "");
                    boardingService.put("petInfo", booking.getPetInfo() != null ? booking.getPetInfo() : "");
                    boardingService.put("status", booking.getStatus() != null ? booking.getStatus() : "Chờ xác nhận");
                    boardingService.put("isBoarding", true);
                    boardingService.put("createdAt", booking.getCreatedAt());
                    boardingService.put("specialNotes", booking.getSpecialNotes() != null ? booking.getSpecialNotes() : "");
                    boardingService.put("emergencyPhone1", booking.getEmergencyPhone1() != null ? booking.getEmergencyPhone1() : "");
                    boardingService.put("emergencyPhone2", booking.getEmergencyPhone2() != null ? booking.getEmergencyPhone2() : "");
                    boardingServices.add(boardingService);
                } catch (Exception e) {}
            }
        }
        request.setAttribute("spaBookings", filteredSpaBookings);
        request.setAttribute("spaStatusMap", spaStatusMap);
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
            
            // Lấy thông tin thú cưng của booking này (chỉ pet đã được chọn)
            List<Pet> bookingPets = new ArrayList<>();
            if (booking.getPetId() > 0) {
                Pet bookingPet = petDAO.getPetById(booking.getPetId());
                if (bookingPet != null) {
                    bookingPets.add(bookingPet);
                }
            }
            
            request.setAttribute("booking", booking);
            request.setAttribute("spaBookingDetails", spaBookingDetails);
            request.setAttribute("customerPets", bookingPets); // Chỉ hiển thị pet của booking này
            
            request.getRequestDispatcher("/spa-booking-detail.jsp").forward(request, response);
            
        } catch (NumberFormatException e) {
            HttpSession session = request.getSession(true);
            session.setAttribute("errorMessage", "ID booking không hợp lệ");
            response.sendRedirect(request.getContextPath() + "/spa-booking?action=history");
        }
    }
    
    /**
     * Hiển thị chi tiết dịch vụ Spa trước khi thêm vào giỏ hàng
     */
    private void showServiceDetail(HttpServletRequest request, HttpServletResponse response, Customer customer) 
            throws ServletException, IOException {
        
        String serviceIdParam = request.getParameter("serviceId");
        if (serviceIdParam == null || serviceIdParam.trim().isEmpty()) {
            HttpSession session = request.getSession(true);
            session.setAttribute("errorMessage", "Không tìm thấy dịch vụ");
            response.sendRedirect(request.getContextPath() + "/spa-booking?action=services");
            return;
        }
        
        try {
            int serviceId = Integer.parseInt(serviceIdParam);
            PetServiceModel service = spaBookingService.getSpaServiceById(serviceId);
            
            if (service == null || !service.isActive()) {
                HttpSession session = request.getSession(true);
                session.setAttribute("errorMessage", "Dịch vụ không tồn tại hoặc không còn hoạt động");
                response.sendRedirect(request.getContextPath() + "/spa-booking?action=services");
                return;
            }
            
            // Lấy danh sách reviews của dịch vụ (tối đa 50 reviews)
            List<Review> reviews = reviewService.listByService(serviceId, 50);
            if (reviews == null) {
                reviews = new ArrayList<>(); // Đảm bảo không null
            }
            
            // Kiểm tra xem customer đã từng mua/đặt dịch vụ này chưa
            boolean hasPurchasedService = reviewService.hasPurchasedService(customer.getCustomerId(), serviceId);
            
            // Lấy thông tin thú cưng của khách hàng để hiển thị trong form
            List<Pet> customerPets = petDAO.getPetsByCustomerId(customer.getCustomerId());
            if (customerPets == null) {
                customerPets = new ArrayList<>(); // Đảm bảo không null
            }

            request.setAttribute("service", service);
            request.setAttribute("reviews", reviews);
            request.setAttribute("customerPets", customerPets);
            request.setAttribute("hasPurchasedService", hasPurchasedService);
            
            request.getRequestDispatcher("/spa-service-detail.jsp").forward(request, response);
            
        } catch (NumberFormatException e) {
            HttpSession session = request.getSession(true);
            session.setAttribute("errorMessage", "ID dịch vụ không hợp lệ");
            response.sendRedirect(request.getContextPath() + "/spa-booking?action=services");
        } catch (Exception e) {
            logger.severe("Error showing service detail: " + e.getMessage());
            e.printStackTrace();
            HttpSession session = request.getSession(true);
            session.setAttribute("errorMessage", "Có lỗi xảy ra khi tải chi tiết dịch vụ");
            response.sendRedirect(request.getContextPath() + "/spa-booking?action=services");
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
                
            } catch (ParseException e) {
                HttpSession session = request.getSession(true);
                session.setAttribute("errorMessage", "Thời gian hẹn không hợp lệ");
                response.sendRedirect(request.getContextPath() + "/spa-booking?action=cart");
                return;
            }
            
            // Đã xóa tất cả validation thời gian - cho phép đặt bất kỳ giờ nào, nhiều khách có thể đặt cùng giờ

            // Tính tổng tiền từ giỏ hàng
            BigDecimal totalAmount = BigDecimal.ZERO;
            for (Map.Entry<Integer, Integer> entry : spaCart.entrySet()) {
                int serviceId = entry.getKey();
                int quantity = entry.getValue();
                PetServiceModel service = spaBookingService.getSpaServiceById(serviceId);
                if (service != null) {
                    totalAmount = totalAmount.add(service.getPrice().multiply(BigDecimal.valueOf(quantity)));
                }
            }

            // Tạo booking
            boolean success = spaBookingService.createSpaBookingFromCart(customer, spaCart, appointmentStart, note);
            
            if (success) {
                // Lấy booking_id vừa tạo để tạo payment record
                try {
                    // Tìm booking mới nhất của customer với appointment_start tương ứng
                    List<Booking> recentBookings = spaBookingService.getSpaBookingsByCustomerId(customer.getCustomerId());
                    Booking newBooking = null;
                    for (Booking b : recentBookings) {
                        if (b.getAppointmentStart() != null && 
                            Math.abs(b.getAppointmentStart().getTime() - appointmentStart.getTime()) < 60000) { // ±1 phút
                            newBooking = b;
                            break;
                        }
                    }
                    
                    if (newBooking != null) {
                        // Tạo payment record với status 'pending'
                        String description = "Thanh toan Spa #" + newBooking.getBookingId();
                        int paymentId = payOSService.createPaymentRecord("spa", newBooking.getBookingId(), 
                            customer.getCustomerId(), totalAmount.doubleValue(), 0, description);
                        if (paymentId > 0) {
                            // Cập nhật payment method và status
                            try (java.sql.Connection conn = utils.DBConnection.getConnection();
                                 java.sql.PreparedStatement ps = conn.prepareStatement(
                                     "UPDATE dbo.Payment SET payment_method = 'CASH', payment_status = 'pending' " +
                                     "WHERE payment_id = ?")) {
                                ps.setInt(1, paymentId);
                                ps.executeUpdate();
                                logger.info("✅ Payment record created for spa booking #" + newBooking.getBookingId());
                            }
                        }
                    }
                } catch (Exception e) {
                    logger.warning("Could not create payment record for spa booking: " + e.getMessage());
                    e.printStackTrace();
                }
                
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

    // Kiểm tra đơn hàng đã thanh toán (dựa PayOS)
    private boolean isOrderPaid(int orderId) {
        try {
            Map<String, Object> order = payOSService.getOrderInfo(orderId);
            if (order == null || order.isEmpty()) return false;
            Object paymentStatus = order.get("payment_status");
            if (paymentStatus == null) paymentStatus = order.get("paymentStatus");
            String st = paymentStatus != null ? paymentStatus.toString() : "";
            return "Da thanh toan".equalsIgnoreCase(st) || "paid".equalsIgnoreCase(st);
        } catch (Exception e) {
            logger.warning("isOrderPaid error: " + e.getMessage());
            return false;
        }
    }
    
    /**
     * Kiểm tra order đã thanh toán từ database trực tiếp
     */
    private boolean isOrderPaidFromDB(int orderId) {
        try {
            String sql = "SELECT payment_status FROM [Order] WHERE order_id = ?";
            try (java.sql.Connection conn = utils.DBConnection.getConnection();
                 java.sql.PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, orderId);
                try (java.sql.ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        String paymentStatus = rs.getString("payment_status");
                        if (paymentStatus != null) {
                            String status = paymentStatus.trim();
                            boolean paid = "Đã thanh toán".equalsIgnoreCase(status) ||
                                         "Da thanh toan".equalsIgnoreCase(status) ||
                                         "paid".equalsIgnoreCase(status) ||
                                         status.contains("thanh toán") ||
                                         status.contains("thanh toan");
                            logger.info("Order ID " + orderId + " payment_status from DB: '" + paymentStatus + "', isPaid: " + paid);
                            return paid;
                        }
                    }
                }
            }
        } catch (Exception e) {
            logger.warning("isOrderPaidFromDB error for orderId " + orderId + ": " + e.getMessage());
        }
        return false;
    }

    /**
     * Kiểm tra khả dụng slot theo giỏ hiện tại (AJAX)
     */
    private void checkSpaAvailability(HttpServletRequest request, HttpServletResponse response, Customer customer)
            throws IOException {
        try {
            String appointmentDate = request.getParameter("appointmentDate");
            String appointmentTime = request.getParameter("appointmentTime");
            if (appointmentDate == null || appointmentTime == null) {
                response.setContentType("application/json");
                response.getWriter().write("{\"success\":false,\"message\":\"Thiếu ngày/giờ hẹn\"}");
                return;
            }

            // Lấy giỏ hàng Spa từ session
            @SuppressWarnings("unchecked")
            Map<Integer, Integer> spaCart = (Map<Integer, Integer>) request.getSession().getAttribute("spaCart");
            if (spaCart == null || spaCart.isEmpty()) {
                response.setContentType("application/json");
                response.getWriter().write("{\"success\":false,\"message\":\"Giỏ hàng trống\"}");
                return;
            }

            List<Integer> serviceIds = new ArrayList<>();
            for (Map.Entry<Integer, Integer> entry : spaCart.entrySet()) {
                serviceIds.add(entry.getKey());
            }

            SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm");
            Timestamp start = new Timestamp(dateFormat.parse(appointmentDate + " " + appointmentTime).getTime());

            boolean available = spaBookingService.isSpaSlotAvailable(start, serviceIds);
            response.setContentType("application/json");
            response.getWriter().write("{\"success\":" + available + "}");

        } catch (Exception e) {
            logger.severe("Error checking availability: " + e.getMessage());
            response.setContentType("application/json");
            response.getWriter().write("{\"success\":false,\"message\":\"Lỗi kiểm tra khả dụng\"}");
        }
    }

    /**
     * Kiểm tra khả dụng một dịch vụ đơn lẻ (AJAX)
     */
    private void checkSingleAvailability(HttpServletRequest request, HttpServletResponse response) throws IOException {
        try {
            int serviceId = getSafeIntParameter(request, "serviceId", 0);
            int quantity = getSafeIntParameter(request, "quantity", 1);
            String appointmentDate = request.getParameter("appointmentDate");
            String appointmentTime = request.getParameter("appointmentTime");
            if (serviceId <= 0 || quantity <= 0 || appointmentDate == null || appointmentTime == null) {
                response.setContentType("application/json");
                response.getWriter().write("{\"success\":false,\"message\":\"Thiếu dữ liệu\"}");
                return;
            }
            java.text.SimpleDateFormat df = new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm");
            java.sql.Timestamp start = new java.sql.Timestamp(df.parse(appointmentDate + " " + appointmentTime).getTime());
            boolean ok = spaBookingService.isSpaSlotAvailableForSingle(start, serviceId, quantity);
            response.setContentType("application/json");
            response.getWriter().write("{\"success\":" + ok + "}");
        } catch (Exception e) {
            logger.severe("checkSingleAvailability error: " + e.getMessage());
            response.setContentType("application/json");
            response.getWriter().write("{\"success\":false}");
        }
    }

    /**
     * Khởi tạo thanh toán PayOS cho dịch vụ spa (AJAX)
     */
    private void initiateSpaPayment(HttpServletRequest request, HttpServletResponse response, Customer customer)
            throws IOException {
        try {
            int serviceId = getSafeIntParameter(request, "serviceId", 0);
            int quantity = getSafeIntParameter(request, "quantity", 1);
            if (serviceId <= 0 || quantity <= 0) {
                response.setContentType("application/json");
                response.getWriter().write("{\"success\":false,\"message\":\"Thiếu dịch vụ/ số lượng\"}");
                return;
            }

            PetServiceModel service = spaBookingService.getSpaServiceById(serviceId);
            if (service == null) {
                response.setContentType("application/json");
                response.getWriter().write("{\"success\":false,\"message\":\"Dịch vụ không hợp lệ\"}");
                return;
            }

            // Tạo orderCode unique từ timestamp
            long timestamp = System.currentTimeMillis();
            int orderCode = (int) ((timestamp % 1000000000) * 1000 + (serviceId % 1000));
            if (orderCode < 0) {
                orderCode = Math.abs(orderCode);
            }
            
            double amount = service.getPrice().doubleValue() * quantity;
            // Giới hạn description <= 25 ký tự cho PayOS
            String description = "Thanh toan Spa #" + serviceId;
            if (description.length() > 25) {
                description = "Spa #" + serviceId;
            }

            String baseUrl = buildBaseUrl(request);
            String returnUrl = baseUrl + "/payos/return?orderId=" + orderCode;
            String cancelUrl = baseUrl + "/payos/cancel?orderId=" + orderCode;

            String paymentUrl = payOSService.createPaymentLink(orderCode, amount, description, returnUrl, cancelUrl);
            response.setContentType("application/json");
            response.getWriter().write("{\"success\":true,\"url\":\"" + paymentUrl + "\"}");
        } catch (Exception e) {
            logger.severe("initiateSpaPayment error: " + e.getMessage());
            response.setContentType("application/json");
            response.getWriter().write("{\"success\":false,\"message\":\"Không tạo được link thanh toán\"}");
        }
    }

    /**
     * Tạo booking cho một dịch vụ đơn lẻ
     */
    private void createSingleBooking(HttpServletRequest request, HttpServletResponse response, Customer customer)
            throws IOException {
        try {
            int serviceId = getSafeIntParameter(request, "serviceId", 0);
            int quantity = getSafeIntParameter(request, "quantity", 1); // Số lượng = số pet được chọn
            String petIdsParam = request.getParameter("petIds"); // Danh sách pet IDs (CSV)
            String note = getSafeParameter(request, "note", "");
            String paymentMethod = getSafeParameter(request, "paymentMethod", "payos"); // payos only
            String appointmentDate = request.getParameter("appointmentDate");
            String appointmentTime = request.getParameter("appointmentTime");
            
            // Parse pet IDs từ chuỗi CSV
            List<Integer> petIds = new ArrayList<>();
            if (petIdsParam != null && !petIdsParam.trim().isEmpty()) {
                String[] petIdArray = petIdsParam.split(",");
                for (String petIdStr : petIdArray) {
                    try {
                        int petId = Integer.parseInt(petIdStr.trim());
                        if (petId > 0) {
                            petIds.add(petId);
                        }
                    } catch (NumberFormatException e) {
                        // Bỏ qua giá trị không hợp lệ
                    }
                }
            }
            
            // Fallback: nếu không có petIds, dùng petId cũ (tương thích)
            if (petIds.isEmpty()) {
                int petId = getSafeIntParameter(request, "petId", 0);
                if (petId > 0) {
                    petIds.add(petId);
                }
            }
            
            if (serviceId <= 0 || petIds.isEmpty() || appointmentDate == null || appointmentTime == null) {
                response.setContentType("application/json");
                response.getWriter().write("{\"success\":false,\"message\":\"Thiếu dữ liệu\"}");
                return;
            }
            
            java.text.SimpleDateFormat df = new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm");
            java.sql.Timestamp start = new java.sql.Timestamp(df.parse(appointmentDate + " " + appointmentTime).getTime());
            
            // Số lượng thực tế = số pet được chọn
            quantity = petIds.size();
            
            logger.info("=== CREATE SINGLE BOOKING DEBUG ===");
            logger.info("Service ID: " + serviceId);
            logger.info("Quantity: " + quantity);
            logger.info("Pet IDs: " + petIds);
            logger.info("Appointment Date: " + appointmentDate);
            logger.info("Appointment Time: " + appointmentTime);
            logger.info("Payment Method: " + paymentMethod);
            logger.info("Note: " + note);
            
            // Nếu payOS: tạo booking trước, lưu orderCode vào booking, rồi tạo link thanh toán
            if ("payos".equalsIgnoreCase(paymentMethod)) {
                try {
                    // Tạo booking cho mỗi pet và lấy booking_id
                    List<Integer> createdBookingIds = new ArrayList<>();
                    for (int petId : petIds) {
                        logger.info("Creating booking for pet ID: " + petId);
                        int bookingId = spaBookingService.createSingleSpaBooking(customer, petId, serviceId, 1, start, note);
                        logger.info("Booking creation result for pet " + petId + ": booking_id = " + bookingId);
                        if (bookingId > 0) {
                            createdBookingIds.add(bookingId);
                        } else {
                            logger.severe("Failed to create booking for pet ID: " + petId);
                        }
                    }
                    
                    if (createdBookingIds.isEmpty()) {
                        logger.severe("Failed to create any bookings. Pet IDs attempted: " + petIds);
                        response.setContentType("application/json");
                        response.getWriter().write("{\"success\":false,\"message\":\"Không thể tạo booking. Vui lòng kiểm tra lại thông tin thú cưng và dịch vụ.\"}");
                        return;
                    }
                    
                    logger.info("Successfully created " + createdBookingIds.size() + " bookings. IDs: " + createdBookingIds);
                    
                    // Tạo orderCode unique để tránh trùng với PayOS
                    long timestamp = System.currentTimeMillis();
                    int firstBookingId = createdBookingIds.get(0);
                    // Tạo số nguyên unique từ timestamp và booking_id
                    int orderCode = (int) ((timestamp % 1000000000) * 1000 + (firstBookingId % 1000));
                    if (orderCode < 0) {
                        orderCode = Math.abs(orderCode);
                    }
                    logger.info("Generated unique orderCode: " + orderCode + " (from timestamp: " + timestamp + ", bookingId: " + firstBookingId + ")");
                    
                    double amount = spaBookingService.getSpaServiceById(serviceId).getPrice().doubleValue() * quantity;
                    // Giới hạn description <= 25 ký tự cho PayOS
                    String description = "Thanh toan Spa #" + serviceId;
                    if (description.length() > 25) {
                        description = description.substring(0, 25);
                    }
                    
                    // Lưu orderCode vào tất cả các booking đã tạo
                    try (java.sql.Connection conn = utils.DBConnection.getConnection();
                         java.sql.PreparedStatement ps = conn.prepareStatement(
                             "UPDATE dbo.Booking SET order_id = ? WHERE booking_id = ?")) {
                        for (int bookingId : createdBookingIds) {
                            ps.setInt(1, orderCode);
                            ps.setInt(2, bookingId);
                            ps.addBatch();
                        }
                        ps.executeBatch();
                    }
                    
                    // Tạo baseUrl an toàn
                    String baseUrl = buildBaseUrl(request);
                    
                    String commonParams = "orderId=" + orderCode + "&type=service" +
                            "&serviceId=" + serviceId + "&quantity=" + quantity + "&amount=" + amount;
                    String returnUrl = baseUrl + "/payos/return?" + commonParams;
                    String cancelUrl = baseUrl + "/payos/cancel?" + commonParams;
                    
                    logger.info("Creating PayOS payment link - orderCode: " + orderCode + ", amount: " + amount);
                    logger.info("Return URL: " + returnUrl);
                    logger.info("Cancel URL: " + cancelUrl);
                    
                    String paymentUrl = payOSService.createPaymentLink(orderCode, amount, description, returnUrl, cancelUrl);
                    
                    logger.info("PayOS payment URL result: " + (paymentUrl != null ? paymentUrl : "NULL"));
                    
                    if (paymentUrl == null || paymentUrl.trim().isEmpty()) {
                        logger.severe("PayOS payment URL is null or empty!");
                        
                        // Lấy thông tin lỗi chi tiết từ PayOSService
                        String payosError = payOSService.getLastPayOSError();
                        String payosResponse = payOSService.getLastPayOSResponse();
                        
                        logger.severe("PayOS Error: " + (payosError != null ? payosError : "Unknown"));
                        logger.severe("PayOS Response: " + (payosResponse != null ? payosResponse : "No response"));
                        
                        response.setContentType("application/json");
                        response.setCharacterEncoding("UTF-8");
                        
                        // Tạo error message chi tiết
                        String errorMsg = "Không thể tạo link thanh toán PayOS.";
                        if (payosError != null && !payosError.trim().isEmpty()) {
                            errorMsg += " Lỗi: " + payosError;
                        } else if (payosResponse != null && !payosResponse.trim().isEmpty()) {
                            // Cố gắng parse response để lấy error message
                            try {
                                com.google.gson.JsonObject json = com.google.gson.JsonParser.parseString(payosResponse).getAsJsonObject();
                                if (json.has("desc")) {
                                    errorMsg += " " + json.get("desc").getAsString();
                                } else if (json.has("message")) {
                                    errorMsg += " " + json.get("message").getAsString();
                                }
                            } catch (Exception e) {
                                // Không parse được, dùng message mặc định
                            }
                        }
                        errorMsg += " Vui lòng thử lại hoặc chọn phương thức thanh toán khác.";
                        
                        // Escape JSON
                        String escapedMsg = errorMsg.replace("\\", "\\\\").replace("\"", "\\\"");
                        response.getWriter().write("{\"success\":false,\"message\":\"" + escapedMsg + "\"}");
                        return;
                    }
                    
                    // Escape JSON để tránh lỗi nếu URL có ký tự đặc biệt
                    String escapedUrl = paymentUrl.replace("\\", "\\\\").replace("\"", "\\\"");
                    
                    response.setContentType("application/json");
                    response.setCharacterEncoding("UTF-8");
                    response.getWriter().write("{\"success\":true,\"payment\":\"payos\",\"url\":\"" + escapedUrl + "\"}");
                    logger.info("Successfully returned PayOS payment URL to client");
                    return;
                } catch (Exception ex) {
                    logger.severe("PayOS create link error: " + ex.getMessage());
                    ex.printStackTrace();
                    response.setContentType("application/json");
                    response.getWriter().write("{\"success\":false,\"message\":\"Không tạo được link PayOS: " + ex.getMessage() + "\"}");
                    return;
                }
            }

            // Chỉ chấp nhận thanh toán PayOS cho dịch vụ spa
            // Nếu không phải PayOS thì trả lỗi
            logger.warning("Invalid payment method for service booking: " + paymentMethod + ". Only PayOS is allowed.");
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            response.getWriter().write("{\"success\":false,\"message\":\"Chỉ chấp nhận thanh toán PayOS cho dịch vụ spa\"}");
        } catch (Exception e) {
            logger.severe("createSingleBooking error: " + e.getMessage());
            e.printStackTrace();
            response.setContentType("application/json");
            String errorMessage = e.getMessage() != null ? e.getMessage().replace("\"", "\\\"") : "Unknown error";
            response.getWriter().write("{\"success\":false,\"message\":\"" + errorMessage + "\"}");
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
            
            String status = booking.getStatus();
            if (status == null) status = "";
            
            // Log chi tiết để debug
            logger.info("=== CANCEL BOOKING DEBUG ===");
            logger.info("Booking ID: " + bookingId);
            logger.info("Status from DB (raw): '" + status + "'");
            logger.info("Status length: " + status.length());
            logger.info("Status bytes: " + java.util.Arrays.toString(status.getBytes()));
            
            // Kiểm tra status đã thanh toán - CHỈ cho phép "Đã thanh toán", KHÔNG cho "Chưa thanh toán" hoặc "Hủy thanh toán"
            String statusTrimmed = status.trim();
            boolean isPaid = 
                "Đã thanh toán".equals(statusTrimmed) ||
                "Đã thanh toán".equalsIgnoreCase(statusTrimmed) ||
                // Kiểm tra thêm các trường hợp khác
                statusTrimmed.equalsIgnoreCase("confirmed") ||
                // Kiểm tra qua order_id nếu có (chỉ khi không phải "Chưa thanh toán")
                (!statusTrimmed.equals("Chưa thanh toán") && 
                 !statusTrimmed.equalsIgnoreCase("chưa thanh toán") &&
                 booking.getOrderId() > 0 && isOrderPaid(booking.getOrderId())) ||
                // Kiểm tra trực tiếp từ database Order nếu có order_id
                (!statusTrimmed.equals("Chưa thanh toán") && 
                 !statusTrimmed.equalsIgnoreCase("chưa thanh toán") &&
                 booking.getOrderId() > 0 && isOrderPaidFromDB(booking.getOrderId()));
            
            // Kiểm tra đã hủy chưa
            boolean isCancelled = 
                "Đã hủy".equals(statusTrimmed) ||
                "Yêu cầu hoàn tiền".equals(statusTrimmed) ||
                statusTrimmed.equalsIgnoreCase("cancelled") ||
                statusTrimmed.equalsIgnoreCase("đã hủy") ||
                statusTrimmed.contains("hủy") ||
                statusTrimmed.contains("Hủy") ||
                statusTrimmed.contains("HỦY");
            
            boolean canCancel = isPaid && !isCancelled;
            
            logger.info("isPaid: " + isPaid);
            logger.info("isCancelled: " + isCancelled);
            logger.info("canCancel: " + canCancel);
            
            if (!canCancel) {
                String reason;
                
                if (isCancelled) {
                    reason = "Booking này đã được hủy trước đó. Trạng thái: '" + status + "'";
                } else if (!isPaid) {
                    reason = "Chỉ có thể hủy booking đã thanh toán. Trạng thái hiện tại: '" + status + "'";
                    logger.warning("Booking ID " + bookingId + " không phải đã thanh toán. Status: '" + status + "'");
                } else {
                    reason = "Không thể hủy booking này. Trạng thái: '" + status + "'";
                }
                
                logger.warning("Cannot cancel booking ID " + bookingId + ". Reason: " + reason);
                session.setAttribute("errorMessage", reason);
                response.sendRedirect(request.getContextPath() + "/spa-booking?action=history");
                return;
            }
            
            logger.info("Booking ID " + bookingId + " passed validation, proceeding to cancel...");
            
            // Hủy booking - cập nhật status thành "Yêu cầu hoàn tiền" và gửi email biên lai
            // Sử dụng booking object đã lấy được thay vì query lại
            logger.info("Attempting to cancel booking ID: " + bookingId);
            logger.info("Using booking object with status: " + booking.getStatus());
            boolean success = spaBookingService.cancelSpaBookingWithRefund(booking, customer);
            
            if (success) {
                logger.info("Cancel booking ID " + bookingId + " successful");
                
                // Cập nhật hoặc tạo payment record với status 'cancelled'
                try {
                    // Tìm payment record theo booking_id
                    try (java.sql.Connection conn = utils.DBConnection.getConnection();
                         java.sql.PreparedStatement ps = conn.prepareStatement(
                             "SELECT payment_id FROM dbo.Payment WHERE payment_type = 'spa' AND reference_id = ?")) {
                        ps.setInt(1, bookingId);
                        try (java.sql.ResultSet rs = ps.executeQuery()) {
                            if (rs.next()) {
                                // Cập nhật payment record hiện có
                                int paymentId = rs.getInt("payment_id");
                                try (java.sql.PreparedStatement ps2 = conn.prepareStatement(
                                    "UPDATE dbo.Payment SET payment_status = 'cancelled' WHERE payment_id = ?")) {
                                    ps2.setInt(1, paymentId);
                                    ps2.executeUpdate();
                                    logger.info("✅ Updated payment record #" + paymentId + " to cancelled");
                                }
                            } else {
                                // Tạo payment record mới với status 'cancelled'
                                // Tính tổng tiền từ booking services
                                BigDecimal totalAmount = BigDecimal.ZERO;
                                List<BookingServiceItem> services = spaBookingService.getSpaBookingDetails(bookingId);
                                for (BookingServiceItem item : services) {
                                    if (item.getPrice() != null) {
                                        totalAmount = totalAmount.add(
                                            item.getPrice().multiply(BigDecimal.valueOf(item.getQuantity())));
                                    }
                                }
                                
                                String description = "Thanh toan Spa #" + bookingId + " (da huy)";
                                int paymentId = payOSService.createPaymentRecord("spa", bookingId, 
                                    customer.getCustomerId(), totalAmount.doubleValue(), 0, description);
                                if (paymentId > 0) {
                                    try (java.sql.PreparedStatement ps3 = conn.prepareStatement(
                                        "UPDATE dbo.Payment SET payment_method = 'CASH', payment_status = 'cancelled' " +
                                        "WHERE payment_id = ?")) {
                                        ps3.setInt(1, paymentId);
                                        ps3.executeUpdate();
                                        logger.info("✅ Created payment record #" + paymentId + " with cancelled status");
                                    }
                                }
                            }
                        }
                    }
                } catch (Exception e) {
                    logger.warning("Could not update/create payment record for cancelled spa booking: " + e.getMessage());
                    e.printStackTrace();
                }
                
                // Thêm flag để hiển thị popup hoàn tiền
                session.setAttribute("showRefundPopup", "true");
                session.setAttribute("successMessage", "Đã hủy đặt lịch Spa thành công. Vui lòng đến cửa hàng để được hoàn tiền.");
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
                    boardingDetails.put("status", "Chờ xác nhận");
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
            // Chỉ cho phép hủy ở trạng thái "Chờ xác nhận" hoặc "Chưa nhận thú cưng"
            // Không thể hủy khi đã "Đang ở" hoặc "Đã nhận về"
            String status = booking.getStatus();
            boolean canCancel = "Chờ xác nhận".equals(status) || 
                               "pending".equals(status) ||
                               "Chưa nhận thú cưng".equals(status);
            
            if (!canCancel) {
                String reason;
                if ("Đã hủy".equals(status) || "cancelled".equals(status)) {
                    reason = "Booking này đã được hủy trước đó";
                } else if ("Đã nhận về".equals(status) || "Hoàn thành".equals(status) || "completed".equals(status)) {
                    reason = "Booking này đã hoàn thành, không thể hủy";
                } else if ("Đang ở".equals(status) || "Đang thuê".equals(status)) {
                    reason = "Thú cưng đang ở trong phòng, không thể hủy. Vui lòng liên hệ nhân viên để trả thú cưng.";
                } else {
                    reason = "Booking có trạng thái '" + status + "' không thể hủy";
                }
                
                session.setAttribute("errorMessage", reason);
                response.sendRedirect(request.getContextPath() + "/spa-booking?action=history");
                return;
            }
            
            // Hủy booking - cập nhật status thành "Đã hủy"
            // Nếu booking đang ở "Chưa nhận thú cưng", có thể cần trả lại phòng (nhưng thực ra phòng chưa được giữ)
            boolean success = boardingBookingDAO.updateBookingStatus(bookingId, "Đã hủy");
            
            if (success) {
                logger.info("Cancelled boarding booking ID: " + bookingId + " (status changed to: Đã hủy)");
                session.setAttribute("successMessage", "Đã hủy lịch lưu trú thành công. Bạn có thể xóa booking này khỏi danh sách.");
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
            
            // Parse dates để tính số ngày thực tế
            SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
            java.util.Date checkIn = dateFormat.parse(checkInDate);
            java.util.Date checkOut = dateFormat.parse(checkOutDate);
            
            // Tính số ngày thực tế từ ngày check-in đến check-out
            long timeDiff = checkOut.getTime() - checkIn.getTime();
            int actualBoardingDays = (int) Math.ceil(timeDiff / (1000.0 * 60 * 60 * 24));
            
            // Nếu boardingDaysStr từ form = 0 hoặc âm, dùng giá trị thực tế tính từ dates
            int boardingDays = Math.max(Integer.parseInt(boardingDaysStr), actualBoardingDays);
            
            // Đảm bảo boardingDays >= 1 để tính đúng giờ
            if (boardingDays < 1) {
                boardingDays = 1; // Tối thiểu 1 ngày để tính đúng logic giờ
                logger.info("Adjusting boardingDays to 1 for hours calculation");
            }
            
            logger.info("Form boardingDays: " + boardingDaysStr);
            logger.info("Actual boardingDays from dates: " + actualBoardingDays);
            logger.info("Final boardingDays used: " + boardingDays);
            logger.info("Price per day: " + pricePerDay);
            
            // Tính tổng số giờ lưu trú
            double totalHours = calculateTotalHours(boardingDays, checkInTime, checkOutTime);
            logger.info("Total hours calculated: " + totalHours);
            
            // Tính giá theo logic 12 tiếng với ưu đãi
            BigDecimal totalPrice = calculatePriceByHours(totalHours, pricePerDay);
            
            // Validate price and days
            if (pricePerDay.compareTo(BigDecimal.ZERO) <= 0) {
                session.setAttribute("errorMessage", "Giá mỗi ngày phải lớn hơn 0");
                response.sendRedirect(request.getContextPath() + "/spa-booking?action=history");
                return;
            }
            
            // Validate boardingDays hợp lệ (đã được tính từ dates)
            if (boardingDays > 30) {
                session.setAttribute("errorMessage", "Số ngày lưu trú không được vượt quá 30 ngày");
                response.sendRedirect(request.getContextPath() + "/spa-service.jsp");
                return;
            }
            
            // Validate dates
            java.util.Calendar cal = java.util.Calendar.getInstance();
            cal.set(java.util.Calendar.HOUR_OF_DAY, 0);
            cal.set(java.util.Calendar.MINUTE, 0);
            cal.set(java.util.Calendar.SECOND, 0);
            cal.set(java.util.Calendar.MILLISECOND, 0);
            java.util.Date today = cal.getTime();
            
            if (checkIn.before(today)) {
                session.setAttribute("errorMessage", "Ngày nhận không được là ngày quá khứ");
                response.sendRedirect(request.getContextPath() + "/spa-booking?action=history");
                return;
            }
            
            if (!isValidDateRange(checkIn, checkOut)) {
                session.setAttribute("errorMessage", "Ngày trả phải sau hoặc bằng ngày nhận");
                response.sendRedirect(request.getContextPath() + "/spa-booking?action=history");
                return;
            }
            
            // Parse timestamps
            Timestamp checkInTimestamp = new Timestamp(checkIn.getTime());
            Timestamp checkOutTimestamp = new Timestamp(checkOut.getTime());
            
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
                
                // Lấy payment method
                String paymentMethod = request.getParameter("paymentMethod");
                logger.info("Payment method: " + paymentMethod);
                
                // Nếu chọn PayOS → redirect đến PayOS
                if ("payos".equalsIgnoreCase(paymentMethod)) {
                    String baseUrl = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort()
                            + request.getContextPath();
                    response.sendRedirect(baseUrl + "/boarding-room?action=initiate-boarding-payment&bookingId=" + booking.getBookingId());
                    return;
                }
                
                // Nếu chọn tiền mặt, chỉ cần redirect đến trang lịch sử
                session.setAttribute("successMessage", 
                    "Đặt phòng lưu trú thành công! Mã đặt phòng: " + booking.getBookingId() + 
                    ". Vui lòng thanh toán khi đến nhận thú cưng.");
            } else {
                logger.warning("Failed to create boarding booking from form");
                session.setAttribute("errorMessage", "Đặt phòng thất bại. Vui lòng thử lại hoặc liên hệ hỗ trợ.");
            }
            
        } catch (NumberFormatException e) {
            logger.warning("Number format error: " + e.getMessage());
            session.setAttribute("errorMessage", "Dữ liệu số không hợp lệ. Vui lòng kiểm tra lại giá và số ngày.");
            response.sendRedirect(request.getContextPath() + "/spa-service.jsp");
        } catch (java.text.ParseException e) {
            logger.warning("Date parse error: " + e.getMessage());
            session.setAttribute("errorMessage", "Ngày tháng không hợp lệ. Vui lòng chọn lại ngày nhận và ngày trả.");
            response.sendRedirect(request.getContextPath() + "/spa-service.jsp");
        } catch (IllegalArgumentException e) {
            logger.warning("Illegal argument error: " + e.getMessage());
            session.setAttribute("errorMessage", "Dữ liệu không hợp lệ: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/spa-service.jsp");
        } catch (Exception e) {
            logger.severe("Unexpected error creating boarding booking from form: " + e.getMessage());
            logger.severe("Stack trace: " + java.util.Arrays.toString(e.getStackTrace()));
            e.printStackTrace();
            session.setAttribute("errorMessage", "Có lỗi xảy ra khi đặt phòng. Vui lòng thử lại hoặc liên hệ hỗ trợ.");
            response.sendRedirect(request.getContextPath() + "/spa-service.jsp");
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
                json.append("\"healthStatus\":\"").append(escapeJson(pet.getHealthStatus())).append("\",");
                Double weight = pet.getWeightKg();
                json.append("\"weightKg\":");
                if (weight != null) {
                    json.append(weight);
                } else {
                    json.append("null");
                }
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
     * Tạo baseUrl an toàn từ request
     */
    private String buildBaseUrl(HttpServletRequest request) {
        String scheme = request.getScheme();
        String serverName = request.getServerName();
        int port = request.getServerPort();
        String contextPath = request.getContextPath();
        
        // Xử lý contextPath null hoặc rỗng
        if (contextPath == null || contextPath.trim().isEmpty()) {
            contextPath = "";
        }
        
        StringBuilder url = new StringBuilder();
        url.append(scheme).append("://").append(serverName);
        
        // Chỉ thêm port nếu không phải port chuẩn (80 cho http, 443 cho https)
        if ((scheme.equals("http") && port != 80) || (scheme.equals("https") && port != 443)) {
            url.append(":").append(port);
        }
        
        url.append(contextPath);
        
        return url.toString();
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
            
            // KHÔNG cho phép xóa booking đã thanh toán
            String bookingStatus = booking.getStatus();
            if ("Đã thanh toán".equals(bookingStatus)) {
                logger.warning("Attempted to delete paid booking ID: " + bookingId);
                session.setAttribute("errorMessage", "Không thể xóa lịch hẹn đã thanh toán. Vui lòng liên hệ hỗ trợ nếu cần hủy.");
                response.sendRedirect(request.getContextPath() + "/spa-booking?action=history");
                return;
            }
            
            // Xóa booking khỏi database
            boolean success = spaBookingService.deleteSpaBooking(bookingId);
            
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
     * Submit review cho service từ trang service-detail
     */
    private void submitServiceReview(HttpServletRequest request, HttpServletResponse response, Customer customer) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        
        try {
            String serviceIdParam = request.getParameter("serviceId");
            String ratingParam = request.getParameter("rating");
            String comment = request.getParameter("comment");
            
            if (serviceIdParam == null || serviceIdParam.trim().isEmpty()) {
                session.setAttribute("errorMessage", "Không tìm thấy dịch vụ");
                response.sendRedirect(request.getContextPath() + "/spa-booking?action=services");
                return;
            }
            
            if (ratingParam == null || ratingParam.trim().isEmpty()) {
                session.setAttribute("errorMessage", "Vui lòng chọn đánh giá");
                response.sendRedirect(request.getContextPath() + "/spa-booking?action=service-detail&serviceId=" + serviceIdParam);
                return;
            }
            
            int serviceId = Integer.parseInt(serviceIdParam);
            int rating = Integer.parseInt(ratingParam);
            
            // Validate rating
            if (rating < 1 || rating > 5) {
                session.setAttribute("errorMessage", "Đánh giá phải từ 1 đến 5 sao");
                response.sendRedirect(request.getContextPath() + "/spa-booking?action=service-detail&serviceId=" + serviceId);
                return;
            }
            
            // Kiểm tra customer đã mua dịch vụ này chưa
            if (!reviewService.hasPurchasedService(customer.getCustomerId(), serviceId)) {
                session.setAttribute("errorMessage", "Bạn cần đặt và sử dụng dịch vụ này trước khi đánh giá");
                response.sendRedirect(request.getContextPath() + "/spa-booking?action=service-detail&serviceId=" + serviceId);
                return;
            }
            
            // Lấy booking_id từ Booking_Service mà customer đã sử dụng
            dao.ReviewDAO reviewDAO = new dao.ReviewDAO();
            Integer bookingId = reviewDAO.getBookingIdForService(customer.getCustomerId(), serviceId);
            
            if (bookingId == null) {
                session.setAttribute("errorMessage", "Không tìm thấy booking cho dịch vụ này");
                response.sendRedirect(request.getContextPath() + "/spa-booking?action=service-detail&serviceId=" + serviceId);
                return;
            }
            
            // Cho phép comment nhiều lần - không check duplicate
            // Tạo review object
            Review review = new Review();
            review.setCustomerId(customer.getCustomerId());
            review.setServiceId(serviceId);
            review.setBookingId(bookingId);
            review.setRating(rating);
            review.setComment(comment != null ? comment.trim() : "");
            
            // Lưu review
            reviewService.add(review);
            
            logger.info("Review submitted successfully: serviceId=" + serviceId + ", bookingId=" + bookingId + ", customerId=" + customer.getCustomerId());
            session.setAttribute("successMessage", "Cảm ơn bạn đã đánh giá dịch vụ!");
            
        } catch (NumberFormatException e) {
            logger.warning("Invalid number format in submitServiceReview: " + e.getMessage());
            session.setAttribute("errorMessage", "Dữ liệu không hợp lệ");
        } catch (Exception e) {
            logger.severe("Error submitting service review: " + e.getMessage());
            e.printStackTrace();
            session.setAttribute("errorMessage", "Có lỗi xảy ra khi gửi đánh giá: " + e.getMessage());
        }
        
        String serviceIdParam = request.getParameter("serviceId");
        if (serviceIdParam != null) {
            response.sendRedirect(request.getContextPath() + "/spa-booking?action=service-detail&serviceId=" + serviceIdParam);
        } else {
            response.sendRedirect(request.getContextPath() + "/spa-booking?action=services");
        }
    }
    
    /**
     * Sửa review cho service
     */
    private void editServiceReview(HttpServletRequest request, HttpServletResponse response, Customer customer) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        
        try {
            // Log tất cả parameters để debug
            logger.info("=== EDIT REVIEW REQUEST ===");
            logger.info("All parameters: " + java.util.Collections.list(request.getParameterNames()));
            java.util.Enumeration<String> paramNames = request.getParameterNames();
            while (paramNames.hasMoreElements()) {
                String paramName = paramNames.nextElement();
                logger.info("Parameter: " + paramName + " = " + request.getParameter(paramName));
            }
            
            // Set encoding để đọc đúng UTF-8
            request.setCharacterEncoding("UTF-8");
            
            String reviewIdParam = request.getParameter("reviewId");
            String serviceIdParam = request.getParameter("serviceId");
            String ratingParam = request.getParameter("rating");
            String comment = request.getParameter("comment");
            
            logger.info("reviewIdParam: " + reviewIdParam);
            logger.info("serviceIdParam: " + serviceIdParam);
            logger.info("ratingParam: " + ratingParam);
            logger.info("comment: " + comment);
            logger.info("comment length: " + (comment != null ? comment.length() : "null"));
            
            if (reviewIdParam == null || reviewIdParam.trim().isEmpty()) {
                logger.warning("reviewIdParam is null or empty");
                session.setAttribute("errorMessage", "Không tìm thấy review");
                if (serviceIdParam != null) {
                    response.sendRedirect(request.getContextPath() + "/spa-booking?action=service-detail&serviceId=" + serviceIdParam);
                } else {
                    response.sendRedirect(request.getContextPath() + "/spa-booking?action=services");
                }
                return;
            }
            
            if (ratingParam == null || ratingParam.trim().isEmpty()) {
                logger.warning("ratingParam is null or empty");
                session.setAttribute("errorMessage", "Vui lòng chọn đánh giá");
                if (serviceIdParam != null) {
                    response.sendRedirect(request.getContextPath() + "/spa-booking?action=service-detail&serviceId=" + serviceIdParam);
                } else {
                    response.sendRedirect(request.getContextPath() + "/spa-booking?action=services");
                }
                return;
            }
            
            int reviewId = Integer.parseInt(reviewIdParam);
            int rating = Integer.parseInt(ratingParam);
            
            logger.info("Parsed reviewId: " + reviewId + ", rating: " + rating);
            
            logger.info("Editing review: reviewId=" + reviewId + ", customerId=" + customer.getCustomerId() + ", rating=" + rating);
            
            // Validate rating
            if (rating < 1 || rating > 5) {
                session.setAttribute("errorMessage", "Đánh giá phải từ 1 đến 5 sao");
                if (serviceIdParam != null) {
                    response.sendRedirect(request.getContextPath() + "/spa-booking?action=service-detail&serviceId=" + serviceIdParam);
                } else {
                    response.sendRedirect(request.getContextPath() + "/spa-booking?action=services");
                }
                return;
            }
            
            // Kiểm tra review có tồn tại và thuộc về customer không
            logger.info("Getting review by ID: " + reviewId);
            Review review = reviewService.getReviewById(reviewId);
            logger.info("Review result: " + (review != null ? "Found, reviewId=" + review.getReviewId() + ", customerId=" + review.getCustomerId() : "null"));
            
            if (review == null) {
                logger.warning("Review not found for editing: reviewId=" + reviewId);
                session.setAttribute("errorMessage", "Không tìm thấy review (ID: " + reviewId + ")");
                if (serviceIdParam != null) {
                    response.sendRedirect(request.getContextPath() + "/spa-booking?action=service-detail&serviceId=" + serviceIdParam);
                } else {
                    response.sendRedirect(request.getContextPath() + "/spa-booking?action=services");
                }
                return;
            }
            
            if (review.getCustomerId() != customer.getCustomerId()) {
                logger.warning("Permission denied: review customerId=" + review.getCustomerId() + ", current customerId=" + customer.getCustomerId());
                session.setAttribute("errorMessage", "Bạn không có quyền sửa review này");
                if (serviceIdParam != null) {
                    response.sendRedirect(request.getContextPath() + "/spa-booking?action=service-detail&serviceId=" + serviceIdParam);
                } else {
                    response.sendRedirect(request.getContextPath() + "/spa-booking?action=services");
                }
                return;
            }
            
            // Cập nhật review
            review.setRating(rating);
            String finalComment = (comment != null && !comment.trim().isEmpty()) ? comment.trim() : "";
            review.setComment(finalComment);
            
            logger.info("Updating review: reviewId=" + review.getReviewId() + ", customerId=" + review.getCustomerId() + ", rating=" + review.getRating());
            logger.info("Comment length: " + finalComment.length() + ", comment preview: " + (finalComment.length() > 50 ? finalComment.substring(0, 50) + "..." : finalComment));
            
            boolean success = reviewService.update(review);
            
            if (success) {
                logger.info("Review updated successfully: reviewId=" + reviewId + ", customerId=" + customer.getCustomerId());
                session.setAttribute("successMessage", "Đã cập nhật đánh giá thành công!");
            } else {
                logger.warning("Failed to update review: reviewId=" + reviewId + ", customerId=" + customer.getCustomerId());
                session.setAttribute("errorMessage", "Cập nhật đánh giá thất bại. Vui lòng thử lại hoặc kiểm tra lại quyền truy cập.");
            }
            
        } catch (NumberFormatException e) {
            logger.warning("Invalid number format in editServiceReview: " + e.getMessage());
            session.setAttribute("errorMessage", "Dữ liệu không hợp lệ");
        } catch (Exception e) {
            logger.severe("Error editing service review: " + e.getMessage());
            e.printStackTrace();
            session.setAttribute("errorMessage", "Có lỗi xảy ra khi sửa đánh giá: " + e.getMessage());
        }
        
        String serviceIdParam = request.getParameter("serviceId");
        if (serviceIdParam != null) {
            response.sendRedirect(request.getContextPath() + "/spa-booking?action=service-detail&serviceId=" + serviceIdParam);
        } else {
            response.sendRedirect(request.getContextPath() + "/spa-booking?action=services");
        }
    }
    
    /**
     * Xóa review cho service
     */
    private void deleteServiceReview(HttpServletRequest request, HttpServletResponse response, Customer customer) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        
        try {
            String reviewIdParam = request.getParameter("reviewId");
            String serviceIdParam = request.getParameter("serviceId");
            
            if (reviewIdParam == null || reviewIdParam.trim().isEmpty()) {
                session.setAttribute("errorMessage", "Không tìm thấy review");
                if (serviceIdParam != null) {
                    response.sendRedirect(request.getContextPath() + "/spa-booking?action=service-detail&serviceId=" + serviceIdParam);
                } else {
                    response.sendRedirect(request.getContextPath() + "/spa-booking?action=services");
                }
                return;
            }
            
            int reviewId = Integer.parseInt(reviewIdParam);
            
            logger.info("Deleting review: reviewId=" + reviewId + ", customerId=" + customer.getCustomerId());
            
            // Kiểm tra review có tồn tại và thuộc về customer không
            Review review = reviewService.getReviewById(reviewId);
            logger.info("Review result: " + (review != null ? "Found, reviewId=" + review.getReviewId() + ", customerId=" + review.getCustomerId() : "null"));
            
            if (review == null) {
                logger.warning("Review not found for deletion: reviewId=" + reviewId);
                session.setAttribute("errorMessage", "Không tìm thấy review (ID: " + reviewId + ")");
                if (serviceIdParam != null) {
                    response.sendRedirect(request.getContextPath() + "/spa-booking?action=service-detail&serviceId=" + serviceIdParam);
                } else {
                    response.sendRedirect(request.getContextPath() + "/spa-booking?action=services");
                }
                return;
            }
            
            if (review.getCustomerId() != customer.getCustomerId()) {
                logger.warning("Permission denied: review customerId=" + review.getCustomerId() + ", current customerId=" + customer.getCustomerId());
                session.setAttribute("errorMessage", "Bạn không có quyền xóa review này");
                if (serviceIdParam != null) {
                    response.sendRedirect(request.getContextPath() + "/spa-booking?action=service-detail&serviceId=" + serviceIdParam);
                } else {
                    response.sendRedirect(request.getContextPath() + "/spa-booking?action=services");
                }
                return;
            }
            
            // Xóa review
            boolean success = reviewService.delete(reviewId);
            
            if (success) {
                logger.info("Review deleted successfully: reviewId=" + reviewId + ", customerId=" + customer.getCustomerId());
                session.setAttribute("successMessage", "Đã xóa đánh giá thành công!");
            } else {
                logger.warning("Failed to delete review: reviewId=" + reviewId);
                session.setAttribute("errorMessage", "Xóa đánh giá thất bại. Vui lòng thử lại.");
            }
            
        } catch (NumberFormatException e) {
            logger.warning("Invalid number format in deleteServiceReview: " + e.getMessage());
            session.setAttribute("errorMessage", "Dữ liệu không hợp lệ");
        } catch (Exception e) {
            logger.severe("Error deleting service review: " + e.getMessage());
            e.printStackTrace();
            session.setAttribute("errorMessage", "Có lỗi xảy ra khi xóa đánh giá: " + e.getMessage());
        }
        
        String serviceIdParam = request.getParameter("serviceId");
        if (serviceIdParam != null) {
            response.sendRedirect(request.getContextPath() + "/spa-booking?action=service-detail&serviceId=" + serviceIdParam);
        } else {
            response.sendRedirect(request.getContextPath() + "/spa-booking?action=services");
        }
    }
    
    /**
     * Cập nhật status của booking
     */
    private void updateBookingStatus(HttpServletRequest request, HttpServletResponse response, Customer customer) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        
        try {
            String bookingIdParam = request.getParameter("bookingId");
            String newStatus = request.getParameter("status");
            
            if (bookingIdParam == null || bookingIdParam.trim().isEmpty()) {
                session.setAttribute("errorMessage", "Không tìm thấy booking");
                response.sendRedirect(request.getContextPath() + "/spa-booking?action=history");
                return;
            }
            
            if (newStatus == null || newStatus.trim().isEmpty()) {
                session.setAttribute("errorMessage", "Status không được để trống");
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
                session.setAttribute("errorMessage", "Không tìm thấy booking hoặc bạn không có quyền sửa");
                response.sendRedirect(request.getContextPath() + "/spa-booking?action=history");
                return;
            }
            
            // Cập nhật status
            boolean success = spaBookingService.updateBookingStatus(bookingId, newStatus);
            
            if (success) {
                logger.info("Updated booking " + bookingId + " status to " + newStatus);
                session.setAttribute("successMessage", "Đã cập nhật trạng thái booking thành công");
            } else {
                logger.warning("Failed to update booking " + bookingId + " status to " + newStatus);
                session.setAttribute("errorMessage", "Cập nhật trạng thái thất bại. Vui lòng thử lại.");
            }
            
        } catch (NumberFormatException e) {
            session.setAttribute("errorMessage", "ID booking không hợp lệ");
        } catch (Exception e) {
            logger.severe("Error updating booking status: " + e.getMessage());
            e.printStackTrace();
            session.setAttribute("errorMessage", "Có lỗi xảy ra khi cập nhật: " + e.getMessage());
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
            
            // Lấy thông tin thú cưng liên quan đến booking này
            // Nếu booking là chung phòng: petInfo có thể chứa nhiều tên pet (ví dụ: "Buddy, Max, Luna")
            // Nếu booking là khác phòng: petInfo chỉ chứa 1 tên pet (ví dụ: "Buddy")
            List<Pet> bookingPets = new ArrayList<>();
            if (booking.getPetInfo() != null && !booking.getPetInfo().trim().isEmpty()) {
                // Parse petInfo để lấy danh sách tên pet
                String petInfo = booking.getPetInfo().trim();
                String[] petNames = petInfo.split(",");
                
                // Lấy tất cả pets của customer
                List<Pet> allCustomerPets = petDAO.getPetsByCustomerId(customer.getCustomerId());
                
                // Chỉ lấy các pets có tên khớp với petInfo trong booking
                for (String petName : petNames) {
                    petName = petName.trim();
                    for (Pet pet : allCustomerPets) {
                        if (pet.getPetName() != null && pet.getPetName().trim().equals(petName)) {
                            bookingPets.add(pet);
                            break; // Đã tìm thấy, không cần tìm tiếp
                        }
                    }
                }
            }
            
            request.setAttribute("boardingBooking", booking);
            request.setAttribute("customerPets", bookingPets); // Chỉ pets trong booking này
            
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

    private void refundSpaBooking(HttpServletRequest request, HttpServletResponse response, Customer customer)
            throws ServletException, IOException {
        try {
            String bookingIdStr = request.getParameter("bookingId");
            String amountStr = request.getParameter("amount");
            String reason = request.getParameter("reason");
            if (reason == null || reason.trim().isEmpty()) reason = "Hoàn tiền spa";
            
            if (bookingIdStr == null || bookingIdStr.trim().isEmpty() || amountStr == null || amountStr.trim().isEmpty()) {
                request.getSession().setAttribute("errorMessage", "Thiếu bookingId hoặc amount");
                response.sendRedirect(request.getContextPath() + "/spa-booking?action=history");
                return;
            }
            int bookingId = Integer.parseInt(bookingIdStr);
            double amount = Double.parseDouble(amountStr);
            if (amount <= 0) {
                request.getSession().setAttribute("errorMessage", "Số tiền không hợp lệ");
                response.sendRedirect(request.getContextPath() + "/spa-booking?action=history");
                return;
            }
            
            try (java.sql.Connection conn = utils.DBConnection.getConnection()) {
                // Ghi log Refunds với order_id = SPA_<bookingId>
                String insertRefund = "INSERT INTO dbo.Refunds (order_id, amount, payos_payout_id, reason, created_at) VALUES (?, ?, ?, ?, GETDATE())";
                try (java.sql.PreparedStatement ps = conn.prepareStatement(insertRefund)) {
                    ps.setString(1, "SPA_" + bookingId);
                    ps.setDouble(2, amount);
                    ps.setString(3, null);
                    ps.setString(4, reason);
                    ps.executeUpdate();
                }
                // Cập nhật trạng thái booking
                String updateBooking = "UPDATE dbo.Booking SET note = COALESCE(CAST(note AS NVARCHAR(255)),'') + CASE WHEN LEN(COALESCE(CAST(note AS NVARCHAR(255)),''))>0 THEN N' | refunded' ELSE N'refunded' END, updated_at = GETDATE() WHERE booking_id = ?";
                try (java.sql.PreparedStatement ps2 = conn.prepareStatement(updateBooking)) {
                    ps2.setInt(1, bookingId);
                    ps2.executeUpdate();
                }
            }
            request.getSession().setAttribute("successMessage", "Hoàn tiền thành công cho booking #" + bookingId);
        } catch (Exception ex) {
            request.getSession().setAttribute("errorMessage", "Lỗi hoàn tiền: " + ex.getMessage());
        }
        response.sendRedirect(request.getContextPath() + "/spa-booking?action=history");
    }

    /**
     * Lấy danh sách bookings đã hoàn thành để review
     */
    private void getCompletedBookingsForReview(HttpServletRequest request, HttpServletResponse response, Customer customer) 
            throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        try {
            List<Booking> allBookings = spaBookingService.getSpaBookingsByCustomerId(customer.getCustomerId());
            List<Map<String, Object>> completedBookings = new ArrayList<>();
            
            dao.BookingServiceDAO bookingServiceDAO = new dao.BookingServiceDAO();
            
            for (Booking booking : allBookings) {
                String status = booking.getStatus();
                // Cho phép review cả "Đã thanh toán", "Chờ xác nhận" và "Đã xác nhận" (cùng cấp độ)
                if (status != null && 
                    (status.equalsIgnoreCase("completed") || status.equalsIgnoreCase("hoàn thành") ||
                     status.equals("Đã thanh toán") || status.equals("Chờ xác nhận") || 
                     status.equals("Đã xác nhận"))) {
                    List<BookingServiceItem> services = bookingServiceDAO.getBookingServicesByBookingId(booking.getBookingId());
                    for (BookingServiceItem service : services) {
                        if (service.isSpaService()) {
                            Map<String, Object> bookingInfo = new HashMap<>();
                            bookingInfo.put("bookingId", booking.getBookingId());
                            bookingInfo.put("serviceId", service.getServiceId());
                            bookingInfo.put("serviceName", service.getServiceName() != null ? service.getServiceName() : "Dịch vụ Spa");
                            
                            if (booking.getAppointmentStart() != null) {
                                SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
                                bookingInfo.put("bookingDate", sdf.format(new java.util.Date(booking.getAppointmentStart().getTime())));
                            } else {
                                bookingInfo.put("bookingDate", "");
                            }
                            
                            completedBookings.add(bookingInfo);
                        }
                    }
                }
            }
            
            Map<String, Object> result = new HashMap<>();
            result.put("bookings", completedBookings);
            
            response.getWriter().write(new com.google.gson.Gson().toJson(result));
        } catch (Exception e) {
            logger.severe("Error getting completed bookings: " + e.getMessage());
            e.printStackTrace();
            Map<String, Object> error = new HashMap<>();
            error.put("error", "Lỗi khi tải danh sách bookings");
            response.getWriter().write(new com.google.gson.Gson().toJson(error));
        }
    }

    /**
     * Kiểm tra xem đã review chưa
     */
    private void checkReviewExists(HttpServletRequest request, HttpServletResponse response, Customer customer) 
            throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        try {
            int bookingId = Integer.parseInt(request.getParameter("bookingId"));
            int serviceId = Integer.parseInt(request.getParameter("serviceId"));
            
            Review existingReview = reviewService.getReviewByBooking(bookingId, serviceId, customer.getCustomerId());
            
            Map<String, Object> result = new HashMap<>();
            result.put("exists", existingReview != null);
            
            response.getWriter().write(new com.google.gson.Gson().toJson(result));
        } catch (Exception e) {
            logger.severe("Error checking review exists: " + e.getMessage());
            e.printStackTrace();
            Map<String, Object> error = new HashMap<>();
            error.put("error", "Lỗi khi kiểm tra");
            response.getWriter().write(new com.google.gson.Gson().toJson(error));
        }
    }

    /**
     * Lấy reviews của một service
     */
    private void getServiceReviews(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        try {
            int serviceId = Integer.parseInt(request.getParameter("serviceId"));
            int limit = 10;
            if (request.getParameter("limit") != null) {
                limit = Integer.parseInt(request.getParameter("limit"));
            }
            
            List<Review> reviews = reviewService.listByService(serviceId, limit);
            
            List<Map<String, Object>> reviewList = new ArrayList<>();
            for (Review review : reviews) {
                Map<String, Object> reviewMap = new HashMap<>();
                reviewMap.put("reviewId", review.getReviewId());
                reviewMap.put("rating", review.getRating());
                reviewMap.put("comment", review.getComment());
                reviewMap.put("customerName", review.getCustomerName());
                if (review.getCreatedAt() != null) {
                    reviewMap.put("createdAt", review.getCreatedAt().getTime());
                }
                reviewList.add(reviewMap);
            }
            
            Map<String, Object> result = new HashMap<>();
            result.put("reviews", reviewList);
            
            response.getWriter().write(new com.google.gson.Gson().toJson(result));
        } catch (Exception e) {
            logger.severe("Error getting service reviews: " + e.getMessage());
            e.printStackTrace();
            Map<String, Object> error = new HashMap<>();
            error.put("error", "Lỗi khi tải đánh giá");
            response.getWriter().write(new com.google.gson.Gson().toJson(error));
        }
    }

    /**
     * Submit review cho service
     */
    private void submitReview(HttpServletRequest request, HttpServletResponse response, Customer customer) 
            throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        try {
            int bookingId = Integer.parseInt(request.getParameter("bookingId"));
            int serviceId = Integer.parseInt(request.getParameter("serviceId"));
            int rating = Integer.parseInt(request.getParameter("rating"));
            String comment = request.getParameter("comment");
            
            // Validate rating
            if (rating < 1 || rating > 5) {
                Map<String, Object> error = new HashMap<>();
                error.put("success", false);
                error.put("message", "Đánh giá phải từ 1 đến 5 sao");
                response.getWriter().write(new com.google.gson.Gson().toJson(error));
                return;
            }
            
            // Check if booking is completed or paid/confirmed (cùng cấp độ)
            if (!reviewService.hasCompletedBooking(customer.getCustomerId(), serviceId, bookingId)) {
                Map<String, Object> error = new HashMap<>();
                error.put("success", false);
                error.put("message", "Bạn chỉ có thể đánh giá các dịch vụ đã thanh toán hoặc đã xác nhận");
                response.getWriter().write(new com.google.gson.Gson().toJson(error));
                return;
            }
            
            // Check if already reviewed
            Review existingReview = reviewService.getReviewByBooking(bookingId, serviceId, customer.getCustomerId());
            if (existingReview != null) {
                Map<String, Object> error = new HashMap<>();
                error.put("success", false);
                error.put("message", "Bạn đã đánh giá dịch vụ này rồi");
                response.getWriter().write(new com.google.gson.Gson().toJson(error));
                return;
            }
            
            // Create and save review
            Review review = new Review();
            review.setCustomerId(customer.getCustomerId());
            review.setServiceId(serviceId);
            review.setBookingId(bookingId);
            review.setRating(rating);
            review.setComment(comment != null ? comment.trim() : "");
            
            reviewService.add(review);
            
            Map<String, Object> result = new HashMap<>();
            result.put("success", true);
            result.put("message", "Đánh giá đã được gửi thành công");
            
            response.getWriter().write(new com.google.gson.Gson().toJson(result));
        } catch (Exception e) {
            logger.severe("Error submitting review: " + e.getMessage());
            e.printStackTrace();
            Map<String, Object> error = new HashMap<>();
            error.put("success", false);
            error.put("message", "Lỗi khi gửi đánh giá: " + e.getMessage());
            response.getWriter().write(new com.google.gson.Gson().toJson(error));
        }
    }

    /**
     * Lấy danh sách time slots với trạng thái available/occupied cho một ngày và service
     */
    private void getTimeSlots(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        try {
            String dateStr = request.getParameter("date");
            String serviceIdStr = request.getParameter("serviceId");
            String quantityStr = request.getParameter("quantity");
            
            if (dateStr == null || serviceIdStr == null) {
                Map<String, Object> error = new HashMap<>();
                error.put("error", "Thiếu tham số date hoặc serviceId");
                response.getWriter().write(new com.google.gson.Gson().toJson(error));
                return;
            }
            
            int serviceId = Integer.parseInt(serviceIdStr);
            int quantity = quantityStr != null ? Integer.parseInt(quantityStr) : 1;
            
            // Lấy thông tin service để biết duration
            PetServiceModel service = spaBookingService.getSpaServiceById(serviceId);
            if (service == null) {
                Map<String, Object> error = new HashMap<>();
                error.put("error", "Không tìm thấy dịch vụ");
                response.getWriter().write(new com.google.gson.Gson().toJson(error));
                return;
            }
            
            int duration = service.getDuration() * quantity; // Tổng thời gian = duration * quantity
            SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
            java.util.Date selectedDate = dateFormat.parse(dateStr);
            
            List<Map<String, Object>> slots = new ArrayList<>();
            
            // Đã xóa tất cả validation - tạo slots cho cả ngày (00:00 - 23:59)
            // Mỗi slot bắt đầu và kéo dài trong duration phút
            
            java.util.Calendar cal = java.util.Calendar.getInstance();
            cal.setTime(selectedDate);
            cal.set(java.util.Calendar.HOUR_OF_DAY, 0);
            cal.set(java.util.Calendar.MINUTE, 0);
            cal.set(java.util.Calendar.SECOND, 0);
            cal.set(java.util.Calendar.MILLISECOND, 0);
            
            // Tạo slots cho cả ngày (0h-23h)
            int originalDay = cal.get(java.util.Calendar.DAY_OF_MONTH);
            int originalMonth = cal.get(java.util.Calendar.MONTH);
            int originalYear = cal.get(java.util.Calendar.YEAR);
            
            while (true) {
                int currentHour = cal.get(java.util.Calendar.HOUR_OF_DAY);
                int currentMinute = cal.get(java.util.Calendar.MINUTE);
                
                // Kiểm tra nếu đã sang ngày hôm sau thì dừng
                if (cal.get(java.util.Calendar.DAY_OF_MONTH) != originalDay || 
                    cal.get(java.util.Calendar.MONTH) != originalMonth ||
                    cal.get(java.util.Calendar.YEAR) != originalYear) {
                    break;
                }
                
                Timestamp slotStart = new Timestamp(cal.getTimeInMillis());
                
                // Tính end time
                java.util.Calendar calEnd = (java.util.Calendar) cal.clone();
                calEnd.add(java.util.Calendar.MINUTE, duration);
                
                int endHour = calEnd.get(java.util.Calendar.HOUR_OF_DAY);
                int endMinute = calEnd.get(java.util.Calendar.MINUTE);
                
                Timestamp slotEnd = new Timestamp(calEnd.getTimeInMillis());
                
                // Đã xóa kiểm tra trùng lịch - tất cả slots luôn available (cho phép nhiều khách đặt cùng giờ)
                boolean isAvailable = true;
                
                Map<String, Object> slot = new HashMap<>();
                slot.put("start", String.format("%02d:%02d", currentHour, currentMinute));
                slot.put("end", String.format("%02d:%02d", endHour, endMinute));
                slot.put("startTimestamp", slotStart.getTime());
                slot.put("endTimestamp", slotEnd.getTime());
                slot.put("available", isAvailable);
                slot.put("duration", duration);
                
                slots.add(slot);
                
                // Chuyển sang slot tiếp theo: cộng thêm duration phút
                cal.add(java.util.Calendar.MINUTE, duration);
            }
            
            Map<String, Object> result = new HashMap<>();
            result.put("date", dateStr);
            result.put("serviceId", serviceId);
            result.put("serviceDuration", service.getDuration());
            result.put("quantity", quantity);
            result.put("totalDuration", duration);
            result.put("slots", slots);
            
            response.getWriter().write(new com.google.gson.Gson().toJson(result));
            
        } catch (Exception e) {
            logger.severe("Error getting time slots: " + e.getMessage());
            e.printStackTrace();
            Map<String, Object> error = new HashMap<>();
            error.put("error", "Lỗi khi lấy danh sách time slots: " + e.getMessage());
            response.getWriter().write(new com.google.gson.Gson().toJson(error));
        }
    }

    /**
     * Lấy danh sách reviews cho boarding booking
     */
    private void getBoardingReviews(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        try {
            String bookingIdStr = request.getParameter("bookingId");
            if (bookingIdStr == null) {
                Map<String, Object> error = new HashMap<>();
                error.put("error", "Thiếu bookingId");
                response.getWriter().write(new com.google.gson.Gson().toJson(error));
                return;
            }
            
            int bookingId = Integer.parseInt(bookingIdStr);
            
            // Boarding reviews: dùng service_id = 9999 (đặc biệt cho boarding)
            // Query trực tiếp từ Review table với booking_id và service_id = 9999
            String sql = "SELECT r.*, c.name AS customer_name FROM Review r " +
                         "JOIN Customer c ON r.customer_id = c.customer_id " +
                         "WHERE r.booking_id = ? AND r.service_id = 9999 " +
                         "ORDER BY r.created_at DESC";
            
            List<Review> reviews = new ArrayList<>();
            try (java.sql.Connection conn = utils.DBConnection.getConnection();
                 java.sql.PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, bookingId);
                try (java.sql.ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Review review = new Review();
                        review.setReviewId(rs.getInt("review_id"));
                        review.setCustomerId(rs.getInt("customer_id"));
                        review.setServiceId(rs.getInt("service_id"));
                        review.setBookingId(rs.getInt("booking_id"));
                        review.setRating(rs.getInt("rating"));
                        review.setComment(rs.getString("comment"));
                        review.setCreatedAt(rs.getTimestamp("created_at"));
                        review.setCustomerName(rs.getString("customer_name"));
                        reviews.add(review);
                    }
                }
            }
            
            response.getWriter().write(new com.google.gson.Gson().toJson(reviews));
            
        } catch (Exception e) {
            logger.severe("Error getting boarding reviews: " + e.getMessage());
            e.printStackTrace();
            Map<String, Object> error = new HashMap<>();
            error.put("error", "Lỗi khi lấy đánh giá: " + e.getMessage());
            response.getWriter().write(new com.google.gson.Gson().toJson(error));
        }
    }

    /**
     * Gửi review cho boarding booking
     */
    private void submitBoardingReview(HttpServletRequest request, HttpServletResponse response, Customer customer)
            throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        try {
            String bookingIdStr = request.getParameter("bookingId");
            String ratingStr = request.getParameter("rating");
            String comment = request.getParameter("comment");
            
            if (bookingIdStr == null || ratingStr == null) {
                Map<String, Object> error = new HashMap<>();
                error.put("success", false);
                error.put("message", "Thiếu thông tin bookingId hoặc rating");
                response.getWriter().write(new com.google.gson.Gson().toJson(error));
                return;
            }
            
            int bookingId = Integer.parseInt(bookingIdStr);
            int rating = Integer.parseInt(ratingStr);
            
            if (rating < 1 || rating > 5) {
                Map<String, Object> error = new HashMap<>();
                error.put("success", false);
                error.put("message", "Rating phải từ 1 đến 5 sao");
                response.getWriter().write(new com.google.gson.Gson().toJson(error));
                return;
            }
            
            if (comment == null || comment.trim().isEmpty()) {
                Map<String, Object> error = new HashMap<>();
                error.put("success", false);
                error.put("message", "Vui lòng nhập đánh giá");
                response.getWriter().write(new com.google.gson.Gson().toJson(error));
                return;
            }
            
            if (comment.length() > 1000) {
                Map<String, Object> error = new HashMap<>();
                error.put("success", false);
                error.put("message", "Đánh giá không được vượt quá 1000 ký tự");
                response.getWriter().write(new com.google.gson.Gson().toJson(error));
                return;
            }
            
            // Kiểm tra xem booking có thuộc customer và đã hoàn thành chưa
            BoardingBooking booking = boardingBookingDAO.getBoardingBookingById(bookingId);
            if (booking == null || booking.getCustomerId() != customer.getCustomerId()) {
                Map<String, Object> error = new HashMap<>();
                error.put("success", false);
                error.put("message", "Không tìm thấy đơn lưu trú hoặc bạn không có quyền đánh giá");
                response.getWriter().write(new com.google.gson.Gson().toJson(error));
                return;
            }
            
            String status = booking.getStatus();
            if (status == null || (!status.contains("Hoàn thành") && !status.contains("completed") 
                && !status.contains("Đã thanh toán") && !status.contains("Đã xác nhận"))) {
                Map<String, Object> error = new HashMap<>();
                error.put("success", false);
                error.put("message", "Chỉ có thể đánh giá các đơn đã hoàn thành, đã thanh toán hoặc đã xác nhận");
                response.getWriter().write(new com.google.gson.Gson().toJson(error));
                return;
            }
            
            // Kiểm tra xem đã review chưa
            String checkSql = "SELECT COUNT(*) FROM Review WHERE booking_id = ? AND service_id = 9999 AND customer_id = ?";
            boolean alreadyReviewed = false;
            try (java.sql.Connection conn = utils.DBConnection.getConnection();
                 java.sql.PreparedStatement ps = conn.prepareStatement(checkSql)) {
                ps.setInt(1, bookingId);
                ps.setInt(2, customer.getCustomerId());
                try (java.sql.ResultSet rs = ps.executeQuery()) {
                    if (rs.next() && rs.getInt(1) > 0) {
                        alreadyReviewed = true;
                    }
                }
            }
            
            if (alreadyReviewed) {
                Map<String, Object> error = new HashMap<>();
                error.put("success", false);
                error.put("message", "Bạn đã đánh giá đơn lưu trú này rồi");
                response.getWriter().write(new com.google.gson.Gson().toJson(error));
                return;
            }
            
            // Tạo review với service_id = 9999 cho boarding
            Review review = new Review();
            review.setCustomerId(customer.getCustomerId());
            review.setServiceId(9999); // Service ID đặc biệt cho boarding
            review.setBookingId(bookingId);
            review.setRating(rating);
            review.setComment(comment.trim());
            review.setCreatedAt(new Timestamp(System.currentTimeMillis()));
            
            reviewService.add(review);
            
            Map<String, Object> result = new HashMap<>();
            result.put("success", true);
            result.put("message", "Đánh giá thành công");
            response.getWriter().write(new com.google.gson.Gson().toJson(result));
            
        } catch (Exception e) {
            logger.severe("Error submitting boarding review: " + e.getMessage());
            e.printStackTrace();
            Map<String, Object> error = new HashMap<>();
            error.put("success", false);
            error.put("message", "Lỗi khi gửi đánh giá: " + e.getMessage());
            response.getWriter().write(new com.google.gson.Gson().toJson(error));
        }
    }
    
    /**
     * Staff xác nhận boarding booking: Chờ xác nhận → Chưa nhận thú cưng
     */
    private void confirmBoardingBooking(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        
        // Kiểm tra staff authentication
        model.Staff staff = (model.Staff) session.getAttribute("staff");
        if (staff == null) {
            session.setAttribute("errorMessage", "Chỉ nhân viên mới có thể thực hiện thao tác này");
            response.sendRedirect(request.getContextPath() + "/spa-booking?action=history");
            return;
        }
        
        try {
            String bookingIdParam = request.getParameter("bookingId");
            if (bookingIdParam == null || bookingIdParam.trim().isEmpty()) {
                session.setAttribute("errorMessage", "ID booking không hợp lệ");
                response.sendRedirect(request.getContextPath() + "/spa-booking?action=history");
                return;
            }
            
            int bookingId = Integer.parseInt(bookingIdParam);
            BoardingBooking booking = boardingBookingDAO.getBoardingBookingById(bookingId);
            
            if (booking == null) {
                session.setAttribute("errorMessage", "Không tìm thấy booking");
                response.sendRedirect(request.getContextPath() + "/spa-booking?action=history");
                return;
            }
            
            // Chỉ có thể xác nhận nếu status là "Chờ xác nhận"
            if (!"Chờ xác nhận".equals(booking.getStatus()) && !"pending".equals(booking.getStatus())) {
                session.setAttribute("errorMessage", "Chỉ có thể xác nhận booking ở trạng thái 'Chờ xác nhận'");
                response.sendRedirect(request.getContextPath() + "/spa-booking?action=history");
                return;
            }
            
            // Cập nhật status: Chờ xác nhận → Chưa nhận thú cưng
            boolean success = boardingBookingDAO.updateBookingStatus(bookingId, "Chưa nhận thú cưng");
            
            if (success) {
                logger.info("Staff " + staff.getStaffId() + " confirmed boarding booking ID: " + bookingId);
                session.setAttribute("successMessage", "Đã xác nhận booking thành công. Khách hàng có thể gửi thú cưng.");
            } else {
                logger.warning("Failed to confirm boarding booking ID: " + bookingId);
                session.setAttribute("errorMessage", "Xác nhận booking thất bại. Vui lòng thử lại.");
            }
            
        } catch (NumberFormatException e) {
            session.setAttribute("errorMessage", "ID booking không hợp lệ");
        } catch (Exception e) {
            logger.severe("Error confirming boarding booking: " + e.getMessage());
            e.printStackTrace();
            session.setAttribute("errorMessage", "Có lỗi xảy ra khi xác nhận booking: " + e.getMessage());
        }
        
        response.sendRedirect(request.getContextPath() + "/spa-booking?action=history");
    }
    
    /**
     * Staff nhận thú cưng: Chưa nhận thú cưng → Đang ở
     */
    private void checkInPet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        
        // Kiểm tra staff authentication
        model.Staff staff = (model.Staff) session.getAttribute("staff");
        if (staff == null) {
            session.setAttribute("errorMessage", "Chỉ nhân viên mới có thể thực hiện thao tác này");
            response.sendRedirect(request.getContextPath() + "/spa-booking?action=history");
            return;
        }
        
        try {
            String bookingIdParam = request.getParameter("bookingId");
            if (bookingIdParam == null || bookingIdParam.trim().isEmpty()) {
                session.setAttribute("errorMessage", "ID booking không hợp lệ");
                response.sendRedirect(request.getContextPath() + "/spa-booking?action=history");
                return;
            }
            
            int bookingId = Integer.parseInt(bookingIdParam);
            BoardingBooking booking = boardingBookingDAO.getBoardingBookingById(bookingId);
            
            if (booking == null) {
                session.setAttribute("errorMessage", "Không tìm thấy booking");
                response.sendRedirect(request.getContextPath() + "/spa-booking?action=history");
                return;
            }
            
            // Chỉ có thể nhận thú cưng nếu status là "Chưa nhận thú cưng"
            if (!"Chưa nhận thú cưng".equals(booking.getStatus())) {
                session.setAttribute("errorMessage", "Chỉ có thể nhận thú cưng khi booking ở trạng thái 'Chưa nhận thú cưng'");
                response.sendRedirect(request.getContextPath() + "/spa-booking?action=history");
                return;
            }
            
            // Cập nhật status: Chưa nhận thú cưng → Đang ở
            boolean success = boardingBookingDAO.updateBookingStatus(bookingId, "Đang ở");
            
            if (success) {
                logger.info("Staff " + staff.getStaffId() + " checked in pet for booking ID: " + bookingId);
                session.setAttribute("successMessage", "Đã nhận thú cưng thành công. Thú cưng đang ở trong phòng.");
            } else {
                logger.warning("Failed to check in pet for booking ID: " + bookingId);
                session.setAttribute("errorMessage", "Nhận thú cưng thất bại. Vui lòng thử lại.");
            }
            
        } catch (NumberFormatException e) {
            session.setAttribute("errorMessage", "ID booking không hợp lệ");
        } catch (Exception e) {
            logger.severe("Error checking in pet: " + e.getMessage());
            e.printStackTrace();
            session.setAttribute("errorMessage", "Có lỗi xảy ra khi nhận thú cưng: " + e.getMessage());
        }
        
        response.sendRedirect(request.getContextPath() + "/spa-booking?action=history");
    }
    
    /**
     * Staff trả thú cưng: Đang ở → Đã nhận về
     */
    private void checkOutPet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        
        // Kiểm tra staff authentication
        model.Staff staff = (model.Staff) session.getAttribute("staff");
        if (staff == null) {
            session.setAttribute("errorMessage", "Chỉ nhân viên mới có thể thực hiện thao tác này");
            response.sendRedirect(request.getContextPath() + "/spa-booking?action=history");
            return;
        }
        
        try {
            String bookingIdParam = request.getParameter("bookingId");
            if (bookingIdParam == null || bookingIdParam.trim().isEmpty()) {
                session.setAttribute("errorMessage", "ID booking không hợp lệ");
                response.sendRedirect(request.getContextPath() + "/spa-booking?action=history");
                return;
            }
            
            int bookingId = Integer.parseInt(bookingIdParam);
            BoardingBooking booking = boardingBookingDAO.getBoardingBookingById(bookingId);
            
            if (booking == null) {
                session.setAttribute("errorMessage", "Không tìm thấy booking");
                response.sendRedirect(request.getContextPath() + "/spa-booking?action=history");
                return;
            }
            
            // Chỉ có thể trả thú cưng nếu status là "Đang ở"
            if (!"Đang ở".equals(booking.getStatus()) && !"Đang thuê".equals(booking.getStatus())) {
                session.setAttribute("errorMessage", "Chỉ có thể trả thú cưng khi booking ở trạng thái 'Đang ở'");
                response.sendRedirect(request.getContextPath() + "/spa-booking?action=history");
                return;
            }
            
            // Cập nhật status: Đang ở → Đã nhận về
            boolean success = boardingBookingDAO.updateBookingStatus(bookingId, "Đã nhận về");
            
            if (success) {
                logger.info("Staff " + staff.getStaffId() + " checked out pet for booking ID: " + bookingId);
                session.setAttribute("successMessage", "Đã trả thú cưng thành công. Booking đã hoàn thành và tính tiền.");
            } else {
                logger.warning("Failed to check out pet for booking ID: " + bookingId);
                session.setAttribute("errorMessage", "Trả thú cưng thất bại. Vui lòng thử lại.");
            }
            
        } catch (NumberFormatException e) {
            session.setAttribute("errorMessage", "ID booking không hợp lệ");
        } catch (Exception e) {
            logger.severe("Error checking out pet: " + e.getMessage());
            e.printStackTrace();
            session.setAttribute("errorMessage", "Có lỗi xảy ra khi trả thú cưng: " + e.getMessage());
        }
        
        response.sendRedirect(request.getContextPath() + "/spa-booking?action=history");
    }
}
