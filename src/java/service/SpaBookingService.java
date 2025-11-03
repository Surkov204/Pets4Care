package service;

import dao.BookingDAO;
import dao.BookingServiceDAO;
import dao.PetServiceDAO;
import model.Booking;
import model.BookingServiceItem;
import model.Customer;
import model.Pet;
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
 * Service xử lý logic nghiệp vụ cho Spa Booking
 * Tích hợp với Cart hiện có
 * @author ASUS
 */
public class SpaBookingService {
    
    private static final Logger logger = Logger.getLogger(SpaBookingService.class.getName());
    
    private BookingDAO bookingDAO;
    private BookingServiceDAO bookingServiceDAO;
    private PetServiceDAO petServiceDAO;
    
    public SpaBookingService() {
        this.bookingDAO = new BookingDAO();
        this.bookingServiceDAO = new BookingServiceDAO();
        this.petServiceDAO = new PetServiceDAO();
    }

    /**
     * Kiểm tra slot thời gian đề xuất có khả dụng cho Spa (không trùng các lịch spa khác)
     * Áp dụng ràng buộc giờ làm việc 08:00 - 18:00
     */
    public boolean isSpaSlotAvailable(java.sql.Timestamp start, List<Integer> serviceIds) {
        if (start == null || serviceIds == null || serviceIds.isEmpty()) return false;

        // Ràng buộc giờ làm việc 08:00 - 18:00
        java.util.Calendar cal = java.util.Calendar.getInstance();
        cal.setTimeInMillis(start.getTime());
        int hour = cal.get(java.util.Calendar.HOUR_OF_DAY);
        int minute = cal.get(java.util.Calendar.MINUTE);
        if (hour < 8 || hour > 18 || minute < 0 || minute > 59) return false;

        int totalDuration = calculateTotalDuration(serviceIds);
        java.sql.Timestamp end = new java.sql.Timestamp(start.getTime() + (long) totalDuration * 60 * 1000);

        // End vẫn phải nằm trong khung 08:00 - 18:59 (cho phép kết thúc đúng 18:00)
        java.util.Calendar calEnd = java.util.Calendar.getInstance();
        calEnd.setTimeInMillis(end.getTime());
        int endHour = calEnd.get(java.util.Calendar.HOUR_OF_DAY);
        int endMinute = calEnd.get(java.util.Calendar.MINUTE);
        if (endHour > 18 || (endHour == 18 && endMinute > 0)) return false;

        return bookingDAO.isSpaTimeSlotAvailable(start, end);
    }

    /**
     * Tính tổng thời lượng cho 1 dịch vụ với số lượng quantity (mặc định nhân theo quantity)
     */
    public int calculateDurationForSingle(int serviceId, int quantity) {
        PetServiceModel service = petServiceDAO.getServiceById(serviceId);
        if (service == null || quantity <= 0) return 0;
        int perUnit = service.getDuration();
        long total = (long) perUnit * (long) quantity;
        return (int) Math.min(Integer.MAX_VALUE, total);
    }

    /**
     * Kiểm tra khả dụng slot cho 1 dịch vụ đơn lẻ
     */
    public boolean isSpaSlotAvailableForSingle(java.sql.Timestamp start, int serviceId, int quantity) {
        if (start == null || serviceId <= 0 || quantity <= 0) return false;

        // Ràng buộc 08:00 - 18:00 và phút 0-59
        java.util.Calendar cal = java.util.Calendar.getInstance();
        cal.setTimeInMillis(start.getTime());
        int hour = cal.get(java.util.Calendar.HOUR_OF_DAY);
        int minute = cal.get(java.util.Calendar.MINUTE);
        if (hour < 8 || hour > 18 || minute < 0 || minute > 59) return false;

        int duration = calculateDurationForSingle(serviceId, quantity);
        java.sql.Timestamp end = new java.sql.Timestamp(start.getTime() + (long) duration * 60 * 1000);

        java.util.Calendar calEnd = java.util.Calendar.getInstance();
        calEnd.setTimeInMillis(end.getTime());
        int endHour = calEnd.get(java.util.Calendar.HOUR_OF_DAY);
        int endMinute = calEnd.get(java.util.Calendar.MINUTE);
        if (endHour > 18 || (endHour == 18 && endMinute > 0)) return false;

        return bookingDAO.isSpaTimeSlotAvailable(start, end);
    }

