package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import service.HealthCheckBookingService;
import service.PayOSService;
import dao.MedicalRecordDAO;
import dao.PetDAO;
import dao.PetServiceDAO;
import model.Customer;
import model.Booking;
import model.BookingServiceItem;
import model.CartItem;
import model.Product;
import model.MedicalRecord;
import model.Pet;
import utils.DBConnection;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.List;
import java.util.Map;
import java.util.HashMap;
import java.util.Collections;
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
    private MedicalRecordDAO medicalRecordDAO;
    private PetDAO petDAO;
    private PetServiceDAO petServiceDAO;
    private PayOSService payOSService;
    
    @Override
    public void init() throws ServletException {
        super.init();
        this.healthCheckBookingService = new HealthCheckBookingService();
        this.medicalRecordDAO = new MedicalRecordDAO();
        this.petDAO = new PetDAO();
        this.petServiceDAO = new PetServiceDAO();
        this.payOSService = new PayOSService();
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
            
            // Xử lý PayOS callback (GET request)
            if (action != null && action.equals("complete-booking")) {
                // Hoàn tất booking sau khi thanh toán thành công (PayOS callback)
                completeHealthCheckBooking(request, response, customer);
                return;
            } else if (action != null && action.equals("cancel-payment")) {
                // Hủy payment (PayOS callback)
                cancelHealthCheckPayment(request, response, customer);
                return;
            }
            
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
            } else if (action != null && action.equals("get-suitable-doctor")) {
                // Lấy thông tin bác sĩ phù hợp với dịch vụ (AJAX)
                getSuitableDoctorInfo(request, response, customer);
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
                // Tạo payment và redirect đến PayOS
                createHealthCheckPayment(request, response, customer);
            } else if (action != null && action.equals("complete-booking")) {
                // Hoàn tất booking sau khi thanh toán thành công
                completeHealthCheckBooking(request, response, customer);
            } else if (action != null && action.equals("cancel-payment")) {
                // Hủy payment
                cancelHealthCheckPayment(request, response, customer);
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

        // Get selected pet information
        model.Pet pet = null;
        String petIdParam = request.getParameter("petId");
        try {
            if (petIdParam != null && !petIdParam.trim().isEmpty()) {
                // Get pet by ID if specified in URL
                int petId = Integer.parseInt(petIdParam);
                pet = petDAO.getPetById(petId);
                // Verify pet belongs to customer
                if (pet != null && pet.getCustomerId() != customer.getCustomerId()) {
                    logger.warning("Pet ID " + petId + " does not belong to customer " + customer.getCustomerId());
                    pet = null;
                }
            }

            // If no pet selected or invalid, get the first pet as default
            if (pet == null) {
                List<Pet> customerPets = petDAO.getPetsByCustomerId(customer.getCustomerId());
                if (customerPets != null && !customerPets.isEmpty()) {
                    pet = customerPets.get(0); // Default to first pet
                }
            }

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

        // Get bookings filtered by selected pet
        List<Booking> healthCheckBookings;
        if (pet != null) {
            healthCheckBookings = healthCheckBookingService.getHealthCheckHistoryByPetId(pet.getId());
        } else {
            healthCheckBookings = Collections.emptyList(); // No pet selected, no bookings to show
        }

        // Load medical records for the selected pet (not other pets)
        List<Pet> customerPets = null;
        Map<Integer, List<MedicalRecord>> petsMedicalRecords = new HashMap<>();

        try {
            customerPets = petDAO.getPetsByCustomerId(customer.getCustomerId());
            logger.info("Customer has " + (customerPets != null ? customerPets.size() : 0) + " pets");

            // Only load medical records for the selected pet
            if (pet != null) {
                List<MedicalRecord> petRecords = medicalRecordDAO.getByPetId(pet.getId());
                if (!petRecords.isEmpty()) {
                    petsMedicalRecords.put(pet.getId(), petRecords);
                    logger.info("Selected pet " + pet.getPetName() + " has " + petRecords.size() + " medical records");
                }
            }
        } catch (Exception e) {
            logger.warning("Could not load medical records for selected pet: " + e.getMessage());
        }

        request.setAttribute("healthCheckServices", healthCheckServices);
        request.setAttribute("healthCheckBookings", healthCheckBookings);
        request.setAttribute("pet", pet);
        request.setAttribute("customerPets", customerPets);
        request.setAttribute("petsMedicalRecords", petsMedicalRecords);

        logger.info("Forwarding to dat-lich-kham.jsp with " + healthCheckBookings.size() + " bookings and " + petsMedicalRecords.size() + " pets with medical records");

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
     * Tạo payment và redirect đến PayOS
     */
    private void createHealthCheckPayment(HttpServletRequest request, HttpServletResponse response, Customer customer) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        
        logger.info("========== CREATE HEALTH CHECK PAYMENT ==========");
        logger.info("Customer: " + customer.getName() + " (ID: " + customer.getCustomerId() + ")");
        
        try {
            // Lấy thông tin từ form
            String petIdParam = request.getParameter("petId");
            String serviceIdParam = request.getParameter("serviceId");
            String appointmentDate = request.getParameter("appointmentDate");
            String appointmentTime = request.getParameter("appointmentTime");
            String note = request.getParameter("note");
            String doctorIdParam = request.getParameter("doctorId");

            logger.info("Form data - petId: " + petIdParam + ", serviceId: " + serviceIdParam + ", date: " + appointmentDate +
                        ", time: " + appointmentTime + ", doctorId: " + doctorIdParam);

            // Validate dữ liệu đầu vào
            if (petIdParam == null || petIdParam.trim().isEmpty()) {
                logger.warning("Missing petId");
                session.setAttribute("errorMessage", "Vui lòng chọn thú cưng");
                response.sendRedirect(request.getContextPath() + "/health-check-booking");
                return;
            }

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
            
            int petId = Integer.parseInt(petIdParam);
            int serviceId = Integer.parseInt(serviceIdParam);
            
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
            
            // Tự động chọn bác sĩ phù hợp với dịch vụ
            logger.info("Automatically selecting suitable doctor for service...");
            model.Doctor selectedDoctor = healthCheckBookingService.getSuitableDoctorForService(serviceId, appointmentStart);
            if (selectedDoctor == null) {
                logger.severe("❌ No suitable doctor found!");
                session.setAttribute("errorMessage", "Không tìm thấy bác sĩ phù hợp. Vui lòng thử lại sau.");
                response.sendRedirect(request.getContextPath() + "/health-check-booking");
                return;
            }
            
            int doctorId = selectedDoctor.getDoctorId();
            logger.info("✅ Selected doctor: " + selectedDoctor.getName() + " (ID: " + doctorId + ", Specialization: " + selectedDoctor.getSpecialization() + ")");
            
            // Kiểm tra trùng lịch trước khi tạo payment
            // Nếu bác sĩ vẫn bận, getSuitableDoctorForService đã tự động chọn bác sĩ khác rảnh
            // Nên chỉ cần kiểm tra để log cảnh báo
            logger.info("Checking for conflicting appointments...");
            if (healthCheckBookingService.hasConflictingAppointment(doctorId, appointmentStart)) {
                logger.warning("⚠️ Warning: Selected doctor may have conflicting appointment. Trying to find another available doctor...");
                // Thử tìm bác sĩ khác một lần nữa
                model.Doctor alternativeDoctor = healthCheckBookingService.getSuitableDoctorForService(serviceId, appointmentStart);
                if (alternativeDoctor != null && !healthCheckBookingService.hasConflictingAppointment(alternativeDoctor.getDoctorId(), appointmentStart)) {
                    doctorId = alternativeDoctor.getDoctorId();
                    selectedDoctor = alternativeDoctor;
                    logger.info("✅ Found alternative available doctor: " + alternativeDoctor.getName() + " (ID: " + doctorId + ")");
                } else {
                    logger.warning("⚠️ All doctors appear to be busy at this time. Proceeding with selected doctor.");
                }
            }

            // Lấy thông tin dịch vụ để lấy giá
            PetServiceModel service = healthCheckBookingService.getHealthCheckServiceById(serviceId);
            if (service == null) {
                logger.severe("Service not found: " + serviceId);
                session.setAttribute("errorMessage", "Dịch vụ không tồn tại");
                response.sendRedirect(request.getContextPath() + "/health-check-booking");
                return;
            }
            
            double amount = service.getPrice().doubleValue();
            logger.info("Service price: " + amount);
            
            // Tạo payment record trong database
            int paymentId = createPaymentRecord(customer.getCustomerId(), serviceId, amount, petId, appointmentStart, note, doctorId);
            if (paymentId <= 0) {
                logger.severe("Failed to create payment record");
                session.setAttribute("errorMessage", "Không thể tạo thanh toán. Vui lòng thử lại.");
                response.sendRedirect(request.getContextPath() + "/health-check-booking");
                return;
            }
            
            // Tạo PayOS orderCode unique
            long timestamp = System.currentTimeMillis();
            int payosOrderCode = (int) ((timestamp % 1000000000) * 1000 + (paymentId % 1000));
            if (payosOrderCode < 0) {
                payosOrderCode = Math.abs(payosOrderCode);
            }
            
            // Cập nhật payos_order_code vào payment record
            updatePaymentPayOSCode(paymentId, payosOrderCode);
            
            // Tạo PayOS payment link
            String description = "Thanh toan kham suc khoe #" + paymentId;
            if (description.length() > 25) {
                description = "Kham suc khoe #" + paymentId;
            }
            if (description.length() > 25) {
                description = "KSK#" + paymentId;
            }
            
            String baseUrl = buildBaseUrl(request);
            String returnUrl = baseUrl + "/health-check-booking?action=complete-booking&paymentId=" + paymentId;
            String cancelUrl = baseUrl + "/health-check-booking?action=cancel-payment&paymentId=" + paymentId;
            
            logger.info("Creating PayOS payment link - orderCode: " + payosOrderCode + ", amount: " + amount);
            String paymentUrl = payOSService.createPaymentLink(payosOrderCode, amount, description, returnUrl, cancelUrl);
            
            if (paymentUrl != null && !paymentUrl.trim().isEmpty()) {
                logger.info("✅ Payment URL created: " + paymentUrl);
                // Lưu thông tin booking vào session để tạo booking sau khi thanh toán thành công
                session.setAttribute("pendingBooking_" + paymentId, 
                    new BookingInfo(petId, serviceId, appointmentStart, note, doctorId));
                response.sendRedirect(paymentUrl);
            } else {
                logger.severe("❌ Failed to create PayOS payment link");
                session.setAttribute("errorMessage", "Không thể tạo link thanh toán. Vui lòng thử lại.");
                response.sendRedirect(request.getContextPath() + "/health-check-booking");
            }
            
        } catch (NumberFormatException e) {
            logger.severe("NumberFormatException: " + e.getMessage());
            session.setAttribute("errorMessage", "Dữ liệu không hợp lệ. Vui lòng kiểm tra lại.");
            response.sendRedirect(request.getContextPath() + "/health-check-booking");
        } catch (Exception e) {
            logger.severe("Exception in createHealthCheckPayment: " + e.getMessage());
            e.printStackTrace();
            session.setAttribute("errorMessage", "Có lỗi xảy ra khi tạo thanh toán. Vui lòng thử lại sau.");
            response.sendRedirect(request.getContextPath() + "/health-check-booking");
        }
        
        logger.info("========== END CREATE HEALTH CHECK PAYMENT ==========");
    }
    
    /**
     * Hoàn tất booking sau khi thanh toán thành công
     */
    private void completeHealthCheckBooking(HttpServletRequest request, HttpServletResponse response, Customer customer) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        logger.info("=== BẮT ĐẦU completeHealthCheckBooking ===");
        logger.info("Customer ID: " + (customer != null ? customer.getCustomerId() : "null"));
        logger.info("Request params: paymentId=" + request.getParameter("paymentId") + 
                   ", status=" + request.getParameter("status") + 
                   ", orderCode=" + request.getParameter("orderCode") +
                   ", code=" + request.getParameter("code") +
                   ", cancel=" + request.getParameter("cancel"));
        
        try {
            // Kiểm tra trạng thái thanh toán từ PayOS callback
            String payosStatus = request.getParameter("status");
            String cancelParam = request.getParameter("cancel");
            String codeParam = request.getParameter("code");
            
            // Nếu cancel=true hoặc status không phải PAID, redirect về trang hủy
            if ("true".equalsIgnoreCase(cancelParam) || 
                (payosStatus != null && !"PAID".equalsIgnoreCase(payosStatus))) {
                logger.warning("⚠️ Payment cancelled or not paid. Status: " + payosStatus + ", Cancel: " + cancelParam);
                String paymentIdParam = request.getParameter("paymentId");
                if (paymentIdParam != null && !paymentIdParam.trim().isEmpty()) {
                    try {
                        int paymentId = Integer.parseInt(paymentIdParam);
                        updatePaymentStatus(paymentId, "cancelled");
                    } catch (Exception e) {
                        logger.warning("Could not update payment status: " + e.getMessage());
                    }
                }
                response.sendRedirect(request.getContextPath() + "/order/invoice-cancelled.jsp?type=health_check&paymentId=" + 
                    (paymentIdParam != null ? paymentIdParam : ""));
                return;
            }
            
            String paymentIdParam = request.getParameter("paymentId");
            if (paymentIdParam == null || paymentIdParam.trim().isEmpty()) {
                logger.warning("⚠️ Payment ID not found in request");
                // Cố gắng lấy từ orderCode nếu có
                String orderCodeParam = request.getParameter("orderCode");
                if (orderCodeParam != null && !orderCodeParam.trim().isEmpty()) {
                    try {
                        int orderCode = Integer.parseInt(orderCodeParam);
                        Integer foundPaymentId = getPaymentIdByOrderCode(orderCode);
                        if (foundPaymentId != null) {
                            paymentIdParam = String.valueOf(foundPaymentId);
                            logger.info("✅ Found payment ID from orderCode: " + foundPaymentId);
                        }
                    } catch (Exception e) {
                        logger.warning("Could not parse orderCode: " + e.getMessage());
                    }
                }
                
                if (paymentIdParam == null || paymentIdParam.trim().isEmpty()) {
                    session.setAttribute("errorMessage", "Không tìm thấy thông tin thanh toán");
                    response.sendRedirect(request.getContextPath() + "/health-check-booking");
                    return;
                }
            }
            
            int paymentId = Integer.parseInt(paymentIdParam);
            logger.info("📋 Processing payment ID: " + paymentId);
            
            // Kiểm tra payment status
            PaymentInfo paymentInfo = getPaymentInfo(paymentId);
            if (paymentInfo == null || !paymentInfo.belongsToCustomer(customer.getCustomerId())) {
                logger.warning("⚠️ Payment not found or doesn't belong to customer");
                session.setAttribute("errorMessage", "Không tìm thấy thông tin thanh toán");
                response.sendRedirect(request.getContextPath() + "/health-check-booking");
                return;
            }
            
            // Kiểm tra nếu payment đã được xử lý rồi (tránh duplicate booking)
            if ("paid".equalsIgnoreCase(paymentInfo.status)) {
                logger.info("ℹ️ Payment already processed, redirecting to invoice");
                // Lấy thông tin booking từ payment để redirect
                BookingInfo bookingInfo = getBookingInfoFromPayment(paymentId);
                if (bookingInfo != null) {
                    Integer bookingId = getLatestBookingIdByCustomerAndTime(customer.getCustomerId(), bookingInfo.appointmentStart);
                    model.PetServiceModel service = petServiceDAO.getServiceById(bookingInfo.serviceId);
                    String serviceName = service != null ? service.getName() : "Dịch vụ khám sức khỏe";
                    
                    StringBuilder invoiceUrl = new StringBuilder(request.getContextPath() + "/order/invoice.jsp");
                    invoiceUrl.append("?type=health_check");
                    invoiceUrl.append("&serviceId=").append(bookingInfo.serviceId);
                    invoiceUrl.append("&serviceName=").append(java.net.URLEncoder.encode(serviceName, "UTF-8"));
                    invoiceUrl.append("&amount=").append(paymentInfo.amount);
                    invoiceUrl.append("&method=PayOS");
                    if (bookingId != null) {
                        invoiceUrl.append("&bookingId=").append(bookingId);
                    }
                    response.sendRedirect(invoiceUrl.toString());
                    return;
                }
            }
            
            // Lấy thông tin booking từ payment record
            BookingInfo bookingInfo = getBookingInfoFromPayment(paymentId);
            if (bookingInfo == null) {
                session.setAttribute("errorMessage", "Không tìm thấy thông tin đặt lịch");
                response.sendRedirect(request.getContextPath() + "/health-check-booking");
                return;
            }
            
            // Tạo booking
            boolean success = healthCheckBookingService.createHealthCheckBooking(
                customer, 
                bookingInfo.petId, 
                bookingInfo.serviceId, 
                bookingInfo.appointmentStart, 
                bookingInfo.note, 
                bookingInfo.doctorId
            );
            
            if (success) {
                // Cập nhật payment status
                updatePaymentAfterBooking(paymentId);
                
                // Lấy booking_id vừa tạo để hiển thị hóa đơn
                Integer bookingId = getLatestBookingIdByCustomerAndTime(
                    customer.getCustomerId(), 
                    bookingInfo.appointmentStart
                );
                
                // Lấy thông tin dịch vụ để hiển thị trên hóa đơn
                model.PetServiceModel service = petServiceDAO.getServiceById(bookingInfo.serviceId);
                String serviceName = service != null ? service.getName() : "Dịch vụ khám sức khỏe";
                double amount = paymentInfo.amount;
                
                // Luôn redirect về trang hóa đơn thành công
                // Nếu không tìm thấy booking_id, vẫn hiển thị hóa đơn với thông tin từ payment
                StringBuilder invoiceUrl = new StringBuilder(request.getContextPath() + "/order/invoice.jsp");
                invoiceUrl.append("?type=health_check");
                invoiceUrl.append("&serviceId=").append(bookingInfo.serviceId);
                invoiceUrl.append("&serviceName=").append(java.net.URLEncoder.encode(serviceName, "UTF-8"));
                invoiceUrl.append("&amount=").append(amount);
                invoiceUrl.append("&method=PayOS");
                
                if (bookingId != null) {
                    invoiceUrl.append("&bookingId=").append(bookingId);
                    logger.info("✅ Redirecting to invoice with bookingId: " + bookingId);
                } else {
                    logger.warning("⚠️ Booking ID not found, redirecting to invoice without bookingId");
                }
                
                response.sendRedirect(invoiceUrl.toString());
                return;
            } else {
                session.setAttribute("errorMessage", "Đặt lịch khám sức khỏe thất bại. Vui lòng liên hệ hỗ trợ.");
                response.sendRedirect(request.getContextPath() + "/health-check-booking");
            }
            
        } catch (Exception e) {
            logger.severe("❌ Exception in completeHealthCheckBooking: " + e.getMessage());
            e.printStackTrace();
            
            // LUÔN cố gắng redirect về invoice với thông tin có sẵn từ request
            try {
                String paymentIdParam = request.getParameter("paymentId");
                String orderCodeParam = request.getParameter("orderCode");
                
                // Nếu không có paymentId, thử lấy từ orderCode
                if ((paymentIdParam == null || paymentIdParam.trim().isEmpty()) && 
                    orderCodeParam != null && !orderCodeParam.trim().isEmpty()) {
                    try {
                        int orderCode = Integer.parseInt(orderCodeParam);
                        Integer foundPaymentId = getPaymentIdByOrderCode(orderCode);
                        if (foundPaymentId != null) {
                            paymentIdParam = String.valueOf(foundPaymentId);
                            logger.info("✅ Found payment ID from orderCode in exception handler: " + foundPaymentId);
                        }
                    } catch (Exception ex) {
                        logger.warning("Could not parse orderCode in exception handler: " + ex.getMessage());
                    }
                }
                
                if (paymentIdParam != null && !paymentIdParam.trim().isEmpty()) {
                    try {
                        // Lấy thông tin từ payment nếu có thể
                        PaymentInfo paymentInfo = getPaymentInfo(Integer.parseInt(paymentIdParam));
                        if (paymentInfo != null) {
                            // Lấy service name
                            model.PetServiceModel service = petServiceDAO.getServiceById(paymentInfo.serviceId);
                            String serviceName = service != null ? service.getName() : "Dịch vụ khám sức khỏe";
                            
                            StringBuilder invoiceUrl = new StringBuilder(request.getContextPath() + "/order/invoice.jsp");
                            invoiceUrl.append("?type=health_check");
                            invoiceUrl.append("&serviceId=").append(paymentInfo.serviceId);
                            invoiceUrl.append("&serviceName=").append(java.net.URLEncoder.encode(serviceName, "UTF-8"));
                            invoiceUrl.append("&amount=").append(paymentInfo.amount);
                            invoiceUrl.append("&method=PayOS");
                            
                            // Thử lấy bookingId nếu có thể
                            BookingInfo bookingInfo = getBookingInfoFromPayment(Integer.parseInt(paymentIdParam));
                            if (bookingInfo != null && customer != null) {
                                Integer bookingId = getLatestBookingIdByCustomerAndTime(customer.getCustomerId(), bookingInfo.appointmentStart);
                                if (bookingId != null) {
                                    invoiceUrl.append("&bookingId=").append(bookingId);
                                }
                            }
                            
                            logger.info("✅ Redirecting to invoice from exception handler: " + invoiceUrl.toString());
                            response.sendRedirect(invoiceUrl.toString());
                            return;
                        }
                    } catch (Exception ex) {
                        logger.severe("❌ Error getting payment info in exception handler: " + ex.getMessage());
                    }
                }
                
                // Fallback: redirect với thông tin tối thiểu
                StringBuilder invoiceUrl = new StringBuilder(request.getContextPath() + "/order/invoice.jsp");
                invoiceUrl.append("?type=health_check");
                invoiceUrl.append("&method=PayOS");
                if (orderCodeParam != null) {
                    invoiceUrl.append("&orderCode=").append(orderCodeParam);
                }
                logger.info("⚠️ Redirecting to invoice with minimal info: " + invoiceUrl.toString());
                response.sendRedirect(invoiceUrl.toString());
                return;
                
            } catch (Exception ex) {
                logger.severe("❌ Error in fallback redirect: " + ex.getMessage());
                ex.printStackTrace();
            }
            
            // Last resort: redirect về health check booking page
            session.setAttribute("errorMessage", "Có lỗi xảy ra khi hoàn tất đặt lịch. Vui lòng thử lại sau.");
            response.sendRedirect(request.getContextPath() + "/health-check-booking");
        }
    }
    
    /**
     * Helper class để lưu thông tin booking
     */
    private static class BookingInfo {
        int petId;
        int serviceId;
        Timestamp appointmentStart;
        String note;
        int doctorId;
        
        BookingInfo(int petId, int serviceId, Timestamp appointmentStart, String note, int doctorId) {
            this.petId = petId;
            this.serviceId = serviceId;
            this.appointmentStart = appointmentStart;
            this.note = note;
            this.doctorId = doctorId;
        }
    }
    
    /**
     * Helper class để lưu thông tin payment
     */
    private static class PaymentInfo {
        int paymentId;
        int customerId;
        int serviceId;
        double amount;
        String status;
        int petId;
        Timestamp appointmentStart;
        String note;
        int doctorId;
        
        boolean belongsToCustomer(int customerId) {
            return this.customerId == customerId;
        }
    }
    
    /**
     * Tạo payment record trong database
     */
    private int createPaymentRecord(int customerId, int serviceId, double amount, int petId, 
                                    Timestamp appointmentStart, String note, int doctorId) {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                 "INSERT INTO dbo.Payment (payment_type, reference_id, customer_id, amount, payment_status, payment_method, note, created_at) " +
                 "OUTPUT INSERTED.payment_id VALUES ('health_check', ?, ?, ?, 'pending', 'PayOS', ?, GETDATE())")) {
            
            ps.setInt(1, serviceId); // reference_id = service_id cho health_check
            ps.setInt(2, customerId);
            ps.setDouble(3, amount);
            ps.setString(4, buildPaymentNote(petId, appointmentStart, note, doctorId));
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int paymentId = rs.getInt(1);
                    logger.info("Payment record created with ID: " + paymentId);
                    return paymentId;
                }
            }
            
        } catch (Exception e) {
            logger.severe("Error creating payment record: " + e.getMessage());
            e.printStackTrace();
        }
        return 0;
    }
    
    /**
     * Build payment note để lưu thông tin booking
     */
    private String buildPaymentNote(int petId, Timestamp appointmentStart, String note, int doctorId) {
        return "petId:" + petId + ";appointmentStart:" + appointmentStart.getTime() + 
               ";doctorId:" + doctorId + ";note:" + (note != null ? note : "");
    }
    
    /**
     * Parse booking info từ payment note
     */
    private BookingInfo getBookingInfoFromPayment(int paymentId) {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                 "SELECT reference_id, note FROM dbo.Payment WHERE payment_id = ? AND payment_type = 'health_check'")) {
            
            ps.setInt(1, paymentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int serviceId = rs.getInt("reference_id"); // reference_id = service_id cho health_check
                    String note = rs.getString("note");
                    if (note != null && note.contains("petId:")) {
                        String[] parts = note.split(";");
                        int petId = 0;
                        long appointmentTime = 0;
                        int doctorId = 0;
                        String bookingNote = "";
                        
                        for (String part : parts) {
                            if (part.startsWith("petId:")) {
                                petId = Integer.parseInt(part.substring(6));
                            } else if (part.startsWith("appointmentStart:")) {
                                appointmentTime = Long.parseLong(part.substring(17));
                            } else if (part.startsWith("doctorId:")) {
                                doctorId = Integer.parseInt(part.substring(9));
                            } else if (part.startsWith("note:")) {
                                bookingNote = part.substring(5);
                            }
                        }
                        
                        return new BookingInfo(petId, serviceId, new Timestamp(appointmentTime), bookingNote, doctorId);
                    }
                }
            }
            
        } catch (Exception e) {
            logger.severe("Error getting booking info from payment: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }
    
    /**
     * Lấy thông tin payment
     */
    private PaymentInfo getPaymentInfo(int paymentId) {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                 "SELECT payment_id, customer_id, reference_id, amount, payment_status " +
                 "FROM dbo.Payment WHERE payment_id = ? AND payment_type = 'health_check'")) {
            
            ps.setInt(1, paymentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    PaymentInfo info = new PaymentInfo();
                    info.paymentId = rs.getInt("payment_id");
                    info.customerId = rs.getInt("customer_id");
                    info.serviceId = rs.getInt("reference_id"); // reference_id = service_id cho health_check
                    info.amount = rs.getDouble("amount");
                    info.status = rs.getString("payment_status");
                    return info;
                }
            }
            
        } catch (Exception e) {
            logger.severe("Error getting payment info: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }
    
    /**
     * Cập nhật PayOS order code vào payment
     */
    private void updatePaymentPayOSCode(int paymentId, int payosOrderCode) {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                 "UPDATE dbo.Payment SET payos_order_code = ? WHERE payment_id = ?")) {
            
            ps.setInt(1, payosOrderCode);
            ps.setInt(2, paymentId);
            ps.executeUpdate();
            
        } catch (Exception e) {
            logger.severe("Error updating PayOS order code: " + e.getMessage());
            e.printStackTrace();
        }
    }
    
    /**
     * Cập nhật payment sau khi tạo booking thành công
     */
    private void updatePaymentAfterBooking(int paymentId) {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                 "UPDATE dbo.Payment SET payment_status = 'paid', paid_at = GETDATE() " +
                 "WHERE payment_id = ?")) {
            
            ps.setInt(1, paymentId);
            ps.executeUpdate();
            
        } catch (Exception e) {
            logger.severe("Error updating payment after booking: " + e.getMessage());
            e.printStackTrace();
        }
    }
    
    /**
     * Lấy payment_id từ PayOS order code
     */
    private Integer getPaymentIdByOrderCode(int orderCode) {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                 "SELECT payment_id FROM dbo.Payment WHERE payos_order_code = ? AND payment_type = 'health_check'")) {
            
            ps.setInt(1, orderCode);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int paymentId = rs.getInt("payment_id");
                    logger.info("✅ Found payment ID: " + paymentId + " for orderCode: " + orderCode);
                    return paymentId;
                } else {
                    logger.warning("⚠️ No payment found for orderCode: " + orderCode);
                }
            }
            
        } catch (Exception e) {
            logger.severe("❌ Error getting payment ID by order code: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }
    
    /**
     * Lấy booking_id mới nhất của customer với appointment_start tương ứng
     * Tìm trong khoảng thời gian ±1 phút để tránh vấn đề về milliseconds
     */
    private Integer getLatestBookingIdByCustomerAndTime(int customerId, Timestamp appointmentStart) {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                 "SELECT TOP 1 booking_id FROM dbo.Booking " +
                 "WHERE customer_id = ? " +
                 "AND appointment_start >= DATEADD(MINUTE, -1, ?) " +
                 "AND appointment_start <= DATEADD(MINUTE, 1, ?) " +
                 "ORDER BY created_at DESC")) {
            
            ps.setInt(1, customerId);
            ps.setTimestamp(2, appointmentStart);
            ps.setTimestamp(3, appointmentStart);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int bookingId = rs.getInt("booking_id");
                    logger.info("✅ Found booking_id: " + bookingId + " for customer: " + customerId);
                    return bookingId;
                } else {
                    logger.warning("⚠️ No booking found for customer: " + customerId + " at time: " + appointmentStart);
                }
            }
            
        } catch (Exception e) {
            logger.severe("❌ Error getting latest booking ID: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }
    
    /**
     * Tạo baseUrl từ request
     */
    private String buildBaseUrl(HttpServletRequest request) {
        String scheme = request.getScheme();
        String serverName = request.getServerName();
        int port = request.getServerPort();
        String contextPath = request.getContextPath();
        
        if (contextPath == null || contextPath.trim().isEmpty()) {
            contextPath = "";
        }
        
        StringBuilder url = new StringBuilder();
        url.append(scheme).append("://").append(serverName);
        
        if ((scheme.equals("http") && port != 80) || (scheme.equals("https") && port != 443)) {
            url.append(":").append(port);
        }
        
        url.append(contextPath);
        
        return url.toString();
    }
    
    /**
     * Hủy payment
     */
    private void cancelHealthCheckPayment(HttpServletRequest request, HttpServletResponse response, Customer customer) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        
        try {
            String paymentIdParam = request.getParameter("paymentId");
            if (paymentIdParam == null || paymentIdParam.trim().isEmpty()) {
                session.setAttribute("errorMessage", "Không tìm thấy thông tin thanh toán");
                response.sendRedirect(request.getContextPath() + "/health-check-booking");
                return;
            }
            
            int paymentId = Integer.parseInt(paymentIdParam);
            
            // Kiểm tra payment status
            PaymentInfo paymentInfo = getPaymentInfo(paymentId);
            if (paymentInfo == null || !paymentInfo.belongsToCustomer(customer.getCustomerId())) {
                session.setAttribute("errorMessage", "Không tìm thấy thông tin thanh toán");
                response.sendRedirect(request.getContextPath() + "/health-check-booking");
                return;
            }
            
            // Cập nhật payment status thành cancelled
            updatePaymentStatus(paymentId, "cancelled");
            
            session.setAttribute("errorMessage", "Đã hủy thanh toán. Vui lòng đặt lịch lại nếu cần.");
            response.sendRedirect(request.getContextPath() + "/health-check-booking");
            
        } catch (Exception e) {
            logger.severe("Exception in cancelHealthCheckPayment: " + e.getMessage());
            e.printStackTrace();
            session.setAttribute("errorMessage", "Có lỗi xảy ra khi hủy thanh toán.");
            response.sendRedirect(request.getContextPath() + "/health-check-booking");
        }
    }
    
    /**
     * Cập nhật payment status
     */
    private void updatePaymentStatus(int paymentId, String status) {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                 "UPDATE dbo.Payment SET payment_status = ? WHERE payment_id = ?")) {
            
            ps.setString(1, status);
            ps.setInt(2, paymentId);
            ps.executeUpdate();
            
        } catch (Exception e) {
            logger.severe("Error updating payment status: " + e.getMessage());
            e.printStackTrace();
        }
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

    /**
     * Lấy thông tin bác sĩ phù hợp với dịch vụ (AJAX endpoint)
     */
    private void getSuitableDoctorInfo(HttpServletRequest request, HttpServletResponse response, Customer customer)
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        try {
            String serviceIdParam = request.getParameter("serviceId");
            String appointmentDate = request.getParameter("appointmentDate");
            String appointmentTime = request.getParameter("appointmentTime");
            
            if (serviceIdParam == null || serviceIdParam.trim().isEmpty()) {
                response.getWriter().write("{\"error\": \"Vui lòng chọn dịch vụ\"}");
                return;
            }
            
            if (appointmentDate == null || appointmentDate.trim().isEmpty() ||
                appointmentTime == null || appointmentTime.trim().isEmpty()) {
                response.getWriter().write("{\"error\": \"Vui lòng chọn ngày và giờ khám\"}");
                return;
            }
            
            int serviceId = Integer.parseInt(serviceIdParam);
            
            // Parse thời gian hẹn
            SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm");
            Timestamp appointmentStart;
            try {
                appointmentStart = new Timestamp(dateFormat.parse(appointmentDate + " " + appointmentTime).getTime());
            } catch (ParseException e) {
                response.getWriter().write("{\"error\": \"Thời gian không hợp lệ\"}");
                return;
            }
            
            // Lấy bác sĩ phù hợp
            model.Doctor selectedDoctor = healthCheckBookingService.getSuitableDoctorForService(serviceId, appointmentStart);
            
            if (selectedDoctor == null) {
                response.getWriter().write("{\"error\": \"Không tìm thấy bác sĩ phù hợp\"}");
                return;
            }
            
            // Kiểm tra xem bác sĩ có bận không
            boolean isBusy = healthCheckBookingService.hasConflictingAppointment(selectedDoctor.getDoctorId(), appointmentStart);
            
            // Trả về JSON với thông tin bác sĩ
            StringBuilder json = new StringBuilder();
            json.append("{");
            json.append("\"success\": true,");
            json.append("\"doctorId\": ").append(selectedDoctor.getDoctorId()).append(",");
            json.append("\"doctorName\": \"").append(escapeJson(selectedDoctor.getName())).append("\",");
            json.append("\"specialization\": \"").append(escapeJson(selectedDoctor.getSpecialization())).append("\",");
            json.append("\"isBusy\": ").append(isBusy);
            json.append("}");
            
            response.getWriter().write(json.toString());
            
        } catch (NumberFormatException e) {
            response.getWriter().write("{\"error\": \"Dữ liệu không hợp lệ\"}");
        } catch (Exception e) {
            logger.severe("Error getting suitable doctor info: " + e.getMessage());
            e.printStackTrace();
            response.getWriter().write("{\"error\": \"Có lỗi xảy ra\"}");
        }
    }
    
    /**
     * Escape JSON string
     */
    private String escapeJson(String str) {
        if (str == null) return "";
        return str.replace("\\", "\\\\")
                  .replace("\"", "\\\"")
                  .replace("\n", "\\n")
                  .replace("\r", "\\r")
                  .replace("\t", "\\t");
    }
}
