package controller;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import jakarta.servlet.ServletException;
import utils.DBConnection;
import utils.EmailUtils;
import dao.OrderDAO;
import dao.CustomerDAO;
import service.PayOSService;
import model.Order;
import model.OrderDetail;
import model.Customer;

import java.io.IOException;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.List;

@WebServlet("/cancelorder")
public class CancelOrderServlet extends HttpServlet {

    private final PayOSService payOSService = new PayOSService();
    private final OrderDAO orderDAO = new OrderDAO();
    private final CustomerDAO customerDAO = new CustomerDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String orderIdRaw = request.getParameter("id");
        if (orderIdRaw == null) {
            response.sendRedirect("order/order-history.jsp");
            return;
        }

        int orderId = Integer.parseInt(orderIdRaw);

        try (Connection con = DBConnection.getConnection()) {
            // Lấy thông tin đơn hàng
            System.out.println("🔍 ===== BẮT ĐẦU HỦY ĐƠN HÀNG #" + orderId + " =====");
            Order order = orderDAO.getOrderById(orderId);
            if (order == null) {
                System.err.println("❌ Không tìm thấy đơn hàng #" + orderId);
                response.sendRedirect("order/order-history.jsp?msg=order_not_found");
                return;
            }

            // Log thông tin đơn hàng
            String orderStatus = order.getStatus() != null ? order.getStatus() : "";
            String paymentStatus = order.getPaymentStatus() != null ? order.getPaymentStatus() : "";
            String paymentMethod = order.getPaymentMethod() != null ? order.getPaymentMethod() : "";
            
            System.out.println("📋 Thông tin đơn hàng #" + orderId + ":");
            System.out.println("   - Status: " + orderStatus);
            System.out.println("   - Payment Status: " + paymentStatus);
            System.out.println("   - Payment Method: " + paymentMethod);
            System.out.println("   - Paid At: " + (order.getPaidAt() != null ? order.getPaidAt() : "NULL"));
            System.out.println("   - Total Amount: " + order.getTotalAmount());

            // Kiểm tra nếu đơn hàng đã thanh toán bằng PayOS
            boolean isPayOSPaid = "PayOS".equalsIgnoreCase(paymentMethod) 
                                && ("Đã thanh toán".equals(paymentStatus) 
                                    || "paid".equalsIgnoreCase(paymentStatus)
                                    || "PAID".equalsIgnoreCase(paymentStatus));

            // Kiểm tra nếu đơn hàng đã thanh toán (bất kỳ phương thức nào)
            // Bao gồm các trường hợp: payment_status đã thanh toán, có paid_at, hoặc status cho thấy đã thanh toán
            boolean isPaid = "Đã thanh toán".equals(paymentStatus) 
                          || "paid".equalsIgnoreCase(paymentStatus)
                          || "PAID".equalsIgnoreCase(paymentStatus)
                          || order.getPaidAt() != null
                          // Nếu status là các trạng thái cho thấy đã thanh toán
                          || "Chờ giao hàng".equals(orderStatus)
                          || "Hoàn tất".equals(orderStatus)
                          || "Đã hoàn tất".equals(orderStatus);
            
            System.out.println("🔍 Kiểm tra điều kiện:");
            System.out.println("   - isPayOSPaid: " + isPayOSPaid);
            System.out.println("   - isPaid: " + isPaid);

            if (isPayOSPaid) {
                System.out.println("💰 Đơn hàng #" + orderId + " đã thanh toán bằng PayOS, tiến hành hoàn tiền...");
                
                try {
                    // Lấy payos_order_code từ bảng Payment
                    Integer payosOrderCode = null;
                    try (PreparedStatement ps = con.prepareStatement(
                            "SELECT payos_order_code FROM dbo.Payment " +
                            "WHERE payment_type = 'order' AND reference_id = ? AND payment_status = 'paid' " +
                            "ORDER BY created_at DESC")) {
                        ps.setInt(1, orderId);
                        try (ResultSet rs = ps.executeQuery()) {
                            if (rs.next()) {
                                payosOrderCode = rs.getObject("payos_order_code") != null 
                                    ? rs.getInt("payos_order_code") 
                                    : null;
                            }
                        }
                    }

                    if (payosOrderCode != null && payosOrderCode > 0) {
                        // Gọi PayOS refund - amount đã là VND trong database
                        int amountVnd = (int) Math.round(order.getTotalAmount());
                        String reason = "Hủy đơn hàng #" + orderId;
                        
                        System.out.println("🔄 Đang hoàn tiền qua PayOS - orderCode: " + payosOrderCode + ", amount: " + amountVnd);
                        boolean refundSuccess = payOSService.refundPayment(payosOrderCode, amountVnd, reason, "order");
                        
                        if (refundSuccess) {
                            System.out.println("✅ Hoàn tiền PayOS thành công cho đơn hàng #" + orderId);
                        } else {
                            System.err.println("⚠️ Hoàn tiền PayOS thất bại, nhưng vẫn tiếp tục hủy đơn hàng");
                        }
                    } else {
                        System.err.println("⚠️ Không tìm thấy payos_order_code cho đơn hàng #" + orderId);
                    }
                } catch (Exception e) {
                    System.err.println("⚠️ Lỗi khi xử lý hoàn tiền PayOS, nhưng vẫn tiếp tục hủy đơn hàng: " + e.getMessage());
                    e.printStackTrace();
                }
            }

            // Gửi email hóa đơn hoàn tiền cho TẤT CẢ các đơn hàng đã thanh toán (không chỉ PayOS)
            // Bao gồm cả đơn hàng đang giao/chờ giao
            if (isPaid) {
                System.out.println("📧 ===== BẮT ĐẦU GỬI EMAIL HOÀN TIỀN =====");
                System.out.println("📧 Đơn hàng #" + orderId + " đã thanh toán (status: " + orderStatus + ", payment_status: " + paymentStatus + "), sẽ gửi email hóa đơn hoàn tiền...");
                
                try {
                    // Lấy thông tin customer và order details để gửi email
                    System.out.println("📧 Đang lấy thông tin customer (customer_id: " + order.getCustomerId() + ")...");
                    Customer customer = customerDAO.getCustomerById(order.getCustomerId());
                    System.out.println("📧 Đang lấy order details...");
                    List<OrderDetail> orderDetails = orderDAO.getOrderDetailsByOrderId(orderId);
                    System.out.println("📧 Số lượng order details: " + (orderDetails != null ? orderDetails.size() : 0));

                    // Gửi email hóa đơn hoàn tiền
                    if (customer != null && customer.getEmail() != null && !customer.getEmail().trim().isEmpty()) {
                        System.out.println("📧 Customer tìm thấy:");
                        System.out.println("   - Name: " + customer.getName());
                        System.out.println("   - Email: " + customer.getEmail());
                        System.out.println("📧 Đang gọi EmailUtils.sendOrderRefundInvoice()...");
                        try {
                            EmailUtils.sendOrderRefundInvoice(
                                customer.getEmail(),
                                customer.getName(),
                                orderId,
                                order,
                                orderDetails,
                                order.getTotalAmount()
                            );
                            System.out.println("✅ Đã gửi email hóa đơn hoàn tiền đến: " + customer.getEmail());
                        } catch (Exception emailEx) {
                            // Nếu lỗi do giới hạn Gmail, vẫn log nhưng không throw
                            System.err.println("❌ EXCEPTION khi gửi email:");
                            System.err.println("   - Type: " + emailEx.getClass().getName());
                            System.err.println("   - Message: " + emailEx.getMessage());
                            
                            String errorMsg = emailEx.getMessage() != null ? emailEx.getMessage() : "";
                            if (errorMsg.contains("Daily user sending limit exceeded") || 
                                errorMsg.contains("Gmail daily sending limit") ||
                                errorMsg.contains("550-5.4.5")) {
                                System.err.println("");
                                System.err.println("⚠️ ================================================");
                                System.err.println("⚠️ EMAIL KHÔNG THỂ GỬI - GMAIL ĐẠT GIỚI HẠN");
                                System.err.println("⚠️ ================================================");
                                System.err.println("⚠️ Gmail tài khoản 'th9312242@gmail.com' đã đạt giới hạn gửi trong ngày.");
                                System.err.println("⚠️ Đơn hàng #" + orderId + " vẫn được hủy thành công.");
                                System.err.println("");
                                System.err.println("📧 Thông tin email cần gửi:");
                                System.err.println("   - Khách hàng: " + customer.getName());
                                System.err.println("   - Email: " + customer.getEmail());
                                System.err.println("   - Mã đơn hàng: #" + orderId);
                                System.err.println("   - Tổng tiền: " + order.getTotalAmount() + " VND");
                                System.err.println("");
                                System.err.println("💡 Giải pháp:");
                                System.err.println("   1. Đợi đến ngày mai (giới hạn reset mỗi ngày lúc 0h UTC)");
                                System.err.println("   2. Gửi email thủ công từ tài khoản Gmail khác");
                                System.err.println("   3. Cấu hình dịch vụ email khác (SendGrid, Mailgun, AWS SES)");
                                System.err.println("⚠️ ================================================");
                                System.err.println("");
                            } else {
                                System.err.println("❌ Lỗi gửi email hoàn tiền: " + emailEx.getMessage());
                                emailEx.printStackTrace();
                            }
                        }
                    } else {
                        System.err.println("⚠️ Không có email customer để gửi hóa đơn hoàn tiền");
                        if (customer == null) {
                            System.err.println("   - Customer không tồn tại với customer_id: " + order.getCustomerId());
                        } else {
                            System.err.println("   - Customer tồn tại nhưng email: " + (customer.getEmail() != null ? customer.getEmail() : "NULL"));
                        }
                    }
                    System.out.println("📧 ===== KẾT THÚC GỬI EMAIL HOÀN TIỀN =====");
                } catch (Exception e) {
                    System.err.println("❌ Lỗi khi lấy thông tin để gửi email hoàn tiền: " + e.getMessage());
                    e.printStackTrace();
                    // Không throw exception, vẫn tiếp tục hủy đơn hàng
                }
            } else {
                System.out.println("ℹ️ Đơn hàng #" + orderId + " chưa thanh toán (status: " + orderStatus + ", payment_status: " + paymentStatus + "), không cần gửi email hoàn tiền");
                System.out.println("   - Kiểm tra: payment_status='Đã thanh toán'? " + "Đã thanh toán".equals(paymentStatus));
                System.out.println("   - Kiểm tra: payment_status='paid'? " + "paid".equalsIgnoreCase(paymentStatus));
                System.out.println("   - Kiểm tra: paid_at != null? " + (order.getPaidAt() != null));
                System.out.println("   - Kiểm tra: status='Chờ giao hàng'? " + "Chờ giao hàng".equals(orderStatus));
                System.out.println("   - Kiểm tra: status='Hoàn tất'? " + "Hoàn tất".equals(orderStatus));
            }

            // Cập nhật status thành "Đã hủy" (stored procedure CancelOrder)
            // Đảm bảo luôn thực hiện bước này dù có lỗi ở trên
            try {
                CallableStatement cs = con.prepareCall("{call CancelOrder(?)}");
                cs.setInt(1, orderId);
                cs.execute();
                System.out.println("✅ Đã hủy đơn hàng #" + orderId);
            } catch (Exception e) {
                System.err.println("❌ Lỗi khi gọi stored procedure CancelOrder: " + e.getMessage());
                e.printStackTrace();
                // Thử cập nhật trực tiếp nếu stored procedure lỗi
                try (PreparedStatement ps = con.prepareStatement(
                        "UPDATE [Order] SET status = N'Đã hủy', payment_status = 'REFUNDED' WHERE order_id = ?")) {
                    ps.setInt(1, orderId);
                    int rows = ps.executeUpdate();
                    if (rows > 0) {
                        System.out.println("✅ Đã cập nhật trực tiếp status thành 'Đã hủy' cho đơn hàng #" + orderId);
                    } else {
                        throw new Exception("Không thể cập nhật status đơn hàng");
                    }
                }
            }

        } catch (Exception e) {
            System.err.println("❌ Lỗi khi hủy đơn hàng: " + e.getMessage());
            e.printStackTrace();
        }

        response.sendRedirect("order/order-history.jsp?msg=cancel_success");
    }
}
