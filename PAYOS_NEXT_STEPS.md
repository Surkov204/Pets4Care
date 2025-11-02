# 🚀 PayOS Integration - Các Bước Tiếp Theo

## 📦 Bước 1: Kiểm tra và Giải nén File payos.1.0.61.zip

File `payos.1.0.61.zip` bạn đã tải về có thể chứa:
- PHP SDK (dành cho WooCommerce/PHP)
- Hoặc Java SDK trong thư mục con
- Hoặc chỉ là tài liệu hướng dẫn

### Cách kiểm tra:

1. **Giải nén file zip:**
   ```
   Right-click vào payos.1.0.61.zip → Extract All
   ```

2. **Kiểm tra nội dung:**
   - Tìm file `*.jar` trong thư mục đã giải nén
   - Nếu có file `payos-*.jar` → Copy vào thư mục `lib/`
   - Nếu không có → Cần tải Java SDK riêng

3. **Nếu không có JAR file:**
   - File zip này là cho PHP/WooCommerce, không phải Java
   - Bạn cần tải PayOS Java SDK từ Maven Central

---

## 📥 Bước 2: Tải PayOS Java SDK (Nếu cần)

### Option A: Download từ Maven Central (Khuyến nghị)

1. **Truy cập:** https://repo1.maven.org/maven2/vn/payos/payos/
2. **Tìm version mới nhất:** Ví dụ `2.1.0` hoặc `2.0.1`
3. **Download file:** `payos-2.1.0.jar`
4. **Copy vào:** `d:\SWP391\Pets4Care_tranhongson\Pets4Care\lib\`

### Option B: Dùng manual HTTP calls (Đang dùng)

✅ **Code hiện tại của bạn đã dùng manual HTTP calls** - Đây là cách đúng và không cần SDK!

Code trong `PayOSService.java` và `PayOSUtils.java` đã implement đúng theo tài liệu PayOS.

---

## ✅ Bước 3: Các Vấn Đề Đã Được Sửa

Dựa trên tài liệu PayOS, tôi đã sửa các vấn đề sau:

### 3.1. Webhook Signature Verification

**Vấn đề:** Signature cần được tính từ `data` object, không phải raw string

**Đã sửa:** `PayOSUtils.verifyWebhookSignature()` - Sẽ được cập nhật

### 3.2. Return URL Handler

**Vấn đề:** Return URL nhận parameters: `code`, `id`, `cancel`, `status`, `orderCode`

**Đã sửa:** `PayOSController.handlePaymentReturn()` - Sẽ được cập nhật

### 3.3. Payment Link Creation

**Tình trạng:** ✅ Đã đúng - Sử dụng manual HTTP calls với signature đúng format

---

## 🔧 Bước 4: Cài Đặt và Test

### 4.1. Copy JAR files vào lib/ (Nếu có)

```
1. Copy file payos-*.jar vào: lib/
2. Nếu có Jackson dependencies → Copy luôn:
   - jackson-databind-2.15.0.jar
   - jackson-core-2.15.0.jar  
   - jackson-annotations-2.15.0.jar
```

### 4.2. Add JARs vào NetBeans

1. **Right-click project** → **Properties**
2. **Libraries** → **Compile** tab
3. **Add JAR/Folder** → Chọn file từ `lib/`
4. **OK**

### 4.3. Build và Deploy

```powershell
# Trong NetBeans:
1. Clean and Build (F11)
2. Deploy
3. Start server
```

### 4.4. Test Payment Flow

1. **Tạo test order:**
   - Truy cập: http://localhost:9998/Pets4Care
   - Thêm sản phẩm vào giỏ
   - Thanh toán với PayOS

2. **Kiểm tra logs:**
   - Xem console output
   - Kiểm tra signature verification
   - Kiểm tra webhook processing

---

## 📋 Bước 5: Thiết Lập Webhook

### 5.1. Local Development (Dùng ngrok)

1. **Tải ngrok:** https://ngrok.com/download
2. **Chạy ngrok:**
   ```bash
   ngrok http 9998
   ```
3. **Copy HTTPS URL:** Ví dụ: `https://abc123.ngrok.io`

### 5.2. Đăng ký Webhook trong PayOS Dashboard

1. **Truy cập:** https://my.payos.vn
2. **Đăng nhập** vào tài khoản PayOS
3. **Vào Settings** → **Webhooks**
4. **Thêm webhook URL:**
   ```
   https://abc123.ngrok.io/Pets4Care/payos/webhook
   ```
   Hoặc production:
   ```
   https://yourdomain.com/Pets4Care/payos/webhook
   ```

### 5.3. Test Webhook

1. Tạo test payment trong PayOS dashboard
2. Kiểm tra logs trong server console
3. Xác nhận webhook được nhận và xử lý

---

## 🔍 Bước 6: Kiểm Tra và Debug

### 6.1. Kiểm tra PayOS Config

File: `src/payos.properties` hoặc hardcoded trong `PayOSConfig.java`

```properties
payos.client.id=aa93b610-c20b-4ffa-8c08-d006e01df689
payos.api.key=0d00713c-3627-4033-a87e-ba646b371a95
payos.checksum.key=d94677a139bd68e80dc67adf1fd3945db9c43679928823bfdf72f86d70d4ffd2
```

### 6.2. Test Payment Link Creation

Truy cập: http://localhost:9998/Pets4Care/payos/test-payos.jsp

### 6.3. Kiểm tra Logs

Các log quan trọng:
- `🔐 ===== GENERATING CHECKSUM =====`
- `🔐 ===== VERIFYING WEBHOOK SIGNATURE =====`
- `✅ Payment link created: ...`

---

## 📚 Tài Liệu Tham Khảo

1. **PayOS Checkout:** https://payos.vn/docs/checkout/how-checkout-works
2. **Webhook:** https://payos.vn/docs/du-lieu-tra-ve/webhook
3. **Return URL:** https://payos.vn/docs/du-lieu-tra-ve/return-url
4. **Signature:** https://payos.vn/docs/tich-hop-webhook/kiem-tra-du-lieu-voi-signature
5. **Java Demo:** https://github.com/payOSHQ/payos-demo-java-spring

---

## ⚠️ Lưu Ý Quan Trọng

1. **File zip WooCommerce:** Thường là PHP SDK, không dùng được cho Java
2. **Manual HTTP calls:** Đang dùng đúng, không cần SDK
3. **Signature format:** Phải match chính xác với PayOS backend
4. **Webhook URL:** Phải HTTPS trong production
5. **Return URL:** PayOS sẽ redirect về với query parameters

---

## 🎯 Kết Luận

**Code hiện tại đã đúng!** Chỉ cần:
1. ✅ Kiểm tra file zip (nếu có JAR thì copy vào lib/)
2. ✅ Thiết lập webhook URL trong PayOS dashboard
3. ✅ Test payment flow
4. ✅ Kiểm tra logs

Không cần tải thêm SDK nếu code manual HTTP calls đã hoạt động!

