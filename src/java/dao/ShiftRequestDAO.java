package dao;

import java.sql.*;
import java.util.*;
import model.ShiftRequest;
import utils.DBConnection;

public class ShiftRequestDAO {

    public List<ShiftRequest> getAllRequests() {
        List<ShiftRequest> list = new ArrayList<>();
        String sql = "SELECT * FROM ShiftRequests ORDER BY CreatedAt DESC";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                ShiftRequest r = new ShiftRequest(
                        rs.getInt("RequestID"),
                        rs.getInt("EmployeeID"),
                        rs.getString("Type"),
                        rs.getDate("TargetDate"),
                        rs.getInt("FromShiftID"),
                        rs.getInt("ToShiftID"),
                        rs.getString("Reason"),
                        rs.getString("Status"),
                        (Integer) rs.getObject("ApprovedBy"),
                        rs.getTimestamp("CreatedAt")
                );
                list.add(r);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public void addRequest(ShiftRequest r) {
        String sql = "INSERT INTO ShiftRequests(EmployeeID, Type, TargetDate, FromShiftID, ToShiftID, Reason, Status, ApprovedBy, CreatedAt) VALUES(?,?,?,?,?,?,?,?,GETDATE())";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, r.getEmployeeID());
            ps.setString(2, r.getType());
            ps.setDate(3, r.getTargetDate());
            ps.setInt(4, r.getFromShiftID());
            ps.setInt(5, r.getToShiftID());
            ps.setString(6, r.getReason());
            ps.setString(7, r.getStatus());
            ps.setObject(8, r.getApprovedBy());
            ps.executeUpdate();

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public void updateStatus(int id, String status, Integer approvedBy) {
        String sql = "UPDATE ShiftRequests SET Status=?, ApprovedBy=? WHERE RequestID=?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setObject(2, approvedBy);
            ps.setInt(3, id);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public void deleteRequest(int id) {
        String sql = "DELETE FROM ShiftRequests WHERE RequestID=?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}
