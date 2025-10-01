package service;

import dao.UserDAO;
import model.Customer;
import model.GoogleUser;
import org.mindrot.jbcrypt.BCrypt;

public class UserService implements IUserService {

    private UserDAO userDao = new UserDAO();

    @Override
    public Customer loginCustomer(String email, String password) {
        Customer customer = userDao.findByEmail(email);
        if (customer != null) {
            String stored = customer.getPassword();

            try {
                if (stored != null && stored.startsWith("$2")) {
                    if (BCrypt.checkpw(password, stored)) {
                        return customer;
                    }
                } else {
                    if (password.equals(stored)) {
                        String hashed = BCrypt.hashpw(password, BCrypt.gensalt(12));
                        userDao.resetPassword(customer.getEmail(), hashed);
                        customer.setPassword(hashed);
                        return customer;
                    }
                }
            } catch (Exception e) {
                System.err.println("Password check error: " + e.getMessage());
            }
        }
        return null;
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

        String hashed = BCrypt.hashpw(customer.getPassword(), BCrypt.gensalt(12));
        customer.setPassword(hashed);

        return userDao.registerCustomer(customer);
    }

    @Override
    public boolean resetPassword(String email, String newPassword) {

        String hased = BCrypt.hashpw(newPassword, BCrypt.gensalt(12));
        return userDao.resetPassword(email, hased);
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
