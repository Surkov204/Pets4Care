package dao;

import java.sql.*;
import java.util.*;
import model.AttendanceRecord;
import utils.DBConnection;

public class AttendanceDAO {

    // ✅ Check-in
    public boolean staffCheckIn(int staffId) {
        String sql = "{CALL StaffCheckIn(?)}";
        try (Connection con = DBConnection.getConnection(); CallableStatement cs = con.prepareCall(sql)) {
            cs.setInt(1, staffId);
            cs.execute();
            return true;
        } catch (SQLException e) {
            System.err.println("[AttendanceDAO] ❌ Check-in failed: " + e.getMessage());
            return false;
        }
    }

    // ✅ Check-out
    public boolean staffCheckOut(int staffId) {
        String sql = "{CALL StaffCheckOut(?)}";
        try (Connection con = DBConnection.getConnection(); CallableStatement cs = con.prepareCall(sql)) {
            cs.setInt(1, staffId);
            cs.execute();
            return true;
        } catch (SQLException e) {
            System.err.println("[AttendanceDAO] ❌ Check-out failed: " + e.getMessage());
            return false;
        }
    }

    // ✅ Lấy danh sách chấm công
    public List<AttendanceRecord> getAttendanceByStaff(int staffId) {
        List<AttendanceRecord> list = new ArrayList<>();
        String sql = "SELECT * FROM AttendanceRecords WHERE StaffID = ? ORDER BY CheckIn DESC";
        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, staffId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                AttendanceRecord a = new AttendanceRecord(
                        rs.getInt("AttendanceID"),
                        rs.getInt("StaffID"),
                        rs.getTimestamp("CheckIn"),
                        rs.getTimestamp("CheckOut"),
                        rs.getDouble("TotalHours"),
                        rs.getString("Status"),
                        rs.getTimestamp("CreatedAt")
                );
                list.add(a);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public AttendanceRecord getLatestRecord(int staffId) {
        String sql = "SELECT TOP 1 * FROM AttendanceRecords WHERE StaffID = ? ORDER BY CheckIn DESC";
        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, staffId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return new AttendanceRecord(
                        rs.getInt("AttendanceID"),
                        rs.getInt("StaffID"),
                        rs.getTimestamp("CheckIn"),
                        rs.getTimestamp("CheckOut"),
                        rs.getDouble("TotalHours"),
                        rs.getString("Status"),
                        rs.getTimestamp("CreatedAt")
                );
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
}