    /**
     * Tạo booking Spa cho một dịch vụ đơn lẻ
     */
    public boolean createSingleSpaBooking(Customer customer, int petId, int serviceId, int quantity,
                                          java.sql.Timestamp start, String note) {
        try {
            if (!validateSpaService(serviceId) || quantity <= 0) return false;

            // Tính end và kiểm tra khả dụng
            int duration = calculateDurationForSingle(serviceId, quantity);
            java.sql.Timestamp end = new java.sql.Timestamp(start.getTime() + (long) duration * 60 * 1000);
            if (!bookingDAO.isSpaTimeSlotAvailable(start, end)) return false;

            Booking booking = new Booking();
            booking.setCustomerId(customer.getCustomerId());
            booking.setPetId(petId);
            booking.setAppointmentStart(start);
            booking.setAppointmentEnd(end);
            booking.setStatus("pending");
            booking.setNote(note != null ? note.trim() : "");
            booking.setCreatedAt(new java.sql.Timestamp(System.currentTimeMillis()));

            boolean created = bookingDAO.addBooking(booking);
            if (!created) return false;

            PetServiceModel svc = petServiceDAO.getServiceById(serviceId);
            if (svc == null) return false;

            BookingServiceItem item = new BookingServiceItem();
            item.setBookingId(booking.getBookingId());
            item.setServiceId(serviceId);
            item.setQuantity(quantity);
            item.setPrice(svc.getPrice());
            item.setNote("");

            return bookingServiceDAO.addBookingService(item);
        } catch (Exception e) {
            logger.log(java.util.logging.Level.SEVERE, "Lỗi tạo booking đơn lẻ", e);
            return false;
        }
    }
    
    /**
     * Lấy tất cả dịch vụ Spa đang hoạt động
     */
    public List<PetServiceModel> getActiveSpaServices() {
        return petServiceDAO.getActiveServicesByType("spa");
    }
    
    /**
     * Lấy dịch vụ Spa theo ID
     */
    public PetServiceModel getSpaServiceById(int serviceId) {
        PetServiceModel service = petServiceDAO.getServiceById(serviceId);
        if (service != null && service.isSpaService()) {
            return service;
        }
        return null;
    }
    
    /**
     * Validate dịch vụ Spa có thể đặt lịch
     */
    public boolean validateSpaService(int serviceId) {
        PetServiceModel service = getSpaServiceById(serviceId);
        return service != null && service.isActive();
    }
    
    /**
     * Tạo booking Spa từ Cart
     */
    public boolean createSpaBookingFromCart(Customer customer, Map<Integer, Integer> spaServices, 
                                          Timestamp appointmentStart, String note) {
        try {
            // 1. Validate customer và pet
            // Tạm thời bỏ qua validation pet để test
            // Pet pet = petService.getPetByCustomerId(customer.getCustomerId());
            // if (pet == null) {
            //     logger.warning("Customer " + customer.getCustomerId() + " chưa có thông tin pet");
            //     return false;
            // }
            
            // 2. Validate dịch vụ Spa
            List<Integer> serviceIds = new ArrayList<>();
            List<Integer> quantities = new ArrayList<>();
            
            for (Map.Entry<Integer, Integer> entry : spaServices.entrySet()) {
                int serviceId = entry.getKey();
                int quantity = entry.getValue();
                
                if (!validateSpaService(serviceId)) {
                    logger.warning("Dịch vụ Spa ID " + serviceId + " không hợp lệ");
                    continue;
                }
                
                serviceIds.add(serviceId);
                quantities.add(quantity);
            }
            
            if (serviceIds.isEmpty()) {
                logger.warning("Không có dịch vụ Spa hợp lệ nào");
                return false;
            }
            
            // 3. Tính thời gian kết thúc
            int totalDuration = calculateTotalDuration(serviceIds);
            Timestamp appointmentEnd = new Timestamp(appointmentStart.getTime() + (totalDuration * 60 * 1000L));

            // 3.1 Kiểm tra khả dụng khung giờ
            if (!isSpaSlotAvailable(appointmentStart, serviceIds)) {
                logger.warning("Khung giờ spa không khả dụng hoặc ngoài giờ làm việc");
                return false;
            }
            
            // 4. Tạo booking
            Booking booking = new Booking();
            booking.setCustomerId(customer.getCustomerId());
            booking.setPetId(1); // Tạm thời set petId = 1 để test
            booking.setAppointmentStart(appointmentStart);
            booking.setAppointmentEnd(appointmentEnd);
            booking.setStatus("pending");
            booking.setNote(note != null ? note.trim() : "");
            booking.setCreatedAt(new Timestamp(System.currentTimeMillis()));
            
            // 5. Lưu booking và chi tiết
            boolean success = createBookingWithServices(booking, serviceIds, quantities);
            
            if (success) {
                logger.info("Tạo booking Spa thành công cho customer " + customer.getCustomerId());
            }
            
            return success;
            
        } catch (Exception e) {
            logger.log(Level.SEVERE, "Lỗi khi tạo booking Spa từ Cart", e);
            return false;
        }
    }
    
    /**
     * Tạo booking với chi tiết dịch vụ
     */
    private boolean createBookingWithServices(Booking booking, List<Integer> serviceIds, List<Integer> quantities) {
        try {
            // 1. Tạo booking chính
            boolean bookingCreated = bookingDAO.addBooking(booking);
            if (!bookingCreated) {
                logger.severe("Không thể tạo booking chính");
                return false;
            }
            
            // 2. Tạo chi tiết booking service
            for (int i = 0; i < serviceIds.size(); i++) {
                int serviceId = serviceIds.get(i);
                int quantity = quantities.get(i);
                
                PetServiceModel service = petServiceDAO.getServiceById(serviceId);
                if (service == null) {
                    logger.warning("Không tìm thấy dịch vụ ID: " + serviceId);
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
                    logger.warning("Không thể tạo chi tiết booking service ID: " + serviceId);
                }
            }
            
            return true;
            
        } catch (Exception e) {
            logger.log(Level.SEVERE, "Lỗi khi tạo booking với services", e);
            return false;
        }
    }
    
