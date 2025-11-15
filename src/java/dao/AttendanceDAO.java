package dao;

import java.sql.*;
import java.util.*;
import model.AttendanceRecord;
import utils.DBConnection;

public class AttendanceDAO {

    // 🟢 Check-in
    public boolean staffCheckIn(int staffId, boolean isLate) {
        String sql = "{CALL StaffCheckIn(?, ?)}";

        try (Connection con = DBConnection.getConnection(); CallableStatement cs = con.prepareCall(sql)) {

            cs.setInt(1, staffId);
            cs.setString(2, isLate ? "LATE" : "ONTIME");
            cs.execute();

            return true;
        } catch (SQLException e) {
            System.err.println("[AttendanceDAO] ❌ Check-in failed: " + e.getMessage());
            return false;
        }
    }

    // 🟢 Check-out
    public boolean staffCheckOut(int staffId) {
        String sql = "{CALL StaffCheckOut(?)}";
        try (Connection con = DBConnection.getConnection(); CallableStatement cs = con.prepareCall(sql)) {
            cs.setInt(1, staffId);
            cs.execute();
            System.out.println("[AttendanceDAO] ✅ Check-out stored procedure executed for staffID=" + staffId);
            return true;
        } catch (SQLException e) {
            System.err.println("[AttendanceDAO] ❌ Check-out failed: " + e.getMessage());
            return false;
        }
    }

    // 🟢 Lấy danh sách chấm công theo nhân viên
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

            System.out.println("[AttendanceDAO] ✅ getAttendanceByStaff(" + staffId + ") -> " + list.size() + " record(s)");

        } catch (SQLException e) {
            System.err.println("[AttendanceDAO] ❌ Error in getAttendanceByStaff: " + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }

    // 🟢 Lấy bản ghi mới nhất để kiểm tra đang làm hay đã checkout
    public AttendanceRecord getLatestRecord(int staffId) {
        String sql = "SELECT TOP 1 * FROM AttendanceRecords WHERE StaffID = ? ORDER BY CheckIn DESC";
        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, staffId);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                AttendanceRecord record = new AttendanceRecord();
                record.setAttendanceID(rs.getInt("AttendanceID"));
                record.setStaffID(rs.getInt("StaffID"));
                record.setCheckIn(rs.getTimestamp("CheckIn"));
                record.setCheckOut(rs.getTimestamp("CheckOut"));
                record.setTotalHours(rs.getDouble("TotalHours"));
                record.setStatus(rs.getString("Status"));
                record.setCreatedAt(rs.getTimestamp("CreatedAt"));
                return record;
            }

        } catch (SQLException e) {
            System.err.println("[AttendanceDAO] ❌ Error in getLatestRecord: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }

    // 🟢 Kiểm tra hôm nay đã check-in chưa (phòng trường hợp gọi thủ công từ service khác)
    public boolean hasCheckedInToday(int staffId) {
        String sql = """
            SELECT COUNT(*) FROM AttendanceRecords 
            WHERE StaffID = ? AND CAST(CheckIn AS DATE) = CAST(GETDATE() AS DATE)
        """;
        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, staffId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            System.err.println("[AttendanceDAO] ❌ Error in hasCheckedInToday: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }
    
    // 🟢 Lấy bản ghi chấm công của hôm nay (nếu có)
    public AttendanceRecord getTodayRecord(int staffId) {
        String sql = """
        SELECT TOP 1 *
        FROM AttendanceRecords
        WHERE StaffID = ?
          AND CAST(CheckIn AS DATE) = CAST(GETDATE() AS DATE)
        ORDER BY CheckIn DESC
    """;

        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, staffId);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                AttendanceRecord record = new AttendanceRecord();
                record.setAttendanceID(rs.getInt("AttendanceID"));
                record.setStaffID(rs.getInt("StaffID"));
                record.setCheckIn(rs.getTimestamp("CheckIn"));
                record.setCheckOut(rs.getTimestamp("CheckOut"));
                record.setTotalHours(rs.getDouble("TotalHours"));
                record.setStatus(rs.getString("Status"));
                record.setCreatedAt(rs.getTimestamp("CreatedAt"));
                return record;
            }

        } catch (SQLException e) {
            System.err.println("[AttendanceDAO] ❌ Error in getTodayRecord: " + e.getMessage());
        }

        return null;
    }
    
    
}
