# 🔧 PayOS Integration - Các lỗi đã sửa

## ❌ Lỗi gốc

1. **Payment URL: NULL** - PayOS API không trả về payment link
2. **Response Body: NULL** - Không nhận được response từ PayOS
3. **Error: api.payos.vn** - Lỗi kết nối đến PayOS API
4. **"items": []** - Items array rỗng trong request

---

## ✅ Các thay đổi đã thực hiện

### 1. Sửa Items Array Rỗng

**File:** `src/java/utils/PayOSUtils.java` (dòng 332-351)

**Vấn đề:** PayOS yêu cầu ít nhất 1 item trong `items` array, nhưng code gửi array rỗng

**Giải pháp:**
```java
// Trước:
dataToSign.add("items", new JsonArray()); // ❌ Rỗng

// Sau:
JsonArray items = new JsonArray();
JsonObject defaultItem = new JsonObject();

// Tạo tên item ngắn gọn (PayOS giới hạn độ dài)
String itemName = cleanDescription;
if (itemName.length() > 50) {
    itemName = itemName.substring(0, 47) + "...";
}

defaultItem.addProperty("name", itemName);
defaultItem.addProperty("quantity", 1);
defaultItem.addProperty("price", amountInVND);
items.add(defaultItem);

dataToSign.add("items", items); // ✅ Có 1 item
```

**Kết quả:**
- Items array bây giờ có 1 item với name, quantity, price
- Tên item được rút ngắn nếu quá dài (max 50 ký tự)

---

### 2. Cải thiện Error Handling cho Network Issues

**File:** `src/java/utils/PayOSUtils.java` (dòng 36-66)

**Vấn đề:** 
- Không có timeout → có thể hang mãi
- Error messages không rõ ràng
- Không phân biệt loại lỗi (DNS, Connection, Timeout)

**Giải pháp:**
```java
HttpURLConnection conn = null;
try {
    conn = (HttpURLConnection) new URL(url).openConnection();
    
    // Set timeouts
    conn.setConnectTimeout(15000); // 15 giây
    conn.setReadTimeout(15000); // 15 giây
    
    conn.setRequestMethod(method);
    conn.setRequestProperty("Content-Type", "application/json");
    conn.setRequestProperty("x-client-id", PayOSConfig.getClientId());
    conn.setRequestProperty("x-api-key", PayOSConfig.getApiKey());
    
} catch (java.net.UnknownHostException e) {
    // DNS resolution failed
    System.err.println("❌ DNS Resolution Failed: Cannot resolve " + url);
    throw new IOException("Cannot connect to PayOS API - DNS resolution failed", e);
    
} catch (java.net.ConnectException e) {
    // Connection refused
    System.err.println("❌ Connection Failed: Cannot connect to " + url);
    throw new IOException("Cannot connect to PayOS API - connection refused", e);
    
} catch (java.net.SocketTimeoutException e) {
    // Timeout
    System.err.println("❌ Timeout: Connection timed out");
    throw new IOException("PayOS API timeout", e);
}
```

**Kết quả:**
- ✅ Request sẽ timeout sau 15 giây thay vì hang mãi
- ✅ Error messages rõ ràng hơn
- ✅ Phân biệt được lỗi DNS, Connection, Timeout

---

## 🧪 Test sau khi sửa

### Bước 1: Khởi động lại server

**Quan trọng:** Phải restart server để apply code changes!

```bash
# Stop server
# Restart server
```

### Bước 2: Thử thanh toán lại

1. Thêm sản phẩm vào giỏ hàng HOẶC đặt spa service
2. Chọn phương thức thanh toán **PayOS**
3. Click "Thanh toán"

### Bước 3: Kiểm tra logs

Tìm các dòng log sau trong console:

#### ✅ Logs thành công:

```
🚀 ===== CREATING PAYMENT REQUEST =====
📋 Input parameters:
   orderId: 54
   amount: 9490.0
   ...
   
📦 Added default item to items array:
   name: Thanh toan don hang #54
   quantity: 1
   price: 9490

🔗 PayOS URL: https://api.payos.vn/v2/payment-requests
⏱️ Timeouts set: connect=15s, read=15s
📤 Sending [xxx] bytes to PayOS
📥 PayOS Response Code: 201
📥 PayOS Response Body: {"code":"00","data":{"...","checkoutUrl":"https://..."}}
✅ PayOS request successful
✅ Payment link created: https://pay.payos.vn/web/...
```

#### ❌ Nếu vẫn lỗi:

**Lỗi DNS:**
```
❌ DNS Resolution Failed: Cannot resolve https://api.payos.vn
❌ Please check:
   1. Internet connection
   2. DNS settings
   3. Firewall not blocking api.payos.vn
```
**→ Giải pháp:** 
- Kiểm tra internet connection
- Thử ping `api.payos.vn` từ terminal
- Check firewall/antivirus

