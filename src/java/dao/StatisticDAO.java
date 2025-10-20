package dao;

import java.util.LinkedHashMap;
import java.util.Map;
import java.sql.*;
import utils.DBConnection;

public class StatisticDAO implements IStatisticDAO {

    private Connection getConnection() throws Exception {
        return DBConnection.getConnection();
    }

    @Override
    public Map<String, Double> getDailyRevenue() {
        return getRevenue(
                "SELECT CONVERT(date, order_date) AS [time], SUM(total_amount) AS [revenue] "
                + "FROM [Order] WHERE status IN (N'Hoàn tất', N'Đã hoàn tất') "
                + "GROUP BY CONVERT(date, order_date) ORDER BY [time]"
        );
    }

    @Override
    public Map<String, Double> getMonthlyRevenue() {
        return getRevenue(
                "SELECT FORMAT(order_date, 'yyyy-MM') AS [time], SUM(total_amount) AS [revenue] "
                + "FROM [Order] WHERE status IN (N'Hoàn tất', N'Đã hoàn tất') "
                + "GROUP BY FORMAT(order_date, 'yyyy-MM') ORDER BY [time]"
        );
    }

    @Override
    public Map<String, Double> getYearlyRevenue() {
        return getRevenue(
                "SELECT CAST(YEAR(order_date) AS varchar) AS [time], SUM(total_amount) AS [revenue] "
                + "FROM [Order] WHERE status IN (N'Hoàn tất', N'Đã hoàn tất') "
                + "GROUP BY YEAR(order_date) ORDER BY [time]"
        );
    }

    private Map<String, Double> getRevenue(String query) {
        Map<String, Double> result = new LinkedHashMap<>();
        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(query); ResultSet rs = ps.executeQuery()) {

            System.out.println("📊 [DEBUG] Kết quả doanh thu:");
            while (rs.next()) {
                String label = rs.getString(1);      // alias: time
                double value = rs.getDouble(2);      // alias: revenue
                System.out.println("⏰ " + label + " → 💸 " + value);
                result.put(label, value);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return result;
    }

}