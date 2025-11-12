package service;

import dao.BookingDAO;
import dao.BookingServiceDAO;
import dao.PetServiceDAO;
import model.Booking;
import model.BookingServiceItem;
import model.Customer;
import model.PetServiceModel;

import java.math.BigDecimal;
import java.sql.Timestamp;
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
     * Kiểm tra slot thời gian đề xuất có khả dụng cho Spa
     * Đã xóa tất cả validation - luôn cho phép đặt lịch
     */
    public boolean isSpaSlotAvailable(java.sql.Timestamp start, List<Integer> serviceIds) {
        // Xóa tất cả validation - cho phép đặt bất kỳ giờ nào, nhiều khách có thể đặt cùng giờ
        return true;
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
     * Đã xóa tất cả validation - luôn cho phép đặt lịch
     */
    public boolean isSpaSlotAvailableForSingle(java.sql.Timestamp start, int serviceId, int quantity) {
        if (start == null || serviceId <= 0 || quantity <= 0) return false;
        // Xóa tất cả validation - cho phép đặt bất kỳ giờ nào, nhiều khách có thể đặt cùng giờ
        return true;
    }

    /**
     * Tạo booking Spa cho một dịch vụ đơn lẻ
     * @return booking_id của booking vừa tạo, hoặc -1 nếu thất bại
     */
    public int createSingleSpaBooking(Customer customer, int petId, int serviceId, int quantity,
                                          java.sql.Timestamp start, String note) {
        try {
            if (!validateSpaService(serviceId) || quantity <= 0) return -1;

            // Tính end (đã xóa kiểm tra khả dụng - cho phép nhiều khách đặt cùng giờ)
            int duration = calculateDurationForSingle(serviceId, quantity);
            java.sql.Timestamp end = new java.sql.Timestamp(start.getTime() + (long) duration * 60 * 1000);

            Booking booking = new Booking();
            booking.setCustomerId(customer.getCustomerId());
            booking.setPetId(petId);
            booking.setAppointmentStart(start);
            booking.setAppointmentEnd(end);
            booking.setStatus("Chưa thanh toán"); // Đổi từ "pending" sang status hợp lệ
            booking.setNote(note != null ? note.trim() : "");
            booking.setCreatedAt(new java.sql.Timestamp(System.currentTimeMillis()));

            boolean created = bookingDAO.addBooking(booking);
            if (!created) {
                logger.warning("Failed to add booking to database");
                return -1;
            }
            if (booking.getBookingId() <= 0) {
                logger.warning("Booking created but booking_id is not set: " + booking.getBookingId());
                return -1;
            }

            PetServiceModel svc = petServiceDAO.getServiceById(serviceId);
            if (svc == null) return -1;

            BookingServiceItem item = new BookingServiceItem();
            item.setBookingId(booking.getBookingId());
            item.setServiceId(serviceId);
            item.setQuantity(quantity);
            item.setPrice(svc.getPrice());
            item.setNote("");

            boolean itemAdded = bookingServiceDAO.addBookingService(item);
            if (!itemAdded) {
                logger.warning("Failed to add booking service item for booking_id: " + booking.getBookingId());
                // Xóa booking đã tạo nếu không thêm được service item
                try {
                    bookingDAO.deleteBooking(booking.getBookingId());
                } catch (Exception ex) {
                    logger.warning("Failed to rollback booking: " + ex.getMessage());
                }
                return -1;
            }
            logger.info("Successfully created booking ID: " + booking.getBookingId() + " for pet ID: " + petId);
            return booking.getBookingId();
        } catch (Exception e) {
            logger.log(java.util.logging.Level.SEVERE, "Lỗi tạo booking đơn lẻ", e);
            e.printStackTrace();
            return -1;
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
            
            // 3. Tính thời gian kết thúc (đã xóa kiểm tra khả dụng - cho phép nhiều khách đặt cùng giờ)
            int totalDuration = calculateTotalDuration(serviceIds);
            Timestamp appointmentEnd = new Timestamp(appointmentStart.getTime() + (totalDuration * 60 * 1000L));
            
            // 4. Tạo booking
            Booking booking = new Booking();
            booking.setCustomerId(customer.getCustomerId());
            booking.setPetId(1); // Tạm thời set petId = 1 để test
            booking.setAppointmentStart(appointmentStart);
            booking.setAppointmentEnd(appointmentEnd);
            booking.setStatus("Chưa thanh toán"); // Đổi từ "pending" sang status hợp lệ
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
        
        // Sắp xếp lại theo thời gian đặt gần nhất (created_at DESC) để đảm bảo booking mới nhất luôn ở đầu
        spaBookings.sort((b1, b2) -> {
            if (b1.getCreatedAt() == null && b2.getCreatedAt() == null) return 0;
            if (b1.getCreatedAt() == null) return 1;
            if (b2.getCreatedAt() == null) return -1;
            return b2.getCreatedAt().compareTo(b1.getCreatedAt()); // DESC: mới nhất trước
        });
        
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
        boolean canCancel = "Chưa thanh toán".equals(status) || "Chờ xác nhận".equals(status) || 
                          "Đã xác nhận".equals(status) || "Đã thanh toán".equals(status) ||
                          "pending".equalsIgnoreCase(status) || "confirmed".equalsIgnoreCase(status);
        
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
            // Cập nhật trạng thái thành "Yêu cầu hoàn tiền" khi khách hủy booking đã thanh toán
            boolean success = bookingDAO.updateBookingStatus(bookingId, "Yêu cầu hoàn tiền");
            
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
     * Hủy booking Spa và gửi email biên lai hoàn tiền
     */
    public boolean cancelSpaBookingWithRefund(Booking booking, Customer customer) {
        if (booking == null) {
            logger.severe("❌ Booking object is null!");
            return false;
        }
        
        int bookingId = booking.getBookingId();
        logger.info("=== BẮT ĐẦU HỦY BOOKING VỚI HOÀN TIỀN ===");
        logger.info("Booking ID: " + bookingId + ", Customer ID: " + customer.getCustomerId());
        logger.info("Booking status hiện tại: '" + booking.getStatus() + "'");
        
        try {
            
            // Bước 2: Cập nhật trạng thái thành "Yêu cầu hoàn tiền"
            logger.info("Bước 2: Cập nhật status...");
            String newStatus = "Yêu cầu hoàn tiền";
            logger.info("Đang cập nhật từ '" + booking.getStatus() + "' sang '" + newStatus + "'");
            
            boolean updateSuccess = false;
            try {
                updateSuccess = bookingDAO.updateBookingStatus(bookingId, newStatus);
                if (updateSuccess) {
                    logger.info("✅ Đã cập nhật status thành công");
                } else {
                    logger.severe("❌ KHÔNG thể cập nhật status booking ID: " + bookingId);
                    logger.severe("Có thể do:");
                    logger.severe("  1. Constraint database chưa cho phép status 'Yêu cầu hoàn tiền'");
                    logger.severe("  2. Booking ID không tồn tại");
                    logger.severe("  3. Lỗi SQL khác");
                    logger.severe("Vui lòng kiểm tra log SQL Error ở trên và chạy file update_booking_status_constraint.sql");
                    return false;
                }
            } catch (Exception updateEx) {
                logger.severe("❌ EXCEPTION khi cập nhật status: " + updateEx.getMessage());
                updateEx.printStackTrace();
                return false;
            }
            
            // Bước 3: Lấy danh sách dịch vụ (không bắt buộc, có thể empty)
            logger.info("Bước 3: Lấy danh sách dịch vụ...");
            List<BookingServiceItem> bookingServices = null;
            BigDecimal totalAmount = BigDecimal.ZERO;
            try {
                bookingServices = bookingServiceDAO.getBookingServicesByBookingId(bookingId);
                if (bookingServices != null) {
                    logger.info("✅ Lấy được " + bookingServices.size() + " dịch vụ");
                    // Tính tổng tiền
                    for (BookingServiceItem bs : bookingServices) {
                        if (bs != null && bs.getPrice() != null) {
                            totalAmount = totalAmount.add(bs.getPrice().multiply(BigDecimal.valueOf(bs.getQuantity())));
                        }
                    }
                    logger.info("Tổng tiền cần hoàn: " + totalAmount);
                } else {
                    logger.warning("⚠️ Không lấy được danh sách dịch vụ (null), nhưng vẫn tiếp tục");
                    bookingServices = new ArrayList<>();
                }
            } catch (Exception serviceEx) {
                logger.warning("⚠️ Lỗi khi lấy dịch vụ (không ảnh hưởng việc hủy): " + serviceEx.getMessage());
                bookingServices = new ArrayList<>();
            }
            
            // Bước 4: Gửi email biên lai hoàn tiền (optional, không làm hủy booking thất bại)
            logger.info("Bước 4: Gửi email hoàn tiền...");
            try {
                if (bookingServices == null) {
                    bookingServices = new ArrayList<>();
                }
                utils.EmailUtils.sendRefundInvoice(customer.getEmail(), customer.getName(), bookingId, booking, bookingServices, totalAmount);
                logger.info("✅ Đã gửi email biên lai hoàn tiền cho: " + customer.getEmail());
            } catch (Exception emailEx) {
                logger.warning("⚠️ Không thể gửi email hoàn tiền (không ảnh hưởng việc hủy): " + emailEx.getMessage());
                // Không throw exception vì booking đã được hủy thành công
            }
            
            logger.info("=== ✅ HỦY BOOKING THÀNH CÔNG ===");
            logger.info("Booking ID " + bookingId + " đã được cập nhật status thành 'Yêu cầu hoàn tiền'");
            return true;
            
        } catch (Exception e) {
            logger.severe("=== ❌ LỖI NGHIÊM TRỌNG KHI HỦY BOOKING ===");
            logger.severe("Booking ID: " + bookingId);
            logger.severe("Exception type: " + e.getClass().getName());
            logger.severe("Exception message: " + e.getMessage());
            logger.severe("Stack trace:");
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
     * Cập nhật status của spa booking
     */
    public boolean updateBookingStatus(int bookingId, String status) {
        try {
            return bookingDAO.updateBookingStatus(bookingId, status);
        } catch (Exception e) {
            logger.severe("Exception khi cập nhật status booking ID " + bookingId + ": " + e.getMessage());
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
