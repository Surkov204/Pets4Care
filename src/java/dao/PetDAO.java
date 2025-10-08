package dao;

import model.Pet;
import utils.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * PetDAO implementation
 *
 * @author ASUS
 */
public class PetDAO implements IPetDAO {

    @Override
    public Pet getPetByCustomerId(int customerId) {
        System.out.println("=== DEBUG GET PET BY CUSTOMER ID ===");
        System.out.println("Customer ID: " + customerId);
        String sql = "SELECT * FROM PET WHERE customer_id = ?";
        System.out.println("SQL: " + sql);

        try (Connection conn = DBConnection.getConnection()) {
            System.out.println("Connection obtained: " + (conn != null ? "SUCCESS" : "FAILED"));
            if (conn == null) {
                System.out.println("ERROR: Database connection is null!");
                return null;
            }
            
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                System.out.println("PreparedStatement created successfully");
                ps.setInt(1, customerId);
                System.out.println("Parameter set: customerId = " + customerId);

                try (ResultSet rs = ps.executeQuery()) {
                    System.out.println("Query executed successfully");
                    if (rs.next()) {
                        System.out.println("Pet found in database");
                        Pet pet = new Pet(
                                rs.getInt("id"),
                                rs.getInt("customer_id"),
                                rs.getString("pet_name"),
                                rs.getString("species"),
                                rs.getString("breed"),
                                rs.getInt("age"),
                                rs.getString("gender"),
                                rs.getString("description"),
                                rs.getString("health_status"),
                                rs.getString("image_path"),
                                rs.getTimestamp("created_at"),
                                rs.getTimestamp("updated_at")
                        );
                        System.out.println("Pet object created: " + pet.getPetName());
                        return pet;
                    } else {
                        System.out.println("No pet found for customer ID: " + customerId);
                    }
                } catch (SQLException e) {
                    System.out.println("ERROR in ResultSet: " + e.getMessage());
                    e.printStackTrace();
                }
            } catch (SQLException e) {
                System.out.println("ERROR in PreparedStatement: " + e.getMessage());
                e.printStackTrace();
            }
        } catch (SQLException e) {
            System.out.println("ERROR in getPetByCustomerId: " + e.getMessage());
            e.printStackTrace();
        }

