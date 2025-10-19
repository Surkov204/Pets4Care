package dao;

import java.sql.*;
import java.util.*;
import model.WorkSchedule;
import utils.DBConnection;

public class WorkScheduleDAO {

    public List<WorkSchedule> getAllSchedules() {
        List<WorkSchedule> list = new ArrayList<>();
        String sql = "SELECT * FROM WorkSchedule ORDER BY work_date DESC";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                WorkSchedule ws = new WorkSchedule(
                        rs.getInt("schedule_id"),
                        (Integer) rs.getObject("doctor_id"),
                        (Integer) rs.getObject("staff_id"),
                        rs.getDate("work_date"),
                        rs.getTime("start_time"),
                        rs.getTime("end_time"),
                        rs.getString("status"),
                        rs.getString("note")
                );
                list.add(ws);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public void addSchedule(WorkSchedule ws) {
        String sql = "INSERT INTO WorkSchedule(doctor_id, staff_id, work_date, start_time, end_time, status, note) VALUES(?,?,?,?,?,?,?)";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setObject(1, ws.getDoctorId());
            ps.setObject(2, ws.getStaffId());
            ps.setDate(3, ws.getWorkDate());
            ps.setTime(4, ws.getStartTime());
            ps.setTime(5, ws.getEndTime());
            ps.setString(6, ws.getStatus());
            ps.setString(7, ws.getNote());
            ps.executeUpdate();

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public void updateSchedule(WorkSchedule ws) {
        String sql = "UPDATE WorkSchedule SET doctor_id=?, staff_id=?, work_date=?, start_time=?, end_time=?, status=?, note=? WHERE schedule_id=?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setObject(1, ws.getDoctorId());
            ps.setObject(2, ws.getStaffId());
            ps.setDate(3, ws.getWorkDate());
            ps.setTime(4, ws.getStartTime());
            ps.setTime(5, ws.getEndTime());
            ps.setString(6, ws.getStatus());
            ps.setString(7, ws.getNote());
            ps.setInt(8, ws.getScheduleId());
            ps.executeUpdate();

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public void deleteSchedule(int id) {
        String sql = "DELETE FROM WorkSchedule WHERE schedule_id=?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
    
    public List<WorkSchedule> getScheduleByStaff(int staffId) {
    List<WorkSchedule> list = new ArrayList<>();
    String sql = "SELECT * FROM WorkSchedule WHERE staff_id = ? ORDER BY work_date ASC";
    try (Connection con = DBConnection.getConnection();
         PreparedStatement ps = con.prepareStatement(sql)) {
        ps.setInt(1, staffId);
        try (ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                WorkSchedule ws = new WorkSchedule(
                        rs.getInt("schedule_id"),
                        (Integer) rs.getObject("doctor_id"),
                        (Integer) rs.getObject("staff_id"),
                        rs.getDate("work_date"),
                        rs.getTime("start_time"),
                        rs.getTime("end_time"),
                        rs.getString("status"),
                        rs.getString("note")
                );
                list.add(ws);
            }
        }
    } catch (SQLException e) {
        e.printStackTrace();
    }
    return list;
}
}
