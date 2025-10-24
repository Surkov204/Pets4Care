package dao;
import java.sql.*;
import java.util.*;
import model.Notification;
import utils.DBConnection;

public class NotificationDAO {

    // 🔔 Gửi thông báo cho 1 nhân viên
    public void createNotification(int staffId, String title, String message) {
        String sql = "INSERT INTO Notifications (StaffID, Title, Message) VALUES (?, ?, ?)";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, staffId);
            ps.setString(2, title);
            ps.setString(3, message);
            ps.executeUpdate();
            System.out.println("[NotificationDAO] 🔔 Sent to staff #" + staffId);
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    // 📬 Lấy tất cả thông báo chưa đọc & chưa xử lý
    public List<Notification> getUnread(int staffId) {
        List<Notification> list = new ArrayList<>();
        String sql = "SELECT * FROM Notifications WHERE StaffID=? AND IsRead=0 AND IsHandled=0 ORDER BY CreatedAt DESC";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, staffId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(new Notification(
                    rs.getInt("NotificationID"),
                    rs.getInt("StaffID"),
                    rs.getString("Title"),
                    rs.getString("Message"),
                    rs.getTimestamp("CreatedAt"),
                    rs.getBoolean("IsRead"),
                    rs.getBoolean("IsHandled")
                ));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // ✅ Đánh dấu tất cả thông báo là đã đọc
    public void markAsRead(int staffId) {
        String sql = "UPDATE Notifications SET IsRead=1 WHERE StaffID=?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, staffId);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    // 🔢 Đếm số thông báo chưa đọc
    public int countUnread(int staffId) {
        String sql = "SELECT COUNT(*) FROM Notifications WHERE StaffID=? AND IsRead=0 AND IsHandled=0";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, staffId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    // 📜 Lấy toàn bộ thông báo
    public List<Notification> getNotifications(int staffId) {
        List<Notification> list = new ArrayList<>();
        String sql = "SELECT * FROM Notifications WHERE StaffID = ? ORDER BY CreatedAt DESC";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, staffId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(new Notification(
                    rs.getInt("NotificationID"),
                    rs.getInt("StaffID"),
                    rs.getString("Title"),
                    rs.getString("Message"),
                    rs.getTimestamp("CreatedAt"),
                    rs.getBoolean("IsRead"),
                    rs.getBoolean("IsHandled")
                ));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // 🧭 Gửi thông báo cho admin (StaffID = NULL)
    public void createForAdmin(String title, String message) {
        String sql = "INSERT INTO Notifications (StaffID, Title, Message) VALUES (NULL, ?, ?)";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, title);
            ps.setString(2, message);
            ps.executeUpdate();
            System.out.println("[NotificationDAO] 📢 Sent to admin dashboard");
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    // 🔁 Gửi thông báo cho 2 nhân viên trong yêu cầu đổi ca
    public void createForStaffByRequest(int requestId, String title, String message) {
        String sql = "SELECT EmployeeID, ToStaffID FROM ShiftRequests WHERE RequestID = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, requestId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                int empA = rs.getInt("EmployeeID");
                int empB = rs.getInt("ToStaffID");
                createNotification(empA, title, message);
                createNotification(empB, title, message);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    // ✅ Đánh dấu thông báo là đã xử lý (sau khi nhân viên đồng ý hoặc từ chối)
    public void markAsHandled(int notificationId) {
        String sql = "UPDATE Notifications SET IsHandled = 1 WHERE NotificationID = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, notificationId);
            ps.executeUpdate();
            System.out.println("[NotificationDAO] ✅ Notification #" + notificationId + " marked as handled");
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}