    /**
     * Tính tổng thời gian thực hiện
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
     * Tính tổng giá trị booking Spa
     */
    public BigDecimal calculateSpaBookingTotal(List<Integer> serviceIds, List<Integer> quantities) {
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
     * Lấy booking Spa của customer
     */
    public List<Booking> getSpaBookingsByCustomerId(int customerId) {
        List<Booking> allBookings = bookingDAO.getBookingsByCustomerId(customerId);
        List<Booking> spaBookings = new ArrayList<>();
        
        for (Booking booking : allBookings) {
            List<BookingServiceItem> bookingServices = bookingServiceDAO.getBookingServicesByBookingId(booking.getBookingId());
            boolean hasSpaService = false;
            
            for (BookingServiceItem bs : bookingServices) {
                if (bs.isSpaService()) {
                    hasSpaService = true;
                    break;
                }
            }
            
            if (hasSpaService) {
                spaBookings.add(booking);
            }
        }
        
        return spaBookings;
    }
    
    /**
     * Kiểm tra xem có thể hủy booking Spa không
     */
    public boolean canCancelSpaBooking(int bookingId) {
        logger.info("=== DEBUG canCancelSpaBooking for ID: " + bookingId + " ===");
        
        Booking booking = bookingDAO.getBookingById(bookingId);
        if (booking == null) {
            logger.warning("Booking ID " + bookingId + " không tồn tại trong database");
            return false;
        }
        
        String status = booking.getStatus();
        boolean canCancel = "pending".equals(status) || "confirmed".equals(status);
        
        logger.info("Booking ID " + bookingId + " details:");
        logger.info("  - Status: '" + status + "'");
        logger.info("  - Status length: " + (status != null ? status.length() : "null"));
        logger.info("  - Status equals 'pending': " + "pending".equals(status));
        logger.info("  - Status equals 'confirmed': " + "confirmed".equals(status));
        logger.info("  - Can cancel: " + canCancel);
        logger.info("  - Customer ID: " + booking.getCustomerId());
        logger.info("  - Appointment: " + booking.getAppointmentStart());
        
        return canCancel;
    }
    
    /**
     * Hủy booking Spa - Phiên bản đơn giản
     */
    public boolean cancelSpaBooking(int bookingId) {
        logger.info("Bắt đầu hủy booking ID: " + bookingId);
        
        try {
            // Thử cập nhật trực tiếp trạng thái thành cancelled
            boolean success = bookingDAO.updateBookingStatus(bookingId, "cancelled");
            
            if (success) {
                logger.info("Hủy booking ID " + bookingId + " thành công");
            } else {
                logger.severe("Hủy booking ID " + bookingId + " thất bại - không thể cập nhật database");
            }
            
            return success;
            
        } catch (Exception e) {
            logger.severe("Exception khi hủy booking ID " + bookingId + ": " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Lấy chi tiết booking Spa
     */
    public List<BookingServiceItem> getSpaBookingDetails(int bookingId) {
        List<BookingServiceItem> allDetails = bookingServiceDAO.getBookingServicesByBookingId(bookingId);
        List<BookingServiceItem> spaDetails = new ArrayList<>();
        
        for (BookingServiceItem detail : allDetails) {
            if (detail.isSpaService()) {
                spaDetails.add(detail);
            }
        }
        
        return spaDetails;
    }
    
    /**
     * Cập nhật spa booking
     */
    public boolean updateSpaBooking(int bookingId, Timestamp appointmentStart, String note) {
        try {
            return bookingDAO.updateBooking(bookingId, appointmentStart, note);
        } catch (Exception e) {
            logger.severe("Exception khi cập nhật booking ID " + bookingId + ": " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Lấy spa booking theo ID
     */
    public Booking getSpaBookingById(int bookingId) {
        try {
            return bookingDAO.getBookingById(bookingId);
        } catch (Exception e) {
            logger.severe("Exception khi lấy spa booking ID " + bookingId + ": " + e.getMessage());
            e.printStackTrace();
            return null;
        }
    }
    
    /**
     * Xóa spa booking khỏi database
     */
    public boolean deleteSpaBooking(int bookingId) {
        try {
            // Xóa booking services trước (foreign key constraint)
            boolean deleteServices = bookingServiceDAO.deleteBookingServicesByBookingId(bookingId);
            if (!deleteServices) {
                logger.warning("Failed to delete booking services for booking ID: " + bookingId);
            }
            
            // Xóa booking
            boolean deleteBooking = bookingDAO.deleteBooking(bookingId);
            if (deleteBooking) {
                logger.info("Successfully deleted spa booking ID: " + bookingId);
            }
            return deleteBooking;
        } catch (Exception e) {
            logger.severe("Exception khi xóa spa booking ID " + bookingId + ": " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
}
