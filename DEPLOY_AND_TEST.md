# 🚀 Hướng dẫn Deploy và Test PayOS Webhook

## 🔧 Các lỗi đã sửa:

1. ✅ **CORS Policy**: Thêm CORS headers vào servlets
2. ✅ **404 Not Found**: Cần build và deploy servlet mới
3. ✅ **Preflight Request**: Thêm doOptions() method

## 📋 Bước 1: Build và Deploy

### Trong NetBeans:
1. **Clean and Build Project**:
   - Right-click project → Clean and Build
   - Hoặc: Build → Clean and Build

2. **Deploy to Tomcat**:
   - Right-click project → Deploy
   - Hoặc: Build → Deploy

### Hoặc dùng command line:
```bash
# Build
ant clean build

# Deploy
ant deploy
```

## 🧪 Bước 2: Test Webhook

### Option 1: Test trực tiếp từ server
1. Mở: `https://uninvigorated-unfavorably-dotty.ngrok-free.dev/Pets4Care/test-webhook-direct.html`
2. Click "Test Webhook (Order #14)"
3. Kiểm tra console logs

### Option 2: Test với curl
```bash
curl -X POST https://uninvigorated-unfavorably-dotty.ngrok-free.dev/Pets4Care/test-webhook \
  -H "Content-Type: application/json" \
  -d '{"data":{"orderCode":14,"status":"PAID"}}'
```

### Option 3: Test PayOS webhook thật
1. Mở: `https://uninvigorated-unfavorably-dotty.ngrok-free.dev/Pets4Care/payos/webhook`
2. Gửi POST request với PayOS webhook data

## 📊 Bước 3: Kiểm tra kết quả

### Console logs mong đợi:
```
🧪 ===== TEST WEBHOOK SERVLET =====
📝 Webhook data: {"data":{"orderCode":14,"status":"PAID"}}
📦 Order ID: 14
📊 Status: PAID
✅ Processing payment confirmation...
Database update result: 1
✅ Order #14 updated successfully
```

### Database check:
```sql
SELECT order_id, payment_status, paid_at, status 
FROM [Order] 
WHERE order_id = 14;
```

## 🔍 Troubleshooting:

### Nếu vẫn bị 404:
1. Kiểm tra servlet đã được deploy chưa
2. Kiểm tra web.xml có mapping đúng không
3. Restart Tomcat server

### Nếu vẫn bị CORS:
1. Sử dụng trang test trực tiếp từ server
2. Hoặc dùng curl command
3. Kiểm tra CORS headers trong servlet

### Nếu database không update:
1. Kiểm tra connection string
2. Kiểm tra stored procedure ConfirmAndPayOrder
3. Kiểm tra console logs chi tiết

## 🎯 Kết quả mong đợi:

Sau khi test thành công:
- ✅ Webhook được nhận và xử lý
- ✅ Order #14 được update thành "Đã thanh toán"
- ✅ `paid_at` được set thành thời gian hiện tại
- ✅ `status` được update thành "Hoàn tất"

## 📞 Nếu vẫn có lỗi:

1. **Kiểm tra ngrok có chạy không**
2. **Kiểm tra Tomcat có chạy không**
3. **Kiểm tra console logs chi tiết**
4. **Test với curl trước khi test từ browser**
