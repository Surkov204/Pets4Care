package dao;

import java.sql.*;
import java.time.LocalDate;
import java.util.*;
import java.sql.Date;
import model.ShiftRequest;
import utils.DBConnection;

public class ShiftRequestDAO {

    // 📋 Lấy toàn bộ yêu cầu (cho Admin)
    public List<ShiftRequest> getAllRequests() {
        List<ShiftRequest> list = new ArrayList<>();
        String sql = "SELECT * FROM ShiftRequests ORDER BY CreatedAt DESC";
        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                ShiftRequest r = new ShiftRequest(
                        rs.getInt("RequestID"),
                        rs.getInt("EmployeeID"),
                        rs.getInt("ToStaffID"),
                        rs.getString("Type"),
                        rs.getDate("FromDate"),
                        rs.getDate("ToDate"),
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

    // ➕ Thêm yêu cầu đổi ca
    public void addRequest(ShiftRequest r) {
        String sql = """
    INSERT INTO ShiftRequests
    (EmployeeID, ToStaffID, Type, TargetDate, FromDate, ToDate, FromShiftID, ToShiftID,
     Reason, Status, ApprovedBy, CreatedAt)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, GETDATE())
""";

        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, r.getEmployeeID());
            ps.setInt(2, r.getToStaffID());
            ps.setString(3, r.getType());

            // 👇 Nếu bạn muốn TargetDate = ngày đổi ca ban đầu
            ps.setDate(4, r.getFromDate());

            ps.setDate(5, r.getFromDate());
            ps.setDate(6, r.getToDate());
            ps.setInt(7, r.getFromShiftID());
            ps.setInt(8, r.getToShiftID());
            ps.setString(9, r.getReason());
            ps.setString(10, r.getStatus());
            ps.setObject(11, r.getApprovedBy());

            ps.executeUpdate();
            System.out.println("[ShiftRequestDAO] ✅ Insert yêu cầu đổi ca thành công.");

        } catch (SQLException e) {
            System.err.println("[ShiftRequestDAO] ❌ Lỗi khi insert yêu cầu đổi ca:");
            e.printStackTrace();
        }
    }

