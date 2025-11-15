package dao;

import model.BoardingRoom;
import utils.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Logger;

/**
 * Data Access Object cho BoardingRoom Xử lý các thao tác database cho phòng lưu
 * trú
 *
 * @author ASUS
 */
public class BoardingRoomDAO {

    private static final Logger logger = Logger.getLogger(BoardingRoomDAO.class.getName());

    /**
     * Lấy tất cả phòng lưu trú
     */
    public List<BoardingRoom> getAllRooms() {
        String sql = "SELECT * FROM BoardingRoom ORDER BY room_type, room_name";
        List<BoardingRoom> rooms = new ArrayList<>();

        try (Connection conn = DBConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql); ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                rooms.add(mapResultSetToBoardingRoom(rs));
            }

        } catch (SQLException e) {
            logger.severe("Error getting all rooms: " + e.getMessage());
            e.printStackTrace();
        }

        return rooms;
    }

    /**
     * Lấy phòng theo ID
     */
    public BoardingRoom getRoomById(int roomId) {
        String sql = "SELECT * FROM BoardingRoom WHERE room_id = ?";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, roomId);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                return mapResultSetToBoardingRoom(rs);
            }

        } catch (SQLException e) {
            logger.severe("Error getting room by ID: " + e.getMessage());
            e.printStackTrace();
        }

        return null;
    }

    /**
     * Lấy phòng theo loại
     */
    public List<BoardingRoom> getRoomsByType(String roomType) {
        String sql = "SELECT * FROM BoardingRoom WHERE room_type = ? ORDER BY room_name";
        List<BoardingRoom> rooms = new ArrayList<>();

        try (Connection conn = DBConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, roomType);
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                rooms.add(mapResultSetToBoardingRoom(rs));
            }

        } catch (SQLException e) {
            logger.severe("Error getting rooms by type: " + e.getMessage());
            e.printStackTrace();
        }

        return rooms;
    }

    /**
     * Lấy tất cả phòng (không còn filter theo status)
     */
    public List<BoardingRoom> getAvailableRooms() {
        String sql = "SELECT * FROM BoardingRoom ORDER BY room_type, room_name";
        List<BoardingRoom> rooms = new ArrayList<>();

        try (Connection conn = DBConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql); ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                BoardingRoom room = mapResultSetToBoardingRoom(rs);
                // Tính số phòng còn lại cho mỗi room
                int availableCount = getAvailableRoomsCountByType(room.getRoomType());
                room.setAvailableRooms(availableCount);
                rooms.add(room);
            }

        } catch (SQLException e) {
            logger.severe("Error getting available rooms: " + e.getMessage());
            e.printStackTrace();
        }

        return rooms;
    }

    /**
     * Lấy roomId đầu tiên theo roomType
     */
    public Integer getRoomIdByType(String roomType) {
        String sql = "SELECT TOP 1 room_id FROM BoardingRoom WHERE room_type = ? ORDER BY room_id";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, roomType);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                return rs.getInt("room_id");
            }

        } catch (SQLException e) {
            logger.severe("Error getting room ID by type: " + e.getMessage());
            e.printStackTrace();
        }

        return null;
    }

    /**
     * Kiểm tra phòng có sẵn trong khoảng thời gian
     */
    public boolean isRoomAvailable(int roomId, Timestamp checkInDate, Timestamp checkOutDate) {
<<<<<<< HEAD
        // Lấy room type từ room_id
        String roomType = null;
        String getRoomTypeSql = "SELECT room_type FROM BoardingRoom WHERE room_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(getRoomTypeSql)) {
            
=======
        // Đơn giản hóa: chỉ kiểm tra phòng có tồn tại và status = 'available'
        String sql = "SELECT COUNT(*) FROM BoardingRoom WHERE room_id = ? AND status = 'available'";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {

>>>>>>> origin/master
            stmt.setInt(1, roomId);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                roomType = rs.getString("room_type");
            } else {
                return false;
            }

        } catch (SQLException e) {
            logger.severe("Error getting room type: " + e.getMessage());
            return false;
        }
<<<<<<< HEAD
        
        // Kiểm tra số phòng còn lại
        int availableCount = getAvailableRoomsCountByType(roomType);
        return availableCount > 0;
=======

        return false;
>>>>>>> origin/master
    }

    /**
     * Lấy số lượng phòng có sẵn theo loại (deprecated - dùng getAvailableRoomsCountByType)
     */
    public int getAvailableRoomCountByType(String roomType) {
<<<<<<< HEAD
        return getAvailableRoomsCountByType(roomType);
=======
        String sql = "SELECT COUNT(*) FROM BoardingRoom WHERE room_type = ? AND status = 'available'";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, roomType);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                return rs.getInt(1);
            }

        } catch (SQLException e) {
            logger.severe("Error getting available room count by type: " + e.getMessage());
            e.printStackTrace();
        }

        return 0;
