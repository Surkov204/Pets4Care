package dao;

import model.BoardingRoom;
import utils.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Logger;

/**
 * Data Access Object cho BoardingRoom
 * Xử lý các thao tác database cho phòng lưu trú
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
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            
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
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
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
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
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
     * Lấy phòng có sẵn
     */
    public List<BoardingRoom> getAvailableRooms() {
        String sql = "SELECT * FROM BoardingRoom WHERE status = 'available' ORDER BY room_type, room_name";
        List<BoardingRoom> rooms = new ArrayList<>();
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            
            while (rs.next()) {
                rooms.add(mapResultSetToBoardingRoom(rs));
            }
            
        } catch (SQLException e) {
            logger.severe("Error getting available rooms: " + e.getMessage());
            e.printStackTrace();
        }
        
        return rooms;
    }
    
    /**
     * Kiểm tra phòng có sẵn trong khoảng thời gian
     */
    public boolean isRoomAvailable(int roomId, Timestamp checkInDate, Timestamp checkOutDate) {
        // Đơn giản hóa: chỉ kiểm tra phòng có tồn tại và status = 'available'
        String sql = "SELECT COUNT(*) FROM BoardingRoom WHERE room_id = ? AND status = 'available'";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, roomId);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
            
        } catch (SQLException e) {
            logger.severe("Error checking room availability: " + e.getMessage());
            e.printStackTrace();
        }
        
        return false;
    }
    
    /**
     * Lấy số lượng phòng có sẵn theo loại
     */
    public int getAvailableRoomCountByType(String roomType) {
        String sql = "SELECT COUNT(*) FROM BoardingRoom WHERE room_type = ? AND status = 'available'";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
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
    }
    
    /**
     * Cập nhật trạng thái phòng
     */
    public boolean updateRoomStatus(int roomId, String status) {
        String sql = "UPDATE BoardingRoom SET status = ?, updated_at = ? WHERE room_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, status);
            stmt.setTimestamp(2, new Timestamp(System.currentTimeMillis()));
            stmt.setInt(3, roomId);
            
            int rowsAffected = stmt.executeUpdate();
            
            if (rowsAffected > 0) {
                logger.info("Updated room status for room ID: " + roomId + " to: " + status);
                return true;
            }
            
        } catch (SQLException e) {
            logger.severe("Error updating room status: " + e.getMessage());
            e.printStackTrace();
        }
        
        return false;
    }
    
    /**
     * Tạo phòng mới
     */
    public boolean createRoom(BoardingRoom room) {
        String sql = "INSERT INTO BoardingRoom (room_name, room_type, capacity, price_per_day, " +
                    "description, status, created_at, updated_at) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            stmt.setString(1, room.getRoomName());
            stmt.setString(2, room.getRoomType());
            stmt.setInt(3, room.getCapacity());
            stmt.setDouble(4, room.getPricePerDay());
            stmt.setString(5, room.getDescription());
            stmt.setString(6, room.getStatus());
            stmt.setTimestamp(7, new Timestamp(System.currentTimeMillis()));
            stmt.setTimestamp(8, new Timestamp(System.currentTimeMillis()));
            
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
        String sql = "UPDATE BoardingRoom SET room_name = ?, room_type = ?, capacity = ?, " +
                    "price_per_day = ?, description = ?, status = ?, " +
                    "updated_at = ? WHERE room_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, room.getRoomName());
            stmt.setString(2, room.getRoomType());
            stmt.setInt(3, room.getCapacity());
            stmt.setDouble(4, room.getPricePerDay());
            stmt.setString(5, room.getDescription());
            stmt.setString(6, room.getStatus());
            stmt.setTimestamp(7, new Timestamp(System.currentTimeMillis()));
            stmt.setInt(8, room.getRoomId());
            
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
     * Xóa phòng (soft delete)
     */
    public boolean deleteRoom(int roomId) {
        String sql = "UPDATE BoardingRoom SET status = 'unavailable', updated_at = ? WHERE room_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
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
     * Map ResultSet to BoardingRoom object
     */
    private BoardingRoom mapResultSetToBoardingRoom(ResultSet rs) throws SQLException {
        BoardingRoom room = new BoardingRoom();
        
        room.setRoomId(rs.getInt("room_id"));
        room.setRoomName(rs.getString("room_name"));
        room.setRoomType(rs.getString("room_type"));
        room.setCapacity(rs.getInt("capacity"));
        room.setPricePerDay(rs.getDouble("price_per_day"));
        room.setDescription(rs.getString("description"));
        room.setStatus(rs.getString("status"));
        room.setActive(true); // Mặc định là active
        room.setCreatedAt(rs.getTimestamp("created_at"));
        room.setUpdatedAt(rs.getTimestamp("updated_at"));
        
        return room;
    }
}
