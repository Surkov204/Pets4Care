/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package service;

import dao.CustomerDAO;
import dao.ICustomerDAO;
import java.util.List;
import model.Customer;

/**
 *
 * @author ASUS
 */
public class CustomerService implements ICustomerService {

    private ICustomerDAO customerDAO = new CustomerDAO();

    @Override
    public List<Customer> getAllCustomers() {
        return customerDAO.getAllCustomers();
    }

    @Override
    public List<Customer> searchCustomers(String keyword) {
        return customerDAO.searchCustomers(keyword);
    }

    @Override
    public void updateCustomerStatus(int customerId, String status) {
        customerDAO.updateStatus(customerId, status);
    }

}
