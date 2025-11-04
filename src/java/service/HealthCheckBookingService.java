package service;

import dao.BookingDAO;
import dao.BookingServiceDAO;
import dao.PetServiceDAO;
import model.Booking;
import model.BookingServiceItem;
import model.Customer;
import model.Pet;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Service xử lý logic nghiệp vụ cho Health Check Booking
 * Tích hợp với trang đặt lịch khám hiện có
 * @author ASUS
 */
public class HealthCheckBookingService {
    
    private static final Logger logger = Logger.getLogger(HealthCheckBookingService.class.getName());
    
    private BookingDAO bookingDAO;
    private BookingServiceDAO bookingServiceDAO;
    private PetServiceDAO petServiceDAO;
    private PetService petService;
    
    public HealthCheckBookingService() {
        this.bookingDAO = new BookingDAO();
        this.bookingServiceDAO = new BookingServiceDAO();
        this.petServiceDAO = new PetServiceDAO();
        this.petService = new PetService();
    }
    
    /**
     * Lấy tất cả dịch vụ khám sức khỏe đang hoạt động
     */
    public List<model.PetServiceModel> getActiveHealthCheckServices() {
        return petServiceDAO.getActiveServicesByType("health_check");
    }
    
    /**
     * Lấy dịch vụ khám sức khỏe theo ID
     */
    public model.PetServiceModel getHealthCheckServiceById(int serviceId) {
        model.PetServiceModel service = petServiceDAO.getServiceById(serviceId);
        if (service != null && service.isHealthCheckService()) {
            return service;
        }
        return null;
    }
    
    /**
     * Validate dịch vụ khám sức khỏe có thể đặt lịch
     */
    public boolean validateHealthCheckService(int serviceId) {
        model.PetServiceModel service = getHealthCheckServiceById(serviceId);
        return service != null && service.isActive();
    }
    
    /**
     * Tạo booking khám sức khỏe
     */
    public boolean createHealthCheckBooking(Customer customer, int serviceId, 
                                          Timestamp appointmentStart, String note, int doctorId) {
        logger.info("=== BẮT ĐẦU TẠO BOOKING ===");
        logger.info("Customer ID: " + customer.getCustomerId());
        logger.info("Service ID: " + serviceId);
        logger.info("Doctor ID: " + doctorId);
        logger.info("Appointment Start: " + appointmentStart);
        
        try {
            // 1. Validate customer và pet
            logger.info("Bước 1: Kiểm tra thông tin pet...");
            Pet pet = petService.getPetByCustomerId(customer.getCustomerId());
            if (pet == null) {
                logger.severe("❌ FAILED: Customer " + customer.getCustomerId() + " chưa có thông tin pet");
                return false;
            }
            logger.info("✓ Pet found: ID=" + pet.getId() + ", Name=" + pet.getPetName());
            
            // 2. Validate dịch vụ khám sức khỏe
            logger.info("Bước 2: Kiểm tra dịch vụ...");
            if (!validateHealthCheckService(serviceId)) {
                logger.severe("❌ FAILED: Dịch vụ khám sức khỏe ID " + serviceId + " không hợp lệ");
                return false;
            }
            logger.info("✓ Service validated");
            
            // 3. Lấy thông tin dịch vụ
            logger.info("Bước 3: Lấy thông tin dịch vụ...");
            model.PetServiceModel service = petServiceDAO.getServiceById(serviceId);
            if (service == null) {
                logger.severe("❌ FAILED: Không tìm thấy dịch vụ ID: " + serviceId);
                return false;
            }
            logger.info("✓ Service: " + service.getName() + ", Price: " + service.getPrice() + ", Duration: " + service.getDuration());
            
            // 4. Tính thời gian kết thúc
            logger.info("Bước 4: Tính thời gian kết thúc...");
            int duration = service.getDuration();
            Timestamp appointmentEnd = new Timestamp(appointmentStart.getTime() + (duration * 60 * 1000L));
            logger.info("✓ Appointment End: " + appointmentEnd);
            
            // 5. Tạo booking
            logger.info("Bước 5: Tạo booking object...");
            Booking booking = new Booking();
            booking.setCustomerId(customer.getCustomerId());
            booking.setPetId(pet.getId());
            booking.setAppointmentStart(appointmentStart);
            booking.setAppointmentEnd(appointmentEnd);
            booking.setStatus("Chưa thanh toán");
            booking.setNote(note != null ? note.trim() : "");
            booking.setCreatedAt(new Timestamp(System.currentTimeMillis()));
            booking.setDoctorId(doctorId);
            logger.info("✓ Booking object created");
            
            // 6. Lưu booking và chi tiết
            logger.info("Bước 6: Lưu booking vào database...");
            boolean success = createBookingWithService(booking, serviceId);
            
            if (success) {
                logger.info("✅ SUCCESS: Tạo booking khám sức khỏe thành công! Booking ID: " + booking.getBookingId());
            } else {
                logger.severe("❌ FAILED: Không thể lưu booking vào database");
            }
            
            return success;
            
        } catch (Exception e) {
            logger.log(Level.SEVERE, "❌ EXCEPTION: Lỗi khi tạo booking khám sức khỏe", e);
            return false;
        }
    }
    
