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
    private PetService petService;
    
    public SpaBookingService() {
        this.bookingDAO = new BookingDAO();
        this.bookingServiceDAO = new BookingServiceDAO();
        this.petServiceDAO = new PetServiceDAO();
        this.petService = new PetService();
    }
    
    /**
     * Lấy tất cả dịch vụ Spa đang hoạt động
     */
    public List<model.PetServiceModel> getActiveSpaServices() {
        return petServiceDAO.getActiveServicesByType("spa");
    }
    
    /**
     * Lấy dịch vụ Spa theo ID
     */
    public model.PetServiceModel getSpaServiceById(int serviceId) {
        model.PetServiceModel service = petServiceDAO.getServiceById(serviceId);
        if (service != null && service.isSpaService()) {
            return service;
        }
        return null;
    }
    
    /**
     * Validate dịch vụ Spa có thể đặt lịch
     */
    public boolean validateSpaService(int serviceId) {
        model.PetServiceModel service = getSpaServiceById(serviceId);
        return service != null && service.isActive();
    }
    
    /**
     * Tạo booking Spa từ Cart
     */
    public boolean createSpaBookingFromCart(Customer customer, Map<Integer, Integer> spaServices, 
                                          Timestamp appointmentStart, String note) {
        try {
            // 1. Validate customer và pet
            Pet pet = petService.getPetByCustomerId(customer.getCustomerId());
            if (pet == null) {
                logger.warning("Customer " + customer.getCustomerId() + " chưa có thông tin pet");
                return false;
            }
            
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
            
            // 4. Tạo booking
            Booking booking = new Booking();
            booking.setCustomerId(customer.getCustomerId());
            booking.setPetId(pet.getId());
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
                
                model.PetServiceModel service = petServiceDAO.getServiceById(serviceId);
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
            model.PetServiceModel service = petServiceDAO.getServiceById(serviceId);
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
            
            model.PetServiceModel service = petServiceDAO.getServiceById(serviceId);
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
        Booking booking = bookingDAO.getBookingById(bookingId);
        if (booking == null) {
            return false;
        }
        
        String status = booking.getStatus();
        return "pending".equals(status) || "confirmed".equals(status);
    }
    
    /**
     * Hủy booking Spa
     */
    public boolean cancelSpaBooking(int bookingId) {
        if (!canCancelSpaBooking(bookingId)) {
            logger.warning("Không thể hủy booking ID: " + bookingId);
            return false;
        }
        
        return bookingDAO.updateBookingStatus(bookingId, "cancelled");
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
}