>>>>>>> origin/master
    }

    /**
     * Cập nhật số phòng (rooms) - được gọi khi có booking được xác nhận
     */
<<<<<<< HEAD
    public boolean updateRoomsCount(int roomId, int newRoomsCount) {
        String sql = "UPDATE BoardingRoom SET rooms = ?, updated_at = ? WHERE room_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, newRoomsCount);
=======
    public boolean updateRoomStatus(int roomId, String status) {
        String sql = "UPDATE BoardingRoom SET status = ?, updated_at = ? WHERE room_id = ?";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, status);
>>>>>>> origin/master
            stmt.setTimestamp(2, new Timestamp(System.currentTimeMillis()));
            stmt.setInt(3, roomId);

            int rowsAffected = stmt.executeUpdate();

            if (rowsAffected > 0) {
                logger.info("Updated rooms count for room ID: " + roomId + " to: " + newRoomsCount);
                return true;
            }

        } catch (SQLException e) {
            logger.severe("Error updating rooms count: " + e.getMessage());
            e.printStackTrace();
        }

        return false;
    }

    /**
     * Tạo phòng mới
     */
    public boolean createRoom(BoardingRoom room) {
<<<<<<< HEAD
        String sql = "INSERT INTO BoardingRoom (room_name, room_type, rooms, price_per_day, " +
                    "description, created_at, updated_at) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?)";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
=======
        String sql = "INSERT INTO BoardingRoom (room_name, room_type, capacity, price_per_day, "
                + "description, status, created_at, updated_at) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

>>>>>>> origin/master
            stmt.setString(1, room.getRoomName());
            stmt.setString(2, room.getRoomType());
            stmt.setInt(3, room.getCapacity());
            stmt.setDouble(4, room.getPricePerDay());
            stmt.setString(5, room.getDescription());
            stmt.setTimestamp(6, new Timestamp(System.currentTimeMillis()));
            stmt.setTimestamp(7, new Timestamp(System.currentTimeMillis()));
<<<<<<< HEAD
            
=======
            stmt.setTimestamp(8, new Timestamp(System.currentTimeMillis()));

>>>>>>> origin/master
            int rowsAffected = stmt.executeUpdate();

            if (rowsAffected > 0) {
                ResultSet generatedKeys = stmt.getGeneratedKeys();
                if (generatedKeys.next()) {
                    room.setRoomId(generatedKeys.getInt(1));
                }
                logger.info("Created room with ID: " + room.getRoomId());
                return true;
            }

        } catch (SQLException e) {
            logger.severe("Error creating room: " + e.getMessage());
            e.printStackTrace();
        }

        return false;
    }

    /**
     * Cập nhật thông tin phòng
     */
    public boolean updateRoom(BoardingRoom room) {
<<<<<<< HEAD
        String sql = "UPDATE BoardingRoom SET room_name = ?, room_type = ?, rooms = ?, " +
                    "price_per_day = ?, description = ?, " +
                    "updated_at = ? WHERE room_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
=======
        String sql = "UPDATE BoardingRoom SET room_name = ?, room_type = ?, capacity = ?, "
                + "price_per_day = ?, description = ?, status = ?, "
                + "updated_at = ? WHERE room_id = ?";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {

>>>>>>> origin/master
            stmt.setString(1, room.getRoomName());
            stmt.setString(2, room.getRoomType());
            stmt.setInt(3, room.getCapacity());
            stmt.setDouble(4, room.getPricePerDay());
            stmt.setString(5, room.getDescription());
<<<<<<< HEAD
            stmt.setTimestamp(6, new Timestamp(System.currentTimeMillis()));
            stmt.setInt(7, room.getRoomId());
            
=======
            stmt.setString(6, room.getStatus());
            stmt.setTimestamp(7, new Timestamp(System.currentTimeMillis()));
            stmt.setInt(8, room.getRoomId());

>>>>>>> origin/master
            int rowsAffected = stmt.executeUpdate();

            if (rowsAffected > 0) {
                logger.info("Updated room with ID: " + room.getRoomId());
                return true;
            }

        } catch (SQLException e) {
            logger.severe("Error updating room: " + e.getMessage());
            e.printStackTrace();
        }

        return false;
    }

    /**
     * Xóa phòng (hard delete hoặc set rooms = 0)
     */
    public boolean deleteRoom(int roomId) {
<<<<<<< HEAD
        String sql = "UPDATE BoardingRoom SET rooms = 0, updated_at = ? WHERE room_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
=======
        String sql = "UPDATE BoardingRoom SET status = 'unavailable', updated_at = ? WHERE room_id = ?";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {

>>>>>>> origin/master
            stmt.setTimestamp(1, new Timestamp(System.currentTimeMillis()));
            stmt.setInt(2, roomId);

            int rowsAffected = stmt.executeUpdate();

            if (rowsAffected > 0) {
                logger.info("Deleted room with ID: " + roomId);
                return true;
            }

        } catch (SQLException e) {
            logger.severe("Error deleting room: " + e.getMessage());
            e.printStackTrace();
        }

        return false;
    }

    /**
     * Lấy số phòng còn lại theo loại (rooms - số booking đã xác nhận và đang active)
     */
    public int getAvailableRoomsCountByType(String roomType) {
        // Lấy số phòng tổng từ bảng BoardingRoom
        String getRoomsSql = "SELECT rooms FROM dbo.BoardingRoom WHERE room_type = ?";
        
        // Đếm số booking đang active (trong khoảng thời gian hiện tại)
        String countOccupiedSql = "SELECT COUNT(DISTINCT booking_id) AS occupied_count " +
                                 "FROM dbo.boarding_bookings " +
                                 "WHERE room_type = ? " +
                                 "AND status IN (N'Hoàn thành', N'Đã trả', N'Đã thanh toán', N'Đang ở', N'Chờ xác nhận', N'Đã nhận về', N'Chưa nhận thú cưng') " +
                                 "AND CAST(GETDATE() AS DATE) >= check_in_date " +
                                 "AND CAST(GETDATE() AS DATE) <= check_out_date";
        
        try (Connection conn = DBConnection.getConnection()) {
            // Lấy số phòng tổng
            int totalRooms = 0;
            try (PreparedStatement stmt = conn.prepareStatement(getRoomsSql)) {
                stmt.setString(1, roomType);
                ResultSet rs = stmt.executeQuery();
                if (rs.next()) {
                    totalRooms = rs.getInt("rooms");
                } else {
                    logger.warning("Room type not found: " + roomType);
                    return 0;
                }
            }
            
            // Đếm số booking đang active
            int occupiedCount = 0;
            try (PreparedStatement stmt = conn.prepareStatement(countOccupiedSql)) {
                stmt.setString(1, roomType);
                ResultSet rs = stmt.executeQuery();
                if (rs.next()) {
                    occupiedCount = rs.getInt("occupied_count");
                }
            }
            
            // Tính số phòng còn lại
            int available = totalRooms - occupiedCount;
            logger.info("Room type: " + roomType + ", Total rooms: " + totalRooms + ", Occupied: " + occupiedCount + ", Available: " + available);
            return available > 0 ? available : 0;
            
        } catch (SQLException e) {
            logger.severe("Error getting available rooms count by type: " + e.getMessage());
            e.printStackTrace();
        }
        
        return 0;
    }
    
    /**
     * Map ResultSet to BoardingRoom object
     */
    private BoardingRoom mapResultSetToBoardingRoom(ResultSet rs) throws SQLException {
        BoardingRoom room = new BoardingRoom();

        room.setRoomId(rs.getInt("room_id"));
        room.setRoomName(rs.getString("room_name"));
        room.setRoomType(rs.getString("room_type"));
        // Map rooms từ database sang capacity trong model
        try {
            room.setCapacity(rs.getInt("rooms"));
        } catch (SQLException e) {
            // Fallback nếu không có rooms, thử total_rooms hoặc capacity
            try {
                room.setCapacity(rs.getInt("total_rooms"));
            } catch (SQLException e2) {
                try {
                    room.setCapacity(rs.getInt("capacity"));
                } catch (SQLException e3) {
                    room.setCapacity(1); // Default value
                }
            }
        }
        room.setPricePerDay(rs.getDouble("price_per_day"));
        room.setDescription(rs.getString("description"));
        // Không còn cột status, set mặc định
        room.setStatus("available");
        room.setActive(true); // Mặc định là active
        room.setCreatedAt(rs.getTimestamp("created_at"));
        room.setUpdatedAt(rs.getTimestamp("updated_at"));

        return room;
    }

    public void decreaseCapacity(String roomType) {
        String sql = "UPDATE BoardingRoom SET capacity = capacity - 1 WHERE room_type = ? AND capacity > 0";
        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, roomType);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public void increaseCapacity(String roomType) {
        String sql = "UPDATE BoardingRoom SET capacity = capacity + 1 WHERE room_type = ?";
        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, roomType);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}
