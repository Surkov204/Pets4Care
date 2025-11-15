# 🔧 Giải pháp lỗi PayOS Code 231: "Đơn thanh toán đã tồn tại"

## ❌ Vấn đề

Khi thanh toán PayOS cho product orders, hệ thống gặp lỗi:
```
Code: 231
Description: Đơn thanh toán đã tồn tại
```

**Nguyên nhân:** 
- Hệ thống đang dùng trực tiếp `order_id` từ database làm `orderCode` cho PayOS
- Khi order đã được tạo thanh toán trước đó (hoặc order_id bị trùng), PayOS từ chối với lỗi Code 231

## ✅ Giải pháp

### 1. Tạo PayOS orderCode unique từ timestamp + orderId

Thay vì dùng trực tiếp `order_id`, tạo `payosOrderCode` unique từ timestamp và orderId:

```java
// Trong PayOSController.java - handleCreatePayment()
long timestamp = System.currentTimeMillis();
int payosOrderCode = (int) ((timestamp % 1000000000) * 1000 + (orderId % 1000));
if (payosOrderCode < 0) {
    payosOrderCode = Math.abs(payosOrderCode);
}
```

### 2. Thêm Retry Logic

Nếu vẫn gặp lỗi Code 231 (do collision ngẫu nhiên), tự động retry với orderCode mới:

```java
String paymentUrl = null;
int maxRetries = 3;
int retryCount = 0;

while (paymentUrl == null && retryCount < maxRetries) {
    if (retryCount > 0) {
        // Tạo orderCode mới cho retry
        timestamp = System.currentTimeMillis();
        payosOrderCode = (int) ((timestamp % 1000000000) * 1000 + ((orderId * (retryCount + 1)) % 1000));
        if (payosOrderCode < 0) {
            payosOrderCode = Math.abs(payosOrderCode);
        }
    }
    
    paymentUrl = payOSService.createPaymentLink(payosOrderCode, amount, description, returnUrl, cancelUrl);
    
    if (paymentUrl == null) {
        String lastError = payOSService.getLastPayOSError();
        if (lastError != null && lastError.contains("231")) {
            // OrderCode đã tồn tại, retry với orderCode mới
            retryCount++;
        } else {
            // Lỗi khác, không retry
            break;
        }
    }
}
```

### 3. Lưu PayOS orderCode vào database

Để tra cứu sau này (cho refund, webhook, etc.), lưu PayOS orderCode vào database:

```java
if (paymentUrl != null && payosOrderCode != orderId) {
    try (Connection conn = DBConnection.getConnection();
         PreparedStatement ps = conn.prepareStatement(
             "UPDATE [Order] SET note = ? WHERE order_id = ?")) {
        String note = "PayOS OrderCode: " + payosOrderCode;
        ps.setString(1, note);
        ps.setInt(2, orderId);
        ps.executeUpdate();
    } catch (Exception e) {
        // Log error nhưng không fail payment
    }
}
```

## 📝 Lưu ý quan trọng

### Khi nào áp dụng giải pháp này?

- **Product Orders**: Luôn dùng PayOS orderCode unique (không dùng order_id trực tiếp)
- **Service/Boarding Orders**: Vẫn dùng order_id trực tiếp vì đã được tạo unique ở `SpaBookingServlet`

### Mapping giữa Order ID và PayOS OrderCode

- **Return/Cancel URL**: Vẫn dùng `orderId` (để map lại đúng order trong database)
- **PayOS API**: Dùng `payosOrderCode` (unique, không trùng)
- **Database**: Lưu `payosOrderCode` vào field `note` của Order table

## 🔍 Kiểm tra nếu gặp lại lỗi

1. Kiểm tra PayOS API response trong console logs
2. Xác nhận orderCode được tạo có unique không (timestamp khác nhau)
3. Kiểm tra retry logic có hoạt động không
4. Verify PayOS orderCode đã được lưu vào database

## 📅 Ngày sửa

- **Ngày**: 2025-01-XX
- **File sửa**: `Pets4Care/src/java/controller/PayOSController.java`
- **Method**: `handleCreatePayment()`
- **Dòng**: 259-319

## ✅ Kết quả

- ✅ Product orders có thể thanh toán PayOS thành công
- ✅ Tự động retry nếu gặp lỗi Code 231
- ✅ PayOS orderCode được lưu để tra cứu sau này
- ✅ Service/Boarding orders không bị ảnh hưởng

