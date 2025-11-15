package service;

import dao.BookingDAO;
import dao.BookingServiceDAO;
import dao.PetServiceDAO;
import dao.DoctorDAO;
import model.Booking;
import model.BookingServiceItem;
import model.PetServiceModel;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * BookingService implementation
 * Xử lý logic nghiệp vụ cho Booking module
 * @author ASUS
 */
public class BookingService {
    
    private static final Logger logger = Logger.getLogger(BookingService.class.getName());
    
    private BookingDAO bookingDAO;
    private BookingServiceDAO bookingServiceDAO;
    private PetServiceDAO petServiceDAO;
    private DoctorDAO doctorDAO;
    
    public BookingService() {
        this.bookingDAO = new BookingDAO();
        this.bookingServiceDAO = new BookingServiceDAO();
        this.petServiceDAO = new PetServiceDAO();
        this.doctorDAO = new DoctorDAO();
    }
    
    // =========================
    // BOOKING OPERATIONS
    // =========================
    
    /**
     * Lấy tất cả booking
     */
    public List<Booking> getAllBookings() {
        return bookingDAO.getAllBookings();
    }
    
    /**
     * Lấy booking theo ID
     */
    public Booking getBookingById(int bookingId) {
        return bookingDAO.getBookingById(bookingId);
    }
    
    /**
     * Lấy booking theo customer ID
     */
    public List<Booking> getBookingsByCustomerId(int customerId) {
        return bookingDAO.getBookingsByCustomerId(customerId);
    }
    
    /**
     * Lấy booking theo staff ID
     */
    public List<Booking> getBookingsByStaffId(int staffId) {
        return bookingDAO.getBookingsByStaffId(staffId);
    }
    
    /**
     * Lấy booking theo trạng thái
     */
    public List<Booking> getBookingsByStatus(String status) {
        return bookingDAO.getBookingsByStatus(status);
    }
    
    /**
     * Tìm kiếm booking
     */
    public List<Booking> searchBookings(String keyword) {
        return bookingDAO.searchBookings(keyword);
    }
    
    /**
     * Tạo booking mới với chi tiết dịch vụ
     */
    public boolean createBooking(Booking booking, List<Integer> serviceIds, List<Integer> quantities) {
        try {
            // 1. Validate dữ liệu đầu vào
            if (!validateBookingData(booking, serviceIds, quantities)) {
                logger.warning("Validation failed for booking creation");
                return false;
            }
            
            // 2. Đảm bảo gán doctor_id nếu thiếu (fallback: chọn 1 bác sĩ đang active)
            if (booking.getDoctorId() <= 0) {
                int fallbackDoctorId = doctorDAO.getAnyActiveDoctorId();
                if (fallbackDoctorId > 0) {
                    booking.setDoctorId(fallbackDoctorId);
                }
            }

            // 3. Tạo booking chính
            boolean bookingCreated = bookingDAO.addBooking(booking);
            if (!bookingCreated) {
                logger.severe("Failed to create main booking");
                return false;
            }
            
            // 4. Tạo chi tiết booking service
            for (int i = 0; i < serviceIds.size(); i++) {
                int serviceId = serviceIds.get(i);
                int quantity = quantities.get(i);
                
                PetServiceModel service = petServiceDAO.getServiceById(serviceId);
                if (service == null || !service.isActive()) {
                    logger.warning("Service with ID " + serviceId + " is not available");
                    continue;
                }
                
                BookingServiceItem bookingService = new BookingServiceItem();
                bookingService.setBookingId(booking.getBookingId());
                bookingService.setServiceId(serviceId);
                bookingService.setQuantity(quantity);
                bookingService.setPrice(service.getPrice());
                bookingService.setNote("");
                
                boolean detailCreated = bookingServiceDAO.addBookingService(bookingService);
                if (!detailCreated) {
                    logger.warning("Failed to create booking service detail for service ID: " + serviceId);
                }
            }
            
            return true;
            
        } catch (Exception e) {
            logger.log(Level.SEVERE, "Error creating booking with services", e);
            return false;
        }
    }
    
    /**
     * Cập nhật booking
     */
    public boolean updateBooking(Booking booking) {
        return bookingDAO.updateBooking(booking);
    }
    
    /**
     * Cập nhật trạng thái booking
     */
    public boolean updateBookingStatus(int bookingId, String status) {
        return bookingDAO.updateBookingStatus(bookingId, status);
    }
    
    /**
     * Hủy booking
     */
    public boolean cancelBooking(int bookingId) {
        // Chỉ cho phép hủy nếu booking đang ở trạng thái pending hoặc confirmed
        Booking booking = getBookingById(bookingId);
        if (booking == null) {
            return false;
        }
        
        String currentStatus = booking.getStatus();
        if (!"pending".equals(currentStatus) && !"confirmed".equals(currentStatus)) {
            logger.warning("Cannot cancel booking with status: " + currentStatus);
            return false;
        }
        
        return updateBookingStatus(bookingId, "cancelled");
    }
    
    /**
     * Xóa booking
     */
    public boolean deleteBooking(int bookingId) {
        try {
            // 1. Xóa tất cả chi tiết booking service trước
            bookingServiceDAO.deleteBookingServicesByBookingId(bookingId);
            
            // 2. Xóa booking chính
            return bookingDAO.deleteBooking(bookingId);
            
        } catch (Exception e) {
            logger.log(Level.SEVERE, "Error deleting booking", e);
            return false;
        }
    }
    
    // =========================
    // BOOKING SERVICE OPERATIONS
    // =========================
    
    /**
     * Lấy chi tiết booking service theo booking ID
     */
    public List<BookingServiceItem> getBookingServices(int bookingId) {
        return bookingServiceDAO.getBookingServicesByBookingId(bookingId);
    }
    
