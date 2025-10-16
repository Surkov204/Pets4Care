package service;

import dao.IOrderDAO;
import dao.OrderDAO;
import model.Order;
import model.OrderItem;
import java.util.List;

public class OrderService implements IOrderService {
    
    private final IOrderDAO orderDAO;
    
    public OrderService() {
        this.orderDAO = new OrderDAO();
    }
    
    @Override
    public Order getOrderById(int orderId) {
        return orderDAO.getOrderById(orderId);
    }
    
    @Override
    public List<Order> getAllOrders() {
        return orderDAO.getAllOrders();
    }
    
    @Override
    public List<Order> searchOrders(String keyword) {
        return orderDAO.searchOrders(keyword);
    }
    
    @Override
    public List<Order> filterOrdersByStatus(String status) {
        return orderDAO.filterByStatus(status);
    }
    
    @Override
    public List<OrderItem> getOrderItems(int orderId) {
        return orderDAO.getOrderItems(orderId);
    }
    
    @Override
    public boolean updateOrderStatus(int orderId, String newStatus) {
        return orderDAO.updateOrderStatus(orderId, newStatus);
    }
}

