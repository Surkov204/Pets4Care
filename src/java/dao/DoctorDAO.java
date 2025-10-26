package dao;

import model.Doctor;
import utils.DBConnection;
import java.sql.*;
import java.util.logging.Logger;

public class DoctorDAO {
    private static final Logger logger = Logger.getLogger(DoctorDAO.class.getName());

    public Doctor findByEmail(String email) {
        String sql = "SELECT * FROM Doctor WHERE email = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapDoctorFromResultSet(rs);
                }
            }
        } catch (SQLException e) {
            logger.severe("Error finding doctor by email: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }

    public Doctor findById(int doctorId) {
        String sql = "SELECT * FROM Doctor WHERE doctor_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, doctorId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapDoctorFromResultSet(rs);
                }
            }
        } catch (SQLException e) {
            logger.severe("Error finding doctor by ID: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }

    public boolean authenticateDoctor(String email, String password) {
        String sql = "SELECT * FROM Doctor WHERE email = ? AND password = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, email);
            ps.setString(2, password);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            logger.severe("Error authenticating doctor: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    public boolean updateProfile(Doctor doctor) {
        String sql = "UPDATE Doctor SET name = ?, email = ?, phone = ?, specialization = ?, description = ? WHERE doctor_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, doctor.getName());
            ps.setString(2, doctor.getEmail());
            ps.setString(3, doctor.getPhone());
            ps.setString(4, doctor.getSpecialization());
            ps.setString(5, doctor.getScheduleNote()); // Map scheduleNote -> description
            ps.setInt(6, doctor.getDoctorId());
            
            int rowsAffected = ps.executeUpdate();
            logger.info("Doctor profile updated: " + doctor.getDoctorId() + ", rows affected: " + rowsAffected);
            return rowsAffected > 0;
            
        } catch (SQLException e) {
            logger.severe("Error updating doctor profile: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    public boolean updatePassword(int doctorId, String newPassword) {
        String sql = "UPDATE Doctor SET password = ? WHERE doctor_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, newPassword);
            ps.setInt(2, doctorId);
            
            int rowsAffected = ps.executeUpdate();
            logger.info("Doctor password updated: " + doctorId);
            return rowsAffected > 0;
            
        } catch (SQLException e) {
            logger.severe("Error updating doctor password: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    private Doctor mapDoctorFromResultSet(ResultSet rs) throws SQLException {
        Doctor doctor = new Doctor();
        doctor.setDoctorId(rs.getInt("doctor_id"));
        doctor.setName(rs.getString("name"));
        doctor.setEmail(rs.getString("email"));
        doctor.setPhone(rs.getString("phone"));
        doctor.setPassword(rs.getString("password"));
        doctor.setSpecialization(rs.getString("specialization"));
        doctor.setScheduleNote(rs.getString("description")); // Map description -> scheduleNote
        return doctor;
    }
}
