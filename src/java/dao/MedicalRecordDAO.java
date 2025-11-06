package dao;

import model.MedicalRecord;
import utils.DBConnection;

import java.sql.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Logger;

/**
 * DAO class cho Medical Record
 * Xử lý các thao tác CRUD với bảng MedicalRecord
 */
public class MedicalRecordDAO {
    private static final Logger logger = Logger.getLogger(MedicalRecordDAO.class.getName());
    
    /**
     * Tạo medical record mới
     */
    public boolean createMedicalRecord(MedicalRecord record) {
        String sql = "INSERT INTO dbo.MedicalRecord " +
                    "(booking_id, pet_id, doctor_id, customer_id, examination_date, " +
                    "symptoms, diagnosis, treatment, prescription, weight, temperature, " +
                    "heart_rate, blood_pressure, notes, follow_up_date, follow_up_notes) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            ps.setInt(1, record.getBookingId());
            ps.setInt(2, record.getPetId());
            ps.setInt(3, record.getDoctorId());
            ps.setInt(4, record.getCustomerId());
            ps.setTimestamp(5, record.getExaminationDate());
            ps.setString(6, record.getSymptoms());
            ps.setString(7, record.getDiagnosis());
            ps.setString(8, record.getTreatment());
            ps.setString(9, record.getPrescription());
            
            if (record.getWeight() != null) {
                ps.setBigDecimal(10, record.getWeight());
            } else {
                ps.setNull(10, Types.DECIMAL);
            }
            
            if (record.getTemperature() != null) {
                ps.setBigDecimal(11, record.getTemperature());
            } else {
                ps.setNull(11, Types.DECIMAL);
            }
            
            if (record.getHeartRate() != null) {
                ps.setInt(12, record.getHeartRate());
            } else {
                ps.setNull(12, Types.INTEGER);
            }
            
            ps.setString(13, record.getBloodPressure());
            ps.setString(14, record.getNotes());
            
            if (record.getFollowUpDate() != null) {
                ps.setDate(15, Date.valueOf(record.getFollowUpDate()));
            } else {
                ps.setNull(15, Types.DATE);
            }
            
            ps.setString(16, record.getFollowUpNotes());
            
            int rowsAffected = ps.executeUpdate();
            
            if (rowsAffected > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        record.setRecordId(rs.getInt(1));
                    }
                }
                logger.info("Created medical record for booking ID: " + record.getBookingId());
                return true;
            }
            
        } catch (Exception e) {
            logger.severe("Error creating medical record: " + e.getMessage());
            e.printStackTrace();
        }
        
        return false;
    }
    
    /**
     * Cập nhật medical record
     */
    public boolean updateMedicalRecord(MedicalRecord record) {
        String sql = "UPDATE dbo.MedicalRecord SET " +
                    "symptoms = ?, diagnosis = ?, treatment = ?, prescription = ?, " +
                    "weight = ?, temperature = ?, heart_rate = ?, blood_pressure = ?, " +
                    "notes = ?, follow_up_date = ?, follow_up_notes = ? " +
                    "WHERE record_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, record.getSymptoms());
            ps.setString(2, record.getDiagnosis());
            ps.setString(3, record.getTreatment());
            ps.setString(4, record.getPrescription());
            
            if (record.getWeight() != null) {
                ps.setBigDecimal(5, record.getWeight());
            } else {
                ps.setNull(5, Types.DECIMAL);
            }
            
            if (record.getTemperature() != null) {
                ps.setBigDecimal(6, record.getTemperature());
            } else {
                ps.setNull(6, Types.DECIMAL);
            }
            
            if (record.getHeartRate() != null) {
                ps.setInt(7, record.getHeartRate());
            } else {
                ps.setNull(7, Types.INTEGER);
            }
            
            ps.setString(8, record.getBloodPressure());
            ps.setString(9, record.getNotes());
            
            if (record.getFollowUpDate() != null) {
                ps.setDate(10, Date.valueOf(record.getFollowUpDate()));
            } else {
                ps.setNull(10, Types.DATE);
            }
            
            ps.setString(11, record.getFollowUpNotes());
            ps.setInt(12, record.getRecordId());
            
            int rowsAffected = ps.executeUpdate();
            
            if (rowsAffected > 0) {
                logger.info("Updated medical record ID: " + record.getRecordId());
                return true;
            }
            
        } catch (Exception e) {
            logger.severe("Error updating medical record: " + e.getMessage());
            e.printStackTrace();
        }
        
        return false;
    }
    
    /**
     * Lấy medical record theo booking ID
     */
    public MedicalRecord getByBookingId(int bookingId) {
        String sql = "SELECT mr.*, " +
                    "p.name AS pet_name, p.species AS pet_species, " +
                    "d.name AS doctor_name, " +
                    "c.name AS customer_name " +
                    "FROM dbo.MedicalRecord mr " +
                    "LEFT JOIN dbo.Pet p ON mr.pet_id = p.id " +
                    "LEFT JOIN dbo.Doctor d ON mr.doctor_id = d.doctor_id " +
                    "LEFT JOIN dbo.Customer c ON mr.customer_id = c.customer_id " +
                    "WHERE mr.booking_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, bookingId);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToMedicalRecord(rs);
                }
            }
            
        } catch (Exception e) {
            logger.severe("Error getting medical record by booking ID: " + e.getMessage());
            e.printStackTrace();
        }
        
        return null;
    }
    
    /**
     * Lấy tất cả medical records của một pet
     */
    public List<MedicalRecord> getByPetId(int petId) {
        List<MedicalRecord> records = new ArrayList<>();
        String sql = "SELECT mr.*, " +
                    "p.name AS pet_name, p.species AS pet_species, " +
                    "d.name AS doctor_name, " +
                    "c.name AS customer_name " +
                    "FROM dbo.MedicalRecord mr " +
                    "LEFT JOIN dbo.Pet p ON mr.pet_id = p.id " +
                    "LEFT JOIN dbo.Doctor d ON mr.doctor_id = d.doctor_id " +
                    "LEFT JOIN dbo.Customer c ON mr.customer_id = c.customer_id " +
                    "WHERE mr.pet_id = ? " +
                    "ORDER BY mr.examination_date DESC";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, petId);
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    records.add(mapResultSetToMedicalRecord(rs));
                }
            }
            
        } catch (Exception e) {
            logger.severe("Error getting medical records by pet ID: " + e.getMessage());
            e.printStackTrace();
        }
        
        return records;
    }
    
    /**
     * Lấy tất cả medical records của một doctor
     */
    public List<MedicalRecord> getByDoctorId(int doctorId) {
        List<MedicalRecord> records = new ArrayList<>();
        String sql = "SELECT mr.*, " +
                    "p.name AS pet_name, p.species AS pet_species, " +
                    "d.name AS doctor_name, " +
                    "c.name AS customer_name " +
                    "FROM dbo.MedicalRecord mr " +
                    "LEFT JOIN dbo.Pet p ON mr.pet_id = p.id " +
                    "LEFT JOIN dbo.Doctor d ON mr.doctor_id = d.doctor_id " +
                    "LEFT JOIN dbo.Customer c ON mr.customer_id = c.customer_id " +
                    "WHERE mr.doctor_id = ? " +
                    "ORDER BY mr.examination_date DESC";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, doctorId);
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    records.add(mapResultSetToMedicalRecord(rs));
                }
            }
            
        } catch (Exception e) {
            logger.severe("Error getting medical records by doctor ID: " + e.getMessage());
            e.printStackTrace();
        }
        
        return records;
    }
    
    /**
     * Map ResultSet to MedicalRecord object
     */
    private MedicalRecord mapResultSetToMedicalRecord(ResultSet rs) throws SQLException {
        MedicalRecord record = new MedicalRecord();
        
        record.setRecordId(rs.getInt("record_id"));
        record.setBookingId(rs.getInt("booking_id"));
        record.setPetId(rs.getInt("pet_id"));
        record.setDoctorId(rs.getInt("doctor_id"));
        record.setCustomerId(rs.getInt("customer_id"));
        record.setExaminationDate(rs.getTimestamp("examination_date"));
        record.setSymptoms(rs.getString("symptoms"));
        record.setDiagnosis(rs.getString("diagnosis"));
        record.setTreatment(rs.getString("treatment"));
        record.setPrescription(rs.getString("prescription"));
        record.setWeight(rs.getBigDecimal("weight"));
        record.setTemperature(rs.getBigDecimal("temperature"));
        
        int heartRate = rs.getInt("heart_rate");
        if (!rs.wasNull()) {
            record.setHeartRate(heartRate);
        }
        
        record.setBloodPressure(rs.getString("blood_pressure"));
        record.setNotes(rs.getString("notes"));
        
        Date followUpDate = rs.getDate("follow_up_date");
        if (followUpDate != null) {
            record.setFollowUpDate(followUpDate.toLocalDate());
        }
        
        record.setFollowUpNotes(rs.getString("follow_up_notes"));
        record.setCreatedAt(rs.getTimestamp("created_at"));
        record.setUpdatedAt(rs.getTimestamp("updated_at"));
        
        // Thông tin bổ sung từ JOIN
        record.setPetName(rs.getString("pet_name"));
        record.setPetSpecies(rs.getString("pet_species"));
        record.setDoctorName(rs.getString("doctor_name"));
        record.setCustomerName(rs.getString("customer_name"));
        
        return record;
    }
}

