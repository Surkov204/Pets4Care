package dao;

import model.Booking;
import java.util.List;

public interface IBookingDAO {
    
    // Lấy tất cả booking
    List<Booking> getAllBookings();
    
    // Lấy booking theo ID
    Booking getBookingById(int bookingId);
    
    // Lấy booking theo customer ID
    List<Booking> getBookingsByCustomerId(int customerId);
    
    // Lấy booking theo staff ID
    List<Booking> getBookingsByStaffId(int staffId);
    
    // Lấy booking theo status
    List<Booking> getBookingsByStatus(String status);
    
    // Lấy booking theo ngày
    List<Booking> getBookingsByDate(java.sql.Date date);
    
    // Lấy booking theo khoảng thời gian
    List<Booking> getBookingsByDateRange(java.sql.Date startDate, java.sql.Date endDate);
    
    // Tìm kiếm booking
    List<Booking> searchBookings(String keyword);
    
    // Thêm booking mới
    boolean addBooking(Booking booking);
    
    // Cập nhật booking
    boolean updateBooking(Booking booking);
    
    // Cập nhật status của booking
    boolean updateBookingStatus(int bookingId, String status);
    
    // Xóa booking
    boolean deleteBooking(int bookingId);
    
    // Đếm số lượng booking theo status
    int countBookingsByStatus(String status);
    
    // Lấy booking gần nhất
    List<Booking> getRecentBookings(int limit);
    
    // Lấy thống kê booking
    java.util.Map<String, Integer> getBookingStats();
}
