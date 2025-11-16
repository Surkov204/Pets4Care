package utils;

import dao.OrderDAO;
import dao.ProductDAO;
import dao.PetServiceDAO;
import jakarta.mail.*;
import jakarta.mail.internet.*;
import java.util.List;
import java.util.Properties;
import java.math.BigDecimal;
import model.Order;
import model.OrderDetail;
import model.Booking;
import model.BookingServiceItem;

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

    // ====================== GỬI EMAIL BIÊN LAI HOÀN TIỀN SPA ======================
    public static void sendRefundInvoice(String recipientEmail, String customerName, int bookingId, 
                                        Booking booking, List<BookingServiceItem> bookingServices, BigDecimal totalAmount) {
        try {
            PetServiceDAO petServiceDAO = new PetServiceDAO();
            
            // Nội dung email HTML
            StringBuilder content = new StringBuilder();
            content.append("<div style='font-family:Arial,sans-serif; max-width:600px; margin:auto; border:2px solid #E74C3C; border-radius:8px; padding:20px;'>")
                    .append("<h2 style='color:#E74C3C;'>💰 BIÊN LAI HOÀN TIỀN - ĐẶT LỊCH SPA</h2>")
                    .append("<p>Xin chào <strong>").append(customerName != null ? customerName : "Khách hàng").append("</strong>,</p>")
                    .append("<p>Chúng tôi xác nhận đã nhận được yêu cầu hủy đặt lịch Spa của bạn.</p>")
                    .append("<hr>")
                    .append("<h3 style='color:#2E8B57;'>📋 Thông tin booking:</h3>")
                    .append("<p><strong>Mã booking:</strong> #").append(bookingId).append("</p>")
                    .append("<p><strong>Ngày đặt lịch:</strong> ").append(booking.getAppointmentStart() != null ? booking.getAppointmentStart() : "N/A").append("</p>")
                    .append("<p><strong>Trạng thái:</strong> <span style='color:#E74C3C; font-weight:bold;'>Yêu cầu hoàn tiền</span></p>")
                    .append("<hr>")
                    .append("<h3 style='color:#2E8B57;'>🧾 Chi tiết dịch vụ đã hủy:</h3>")
                    .append("<table border='1' cellpadding='10' cellspacing='0' style='border-collapse:collapse; width:100%;'>")
                    .append("<thead style='background-color:#f2f2f2;'>")
                    .append("<tr><th>Tên dịch vụ</th><th>Số lượng</th><th>Đơn giá</th><th>Thành tiền</th></tr>")
                    .append("</thead><tbody>");

            for (BookingServiceItem bs : bookingServices) {
                String serviceName = petServiceDAO.getServiceById(bs.getServiceId()) != null 
                    ? petServiceDAO.getServiceById(bs.getServiceId()).getName() 
                    : "Dịch vụ #" + bs.getServiceId();
                BigDecimal itemTotal = bs.getPrice().multiply(BigDecimal.valueOf(bs.getQuantity()));
                
                content.append("<tr>")
                        .append("<td>").append(serviceName).append("</td>")
                        .append("<td>").append(bs.getQuantity()).append("</td>")
                        .append("<td>").append(String.format("%.0f", bs.getPrice().doubleValue())).append(" ₫</td>")
                        .append("<td><strong>").append(String.format("%.0f", itemTotal.doubleValue())).append(" ₫</strong></td>")
                        .append("</tr>");
            }

            content.append("</tbody></table>")
                    .append("<p style='margin-top:16px; font-size:18px; text-align:right;'><strong style='color:#E74C3C;'>💰 Tổng tiền hoàn lại: ")
                    .append(String.format("%.0f", totalAmount.doubleValue())).append(" ₫</strong></p>")
                    .append("<hr>")
                    .append("<p style='background-color:#FFF3CD; padding:15px; border-left:4px solid #FFC107; border-radius:4px;'>")
                    .append("<strong>📌 Lưu ý:</strong><br>")
                    .append("• Bạn có thể lên cửa hàng để nhận lại tiền.<br>")
                    .append("• Vui lòng mang theo biên lai này (có thể in ra hoặc hiển thị trên điện thoại).<br>")
                    .append("• Thời gian hoàn tiền: Trong vòng 7 ngày làm việc.")
                    .append("</p>")
                    .append("<hr>")
                    .append("<p style='color:gray; font-size:13px;'>Nếu bạn có bất kỳ thắc mắc nào, vui lòng liên hệ hotline: <strong>0912 345 678</strong></p>")
                    .append("</div>");

            // Gửi email
            Message message = new MimeMessage(getMailSession());
            message.setFrom(new InternetAddress(SENDER_EMAIL, "Pets4Care", "UTF-8"));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(recipientEmail));
            String subject = MimeUtility.encodeText("💰 Biên lai hoàn tiền - Booking #" + bookingId, "UTF-8", "B");
            message.setSubject(subject);
            message.setContent(content.toString(), "text/html; charset=UTF-8");

            Transport.send(message);
            System.out.println("✅ Đã gửi email biên lai hoàn tiền đến: " + recipientEmail);

        } catch (Exception e) {
            System.err.println("❌ Lỗi gửi email biên lai hoàn tiền: " + e.getMessage());
            e.printStackTrace();
        }
    }

    // ====================== GỬI EMAIL BIÊN LAI HOÀN TIỀN ĐƠN HÀNG ======================
    public static void sendOrderRefundInvoice(String recipientEmail, String customerName, int orderId, 
                                             Order order, List<OrderDetail> orderDetails, double totalAmount) {
        System.out.println("📧 ===== BẮT ĐẦU GỬI EMAIL HOÀN TIỀN ĐƠN HÀNG =====");
        System.out.println("📧 Email người nhận: " + recipientEmail);
        System.out.println("📧 Tên khách hàng: " + customerName);
        System.out.println("📧 Mã đơn hàng: " + orderId);
        System.out.println("📧 Tổng tiền: " + totalAmount);
        
        try {
            ProductDAO productDAO = new ProductDAO();
            
            // Nội dung email HTML
            StringBuilder content = new StringBuilder();
            content.append("<div style='font-family:Arial,sans-serif; max-width:600px; margin:auto; border:2px solid #E74C3C; border-radius:8px; padding:20px;'>")
                    .append("<h2 style='color:#E74C3C;'>💰 BIÊN LAI HOÀN TIỀN - ĐƠN HÀNG</h2>")
                    .append("<p>Xin chào <strong>").append(customerName != null ? customerName : "Khách hàng").append("</strong>,</p>")
                    .append("<p>Chúng tôi xác nhận đã nhận được yêu cầu hủy đơn hàng của bạn.</p>")
                    .append("<hr>")
                    .append("<h3 style='color:#2E8B57;'>📋 Thông tin đơn hàng:</h3>")
                    .append("<p><strong>Mã đơn hàng:</strong> #").append(orderId).append("</p>")
                    .append("<p><strong>Ngày đặt:</strong> ").append(order.getOrderDate() != null ? order.getOrderDate() : "N/A").append("</p>")
                    .append("<p><strong>Phương thức thanh toán:</strong> ").append(order.getPaymentMethod() != null ? order.getPaymentMethod() : "N/A").append("</p>")
                    .append("<p><strong>Trạng thái:</strong> <span style='color:#E74C3C; font-weight:bold;'>Đã hủy - Đã hoàn tiền</span></p>")
                    .append("<hr>")
                    .append("<h3 style='color:#2E8B57;'>🧾 Chi tiết sản phẩm đã hủy:</h3>")
                    .append("<table border='1' cellpadding='10' cellspacing='0' style='border-collapse:collapse; width:100%;'>")
                    .append("<thead style='background-color:#f2f2f2;'>")
                    .append("<tr><th>Tên sản phẩm</th><th>Số lượng</th><th>Đơn giá</th><th>Thành tiền</th></tr>")
                    .append("</thead><tbody>");

            for (OrderDetail detail : orderDetails) {
                String productName = productDAO.getProductNameById(detail.getProductId());
                double itemTotal = detail.getUnitPrice() * detail.getQuantity();
                
                content.append("<tr>")
                        .append("<td>").append(productName != null ? productName : "Sản phẩm #" + detail.getProductId()).append("</td>")
                        .append("<td>").append(detail.getQuantity()).append("</td>")
                        .append("<td>").append(String.format("%.0f", detail.getUnitPrice())).append(" ₫</td>")
                        .append("<td><strong>").append(String.format("%.0f", itemTotal)).append(" ₫</strong></td>")
                        .append("</tr>");
            }

            content.append("</tbody></table>")
                    .append("<p style='margin-top:16px; font-size:18px; text-align:right;'><strong style='color:#E74C3C;'>💰 Tổng tiền hoàn lại: ")
                    .append(String.format("%.0f", totalAmount)).append(" ₫</strong></p>")
                    .append("<hr>")
                    .append("<p style='background-color:#D4EDDA; padding:15px; border-left:4px solid #28A745; border-radius:4px;'>")
                    .append("<strong>✅ Thông tin hoàn tiền:</strong><br>")
                    .append("• Đơn hàng đã được hủy thành công.<br>")
                    .append("• Tiền hoàn lại sẽ được chuyển về tài khoản của bạn trong vòng 3-5 ngày làm việc.<br>")
                    .append("• Nếu bạn có thắc mắc, vui lòng liên hệ hotline: <strong>0912 345 678</strong>")
                    .append("</p>")
                    .append("<hr>")
                    .append("<p style='color:gray; font-size:13px;'>Cảm ơn bạn đã sử dụng dịch vụ của chúng tôi!</p>")
                    .append("</div>");

            // Gửi email
            System.out.println("📧 Đang tạo message email...");
            Message message = new MimeMessage(getMailSession());
            message.setFrom(new InternetAddress(SENDER_EMAIL, "Pets4Care", "UTF-8"));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(recipientEmail));
            String subject = MimeUtility.encodeText("💰 Biên lai hoàn tiền - Đơn hàng #" + orderId, "UTF-8", "B");
            message.setSubject(subject);
            message.setContent(content.toString(), "text/html; charset=UTF-8");

            System.out.println("📧 Đang gửi email qua SMTP...");
            System.out.println("📧 SMTP Host: " + SMTP_HOST);
            System.out.println("📧 SMTP Port: " + SMTP_PORT);
            System.out.println("📧 From: " + SENDER_EMAIL);
            System.out.println("📧 To: " + recipientEmail);
            
            Transport.send(message);
            System.out.println("✅ Đã gửi email biên lai hoàn tiền đơn hàng đến: " + recipientEmail);
            System.out.println("📧 ===== KẾT THÚC GỬI EMAIL HOÀN TIỀN ĐƠN HÀNG =====");

        } catch (MessagingException e) {
            String errorMsg = e.getMessage() != null ? e.getMessage() : "";
            System.err.println("❌ Lỗi MessagingException khi gửi email biên lai hoàn tiền đơn hàng:");
            System.err.println("   - Message: " + errorMsg);
            System.err.println("   - Cause: " + (e.getCause() != null ? e.getCause().getMessage() : "N/A"));
            
            // Kiểm tra nếu là lỗi Gmail limit
            if (errorMsg.contains("Daily user sending limit exceeded") || 
                errorMsg.contains("550-5.4.5")) {
                System.err.println("⚠️ ===== GMAIL ĐÃ ĐẠT GIỚI HẠN GỬI EMAIL ===== ");
                System.err.println("⚠️ Email không thể gửi do Gmail đã đạt giới hạn gửi trong ngày.");
                System.err.println("⚠️ Giới hạn Gmail: 500 email/ngày cho tài khoản miễn phí, 2000 email/ngày cho Google Workspace");
                System.err.println("⚠️ Giải pháp:");
                System.err.println("   1. Đợi đến ngày mai (giới hạn reset mỗi ngày)");
                System.err.println("   2. Sử dụng dịch vụ email khác (SendGrid, Mailgun, AWS SES)");
                System.err.println("   3. Nâng cấp lên Google Workspace");
                System.err.println("⚠️ ============================================");
                
                // Throw RuntimeException để caller biết và có thể xử lý (không cần declare throws)
                throw new RuntimeException("Gmail daily sending limit exceeded", e);
            }
            e.printStackTrace();
            // Wrap trong RuntimeException để không cần declare throws
            throw new RuntimeException("Email sending failed", e);
        } catch (RuntimeException e) {
            // Re-throw RuntimeException (bao gồm các exception đã wrap)
            throw e;
        } catch (Exception e) {
            System.err.println("❌ Lỗi Exception khi gửi email biên lai hoàn tiền đơn hàng:");
            System.err.println("   - Message: " + e.getMessage());
            System.err.println("   - Type: " + e.getClass().getName());
            e.printStackTrace();
            // Wrap trong RuntimeException để không cần declare throws
            throw new RuntimeException("Email sending failed", e);
        }
    }
}
