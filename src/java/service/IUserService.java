package service;

import model.Customer;
import model.GoogleUser;

public interface IUserService {
    Customer loginCustomer(String email, String password);
    boolean registerCustomer(Customer customer);
    Customer loginWithGoogle(GoogleUser user);
    boolean checkEmailExists(String email);  
    boolean checkPhoneExists(String phone); 
    boolean resetPassword(String email, String newPassword);
}
