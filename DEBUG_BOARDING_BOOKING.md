# 🐛 DEBUG: Lỗi đặt phòng boarding

## ❌ Lỗi hiện tại
"Đặt phòng thất bại. Vui lòng kiểm tra: 1. Thông tin khách hàng hợp lệ 2. Kết nối database 3. Liên hệ hỗ trợ nếu vấn đề vẫn tiếp diễn."

## 📋 Checklist Debug

### 1️⃣ Kiểm tra Server Logs (TÌM CÁC DÒng LOG)

Tìm trong console/logs các dòng sau:

#### A. Form Parameters (Dòng log đầu tiên)
```
=== CREATE BOARDING BOOKING FROM FORM DEBUG ===
Customer ID: [số]
Form parameters:
roomType: [giá trị]
pricePerDayStr: [giá trị]
boardingDaysStr: [giá trị]
checkInDate: [giá trị]
checkOutDate: [giá trị]
petInfo: [giá trị]
emergencyPhone1: [giá trị]
```

**✅ PASS nếu:** Tất cả các giá trị hiển thị đúng
**❌ FAIL nếu:** Có giá trị null hoặc empty

---

#### B. Validation Checks
Tìm các dòng:
- `✅ All validations passed, starting to parse data...`
- `Validating emergencyPhone1: [số]`
- `✅ emergencyPhone1 is valid`

**✅ PASS nếu:** Thấy dòng "All validations passed"
**❌ FAIL nếu:** Thấy dòng `❌` với lỗi cụ thể, ví dụ:
  - `❌ Phone validation failed for emergencyPhone1`
  - `❌ Failed to parse pricePerDay`
  - `❌ Failed to parse dates`

---

#### C. Boarding Days Calculation
Tìm block:
```
📊 BOARDING DAYS CALCULATION:
  - Form boardingDays: [giá trị]
  - Parsed formBoardingDays: [số]
  - Actual boardingDays from dates: [số]
  - Final boardingDays used: [số]
  - Price per day: [số]
```

**✅ PASS nếu:** Final boardingDays >= 1
**❌ FAIL nếu:** Final boardingDays = 0

---

#### D. Booking Object Before Insert
Tìm block:
```
=== BOARDING BOOKING OBJECT BEFORE INSERT ===
Customer ID: [số]
Room Type: [text]
Price Per Day: [số]
Boarding Days: [số]
Total Price: [số]
Check-in Date: [timestamp]
Check-out Date: [timestamp]
Check-in Time: [HH:mm]
Check-out Time: [HH:mm]
Pet Info: [text]
Emergency Phone 1: [số]
```

**KiỂM TRA:**
- [ ] Customer ID > 0?
- [ ] Room Type không null?
- [ ] Price Per Day > 0?
- [ ] Boarding Days >= 1?
- [ ] Total Price > 0?
- [ ] Dates không null?
- [ ] Emergency Phone 1 có 10-11 chữ số?

---

#### E. DAO Validation (BoardingBookingDAO logs)
Tìm các dòng từ DAO:
```
Setting parameters for boarding booking insert:
Customer ID: [số]
Room Type: [text]
...
Executing INSERT statement...
INSERT executed, affected rows: [số]
```

**✅ PASS nếu:**
- Thấy "Executing INSERT statement..."
- affected rows = 1
- Thấy "✅ Boarding booking created with ID: [số]"

**❌ FAIL nếu thấy:**
- `Invalid customer ID: [số]` → Customer ID = 0 hoặc âm
- `Room type cannot be null or empty` → roomType null
- `Invalid price per day: [số]` → pricePerDay <= 0
- `❌ Invalid boarding days (must be >= 1): [số]` → boardingDays < 1
- `Check-in or check-out date cannot be null` → Dates null
- `Emergency phone 1 cannot be null or empty` → Phone null

**❌ FAIL nếu thấy SQL ERROR:**
```
Error adding boarding booking: [message]
SQL State: [code]
Error Code: [số]
```

Các lỗi SQL phổ biến:
- **23000** / Error Code **547**: Foreign key constraint violation
  → Customer ID không tồn tại trong bảng Customer
  → **Giải pháp:** Kiểm tra customer có tồn tại trong database không
  
- **08S01**: Connection error
  → Không kết nối được database
  → **Giải pháp:** Kiểm tra database server có đang chạy không
  
