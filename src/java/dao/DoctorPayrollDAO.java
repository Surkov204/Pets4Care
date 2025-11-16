package dao;

import model.DoctorPayrollRecord;
import utils.DBConnection;

import java.sql.Connection;
import java.sql.Date;
import java.sql.CallableStatement;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class DoctorPayrollDAO {

    // Gọi Stored Procedure tính lương theo tháng
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

    // Lấy lịch sử phiếu lương của một bác sĩ
    public List<DoctorPayrollRecord> getPayrollHistory(int doctorId) {
        List<DoctorPayrollRecord> list = new ArrayList<>();
        String sql = "SELECT * FROM DoctorPayrollRecords WHERE DoctorID = ? ORDER BY CreatedAt DESC";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, doctorId);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                DoctorPayrollRecord p = new DoctorPayrollRecord(
                        rs.getInt("PayrollID"),
                        rs.getInt("DoctorID"),
                        rs.getDate("PeriodStart"),
                        rs.getDate("PeriodEnd"),
                        rs.getInt("DaysWorked"),
                        rs.getInt("StandardWorkingDays"),
                        rs.getDouble("MonthlyBaseSalary"),
                        rs.getDouble("TotalSalary"),
                        rs.getTimestamp("CreatedAt")
                );
                list.add(p);
            }

        } catch (SQLException e) {
            System.err.println("[DoctorPayrollDAO] ❌ getPayrollHistory error: " + e.getMessage());
        }
        return list;
    }

    // Lấy phiếu lương mới nhất của bác sĩ
    public DoctorPayrollRecord getLatestPayroll(int doctorId) {
        String sql = "SELECT TOP 1 * FROM DoctorPayrollRecords WHERE DoctorID = ? ORDER BY CreatedAt DESC";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, doctorId);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                return new DoctorPayrollRecord(
                        rs.getInt("PayrollID"),
                        rs.getInt("DoctorID"),
                        rs.getDate("PeriodStart"),
                        rs.getDate("PeriodEnd"),
                        rs.getInt("DaysWorked"),
                        rs.getInt("StandardWorkingDays"),
                        rs.getDouble("MonthlyBaseSalary"),
                        rs.getDouble("TotalSalary"),
                        rs.getTimestamp("CreatedAt")
                );
            }

        } catch (SQLException e) {
            System.err.println("[DoctorPayrollDAO] ❌ getLatestPayroll error: " + e.getMessage());
        }

        return null;
    }
}