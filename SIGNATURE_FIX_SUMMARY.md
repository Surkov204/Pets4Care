# PayOS Webhook Signature Verification Fix

## Vấn đề đã được khắc phục

### 1. **Signature Extraction**
- **Trước:** Code mong đợi signature được truyền từ header, nhưng PayOS có thể gửi signature trong JSON body
- **Sau:** Code tự động extract signature từ cả header `x-payos-signature` và từ JSON body nếu header không có

### 2. **Webhook Data Structure**
- **Trước:** Code đang kiểm tra field `status == "PAID"` trong data object
- **Sau:** Kiểm tra đúng field `code == "00"` để xác định thanh toán thành công (theo tài liệu PayOS)

### 3. **Case-insensitive Signature Comparison**
- **Trước:** So sánh signature chính xác hoàn toàn (case-sensitive)
- **Sau:** Sử dụng `equalsIgnoreCase()` để so sánh signature

### 4. **Syntax Error Fix**
- **Trước:** Thiếu opening brace trong PayOSWebhookServlet
- **Sau:** Đã sửa cấu trúc if-else

## Các file đã được sửa đổi

### 1. `src/java/utils/PayOSUtils.java`
- Phương thức `verifyPaymentRequestSignature()`: Extract signature từ webhook data nếu header không có
- Phương thức `verifyPayoutSignature()`: Extract signature từ webhook data nếu header không có
- Phương thức `verifyWebhookSignature()`: Cải thiện logic extract signature
- Thay đổi từ `equals()` sang `equalsIgnoreCase()` cho việc so sánh signature

### 2. `src/java/controller/PayOSWebhookServlet.java`
- Sửa lỗi syntax: thiếu opening brace trong if-else block
- Cải thiện cấu trúc xử lý signature validation

### 3. `src/java/service/PayOSService.java`
- Phương thức `handleWebhook()`: Cập nhật để đọc đúng cấu trúc webhook theo tài liệu PayOS
- Thay đổi từ kiểm tra `status == "PAID"` sang `code == "00"`
- Thêm support cho payout webhook (nhận và acknowledge, chưa xử lý chi tiết)
- Thêm logging chi tiết hơn cho debugging

### 4. `src/java/controller/PayOSController.java`
- Thêm logging chi tiết khi nhận webhook
- Cải thiện error handling và logging

## Cấu trúc webhook PayOS

### Payment Request Webhook (theo tài liệu)
```json
{
  "code": "00",
  "desc": "success",
  "success": true,
  "data": {
    "orderCode": 123,
    "amount": 3000,
    "description": "VQRIO123",
    "accountNumber": "12345678",
    "reference": "TF230204212323",
    "transactionDateTime": "2023-02-04 18:25:00",
    "currency": "VND",
    "paymentLinkId": "124c33293c43417ab7879e14c8d9eb18",
    "code": "00",
    "desc": "Thành công",
    "counterAccountBankId": "",
    "counterAccountBankName": "",
    "counterAccountName": "",
    "counterAccountNumber": "",
    "virtualAccountName": "",
    "virtualAccountNumber": ""
  },
  "signature": "8d8640d802576397a1ce45ebda7f835055768ac7ad2e0bfb77f9b8f12cca4c7f"
}
```

**Lưu ý:**
- Signature được tạo từ object `data` (không bao gồm các field `code`, `desc`, `success`, `signature` ở top level)
- Trong `data` object, có 2 field quan trọng:
  - `code`: "00" = thành công, khác "00" = lỗi
  - `orderCode`: mã đơn hàng để update database

## Cách signature được tạo

### Payment Requests
1. Lấy data object (không lấy signature)
2. Sắp xếp keys theo alphabet
3. Tạo query string: `key1=value1&key2=value2&...`
4. HMAC-SHA256 với checksum key
5. Convert sang hex

### Payouts
1. Lấy data object (không lấy signature)
2. Sắp xếp keys theo alphabet
3. Tạo query string với URL encoding: `key1=encodeURI(value1)&key2=encodeURI(value2)&...`
4. HMAC-SHA256 với checksum key
5. Convert sang hex
6. **Lưu ý:** Arrays giữ nguyên thứ tự, không sort

## Testing

Để test webhook signature verification:

1. Log vào My PayOS: https://my.payos.vn
2. Tạo thanh toán test
3. Chờ webhook được gửi đến
4. Kiểm tra logs trong server để xem signature verification

## Debugging

Các log quan trọng:
- `🔐 ===== VERIFYING WEBHOOK SIGNATURE =====`
- `📋 Webhook data: ...` - Data object để tạo signature
- `🔑 Expected signature: ...` - Signature từ webhook
- `🔐 Computed signature: ...` - Signature tính toán được
- `✅ Signature verification result: true/false`

Nếu signature mismatch, kiểm tra:
1. Checksum key có đúng không?
2. Data object có đúng structure không?
3. Keys có được sort alphabetically không?
4. Values có được format đúng không (URL encoding cho payouts)?

