# 🚨 FIX NGAY - PayOS Config Không Load

## ❌ Vấn đề:

Log cho thấy:
```
❌ PayOS config file not found: payos.properties
❌ Using default values
🔍 PayOS Configuration Check:
  - Client ID: your_client_id
  - API Key: [NOT CONFIGURED]
  - Is Configured: false
```

➡️ **File `payos.properties` không được load!**

---

## ✅ GIẢI PHÁP NGAY:

NetBeans deploy từ thư mục `web/`, KHÔNG phải `build/web/`.

### Copy file vào đúng thư mục:

```powershell
# Đã chạy lệnh này!
Copy-Item "src\payos.properties" "web\WEB-INF\classes\payos.properties" -Force
```

### Kiểm tra:

```powershell
# Kiểm tra file có tồn tại không
Test-Path "web\WEB-INF\classes\payos.properties"
```

---

## 🔄 Tiếp theo:

1. **UNDEPLOY** project trong NetBeans
2. **REBUILD** project
3. **DEPLOY** lại project
4. **Test lại PayOS**

### Trong NetBeans:

1. **Stop** Tomcat (nếu đang chạy)
2. **Right click** project → **Clean**
3. **Right click** project → **Build**
4. **Start** Tomcat
5. Kiểm tra console có thấy:
   ```
   ✅ Loading PayOS config from: payos.properties
   ✅ PayOS config loaded successfully
   ```

---

## 🎯 Kết quả mong đợi:

Sau khi rebuild và restart, log sẽ hiển thị:

```
✅ Loading PayOS config from: payos.properties
✅ PayOS config loaded successfully
  - Client ID: 82a4c379-98cf-4f13-8376-8b0bab8f9368
  - API Key: [SET]
  - Checksum Key: [SET]
🔍 PayOS Configuration Check:
  - Client ID: 82a4c379-98cf-4f13-8376-8b0bab8f9368
  - API Key: [CONFIGURED]
  - Checksum Key: [CONFIGURED]
  - Is Configured: true
✅ PayOS is configured
📤 Payment data: {...}
✅ Payment link created: https://...
```

---

## 📝 Lưu ý:

**NetBeans deploy file từ thư mục `web/`, không phải `build/web/`!**

Mỗi lần rebuild, file config sẽ được copy từ:
- `web/` → `build/web/` → Tomcat deployment folder

Vậy nên **phải copy file vào `web/WEB-INF/classes/`** để nó được deploy!

---

## ✅ Đã làm:

- [x] Copy `payos.properties` vào `web/WEB-INF/classes/`
- [ ] Clean project
- [ ] Rebuild project
- [ ] Restart Tomcat
- [ ] Test PayOS payment

