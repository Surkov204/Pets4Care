package dao;

import model.BoardingBooking;
import utils.DBConnection;

import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Logger;

/**
 * DAO cho BoardingBooking
 * Xử lý các thao tác database cho đặt phòng lưu trú
 * @author ASUS
 */
public class BoardingBookingDAO {
    
    private static final Logger logger = Logger.getLogger(BoardingBookingDAO.class.getName());
    
    // SQL queries
    private static final String INSERT_BOARDING_BOOKING = 
        "INSERT INTO dbo.boarding_bookings (customer_id, room_type, price_per_day, boarding_days, " +
        "check_in_date, check_out_date, check_in_time, check_out_time, pet_info, special_notes, " +
        "emergency_phone1, emergency_phone2, total_price, status, created_at, updated_at) " +
        "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
    
    private static final String SELECT_BY_CUSTOMER_ID = 
        "SELECT * FROM dbo.boarding_bookings WHERE customer_id = ? ORDER BY created_at DESC";
    
    private static final String SELECT_BY_ID = 
        "SELECT * FROM dbo.boarding_bookings WHERE booking_id = ?";
    
    private static final String UPDATE_STATUS = 
        "UPDATE dbo.boarding_bookings SET status = ?, updated_at = ? WHERE booking_id = ?";
    
    private static final String DELETE_BOOKING = 
        "DELETE FROM dbo.boarding_bookings WHERE booking_id = ?";
    
