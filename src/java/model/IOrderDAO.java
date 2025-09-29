package model;

import dao.*;
import model.Order;
import model.OrderDetail;
import model.OrderItem;
import model.OrderStats;
import java.util.List;

public interface IOrderDAO {
    // Các phương thức từ phiên bản cũ
    Order getOrderById(int orderId);
    List<OrderDetail> getOrderDetailsByOrderId(int orderId);
    
    // Các phương thức từ phiên bản mới
    List<Order> getOrdersByCustomerId(int customerId);
    OrderStats getOrderStatsByCustomerId(int customerId);
    List<Order> getAllOrders();
    List<Order> searchOrders(String keyword);
    List<Order> filterByStatus(String status);
    List<OrderItem> getOrderItems(int orderId);
    boolean updateOrderStatus(int orderId, String newStatus);
}