# 🎉 Hướng dẫn hoàn chỉnh PayOS cho Pets4Care

## ✅ Trạng thái hiện tại

### ✅ Đã hoàn thành:
1. ✅ Cấu hình PayOS credentials
2. ✅ Signature generation theo đúng format PayOS
3. ✅ Tạo payment link thành công
4. ✅ Redirect đến trang thanh toán PayOS
5. ✅ Xử lý webhook từ PayOS
6. ✅ Cập nhật trạng thái đơn hàng trong database

### 📋 Test Pages:
- **Test Payment**: `http://localhost:8080/Pets4Care/test-payos.jsp`
- **Test Webhook**: `http://localhost:8080/Pets4Care/test-webhook.jsp`
- **Monitor Webhook**: `https://webhook.site/b15f91fa-1b0f-423a-90cf-35c6c0426fe0`

## 🚀 Cách sử dụng PayOS thanh toán

### 1. Trong Production:

#### Bước 1: Cấu hình Webhook URL
Trong PayOS Dashboard, cấu hình webhook URL thành:
```
https://your-domain.com/Pets4Care/payos/webhook
```

**HOẶC** sử dụng ngrok để test:
```
https://recent-giada-aimfully.ngrok-free.dev/Pets4Care/payos/webhook
```

#### Bước 2: Sử dụng trong code
```jsp
<a href="<%= request.getContextPath() %>/payos/create-payment?orderId=YOUR_ORDER_ID">
    Thanh toán với PayOS
</a>
```

### 2. Flow thanh toán:

1. **User click "Thanh toán với PayOS"**
   - → `PayOSController.handleCreatePayment()`
   - → `PayOSService.createPaymentLink()`
   - → Tạo signature theo format PayOS
   - → Gọi PayOS API
   - → Redirect đến PayOS payment page

2. **User thanh toán trên PayOS**
   - → Quét QR code hoặc chuyển khoản
   - → PayOS xác nhận thanh toán

3. **PayOS gửi Webhook**
   - → `PayOSWebhookServlet.doPost()`
   - → Verify signature
   - → `PayOSService.handleWebhook()`
   - → Cập nhật trạng thái đơn hàng

4. **User return**
   - → `PayOSController.handlePaymentReturn()`
   - → Kiểm tra trạng thái thanh toán
   - → Redirect đến trang success

## 🔧 Cấu hình quan trọng

### File: `src/payos.properties`
```properties
payos.client.id=aa93b610-c20b-4ffa-8c08-d006e01df689
payos.api.key=0d00713c-3627-4033-a87e-ba646b371a95
payos.checksum.key=d94677a139bd68e80dc67adf1fd3945db9c43679928823bfdf72f86d70d4ffd2
payos.base.url=https://api-merchant.payos.vn/v2
payos.webhook.url=https://webhook.site/b15f91fa-1b0f-423a-90cf-35c6c0426fe0
```

### File: `src/java/utils/PayOSConfig.java`
- Hardcode các credentials cho easy access
- Tự động load khi application start

## 📝 Lưu ý quan trọng

### 1. Description
- PayOS chỉ cho phép tối đa **25 ký tự**
- Đã được xử lý trong code: `"Order #" + orderId`

### 2. Signature Format
```java
// Format: key1=value1&key2=value2... (sắp xếp theo alphabet)
// Ví dụ: amount=15740&cancelUrl=...&description=...&orderCode=13&returnUrl=...
// Ký bằng HMAC-SHA256 với checksum key
// Encode kết quả sang HEX
```

### 3. Webhook
- Webhook hiện đang dùng webhook.site để test
- Trong production, cần thay bằng URL thực của server
- Webhook được gửi đến `/payos/webhook`
- Servet: `PayOSWebhookServlet`

### 4. Response Codes
- `code: "00"` → Success
- `code: "231"` → Order đã tồn tại
- `code: "201"` → Signature không hợp lệ
- `code: "20"` → Description quá dài

## 🎯 Test Checklist

- [x] Cấu hình PayOS credentials
- [x] Signature generation
- [x] Tạo payment link
- [x] Redirect đến PayOS
- [x] Nhận webhook từ PayOS
- [x] Verify signature
- [x] Cập nhật database
- [ ] Test với order mới (thực tế)
- [ ] Test webhook trong production

## 🎊 Kết luận

PayOS đã được tích hợp thành công vào project Pets4Care!

- ✅ Signature generation hoạt động đúng
- ✅ Payment link được tạo thành công  
- ✅ Webhook handling đã sẵn sàng
- ✅ Database update đã được cấu hình

Bây giờ bạn có thể sử dụng PayOS để thanh toán trong project!


