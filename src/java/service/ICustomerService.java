/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Interface.java to edit this template
 */
package service;

import java.util.List;
import model.Customer;

/**
 *
 * @author ASUS
 */
public interface ICustomerService {

    List<Customer> getAllCustomers();

    List<Customer> searchCustomers(String keyword);
    
    void updateCustomerStatus(int customerId, String status);

}
