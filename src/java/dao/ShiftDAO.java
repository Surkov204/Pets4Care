package dao;

import java.sql.*;
import java.util.*;
import model.Shift;
import utils.DBConnection;

public class ShiftDAO {

    public List<Shift> getAllShifts() {
        List<Shift> list = new ArrayList<>();
        String sql = "SELECT * FROM Shifts";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Shift s = new Shift(
                        rs.getInt("ShiftID"),
                        rs.getString("ShiftCode"),
                        rs.getString("ShiftName"),
                        rs.getString("StartTime"),
                        rs.getString("EndTime"),
                        rs.getInt("BreakMinutes"),
                        rs.getString("Location")
                );
                list.add(s);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public Shift getShiftById(int id) {
        String sql = "SELECT * FROM Shifts WHERE ShiftID=?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new Shift(
                            rs.getInt("ShiftID"),
                            rs.getString("ShiftCode"),
                            rs.getString("ShiftName"),
                            rs.getString("StartTime"),
                            rs.getString("EndTime"),
                            rs.getInt("BreakMinutes"),
                            rs.getString("Location")
                    );
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public void addShift(Shift s) {
        String sql = "INSERT INTO Shifts(ShiftCode, ShiftName, StartTime, EndTime, BreakMinutes, Location) VALUES(?,?,?,?,?,?)";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, s.getShiftCode());
            ps.setString(2, s.getShiftName());
            ps.setString(3, s.getStartTime());
            ps.setString(4, s.getEndTime());
            ps.setInt(5, s.getBreakMinutes());
            ps.setString(6, s.getLocation());
            ps.executeUpdate();

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public void updateShift(Shift s) {
        String sql = "UPDATE Shifts SET ShiftCode=?, ShiftName=?, StartTime=?, EndTime=?, BreakMinutes=?, Location=? WHERE ShiftID=?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, s.getShiftCode());
            ps.setString(2, s.getShiftName());
            ps.setString(3, s.getStartTime());
            ps.setString(4, s.getEndTime());
            ps.setInt(5, s.getBreakMinutes());
            ps.setString(6, s.getLocation());
            ps.setInt(7, s.getShiftID());
            ps.executeUpdate();

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public void deleteShift(int id) {
        String sql = "DELETE FROM Shifts WHERE ShiftID=?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}
