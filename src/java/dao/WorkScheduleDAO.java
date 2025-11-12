package dao;

import java.sql.*;
import java.sql.Date;
import java.time.LocalDate;
import java.util.*;
import model.Staff;
import model.WorkSchedule;
import utils.DBConnection;

public class WorkScheduleDAO {


    public List<WorkSchedule> getAllSchedules() {
        List<WorkSchedule> list = new ArrayList<>();
        String sql = "SELECT * FROM WorkSchedule ORDER BY work_date DESC";

        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                WorkSchedule ws = new WorkSchedule();
                ws.setScheduleId(rs.getInt("schedule_id"));
                ws.setDoctorId((Integer) rs.getObject("doctor_id"));
                ws.setStaffId((Integer) rs.getObject("staff_id"));
                ws.setShiftId((Integer) rs.getObject("shift_id"));
                ws.setWorkDate(rs.getDate("work_date"));
                ws.setStartTime(rs.getTime("start_time"));
                ws.setEndTime(rs.getTime("end_time"));
                ws.setStatus(rs.getString("status"));
                ws.setNote(rs.getString("note"));
                list.add(ws);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // 🟢 Thêm lịch làm việc mới
    public void addSchedule(WorkSchedule ws) {
        String sql = "INSERT INTO WorkSchedule(doctor_id, staff_id, shift_id, work_date, start_time, end_time, status, note) "
                + "VALUES(?,?,?,?,?,?,?,?)";

        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setObject(1, ws.getDoctorId());
            ps.setObject(2, ws.getStaffId());
            ps.setObject(3, ws.getShiftId());     // ✅ thêm shiftId
            ps.setDate(4, ws.getWorkDate());
            ps.setTime(5, ws.getStartTime());
            ps.setTime(6, ws.getEndTime());
            ps.setString(7, ws.getStatus());
            ps.setString(8, ws.getNote());
            ps.executeUpdate();

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    // 🟢 Cập nhật lịch làm việc
    public void updateSchedule(WorkSchedule ws) {
        String sql = "UPDATE WorkSchedule SET doctor_id=?, staff_id=?, shift_id=?, work_date=?, start_time=?, end_time=?, status=?, note=? "
                + "WHERE schedule_id=?";

        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setObject(1, ws.getDoctorId());
            ps.setObject(2, ws.getStaffId());
            ps.setObject(3, ws.getShiftId());     // ✅ thêm shiftId
            ps.setDate(4, ws.getWorkDate());
            ps.setTime(5, ws.getStartTime());
            ps.setTime(6, ws.getEndTime());
            ps.setString(7, ws.getStatus());
            ps.setString(8, ws.getNote());
            ps.setInt(9, ws.getScheduleId());
            ps.executeUpdate();

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    // 🟢 Xóa lịch làm việc
    public void deleteSchedule(int id) {
        String sql = "DELETE FROM WorkSchedule WHERE schedule_id=?";
        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    // 🟢 Lấy lịch làm việc theo nhân viên
    public List<WorkSchedule> getScheduleByStaff(int staffId) {
        List<WorkSchedule> list = new ArrayList<>();
        String sql = """
        SELECT ws.schedule_id, ws.doctor_id, ws.staff_id, ws.shift_id, ws.work_date,
               ws.start_time, ws.end_time, ws.status, ws.note,
               s.ShiftName AS shift_name, s.StartTime AS s_start, s.EndTime AS s_end
        FROM WorkSchedule ws
        LEFT JOIN Shifts s ON ws.shift_id = s.ShiftID
        WHERE ws.staff_id = ?
        ORDER BY ws.work_date ASC
    """;

        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, staffId);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                WorkSchedule ws = new WorkSchedule();
                ws.setScheduleId(rs.getInt("schedule_id"));
                ws.setDoctorId((Integer) rs.getObject("doctor_id"));
                ws.setStaffId((Integer) rs.getObject("staff_id"));
                ws.setShiftId((Integer) rs.getObject("shift_id"));
                ws.setWorkDate(rs.getDate("work_date"));

                ws.setShiftName(rs.getString("shift_name"));
                ws.setStartTime(rs.getTime("s_start") != null ? rs.getTime("s_start") : rs.getTime("start_time"));
                ws.setEndTime(rs.getTime("s_end") != null ? rs.getTime("s_end") : rs.getTime("end_time"));

                ws.setStatus(rs.getString("status"));
                ws.setNote(rs.getString("note"));
                list.add(ws);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Map<String, Object>> getScheduleWithShiftByStaff(int staffId) {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = """
        SELECT ws.schedule_id, ws.work_date, ws.status, ws.note,
               sh.shift_name, sh.start_time AS shift_start, sh.end_time AS shift_end, sh.location
        FROM WorkSchedule ws
        JOIN Shift sh ON ws.shift_id = sh.shift_id
        WHERE ws.staff_id = ?
        ORDER BY ws.work_date ASC
    """;

        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, staffId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new HashMap<>();
                    row.put("scheduleId", rs.getInt("schedule_id"));
                    row.put("workDate", rs.getDate("work_date"));
                    row.put("status", rs.getString("status"));
                    row.put("note", rs.getString("note"));
                    row.put("shiftName", rs.getString("shift_name"));
                    row.put("shiftStart", rs.getTime("shift_start"));
                    row.put("shiftEnd", rs.getTime("shift_end"));
                    row.put("location", rs.getString("location"));
                    list.add(row);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public void deleteByShiftAndStaff(int shiftId, int staffId) {
        String sql = "DELETE FROM WorkSchedule WHERE shift_id=? AND staff_id=?";
        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, shiftId);
            ps.setInt(2, staffId);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public void addScheduleByShiftType(int staffId, LocalDate workDate, String shiftType) {
        try (Connection con = DBConnection.getConnection()) {
            // ✅ Kiểm tra trùng theo shift_id thay vì note
            int shiftId;
            Time start, end;
            String shiftName;

            switch (shiftType) {
                case "morning" -> {
                    shiftId = 1;
                    shiftName = "Ca sáng";
                    start = Time.valueOf("08:00:00");
                    end = Time.valueOf("12:00:00");
                }
                case "afternoon" -> {
                    shiftId = 2;
                    shiftName = "Ca chiều";
                    start = Time.valueOf("13:00:00");
                    end = Time.valueOf("17:00:00");
                }
                case "evening" -> {
                    shiftId = 3;
                    shiftName = "Ca tối";
                    start = Time.valueOf("18:00:00");
                    end = Time.valueOf("22:00:00");
                }
                default -> {
                    return;
                }
            }

            // 🟢 CHECK ĐÚNG: theo shift_id
            String checkSql = "SELECT COUNT(*) FROM WorkSchedule WHERE staff_id=? AND work_date=? AND shift_id=?";
            PreparedStatement check = con.prepareStatement(checkSql);
            check.setInt(1, staffId);
            check.setDate(2, Date.valueOf(workDate));
            check.setInt(3, shiftId);
            ResultSet rs = check.executeQuery();
            if (rs.next() && rs.getInt(1) > 0) {
                return; // Đã có ca này rồi
            }

            // 🟢 INSERT ĐÚNG
            String sql = "INSERT INTO WorkSchedule (staff_id, shift_id, work_date, start_time, end_time, status, note) "
                    + "VALUES (?, ?, ?, ?, ?, ?, ?)";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setInt(1, staffId);
            ps.setInt(2, shiftId);
            ps.setDate(3, Date.valueOf(workDate));
            ps.setTime(4, start);
            ps.setTime(5, end);
            ps.setString(6, "Registered");
            ps.setString(7, "Đăng ký " + shiftName);
            ps.executeUpdate();

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public List<WorkSchedule> getScheduleByStaffAndRange(int staffId, LocalDate start, LocalDate end) {
        List<WorkSchedule> list = new ArrayList<>();
        String sql = """
        SELECT schedule_id, staff_id, shift_id, work_date, status
        FROM WorkSchedule
        WHERE staff_id = ? AND work_date BETWEEN ? AND ?
        ORDER BY work_date, shift_id
    """;

        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, staffId);
            ps.setDate(2, Date.valueOf(start));
            ps.setDate(3, Date.valueOf(end));

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                WorkSchedule ws = new WorkSchedule();
                ws.setScheduleId(rs.getInt("schedule_id"));
                ws.setStaffId(rs.getInt("staff_id"));
                ws.setShiftId(rs.getInt("shift_id"));
                ws.setWorkDate(rs.getDate("work_date"));
                ws.setStatus(rs.getString("status"));
                list.add(ws);
            }

            System.out.println("✅ getScheduleByStaffAndRange: found " + list.size() + " record(s)");
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public void deleteScheduleByStaffShiftDate(int staffId, int shiftId, LocalDate workDate) {
        String sql = "DELETE FROM WorkSchedule WHERE staff_id=? AND shift_id=? AND work_date=?";
        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, staffId);
            ps.setInt(2, shiftId);
            ps.setDate(3, Date.valueOf(workDate));
            int rows = ps.executeUpdate();
            System.out.println("🗑 Hủy ca: staff=" + staffId + ", shift=" + shiftId + ", date=" + workDate + " | rows=" + rows);
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public boolean deleteScheduleByStaffShift(int staffId, int shiftId, LocalDate date) {
        String sql = "DELETE FROM WorkSchedule WHERE staff_id=? AND shift_id=? AND work_date=?";
        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, staffId);
            ps.setInt(2, shiftId);
            ps.setDate(3, java.sql.Date.valueOf(date));

            int rows = ps.executeUpdate();
            System.out.println("🗑️ [DAO] Xóa ca: staff=" + staffId + ", shift=" + shiftId + ", date=" + date + " | rows=" + rows);
            return rows > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public Map<String, List<String>> getCommonSchedule(LocalDate startOfWeek, LocalDate endOfWeek) {
        Map<String, List<String>> scheduleMap = new LinkedHashMap<>();
        String sql = """
        SELECT ws.work_date, s.name AS staff_name, sh.ShiftName
        FROM WorkSchedule ws
        JOIN Staff s ON ws.staff_id = s.staff_id
        LEFT JOIN Shifts sh ON ws.shift_id = sh.ShiftID
        WHERE ws.work_date BETWEEN ? AND ?
        ORDER BY ws.work_date, sh.StartTime
    """;

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setDate(1, Date.valueOf(startOfWeek));
            ps.setDate(2, Date.valueOf(endOfWeek));

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String date = rs.getDate("work_date").toString();
                    String shift = rs.getString("ShiftName");
                    String key = date + " - " + (shift != null ? shift : "Không xác định");
                    String staffName = rs.getString("staff_name");
                    scheduleMap.computeIfAbsent(key, k -> new ArrayList<>()).add(staffName);
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return scheduleMap;
    }

    public List<Staff> getAllStaffExcept(int staffId) {
        List<Staff> list = new ArrayList<>();
        String sql = "SELECT staff_id, name FROM Staff WHERE staff_id <> ?";
        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, staffId);
            System.out.println("[DEBUG] SQL = " + sql + " | staffId = " + staffId);

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Staff s = new Staff();
                s.setStaffId(rs.getInt("staff_id"));
                s.setName(rs.getString("name"));
                list.add(s);
                System.out.println("👉 Found staff: " + s.getStaffId() + " - " + s.getName());
            }

            System.out.println("✅ getAllStaffExcept(): total = " + list.size());
        } catch (Exception e) {
            System.err.println("❌ Error in getAllStaffExcept(): " + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }

    public List<Staff> getAllStaff() {
        List<Staff> list = new ArrayList<>();
        String sql = "SELECT staff_id, name FROM Staff";
        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Staff s = new Staff();
                s.setStaffId(rs.getInt("staff_id"));
                s.setName(rs.getString("name"));
                list.add(s);
            }

            System.out.println("✅ getAllStaff(): found " + list.size() + " records");
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public void swapShifts(int staffA, int staffB, int shiftId, LocalDate date) {
        String sqlUpdateA = "UPDATE WorkSchedule SET StaffID = ? WHERE StaffID = ? AND ShiftID = ? AND WorkDate = ?";
        String sqlUpdateB = "UPDATE WorkSchedule SET StaffID = ? WHERE StaffID = ? AND ShiftID = ? AND WorkDate = ?";

        try (Connection con = DBConnection.getConnection()) {
            con.setAutoCommit(false); // 🔒 bắt đầu transaction

            // Hoán đổi: A lấy ca của B
            try (PreparedStatement psA = con.prepareStatement(sqlUpdateA); PreparedStatement psB = con.prepareStatement(sqlUpdateB)) {

                // A -> B
                psA.setInt(1, staffB);
                psA.setInt(2, staffA);
                psA.setInt(3, shiftId);
                psA.setDate(4, Date.valueOf(date));
                int updatedA = psA.executeUpdate();

                // B -> A
                psB.setInt(1, staffA);
                psB.setInt(2, staffB);
                psB.setInt(3, shiftId);
                psB.setDate(4, Date.valueOf(date));
                int updatedB = psB.executeUpdate();

                con.commit();
                System.out.println("[WorkScheduleDAO] 🔁 Hoán đổi ca thành công: " + updatedA + " <-> " + updatedB);
            } catch (SQLException ex) {
                con.rollback();
                throw ex;
            } finally {
                con.setAutoCommit(true);
            }
        } catch (Exception e) {
            System.err.println("❌ Lỗi khi hoán đổi ca giữa " + staffA + " và " + staffB);
            e.printStackTrace();
        }
    }

    public boolean swapDoctorShifts(int doctorA, int doctorB,
            Date fromDate, Date toDate, int fromShift, int toShift) {
        String updateA = "UPDATE WorkSchedule SET doctor_id = ? WHERE doctor_id = ? AND work_date = ? AND shift_id = ?";
        String updateB = "UPDATE WorkSchedule SET doctor_id = ? WHERE doctor_id = ? AND work_date = ? AND shift_id = ?";

        try (Connection con = DBConnection.getConnection()) {
            con.setAutoCommit(false);
            try (PreparedStatement psA = con.prepareStatement(updateA);
                 PreparedStatement psB = con.prepareStatement(updateB)) {

                psA.setInt(1, doctorB);
                psA.setInt(2, doctorA);
                psA.setDate(3, fromDate);
                psA.setInt(4, fromShift);
                int rowsA = psA.executeUpdate();

                psB.setInt(1, doctorA);
                psB.setInt(2, doctorB);
                psB.setDate(3, toDate);
                psB.setInt(4, toShift);
                int rowsB = psB.executeUpdate();

                if (rowsA > 0 && rowsB > 0) {
                    con.commit();
                    return true;
                }
                con.rollback();
            } catch (SQLException ex) {
                con.rollback();
                throw ex;
            } finally {
                con.setAutoCommit(true);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean reassignDoctorShift(int fromDoctorId, int toDoctorId, Date workDate, int shiftId) {
        String sql = "UPDATE WorkSchedule SET doctor_id = ? WHERE doctor_id = ? AND work_date = ? AND shift_id = ?";
        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, toDoctorId);
            ps.setInt(2, fromDoctorId);
            ps.setDate(3, workDate);
            ps.setInt(4, shiftId);
            int rows = ps.executeUpdate();
            return rows > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean canSwapShift(int staffA, int staffB,
            Date fromDate, Date toDate,
            int fromShift, int toShift) {
        String sql = """
        SELECT COUNT(*) AS conflicts
        FROM WorkSchedule
        WHERE 
            -- B đang có ca mà A muốn đổi
            (work_date = ? AND shift_id = ? AND staff_id = ?) 
            OR
            -- A đang có ca mà B muốn đổi
            (work_date = ? AND shift_id = ? AND staff_id = ?)
    """;

        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setDate(1, fromDate);
            ps.setInt(2, fromShift);
            ps.setInt(3, staffB);
            ps.setDate(4, toDate);
            ps.setInt(5, toShift);
            ps.setInt(6, staffA);

            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt("conflicts") == 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean canDoctorSwapShift(int doctorA, int doctorB,
            Date fromDate, Date toDate,
            int fromShift, int toShift) {
        String sql = """
        SELECT COUNT(*) AS conflicts
        FROM WorkSchedule
        WHERE 
            (work_date = ? AND shift_id = ? AND doctor_id = ?)
            OR
            (work_date = ? AND shift_id = ? AND doctor_id = ?)
    """;

        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setDate(1, fromDate);
            ps.setInt(2, fromShift);
            ps.setInt(3, doctorB);
            ps.setDate(4, toDate);
            ps.setInt(5, toShift);
            ps.setInt(6, doctorA);

            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt("conflicts") == 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean hasShift(int staffId, Date workDate, int shiftId) {
        String sql = """
        SELECT COUNT(*) 
        FROM WorkSchedule 
        WHERE staff_id = ? AND work_date = ? AND shift_id = ?
    """;
        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, staffId);
            ps.setDate(2, workDate);
            ps.setInt(3, shiftId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean hasDoctorShift(int doctorId, Date workDate, int shiftId) {
        String sql = """
        SELECT COUNT(*)
        FROM WorkSchedule
        WHERE doctor_id = ? AND work_date = ? AND shift_id = ?
    """;
        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, doctorId);
            ps.setDate(2, workDate);
            ps.setInt(3, shiftId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // 🟢 Xác định ca làm hiện tại của nhân viên theo thời gian thực
    public WorkSchedule getCurrentShiftForStaff(int staffId) {
        String sql = """
            SELECT TOP 1 ws.*, s.ShiftName, s.Location, s.StartTime, s.EndTime
            FROM WorkSchedule ws
            JOIN Shifts s ON ws.Shift_ID = s.ShiftID
            WHERE ws.Staff_ID = ? AND ws.Work_Date = CAST(GETDATE() AS DATE)
            ORDER BY s.StartTime
        """;
        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, staffId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Time now = new Time(System.currentTimeMillis());
                    Time start = rs.getTime("StartTime");
                    Time end = rs.getTime("EndTime");

                    // Nếu giờ hiện tại nằm trong ca hoặc sớm hơn 30p trước ca
                    long diffBefore = (start.getTime() - now.getTime()) / (1000 * 60);
                    if (now.after(start) && now.before(end) || (diffBefore <= 30 && diffBefore >= -30)) {
                        WorkSchedule ws = new WorkSchedule();
                        ws.setScheduleId(rs.getInt("Schedule_ID"));
                        ws.setShiftId(rs.getInt("Shift_ID"));
                        ws.setShiftName(rs.getString("ShiftName"));
                        ws.setWorkDate(rs.getDate("Work_Date"));
                        ws.setStartTime(start);
                        ws.setEndTime(end);
                        ws.setStatus(rs.getString("Status"));
                        ws.setNote(rs.getString("Note"));
                        ws.setStaffId(rs.getInt("Staff_ID"));
                        ws.setDoctorId((Integer) rs.getObject("Doctor_ID"));
                        ws.setShiftName(rs.getString("ShiftName"));
                        ws.setNote(rs.getString("Location")); // Gắn location để JSP hiển thị
                        return ws;
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public WorkSchedule getCurrentShiftForToday(int staffId) {
        String sql = """
        SELECT TOP 1 * FROM WorkSchedule
        WHERE staff_id = ?
          AND work_date = CAST(GETDATE() AS date)
          AND CAST(GETDATE() AS time) BETWEEN start_time AND end_time
          AND status IN ('Registered', 'Assigned')
        ORDER BY start_time
    """;
        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, staffId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                WorkSchedule ws = new WorkSchedule();
                ws.setScheduleId(rs.getInt("schedule_id"));
                ws.setWorkDate(rs.getDate("work_date"));
                ws.setStartTime(rs.getTime("start_time"));
                ws.setEndTime(rs.getTime("end_time"));
                ws.setStatus(rs.getString("status"));
                ws.setNote(rs.getString("note"));
                return ws;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public void assignShift(int staffId, String date, int shiftId) {
        String sqlCheck = "SELECT COUNT(*) FROM WorkSchedule WHERE staff_id=? AND work_date=? AND shift_id=?";
        String sqlInsert = """
        INSERT INTO WorkSchedule (staff_id, shift_id, work_date, start_time, end_time, status, note)
        SELECT ?, s.ShiftID, ?, s.StartTime, s.EndTime, 'Assigned', 'Gán trực tiếp bởi Admin'
        FROM Shifts s WHERE s.ShiftID = ?
    """;

        try (Connection con = DBConnection.getConnection()) {
            // Kiểm tra trùng lịch
            try (PreparedStatement check = con.prepareStatement(sqlCheck)) {
                check.setInt(1, staffId);
                check.setDate(2, Date.valueOf(date));
                check.setInt(3, shiftId);
                ResultSet rs = check.executeQuery();
                if (rs.next() && rs.getInt(1) > 0) {
                    System.out.println("⚠️ Nhân viên " + staffId + " đã có ca " + shiftId + " ngày " + date);
                    return;
                }
            }

            // Gán mới
            try (PreparedStatement ps = con.prepareStatement(sqlInsert)) {
                ps.setInt(1, staffId);
                ps.setDate(2, Date.valueOf(date));
                ps.setInt(3, shiftId);
                int rows = ps.executeUpdate();
                System.out.println("✅ assignShift(): " + rows + " row(s) inserted for staff=" + staffId);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public List<WorkSchedule> getScheduleByDoctor(int doctorId) {
        List<WorkSchedule> list = new ArrayList<>();
        String sql = """
        SELECT ws.schedule_id, ws.doctor_id, ws.staff_id, ws.shift_id, ws.work_date,
               ws.start_time, ws.end_time, ws.status, ws.note,
               s.ShiftName AS shift_name, s.StartTime AS s_start, s.EndTime AS s_end
        FROM WorkSchedule ws
        LEFT JOIN Shifts s ON ws.shift_id = s.ShiftID
        WHERE ws.doctor_id = ?
        ORDER BY ws.work_date ASC
    """;

        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, doctorId);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                WorkSchedule ws = new WorkSchedule();
                ws.setScheduleId(rs.getInt("schedule_id"));
                ws.setDoctorId((Integer) rs.getObject("doctor_id"));
                ws.setStaffId((Integer) rs.getObject("staff_id"));
                ws.setShiftId((Integer) rs.getObject("shift_id"));
                ws.setWorkDate(rs.getDate("work_date"));

                ws.setShiftName(rs.getString("shift_name"));
                ws.setStartTime(rs.getTime("s_start") != null ? rs.getTime("s_start") : rs.getTime("start_time"));
                ws.setEndTime(rs.getTime("s_end") != null ? rs.getTime("s_end") : rs.getTime("end_time"));

                ws.setStatus(rs.getString("status"));
                ws.setNote(rs.getString("note"));
                list.add(ws);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<WorkSchedule> getScheduleByDoctorAndRange(int doctorId, LocalDate start, LocalDate end) {
        List<WorkSchedule> list = new ArrayList<>();
        String sql = """
        SELECT schedule_id, doctor_id, shift_id, work_date, status
        FROM WorkSchedule
        WHERE doctor_id = ? AND work_date BETWEEN ? AND ?
        ORDER BY work_date, shift_id
    """;

        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, doctorId);
            ps.setDate(2, Date.valueOf(start));
            ps.setDate(3, Date.valueOf(end));

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                WorkSchedule ws = new WorkSchedule();
                ws.setScheduleId(rs.getInt("schedule_id"));
                ws.setDoctorId(rs.getInt("doctor_id"));
                ws.setShiftId(rs.getInt("shift_id"));
                ws.setWorkDate(rs.getDate("work_date"));
                ws.setStatus(rs.getString("status"));
                list.add(ws);
            }

            System.out.println("✅ getScheduleByDoctorAndRange: found " + list.size() + " record(s)");
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean addScheduleForDoctor(int doctorId, LocalDate workDate, String shiftType) {
        try (Connection con = DBConnection.getConnection()) {
            int shiftId;
            Time start;
            Time end;
            String shiftName;

            switch (shiftType) {
                case "morning" -> {
                    shiftId = 1;
                    shiftName = "Ca sáng";
                    start = Time.valueOf("08:00:00");
                    end = Time.valueOf("12:00:00");
                }
                case "afternoon" -> {
                    shiftId = 2;
                    shiftName = "Ca chiều";
                    start = Time.valueOf("13:00:00");
                    end = Time.valueOf("17:00:00");
                }
                case "evening" -> {
                    shiftId = 3;
                    shiftName = "Ca tối";
                    start = Time.valueOf("18:00:00");
                    end = Time.valueOf("22:00:00");
                }
                default -> {
                    return false;
                }
            }

            String checkSql = "SELECT COUNT(*) FROM WorkSchedule WHERE doctor_id=? AND work_date=? AND shift_id=?";
            try (PreparedStatement check = con.prepareStatement(checkSql)) {
                check.setInt(1, doctorId);
                check.setDate(2, Date.valueOf(workDate));
                check.setInt(3, shiftId);
                try (ResultSet rs = check.executeQuery()) {
                    if (rs.next() && rs.getInt(1) > 0) {
                        return false;
                    }
                }
            }

            String sql = "INSERT INTO WorkSchedule (doctor_id, shift_id, work_date, start_time, end_time, status, note) VALUES (?, ?, ?, ?, ?, ?, ?)";
            try (PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setInt(1, doctorId);
                ps.setInt(2, shiftId);
                ps.setDate(3, Date.valueOf(workDate));
                ps.setTime(4, start);
                ps.setTime(5, end);
                ps.setString(6, "Registered");
                ps.setString(7, "Đăng ký " + shiftName);
                int rows = ps.executeUpdate();
                return rows > 0;
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean deleteScheduleByDoctorShiftDate(int doctorId, int shiftId, LocalDate workDate) {
        String sql = "DELETE FROM WorkSchedule WHERE doctor_id=? AND shift_id=? AND work_date=?";
        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, doctorId);
            ps.setInt(2, shiftId);
            ps.setDate(3, Date.valueOf(workDate));
            int rows = ps.executeUpdate();
            System.out.println("🗑 Hủy ca doctor: doctorId=" + doctorId + ", shift=" + shiftId + ", date=" + workDate + " | rows=" + rows);
            return rows > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public WorkSchedule getTodayScheduleForDoctor(int doctorId) {
        String sql = """
        SELECT TOP 1 ws.*, s.ShiftName, s.Location, s.StartTime, s.EndTime
        FROM WorkSchedule ws
        JOIN Shifts s ON ws.shift_id = s.ShiftID
        WHERE ws.doctor_id = ?
          AND ws.work_date = CAST(GETDATE() AS DATE)
          AND CAST(GETDATE() AS time) BETWEEN s.StartTime AND s.EndTime
        ORDER BY s.StartTime
    """;
        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, doctorId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                WorkSchedule ws = new WorkSchedule();
                ws.setScheduleId(rs.getInt("schedule_id"));
                ws.setDoctorId(rs.getInt("doctor_id"));
                ws.setShiftId(rs.getInt("shift_id"));
                ws.setShiftName(rs.getString("ShiftName"));
                ws.setWorkDate(rs.getDate("work_date"));
                ws.setStartTime(rs.getTime("StartTime"));
                ws.setEndTime(rs.getTime("EndTime"));
                ws.setStatus(rs.getString("status"));
                ws.setLocation(rs.getString("Location"));
                return ws;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public List<WorkSchedule> getUpcomingScheduleForDoctor(int doctorId, int days) {
        List<WorkSchedule> list = new ArrayList<>();
        String sql = """
        SELECT ws.*, s.ShiftName, s.Location, s.StartTime, s.EndTime
        FROM WorkSchedule ws
        JOIN Shifts s ON ws.shift_id = s.ShiftID
        WHERE ws.doctor_id = ?
          AND ws.work_date BETWEEN CAST(GETDATE() AS DATE) AND DATEADD(DAY, ?, CAST(GETDATE() AS DATE))
        ORDER BY ws.work_date, s.StartTime
    """;
        
        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, doctorId);
            ps.setInt(2, days);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                WorkSchedule ws = new WorkSchedule();
                ws.setScheduleId(rs.getInt("schedule_id"));
                ws.setDoctorId(rs.getInt("doctor_id"));
                ws.setShiftId(rs.getInt("shift_id"));
                ws.setShiftName(rs.getString("ShiftName"));
                ws.setWorkDate(rs.getDate("work_date"));
                ws.setStartTime(rs.getTime("StartTime"));
                ws.setEndTime(rs.getTime("EndTime"));
                ws.setStatus(rs.getString("status"));
                ws.setLocation(rs.getString("Location"));
                list.add(ws);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
}
