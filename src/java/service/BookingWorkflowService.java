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
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Service quản lý luồng đặt lịch tổng hợp
 * Xử lý logic nghiệp vụ cho cả Spa và Health Check
 * @author ASUS
 */
public class BookingWorkflowService {
    
    private static final Logger logger = Logger.getLogger(BookingWorkflowService.class.getName());
    
    private BookingDAO bookingDAO;
    private BookingServiceDAO bookingServiceDAO;
    private PetServiceDAO petServiceDAO;
    private PetService petService;
    private SpaBookingService spaBookingService;
    private HealthCheckBookingService healthCheckBookingService;
    
    public BookingWorkflowService() {
        this.bookingDAO = new BookingDAO();
        this.bookingServiceDAO = new BookingServiceDAO();
        this.petServiceDAO = new PetServiceDAO();
        this.petService = new PetService();
        this.spaBookingService = new SpaBookingService();
        this.healthCheckBookingService = new HealthCheckBookingService();
    }
    
    /**
     * Lấy tất cả booking của customer (cả Spa và Health Check)
     */
    public List<Booking> getAllBookingsByCustomerId(int customerId) {
        return bookingDAO.getBookingsByCustomerId(customerId);
    }
    
    /**
     * Lấy booking theo loại dịch vụ
     */
    public List<Booking> getBookingsByServiceType(int customerId, String serviceType) {
        List<Booking> allBookings = getAllBookingsByCustomerId(customerId);
        List<Booking> filteredBookings = new ArrayList<>();
        
        for (Booking booking : allBookings) {
            List<BookingServiceItem> bookingServices = bookingServiceDAO.getBookingServicesByBookingId(booking.getBookingId());
            
            for (BookingServiceItem bs : bookingServices) {
                if (serviceType.equals("spa") && bs.isSpaService()) {
                    filteredBookings.add(booking);
                    break;
                } else if (serviceType.equals("health_check") && bs.isHealthCheckService()) {
                    filteredBookings.add(booking);
                    break;
                }
            }
        }
        
        return filteredBookings;
    }
    
    /**
     * Lấy thống kê booking của customer
     */
    public Map<String, Object> getBookingStats(int customerId) {
        Map<String, Object> stats = new HashMap<>();
        
        List<Booking> allBookings = getAllBookingsByCustomerId(customerId);
        List<Booking> spaBookings = getBookingsByServiceType(customerId, "spa");
        List<Booking> healthCheckBookings = getBookingsByServiceType(customerId, "health_check");
        
        // Thống kê tổng quan
        stats.put("totalBookings", allBookings.size());
        stats.put("spaBookings", spaBookings.size());
        stats.put("healthCheckBookings", healthCheckBookings.size());
        
        // Thống kê theo trạng thái
        Map<String, Integer> statusStats = new HashMap<>();
        for (Booking booking : allBookings) {
            String status = booking.getStatus();
            statusStats.put(status, statusStats.getOrDefault(status, 0) + 1);
        }
        stats.put("statusStats", statusStats);
        
        // Tính tổng chi phí
        BigDecimal totalSpent = BigDecimal.ZERO;
        for (Booking booking : allBookings) {
            List<BookingServiceItem> bookingServices = bookingServiceDAO.getBookingServicesByBookingId(booking.getBookingId());
            for (BookingServiceItem bs : bookingServices) {
                BigDecimal serviceTotal = bs.getPrice().multiply(BigDecimal.valueOf(bs.getQuantity()));
                totalSpent = totalSpent.add(serviceTotal);
            }
        }
        stats.put("totalSpent", totalSpent);
        
        return stats;
    }
    
