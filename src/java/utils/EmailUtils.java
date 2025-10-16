package utils;

import dao.OrderDAO;
import dao.ProductDAO;
import jakarta.mail.*;
import jakarta.mail.internet.*;
import java.util.List;
import java.util.Properties;
import model.Order;
import model.OrderDetail;

public class EmailUtils {

    // ====================== CẤU HÌNH EMAIL ======================
    private static final String SENDER_EMAIL = "th9312242@gmail.com";
    private static final String SENDER_PASSWORD = "cilb tiuu uyti wxbz"; // App Password Gmail
    private static final String SMTP_HOST = "smtp.gmail.com";
    private static final int SMTP_PORT = 587;

    // ====================== KHỞI TẠO SESSION ======================
    private static Session getMailSession() {
        Properties props = new Properties();
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.host", SMTP_HOST);
        props.put("mail.smtp.port", SMTP_PORT);

        return Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(SENDER_EMAIL, SENDER_PASSWORD);
            }
        });
    }

    // ====================== GỬI EMAIL XÁC NHẬN ĐƠN HÀNG ======================
    public static void sendOrderConfirmation(String recipientEmail, int orderId) {
        try {
            OrderDAO orderDAO = new OrderDAO();
            ProductDAO productDAO = new ProductDAO();
            Order order = orderDAO.getOrderById(orderId);
            List<OrderDetail> details = orderDAO.getOrderDetailsByOrderId(orderId);

            // Nội dung email HTML
            StringBuilder content = new StringBuilder();
            content.append("<div style='font-family:Arial,sans-serif; max-width:600px; margin:auto;'>")
                    .append("<h2 style='color:#2E8B57;'>🎉 Cảm ơn bạn đã đặt hàng tại <strong>PET TOY SHOP</strong>!</h2>")
                    .append("<p>🧾 <strong>Mã đơn hàng:</strong> ").append(order.getOrderId()).append("</p>")
                    .append("<p>📅 <strong>Ngày đặt:</strong> ").append(order.getOrderDate()).append("</p>")
                    .append("<p>💳 <strong>Thanh toán:</strong> ").append(order.getPaymentMethod()).append("</p>")
                    .append("<p>🚚 <strong>Trạng thái:</strong> ").append(order.getStatus()).append("</p>")
                    .append("<p>🏠 <strong>Địa chỉ giao hàng:</strong> ").append(order.getShippingAddress()).append("</p>")
                    .append("<hr>")
                    .append("<h3>📦 Chi tiết đơn hàng:</h3>")
                    .append("<table border='1' cellpadding='10' cellspacing='0' style='border-collapse:collapse; width:100%;'>")
                    .append("<thead style='background-color:#f2f2f2;'>")
                    .append("<tr><th>Tên sản phẩm</th><th>Số lượng</th><th>Đơn giá</th></tr>")
                    .append("</thead><tbody>");

            for (OrderDetail d : details) {
                String productName = productDAO.getProductNameById(d.getProductId());
                content.append("<tr>")
                        .append("<td>").append(productName).append("</td>")
                        .append("<td>").append(d.getQuantity()).append("</td>")
                        .append("<td>").append(String.format("%.2f", d.getUnitPrice())).append(" đ</td>")
                        .append("</tr>");
            }

            content.append("</tbody></table>")
                    .append("<p style='margin-top:16px; font-size:16px;'><strong>💰 Tổng tiền: ")
                    .append(String.format("%.2f", order.getTotalAmount())).append(" đ</strong></p>")
                    .append("<hr>")
                    .append("<p style='color:gray; font-size:13px;'>Nếu bạn có bất kỳ thắc mắc nào, vui lòng liên hệ hotline: <strong>0912 345 678</strong></p>")
                    .append("</div>");

            // Gửi email
            Message message = new MimeMessage(getMailSession());
            message.setFrom(new InternetAddress(SENDER_EMAIL, "PET TOY SHOP", "UTF-8"));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(recipientEmail));
            String subject = MimeUtility.encodeText("# Xác nhận đơn hàng #" + order.getOrderId(), "UTF-8", "B");
            message.setSubject(subject);
            message.setContent(content.toString(), "text/html; charset=UTF-8");

            Transport.send(message);
            System.out.println("✅ Đã gửi email xác nhận đến: " + recipientEmail);

        } catch (Exception e) {
            System.err.println("❌ Lỗi gửi email xác nhận đơn hàng: " + e.getMessage());
            e.printStackTrace();
        }
    }

    // ====================== GỬI EMAIL OTP ======================
    public static boolean sendOTPEmail(String recipientEmail, String otp, String customerName) {
        try {
            String htmlContent = buildOTPEmailContent(customerName, otp);

            Message message = new MimeMessage(getMailSession());
            message.setFrom(new InternetAddress(SENDER_EMAIL, "Petcity", "UTF-8"));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(recipientEmail));

            // Encode subject để giữ Unicode + emoji
            String subject = MimeUtility.encodeText("🐾 Mã OTP đặt lại mật khẩu Petcity", "UTF-8", "B");
            message.setSubject(subject);

            message.setContent(htmlContent, "text/html; charset=UTF-8");

            Transport.send(message);
            System.out.println("✅ Email OTP đã gửi đến: " + recipientEmail);
            return true;
        } catch (Exception e) {
            System.err.println("❌ Lỗi gửi email OTP: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    // ====================== GỬI EMAIL OTP ĐĂNG KÝ ======================
    public static boolean sendRegisterOTPEmail(String recipientEmail, String otp, String customerName) {
        try {
            String htmlContent = buildRegisterOTPEmailContent(customerName, otp);

            Message message = new MimeMessage(getMailSession());
            message.setFrom(new InternetAddress(SENDER_EMAIL, "Petcity", "UTF-8"));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(recipientEmail));

            // Encode subject để giữ Unicode + emoji
            String subject = MimeUtility.encodeText("🐾 Mã OTP xác nhận đăng ký Petcity", "UTF-8", "B");
            message.setSubject(subject);

            message.setContent(htmlContent, "text/html; charset=UTF-8");

            Transport.send(message);
            System.out.println("✅ Email OTP đăng ký đã gửi đến: " + recipientEmail);
            return true;
        } catch (Exception e) {
            System.err.println("❌ Lỗi gửi email OTP đăng ký: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    // ====================== TẠO NỘI DUNG OTP HTML ======================
    private static String buildOTPEmailContent(String customerName, String otp) {
        return "<div style='font-family:Arial,sans-serif; max-width:600px; margin:auto; border:1px solid #e1e1e1; border-radius:8px; padding:20px;'>"
                + "<h2 style='color:#6FD5DD;'>🐾 Petcity - Mã OTP đặt lại mật khẩu</h2>"
                + "<p>Xin chào <strong>" + customerName + "</strong>,</p>"
                + "<p>Chúng tôi nhận được yêu cầu đặt lại mật khẩu cho tài khoản Petcity của bạn.</p>"
                + "<p>Mã OTP của bạn là: <strong style='font-size:24px; color:#E74C3C;'>" + otp + "</strong></p>"
                + "<p>Mã có hiệu lực trong <strong>5 phút</strong>. Vui lòng không chia sẻ mã này với ai.</p>"
                + "<hr style='border:none; border-top:1px solid #e1e1e1; margin:20px 0;'>"
                + "<p style='color:#888; font-size:12px;'>Nếu bạn không yêu cầu đặt lại mật khẩu, vui lòng bỏ qua email này.</p>"
                + "</div>";
    }

    // ====================== TẠO NỘI DUNG OTP ĐĂNG KÝ HTML ======================
    private static String buildRegisterOTPEmailContent(String customerName, String otp) {
        return "<div style='font-family:Arial,sans-serif; max-width:600px; margin:auto; border:1px solid #e1e1e1; border-radius:8px; padding:20px;'>"
                + "<h2 style='color:#6FD5DD;'>🐾 Petcity - Chào mừng bạn đến với Petcity!</h2>"
                + "<p>Xin chào <strong>" + customerName + "</strong>,</p>"
                + "<p>Cảm ơn bạn đã đăng ký tài khoản tại Petcity. Để hoàn tất quá trình đăng ký, vui lòng xác nhận email của bạn.</p>"
                + "<p>Mã OTP xác nhận của bạn là: <strong style='font-size:24px; color:#E74C3C;'>" + otp + "</strong></p>"
                + "<p>Mã có hiệu lực trong <strong>5 phút</strong>. Vui lòng không chia sẻ mã này với ai.</p>"
                + "<hr style='border:none; border-top:1px solid #e1e1e1; margin:20px 0;'>"
                + "<p style='color:#888; font-size:12px;'>Nếu bạn không đăng ký tài khoản này, vui lòng bỏ qua email này.</p>"
                + "</div>";
    }
}
