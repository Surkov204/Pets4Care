package dao;

import java.sql.*;
import java.sql.Date;
import java.util.*;
import model.PayrollRecord;
import utils.DBConnection;

public class DoctorPayrollDAO {

    // ✅ Gọi thủ tục tính lương
    public boolean generatePayroll(int doctorId, Date start, Date end) {
        String sql = "{CALL GenerateDoctorPayroll(?, ?, ?)}";
        try (Connection con = DBConnection.getConnection();
             CallableStatement cs = con.prepareCall(sql)) {
            cs.setInt(1, doctorId);
            cs.setDate(2, start);
            cs.setDate(3, end);
            cs.execute();
            return true;
        } catch (SQLException e) {
            System.err.println("[DoctorPayrollDAO] ❌ Generate payroll failed: " + e.getMessage());
            return false;
        }
    }

    // ✅ Lấy danh sách phiếu lương
    public List<PayrollRecord> getPayrollHistory(int doctorId) {
        List<PayrollRecord> list = new ArrayList<>();
        String sql = "SELECT * FROM PayrollRecords WHERE doctor_id = ? ORDER BY CreatedAt DESC";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, doctorId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                PayrollRecord p = new PayrollRecord(
                        rs.getInt("PayrollID"),
                        rs.getInt("doctor_id"),
                        rs.getDate("PeriodStart"),
                        rs.getDate("PeriodEnd"),
                        rs.getDouble("TotalHours"),
                        rs.getDouble("HourlyRate"),
                        rs.getDouble("TotalSalary"),
                        rs.getTimestamp("CreatedAt")
                );
                list.add(p);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // ✅ Lấy phiếu lương mới nhất
    public PayrollRecord getLatestPayroll(int doctorId) {
        String sql = "SELECT TOP 1 * FROM PayrollRecords WHERE doctor_id = ? ORDER BY CreatedAt DESC";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, doctorId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return new PayrollRecord(
                        rs.getInt("PayrollID"),
                        rs.getInt("doctor_id"),
                        rs.getDate("PeriodStart"),
                        rs.getDate("PeriodEnd"),
                        rs.getDouble("TotalHours"),
                        rs.getDouble("HourlyRate"),
                        rs.getDouble("TotalSalary"),
                        rs.getTimestamp("CreatedAt")
                );
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
}