    /**
     * Tạo booking với dịch vụ khám sức khỏe
     */
    private boolean createBookingWithService(Booking booking, int serviceId) {
        logger.info("  → Bước 6.1: Lưu booking chính vào bảng Booking...");
        try {
            // 1. Tạo booking chính
            boolean bookingCreated = bookingDAO.addBooking(booking);
            if (!bookingCreated) {
                logger.severe("  ❌ Không thể tạo booking chính trong database");
                return false;
            }
            logger.info("  ✓ Booking created with ID: " + booking.getBookingId());
            
            // 2. Tạo chi tiết booking service
            logger.info("  → Bước 6.2: Lấy thông tin dịch vụ để tạo Booking_Service...");
            model.PetServiceModel service = petServiceDAO.getServiceById(serviceId);
            if (service == null) {
                logger.severe("  ❌ Không tìm thấy dịch vụ ID: " + serviceId);
                return false;
            }
            logger.info("  ✓ Service found: " + service.getName());
            
            logger.info("  → Bước 6.3: Tạo booking service item...");
            BookingServiceItem bookingService = new BookingServiceItem();
            bookingService.setBookingId(booking.getBookingId());
            bookingService.setServiceId(serviceId);
            bookingService.setQuantity(1);
            bookingService.setPrice(service.getPrice());
            bookingService.setNote("");
            logger.info("  ✓ BookingService object created: booking_id=" + booking.getBookingId() + ", service_id=" + serviceId);
            
            logger.info("  → Bước 6.4: Lưu booking service vào bảng Booking_Service...");
            boolean detailCreated = bookingServiceDAO.addBookingService(bookingService);
            if (!detailCreated) {
                logger.severe("  ❌ Không thể tạo chi tiết booking service ID: " + serviceId);
                return false;
            }
            logger.info("  ✓ Booking service detail created successfully");
            
            logger.info("  ✓ HOÀN THÀNH: Đã lưu booking và booking service vào database");
            return true;
            
        } catch (Exception e) {
            logger.log(Level.SEVERE, "  ❌ EXCEPTION: Lỗi khi tạo booking với service", e);
            return false;
        }
    }
    
    /**
     * Lấy booking khám sức khỏe của customer
     */
    public List<Booking> getHealthCheckBookingsByCustomerId(int customerId) {
        List<Booking> allBookings = bookingDAO.getBookingsByCustomerId(customerId);
        List<Booking> healthCheckBookings = new ArrayList<>();
        
        for (Booking booking : allBookings) {
            List<BookingServiceItem> bookingServices = bookingServiceDAO.getBookingServicesByBookingId(booking.getBookingId());
            boolean hasHealthCheckService = false;
            
            for (BookingServiceItem bs : bookingServices) {
                if (bs.isHealthCheckService()) {
                    hasHealthCheckService = true;
                    break;
                }
            }
            
            if (hasHealthCheckService) {
                healthCheckBookings.add(booking);
            }
        }
        
        return healthCheckBookings;
    }
    
