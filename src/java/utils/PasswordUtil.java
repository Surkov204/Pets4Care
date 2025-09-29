package utils;



public class PasswordUtil {
    // Phương thức mã hóa mật khẩu - trả về plain text
    public static String hashPassword(String password) {
        return password; // Không mã hóa, trả về password gốc
    }

    // Phương thức kiểm tra mật khẩu - so sánh plain text
    public static boolean verifyPassword(String inputPassword, String storedPassword) {
        return inputPassword.equals(storedPassword); // So sánh trực tiếp
    }
}