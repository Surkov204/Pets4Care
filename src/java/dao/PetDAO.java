package dao;

import model.Pet;
import utils.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Logger;

/**
 * DAO cho Pet
 * Xử lý các thao tác database liên quan đến thú cưng
 * @author ASUS
 */
public class PetDAO implements IPetDAO {
    
    private static final Logger logger = Logger.getLogger(PetDAO.class.getName());
    
    /**
     * Lấy tất cả thú cưng của một khách hàng (tiện ích mở rộng ngoài interface)
     */
    public List<Pet> getPetsByCustomerId(int customerId) {
        String sql = "SELECT * FROM Pet WHERE customer_id = ? ORDER BY created_at DESC";
        List<Pet> pets = new ArrayList<>();
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, customerId);
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                pets.add(mapResultSetToPet(rs));
            }
            
        } catch (SQLException e) {
            logger.severe("Error getting pets by customer ID: " + e.getMessage());
            e.printStackTrace();
        }
        
        return pets;
    }
    
    /**
     * Lấy 1 thú cưng đại diện theo customerId (đáp ứng IPetDAO)
     */
    @Override
    public Pet getPetByCustomerId(int customerId) {
        String sql = "SELECT TOP 1 * FROM Pet WHERE customer_id = ? ORDER BY updated_at DESC, created_at DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, customerId);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return mapResultSetToPet(rs);
            }
        } catch (SQLException e) {
            logger.severe("Error getting pet by customer ID: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }
    
    /**
     * Lấy thú cưng theo ID
     */
    public Pet getPetById(int petId) {
        String sql = "SELECT * FROM Pet WHERE id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, petId);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                return mapResultSetToPet(rs);
            }
            
        } catch (SQLException e) {
            logger.severe("Error getting pet by ID: " + e.getMessage());
            e.printStackTrace();
        }
        
        return null;
    }
    
    /**
     * Lấy thú cưng theo ID và customer ID (để đảm bảo quyền truy cập)
     */
    public Pet getPetByIdAndCustomerId(int petId, int customerId) {
        String sql = "SELECT * FROM Pet WHERE id = ? AND customer_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, petId);
            stmt.setInt(2, customerId);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                return mapResultSetToPet(rs);
            }
            
        } catch (SQLException e) {
            logger.severe("Error getting pet by ID and customer ID: " + e.getMessage());
            e.printStackTrace();
        }
        
        return null;
    }
    
    /**
     * Lưu thú cưng mới (đáp ứng IPetDAO.savePet)
     */
    @Override
    public boolean savePet(Pet pet) {
        String sql = "INSERT INTO Pet (customer_id, pet_name, species, breed, age, gender, description, health_status, image_path, created_at, updated_at) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            stmt.setInt(1, pet.getCustomerId());
            stmt.setString(2, pet.getPetName());
            stmt.setString(3, pet.getSpecies());
            stmt.setString(4, pet.getBreed());
            stmt.setInt(5, pet.getAge());
            stmt.setString(6, pet.getGender());
            stmt.setString(7, pet.getDescription());
            stmt.setString(8, pet.getHealthStatus());
            stmt.setString(9, pet.getImagePath());
            stmt.setTimestamp(10, new Timestamp(System.currentTimeMillis()));
            stmt.setTimestamp(11, new Timestamp(System.currentTimeMillis()));
            
            int affectedRows = stmt.executeUpdate();
            
            if (affectedRows > 0) {
                ResultSet generatedKeys = stmt.getGeneratedKeys();
                if (generatedKeys.next()) {
                    pet.setId(generatedKeys.getInt(1));
                }
                return true;
            }
            
        } catch (SQLException e) {
            logger.severe("Error adding pet: " + e.getMessage());
            e.printStackTrace();
        }
        
        return false;
    }
    
    /**
     * Cập nhật thông tin thú cưng
     */
    @Override
    public boolean updatePet(Pet pet) {
        String sql = "UPDATE Pet SET pet_name = ?, species = ?, breed = ?, age = ?, gender = ?, " +
                    "description = ?, health_status = ?, image_path = ?, updated_at = ? WHERE id = ? AND customer_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, pet.getPetName());
            stmt.setString(2, pet.getSpecies());
            stmt.setString(3, pet.getBreed());
            stmt.setInt(4, pet.getAge());
            stmt.setString(5, pet.getGender());
            stmt.setString(6, pet.getDescription());
            stmt.setString(7, pet.getHealthStatus());
            stmt.setString(8, pet.getImagePath());
            stmt.setTimestamp(9, new Timestamp(System.currentTimeMillis()));
            stmt.setInt(10, pet.getId());
            stmt.setInt(11, pet.getCustomerId());
            
            return stmt.executeUpdate() > 0;
            
        } catch (SQLException e) {
            logger.severe("Error updating pet: " + e.getMessage());
            e.printStackTrace();
        }
        
        return false;
    }
    
    /**
     * Xóa thú cưng theo customerId (đáp ứng IPetDAO.deletePetByCustomerId)
     */
    @Override
    public boolean deletePetByCustomerId(int customerId) {
        String sql = "DELETE FROM Pet WHERE customer_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, customerId);
            
            return stmt.executeUpdate() > 0;
            
        } catch (SQLException e) {
            logger.severe("Error deleting pet by customerId: " + e.getMessage());
            e.printStackTrace();
        }
        
        return false;
    }
    
    /**
     * Kiểm tra đã có thông tin thú cưng chưa
     */
    @Override
    public boolean hasPetInfo(int customerId) {
        String sql = "SELECT 1 FROM Pet WHERE customer_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, customerId);
            ResultSet rs = stmt.executeQuery();
            return rs.next();
        } catch (SQLException e) {
            logger.severe("Error checking pet exists: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }
    
    /**
     * Lấy tất cả thú cưng
     */
    @Override
    public List<Pet> getAllPets() {
        String sql = "SELECT * FROM Pet ORDER BY created_at DESC";
        List<Pet> pets = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) pets.add(mapResultSetToPet(rs));
        } catch (SQLException e) {
            logger.severe("Error getting all pets: " + e.getMessage());
            e.printStackTrace();
        }
        return pets;
    }
    
    /**
     * Tìm kiếm thú cưng theo tên
     */
    @Override
    public List<Pet> searchPetsByName(String keyword) {
        String sql = "SELECT * FROM Pet WHERE pet_name LIKE ? ORDER BY created_at DESC";
        List<Pet> pets = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, "%" + keyword + "%");
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) pets.add(mapResultSetToPet(rs));
        } catch (SQLException e) {
            logger.severe("Error searching pets by name: " + e.getMessage());
            e.printStackTrace();
        }
        return pets;
    }
    
    /**
     * Lấy danh sách thú cưng theo loài
     */
    @Override
    public List<Pet> getPetsBySpecies(String species) {
        String sql = "SELECT * FROM Pet WHERE species = ? ORDER BY created_at DESC";
        List<Pet> pets = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, species);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) pets.add(mapResultSetToPet(rs));
        } catch (SQLException e) {
            logger.severe("Error getting pets by species: " + e.getMessage());
            e.printStackTrace();
        }
        return pets;
    }
    
    /**
     * Đếm số thú cưng theo loài
     */
    @Override
    public int countPetsBySpecies(String species) {
        String sql = "SELECT COUNT(*) FROM Pet WHERE species = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, species);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) {
            logger.severe("Error counting pets by species: " + e.getMessage());
            e.printStackTrace();
        }
        return 0;
    }
    
    /**
     * Thống kê số lượng thú cưng theo loài
     */
    @Override
    public Map<String, Integer> getPetStatistics() {
        String sql = "SELECT species, COUNT(*) AS cnt FROM Pet GROUP BY species";
        Map<String, Integer> stats = new HashMap<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                stats.put(rs.getString("species"), rs.getInt("cnt"));
            }
        } catch (SQLException e) {
            logger.severe("Error getting pet statistics: " + e.getMessage());
            e.printStackTrace();
        }
        return stats;
    }
    
    /**
     * Map ResultSet to Pet object
     */
    private Pet mapResultSetToPet(ResultSet rs) throws SQLException {
        Pet pet = new Pet();
        
        pet.setId(rs.getInt("id"));
        pet.setCustomerId(rs.getInt("customer_id"));
        pet.setPetName(rs.getString("pet_name"));
        pet.setSpecies(rs.getString("species"));
        pet.setBreed(rs.getString("breed"));
        pet.setAge(rs.getInt("age"));
        pet.setGender(rs.getString("gender"));
        pet.setDescription(rs.getString("description"));
        pet.setHealthStatus(rs.getString("health_status"));
        pet.setImagePath(rs.getString("image_path"));
        pet.setCreatedAt(rs.getTimestamp("created_at"));
        pet.setUpdatedAt(rs.getTimestamp("updated_at"));
        
        return pet;
    }
}