    /**
     * Tạo bảng boarding_bookings nếu chưa tồn tại
     */
    public void createTableIfNotExists() {
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement()) {
            
            // Kiểm tra bảng có tồn tại không
            String checkTableSQL = 
                "SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES " +
                "WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'boarding_bookings'";
            
            try (ResultSet rs = stmt.executeQuery(checkTableSQL)) {
                if (rs.next() && rs.getInt(1) == 0) {
                    // Bảng chưa tồn tại, tạo mới
                    String createTableSQL = 
                        "CREATE TABLE dbo.boarding_bookings (" +
                        "booking_id INT IDENTITY(1,1) PRIMARY KEY," +
                        "customer_id INT NOT NULL," +
                        "room_type NVARCHAR(100) NOT NULL," +
                        "price_per_day DECIMAL(10,2) NOT NULL," +
                        "boarding_days INT NOT NULL," +
                        "check_in_date DATE NOT NULL," +
                        "check_out_date DATE NOT NULL," +
                        "check_in_time NVARCHAR(10) DEFAULT '08:00'," +
                        "check_out_time NVARCHAR(10) DEFAULT '17:00'," +
                        "pet_info NVARCHAR(MAX)," +
                        "special_notes NVARCHAR(MAX)," +
                        "emergency_phone1 NVARCHAR(20) NOT NULL," +
                        "emergency_phone2 NVARCHAR(20)," +
                        "total_price DECIMAL(10,2) NOT NULL DEFAULT 0," +
                        "status NVARCHAR(20) DEFAULT N'Chờ xác nhận'," +
                        "created_at DATETIME2 DEFAULT GETDATE()," +
                        "updated_at DATETIME2 DEFAULT GETDATE()" +
                        ")";
                    
                    stmt.execute(createTableSQL);
                    logger.info("Boarding bookings table created successfully");
                    
                    // Thêm foreign key constraint
                    try {
                        String addForeignKeySQL = 
                            "ALTER TABLE dbo.boarding_bookings " +
                            "ADD CONSTRAINT fk_boarding_customer " +
                            "FOREIGN KEY (customer_id) REFERENCES dbo.Customer(customer_id) " +
                            "ON DELETE CASCADE ON UPDATE CASCADE";
                        stmt.execute(addForeignKeySQL);
                        logger.info("Foreign key constraint added successfully");
                    } catch (SQLException e) {
                        logger.info("Foreign key constraint may already exist: " + e.getMessage());
                    }
                } else {
                    logger.info("Boarding bookings table already exists");
                    
                    // Kiểm tra và thêm column total_price nếu chưa có (cho bảng cũ)
                    try {
                        String checkColumnSQL = 
                            "SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS " +
                            "WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'boarding_bookings' AND COLUMN_NAME = 'total_price'";
                        
                        try (ResultSet rs2 = stmt.executeQuery(checkColumnSQL)) {
                            if (rs2.next() && rs2.getInt(1) == 0) {
                                // Column total_price chưa tồn tại, thêm mới
                                String addColumnSQL = 
                                    "ALTER TABLE dbo.boarding_bookings " +
                                    "ADD total_price DECIMAL(10,2) NOT NULL DEFAULT 0";
                                stmt.execute(addColumnSQL);
                                logger.info("Added total_price column to existing boarding_bookings table");
                            } else {
                                logger.info("total_price column already exists");
                            }
                        }
                    } catch (SQLException e) {
                        logger.warning("Error checking/adding total_price column: " + e.getMessage());
                    }
                    
                    // Cập nhật total_price cho các record cũ có total_price = 0
                    // Note: Chỉ update đơn giản, logic phức tạp sẽ để backend xử lý khi retrieve
                    try {
                        String updatePriceSQL = 
                            "UPDATE dbo.boarding_bookings " +
                            "SET total_price = price_per_day * boarding_days " +
                            "WHERE total_price = 0 AND price_per_day > 0 AND boarding_days > 0";
                        int updatedRows = stmt.executeUpdate(updatePriceSQL);
                        if (updatedRows > 0) {
                            logger.info("Updated total_price for " + updatedRows + " existing booking(s) with simple calculation");
                        }
                    } catch (SQLException e) {
                        logger.warning("Error updating existing total_price values: " + e.getMessage());
                    }
                }
            }
            
        } catch (SQLException e) {
            logger.severe("Error creating boarding_bookings table: " + e.getMessage());
            logger.severe("SQL State: " + e.getSQLState());
            logger.severe("Error Code: " + e.getErrorCode());
            e.printStackTrace();
        } catch (Exception e) {
            logger.severe("Unexpected error creating table: " + e.getMessage());
            e.printStackTrace();
        }
    }
    
    /**
     * Thêm boarding booking mới
     */
    public boolean addBoardingBooking(BoardingBooking booking) {
        if (booking == null) {
            logger.warning("Cannot add null booking");
            return false;
        }
        
        createTableIfNotExists(); // Đảm bảo bảng tồn tại
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(INSERT_BOARDING_BOOKING, 
                 Statement.RETURN_GENERATED_KEYS)) {
            
            // Validate required fields
            if (booking.getCustomerId() <= 0) {
                logger.warning("Invalid customer ID: " + booking.getCustomerId());
                return false;
            }
            
            if (booking.getRoomType() == null || booking.getRoomType().trim().isEmpty()) {
                logger.warning("Room type cannot be null or empty");
                return false;
            }
            
            if (booking.getPricePerDay() == null || booking.getPricePerDay().compareTo(BigDecimal.ZERO) <= 0) {
                logger.warning("Invalid price per day: " + booking.getPricePerDay());
                return false;
            }
            
            if (booking.getBoardingDays() < 0) {
                logger.warning("Invalid boarding days: " + booking.getBoardingDays());
                return false;
            }
            
            if (booking.getCheckInDate() == null || booking.getCheckOutDate() == null) {
                logger.warning("Check-in or check-out date cannot be null");
                return false;
            }
            
            if (booking.getEmergencyPhone1() == null || booking.getEmergencyPhone1().trim().isEmpty()) {
                logger.warning("Emergency phone 1 cannot be null or empty");
                return false;
            }
            
            // Set parameters với logging chi tiết
            logger.info("Setting parameters for boarding booking insert:");
            logger.info("Customer ID: " + booking.getCustomerId());
            logger.info("Room Type: " + booking.getRoomType());
            logger.info("Price Per Day: " + booking.getPricePerDay());
            logger.info("Boarding Days: " + booking.getBoardingDays());
            logger.info("Total Price: " + booking.getTotalPrice());
            logger.info("Check-in Date: " + booking.getCheckInDate());
            logger.info("Check-out Date: " + booking.getCheckOutDate());
            logger.info("Status: " + booking.getStatus());
            
            pstmt.setInt(1, booking.getCustomerId());
            pstmt.setString(2, booking.getRoomType());
            pstmt.setBigDecimal(3, booking.getPricePerDay());
            pstmt.setInt(4, booking.getBoardingDays());
            pstmt.setDate(5, new java.sql.Date(booking.getCheckInDate().getTime()));
            pstmt.setDate(6, new java.sql.Date(booking.getCheckOutDate().getTime()));
            pstmt.setString(7, booking.getCheckInTime() != null ? booking.getCheckInTime() : "08:00");
            pstmt.setString(8, booking.getCheckOutTime() != null ? booking.getCheckOutTime() : "17:00");
            pstmt.setString(9, booking.getPetInfo() != null ? booking.getPetInfo() : "");
            pstmt.setString(10, booking.getSpecialNotes() != null ? booking.getSpecialNotes() : "");
            pstmt.setString(11, booking.getEmergencyPhone1());
            pstmt.setString(12, booking.getEmergencyPhone2() != null ? booking.getEmergencyPhone2() : "");
            pstmt.setBigDecimal(13, booking.getTotalPrice() != null ? booking.getTotalPrice() : BigDecimal.ZERO);
            pstmt.setString(14, booking.getStatus() != null ? booking.getStatus() : "Chờ xác nhận");
            pstmt.setTimestamp(15, booking.getCreatedAt() != null ? booking.getCreatedAt() : new Timestamp(System.currentTimeMillis()));
            pstmt.setTimestamp(16, booking.getUpdatedAt() != null ? booking.getUpdatedAt() : new Timestamp(System.currentTimeMillis()));
            
            logger.info("Executing INSERT statement...");
            int affectedRows = pstmt.executeUpdate();
            logger.info("INSERT executed, affected rows: " + affectedRows);
            
            if (affectedRows > 0) {
                try (ResultSet generatedKeys = pstmt.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        int newId = generatedKeys.getInt(1);
                        booking.setBookingId(newId);
                        logger.info("✅ Boarding booking created with ID: " + newId);
                        logger.info("✅ Booking details: " + booking.toString());
                        return true;
                    } else {
                        logger.warning("No generated keys returned");
                    }
                }
            } else {
                logger.warning("❌ No rows affected when inserting boarding booking");
                logger.warning("❌ Check database constraints and data validity");
            }
            
        } catch (SQLException e) {
            logger.severe("Error adding boarding booking: " + e.getMessage());
            logger.severe("SQL State: " + e.getSQLState());
            logger.severe("Error Code: " + e.getErrorCode());
            e.printStackTrace();
        } catch (Exception e) {
            logger.severe("Unexpected error adding boarding booking: " + e.getMessage());
            e.printStackTrace();
        }
        
        return false;
    }
    
    /**
     * Lấy danh sách boarding bookings theo customer ID
     */
    public List<BoardingBooking> getBoardingBookingsByCustomerId(int customerId) {
        if (customerId <= 0) {
            logger.warning("Invalid customer ID: " + customerId);
            return new ArrayList<>();
        }
        
        createTableIfNotExists(); // Đảm bảo bảng tồn tại
        
        List<BoardingBooking> bookings = new ArrayList<>();
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(SELECT_BY_CUSTOMER_ID)) {
            
            logger.info("Executing SELECT query for customer ID: " + customerId);
            pstmt.setInt(1, customerId);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                logger.info("SELECT query executed, processing results...");
                int rowCount = 0;
                while (rs.next()) {
                    rowCount++;
                    logger.info("Processing row " + rowCount + "...");
                    try {
                        logger.info("Attempting to map row " + rowCount + "...");
                        BoardingBooking booking = mapResultSetToBoardingBooking(rs);
                        if (booking != null) {
                            bookings.add(booking);
                            logger.info("✅ Successfully mapped booking ID: " + booking.getBookingId());
                        } else {
                            logger.warning("❌ mapResultSetToBoardingBooking returned null for row " + rowCount);
                            logger.warning("❌ This indicates a problem in the mapping logic");
                        }
                    } catch (Exception e) {
                        logger.severe("❌ Error mapping result set row " + rowCount + ": " + e.getMessage());
                        logger.severe("❌ Exception details: " + e.getClass().getSimpleName());
                        e.printStackTrace();
                    }
                }
                logger.info("Total rows processed: " + rowCount);
            }
            
            logger.info("✅ Retrieved " + bookings.size() + " boarding bookings for customer ID: " + customerId);
            if (bookings.isEmpty()) {
                logger.warning("⚠️ No bookings found for customer " + customerId + " - check if data exists in database");
            }
            
        } catch (SQLException e) {
            logger.severe("Error getting boarding bookings by customer ID: " + e.getMessage());
            logger.severe("SQL State: " + e.getSQLState());
            logger.severe("Error Code: " + e.getErrorCode());
            e.printStackTrace();
        } catch (Exception e) {
            logger.severe("Unexpected error getting boarding bookings: " + e.getMessage());
            e.printStackTrace();
        }
        
        return bookings;
    }
    
    /**
     * Lấy boarding booking theo ID
     */
    public BoardingBooking getBoardingBookingById(int bookingId) {
        createTableIfNotExists(); // Đảm bảo bảng tồn tại
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(SELECT_BY_ID)) {
            
            pstmt.setInt(1, bookingId);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToBoardingBooking(rs);
                }
            }
            
        } catch (SQLException e) {
            logger.severe("Error getting boarding booking by ID: " + e.getMessage());
            e.printStackTrace();
        }
        
        return null;
    }
    
    /**
     * Lấy danh sách boarding bookings theo customer ID, khoảng ngày và phân trang
     */
    public List<BoardingBooking> getBoardingBookingsByCustomerIdAndDate(
            int customerId, java.sql.Date startDate, java.sql.Date endDate, int offset, int limit) {
        List<BoardingBooking> bookings = new ArrayList<>();
        if (customerId <= 0) return bookings;
        createTableIfNotExists();
        String sql = "SELECT * FROM dbo.boarding_bookings WHERE customer_id = ? " +
            (startDate != null ? "AND check_in_date >= ? " : "") +
            (endDate != null ? "AND check_in_date <= ? " : "") +
            "ORDER BY check_in_date DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            int idx = 1;
            pstmt.setInt(idx++, customerId);
            if (startDate != null) pstmt.setDate(idx++, startDate);
            if (endDate != null) pstmt.setDate(idx++, endDate);
            pstmt.setInt(idx++, offset);
            pstmt.setInt(idx++, limit);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    BoardingBooking booking = mapResultSetToBoardingBooking(rs);
                    if (booking != null) bookings.add(booking);
                }
            }
        } catch (Exception e) {
            logger.severe("Error in getBoardingBookingsByCustomerIdAndDate: " + e.getMessage());
            e.printStackTrace();
        }
        return bookings;
    }
    
    /**
     * Cập nhật trạng thái booking
     */
    public boolean updateBookingStatus(int bookingId, String status) {
        createTableIfNotExists(); // Đảm bảo bảng tồn tại
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(UPDATE_STATUS)) {
            
            pstmt.setString(1, status);
            pstmt.setTimestamp(2, new Timestamp(System.currentTimeMillis()));
            pstmt.setInt(3, bookingId);
            
            int affectedRows = pstmt.executeUpdate();
            return affectedRows > 0;
            
        } catch (SQLException e) {
            logger.severe("Error updating booking status: " + e.getMessage());
            e.printStackTrace();
        }
        
        return false;
    }
    
    /**
     * Xóa booking
     */
    public boolean deleteBoardingBooking(int bookingId) {
        createTableIfNotExists(); // Đảm bảo bảng tồn tại
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(DELETE_BOOKING)) {
            
            pstmt.setInt(1, bookingId);
            
            int affectedRows = pstmt.executeUpdate();
            return affectedRows > 0;
            
        } catch (SQLException e) {
            logger.severe("Error deleting boarding booking: " + e.getMessage());
            e.printStackTrace();
        }
        
        return false;
    }
    
    /**
     * Map ResultSet thành BoardingBooking object
     */
    private BoardingBooking mapResultSetToBoardingBooking(ResultSet rs) throws SQLException {
        BoardingBooking booking = new BoardingBooking();
        
        logger.info("Mapping ResultSet to BoardingBooking...");
        
        try {
            // Required fields with validation
            int bookingId = rs.getInt("booking_id");
            int customerId = rs.getInt("customer_id");
            
            logger.info("Raw data - booking_id: " + bookingId + ", customer_id: " + customerId);
            
            // Debug: Log all column values
            logger.info("Debug - All column values:");
            logger.info("  booking_id: " + rs.getInt("booking_id"));
            logger.info("  customer_id: " + rs.getInt("customer_id"));
            logger.info("  room_type: " + rs.getString("room_type"));
            logger.info("  price_per_day: " + rs.getBigDecimal("price_per_day"));
            logger.info("  boarding_days: " + rs.getInt("boarding_days"));
            logger.info("  status: " + rs.getString("status"));
            
            if (bookingId <= 0) {
                logger.warning("❌ Invalid booking ID: " + bookingId);
                return null;
            }
            
            if (customerId <= 0) {
                logger.warning("❌ Invalid customer ID: " + customerId);
                return null;
            }
            
            booking.setBookingId(bookingId);
            booking.setCustomerId(customerId);
        
            // String fields with null handling
            String roomType = rs.getString("room_type");
            booking.setRoomType(roomType != null ? roomType : "");
            
            // BigDecimal field
            booking.setPricePerDay(rs.getBigDecimal("price_per_day"));
            
            // Integer field
            booking.setBoardingDays(rs.getInt("boarding_days"));
            
            // Date fields
            booking.setCheckInDate(rs.getTimestamp("check_in_date"));
            booking.setCheckOutDate(rs.getTimestamp("check_out_date"));
            
            // Optional string fields with null handling
            String checkInTime = rs.getString("check_in_time");
            booking.setCheckInTime(checkInTime != null ? checkInTime : "08:00");
            
            String checkOutTime = rs.getString("check_out_time");
            booking.setCheckOutTime(checkOutTime != null ? checkOutTime : "17:00");
            
            String petInfo = rs.getString("pet_info");
            booking.setPetInfo(petInfo != null ? petInfo : "");
            
            String specialNotes = rs.getString("special_notes");
            booking.setSpecialNotes(specialNotes != null ? specialNotes : "");
            
            String emergencyPhone1 = rs.getString("emergency_phone1");
            booking.setEmergencyPhone1(emergencyPhone1 != null ? emergencyPhone1 : "");
            
            String emergencyPhone2 = rs.getString("emergency_phone2");
            booking.setEmergencyPhone2(emergencyPhone2 != null ? emergencyPhone2 : "");
            
            // Total price field - đọc từ DB hoặc tính lại nếu null
            BigDecimal totalPrice = rs.getBigDecimal("total_price");
            if (totalPrice == null || totalPrice.compareTo(BigDecimal.ZERO) == 0) {
                // Nếu không có total_price trong DB, tính lại từ price_per_day * boarding_days
                BigDecimal pricePerDay = booking.getPricePerDay();
                int boardingDays = booking.getBoardingDays();
                totalPrice = pricePerDay.multiply(BigDecimal.valueOf(boardingDays));
            }
            booking.setTotalPrice(totalPrice);
            
            String status = rs.getString("status");
            booking.setStatus(status != null ? status : "Chờ xác nhận");
            
            // Timestamp fields
            booking.setCreatedAt(rs.getTimestamp("created_at"));
            booking.setUpdatedAt(rs.getTimestamp("updated_at"));
        
            logger.info("✅ Successfully mapped BoardingBooking: ID=" + bookingId + ", Room=" + roomType + ", Price=" + totalPrice);
            
            return booking;
            
        } catch (SQLException e) {
            logger.severe("❌ SQLException in mapResultSetToBoardingBooking: " + e.getMessage());
            logger.severe("❌ SQL State: " + e.getSQLState());
            logger.severe("❌ Error Code: " + e.getErrorCode());
            e.printStackTrace();
            return null;
        } catch (Exception e) {
            logger.severe("❌ Unexpected error in mapResultSetToBoardingBooking: " + e.getMessage());
            logger.severe("❌ Exception type: " + e.getClass().getSimpleName());
            e.printStackTrace();
            return null;
        }
    }
    
    /**
     * Kiểm tra kết nối database và tạo bảng nếu cần
     */
    public boolean initializeDatabase() {
        try (Connection conn = DBConnection.getConnection()) {
            if (conn == null) {
                logger.severe("Cannot connect to database");
                return false;
            }
            
            logger.info("Database connection successful");
            
            // Tạo bảng nếu chưa tồn tại
            createTableIfNotExists();
            
            return true;
            
        } catch (SQLException e) {
            logger.severe("Error initializing database: " + e.getMessage());
            logger.severe("SQL State: " + e.getSQLState());
            logger.severe("Error Code: " + e.getErrorCode());
            e.printStackTrace();
            return false;
        } catch (Exception e) {
            logger.severe("Unexpected error initializing database: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Test method để debug database connection
     */
    public boolean testDatabaseConnection() {
        try (Connection conn = DBConnection.getConnection()) {
            if (conn == null) {
                logger.severe("Database connection is null");
                return false;
            }
            
            logger.info("Database connection test successful");
            logger.info("Database URL: " + conn.getMetaData().getURL());
            logger.info("Database Product: " + conn.getMetaData().getDatabaseProductName());
            logger.info("Database Version: " + conn.getMetaData().getDatabaseProductVersion());
            
            return true;
            
        } catch (SQLException e) {
            logger.severe("Database connection test failed: " + e.getMessage());
            logger.severe("SQL State: " + e.getSQLState());
            logger.severe("Error Code: " + e.getErrorCode());
            e.printStackTrace();
            return false;
        } catch (Exception e) {
            logger.severe("Unexpected error in database connection test: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
}