package dao;

import model.WorkSchedule;
import utils.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ShiftRegistrationDAO {

    public List<WorkSchedule> getRegisteredShifts(int staffId, Date start, Date end) {
        List<WorkSchedule> list = new ArrayList<>();
        String sql = """
            SELECT * FROM WorkSchedule 
            WHERE StaffId = ? AND WorkDate BETWEEN ? AND ?
            """;

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, staffId);
            ps.setDate(2, start);
            ps.setDate(3, end);

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                WorkSchedule ws = new WorkSchedule();
                ws.setScheduleId(rs.getInt("ScheduleId"));
                ws.setStaffId(rs.getInt("StaffId"));
                ws.setShiftId(rs.getInt("ShiftId"));
                ws.setWorkDate(rs.getDate("WorkDate"));
                ws.setStatus(rs.getString("Status"));
                list.add(ws);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean registerShift(int staffId, int shiftId, Date workDate) {
        String sql = """
            INSERT INTO WorkSchedule (StaffId, ShiftId, WorkDate, Status)
            VALUES (?, ?, ?, 'registered')
            """;

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, staffId);
            ps.setInt(2, shiftId);
            ps.setDate(3, workDate);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean cancelShift(int staffId, int shiftId, Date workDate) {
        String sql = """
            DELETE FROM WorkSchedule 
            WHERE StaffId = ? AND ShiftId = ? AND WorkDate = ? AND Status = 'registered'
            """;

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, staffId);
            ps.setInt(2, shiftId);
            ps.setDate(3, workDate);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
}