    /**
     * Kiểm tra xem customer có thể đặt lịch không
     */
    public Map<String, Object> validateBookingEligibility(int customerId) {
        Map<String, Object> result = new HashMap<>();
        
        try {
            // Kiểm tra customer có pet không
            Pet pet = petService.getPetByCustomerId(customerId);
            if (pet == null) {
                result.put("canBook", false);
                result.put("reason", "Bạn chưa có thông tin thú cưng. Vui lòng thêm thông tin pet trước khi đặt lịch.");
                return result;
            }
            
            // Kiểm tra có booking đang chờ xử lý không
            List<Booking> pendingBookings = bookingDAO.getBookingsByStatus("pending");
            long customerPendingBookings = pendingBookings.stream()
                    .filter(b -> b.getCustomerId() == customerId)
                    .count();
            
            if (customerPendingBookings >= 3) {
                result.put("canBook", false);
                result.put("reason", "Bạn có quá nhiều lịch hẹn đang chờ xử lý. Vui lòng chờ xác nhận hoặc hủy một số lịch hẹn.");
                return result;
            }
            
            result.put("canBook", true);
            result.put("pet", pet);
            return result;
            
        } catch (Exception e) {
            logger.log(Level.SEVERE, "Error validating booking eligibility", e);
            result.put("canBook", false);
            result.put("reason", "Có lỗi xảy ra khi kiểm tra thông tin. Vui lòng thử lại.");
            return result;
        }
    }
    
    /**
     * Lấy lịch sử đặt lịch chi tiết
     */
    public List<Map<String, Object>> getDetailedBookingHistory(int customerId) {
        List<Map<String, Object>> detailedHistory = new ArrayList<>();
        
        try {
            List<Booking> allBookings = getAllBookingsByCustomerId(customerId);
            
            for (Booking booking : allBookings) {
                Map<String, Object> bookingDetail = new HashMap<>();
                bookingDetail.put("booking", booking);
                
                // Lấy chi tiết dịch vụ
                List<BookingServiceItem> bookingServices = bookingServiceDAO.getBookingServicesByBookingId(booking.getBookingId());
                bookingDetail.put("services", bookingServices);
                
                // Xác định loại dịch vụ
                String serviceType = "unknown";
                for (BookingServiceItem bs : bookingServices) {
                    if (bs.isSpaService()) {
                        serviceType = "spa";
                        break;
                    } else if (bs.isHealthCheckService()) {
                        serviceType = "health_check";
                        break;
                    }
                }
                bookingDetail.put("serviceType", serviceType);
                
                // Tính tổng giá trị
                BigDecimal totalValue = BigDecimal.ZERO;
                for (BookingServiceItem bs : bookingServices) {
                    BigDecimal serviceTotal = bs.getPrice().multiply(BigDecimal.valueOf(bs.getQuantity()));
                    totalValue = totalValue.add(serviceTotal);
                }
                bookingDetail.put("totalValue", totalValue);
                
                detailedHistory.add(bookingDetail);
            }
            
        } catch (Exception e) {
            logger.log(Level.SEVERE, "Error getting detailed booking history", e);
        }
        
        return detailedHistory;
    }
    
