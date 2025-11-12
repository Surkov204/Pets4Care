package dao;

import java.sql.*;
import java.util.*;
import model.ShiftRequest;
import java.sql.Date;
import utils.DBConnection;

public class ShiftRequestDAO {

    // 📋 Lấy toàn bộ yêu cầu (cho Admin)
    public List<ShiftRequest> getAllRequests() {
        List<ShiftRequest> list = new ArrayList<>();
        String sql = "SELECT * FROM ShiftRequests ORDER BY CreatedAt DESC";

        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                list.add(new ShiftRequest(
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
                ));
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // ➕ Thêm yêu cầu đổi / pass ca
    public void addRequest(ShiftRequest r) {
        String sql = """
            INSERT INTO ShiftRequests
            (EmployeeID, ToStaffID, Type, TargetDate, FromDate, ToDate,
             FromShiftID, ToShiftID, Reason, Status, ApprovedBy, CreatedAt)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, GETDATE())
        """;

        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, r.getEmployeeID());

            Integer toStaffId = (r.getToStaffID() <= 0) ? null : r.getToStaffID();
            if (toStaffId == null) {
                ps.setNull(2, Types.INTEGER);
            } else {
                ps.setInt(2, toStaffId);
            }

            ps.setString(3, r.getType());

            Date fromDate = r.getFromDate();
            ps.setDate(4, fromDate); // target date = fromDate
            ps.setDate(5, fromDate);

            Date toDate = r.getToDate();
            if (toDate != null) {
                ps.setDate(6, toDate);
            } else {
                ps.setNull(6, Types.DATE);
            }

            Integer fromShiftId = r.getFromShiftID() > 0 ? r.getFromShiftID() : null;
            if (fromShiftId == null) {
                ps.setNull(7, Types.INTEGER);
            } else {
                ps.setInt(7, fromShiftId);
            }

            Integer toShiftId = r.getToShiftID() > 0 ? r.getToShiftID() : null;
            if (toShiftId == null) {
                ps.setNull(8, Types.INTEGER);
            } else {
                ps.setInt(8, toShiftId);
            }

            ps.setString(9, r.getReason());
            ps.setString(10, r.getStatus());

            if (r.getApprovedBy() == null) {
                ps.setNull(11, Types.INTEGER);
            } else {
                ps.setObject(11, r.getApprovedBy());
            }

            ps.executeUpdate();
            System.out.println("[ShiftRequestDAO] ✅ Thêm yêu cầu thành công.");
        } catch (SQLException e) {
            System.err.println("[ShiftRequestDAO] ❌ Lỗi khi insert yêu cầu đổi/pass ca:");
            e.printStackTrace();
        }
    }

    // 🔍 Lấy request theo ID
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

    // 🔍 Lấy các request chờ xác nhận cho 1 nhân viên
    public List<ShiftRequest> getRequestsForStaff(int staffId) {
        List<ShiftRequest> list = new ArrayList<>();
        String sql = "SELECT * FROM ShiftRequests WHERE ToStaffID = ? AND Status = 'Pending'";

        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, staffId);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                list.add(new ShiftRequest(
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
                ));
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // 🟢 Cập nhật trạng thái
    public void updateStatus(int id, String status) {
        String sql = "UPDATE ShiftRequests SET Status = ? WHERE RequestID = ?";
        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, id);
            ps.executeUpdate();
            System.out.println("[ShiftRequestDAO] ✅ Cập nhật trạng thái #" + id);
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public void updateStatus(int id, String status, Integer approvedBy) {
        String sql = "UPDATE ShiftRequests SET Status = ?, ApprovedBy = ? WHERE RequestID = ?";
        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setObject(2, approvedBy);
            ps.setInt(3, id);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    // 🗑 Xóa yêu cầu
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

    // 🔄 SWAP CA CHÍNH XÁC (chỉ đúng ca + ngày)
    public boolean swapShift(int requestId) {
        String sql = """
        SELECT EmployeeID, ToStaffID, FromDate, ToDate, FromShiftID, ToShiftID
        FROM ShiftRequests WHERE RequestID = ?
    """;

        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, requestId);
            ResultSet rs = ps.executeQuery();
            if (!rs.next()) {
                return false;
            }

            int empA = rs.getInt("EmployeeID");
            int empB = rs.getInt("ToStaffID");
            Date fromDate = rs.getDate("FromDate");
            Date toDate = rs.getDate("ToDate");
            int fromShift = rs.getInt("FromShiftID");
            int toShift = rs.getInt("ToShiftID");

            // ⚠️ 1. Nếu cùng ngày & cùng ca thì hủy luôn
            if (fromDate.equals(toDate) && fromShift == toShift) {
                System.out.println("[ShiftRequestDAO] ⚠️ Không thể đổi cùng ngày & cùng ca.");
                return false;
            }

            // ⚠️ 2. Nếu người nhận (A) đã có ca trùng với ca của B thì hủy luôn
            String checkDuplicate = """
            SELECT COUNT(*) FROM WorkSchedule 
            WHERE staff_id = ? AND work_date = ? AND shift_id = ?
        """;
            try (PreparedStatement psCheck = con.prepareStatement(checkDuplicate)) {
                psCheck.setInt(1, empA);
                psCheck.setDate(2, toDate);
                psCheck.setInt(3, toShift);
                ResultSet rsDup = psCheck.executeQuery();
                if (rsDup.next() && rsDup.getInt(1) > 0) {
                    System.out.println("[ShiftRequestDAO] ⚠️ Nhân viên A đã có ca " + toShift + " vào ngày " + toDate + " → không thể đổi.");
                    return false;
                }
            }

            // ⚠️ 3. Kiểm tra xem B có thực sự có ca đó không
            String checkShift = """
            SELECT COUNT(*) FROM WorkSchedule 
            WHERE staff_id = ? AND work_date = ? AND shift_id = ?
        """;
            try (PreparedStatement psCheck = con.prepareStatement(checkShift)) {
                psCheck.setInt(1, empB);
                psCheck.setDate(2, toDate);
                psCheck.setInt(3, toShift);
                ResultSet rCheck = psCheck.executeQuery();
                if (rCheck.next() && rCheck.getInt(1) == 0) {
                    System.out.println("[ShiftRequestDAO] ⚠️ Nhân viên B không có ca đó để đổi, hủy swap.");
                    return false;
                }
            }

            // ✅ Nếu mọi thứ hợp lệ → bắt đầu hoán đổi
            con.setAutoCommit(false);

            String updateA = "UPDATE WorkSchedule SET staff_id = ? WHERE staff_id = ? AND work_date = ? AND shift_id = ?";
            String updateB = "UPDATE WorkSchedule SET staff_id = ? WHERE staff_id = ? AND work_date = ? AND shift_id = ?";

            try (PreparedStatement psA = con.prepareStatement(updateA); PreparedStatement psB = con.prepareStatement(updateB)) {

                // A → B
                psA.setInt(1, empB);
                psA.setInt(2, empA);
                psA.setDate(3, fromDate);
                psA.setInt(4, fromShift);
                int rowsA = psA.executeUpdate();

                // B → A
                psB.setInt(1, empA);
                psB.setInt(2, empB);
                psB.setDate(3, toDate);
                psB.setInt(4, toShift);
                int rowsB = psB.executeUpdate();

                if (rowsA > 0 && rowsB > 0) {
                    try (PreparedStatement psU = con.prepareStatement(
                            "UPDATE ShiftRequests SET Status='ApprovedByAdmin' WHERE RequestID=?")) {
                        psU.setInt(1, requestId);
                        psU.executeUpdate();
                    }
                    con.commit();
                    System.out.println("[ShiftRequestDAO] ✅ Hoán đổi ca thành công #" + requestId);
                    return true;
                } else {
                    con.rollback();
                    System.out.println("[ShiftRequestDAO] ⚠️ Một trong hai ca không tồn tại, rollback.");
                    return false;
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // 🔁 SWAP CA CHO ADMIN (legacy)
    public boolean swapShiftsForAdmin(int requestId) {
        String sql = "SELECT EmployeeID, ToStaffID, FromDate, ToDate, FromShiftID, ToShiftID FROM ShiftRequests WHERE RequestID = ?";
        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, requestId);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                int empA = rs.getInt("EmployeeID");
                int empB = rs.getInt("ToStaffID");
                Date dateA = rs.getDate("FromDate");
                Date dateB = rs.getDate("ToDate");
                int shiftA = rs.getInt("FromShiftID");
                int shiftB = rs.getInt("ToShiftID");

                String updateA = "UPDATE WorkSchedule SET staff_id=? WHERE staff_id=? AND work_date=? AND shift_id=?";
                String updateB = "UPDATE WorkSchedule SET staff_id=? WHERE staff_id=? AND work_date=? AND shift_id=?";

                try (PreparedStatement psA = con.prepareStatement(updateA); PreparedStatement psB = con.prepareStatement(updateB)) {

                    psA.setInt(1, empB);
                    psA.setInt(2, empA);
                    psA.setDate(3, dateA);
                    psA.setInt(4, shiftA);

                    psB.setInt(1, empA);
                    psB.setInt(2, empB);
                    psB.setDate(3, dateB);
                    psB.setInt(4, shiftB);

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

    public boolean passShift(int requestId) {
        String sql = """
        SELECT EmployeeID, ToStaffID, FromDate, FromShiftID
        FROM ShiftRequests WHERE RequestID = ?
    """;
        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, requestId);
            ResultSet rs = ps.executeQuery();

            if (!rs.next()) {
                System.out.println("[ShiftRequestDAO] ❌ Không tìm thấy request #" + requestId);
                return false;
            }

            int empA = rs.getInt("EmployeeID"); // người pass ca
            int empB = rs.getInt("ToStaffID");  // người nhận ca
            Date date = rs.getDate("FromDate");
            int shift = rs.getInt("FromShiftID");

            // 1️⃣ Kiểm tra người A có ca đó thật không
            String checkA = """
            SELECT COUNT(*) FROM WorkSchedule 
            WHERE staff_id = ? AND work_date = ? AND shift_id = ?
        """;
            try (PreparedStatement psCheck = con.prepareStatement(checkA)) {
                psCheck.setInt(1, empA);
                psCheck.setDate(2, date);
                psCheck.setInt(3, shift);
                ResultSet rsA = psCheck.executeQuery();
                if (rsA.next() && rsA.getInt(1) == 0) {
                    System.out.println("[ShiftRequestDAO] ⚠️ Nhân viên A không có ca này để pass.");
                    return false;
                }
            }

            // 2️⃣ Kiểm tra B có bị trùng ca không
            String checkB = """
            SELECT COUNT(*) FROM WorkSchedule 
            WHERE staff_id = ? AND work_date = ? AND shift_id = ?
        """;
            try (PreparedStatement psCheck = con.prepareStatement(checkB)) {
                psCheck.setInt(1, empB);
                psCheck.setDate(2, date);
                psCheck.setInt(3, shift);
                ResultSet rsB = psCheck.executeQuery();
                if (rsB.next() && rsB.getInt(1) > 0) {
                    System.out.println("[ShiftRequestDAO] ⚠️ Nhân viên B đã có ca trùng, không thể nhận thêm.");
                    return false;
                }
            }

            // ✅ 3️⃣ Cập nhật WorkSchedule: người A → người B
            String update = """
            UPDATE WorkSchedule 
            SET staff_id = ? 
            WHERE staff_id = ? AND work_date = ? AND shift_id = ?
        """;
            try (PreparedStatement psU = con.prepareStatement(update)) {
                psU.setInt(1, empB);
                psU.setInt(2, empA);
                psU.setDate(3, date);
                psU.setInt(4, shift);

                int rows = psU.executeUpdate();
                if (rows > 0) {
                    try (PreparedStatement psStatus = con.prepareStatement(
                            "UPDATE ShiftRequests SET Status='ApprovedByAdmin' WHERE RequestID=?")) {
                        psStatus.setInt(1, requestId);
                        psStatus.executeUpdate();
                    }
                    System.out.println("[ShiftRequestDAO] ✅ Pass ca thành công #" + requestId);
                    return true;
                } else {
                    System.out.println("[ShiftRequestDAO] ⚠️ Không tìm thấy ca để cập nhật.");
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public int createPassRequest(int fromStaffId, int toStaffId, int fromShiftId, Date fromDate, String reason) {
        String sql = """
        INSERT INTO ShiftRequests (EmployeeID, ToStaffID, FromShiftID, ToShiftID, FromDate, ToDate, Type, Reason, Status, CreatedAt)
        VALUES (?, ?, ?, NULL, ?, NULL, 'Pass', ?, 'Pending', GETDATE())
    """;
        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, fromStaffId);
            ps.setInt(2, toStaffId);
            ps.setInt(3, fromShiftId);
            ps.setDate(4, fromDate);
            ps.setString(5, reason);
            return ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
            return 0;
        }
    }

    public void addPassRequest(ShiftRequest r) {
        String sql = """
        INSERT INTO ShiftRequests
        (EmployeeID, ToStaffID, Type, TargetDate, FromDate, ToDate, FromShiftID, ToShiftID, Reason, Status, ApprovedBy, CreatedAt)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, GETDATE())
    """;
        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, r.getEmployeeID());

            Integer toStaffId = (r.getToStaffID() <= 0) ? null : r.getToStaffID();
            if (toStaffId == null) {
                ps.setNull(2, Types.INTEGER);
            } else {
                ps.setInt(2, toStaffId);
            }

            ps.setString(3, r.getType());         // 'DoctorRegister', 'DoctorCancel', 'DoctorPass', etc.

            Date fromDate = r.getFromDate();
            ps.setDate(4, fromDate);       // ✅ TargetDate = FromDate
            ps.setDate(5, fromDate);       // FromDate

            // For pass requests, ToDate is null
            ps.setNull(6, Types.DATE);

            Integer fromShiftId = r.getFromShiftID() > 0 ? r.getFromShiftID() : null;
            if (fromShiftId == null) {
                ps.setNull(7, Types.INTEGER);
            } else {
                ps.setInt(7, fromShiftId);
            }

            // For pass requests, ToShiftID is null
            ps.setNull(8, Types.INTEGER);

            ps.setString(9, r.getReason());
            ps.setString(10, r.getStatus());

            // ApprovedBy is null initially
            ps.setNull(11, Types.INTEGER);

            ps.executeUpdate();
            System.out.println("[ShiftRequestDAO] ✅ Thêm yêu cầu " + r.getType() + " thành công.");
        } catch (SQLException e) {
            System.err.println("[ShiftRequestDAO] ❌ Lỗi khi insert yêu cầu " + r.getType() + ":");
            e.printStackTrace();
        }
    }
}
