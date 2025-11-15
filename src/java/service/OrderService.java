/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package service;

import dao.IOrderDAO;
import dao.OrderDAO;
import java.util.List;
import model.Order;
import model.OrderItem;
import model.OrderStats;

/**
 *
 * @author ASUS
 */
public class OrderService implements IOrderService{
    private IOrderDAO orderDAO = new OrderDAO();

    @Override
    public List<Order> getOrdersByCustomerId(int customerId) {
        return orderDAO.getOrdersByCustomerId(customerId);
    }

    @Override
    public OrderStats getOrderStatsByCustomerId(int customerId) {
        return orderDAO.getOrderStatsByCustomerId(customerId);
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
    public Order getOrderById(int orderId) {
        return orderDAO.getOrderById(orderId);
    }

    @Override
    public List<OrderItem> getOrderItems(int orderId) {
        return orderDAO.getOrderItems(orderId);
    }
}