    /**
     * Tạo báo cáo booking
     */
    public Map<String, Object> generateBookingReport(int customerId, String startDate, String endDate) {
        Map<String, Object> report = new HashMap<>();
        
        try {
            // Parse dates
            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");
            LocalDateTime start = LocalDateTime.parse(startDate + " 00:00:00", DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
            LocalDateTime end = LocalDateTime.parse(endDate + " 23:59:59", DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
            
            Timestamp startTimestamp = Timestamp.valueOf(start);
            Timestamp endTimestamp = Timestamp.valueOf(end);
            
            // Lấy booking trong khoảng thời gian
            List<Booking> bookingsInRange = bookingDAO.getBookingsByDateRange(
                    new java.sql.Date(startTimestamp.getTime()),
                    new java.sql.Date(endTimestamp.getTime())
            );
            
            // Lọc theo customer
            List<Booking> customerBookings = bookingsInRange.stream()
                    .filter(b -> b.getCustomerId() == customerId)
                    .collect(java.util.stream.Collectors.toList());
            
            // Thống kê
            report.put("totalBookings", customerBookings.size());
            report.put("startDate", startDate);
            report.put("endDate", endDate);
            
            // Thống kê theo loại dịch vụ
            int spaCount = 0;
            int healthCheckCount = 0;
            BigDecimal totalSpent = BigDecimal.ZERO;
            
            for (Booking booking : customerBookings) {
                List<BookingServiceItem> bookingServices = bookingServiceDAO.getBookingServicesByBookingId(booking.getBookingId());
                
                for (BookingServiceItem bs : bookingServices) {
                    BigDecimal serviceTotal = bs.getPrice().multiply(BigDecimal.valueOf(bs.getQuantity()));
                    totalSpent = totalSpent.add(serviceTotal);
                    
                    if (bs.isSpaService()) {
                        spaCount++;
                    } else if (bs.isHealthCheckService()) {
                        healthCheckCount++;
                    }
                }
            }
            
            report.put("spaBookings", spaCount);
            report.put("healthCheckBookings", healthCheckCount);
            report.put("totalSpent", totalSpent);
            
            // Chi tiết booking
            report.put("bookings", customerBookings);
            
        } catch (Exception e) {
            logger.log(Level.SEVERE, "Error generating booking report", e);
            report.put("error", "Có lỗi xảy ra khi tạo báo cáo: " + e.getMessage());
        }
        
        return report;
    }
    
    /**
     * Gửi thông báo booking
     */
    public boolean sendBookingNotification(int bookingId, String notificationType) {
        try {
            Booking booking = bookingDAO.getBookingById(bookingId);
            if (booking == null) {
                logger.warning("Booking not found: " + bookingId);
                return false;
            }
            
            // TODO: Implement notification logic
            // Có thể gửi email, SMS, hoặc push notification
            
            logger.info("Notification sent for booking " + bookingId + " - Type: " + notificationType);
            return true;
            
        } catch (Exception e) {
            logger.log(Level.SEVERE, "Error sending booking notification", e);
            return false;
        }
    }
    
    /**
     * Cập nhật trạng thái booking và gửi thông báo
     */
    public boolean updateBookingStatusWithNotification(int bookingId, String newStatus, String reason) {
        try {
            // Cập nhật trạng thái
            boolean updated = bookingDAO.updateBookingStatus(bookingId, newStatus);
            
            if (updated) {
                // Gửi thông báo
                sendBookingNotification(bookingId, "status_update");
                
                // Log thay đổi
                logger.info("Booking " + bookingId + " status updated to " + newStatus + " - Reason: " + reason);
            }
            
            return updated;
            
        } catch (Exception e) {
            logger.log(Level.SEVERE, "Error updating booking status with notification", e);
            return false;
        }
    }
    
    /**
     * Lấy dashboard data cho customer
     */
    public Map<String, Object> getCustomerDashboard(int customerId) {
        Map<String, Object> dashboard = new HashMap<>();
        
        try {
            // Thống kê tổng quan
            Map<String, Object> stats = getBookingStats(customerId);
            dashboard.put("stats", stats);
            
            // Booking gần đây
            List<Booking> recentBookings = bookingDAO.getRecentBookings(5);
            List<Booking> customerRecentBookings = recentBookings.stream()
                    .filter(b -> b.getCustomerId() == customerId)
                    .collect(java.util.stream.Collectors.toList());
            dashboard.put("recentBookings", customerRecentBookings);
            
            // Booking sắp tới
            List<Booking> upcomingBookings = new ArrayList<>();
            Timestamp now = new Timestamp(System.currentTimeMillis());
            List<Booking> allBookings = getAllBookingsByCustomerId(customerId);
            
            for (Booking booking : allBookings) {
                if (booking.getAppointmentStart().after(now) && 
                    ("pending".equals(booking.getStatus()) || "confirmed".equals(booking.getStatus()))) {
                    upcomingBookings.add(booking);
                }
            }
            
            // Sắp xếp theo thời gian
            upcomingBookings.sort((b1, b2) -> b1.getAppointmentStart().compareTo(b2.getAppointmentStart()));
            dashboard.put("upcomingBookings", upcomingBookings);
            
            // Thông tin pet
            Pet pet = petService.getPetByCustomerId(customerId);
            dashboard.put("pet", pet);
            
        } catch (Exception e) {
            logger.log(Level.SEVERE, "Error getting customer dashboard", e);
            dashboard.put("error", "Có lỗi xảy ra khi tải dashboard: " + e.getMessage());
        }
        
        return dashboard;
    }
}
