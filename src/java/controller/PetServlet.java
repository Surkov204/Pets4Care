package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Logger;



import model.Customer;
import utils.DBConnection;

/**
 * Servlet để lấy thông tin thú cưng của khách hàng
 */
@WebServlet("/pet-info")
public class PetServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final Logger logger = Logger.getLogger(PetServlet.class.getName());

    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        PrintWriter out = response.getWriter();
        
        try {
            // Lấy thông tin customer từ session
            HttpSession session = request.getSession(false);
            if (session == null) {
                out.write("{\"error\": \"Session not found\"}");
                return;
            }
            
            Customer customer = (Customer) session.getAttribute("currentUser");
            if (customer == null) {
                out.write("{\"error\": \"Customer not logged in\"}");
                return;
            }
            
            int customerId = customer.getCustomerId();
            logger.info("Getting pet info for customer ID: " + customerId);
            
            // Lấy danh sách thú cưng từ database
            List<PetInfo> pets = getPetsByCustomerId(customerId);
            
            // Tạo JSON response
            StringBuilder json = new StringBuilder();
            json.append("{\"pets\":[");
            
            for (int i = 0; i < pets.size(); i++) {
                PetInfo pet = pets.get(i);
                if (i > 0) json.append(",");
                json.append("{");
                json.append("\"id\":").append(pet.getId()).append(",");
                json.append("\"name\":\"").append(escapeJson(pet.getName())).append("\",");
                json.append("\"species\":\"").append(escapeJson(pet.getSpecies())).append("\",");
                json.append("\"breed\":\"").append(escapeJson(pet.getBreed())).append("\",");
                json.append("\"age\":").append(pet.getAge()).append(",");
                json.append("\"weight\":").append(pet.getWeight()).append(",");
                json.append("\"gender\":\"").append(escapeJson(pet.getGender())).append("\",");
                json.append("\"healthStatus\":\"").append(escapeJson(pet.getHealthStatus())).append("\",");
                json.append("\"specialNotes\":\"").append(escapeJson(pet.getSpecialNotes())).append("\"");
                json.append("}");
            }
            
            json.append("]}");
            
            out.write(json.toString());
            logger.info("Returned " + pets.size() + " pets for customer " + customerId);
            
        } catch (Exception e) {
            logger.severe("Error getting pet info: " + e.getMessage());
            e.printStackTrace();
            out.write("{\"error\": \"Database error: " + escapeJson(e.getMessage()) + "\"}");
        }
    }
    
    private List<PetInfo> getPetsByCustomerId(int customerId) throws SQLException {
        List<PetInfo> pets = new ArrayList<>();
        
        String sql = "SELECT id, pet_name, species, breed, age, gender, description, health_status " +
                    "FROM Pet WHERE customer_id = ? ORDER BY pet_name";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, customerId);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    PetInfo pet = new PetInfo();
                    pet.setId(rs.getInt("id"));
                    pet.setName(rs.getString("pet_name"));
                    pet.setSpecies(rs.getString("species"));
                    pet.setBreed(rs.getString("breed"));
                    pet.setAge(rs.getInt("age"));
                    pet.setWeight(0.0); // Không có cột weight trong database
                    pet.setGender(rs.getString("gender"));
                    pet.setHealthStatus(rs.getString("health_status"));
                    pet.setSpecialNotes(rs.getString("description")); // Sử dụng description thay vì special_notes
                    
                    pets.add(pet);
                    logger.info("Found pet: " + pet.getName() + " (" + pet.getSpecies() + ")");
                }
            }
        }
        
        return pets;
    }
    
    private String escapeJson(String str) {
        if (str == null) return "";
        return str.replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "\\r");
    }
    
    // Inner class để chứa thông tin thú cưng
    public static class PetInfo {
        private int id;
        private String name;
        private String species;
        private String breed;
        private int age;
        private double weight;
        private String gender;
        private String healthStatus;
        private String specialNotes;
        
        // Getters and Setters
        public int getId() { return id; }
        public void setId(int id) { this.id = id; }
        
        public String getName() { return name; }
        public void setName(String name) { this.name = name; }
        
        public String getSpecies() { return species; }
        public void setSpecies(String species) { this.species = species; }
        
        public String getBreed() { return breed; }
        public void setBreed(String breed) { this.breed = breed; }
        
        public int getAge() { return age; }
        public void setAge(int age) { this.age = age; }
        
        public double getWeight() { return weight; }
        public void setWeight(double weight) { this.weight = weight; }
        
        public String getGender() { return gender; }
        public void setGender(String gender) { this.gender = gender; }
        
        public String getHealthStatus() { return healthStatus; }
        public void setHealthStatus(String healthStatus) { this.healthStatus = healthStatus; }
        
        public String getSpecialNotes() { return specialNotes; }
        public void setSpecialNotes(String specialNotes) { this.specialNotes = specialNotes; }
    }
}

