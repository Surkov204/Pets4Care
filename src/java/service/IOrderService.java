/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Interface.java to edit this template
 */
package service;

import java.util.List;
import model.Order;
import model.OrderItem;
import model.OrderStats;

/**
 *
 * @author ASUS
 */
public interface IOrderService {

    List<Order> getOrdersByCustomerId(int customerId);

    OrderStats getOrderStatsByCustomerId(int customerId);

    List<Order> getAllOrders();

    List<Order> searchOrders(String keyword);

    List<Order> filterOrdersByStatus(String status);

    Order getOrderById(int orderId);

    List<OrderItem> getOrderItems(int orderId);

}
