package dao;

import model.ChatMessage;
import java.sql.*;
import java.util.*;

public class ChatDAO {

    private final Connection conn;

    public ChatDAO(Connection conn) {
        this.conn = conn;
    }

    public void addMessage(ChatMessage msg) throws SQLException {
        String sql = "INSERT INTO ChatMessages (CustomerID, StaffID, SenderType, Message, SentAt, IsRead) "
                + "VALUES (?, ?, ?, ?, GETDATE(), 0)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, msg.getCustomerId());
            if (msg.getStaffId() == null) {
                ps.setNull(2, Types.INTEGER);
            } else {
                ps.setInt(2, msg.getStaffId());
            }
            ps.setString(3, msg.getSenderType());
            ps.setString(4, msg.getMessage());
            ps.executeUpdate();
            System.out.println("✅ [ChatDAO] Message inserted: " + msg.getMessage());
        }
    }

    public List<ChatMessage> getMessagesByCustomer(int customerId) throws SQLException {
        List<ChatMessage> list = new ArrayList<>();
        String sql = "SELECT * FROM ChatMessages WHERE CustomerID = ? ORDER BY SentAt ASC";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                ChatMessage msg = new ChatMessage();
                msg.setMessageId(rs.getInt("MessageID"));
                msg.setCustomerId(rs.getInt("CustomerID"));
                msg.setStaffId((Integer) rs.getObject("StaffID"));
                msg.setSenderType(rs.getString("SenderType"));
                msg.setMessage(rs.getString("Message"));
                msg.setSentAt(rs.getTimestamp("SentAt"));
                msg.setRead(rs.getBoolean("IsRead"));
                list.add(msg);
            }
        }
        return list;
    }

    public List<Map<String, Object>> getChatSessions() throws SQLException {
        List<Map<String, Object>> list = new ArrayList<>();

        String sql = """
        SELECT cm.CustomerID,
               cu.name AS CustomerName,
               MIN(cm.SentAt) AS StartedAt,
               MAX(cm.SentAt) AS LastMsgAt
        FROM ChatMessages cm
        JOIN Customer cu ON cm.CustomerID = cu.customer_id
        GROUP BY cm.CustomerID, cu.name
        ORDER BY LastMsgAt DESC
    """;

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("customerId", rs.getInt("CustomerID"));
                row.put("customerName", rs.getString("CustomerName"));
                row.put("startedAt", rs.getTimestamp("StartedAt"));
                row.put("lastMsgAt", rs.getTimestamp("LastMsgAt"));
                list.add(row);
            }
        }

        System.out.println("✅ [ChatDAO] getChatSessions() returned " + list.size() + " session(s)");
        return list;
    }

    public int countUnreadMessages() throws SQLException {
        String sql = "SELECT COUNT(*) FROM ChatMessages WHERE SenderType = 'customer' AND IsRead = 0";
        try (PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        }
        return 0;
    }

// ✅ Đánh dấu là đã đọc khi staff mở chat với 1 khách cụ thể
    public void markMessagesAsRead(int customerId) throws SQLException {
        String sql = "UPDATE ChatMessages SET IsRead = 1 WHERE CustomerID = ? AND SenderType = 'customer' AND IsRead = 0";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            ps.executeUpdate();
        }
    }

}
