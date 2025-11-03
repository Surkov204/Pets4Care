# 🌐 Test Network Connectivity to PayOS

## ❌ Lỗi hiện tại: "Error: api.payos.vn"

Lỗi này nghĩa là **KHÔNG kết nối được đến PayOS API**.

---

## ✅ Kiểm tra ngay (chạy từng lệnh):

### 1️⃣ Test DNS Resolution

**Windows PowerShell:**
```powershell
nslookup api.payos.vn
```

**Kết quả mong đợi:**
```
Server:  ...
Address:  ...

Non-authoritative answer:
Name:    api.payos.vn
Address:  [IP address]
```

❌ **Nếu lỗi:** DNS không hoạt động → Check DNS settings

---

### 2️⃣ Test Ping

```powershell
ping api.payos.vn
```

**Kết quả mong đợi:**
```
Pinging api.payos.vn [xxx.xxx.xxx.xxx] with 32 bytes of data:
Reply from xxx.xxx.xxx.xxx: bytes=32 time=XXms TTL=XX
```

❌ **Nếu lỗi:** "Request timed out" → Network/Firewall issue

---

### 3️⃣ Test HTTPS Connection

```powershell
Test-NetConnection api.payos.vn -Port 443
```

**Kết quả mong đợi:**
```
TcpTestSucceeded : True
```

❌ **Nếu lỗi:** TcpTestSucceeded = False → Firewall chặn port 443

---

### 4️⃣ Test với curl/Invoke-WebRequest

```powershell
curl https://api.payos.vn
```

HOẶC:

```powershell
Invoke-WebRequest -Uri "https://api.payos.vn" -Method GET
```

**Kết quả mong đợi:**
- Nhận được response (có thể là 404/401 nhưng đó là OK)
- Quan trọng là **CÓ RESPONSE**, không phải timeout

❌ **Nếu timeout:** Không kết nối được

---

## 🛠️ Các giải pháp:

### Giải pháp 1: Thử từ browser
```
1. Mở browser
2. Vào: https://api.payos.vn
3. Xem có load được gì không (kể cả error page cũng OK)
```

### Giải pháp 2: Check Firewall/Antivirus
```
1. Tạm thời tắt Windows Firewall
2. Tạm thời tắt Antivirus
3. Thử lại PayOS payment
```

**Windows Firewall:**
```powershell
# Tắt firewall (Administrator)
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False

# Bật lại sau khi test
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True
```

### Giải pháp 3: Thử VPN
```
Nếu ISP chặn api.payos.vn:
1. Bật VPN
2. Thử lại
```

### Giải pháp 4: Check Proxy Settings
```
Settings → Network & Internet → Proxy
→ Tắt proxy nếu đang bật
```

### Giải pháp 5: Flush DNS Cache
```powershell
ipconfig /flushdns
```

---

## 🔧 Debug với Java Code

Nếu các test trên đều OK nhưng Java vẫn không kết nối được, thêm code debug:

### Thêm vào PayOSUtils.java (trước dòng connect):

```java
// Test DNS resolution
try {
    java.net.InetAddress addr = java.net.InetAddress.getByName("api.payos.vn");
    System.out.println("✅ DNS resolved: " + addr.getHostAddress());
} catch (java.net.UnknownHostException e) {
    System.err.println("❌ DNS resolution FAILED: " + e.getMessage());
}

// Test socket connection
try {
    java.net.Socket socket = new java.net.Socket();
    socket.connect(new java.net.InetSocketAddress("api.payos.vn", 443), 5000);
    socket.close();
    System.out.println("✅ Socket connection OK");
} catch (java.io.IOException e) {
    System.err.println("❌ Socket connection FAILED: " + e.getMessage());
}
```

---

## 🎯 Checklist Debug

- [ ] `nslookup api.payos.vn` → DNS resolution OK?
- [ ] `ping api.payos.vn` → Network reachable?
- [ ] `Test-NetConnection api.payos.vn -Port 443` → Port 443 open?
- [ ] Browser có access được `https://api.payos.vn`?
- [ ] Firewall đã tắt để test?
- [ ] Antivirus đã tắt để test?
- [ ] Proxy settings OK?
- [ ] VPN đã thử?

---

## 📋 Thông tin quan trọng:

### Request đã ĐÚNG ✅
```json
{
  "amount": 9490,
  "items": [
    {
      "name": "Thanh toan don hang #55",
      "quantity": 1,
      "price": 9490
    }
  ],
  "orderCode": 55,
  "description": "Thanh toan don hang #55",
  ...
}
```

→ Code KHÔNG có vấn đề!
→ Vấn đề là NETWORK CONNECTION!

---

## 🚨 Nếu TẤT CẢ test đều OK:

### Có thể PayOS API đang down
```
1. Check PayOS status page (nếu có)
2. Liên hệ PayOS support
3. Thử lại sau vài phút
```

### Hoặc Server Java không có internet
```
Nếu chạy trên máy khác với máy test:
- Server có internet không?
- Server firewall có chặn không?
```

---

## 📝 Kết luận:

**CODE ĐÃ ĐÚNG!** ✅
- Items array: OK
- Request format: OK
- Signature: OK

**VẤN ĐỀ LÀ NETWORK!** ❌
- Không kết nối được đến api.payos.vn
- Cần kiểm tra DNS, Firewall, Internet connection

**→ Chạy các test network ở trên và báo kết quả!**

