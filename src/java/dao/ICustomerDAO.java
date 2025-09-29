/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Interface.java to edit this template
 */
package dao;

import java.util.List;
import model.Customer;

/**
 *
 * @author ASUS
 */
public interface ICustomerDAO {

    List<Customer> getAllCustomers();

    List<Customer> searchCustomers(String keyword);
    
    void updateStatus(int customerId, String status);

}
