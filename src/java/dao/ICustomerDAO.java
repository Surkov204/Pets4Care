
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
