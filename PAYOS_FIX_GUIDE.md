# 🔧 Hướng dẫn sửa lỗi PayOS Webhook

## 🚨 Vấn đề đã phát hiện:

1. **Lỗi trong `PayOSUtils.verifyWebhookSignature()`**: Method luôn return `false`
2. **Lỗi xử lý webhook**: Không có logging chi tiết để debug
3. **Lỗi dependencies**: Một số import không được nhận diện

## ✅ Các sửa đổi đã thực hiện:

### 1. Sửa `PayOSUtils.verifyWebhookSignature()`
- ✅ Implement đúng logic xác thực signature PayOS
- ✅ Sử dụng HMAC-SHA256 với checksum key
- ✅ Thêm logging chi tiết để debug

### 2. Cải thiện `PayOSWebhookServlet`
- ✅ Thêm logging chi tiết
- ✅ Xử lý trường hợp không có signature (cho test)
- ✅ Error handling tốt hơn

### 3. Cải thiện `PayOSService.handleWebhook()`
- ✅ Thêm validation dữ liệu webhook
- ✅ Kiểm tra order tồn tại trước khi update
- ✅ Logging chi tiết cho từng bước
- ✅ Return đúng giá trị cho các trường hợp khác nhau

### 4. Tạo Test Tools
- ✅ `TestWebhookServlet`: Servlet test đơn giản không cần dependencies
- ✅ `test-webhook-simple.html`: Trang test webhook
- ✅ Mapping servlet trong `web.xml`

## 🧪 Cách test:

### Bước 1: Build và Deploy
```bash
# Build project
ant clean build

# Deploy to Tomcat
ant deploy
```

### Bước 2: Test Webhook
1. Mở: `https://your-ngrok-url/Pets4Care/test-webhook-simple.html`
2. Click "Test Webhook (Order #14)"
3. Kiểm tra console logs

### Bước 3: Kiểm tra Database
```sql
-- Kiểm tra order 14
SELECT order_id, payment_status, paid_at, status 
FROM [Order] 
WHERE order_id = 14;
```

## 📋 Logs cần kiểm tra:

Khi webhook được gửi, bạn sẽ thấy logs sau trong console:

```
🧪 ===== TEST WEBHOOK SERVLET =====
📝 Webhook data: {"data":{"orderCode":14,"status":"PAID"}}
📦 Order ID: 14
📊 Status: PAID
✅ Processing payment confirmation...
Database update result: 1
✅ Order #14 updated successfully
```

## 🔍 Troubleshooting:

### Nếu webhook không hoạt động:

1. **Kiểm tra ngrok có chạy không:**
   ```bash
   ngrok http 8080
   ```

2. **Kiểm tra URL trong payos.properties:**
   ```
   payos.webhook.url=https://your-ngrok-url/Pets4Care/payos/webhook
   ```

3. **Kiểm tra PayOS Dashboard:**
   - Đăng nhập: https://pay.payos.vn/
   - Vào Webhook settings
   - Đảm bảo URL đúng

4. **Test trực tiếp:**
   ```bash
   curl -X POST https://your-ngrok-url/Pets4Care/test-webhook \
     -H "Content-Type: application/json" \
     -d '{"data":{"orderCode":14,"status":"PAID"}}'
   ```

### Nếu database không update:

1. **Kiểm tra stored procedure:**
   ```sql
   EXEC ConfirmAndPayOrder 
       @p_order_id = 14,
       @p_payment_status = N'Đã thanh toán',
       @p_paid_at = GETDATE();
   ```

2. **Kiểm tra connection string trong DBConnection.java**

## 🎯 Kết quả mong đợi:

Sau khi sửa, khi PayOS gửi webhook:
- ✅ Webhook được nhận và xử lý
- ✅ Signature được verify (nếu có)
- ✅ Order status được update thành "Đã thanh toán"
- ✅ `paid_at` được set thành thời gian hiện tại
- ✅ `status` được update thành "Hoàn tất"

## 📞 Nếu vẫn có lỗi:

1. Kiểm tra console logs chi tiết
2. Test với `TestWebhookServlet` trước
3. Kiểm tra database connection
4. Verify PayOS configuration
