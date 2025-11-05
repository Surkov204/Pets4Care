# 🔍 Hướng dẫn test PayOS Webhook

## Vấn đề phát hiện từ database:

Các orders PayOS (order_id 10-16) có:
- ✅ `payment_method = "PayOS"` → OK
- ❌ `payment_status = "Chưa tha..."` → CHƯA thanh toán
- ❌ `paid_at = NULL` → CHƯA có thời gian thanh toán
- ⚠️ `status = "Đang xử lý"` → Chưa được update

➡️ **NGUYÊN NHÂN: Webhook từ PayOS KHÔNG được xử lý hoặc KHÔNG đến được server**

---

## 🔧 Cách kiểm tra và sửa:

### Bước 1: Kiểm tra Webhook URL trong PayOS Dashboard

1. Đăng nhập PayOS Dashboard: https://pay.payos.vn/
2. Chọn dự án của bạn
3. Vào **Webhook** → **Webhook URL**
4. Kiểm tra URL có đúng không:
   ```
   https://your-ngrok-url/Pets4Care/payos/webhook
   ```

### Bước 2: Kiểm tra ngrok có đang chạy không

```bash
# Kiểm tra ngrok đang chạy
# URL phải giống với trong payos.properties
```

### Bước 3: Test Webhook bằng Postman (hoặc curl)

Gửi test webhook:

```bash
curl -X POST https://your-ngrok-url/Pets4Care/payos/webhook \
  -H "Content-Type: application/json" \
  -H "x-payos-signature: your-signature" \
  -d '{
    "data": {
      "orderCode": 14,
      "status": "PAID"
    }
  }'
```

### Bước 4: Kiểm tra Tomcat Logs

Xem console có log:
```
📨 ===== PAYOS WEBHOOK RECEIVED =====
📦 Order Code: 14
📊 Status: PAID
✅ Payment confirmed, updating order status...
✅ Order #14 updated to 'Đã thanh toán'
```

---

## 🚨 Nếu webhook không đến:

### Option 1: PayOS chưa được config webhook
- Vào PayOS Dashboard
- Thêm/Update webhook URL
- Test webhook từ dashboard

### Option 2: ngrok URL đã thay đổi
- Khi restart ngrok, URL mới
- Update lại trong PayOS Dashboard
- Update lại trong `src/payos.properties`

### Option 3: Manually update order (tạm thời để test)

Chạy SQL để manually test:

```sql
-- Update order 14 manually
EXEC ConfirmAndPayOrder 
    @p_order_id = 14,
    @p_payment_status = N'Đã thanh toán',
    @p_paid_at = GETDATE();

-- Check lại
SELECT order_id, payment_status, paid_at, status 
FROM [Order] 
WHERE order_id = 14;
```

---

## 📝 Checklist:

- [ ] ngrok đang chạy
- [ ] ngrok URL match với payos.properties
- [ ] PayOS Dashboard có config webhook URL đúng
- [ ] Test webhook từ PayOS Dashboard → Kiểm tra log
- [ ] Rebuild và restart Tomcat
- [ ] Test lại thanh toán PayOS
- [ ] Kiểm tra logs để xem webhook có đến không

---

## 🔍 Xem logs chi tiết:

Trong PayOSService.java đã có logging, khi webhook đến sẽ thấy:

```java
System.out.println("📨 ===== PAYOS WEBHOOK RECEIVED =====");
System.out.println("Webhook data: " + webhookData);
System.out.println("📦 Order Code: " + orderCode);
System.out.println("📊 Status: " + status);
System.out.println("✅ Payment confirmed, updating order status...");
System.out.println("Updating payment status for order #" + orderId);
System.out.println("Stored procedure executed. Rows affected: " + result);
```

**Nếu KHÔNG thấy logs này** → Webhook KHÔNG đến được server!

