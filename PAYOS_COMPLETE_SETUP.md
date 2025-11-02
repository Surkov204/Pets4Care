# 🎯 PayOS Integration - Hướng Dẫn Hoàn Chỉnh

## ✅ Đã Hoàn Thành

### 1. Code Implementation
- ✅ Payment Link Creation (manual HTTP calls)
- ✅ Signature Generation (đúng format PayOS)
- ✅ Webhook Signature Verification (đã sửa theo tài liệu)
- ✅ Return URL Handler (đã cải thiện)
- ✅ Database Integration

### 2. Files Đã Được Sửa
- `src/java/utils/PayOSUtils.java` - Webhook signature verification đã đúng
- `src/java/service/PayOSService.java` - Webhook handler
- `src/java/controller/PayOSController.java` - Return URL handler đã cải thiện

---

## 📦 Bước 1: Kiểm Tra File Zip

Bạn đã có file `payos.1.0.61.zip`. Hãy kiểm tra nội dung:

### Cách 1: Dùng Script PowerShell (Khuyến nghị)

```powershell
cd d:\SWP391\Pets4Care_tranhongson\Pets4Care
.\check-payos-zip.ps1
```

Script sẽ:
- ✅ Tự động giải nén và kiểm tra
- ✅ Tìm file JAR nếu có
- ✅ Copy vào thư mục `lib/` nếu bạn đồng ý
- ✅ Hướng dẫn các bước tiếp theo

### Cách 2: Giải Nén Thủ Công

1. **Right-click** vào `payos.1.0.61.zip` → **Extract All**
2. **Kiểm tra** xem có file `*.jar` không
3. Nếu có → Copy vào `lib/`
4. Nếu không có → Đây là PHP SDK, không dùng được cho Java

---

## 🔧 Bước 2: Thiết Lập NetBeans

### 2.1. Add JAR Files (Nếu có)

1. **Right-click** project "Pets4Care" → **Properties**
2. **Libraries** → **Compile** tab
3. **Add JAR/Folder** → Chọn file từ `lib/`
4. Click **OK**

### 2.2. Build Project

```powershell
# Trong NetBeans:
1. Clean and Build (F11)
2. Kiểm tra không có lỗi compile
3. Deploy
```

---

## 🌐 Bước 3: Thiết Lập Webhook (Quan Trọng!)

### 3.1. Local Development (Dùng ngrok)

1. **Tải ngrok:**
   - Truy cập: https://ngrok.com/download
   - Download và giải nén

2. **Chạy ngrok:**
   ```bash
   ngrok http 9998
   ```

3. **Copy HTTPS URL:**
   ```
   Ví dụ: https://abc123.ngrok.io
   ```

4. **Webhook URL sẽ là:**
   ```
   https://abc123.ngrok.io/Pets4Care/payos/webhook
   ```

### 3.2. Đăng Ký Webhook trong PayOS

1. **Truy cập:** https://my.payos.vn
2. **Đăng nhập** vào tài khoản PayOS
3. **Vào Settings** → **Webhooks**
4. **Thêm webhook URL:**
   - Local: `https://abc123.ngrok.io/Pets4Care/payos/webhook`
   - Production: `https://yourdomain.com/Pets4Care/payos/webhook`

### 3.3. Production

- Webhook URL phải là HTTPS
- Đảm bảo server có thể nhận POST requests từ PayOS

---

## 🧪 Bước 4: Test Payment Flow

### 4.1. Test Payment Link Creation

1. **Truy cập:** http://localhost:9998/Pets4Care/payos/test-payos.jsp
2. Click **Test Payment**
3. Kiểm tra xem có redirect đến PayOS checkout không

### 4.2. Test Full Flow

1. **Thêm sản phẩm** vào giỏ hàng
2. **Thanh toán** với PayOS
3. **Kiểm tra:**
   - ✅ Redirect đến PayOS checkout
   - ✅ Sau khi thanh toán → redirect về return URL
   - ✅ Webhook được gửi và xử lý
   - ✅ Database được cập nhật