    /**
     * Thêm chi tiết booking service
     */
    public boolean addBookingService(BookingServiceItem bookingService) {
        return bookingServiceDAO.addBookingService(bookingService);
    }
    
    /**
     * Cập nhật chi tiết booking service
     */
    public boolean updateBookingService(BookingServiceItem bookingService) {
        return bookingServiceDAO.updateBookingService(bookingService);
    }
    
    /**
     * Xóa chi tiết booking service
     */
    public boolean deleteBookingService(int bookingServiceId) {
        return bookingServiceDAO.deleteBookingService(bookingServiceId);
    }
    
    // =========================
    // PET SERVICE OPERATIONS
    // =========================
    
    /**
     * Lấy tất cả dịch vụ đang hoạt động
     */
    public List<PetServiceModel> getActiveServices() {
        return petServiceDAO.getActiveServices();
    }
    
    /**
     * Lấy dịch vụ theo loại
     */
    public List<PetServiceModel> getServicesByType(String serviceType) {
        return petServiceDAO.getServicesByType(serviceType);
    }
    
    /**
     * Lấy dịch vụ đang hoạt động theo loại
     */
    public List<PetServiceModel> getActiveServicesByType(String serviceType) {
        return petServiceDAO.getActiveServicesByType(serviceType);
    }
    
    /**
     * Lấy dịch vụ theo ID
     */
    public PetServiceModel getServiceById(int serviceId) {
        return petServiceDAO.getServiceById(serviceId);
    }
    
    /**
     * Tìm kiếm dịch vụ
     */
    public List<PetServiceModel> searchServices(String keyword) {
        return petServiceDAO.searchServices(keyword);
    }
    
    // =========================
    // BUSINESS LOGIC
    // =========================
    
    /**
     * Validate thông tin booking trước khi tạo
     */
    public boolean validateBookingData(Booking booking, List<Integer> serviceIds, List<Integer> quantities) {
        if (booking == null) {
            logger.warning("Booking object is null");
            return false;
        }
        
        if (serviceIds == null || serviceIds.isEmpty()) {
            logger.warning("Service IDs list is null or empty");
            return false;
        }
        
        if (quantities == null || quantities.isEmpty()) {
            logger.warning("Quantities list is null or empty");
            return false;
        }
        
        if (serviceIds.size() != quantities.size()) {
            logger.warning("Service IDs and quantities lists have different sizes");
            return false;
        }
        
        // Validate booking fields
        if (booking.getCustomerId() <= 0) {
            logger.warning("Invalid customer ID");
            return false;
        }
        
        if (booking.getPetId() <= 0) {
            logger.warning("Invalid pet ID");
            return false;
        }
        
        if (booking.getAppointmentStart() == null || booking.getAppointmentEnd() == null) {
            logger.warning("Invalid appointment time");
            return false;
        }
        
        if (booking.getAppointmentStart().after(booking.getAppointmentEnd())) {
            logger.warning("Appointment start time is after end time");
            return false;
        }
        
        // Validate services
        for (int serviceId : serviceIds) {
            PetServiceModel service = petServiceDAO.getServiceById(serviceId);
            if (service == null || !service.isActive()) {
                logger.warning("Service with ID " + serviceId + " is not available");
                return false;
            }
        }
        
        return true;
    }
    
    /**
     * Kiểm tra xem có thể hủy booking không
     */
    public boolean canCancelBooking(int bookingId) {
        Booking booking = getBookingById(bookingId);
        if (booking == null) {
            return false;
        }
        
        String status = booking.getStatus();
        return "pending".equals(status) || "confirmed".equals(status);
    }
    
    /**
     * Tính tổng thời gian thực hiện booking
     */
    public int calculateTotalDuration(List<Integer> serviceIds) {
        int totalDuration = 0;
        
        for (int serviceId : serviceIds) {
            PetServiceModel service = petServiceDAO.getServiceById(serviceId);
            if (service != null) {
                totalDuration += service.getDuration();
            }
        }
        
        return totalDuration;
    }
    
    /**
     * Tính tổng giá trị booking
     */
    public BigDecimal calculateTotalPrice(List<Integer> serviceIds, List<Integer> quantities) {
        BigDecimal totalPrice = BigDecimal.ZERO;
        
        for (int i = 0; i < serviceIds.size(); i++) {
            int serviceId = serviceIds.get(i);
            int quantity = quantities.get(i);
            
            PetServiceModel service = petServiceDAO.getServiceById(serviceId);
            if (service != null) {
                BigDecimal serviceTotal = service.getPrice().multiply(BigDecimal.valueOf(quantity));
                totalPrice = totalPrice.add(serviceTotal);
            }
        }
        
        return totalPrice;
    }
    
    /**
     * Tính tổng giá trị booking từ chi tiết
     */
    public BigDecimal calculateBookingTotal(int bookingId) {
        return bookingServiceDAO.getTotalPriceByBookingId(bookingId);
    }
    
    // =========================
    // STATISTICS
    // =========================
    
    /**
     * Lấy thống kê booking
     */
    public Map<String, Integer> getBookingStatistics() {
        return bookingDAO.getBookingStats();
    }
    
    /**
     * Đếm số lượng booking theo trạng thái
     */
    public int countBookingsByStatus(String status) {
        return bookingDAO.countBookingsByStatus(status);
    }
    
    /**
     * Lấy booking gần nhất
     */
    public List<Booking> getRecentBookings(int limit) {
        return bookingDAO.getRecentBookings(limit);
    }
    
    /**
     * Lấy thống kê dịch vụ
     */
    public Map<String, Integer> getServiceStatistics() {
        return petServiceDAO.getServiceStatistics();
    }
}
