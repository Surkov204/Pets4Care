package dao;

import model.MedicalRecord;
import utils.DBConnection;

import java.sql.*;
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
     * @throws SQLException nếu có lỗi database hoặc constraint violation
     */
    public boolean createMedicalRecord(MedicalRecord record) throws SQLException {
        String sql = "INSERT INTO dbo.MedicalRecord " +
                    "(booking_id, pet_id, doctor_id, customer_id, examination_date, " +
                    "symptoms, diagnosis, treatment, prescription, weight, temperature, " +
                    "heart_rate, blood_pressure, notes, follow_up_date, follow_up_notes) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            // booking_id is NOT NULL in database, so it must have a value
            // For manual records, we should create a dummy booking or use 0 (but this might cause FK constraint issues)
            // For now, we'll require booking_id to be > 0
            if (record.getBookingId() <= 0) {
                logger.severe("Cannot create medical record: booking_id is required and must be > 0");
                throw new SQLException("booking_id is required for medical record creation");
            }
            ps.setInt(1, record.getBookingId());
            ps.setInt(2, record.getPetId());
            ps.setInt(3, record.getDoctorId());
            ps.setInt(4, record.getCustomerId());
            
            // Đảm bảo examination_date không NULL
            if (record.getExaminationDate() == null) {
                logger.warning("examination_date is null, setting to current timestamp");
                record.setExaminationDate(new Timestamp(System.currentTimeMillis()));
            }
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
            } else {
                logger.warning("No rows affected when creating medical record");
                return false;
            }
            
        } catch (SQLException e) {
            logger.severe("SQL Error creating medical record: " + e.getMessage());
            logger.severe("SQL State: " + e.getSQLState() + ", Error Code: " + e.getErrorCode());
            if (e.getErrorCode() == 547) {
                logger.severe("Foreign key constraint violation - check if booking_id, pet_id, customer_id, or doctor_id exists");
            }
            e.printStackTrace();
            throw e; // Re-throw to let controller handle it
        } catch (Exception e) {
            logger.severe("Error creating medical record: " + e.getMessage());
            e.printStackTrace();
            throw e; // Re-throw to let controller handle it
        }
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
                    "p.pet_name AS pet_name, p.species AS pet_species, " +
                    "d.[name] AS doctor_name, " +
                    "c.[name] AS customer_name, " +
                    "b.appointment_start, b.appointment_end, b.[status] AS booking_status, b.note AS booking_note " +
                    "FROM dbo.MedicalRecord mr " +
                    "LEFT JOIN dbo.Pet p ON mr.pet_id = p.id " +
                    "LEFT JOIN dbo.Doctor d ON mr.doctor_id = d.doctor_id " +
                    "LEFT JOIN dbo.Customer c ON mr.customer_id = c.customer_id " +
                    "LEFT JOIN dbo.Booking b ON mr.booking_id = b.booking_id " +
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
                    "p.pet_name AS pet_name, p.species AS pet_species, " +
                    "d.[name] AS doctor_name, " +
                    "c.[name] AS customer_name " +
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
     * Lấy medical record theo record ID
     */
    public MedicalRecord getByRecordId(int recordId) {
        String sql = "SELECT mr.*, " +
                    "p.pet_name AS pet_name, p.species AS pet_species, " +
                    "d.[name] AS doctor_name, " +
                    "c.[name] AS customer_name " +
                    "FROM dbo.MedicalRecord mr " +
                    "LEFT JOIN dbo.Pet p ON mr.pet_id = p.id " +
                    "LEFT JOIN dbo.Doctor d ON mr.doctor_id = d.doctor_id " +
                    "LEFT JOIN dbo.Customer c ON mr.customer_id = c.customer_id " +
                    "WHERE mr.record_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, recordId);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToMedicalRecord(rs);
                }
            }
            
        } catch (Exception e) {
            logger.severe("Error getting medical record by record ID: " + e.getMessage());
            e.printStackTrace();
        }
        
        return null;
    }
    
    /**
     * Lấy tất cả medical records của một doctor trong 3 tháng gần đây
     */
    public List<MedicalRecord> getByDoctorId(int doctorId) {
        List<MedicalRecord> records = new ArrayList<>();
        // Lọc theo 3 tháng gần đây để phù hợp với thông báo trên JSP
        String sql = "SELECT mr.*, " +
                    "p.pet_name AS pet_name, p.species AS pet_species, " +
                    "d.[name] AS doctor_name, " +
                    "c.[name] AS customer_name, " +
                    "b.appointment_start, b.appointment_end, b.[status] AS booking_status, b.note AS booking_note " +
                    "FROM dbo.MedicalRecord mr " +
                    "LEFT JOIN dbo.Pet p ON mr.pet_id = p.id " +
                    "LEFT JOIN dbo.Doctor d ON mr.doctor_id = d.doctor_id " +
                    "LEFT JOIN dbo.Customer c ON mr.customer_id = c.customer_id " +
                    "LEFT JOIN dbo.Booking b ON mr.booking_id = b.booking_id " +
                    "WHERE mr.doctor_id = ? " +
                    "AND (mr.examination_date IS NULL OR mr.examination_date >= DATEADD(MONTH, -3, GETDATE())) " +
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
        // Handle booking_id - can be NULL for manual records
        int bookingId = rs.getInt("booking_id");
        if (rs.wasNull()) {
            record.setBookingId(0); // Use 0 to indicate no booking
        } else {
            record.setBookingId(bookingId);
        }
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
        
        // Thông tin bổ sung từ JOIN - xử lý NULL an toàn
        String petName = rs.getString("pet_name");
        record.setPetName(petName); // Có thể là null, nhưng setter sẽ xử lý
        String petSpecies = rs.getString("pet_species");
        record.setPetSpecies(petSpecies);
        String doctorName = rs.getString("doctor_name");
        record.setDoctorName(doctorName);
        String customerName = rs.getString("customer_name");
        record.setCustomerName(customerName);

        // Thông tin booking từ JOIN - xử lý an toàn các cột có thể không tồn tại
        try {
            Timestamp appointmentStart = rs.getTimestamp("appointment_start");
            if (appointmentStart != null) {
                record.setAppointmentStart(appointmentStart);
            }
        } catch (SQLException e) {
            // Cột không tồn tại trong ResultSet, bỏ qua
        }
        try {
            Timestamp appointmentEnd = rs.getTimestamp("appointment_end");
            if (appointmentEnd != null) {
                record.setAppointmentEnd(appointmentEnd);
            }
        } catch (SQLException e) {
            // Cột không tồn tại trong ResultSet, bỏ qua
        }
        try {
            String bookingStatus = rs.getString("booking_status");
            if (bookingStatus != null) {
                record.setBookingStatus(bookingStatus);
            }
        } catch (SQLException e) {
            // Cột không tồn tại trong ResultSet, bỏ qua
        }
        try {
            String bookingNote = rs.getString("booking_note");
            if (bookingNote != null) {
                record.setBookingNote(bookingNote);
            }
        } catch (SQLException e) {
            // Cột không tồn tại trong ResultSet, bỏ qua
        }
        // Các thông tin booking khác (customer_name, pet_name, etc.) đã có từ JOIN với Customer và Pet
        // Không cần lấy lại từ Booking vì các cột đó không tồn tại trong bảng Booking

        return record;
    }
}

