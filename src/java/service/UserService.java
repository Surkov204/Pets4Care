package service;

import dao.UserDAO;
import model.Customer;
import model.GoogleUser;

public class UserService implements IUserService {

    private UserDAO userDao = new UserDAO();

    @Override
    public Customer loginCustomer(String email, String password) {
        return userDao.loginCustomer(email, password);
    }

    @Override
    public boolean registerCustomer(Customer customer) {
        // Kiểm tra trước khi đăng ký
        if (checkEmailExists(customer.getEmail())) {
            throw new IllegalArgumentException("Email đã tồn tại");
        }
        if (checkPhoneExists(customer.getPhone())) {
            throw new IllegalArgumentException("Số điện thoại đã tồn tại");
        }
        return userDao.registerCustomer(customer);
    }

    @Override
    public boolean resetPassword(String email, String newPassword) {
        return userDao.resetPassword(email, newPassword);
    }
    
    
    @Override
    public Customer loginWithGoogle(GoogleUser user) {
        return userDao.findOrCreateByGoogle(user);
    }

    @Override
    public boolean checkEmailExists(String email) {
        return userDao.checkEmailExists(email);
    }

    @Override
    public boolean checkPhoneExists(String phone) {
        return userDao.checkPhoneExists(phone);
    }
}

