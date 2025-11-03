<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <title>Hoàn tiền - Pets4Care</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 24px; }
        .container { max-width: 760px; margin: 0 auto; }
        h1 { margin-bottom: 8px; }
        .card { border:1px solid #e5e7eb; border-radius:8px; padding:16px; margin:16px 0; }
        label { display:block; margin:8px 0 4px; font-weight:600; }
        input[type="text"], input[type="number"], textarea { width:100%; padding:10px; border:1px solid #d1d5db; border-radius:6px; }
        textarea { min-height: 80px; }
        .row { display:flex; gap:12px; }
        .row > div { flex:1; }
        .btn { background:#10b981; color:#fff; border:none; padding:10px 16px; border-radius:6px; cursor:pointer; }
        .btn:hover { background:#0ea371; }
        code, pre { background:#f3f4f6; padding:8px; border-radius:6px; display:block; overflow:auto; }
        .muted { color:#6b7280; font-size: 13px; }
        ul { margin: 8px 0 8px 18px; }
    </style>
</head>
<body>
<div class="container">
    <h1>Hoàn tiền (Refund)</h1>
    <p class="muted">Trang tiện ích dùng để test nhanh chức năng hoàn tiền cho Spa Booking và tham khảo hướng dẫn tích hợp.</p>

    <div class="card">
        <h3>Form hoàn tiền Spa Booking</h3>
        <form method="post" action="<%= request.getContextPath() %>/spa-booking?action=refund-spa-booking">
            <div class="row">
                <div>
                    <label for="bookingId">Booking ID (định danh spa)</label>
                    <input id="bookingId" name="bookingId" type="text" placeholder="VD: 12" required />
                </div>
                <div>
                    <label for="amount">Số tiền hoàn</label>
                    <input id="amount" name="amount" type="number" step="1000" min="1" placeholder="VD: 150000" required />
                </div>
            </div>
            <label for="reason">Lý do</label>
            <textarea id="reason" name="reason" placeholder="VD: Khách hủy dịch vụ"></textarea>
            <br/>
            <button class="btn" type="submit">Hoàn tiền</button>
        </form>
        <p class="muted">Luồng này ghi 1 dòng vào bảng <b>dbo.Refunds</b> với <b>order_id = "SPA_&lt;bookingId&gt;"</b> và cập nhật <b>dbo.Booking.status = 'đã hoàn tiền'</b>.</p>
    </div>

    <div class="card">
        <h3>API hoàn tiền nội bộ (đang dùng)</h3>
        <p>Gọi API để ghi Refund vào DB (không gọi PayOS):</p>
        <pre>POST <%= request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + request.getContextPath() %>/api/refund
Content-Type: application/json
{
  "orderId": "BK0001",
  "amount": 150000,
  "reason": "Khách hủy dịch vụ"
}</pre>
        <p class="muted">Trường hợp này endpoint sẽ insert trực tiếp vào <b>dbo.Refunds</b>.</p>
    </div>

    <div class="card">
        <h3>API hoàn tiền qua PayOS (sẵn sàng tích hợp)</h3>
        <p>Ngay khi PayOS cung cấp endpoint refund chính thức, chỉ cần cấu hình <code>payos.refund.endpoint</code> và gọi theo <code>orderCode</code>:</p>
        <pre>POST <%= request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + request.getContextPath() %>/api/refund
Content-Type: application/json
{
  "orderCode": 785176542,
  "amount": 150000,
  "reason": "Khách hủy dịch vụ"
}</pre>
        <ul>
            <li>Sử dụng base URL: <code>https://api.payos.vn/v2</code> (hoặc domain theo tài khoản)</li>
            <li>Cấu hình khóa trong <code>utils/PayOSConfig.java</code> bằng biến môi trường để bảo mật</li>
            <li>Kiểm tra <code>orderCode</code> là mã PayOS thật của đơn đã thanh toán</li>
        </ul>
    </div>

    <div class="card">
        <h3>Hướng dẫn tích hợp trong mục đặt dịch vụ (SpaBooking)</h3>
        <ol>
            <li>Thêm nút "Hoàn tiền" tại trang lịch sử/chi tiết booking.</li>
            <li>Nút gửi form POST tới <code>/spa-booking?action=refund-spa-booking</code> với <code>bookingId</code>, <code>amount</code>, <code>reason</code>.</li>
            <li>Servlet <code>SpaBookingServlet</code> đã có action <code>refund-spa-booking</code> để ghi <code>dbo.Refunds</code> và cập nhật <code>dbo.Booking.status</code>.</li>
            <li>Nếu hoàn tiền qua PayOS: lưu <code>orderCode</code> khi tạo thanh toán, sau đó gọi <code>/api/refund</code> với <code>orderCode</code>.</li>
        </ol>
        <p class="muted">Mẹo: nên log cả người thao tác, nguồn yêu cầu, và hiển thị xác nhận trước khi hoàn tiền.</p>
    </div>
</div>
</body>
</html>