- **42S02**: Table doesn't exist
  → Bảng boarding_bookings chưa được tạo
  → **Giải pháp:** DAO sẽ tự tạo, nhưng có thể quyền không đủ

---

### 2️⃣ Test Cases để debug

#### Test 1: Đặt phòng với dữ liệu hợp lệ
```
Room Type: Phòng Standard
Price: 300000
Check-in: 2025-11-05
Check-out: 2025-11-06
Check-in Time: 08:00
Check-out Time: 17:00
Pet Info: Chó Golden Retriever, 2 tuổi, tên: Buddy
Emergency Phone 1: 0901234567
Emergency Phone 2: (để trống hoặc 0907654321)
Special Notes: (để trống)
```

**Kỳ vọng:**
- boardingDays = 1
- totalPrice = 300000 * (số giờ / 24)

#### Test 2: Kiểm tra Customer ID
Trong database, chạy query:
```sql
SELECT customer_id, full_name, email FROM dbo.Customer WHERE customer_id = [ID trong log]
```

**✅ PASS nếu:** Tìm thấy customer
**❌ FAIL nếu:** Không tìm thấy → Người dùng chưa đăng nhập đúng

#### Test 3: Kiểm tra table tồn tại
```sql
SELECT COUNT(*) FROM dbo.boarding_bookings
```

**✅ PASS nếu:** Query thành công (không cần có dữ liệu)
**❌ FAIL nếu:** "Invalid object name 'boarding_bookings'" → Bảng chưa tạo

---

### 3️⃣ Các nguyên nhân phổ biến

| Lỗi | Nguyên nhân | Giải pháp |
|-----|------------|-----------|
| Customer ID = 0 | Chưa đăng nhập hoặc session hết hạn | Đăng nhập lại |
| Phone validation failed | Số điện thoại có ký tự đặc biệt | Chỉ nhập số (không có - + hoặc space) |
| boardingDays = 0 | Check-in date sau check-out date | Chọn lại dates |
| SQL Error 547 | Customer ID không tồn tại trong DB | Kiểm tra table Customer |
| SQL Error 42S02 | Bảng chưa tạo | Khởi động lại server để trigger createTableIfNotExists() |
| Connection timeout | Database server offline | Kiểm tra SQL Server đang chạy |

---

### 4️⃣ Quick Fix Commands

#### Reset boarding_bookings table
```sql
-- Xóa bảng cũ (nếu có lỗi cấu trúc)
DROP TABLE IF EXISTS dbo.boarding_bookings;
```

Sau đó khởi động lại server để tạo lại bảng.

#### Kiểm tra foreign key constraint
```sql
-- Xem constraints
SELECT 
    fk.name AS ForeignKeyName,
    tp.name AS ParentTable,
    cp.name AS ParentColumn,
    tr.name AS ReferencedTable,
    cr.name AS ReferencedColumn
FROM 
    sys.foreign_keys AS fk
    INNER JOIN sys.tables AS tp ON fk.parent_object_id = tp.object_id
    INNER JOIN sys.tables AS tr ON fk.referenced_object_id = tr.object_id
    INNER JOIN sys.foreign_key_columns AS fkc ON fk.object_id = fkc.constraint_object_id
    INNER JOIN sys.columns AS cp ON fkc.parent_column_id = cp.column_id AND fkc.parent_object_id = cp.object_id
    INNER JOIN sys.columns AS cr ON fkc.referenced_column_id = cr.column_id AND fkc.referenced_object_id = cr.object_id
WHERE 
    tp.name = 'boarding_bookings';
```

---

## 📝 Các thay đổi code đã thực hiện

1. ✅ Thêm `return;` sau mỗi `sendRedirect()` trong catch blocks
2. ✅ Cải thiện logic tính `boardingDays` (tối thiểu = 1)
3. ✅ Thêm validation `boardingDays >= 1` trong DAO
4. ✅ Thêm logging chi tiết cho debugging
5. ✅ Validate customer ID trước khi insert
6. ✅ Try-catch cho parsing pricePerDay và dates

---

## 🚀 Hành động tiếp theo

1. **Khởi động lại server** để apply code changes
2. **Thử đặt phòng lại** với dữ liệu test case ở trên
3. **Xem server logs** và tìm các dòng log theo checklist trên
4. **Báo cáo** dòng log đầu tiên có ❌ (nếu có)

---

Nếu vẫn gặp lỗi, hãy copy toàn bộ stack trace và logs liên quan!

