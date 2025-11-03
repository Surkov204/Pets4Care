# 🧪 Hướng dẫn Test Thanh toán PayOS

## 📋 Tổng quan
Project đã được cấu hình để sử dụng PayOS với các thông tin sau:
- **Client ID**: `aa93b610-c20b-4ffa-8c08-d006e01df689`
- **API Key**: `0d00713c-3627-4033-a87e-ba646b371a95`
- **Checksum Key**: `d94677a139bd68e80dc67adf1fd3945db9c43679928823bfdf72f86d70d4ffd2`
- **Webhook URL**: `https://webhook.site/b15f91fa-1b0f-423a-90cf-35c6c0426fe0`

## 🚀 Cách Test Thanh toán PayOS

### 1. Chạy Project
```bash
# Build project
ant clean-and-build

# Deploy to Tomcat
ant deploy
```

### 2. Truy cập Test Page
Mở trình duyệt và truy cập:
- **Servlet Test**: `http://localhost:8080/Pets4Care/test-payos-final`
- **JSP Test**: `http://localhost:8080/Pets4Care/test-payos-final.jsp`

### 3. Test Thanh toán
1. Click vào nút **"🚀 Test Payment"** trên trang test
2. Bạn sẽ được chuyển đến trang thanh toán PayOS
3. Sử dụng thông tin test:
   - **Số thẻ**: `4111111111111111`
   - **Ngày hết hạn**: `12/25`
   - **CVV**: `123`
   - **Tên chủ thẻ**: `NGUYEN VAN A`

### 4. Kiểm tra Webhook
- Mở tab mới và truy cập: `https://webhook.site/b15f91fa-1b0f-423a-90cf-35c6c0426fe0`
- Sau khi thanh toán thành công, bạn sẽ thấy webhook notification từ PayOS

### 5. Kiểm tra Database
Kiểm tra bảng `[Order]` để xem trạng thái thanh toán đã được cập nhật chưa:
```sql
SELECT order_id, payment_status, status, order_date 
FROM [Order] 
WHERE order_id = 999;
```

## 🔧 Các URL Test Khác

### Test PayOS Controller trực tiếp
```
http://localhost:8080/Pets4Care/payos/create-payment?orderId=999
```

### Test Webhook
```
http://localhost:8080/Pets4Care/payos/webhook
```

### Test Return URL
```
http://localhost:8080/Pets4Care/payos/return?orderId=999
```

### Test Cancel URL
```
http://localhost:8080/Pets4Care/payos/cancel?orderId=999
```

## 🐛 Troubleshooting

### Lỗi thường gặp:

1. **"Payment URL is NULL"**
   - Kiểm tra PayOS credentials
   - Kiểm tra network connection
   - Xem logs trong console

2. **"Invalid signature"**
   - Kiểm tra checksum key
   - Kiểm tra format của dữ liệu gửi đi

3. **"Webhook not received"**
   - Kiểm tra webhook URL
   - Kiểm tra firewall/network
   - Test webhook endpoint trực tiếp

### Debug Information
Trên trang test, bạn sẽ thấy:
- PayOS Configuration
- Signature Generation Test
- API Request/Response
- Error messages (nếu có)

## 📝 Lưu ý quan trọng

1. **Webhook URL**: Hiện tại đang sử dụng webhook.site để test. Trong production, cần thay bằng URL thực của server.

2. **Return/Cancel URLs**: Cần cập nhật thành URL thực của server khi deploy production.

3. **Order ID**: Test sử dụng order ID = 999. Đảm bảo order này tồn tại trong database.

4. **Amount**: Test sử dụng 50,000 VND. Có thể thay đổi trong code test.

## 🎯 Kết quả mong đợi

Khi test thành công, bạn sẽ thấy:
1. ✅ Payment URL được tạo thành công
2. ✅ Chuyển hướng đến trang thanh toán PayOS
3. ✅ Thanh toán thành công
4. ✅ Webhook notification được gửi đến webhook.site
5. ✅ Trạng thái đơn hàng được cập nhật trong database

## 📞 Hỗ trợ

Nếu gặp vấn đề, hãy kiểm tra:
1. Logs trong console
2. Network tab trong Developer Tools
3. Webhook.site để xem webhook data
4. Database để kiểm tra trạng thái đơn hàng


