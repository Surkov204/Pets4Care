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
            (staff_id, doctor_id, ToStaffID, Type, TargetDate, FromDate, ToDate,
             FromShiftID, ToShiftID, Reason, Status, ApprovedBy, CreatedAt)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, GETDATE())
        """;

        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            // Set staff_id or doctor_id (one must be null)
            if (r.getDoctor_id() > 0) {
                ps.setNull(1, Types.INTEGER); // staff_id
                ps.setInt(2, r.getDoctor_id()); // doctor_id
            } else {
                ps.setInt(1, r.getStaff_id() > 0 ? r.getStaff_id() : r.getEmployeeID()); // staff_id
                ps.setNull(2, Types.INTEGER); // doctor_id
            }

            Integer toStaffId = (r.getToStaffID() <= 0) ? null : r.getToStaffID();
            if (toStaffId == null) {
                ps.setNull(3, Types.INTEGER);
            } else {
                ps.setInt(3, toStaffId);
            }

            ps.setString(4, r.getType());

            Date fromDate = r.getFromDate();
            ps.setDate(5, fromDate); // target date = fromDate
            ps.setDate(6, fromDate);

            Date toDate = r.getToDate();
            if (toDate != null) {
                ps.setDate(7, toDate);
            } else {
                ps.setNull(7, Types.DATE);
            }

            Integer fromShiftId = r.getFromShiftID() > 0 ? r.getFromShiftID() : null;
            if (fromShiftId == null) {
                ps.setNull(8, Types.INTEGER);
            } else {
                ps.setInt(8, fromShiftId);
            }

            Integer toShiftId = r.getToShiftID() > 0 ? r.getToShiftID() : null;
            if (toShiftId == null) {
                ps.setNull(9, Types.INTEGER);
            } else {
                ps.setInt(9, toShiftId);
            }

            ps.setString(10, r.getReason());
            ps.setString(11, r.getStatus());

            if (r.getApprovedBy() == null) {
                ps.setNull(12, Types.INTEGER);
            } else {
                ps.setObject(12, r.getApprovedBy());
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
                ShiftRequest req = new ShiftRequest(
                        rs.getInt("RequestID"),
                        rs.getObject("staff_id") != null ? rs.getInt("staff_id") : (rs.getObject("doctor_id") != null ? rs.getInt("doctor_id") : 0),
                        rs.getInt("ToStaffID"),
                        rs.getString("Type"),
                        rs.getDate("TargetDate"), // Use TargetDate
                        rs.getDate("ToDate"),
                        rs.getInt("FromShiftID"),
                        rs.getInt("ToShiftID"),
                        rs.getString("Reason"),
                        rs.getString("Status"),
                        (Integer) rs.getObject("ApprovedBy"),
                        rs.getTimestamp("CreatedAt")
                );
                // Set staff_id or doctor_id
                if (rs.getObject("staff_id") != null) {
                    req.setStaff_id(rs.getInt("staff_id"));
                }
                if (rs.getObject("doctor_id") != null) {
                    req.setDoctor_id(rs.getInt("doctor_id"));
                }
                // Set FromDate from TargetDate for backward compatibility
                req.setFromDate(rs.getDate("TargetDate"));
                return req;
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
                ShiftRequest req = new ShiftRequest(
                        rs.getInt("RequestID"),
                        rs.getObject("staff_id") != null ? rs.getInt("staff_id") : (rs.getObject("doctor_id") != null ? rs.getInt("doctor_id") : 0),
                        rs.getInt("ToStaffID"),
                        rs.getString("Type"),
                        rs.getDate("TargetDate"), // Use TargetDate
                        rs.getDate("ToDate"),
                        rs.getInt("FromShiftID"),
                        rs.getInt("ToShiftID"),
                        rs.getString("Reason"),
                        rs.getString("Status"),
                        (Integer) rs.getObject("ApprovedBy"),
                        rs.getTimestamp("CreatedAt")
                );
                // Set staff_id or doctor_id
                if (rs.getObject("staff_id") != null) {
                    req.setStaff_id(rs.getInt("staff_id"));
                }
                if (rs.getObject("doctor_id") != null) {
                    req.setDoctor_id(rs.getInt("doctor_id"));
                }
                // Set FromDate from TargetDate for backward compatibility
                req.setFromDate(rs.getDate("TargetDate"));
                list.add(req);
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
        SELECT staff_id, doctor_id, ToStaffID, TargetDate, ToDate, FromShiftID, ToShiftID
        FROM ShiftRequests WHERE RequestID = ?
    """;

        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, requestId);
            ResultSet rs = ps.executeQuery();
            if (!rs.next()) {
                return false;
            }

            // Get staff_id or doctor_id (one must be not null)
            int empA = rs.getObject("staff_id") != null ? rs.getInt("staff_id") : rs.getInt("doctor_id");
            int empB = rs.getInt("ToStaffID");
            Date fromDate = rs.getDate("TargetDate"); // Use TargetDate instead of FromDate
            Date toDate = rs.getDate("ToDate");
            int fromShift = rs.getInt("FromShiftID");
            int toShift = rs.getInt("ToShiftID");

            // ⚠️ 1. Nếu cùng ngày & cùng ca thì hủy luôn
            if (fromDate.equals(toDate) && fromShift == toShift) {
                System.out.println("[ShiftRequestDAO] ⚠️ Không thể đổi cùng ngày & cùng ca.");
                return false;
            }

            // Check if empA is staff or doctor
            boolean empAIsDoctor = rs.getObject("doctor_id") != null;
            
            // ⚠️ 2. Nếu người nhận (A) đã có ca trùng với ca của B thì hủy luôn
            String checkDuplicate = empAIsDoctor 
                ? "SELECT COUNT(*) FROM WorkSchedule WHERE doctor_id = ? AND work_date = ? AND shift_id = ?"
                : "SELECT COUNT(*) FROM WorkSchedule WHERE staff_id = ? AND work_date = ? AND shift_id = ?";
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
            String checkShift = "SELECT COUNT(*) FROM WorkSchedule WHERE staff_id = ? AND work_date = ? AND shift_id = ?";
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

            // Update based on whether empA is doctor or staff
            // Note: Swap only works between same type (staff-staff or doctor-doctor)
            // If A is doctor, B must also be doctor (or we need special handling)
            String updateA = empAIsDoctor 
                ? "UPDATE WorkSchedule SET doctor_id = NULL, staff_id = ? WHERE doctor_id = ? AND work_date = ? AND shift_id = ?"
                : "UPDATE WorkSchedule SET staff_id = ? WHERE staff_id = ? AND work_date = ? AND shift_id = ?";
            String updateB = "UPDATE WorkSchedule SET staff_id = ? WHERE staff_id = ? AND work_date = ? AND shift_id = ?";

            try (PreparedStatement psA = con.prepareStatement(updateA); PreparedStatement psB = con.prepareStatement(updateB)) {

                // A → B: If A is doctor, set doctor_id to NULL and staff_id to empB
                // If A is staff, just update staff_id to empB
                if (empAIsDoctor) {
                    psA.setInt(1, empB); // staff_id
                    psA.setInt(2, empA); // doctor_id (old)
                } else {
                    psA.setInt(1, empB); // staff_id (new)
                    psA.setInt(2, empA); // staff_id (old)
                }
                psA.setDate(3, fromDate);
                psA.setInt(4, fromShift);
                int rowsA = psA.executeUpdate();

                // B → A: B is always staff, so just update staff_id
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
        String sql = "SELECT staff_id, doctor_id, ToStaffID, TargetDate, ToDate, FromShiftID, ToShiftID FROM ShiftRequests WHERE RequestID = ?";
        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, requestId);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                int empA = rs.getObject("staff_id") != null ? rs.getInt("staff_id") : rs.getInt("doctor_id");
                int empB = rs.getInt("ToStaffID");
                Date dateA = rs.getDate("TargetDate"); // Use TargetDate
                Date dateB = rs.getDate("ToDate");
                int shiftA = rs.getInt("FromShiftID");
                int shiftB = rs.getInt("ToShiftID");
                
                boolean empAIsDoctor = rs.getObject("doctor_id") != null;
                String updateA = empAIsDoctor 
                    ? "UPDATE WorkSchedule SET doctor_id=NULL, staff_id=? WHERE doctor_id=? AND work_date=? AND shift_id=?"
                    : "UPDATE WorkSchedule SET staff_id=? WHERE staff_id=? AND work_date=? AND shift_id=?";
                String updateB = "UPDATE WorkSchedule SET staff_id=? WHERE staff_id=? AND work_date=? AND shift_id=?";

                try (PreparedStatement psA = con.prepareStatement(updateA); PreparedStatement psB = con.prepareStatement(updateB)) {

                    if (empAIsDoctor) {
                        psA.setInt(1, empB); // staff_id
                        psA.setInt(2, empA); // doctor_id (old)
                    } else {
                        psA.setInt(1, empB); // staff_id (new)
                        psA.setInt(2, empA); // staff_id (old)
                    }
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
        SELECT staff_id, doctor_id, ToStaffID, TargetDate, FromShiftID
        FROM ShiftRequests WHERE RequestID = ?
    """;
        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, requestId);
            ResultSet rs = ps.executeQuery();

            if (!rs.next()) {
                System.out.println("[ShiftRequestDAO] ❌ Không tìm thấy request #" + requestId);
                return false;
            }

            int empA = rs.getObject("staff_id") != null ? rs.getInt("staff_id") : rs.getInt("doctor_id"); // người pass ca
            boolean empAIsDoctor = rs.getObject("doctor_id") != null;
            int empB = rs.getInt("ToStaffID");  // người nhận ca
            Date date = rs.getDate("TargetDate"); // Use TargetDate
            int shift = rs.getInt("FromShiftID");

            // 1️⃣ Kiểm tra người A có ca đó thật không
            String checkA = empAIsDoctor
                ? "SELECT COUNT(*) FROM WorkSchedule WHERE doctor_id = ? AND work_date = ? AND shift_id = ?"
                : "SELECT COUNT(*) FROM WorkSchedule WHERE staff_id = ? AND work_date = ? AND shift_id = ?";
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
            String checkB = "SELECT COUNT(*) FROM WorkSchedule WHERE staff_id = ? AND work_date = ? AND shift_id = ?";
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
            String update = empAIsDoctor
                ? "UPDATE WorkSchedule SET doctor_id = NULL, staff_id = ? WHERE doctor_id = ? AND work_date = ? AND shift_id = ?"
                : "UPDATE WorkSchedule SET staff_id = ? WHERE staff_id = ? AND work_date = ? AND shift_id = ?";
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
        INSERT INTO ShiftRequests (staff_id, doctor_id, ToStaffID, FromShiftID, ToShiftID, TargetDate, FromDate, ToDate, Type, Reason, Status, CreatedAt)
        VALUES (?, NULL, ?, ?, NULL, ?, ?, NULL, 'Pass', ?, 'Pending', GETDATE())
    """;
        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, fromStaffId);
            ps.setInt(2, toStaffId);
            ps.setInt(3, fromShiftId);
            ps.setDate(4, fromDate); // TargetDate
            ps.setDate(5, fromDate); // FromDate
            ps.setString(6, reason);
            return ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
            return 0;
        }
    }

    public void addPassRequest(ShiftRequest r) {
        String sql = """
        INSERT INTO ShiftRequests
        (staff_id, doctor_id, ToStaffID, Type, TargetDate, FromDate, ToDate, FromShiftID, ToShiftID, Reason, Status, ApprovedBy, CreatedAt)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, GETDATE())
    """;
        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            // Set staff_id or doctor_id (one must be null)
            if (r.getDoctor_id() > 0) {
                ps.setNull(1, Types.INTEGER); // staff_id
                ps.setInt(2, r.getDoctor_id()); // doctor_id
            } else {
                ps.setInt(1, r.getStaff_id() > 0 ? r.getStaff_id() : r.getEmployeeID()); // staff_id
                ps.setNull(2, Types.INTEGER); // doctor_id
            }

            Integer toStaffId = (r.getToStaffID() <= 0) ? null : r.getToStaffID();
            if (toStaffId == null) {
                ps.setNull(3, Types.INTEGER);
            } else {
                ps.setInt(3, toStaffId);
            }

            ps.setString(4, r.getType());         // 'DoctorRegister', 'DoctorCancel', 'DoctorPass', etc.

            Date fromDate = r.getFromDate();
            ps.setDate(5, fromDate);       // ✅ TargetDate = FromDate
            ps.setDate(6, fromDate);       // FromDate

            // For pass requests, ToDate is null
            ps.setNull(7, Types.DATE);

            Integer fromShiftId = r.getFromShiftID() > 0 ? r.getFromShiftID() : null;
            if (fromShiftId == null) {
                ps.setNull(8, Types.INTEGER);
            } else {
                ps.setInt(8, fromShiftId);
            }

            // For pass requests, ToShiftID is null
            ps.setNull(9, Types.INTEGER);

            ps.setString(10, r.getReason());
            ps.setString(11, r.getStatus());

            // ApprovedBy is null initially
            ps.setNull(12, Types.INTEGER);

            ps.executeUpdate();
            System.out.println("[ShiftRequestDAO] ✅ Thêm yêu cầu " + r.getType() + " thành công.");
        } catch (SQLException e) {
            System.err.println("[ShiftRequestDAO] ❌ Lỗi khi insert yêu cầu " + r.getType() + ":");
            e.printStackTrace();
        }
    }
}
