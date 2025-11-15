package dao;

import java.sql.*;
import utils.DBConnection;

public class StaffSalaryDAO {

    // ✅ Lấy lương hiện tại của 1 nhân viên
    public Double getHourlyRate(int staffId) {
        String sql = "SELECT HourlyRate FROM StaffSalary WHERE StaffID = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, staffId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getDouble("HourlyRate");
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    // ✅ Cập nhật hoặc thêm mới lương
    public boolean updateHourlyRate(int staffId, double newRate) {
        String checkSql = "SELECT COUNT(*) FROM StaffSalary WHERE StaffID = ?";
        String updateSql = "UPDATE StaffSalary SET HourlyRate = ?, UpdatedAt = GETDATE() WHERE StaffID = ?";
        String insertSql = "INSERT INTO StaffSalary (StaffID, HourlyRate, UpdatedAt) VALUES (?, ?, GETDATE())";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement check = con.prepareStatement(checkSql)) {
            check.setInt(1, staffId);
            ResultSet rs = check.executeQuery();
            rs.next();
            int count = rs.getInt(1);

            if (count > 0) {
                try (PreparedStatement ps = con.prepareStatement(updateSql)) {
                    ps.setDouble(1, newRate);
                    ps.setInt(2, staffId);
                    return ps.executeUpdate() > 0;
                }
            } else {
                try (PreparedStatement ps = con.prepareStatement(insertSql)) {
                    ps.setInt(1, staffId);
                    ps.setDouble(2, newRate);
                    return ps.executeUpdate() > 0;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }   
    public Double getMonthlyBaseSalary(int staffId) {
        String sql = "SELECT MonthlyBaseSalary FROM StaffSalary WHERE StaffID = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, staffId);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) 
                return rs.getDouble("MonthlyBaseSalary");

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }

    // 🔹 Lấy số ca chuẩn
    public Integer getStandardShifts(int staffId) {
        String sql = "SELECT StandardShifts FROM StaffSalary WHERE StaffID = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, staffId);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) 
                return rs.getInt("StandardShifts");

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }

    // 🔹 Cập nhật lương tháng và ca chuẩn
    public boolean updateMonthlySalary(int staffId, double monthlySalary, int standardShifts) {

        String checkSql = "SELECT COUNT(*) FROM StaffSalary WHERE StaffID = ?";
        String updateSql = """
            UPDATE StaffSalary
            SET MonthlyBaseSalary = ?, StandardShifts = ?, UpdatedAt = GETDATE()
            WHERE StaffID = ?
        """;
        String insertSql = """
            INSERT INTO StaffSalary (StaffID, MonthlyBaseSalary, StandardShifts, UpdatedAt)
            VALUES (?, ?, ?, GETDATE())
        """;

        try (Connection con = DBConnection.getConnection();
             PreparedStatement check = con.prepareStatement(checkSql)) {

            check.setInt(1, staffId);
            ResultSet rs = check.executeQuery();
            rs.next();

            boolean exists = rs.getInt(1) > 0;

            if (exists) {
                try (PreparedStatement ps = con.prepareStatement(updateSql)) {
                    ps.setDouble(1, monthlySalary);
                    ps.setInt(2, standardShifts);
                    ps.setInt(3, staffId);
                    return ps.executeUpdate() > 0;
                }

            } else {
                try (PreparedStatement ps = con.prepareStatement(insertSql)) {
                    ps.setInt(1, staffId);
                    ps.setDouble(2, monthlySalary);
                    ps.setInt(3, standardShifts);
                    return ps.executeUpdate() > 0;
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }
}
