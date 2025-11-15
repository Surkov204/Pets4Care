package dao;

import java.sql.*;
import utils.DBConnection;

public class StaffSalaryDAO {

    // ✅ Lấy lương hiện tại của 1 nhân viên (Staff)
    public Double getHourlyRate(int staffId) {
        String sql = "SELECT HourlyRate FROM StaffSalary WHERE staff_id = ?";
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
    
    // ✅ Lấy lương hiện tại của 1 doctor
    public Double getDoctorHourlyRate(int doctorId) {
        String sql = "SELECT HourlyRate FROM StaffSalary WHERE doctor_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, doctorId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getDouble("HourlyRate");
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    // ✅ Cập nhật hoặc thêm mới lương cho Staff
    public boolean updateHourlyRate(int staffId, double newRate) {
        String checkSql = "SELECT COUNT(*) FROM StaffSalary WHERE staff_id = ?";
        String updateSql = "UPDATE StaffSalary SET HourlyRate = ?, UpdatedAt = GETDATE() WHERE staff_id = ?";
        String insertSql = "INSERT INTO StaffSalary (staff_id, HourlyRate, UpdatedAt) VALUES (?, ?, GETDATE())";

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
    
    // ✅ Cập nhật hoặc thêm mới lương cho Doctor
    public boolean updateDoctorHourlyRate(int doctorId, double newRate) {
        String checkSql = "SELECT COUNT(*) FROM StaffSalary WHERE doctor_id = ?";
        String updateSql = "UPDATE StaffSalary SET HourlyRate = ?, UpdatedAt = GETDATE() WHERE doctor_id = ?";
        String insertSql = "INSERT INTO StaffSalary (doctor_id, HourlyRate, UpdatedAt) VALUES (?, ?, GETDATE())";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement check = con.prepareStatement(checkSql)) {
            check.setInt(1, doctorId);
            ResultSet rs = check.executeQuery();
            rs.next();
            int count = rs.getInt(1);

            if (count > 0) {
                try (PreparedStatement ps = con.prepareStatement(updateSql)) {
                    ps.setDouble(1, newRate);
                    ps.setInt(2, doctorId);
                    return ps.executeUpdate() > 0;
                }
            } else {
                try (PreparedStatement ps = con.prepareStatement(insertSql)) {
                    ps.setInt(1, doctorId);
                    ps.setDouble(2, newRate);
                    return ps.executeUpdate() > 0;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
}
