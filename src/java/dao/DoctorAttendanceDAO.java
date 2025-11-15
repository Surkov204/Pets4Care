package dao;

import java.sql.*;
import java.util.*;
import model.AttendanceRecord;
import utils.DBConnection;

public class DoctorAttendanceDAO {

    // 🟢 Check-in
    public boolean doctorCheckIn(int doctorId) {
        String sql = "{CALL DoctorCheckIn(?)}";
        try (Connection con = DBConnection.getConnection();
             CallableStatement cs = con.prepareCall(sql)) {
            cs.setInt(1, doctorId);
            cs.execute();
            System.out.println("[DoctorAttendanceDAO] ✅ Check-in stored procedure executed for doctorID=" + doctorId);
            return true;
        } catch (SQLException e) {
            System.err.println("[DoctorAttendanceDAO] ❌ Check-in failed: " + e.getMessage());
            return false;
        }
    }

    // 🔴 Check-out
    public boolean doctorCheckOut(int doctorId) {
        String sql = "{CALL DoctorCheckOut(?)}";
        try (Connection con = DBConnection.getConnection();
             CallableStatement cs = con.prepareCall(sql)) {
            cs.setInt(1, doctorId);
            cs.execute();
            System.out.println("[DoctorAttendanceDAO] ✅ Check-out stored procedure executed for doctorID=" + doctorId);
            return true;
        } catch (SQLException e) {
            System.err.println("[DoctorAttendanceDAO] ❌ Check-out failed: " + e.getMessage());
            return false;
        }
    }

    // 🟢 Lấy bản ghi chấm công gần nhất
    public AttendanceRecord getLatestRecord(int doctorId) {
        String sql = "SELECT TOP 1 * FROM AttendanceRecords WHERE doctor_id = ? ORDER BY CheckIn DESC";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, doctorId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return new AttendanceRecord(
                        rs.getInt("AttendanceID"),
                        rs.getInt("doctor_id"),
                        rs.getTimestamp("CheckIn"),
                        rs.getTimestamp("CheckOut"),
                        rs.getDouble("TotalHours"),
                        rs.getString("Status"),
                        rs.getTimestamp("CreatedAt")
                );
            }
        } catch (SQLException e) {
            System.err.println("[DoctorAttendanceDAO] ❌ Error getting latest record: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }

    // 🟢 Lấy tất cả bản ghi chấm công của doctor
    public List<AttendanceRecord> getAllRecords(int doctorId) {
        List<AttendanceRecord> list = new ArrayList<>();
        String sql = "SELECT * FROM AttendanceRecords WHERE doctor_id = ? ORDER BY CheckIn DESC";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, doctorId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(new AttendanceRecord(
                        rs.getInt("AttendanceID"),
                        rs.getInt("doctor_id"),
                        rs.getTimestamp("CheckIn"),
                        rs.getTimestamp("CheckOut"),
                        rs.getDouble("TotalHours"),
                        rs.getString("Status"),
                        rs.getTimestamp("CreatedAt")
                ));
            }
        } catch (SQLException e) {
            System.err.println("[DoctorAttendanceDAO] ❌ Error getting all records: " + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }

    // 🟢 Kiểm tra hôm nay đã check-in chưa
    public boolean hasCheckedInToday(int doctorId) {
        String sql = """
            SELECT COUNT(*) FROM AttendanceRecords 
            WHERE doctor_id = ? AND CAST(CheckIn AS DATE) = CAST(GETDATE() AS DATE)
        """;
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, doctorId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            System.err.println("[DoctorAttendanceDAO] ❌ Error in hasCheckedInToday: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }
}

