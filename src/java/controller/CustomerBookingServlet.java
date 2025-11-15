package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import service.BookingService;
import dao.BookingDAO;
import dao.DoctorDAO;
import dao.MedicalRecordDAO;
import model.Customer;
import model.Pet;
import model.PetServiceModel;
import model.Booking;

import java.io.IOException;
import java.sql.Timestamp;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Logger;
import service.PetService;

/**
 * Controller cho Customer đặt lịch dịch vụ
 * @author ASUS
 */
@WebServlet("/customer/booking")
public class CustomerBookingServlet extends HttpServlet {
    
    private static final Logger logger = Logger.getLogger(CustomerBookingServlet.class.getName());
    
    private BookingService bookingService;
    private BookingDAO bookingDAO;
    private DoctorDAO doctorDAO;
    private PetService petService;
    private MedicalRecordDAO medicalRecordDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        this.bookingService = new BookingService();
        this.bookingDAO = new BookingDAO();
        this.doctorDAO = new DoctorDAO();
        this.petService = new PetService();
        this.medicalRecordDAO = new MedicalRecordDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        Customer customer = (Customer) session.getAttribute("customer");
        
        if (customer == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        
        try {
            String action = request.getParameter("action");
            
            if (action == null || action.equals("list")) {
                // Hiển thị danh sách dịch vụ
                showServiceList(request, response, customer);
            } else if (action.equals("form")) {
                // Hiển thị form đặt lịch
                showBookingForm(request, response, customer);
            } else if (action.equals("history")) {
                // Hiển thị lịch sử đặt lịch
                showBookingHistory(request, response, customer);
            } else if (action.equals("detail")) {
                // Hiển thị chi tiết booking
                showBookingDetail(request, response, customer);
            }
            
        } catch (Exception e) {
            logger.severe("Error in CustomerBookingServlet doGet: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "Có lỗi xảy ra: " + e.getMessage());
            request.getRequestDispatcher("/error.jsp").forward(request, response);
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        Customer customer = (Customer) session.getAttribute("customer");
        
        if (customer == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        
        try {
            String action = request.getParameter("action");
            
            if (action != null && action.equals("create")) {
                // Tạo booking mới
                createBooking(request, response, customer);
            } else if (action != null && action.equals("cancel")) {
                // Hủy booking
                cancelBooking(request, response, customer);
            } else if (action != null && action.equals("cancel-pending")) {
                // Hủy booking đang chờ thanh toán
                cancelPendingBooking(request, response, customer);
            }
            
        } catch (Exception e) {
            logger.severe("Error in CustomerBookingServlet doPost: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "Có lỗi xảy ra: " + e.getMessage());
            request.getRequestDispatcher("/error.jsp").forward(request, response);
        }
    }
    
    /**
     * Hiển thị danh sách dịch vụ
     */
    private void showServiceList(HttpServletRequest request, HttpServletResponse response, Customer customer) 
            throws ServletException, IOException {
        
        String serviceType = request.getParameter("type");
        List<PetServiceModel> services;
        
        if (serviceType != null && !serviceType.trim().isEmpty()) {
            services = bookingService.getActiveServicesByType(serviceType);
        } else {
            services = bookingService.getActiveServices();
        }
        
        // Lấy thông tin pet của customer
        Pet pet = petService.getPetByCustomerId(customer.getCustomerId());
        
        request.setAttribute("services", services);
        request.setAttribute("pet", pet);
        request.setAttribute("serviceType", serviceType);
        
        request.getRequestDispatcher("/customer/service-list.jsp").forward(request, response);
    }
    
    /**
     * Hiển thị form đặt lịch
     */
    private void showBookingForm(HttpServletRequest request, HttpServletResponse response, Customer customer) 
            throws ServletException, IOException {
        
        String serviceIdsParam = request.getParameter("serviceIds");
        if (serviceIdsParam == null || serviceIdsParam.trim().isEmpty()) {
            request.setAttribute("error", "Vui lòng chọn ít nhất một dịch vụ");
            response.sendRedirect(request.getContextPath() + "/customer/booking");
            return;
        }
        
        // Parse service IDs
        String[] serviceIdStrings = serviceIdsParam.split(",");
        List<Integer> serviceIds = new ArrayList<>();
        List<PetServiceModel> selectedServices = new ArrayList<>();
        
        for (String serviceIdString : serviceIdStrings) {
            try {
                int serviceId = Integer.parseInt(serviceIdString.trim());
                serviceIds.add(serviceId);
                
                PetServiceModel service = bookingService.getServiceById(serviceId);
                if (service != null) {
                    selectedServices.add(service);
                }
            } catch (NumberFormatException e) {
                logger.warning("Invalid service ID: " + serviceIdString);
            }
        }
        
        if (selectedServices.isEmpty()) {
            request.setAttribute("error", "Không tìm thấy dịch vụ được chọn");
            response.sendRedirect(request.getContextPath() + "/customer/booking");
            return;
        }
        
        // Lấy thông tin pet của customer
        Pet pet = petService.getPetByCustomerId(customer.getCustomerId());
        if (pet == null) {
            request.setAttribute("error", "Vui lòng cập nhật thông tin thú cưng trước khi đặt lịch");
            response.sendRedirect(request.getContextPath() + "/user/pet-info.jsp");
            return;
        }
        
        request.setAttribute("selectedServices", selectedServices);
        request.setAttribute("pet", pet);
        request.setAttribute("customer", customer);
        
        request.getRequestDispatcher("/customer/booking-form.jsp").forward(request, response);
    }
    
    /**
     * Hiển thị lịch sử đặt lịch
     */
    private void showBookingHistory(HttpServletRequest request, HttpServletResponse response, Customer customer)
            throws ServletException, IOException {

        // Xử lý success/error messages từ URL parameters
        String success = request.getParameter("success");
        String error = request.getParameter("error");

        if ("payment_completed".equals(success)) {
            request.setAttribute("success", "Thanh toán thành công! Lịch hẹn của bạn đã hoàn thành và sẵn sàng để bác sĩ khám.");
        } else if ("payment_cancelled".equals(error)) {
            request.setAttribute("error", "Thanh toán đã bị hủy. Lịch hẹn đã bị xóa.");
        }

        List<Booking> bookings = bookingService.getBookingsByCustomerId(customer.getCustomerId());

        // Load medical records for completed bookings
        java.util.Map<Integer, model.MedicalRecord> medicalRecordsMap = new java.util.HashMap<>();
        for (Booking booking : bookings) {
            if ("Hoàn thành".equals(booking.getStatus()) || "completed".equals(booking.getStatus())) {
                model.MedicalRecord record = medicalRecordDAO.getByBookingId(booking.getBookingId());
                if (record != null) {
                    medicalRecordsMap.put(booking.getBookingId(), record);
                }
            }
        }

        request.setAttribute("bookings", bookings);
        request.setAttribute("medicalRecordsMap", medicalRecordsMap);

        request.getRequestDispatcher("/customer/booking-history.jsp").forward(request, response);
    }
    
    /**
     * Hiển thị chi tiết booking
     */
    private void showBookingDetail(HttpServletRequest request, HttpServletResponse response, Customer customer) 
            throws ServletException, IOException {
        
        String bookingIdParam = request.getParameter("id");
        if (bookingIdParam == null || bookingIdParam.trim().isEmpty()) {
            request.setAttribute("error", "Không tìm thấy booking");
            response.sendRedirect(request.getContextPath() + "/customer/booking?action=history");
            return;
        }
        
        try {
            int bookingId = Integer.parseInt(bookingIdParam);
            Booking booking = bookingService.getBookingById(bookingId);
            
            if (booking == null || booking.getCustomerId() != customer.getCustomerId()) {
                request.setAttribute("error", "Không tìm thấy booking hoặc bạn không có quyền xem");
                response.sendRedirect(request.getContextPath() + "/customer/booking?action=history");
                return;
            }
            
            // Lấy chi tiết dịch vụ
            List<model.BookingServiceItem> bookingServices = bookingService.getBookingServices(bookingId);
            
            request.setAttribute("booking", booking);
            request.setAttribute("bookingServices", bookingServices);
            
            request.getRequestDispatcher("/customer/booking-detail.jsp").forward(request, response);
            
        } catch (NumberFormatException e) {
            request.setAttribute("error", "ID booking không hợp lệ");
            response.sendRedirect(request.getContextPath() + "/customer/booking?action=history");
        }
    }
    
    /**
     * Tạo booking mới
     */
    private void createBooking(HttpServletRequest request, HttpServletResponse response, Customer customer) 
            throws ServletException, IOException {
        
        try {
            // Lấy thông tin từ form
            String serviceIdsParam = request.getParameter("serviceIds");
            String quantitiesParam = request.getParameter("quantities");
            String appointmentDate = request.getParameter("appointmentDate");
            String appointmentTime = request.getParameter("appointmentTime");
            String note = request.getParameter("note");
            
            // Validate dữ liệu đầu vào
            if (serviceIdsParam == null || quantitiesParam == null || 
                appointmentDate == null || appointmentTime == null) {
                request.setAttribute("error", "Vui lòng điền đầy đủ thông tin");
                response.sendRedirect(request.getContextPath() + "/customer/booking?action=form&serviceIds=" + serviceIdsParam);
                return;
            }
            
            // Parse service IDs và quantities
            String[] serviceIdStrings = serviceIdsParam.split(",");
            String[] quantityStrings = quantitiesParam.split(",");
            
            if (serviceIdStrings.length != quantityStrings.length) {
                request.setAttribute("error", "Dữ liệu dịch vụ không hợp lệ");
                response.sendRedirect(request.getContextPath() + "/customer/booking?action=form&serviceIds=" + serviceIdsParam);
                return;
            }
            
            List<Integer> serviceIds = new ArrayList<>();
            List<Integer> quantities = new ArrayList<>();
            
            for (int i = 0; i < serviceIdStrings.length; i++) {
                try {
                    int serviceId = Integer.parseInt(serviceIdStrings[i].trim());
                    int quantity = Integer.parseInt(quantityStrings[i].trim());
                    
                    if (quantity <= 0) {
                        request.setAttribute("error", "Số lượng phải lớn hơn 0");
                        response.sendRedirect(request.getContextPath() + "/customer/booking?action=form&serviceIds=" + serviceIdsParam);
                        return;
                    }
                    
                    serviceIds.add(serviceId);
                    quantities.add(quantity);
                } catch (NumberFormatException e) {
                    request.setAttribute("error", "Dữ liệu dịch vụ không hợp lệ");
                    response.sendRedirect(request.getContextPath() + "/customer/booking?action=form&serviceIds=" + serviceIdsParam);
                    return;
                }
            }
            
            // Parse thời gian hẹn
            SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm");
            Timestamp appointmentStart;
            try {
                appointmentStart = new Timestamp(dateFormat.parse(appointmentDate + " " + appointmentTime).getTime());
            } catch (ParseException e) {
                request.setAttribute("error", "Thời gian hẹn không hợp lệ");
                response.sendRedirect(request.getContextPath() + "/customer/booking?action=form&serviceIds=" + serviceIdsParam);
                return;
            }
            
            // Tính thời gian kết thúc
            int totalDuration = bookingService.calculateTotalDuration(serviceIds);
            Timestamp appointmentEnd = new Timestamp(appointmentStart.getTime() + (totalDuration * 60 * 1000L));
            
            // Validate: Mỗi thú cưng chỉ được đặt 1 lần trong 1 tuần
            int petId = petService.getPetByCustomerId(customer.getCustomerId()).getId();
            if (hasPetBookedThisWeek(petId, appointmentStart)) {
                request.setAttribute("error", "Thú cưng này đã có lịch hẹn trong tuần này. Vui lòng chọn thời gian khác.");
                response.sendRedirect(request.getContextPath() + "/customer/booking?action=form&serviceIds=" + serviceIdsParam);
                return;
            }

            // Tạo booking object
            Booking booking = new Booking();
            booking.setCustomerId(customer.getCustomerId());
            booking.setPetId(petId);
            booking.setAppointmentStart(appointmentStart);
            booking.setAppointmentEnd(appointmentEnd);
            booking.setStatus("Hoàn thành"); // Đặt thành công mặc định để test
            booking.setNote(note != null ? note.trim() : "");
            booking.setCreatedAt(new Timestamp(System.currentTimeMillis()));

            // Gán bác sĩ mặc định (fallback)
            int fallbackDoctorId = doctorDAO.getAnyActiveDoctorId();
            if (fallbackDoctorId > 0) {
                booking.setDoctorId(fallbackDoctorId);
                logger.info("Assigned fallback doctor ID: " + fallbackDoctorId);
            }

            logger.info("Creating booking with status: " + booking.getStatus());

            // Tạo booking trực tiếp
            boolean success = bookingService.createBooking(booking, serviceIds, quantities);

            logger.info("Booking creation success: " + success + ", booking ID: " + booking.getBookingId() + ", status: " + booking.getStatus());

            if (success) {
                // Lấy booking ID vừa tạo
                int bookingId = booking.getBookingId();

                // Đảm bảo status được set đúng
                booking.setStatus("Hoàn thành");
                logger.info("Updating booking status to: " + booking.getStatus() + " for booking ID: " + booking.getBookingId());
                boolean updateSuccess = bookingDAO.updateBooking(booking);
                logger.info("Booking status update success: " + updateSuccess);

                // Chuyển đến trang lịch sử booking
                response.sendRedirect(request.getContextPath() + "/customer/booking?action=history&success=booking_created");
                return;
            } else {
                request.setAttribute("error", "Đặt lịch thất bại. Vui lòng thử lại.");
                response.sendRedirect(request.getContextPath() + "/customer/booking?action=form&serviceIds=" + serviceIdsParam);
            }
            
        } catch (Exception e) {
            logger.severe("Error creating booking: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "Có lỗi xảy ra khi đặt lịch: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/customer/booking");
        }
    }
    
    /**
     * Hủy booking
     */
    private void cancelBooking(HttpServletRequest request, HttpServletResponse response, Customer customer) 
            throws ServletException, IOException {
        
        String bookingIdParam = request.getParameter("bookingId");
        if (bookingIdParam == null || bookingIdParam.trim().isEmpty()) {
            request.setAttribute("error", "Không tìm thấy booking");
            response.sendRedirect(request.getContextPath() + "/customer/booking?action=history");
            return;
        }
        
        try {
            int bookingId = Integer.parseInt(bookingIdParam);
            
            // Kiểm tra quyền sở hữu
            Booking booking = bookingService.getBookingById(bookingId);
            if (booking == null || booking.getCustomerId() != customer.getCustomerId()) {
                request.setAttribute("error", "Không tìm thấy booking hoặc bạn không có quyền hủy");
                response.sendRedirect(request.getContextPath() + "/customer/booking?action=history");
                return;
            }
            
            // Kiểm tra có thể hủy không
            if (!bookingService.canCancelBooking(bookingId)) {
                request.setAttribute("error", "Không thể hủy booking này");
                response.sendRedirect(request.getContextPath() + "/customer/booking?action=history");
                return;
            }
            
            // Hủy booking
            boolean success = bookingService.cancelBooking(bookingId);
            
            if (success) {
                request.setAttribute("success", "Hủy đặt lịch thành công");
            } else {
                request.setAttribute("error", "Hủy đặt lịch thất bại");
            }
            
            response.sendRedirect(request.getContextPath() + "/customer/booking?action=history");

        } catch (NumberFormatException e) {
            request.setAttribute("error", "ID booking không hợp lệ");
            response.sendRedirect(request.getContextPath() + "/customer/booking?action=history");
        }
    }

    /**
     * Hủy booking đang chờ thanh toán (xóa dữ liệu trong session)
     */
    private void cancelPendingBooking(HttpServletRequest request, HttpServletResponse response, Customer customer)
            throws IOException {

        HttpSession session = request.getSession();

        // Xóa dữ liệu booking đang chờ thanh toán khỏi session
        session.removeAttribute("pendingBooking");
        session.removeAttribute("pendingServiceIds");
        session.removeAttribute("pendingQuantities");
        session.removeAttribute("tempOrderId");

        // Trả về response JSON cho AJAX
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.getWriter().write("{\"success\":true}");
    }

    /**
     * Check if a pet has already booked an appointment this week
     */
    private boolean hasPetBookedThisWeek(int petId, Timestamp appointmentTime) {
        try {
            // Calculate start and end of the week containing the appointment time
            java.util.Calendar cal = java.util.Calendar.getInstance();
            cal.setTime(appointmentTime);

            // Set to Monday of the week
            cal.set(java.util.Calendar.DAY_OF_WEEK, java.util.Calendar.MONDAY);
            cal.set(java.util.Calendar.HOUR_OF_DAY, 0);
            cal.set(java.util.Calendar.MINUTE, 0);
            cal.set(java.util.Calendar.SECOND, 0);
            cal.set(java.util.Calendar.MILLISECOND, 0);
            Timestamp weekStart = new Timestamp(cal.getTimeInMillis());

            // Set to Sunday of the week
            cal.add(java.util.Calendar.DAY_OF_WEEK, 6);
            cal.set(java.util.Calendar.HOUR_OF_DAY, 23);
            cal.set(java.util.Calendar.MINUTE, 59);
            cal.set(java.util.Calendar.SECOND, 59);
            cal.set(java.util.Calendar.MILLISECOND, 999);
            Timestamp weekEnd = new Timestamp(cal.getTimeInMillis());

            // Check if pet has any booking in this week (except cancelled ones)
            List<Booking> existingBookings = bookingDAO.getBookingsByPetIdAndDateRange(petId, weekStart, weekEnd);

            // Filter out cancelled bookings
            for (Booking booking : existingBookings) {
                String status = booking.getStatus();
                if (status != null && !status.contains("hủy") && !status.contains("cancel")) {
                    return true; // Found an active booking this week
                }
            }

            return false; // No active bookings found this week

        } catch (Exception e) {
            logger.severe("Error checking pet booking for week: " + e.getMessage());
            return false; // Allow booking if check fails
        }
    }
}