    /**
     * Kiểm tra xem có thể hủy booking khám sức khỏe không
     */
    public boolean canCancelHealthCheckBooking(int bookingId) {
        Booking booking = bookingDAO.getBookingById(bookingId);
        if (booking == null) {
            return false;
        }
        
        String status = booking.getStatus();
        return "pending".equals(status) || "confirmed".equals(status);
    }
    
    /**
     * Hủy booking khám sức khỏe
     */
    public boolean cancelHealthCheckBooking(int bookingId) {
        if (!canCancelHealthCheckBooking(bookingId)) {
            logger.warning("Không thể hủy booking ID: " + bookingId);
            return false;
        }
        
        return bookingDAO.updateBookingStatus(bookingId, "cancelled");
    }
    
    /**
     * Lấy chi tiết booking khám sức khỏe
     */
    public List<BookingServiceItem> getHealthCheckBookingDetails(int bookingId) {
        List<BookingServiceItem> allDetails = bookingServiceDAO.getBookingServicesByBookingId(bookingId);
        List<BookingServiceItem> healthCheckDetails = new ArrayList<>();
        
        for (BookingServiceItem detail : allDetails) {
            if (detail.isHealthCheckService()) {
                healthCheckDetails.add(detail);
            }
        }
        
        return healthCheckDetails;
    }
    
    /**
     * Lấy lịch sử khám sức khỏe của pet
     */
    public List<Booking> getHealthCheckHistoryByPetId(int petId) {
        List<Booking> allBookings = bookingDAO.getBookingsByPetId(petId);
        List<Booking> healthCheckHistory = new ArrayList<>();
        
        for (Booking booking : allBookings) {
            List<BookingServiceItem> bookingServices = bookingServiceDAO.getBookingServicesByBookingId(booking.getBookingId());
            boolean hasHealthCheckService = false;
            
            for (BookingServiceItem bs : bookingServices) {
                if (bs.isHealthCheckService()) {
                    hasHealthCheckService = true;
                    break;
                }
            }
            
            if (hasHealthCheckService) {
                healthCheckHistory.add(booking);
            }
        }
        
        return healthCheckHistory;
    }
    
    /**
     * Kiểm tra thời gian hẹn có hợp lệ không
     */
    public boolean validateAppointmentTime(Timestamp appointmentStart) {
        // Kiểm tra thời gian hẹn không được trong quá khứ
        Timestamp now = new Timestamp(System.currentTimeMillis());
        if (appointmentStart.before(now)) {
            return false;
        }
        
        // Kiểm tra thời gian hẹn không được quá xa trong tương lai (tối đa 3 tháng)
        long threeMonthsInMillis = 3L * 30L * 24L * 60L * 60L * 1000L;
        Timestamp maxAppointment = new Timestamp(now.getTime() + threeMonthsInMillis);
        if (appointmentStart.after(maxAppointment)) {
            return false;
        }
        
        // Kiểm tra giờ làm việc (8:00 - 17:00)
        LocalDateTime appointmentDateTime = appointmentStart.toLocalDateTime();
        int hour = appointmentDateTime.getHour();
        if (hour < 8 || hour >= 17) {
            return false;
        }
        
        return true;
    }
    
    /**
     * Lấy các khung giờ có sẵn trong ngày
     */
    public List<String> getAvailableTimeSlots(String date) {
        List<String> availableSlots = new ArrayList<>();
        
        // Tạo danh sách khung giờ mặc định
        String[] timeSlots = {
            "08:00", "09:00", "10:00", "11:00", 
            "14:00", "15:00", "16:00", "17:00"
        };
        
        for (String timeSlot : timeSlots) {
            // TODO: Kiểm tra xem khung giờ này có bị trùng với booking khác không
            // Hiện tại trả về tất cả khung giờ
            availableSlots.add(timeSlot);
        }
        
        return availableSlots;
    }
}