### 4.3. Kiểm Tra Logs

Trong NetBeans console, tìm các log:
```
🔐 ===== GENERATING CHECKSUM =====
💳 Creating payment link...
✅ Payment link created: https://...
🔐 ===== VERIFYING WEBHOOK SIGNATURE =====
✅ Webhook verified successfully
```

---

## 📋 Bước 5: Kiểm Tra Cấu Hình

### 5.1. PayOS Config

File: `src/payos.properties` hoặc hardcoded trong `PayOSConfig.java`

```properties
payos.client.id=aa93b610-c20b-4ffa-8c08-d006e01df689
payos.api.key=0d00713c-3627-4033-a87e-ba646b371a95
payos.checksum.key=d94677a139bd68e80dc67adf1fd3945db9c43679928823bfdf72f86d70d4ffd2
payos.base.url=https://api.payos.vn/v2
```

### 5.2. Verify Config Load

Kiểm tra console khi server start:
```
✅ PayOS config loaded successfully
  - Client ID: aa93b610-c20b-4ffa-8c08-d006e01df689
  - API Key: [SET]
  - Checksum Key: [SET]
```

---

## 🔍 Debugging

### Nếu Payment Link NULL

1. **Kiểm tra console logs:**
   - Xem PayOS API response
   - Kiểm tra signature generation
   - Verify API credentials

2. **Test connectivity:**
   ```java
   PayOSUtils.diagnosePayOSConnectivity();
   ```

3. **Kiểm tra network:**
   - Firewall có chặn không?
   - VPN có ảnh hưởng không?
   - DNS có resolve được api.payos.vn không?

### Nếu Webhook Signature Invalid

1. **Kiểm tra logs:**
   ```
   🔐 Calculated signature: ...
   🔐 PayOS signature: ...
   ```

2. **Verify:**
   - Checksum key có đúng không?
   - Data object có đúng format không?
   - Keys có được sort alphabetically không?

### Nếu Return URL Không Hoạt Động

1. **Kiểm tra parameters:**
   - `code`, `orderCode`, `status`, `cancel`
   - Logs sẽ hiển thị tất cả parameters

2. **Verify redirect:**
   - Return URL có đúng format không?
   - Server có accessible từ internet không?

---

## 📚 Tài Liệu Tham Khảo

1. **PayOS Checkout Flow:** https://payos.vn/docs/checkout/how-checkout-works
2. **Quick Start Hosted Page:** https://payos.vn/docs/checkout/quick-start-payos-hosted-page
3. **Webhook Documentation:** https://payos.vn/docs/du-lieu-tra-ve/webhook
4. **Return URL:** https://payos.vn/docs/du-lieu-tra-ve/return-url
5. **Signature Verification:** https://payos.vn/docs/tich-hop-webhook/kiem-tra-du-lieu-voi-signature
6. **Java Demo:** https://github.com/payOSHQ/payos-demo-java-spring

---

## ⚠️ Lưu Ý Quan Trọng

1. **File zip WooCommerce:** Thường là PHP SDK, không dùng cho Java
2. **Manual HTTP calls:** Code hiện tại đã đúng, không cần SDK
3. **Signature format:** Phải match chính xác với PayOS backend
4. **Webhook URL:** Phải HTTPS trong production
5. **Return URL:** PayOS sẽ redirect về với query parameters

---

## 🎯 Tóm Tắt

✅ **Code đã hoàn chỉnh!** Bạn chỉ cần:

1. ✅ Kiểm tra file zip (dùng script `check-payos-zip.ps1`)
2. ✅ Thiết lập webhook URL trong PayOS dashboard
3. ✅ Test payment flow
4. ✅ Kiểm tra logs

**Không cần tải thêm SDK** nếu code manual HTTP calls đã hoạt động!

---

## 🆘 Cần Hỗ Trợ?

Nếu gặp vấn đề:
1. Kiểm tra logs trong console
2. Xem file `PAYOS_NEXT_STEPS.md`
3. Tham khảo tài liệu PayOS chính thức