    // 🔎 Lấy request theo ID (dành cho Admin duyệt)
    public ShiftRequest getById(int id) {
        String sql = "SELECT * FROM ShiftRequests WHERE RequestID = ?";
        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                return new ShiftRequest(
                        rs.getInt("RequestID"),
                        rs.getInt("EmployeeID"),
                        rs.getInt("ToStaffID"),
                        rs.getString("Type"),
                        rs.getDate("FromDate"),
                        rs.getDate("ToDate"),
                        rs.getInt("FromShiftID"),
                        rs.getInt("ToShiftID"),
                        rs.getString("Reason"),
                        rs.getString("Status"),
                        (Integer) rs.getObject("ApprovedBy"),
                        rs.getTimestamp("CreatedAt")
                );
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    // 🔎 Lấy request cho một nhân viên (để hiển thị thông báo)
    public List<ShiftRequest> getRequestsForStaff(int staffId) {
        List<ShiftRequest> list = new ArrayList<>();
        String sql = "SELECT * FROM ShiftRequests WHERE ToStaffID = ? AND Status = 'Pending'";
        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, staffId);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                ShiftRequest r = new ShiftRequest(
                        rs.getInt("RequestID"),
                        rs.getInt("EmployeeID"),
                        rs.getInt("ToStaffID"),
                        rs.getString("Type"),
                        rs.getDate("FromDate"),
                        rs.getDate("ToDate"),
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

    // 🟢 Cập nhật trạng thái
    public void updateStatus(int id, String status, Integer approvedBy) {
        String sql = "UPDATE ShiftRequests SET Status = ?, ApprovedBy = ? WHERE RequestID = ?";
        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setObject(2, approvedBy);
            ps.setInt(3, id);
            ps.executeUpdate();
            System.out.println("[ShiftRequestDAO] ✅ Cập nhật trạng thái yêu cầu #" + id);
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    // ❌ Xóa yêu cầu
    public void deleteRequest(int id) {
        String sql = "DELETE FROM ShiftRequests WHERE RequestID = ?";
        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.executeUpdate();
            System.out.println("[ShiftRequestDAO] 🗑 Đã xóa yêu cầu #" + id);
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public boolean swapShift(int requestId) {
        String getSql = "SELECT EmployeeID, ToStaffID, FromDate, ToDate FROM ShiftRequests WHERE RequestID = ?";
        String updateA = "UPDATE WorkSchedule SET staff_id = ? WHERE staff_id = ? AND work_date = ?";
        String updateB = "UPDATE WorkSchedule SET staff_id = ? WHERE staff_id = ? AND work_date = ?";
        String updateStatus = "UPDATE ShiftRequests SET Status = 'ApprovedByAdmin' WHERE RequestID = ?";

        try (Connection con = DBConnection.getConnection()) {
            con.setAutoCommit(false);

            int empA = 0, empB = 0;
            Date dateA = null, dateB = null;

            // ✅ Lấy thông tin yêu cầu
            try (PreparedStatement ps = con.prepareStatement(getSql)) {
                ps.setInt(1, requestId);
                ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                    empA = rs.getInt("EmployeeID");
                    empB = rs.getInt("ToStaffID");
                    dateA = rs.getDate("FromDate");
                    dateB = rs.getDate("ToDate");
                } else {
                    return false; // Không tìm thấy yêu cầu
                }
            }

            // ✅ Đổi lịch làm việc giữa 2 nhân viên
            try (PreparedStatement psA = con.prepareStatement(updateA); PreparedStatement psB = con.prepareStatement(updateB)) {

                // Nhân viên A → B
                psA.setInt(1, empB);
                psA.setInt(2, empA);
                psA.setDate(3, dateA);
                psA.executeUpdate();

                // Nhân viên B → A
                psB.setInt(1, empA);
                psB.setInt(2, empB);
                psB.setDate(3, dateB);
                psB.executeUpdate();
            }

            // ✅ Cập nhật trạng thái yêu cầu
            try (PreparedStatement psStatus = con.prepareStatement(updateStatus)) {
                psStatus.setInt(1, requestId);
                psStatus.executeUpdate();
            }

            con.commit();
            return true;

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    public void updateStatus(int requestId, String status) {
        String sql = "UPDATE ShiftRequests SET Status = ? WHERE RequestID = ?";
        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, requestId);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public boolean swapShiftsForAdmin(int requestId) {
        String sql = "SELECT EmployeeID, ToStaffID, FromDate, ToDate FROM ShiftRequests WHERE RequestID = ?";
        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, requestId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                int empA = rs.getInt("EmployeeID");
                int empB = rs.getInt("ToStaffID");
                Date dateA = rs.getDate("FromDate"); // ngày làm của A
                Date dateB = rs.getDate("ToDate");   // ngày làm của B

                // 👉 đổi nhân viên trong WorkSchedule
                String updateA = "UPDATE WorkSchedule SET staff_id = ? WHERE staff_id = ? AND work_date = ?";
                String updateB = "UPDATE WorkSchedule SET staff_id = ? WHERE staff_id = ? AND work_date = ?";

                try (PreparedStatement psA = con.prepareStatement(updateA); PreparedStatement psB = con.prepareStatement(updateB)) {

                    // A → ngày B
                    psA.setInt(1, empB);
                    psA.setInt(2, empA);
                    psA.setDate(3, dateA);

                    // B → ngày A
                    psB.setInt(1, empA);
                    psB.setInt(2, empB);
                    psB.setDate(3, dateB);

                    int rowsA = psA.executeUpdate();
                    int rowsB = psB.executeUpdate();

                    return rowsA > 0 && rowsB > 0;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
}
