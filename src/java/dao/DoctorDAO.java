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

    private Doctor mapDoctorFromResultSet(ResultSet rs) throws SQLException {
        Doctor doctor = new Doctor();

        // Handle both legacy camelCase and new snake_case column names
        doctor.setDoctorId(getIntByAny(rs, "doctor_id", "doctorId"));
        doctor.setName(rs.getString("name"));
        doctor.setEmail(rs.getString("email"));
        doctor.setPhone(rs.getString("phone"));
        doctor.setPassword(getStringByAny(rs, "password"));
        doctor.setSpecialization(getStringByAny(rs, "specialization", "specializaton", "specializ", "speciality"));
        doctor.setScheduleNote(getStringByAny(rs, "schedule_note", "scheduleNote", "schedule"));
        return doctor;
    }

    private boolean hasColumn(ResultSet rs, String columnLabel) throws SQLException {
        ResultSetMetaData meta = rs.getMetaData();
        int count = meta.getColumnCount();
        for (int i = 1; i <= count; i++) {
            if (columnLabel.equalsIgnoreCase(meta.getColumnLabel(i))) {
                return true;
            }
        }
        return false;
    }

    private int getIntByAny(ResultSet rs, String... candidates) throws SQLException {
        for (String name : candidates) {
            if (hasColumn(rs, name)) {
                return rs.getInt(name);
            }
        }
        return 0;
    }

    private String getStringByAny(ResultSet rs, String... candidates) throws SQLException {
        for (String name : candidates) {
            if (hasColumn(rs, name)) {
                return rs.getString(name);
            }
        }
        return null;
    }

    /**
     * Get any active doctor's ID for assignment fallback
     */
    public int getAnyActiveDoctorId() {
        final String sql = "SELECT TOP 1 doctor_id FROM Doctor WHERE status IS NULL OR LOWER(status) = 'active' ORDER BY doctor_id";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            logger.severe("Error getting any active doctor id: " + e.getMessage());
        }
        return 0;
    }
}
