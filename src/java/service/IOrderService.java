package service;

import model.Order;
import model.OrderItem;
import java.util.List;

public interface IOrderService {
    Order getOrderById(int orderId);
    List<Order> getAllOrders();
    List<Order> searchOrders(String keyword);
    List<Order> filterOrdersByStatus(String status);
    List<OrderItem> getOrderItems(int orderId);
    boolean updateOrderStatus(int orderId, String newStatus);
}

