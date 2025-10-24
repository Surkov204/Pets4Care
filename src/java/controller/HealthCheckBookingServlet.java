package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import service.HealthCheckBookingService;
import model.Customer;
import model.Booking;
import model.BookingServiceItem;
import model.CartItem;
import model.Product;

import java.io.IOException;
import java.sql.Timestamp;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.List;
import java.util.Map;
import java.util.HashMap;
import java.util.logging.Logger;
import model.PetServiceModel;

/**
 * Controller cho Health Check Booking
 * Tích hợp với trang đặt lịch khám hiện có
 * @author ASUS
 */
@WebServlet("/health-check-booking")
public class HealthCheckBookingServlet extends HttpServlet {
    
    private static final Logger logger = Logger.getLogger(HealthCheckBookingServlet.class.getName());
    
    private HealthCheckBookingService healthCheckBookingService;
    
    @Override
    public void init() throws ServletException {
        super.init();
        this.healthCheckBookingService = new HealthCheckBookingService();
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
            
            // Default action: show health check services with pet info
            if (action == null || action.isEmpty() || action.equals("services")) {
                // Hiển thị danh sách dịch vụ khám sức khỏe
                showHealthCheckServices(request, response, customer);
            } else if (action.equals("history")) {
                // Hiển thị lịch sử khám sức khỏe
                showHealthCheckHistory(request, response, customer);
            } else if (action.equals("detail")) {
                // Hiển thị chi tiết booking khám sức khỏe
                showHealthCheckBookingDetail(request, response, customer);
            } else if (action.equals("pet-history")) {
                // Hiển thị lịch sử khám sức khỏe của pet
                showPetHealthCheckHistory(request, response, customer);
            }
            
        } catch (Exception e) {
            logger.severe("Error in HealthCheckBookingServlet doGet: " + e.getMessage());
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
            
            if (action != null && action.equals("create-booking")) {
                // Tạo booking khám sức khỏe
                createHealthCheckBooking(request, response, customer);
            } else if (action != null && action.equals("cancel")) {
                // Hủy booking khám sức khỏe
                cancelHealthCheckBooking(request, response, customer);
            } else if (action != null && action.equals("add-to-cart")) {
                // Thêm dịch vụ vào giỏ khám
                addHealthCheckServiceToCart(request, response, customer);
            }
            
        } catch (Exception e) {
            logger.severe("Error in HealthCheckBookingServlet doPost: " + e.getMessage());
            e.printStackTrace();
            // Redirect về servlet để luôn nạp pet/services/bookings, tránh trang trống
            session.setAttribute("errorMessage", "Có lỗi xảy ra khi đặt lịch. Vui lòng thử lại.");
            response.sendRedirect(request.getContextPath() + "/health-check-booking");
        }
    }
    
    /**
     * Hiển thị danh sách dịch vụ khám sức khỏe
     */
    private void showHealthCheckServices(HttpServletRequest request, HttpServletResponse response, Customer customer) 
            throws ServletException, IOException {
        
        List<PetServiceModel> healthCheckServices = healthCheckBookingService.getActiveHealthCheckServices();
        List<Booking> healthCheckBookings = healthCheckBookingService.getHealthCheckBookingsByCustomerId(customer.getCustomerId());
        
        // Get pet information
        model.Pet pet = null;
        try {
            service.PetService petService = new service.PetService();
            pet = petService.getPetByCustomerId(customer.getCustomerId());
            
            // Log pet information for debugging
            if (pet != null) {
                logger.info("Pet found for customer " + customer.getCustomerId() + ": " + pet.getPetName());
                logger.info("Pet image path: " + pet.getImagePath());
            } else {
                logger.warning("No pet found for customer " + customer.getCustomerId());
            }
        } catch (Exception e) {
            logger.warning("Could not get pet information: " + e.getMessage());
            e.printStackTrace();
        }
        
        request.setAttribute("healthCheckServices", healthCheckServices);
        request.setAttribute("healthCheckBookings", healthCheckBookings);
        request.setAttribute("pet", pet);
        
        logger.info("Forwarding to dat-lich-kham.jsp with " + healthCheckBookings.size() + " bookings");
        
        request.getRequestDispatcher("/dat-lich-kham.jsp").forward(request, response);
    }
    
    /**
     * Hiển thị lịch sử khám sức khỏe
     */
    private void showHealthCheckHistory(HttpServletRequest request, HttpServletResponse response, Customer customer) 
            throws ServletException, IOException {
        
        List<Booking> healthCheckBookings = healthCheckBookingService.getHealthCheckBookingsByCustomerId(customer.getCustomerId());
        
        request.setAttribute("healthCheckBookings", healthCheckBookings);
        
        request.getRequestDispatcher("/health-check-history.jsp").forward(request, response);
    }
    
    /**
     * Hiển thị chi tiết booking khám sức khỏe
     */
    private void showHealthCheckBookingDetail(HttpServletRequest request, HttpServletResponse response, Customer customer) 
            throws ServletException, IOException {
        
        String bookingIdParam = request.getParameter("id");
        if (bookingIdParam == null || bookingIdParam.trim().isEmpty()) {
            request.setAttribute("error", "Không tìm thấy booking");
            response.sendRedirect(request.getContextPath() + "/health-check-booking?action=history");
            return;
        }
        
        try {
            int bookingId = Integer.parseInt(bookingIdParam);
            Booking booking = healthCheckBookingService.getHealthCheckBookingsByCustomerId(customer.getCustomerId())
                    .stream()
                    .filter(b -> b.getBookingId() == bookingId)
                    .findFirst()
                    .orElse(null);
            
            if (booking == null) {
                request.setAttribute("error", "Không tìm thấy booking hoặc bạn không có quyền xem");
                response.sendRedirect(request.getContextPath() + "/health-check-booking?action=history");
                return;
            }
            
            // Lấy chi tiết dịch vụ khám sức khỏe
            List<BookingServiceItem> healthCheckBookingDetails = healthCheckBookingService.getHealthCheckBookingDetails(bookingId);
            
            request.setAttribute("booking", booking);
            request.setAttribute("healthCheckBookingDetails", healthCheckBookingDetails);
            
            request.getRequestDispatcher("/health-check-booking-detail.jsp").forward(request, response);
            
        } catch (NumberFormatException e) {
            request.setAttribute("error", "ID booking không hợp lệ");
            response.sendRedirect(request.getContextPath() + "/health-check-booking?action=history");
        }
    }
    
    /**
     * Hiển thị lịch sử khám sức khỏe của pet
     */
    private void showPetHealthCheckHistory(HttpServletRequest request, HttpServletResponse response, Customer customer) 
            throws ServletException, IOException {
        
        String petIdParam = request.getParameter("petId");
        if (petIdParam == null || petIdParam.trim().isEmpty()) {
            request.setAttribute("error", "Không tìm thấy thông tin pet");
            response.sendRedirect(request.getContextPath() + "/dat-lich-kham.jsp");
            return;
        }
        
        try {
            int petId = Integer.parseInt(petIdParam);
            List<Booking> petHealthCheckHistory = healthCheckBookingService.getHealthCheckHistoryByPetId(petId);
            
            request.setAttribute("petHealthCheckHistory", petHealthCheckHistory);
            request.setAttribute("petId", petId);
            
            request.getRequestDispatcher("/pet-health-check-history.jsp").forward(request, response);
            
        } catch (NumberFormatException e) {
            request.setAttribute("error", "ID pet không hợp lệ");
            response.sendRedirect(request.getContextPath() + "/dat-lich-kham.jsp");
        }
    }
    
    /**
     * Tạo booking khám sức khỏe
     */
    private void createHealthCheckBooking(HttpServletRequest request, HttpServletResponse response, Customer customer) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        
        logger.info("========== CREATE HEALTH CHECK BOOKING ==========");
        logger.info("Customer: " + customer.getName() + " (ID: " + customer.getCustomerId() + ")");
        
        try {
            // Lấy thông tin từ form
            String serviceIdParam = request.getParameter("serviceId");
            String appointmentDate = request.getParameter("appointmentDate");
            String appointmentTime = request.getParameter("appointmentTime");
            String note = request.getParameter("note");
            String doctorIdParam = request.getParameter("doctorId");
            
            logger.info("Form data - serviceId: " + serviceIdParam + ", date: " + appointmentDate + 
                       ", time: " + appointmentTime + ", doctorId: " + doctorIdParam);
            
            // Validate dữ liệu đầu vào
            if (serviceIdParam == null || serviceIdParam.trim().isEmpty()) {
                logger.warning("Missing serviceId");
                session.setAttribute("errorMessage", "Vui lòng chọn dịch vụ khám");
                response.sendRedirect(request.getContextPath() + "/health-check-booking");
                return;
            }
            
            if (appointmentDate == null || appointmentDate.trim().isEmpty()) {
                logger.warning("Missing appointmentDate");
                session.setAttribute("errorMessage", "Vui lòng chọn ngày khám");
                response.sendRedirect(request.getContextPath() + "/health-check-booking");
                return;
            }
            
            if (appointmentTime == null || appointmentTime.trim().isEmpty()) {
                logger.warning("Missing appointmentTime");
                session.setAttribute("errorMessage", "Vui lòng chọn giờ khám");
                response.sendRedirect(request.getContextPath() + "/health-check-booking");
                return;
            }
            
            if (doctorIdParam == null || doctorIdParam.trim().isEmpty()) {
                logger.warning("Missing doctorId");
                session.setAttribute("errorMessage", "Vui lòng chọn bác sĩ");
                response.sendRedirect(request.getContextPath() + "/health-check-booking");
                return;
            }
            
            int serviceId = Integer.parseInt(serviceIdParam);
            int doctorId = Integer.parseInt(doctorIdParam);
            
            // Parse thời gian hẹn
            SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm");
            Timestamp appointmentStart;
            try {
                appointmentStart = new Timestamp(dateFormat.parse(appointmentDate + " " + appointmentTime).getTime());
                logger.info("Parsed appointment time: " + appointmentStart);
            } catch (ParseException e) {
                logger.severe("Failed to parse appointment time: " + e.getMessage());
                session.setAttribute("errorMessage", "Thời gian hẹn không hợp lệ");
                response.sendRedirect(request.getContextPath() + "/health-check-booking");
                return;
            }
            
            // Validate thời gian hẹn
            logger.info("Validating appointment time...");
            if (!healthCheckBookingService.validateAppointmentTime(appointmentStart)) {
                logger.warning("Invalid appointment time");
                session.setAttribute("errorMessage", "Thời gian hẹn không hợp lệ. Vui lòng chọn thời gian trong giờ làm việc (8:00-17:00) và không quá 3 tháng trong tương lai.");
                response.sendRedirect(request.getContextPath() + "/health-check-booking");
                return;
            }
            
            // Tạo booking
            logger.info("Calling healthCheckBookingService.createHealthCheckBooking()...");
            boolean success = healthCheckBookingService.createHealthCheckBooking(customer, serviceId, appointmentStart, note, doctorId);
            
            if (success) {
                logger.info("✅ Booking created successfully!");
                session.setAttribute("successMessage", "Đặt lịch khám sức khỏe thành công! Chúng tôi sẽ liên hệ lại để xác nhận.");
                response.sendRedirect(request.getContextPath() + "/health-check-booking");
            } else {
                logger.severe("❌ Booking creation failed!");
                session.setAttribute("errorMessage", "Đặt lịch khám sức khỏe thất bại. Vui lòng kiểm tra lại thông tin thú cưng hoặc thử lại sau.");
                response.sendRedirect(request.getContextPath() + "/health-check-booking");
            }
            
        } catch (NumberFormatException e) {
            logger.severe("NumberFormatException: " + e.getMessage());
            session.setAttribute("errorMessage", "Dữ liệu không hợp lệ. Vui lòng kiểm tra lại.");
            response.sendRedirect(request.getContextPath() + "/health-check-booking");
        } catch (Exception e) {
            logger.severe("Exception in createHealthCheckBooking: " + e.getMessage());
            e.printStackTrace();
            session.setAttribute("errorMessage", "Có lỗi xảy ra khi đặt lịch. Vui lòng thử lại sau.");
            response.sendRedirect(request.getContextPath() + "/health-check-booking");
        }
        
        logger.info("========== END CREATE HEALTH CHECK BOOKING ==========");
    }
    
    /**
     * Hủy booking khám sức khỏe
     */
    private void cancelHealthCheckBooking(HttpServletRequest request, HttpServletResponse response, Customer customer) 
            throws ServletException, IOException {
        
        String bookingIdParam = request.getParameter("bookingId");
        if (bookingIdParam == null || bookingIdParam.trim().isEmpty()) {
            request.setAttribute("error", "Không tìm thấy booking");
            response.sendRedirect(request.getContextPath() + "/health-check-booking?action=history");
            return;
        }
        
        try {
            int bookingId = Integer.parseInt(bookingIdParam);
            
            // Kiểm tra quyền sở hữu
            List<Booking> customerBookings = healthCheckBookingService.getHealthCheckBookingsByCustomerId(customer.getCustomerId());
            boolean hasBooking = customerBookings.stream()
                    .anyMatch(b -> b.getBookingId() == bookingId);
            
            if (!hasBooking) {
                request.setAttribute("error", "Không tìm thấy booking hoặc bạn không có quyền hủy");
                response.sendRedirect(request.getContextPath() + "/health-check-booking?action=history");
                return;
            }
            
            // Kiểm tra có thể hủy không
            if (!healthCheckBookingService.canCancelHealthCheckBooking(bookingId)) {
                request.setAttribute("error", "Không thể hủy booking này");
                response.sendRedirect(request.getContextPath() + "/health-check-booking?action=history");
                return;
            }
            
            // Hủy booking
            boolean success = healthCheckBookingService.cancelHealthCheckBooking(bookingId);
            
            if (success) {
                request.setAttribute("success", "Hủy đặt lịch khám sức khỏe thành công");
            } else {
                request.setAttribute("error", "Hủy đặt lịch khám sức khỏe thất bại");
            }
            
            response.sendRedirect(request.getContextPath() + "/health-check-booking?action=history");
            
        } catch (NumberFormatException e) {
            request.setAttribute("error", "ID booking không hợp lệ");
            response.sendRedirect(request.getContextPath() + "/health-check-booking?action=history");
        }
    }
    
    /**
     * Thêm dịch vụ khám sức khỏe vào giỏ
     */
    private void addHealthCheckServiceToCart(HttpServletRequest request, HttpServletResponse response, Customer customer) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        
        try {
            String serviceIdParam = request.getParameter("serviceId");
            String quantityParam = request.getParameter("quantity");
            
            if (serviceIdParam == null || serviceIdParam.trim().isEmpty()) {
                session.setAttribute("errorMessage", "Vui lòng chọn dịch vụ");
                response.sendRedirect(request.getContextPath() + "/health-check-booking");
                return;
            }
            
            int serviceId = Integer.parseInt(serviceIdParam);
            int quantity = 1; // Default quantity
            if (quantityParam != null && !quantityParam.trim().isEmpty()) {
                quantity = Integer.parseInt(quantityParam);
            }
            
            // Lấy dịch vụ từ database
            PetServiceModel service = healthCheckBookingService.getHealthCheckServiceById(serviceId);
            if (service == null) {
                session.setAttribute("errorMessage", "Dịch vụ không tồn tại");
                response.sendRedirect(request.getContextPath() + "/health-check-booking");
                return;
            }
            
            // Lấy giỏ hàng từ session
            Map<Integer, CartItem> healthCheckCart = (Map<Integer, CartItem>) session.getAttribute("healthCheckCart");
            if (healthCheckCart == null) {
                healthCheckCart = new HashMap<>();
            }
            
            // Thêm hoặc cập nhật số lượng
            if (healthCheckCart.containsKey(serviceId)) {
                CartItem existingItem = healthCheckCart.get(serviceId);
                existingItem.setQuantity(existingItem.getQuantity() + quantity);
            } else {
                // Tạo CartItem mới với Product (giả lập)
                Product product = new Product();
                product.setProductId(serviceId);
                product.setName(service.getName());
                product.setPrice(service.getPrice().doubleValue());
                product.setDescription(service.getDescription());
                
                CartItem newItem = new CartItem(product, quantity);
                healthCheckCart.put(serviceId, newItem);
            }
            
            // Lưu giỏ hàng vào session
            session.setAttribute("healthCheckCart", healthCheckCart);
            
            response.sendRedirect(request.getContextPath() + "/health-check-booking");
            
        } catch (NumberFormatException e) {
            session.setAttribute("errorMessage", "Dữ liệu không hợp lệ");
            response.sendRedirect(request.getContextPath() + "/health-check-booking");
        } catch (Exception e) {
            logger.severe("Error adding service to cart: " + e.getMessage());
            session.setAttribute("errorMessage", "Có lỗi xảy ra khi thêm dịch vụ vào giỏ");
            response.sendRedirect(request.getContextPath() + "/health-check-booking");
        }
    }
}
