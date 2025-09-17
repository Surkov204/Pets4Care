package utils;

import dao.OrderDAO;
import dao.ToyDAO;
import jakarta.mail.*;
import jakarta.mail.internet.*;
import java.util.List;
import java.util.Properties;
import model.Order;
import model.OrderDetail;
import model.Customer;

public class EmailUtils {

    // Các hằng số cấu hình email
    private static final String SENDER_EMAIL = "vinhhtien110@gmail.com";
    private static final String SENDER_PASSWORD = "exaq aozn rcdp jjtm"; // App Password
    private static final String SMTP_HOST = "smtp.gmail.com";
    private static final int SMTP_PORT = 587;

    // Phương thức khởi tạo session chung
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

    // GIỮ NGUYÊN PHƯƠNG THỨC CŨ - Gửi email xác nhận đơn hàng
    public static void sendOrderConfirmation(String recipientEmail, int orderId) {
        try {
            OrderDAO dao = new OrderDAO();
            ToyDAO toyDAO = new ToyDAO();
            Order order = dao.getOrderById(orderId);
            List<OrderDetail> details = dao.getOrderDetailsByOrderId(orderId);

            StringBuilder content = new StringBuilder();
            content.append("<div style='font-family:Arial,sans-serif; max-width:600px; margin:auto;'>");
            content.append("<h2 style='color:#2E8B57;'>🎉 Cảm ơn bạn đã đặt hàng tại <strong>PET TOY SHOP</strong>!</h2>");
            content.append("<p>🧾 <strong>Mã đơn hàng:</strong> ").append(order.getOrderId()).append("</p>");
            content.append("<p>📅 <strong>Ngày đặt:</strong> ").append(order.getOrderDate()).append("</p>");
            content.append("<p>💳 <strong>Thanh toán:</strong> ").append(order.getPaymentMethod()).append("</p>");
            content.append("<p>🚚 <strong>Trạng thái:</strong> ").append(order.getStatus()).append("</p>");

            // Thêm địa chỉ giao hàng
            content.append("<p>🏠 <strong>Địa chỉ giao hàng:</strong> ").append(order.getShippingAddress()).append("</p>");

            content.append("<hr>");
            content.append("<h3>📦 Chi tiết đơn hàng:</h3>");
            content.append("<table border='1' cellpadding='10' cellspacing='0' style='border-collapse:collapse; width:100%;'>");
            content.append("<thead style='background-color:#f2f2f2;'>");
            content.append("<tr><th>Tên sản phẩm</th><th>Số lượng</th><th>Đơn giá</th></tr>");
            content.append("</thead><tbody>");

            // Thêm chi tiết đơn hàng
            for (OrderDetail d : details) {
                String toyName = toyDAO.getToyNameById(d.getToyId());
                content.append("<tr>")
                        .append("<td>").append(toyName).append("</td>")
                        .append("<td>").append(d.getQuantity()).append("</td>")
                        .append("<td>").append(String.format("%.2f", d.getUnitPrice())).append(" đ</td>")
                        .append("</tr>");
            }

            content.append("</tbody></table>");
            content.append("<p style='margin-top:16px; font-size:16px;'><strong>💰 Tổng tiền: ")
                   .append(String.format("%.2f", order.getTotalAmount())).append(" đ</strong></p>");
            content.append("<hr>");
            content.append("<p style='color:gray; font-size:13px;'>Nếu bạn có bất kỳ thắc mắc nào, vui lòng liên hệ hotline: <strong>0912 345 678</strong></p>");
            content.append("</div>");

            // Gửi email
            Message message = new MimeMessage(getMailSession());
            message.setFrom(new InternetAddress(SENDER_EMAIL, "PET TOY SHOP", "UTF-8"));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(recipientEmail));
            message.setSubject("🧾 Xác nhận đơn hàng #" + order.getOrderId());
            message.setContent(content.toString(), "text/html; charset=UTF-8");

            Transport.send(message);
            System.out.println("✅ Đã gửi email xác nhận đến: " + recipientEmail);

        } catch (Exception e) {
            System.err.println("❌ Lỗi gửi email xác nhận đơn hàng: " + e.getMessage());
            e.printStackTrace();
        }
    }



    public static boolean sendOTPEmail(String recipientEmail, String otp, String customerName) {
        try {
            String htmlContent = buildOTPEmailContent(customerName, otp);

            Message message = new MimeMessage(getMailSession());
            message.setFrom(new InternetAddress(SENDER_EMAIL, "Petcity", "UTF-8"));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(recipientEmail));
            message.setSubject("🐾 Mã OTP đặt lại mật khẩu Petcity");
            message.setContent(htmlContent, "text/html; charset=UTF-8");

            Transport.send(message);
            System.out.println("✅ Email OTP đã gửi đến: " + recipientEmail);
            return true;
        } catch (Exception e) {
            System.err.println("❌ Lỗi gửi email OTP: " + e.getMessage());
            return false;
        }
    }

    private static String buildOTPEmailContent(String customerName, String otp) {
        return "<div style='font-family:Arial,sans-serif; max-width:600px; margin:auto; border:1px solid #e1e1e1; border-radius:8px; padding:20px;'>"
                + "<h2 style='color:#6FD5DD;'>🐾 Petcity - Mã OTP đặt lại mật khẩu</h2>"
                + "<p>Xin chào <strong>" + customerName + "</strong>,</p>"
                + "<p>Chúng tôi nhận được yêu cầu đặt lại mật khẩu cho tài khoản Petcity của bạn.</p>"
                + "<p>Mã OTP của bạn là: <strong style='font-size:24px;'>" + otp + "</strong></p>"
                + "<p>Mã có hiệu lực trong <strong>5 phút</strong>. Vui lòng không chia sẻ mã này với ai.</p>"
                + "<hr style='border:none; border-top:1px solid #e1e1e1; margin:20px 0;'>"
                + "<p style='color:#888; font-size:12px;'>Nếu bạn không yêu cầu đặt lại mật khẩu, vui lòng bỏ qua email này.</p>"
                + "</div>";
    }



    

    
}