        System.out.println("Returning null pet");
        return null;
    }

    @Override
    public boolean savePet(Pet pet) {
        String sql = "INSERT INTO PET (customer_id, pet_name, species, breed, age, gender, description, health_status, image_path, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, GETDATE(), GETDATE())";

        System.out.println("=== DEBUG SAVE PET DAO ===");
        System.out.println("SQL: " + sql);
        System.out.println("Customer ID: " + pet.getCustomerId());
        System.out.println("Pet Name: " + pet.getPetName());
        System.out.println("Species: " + pet.getSpecies());
        System.out.println("Breed: " + pet.getBreed());
        System.out.println("Age: " + pet.getAge());
        System.out.println("Gender: " + pet.getGender());
        System.out.println("Description: " + pet.getDescription());
        System.out.println("Health Status: " + pet.getHealthStatus());
        System.out.println("Image Path: " + pet.getImagePath());
        
        try (Connection conn = DBConnection.getConnection()) {
            System.out.println("Connection obtained: " + (conn != null ? "SUCCESS" : "FAILED"));
            if (conn == null) {
                System.out.println("ERROR: Database connection is null!");
                return false;
            }
            
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                System.out.println("PreparedStatement created successfully");

                System.out.println("Setting parameters...");
                ps.setInt(1, pet.getCustomerId());
                ps.setString(2, pet.getPetName());
                ps.setString(3, pet.getSpecies());
                ps.setString(4, pet.getBreed());
                ps.setInt(5, pet.getAge());
                ps.setString(6, pet.getGender());
                ps.setString(7, pet.getDescription() != null ? pet.getDescription() : "");
                ps.setString(8, pet.getHealthStatus() != null ? pet.getHealthStatus() : "");
                ps.setString(9, pet.getImagePath() != null ? pet.getImagePath() : "");
                System.out.println("Parameters set successfully");

                System.out.println("Executing INSERT statement...");
                int rowsAffected = ps.executeUpdate();
                System.out.println("Rows affected: " + rowsAffected);
                return rowsAffected > 0;
            } catch (SQLException e) {
                System.out.println("ERROR in PreparedStatement: " + e.getMessage());
                e.printStackTrace();
                return false;
            }
        } catch (SQLException e) {
            System.out.println("ERROR in savePet: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public boolean updatePet(Pet pet) {
        String sql = "UPDATE PET SET pet_name = ?, species = ?, breed = ?, age = ?, gender = ?, description = ?, health_status = ?, image_path = ?, updated_at = GETDATE() WHERE id = ?";

        System.out.println("=== DEBUG UPDATE PET DAO ===");
        System.out.println("SQL: " + sql);
        System.out.println("Pet ID: " + pet.getId());
        System.out.println("Pet Name: " + pet.getPetName());
        System.out.println("Species: " + pet.getSpecies());
        System.out.println("Breed: " + pet.getBreed());
        System.out.println("Age: " + pet.getAge());
        System.out.println("Gender: " + pet.getGender());
        System.out.println("Description: " + pet.getDescription());
        System.out.println("Health Status: " + pet.getHealthStatus());
        System.out.println("Image Path: " + pet.getImagePath());
        
        try (Connection conn = DBConnection.getConnection()) {
            System.out.println("Connection obtained: " + (conn != null ? "SUCCESS" : "FAILED"));
            if (conn == null) {
                System.out.println("ERROR: Database connection is null!");
                return false;
            }
            
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                System.out.println("PreparedStatement created successfully");

                System.out.println("Setting parameters...");
                ps.setString(1, pet.getPetName());
                ps.setString(2, pet.getSpecies());
                ps.setString(3, pet.getBreed());
                ps.setInt(4, pet.getAge());
                ps.setString(5, pet.getGender());
                ps.setString(6, pet.getDescription() != null ? pet.getDescription() : "");
                ps.setString(7, pet.getHealthStatus() != null ? pet.getHealthStatus() : "");
                ps.setString(8, pet.getImagePath() != null ? pet.getImagePath() : "");
                ps.setInt(9, pet.getId()); 
                System.out.println("Parameters set successfully");

                System.out.println("Executing UPDATE statement...");
                int rowsAffected = ps.executeUpdate();
                System.out.println("Rows affected: " + rowsAffected);
                return rowsAffected > 0;
            } catch (SQLException e) {
                System.out.println("ERROR in PreparedStatement: " + e.getMessage());
                e.printStackTrace();
                return false;
            }
        } catch (SQLException e) {
            System.out.println("ERROR in updatePet: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public boolean deletePetByCustomerId(int customerId) {
        String sql = "DELETE FROM PET WHERE customer_id = ?";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, customerId);
            int rowsAffected = ps.executeUpdate();
            return rowsAffected > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public boolean hasPetInfo(int customerId) {
        String sql = "SELECT COUNT(*) FROM PET WHERE customer_id = ?";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, customerId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    @Override
    public List<Pet> getAllPets() {
        List<Pet> pets = new ArrayList<>();
        String sql = "SELECT * FROM PET ORDER BY created_at DESC";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Pet pet = new Pet(
                        rs.getInt("id"),
                        rs.getInt("customer_id"),
                        rs.getString("pet_name"),
                        rs.getString("species"),
                        rs.getString("breed"),
                        rs.getInt("age"),
                        rs.getString("gender"),
                        rs.getString("description"),
                        rs.getString("health_status"),
                        rs.getString("image_path"),
                        rs.getTimestamp("created_at"),
                        rs.getTimestamp("updated_at")
                );
                pets.add(pet);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return pets;
    }

    @Override
    public List<Pet> searchPetsByName(String keyword) {
        List<Pet> pets = new ArrayList<>();
        String sql = "SELECT * FROM PET WHERE pet_name LIKE ? ORDER BY pet_name";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, "%" + keyword + "%");

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Pet pet = new Pet(
                            rs.getInt("id"),
                            rs.getInt("customer_id"),
                            rs.getString("pet_name"),
                            rs.getString("species"),
                            rs.getString("breed"),
                            rs.getInt("age"),
                            rs.getString("gender"),
                            rs.getString("description"),
                            rs.getString("health_status"),
                            rs.getString("image_path"),
                            rs.getTimestamp("created_at"),
                            rs.getTimestamp("updated_at")
                    );
                    pets.add(pet);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return pets;
    }

    @Override
    public List<Pet> getPetsBySpecies(String species) {
        List<Pet> pets = new ArrayList<>();
        String sql = "SELECT * FROM PET WHERE species = ? ORDER BY pet_name";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, species);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Pet pet = new Pet(
                            rs.getInt("id"),
                            rs.getInt("customer_id"),
                            rs.getString("pet_name"),
                            rs.getString("species"),
                            rs.getString("breed"),
                            rs.getInt("age"),
                            rs.getString("gender"),
                            rs.getString("description"),
                            rs.getString("health_status"),
                            rs.getString("image_path"),
                            rs.getTimestamp("created_at"),
                            rs.getTimestamp("updated_at")
                    );
                    pets.add(pet);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return pets;
    }

    @Override
    public int countPetsBySpecies(String species) {
        String sql = "SELECT COUNT(*) FROM PET WHERE species = ?";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, species);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return 0;
    }

    @Override
    public Map<String, Integer> getPetStatistics() {
        Map<String, Integer> statistics = new HashMap<>();
        String sql = "SELECT species, COUNT(*) as count FROM PET GROUP BY species ORDER BY count DESC";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                statistics.put(rs.getString("species"), rs.getInt("count"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return statistics;
    }
}