**Lỗi Connection Refused:**
```
❌ Connection Failed: Cannot connect to https://api.payos.vn
❌ Possible causes:
   1. PayOS API is down
   2. Firewall blocking connection
   3. Network issue
```
**→ Giải pháp:**
- PayOS API có thể đang down → check https://payos.vn/status
- Firewall đang block port 443 → tắt tạm thời để test

**Lỗi 400/401/403 từ PayOS:**
```
📥 PayOS Response Code: 401
❌ PayOS API Error: 401 - {"code":"401","desc":"Unauthorized"}
```
**→ Giải pháp:**
- Check API Key, Client ID có đúng không
- Check signature có được tạo đúng không

---

## 📋 Checklist Debug

- [ ] Đã restart server?
- [ ] Items array có ít nhất 1 item? (check log "📦 Added default item")
- [ ] Request được gửi đến PayOS? (check log "📤 Sending ... bytes")
- [ ] Response code là gì? (check log "📥 PayOS Response Code:")
  - `201` = Success ✅
  - `400` = Bad Request (sai format data)
  - `401` = Unauthorized (sai API key)
  - `403` = Forbidden (thiếu permission)
  - `500` = Server Error (PayOS API lỗi)
- [ ] Internet connection OK?
- [ ] Có thể ping được `api.payos.vn`?

---

## 🌐 Test Network Connectivity

### Windows:
```powershell
# Test DNS resolution
nslookup api.payos.vn

# Test connection
Test-NetConnection api.payos.vn -Port 443

# hoặc
curl https://api.payos.vn
```

### Linux/Mac:
```bash
# Test DNS resolution
dig api.payos.vn

# Test connection
nc -zv api.payos.vn 443

# hoặc
curl https://api.payos.vn
```

**Kết quả mong đợi:**
- DNS resolution thành công → nhận được IP address
- Connection thành công → port 443 open
- curl thành công → nhận được response (có thể là 404 nhưng đó là OK)

---

## 🔍 Request/Response Sample

### Request gửi đến PayOS (sau khi sửa):

```json
{
  "amount": 9490,
  "cancelUrl": "http://localhost:8080/Pets4Care/payos/cancel?orderId=54",
  "description": "Thanh toan don hang #54",
  "items": [
    {
      "name": "Thanh toan don hang #54",
      "quantity": 1,
      "price": 9490
    }
  ],
  "orderCode": 54,
  "returnUrl": "http://localhost:8080/Pets4Care/payos/return?orderId=54",
  "signature": "a5367f46b6e77db356c937a211ee6b19f0ea7d327a6ac8b848436c8d7891a167"
}
```

**✅ Thay đổi:** `items` bây giờ có 1 object thay vì rỗng!

### Response mong đợi từ PayOS:

```json
{
  "code": "00",
  "desc": "success",
  "data": {
    "bin": "970422",
    "accountNumber": "113366668888",
    "accountName": "NGUYEN VAN A",
    "amount": 9490,
    "description": "Thanh toan don hang #54",
    "orderCode": 54,
    "currency": "VND",
    "paymentLinkId": "...",
    "status": "PENDING",
    "checkoutUrl": "https://pay.payos.vn/web/abcdefgh123456",
    "qrCode": "https://img.vietqr.io/..."
  }
}
```

**Quan trọng:** `checkoutUrl` là payment link cần redirect người dùng đến!

---

## 📝 Notes

1. **Items array:** PayOS bắt buộc phải có ít nhất 1 item. Không thể gửi array rỗng.

2. **Timeouts:** 15 giây là đủ cho hầu hết các trường hợp. Nếu cần có thể tăng lên 30s.

3. **Error messages:** Bây giờ sẽ rõ ràng hơn để debug:
   - DNS failed → vấn đề về internet/DNS
   - Connection refused → firewall/PayOS down
   - Timeout → network chậm hoặc PayOS API slow

4. **Network issues:** Nếu gặp lỗi kết nối, hãy:
   - Check internet connection
   - Test với curl/ping command
   - Tạm thời tắt firewall/antivirus để test
   - Thử từ máy/network khác

---

## 🚀 Next Steps

Sau khi sửa lỗi PayOS, còn vấn đề **"đặt phòng boarding không được"** cần xử lý riêng.

Xem file: `DEBUG_BOARDING_BOOKING.md` để debug vấn đề đặt phòng.

---

**Tóm tắt:**
- ✅ Sửa items array rỗng → thêm 1 item mặc định
- ✅ Thêm timeouts → tránh hang
- ✅ Cải thiện error handling → debug dễ hơn
- ✅ Chi tiết hơn trong logs

**Restart server và thử lại!** 🎉

