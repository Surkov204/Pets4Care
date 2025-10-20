# HƯỚNG DẪN SỬA LỖI ĐẶT LỊCH KHÁM

## ❌ VẤN ĐỀ
- Đặt lịch khám không lưu được vào database
- Form bị trống sau khi bấm "Đặt lịch"
- Báo lỗi "Không thể đặt lịch"

**NGUYÊN NHÂN:** Database thiếu các bảng `Booking`, `Doctor`, `PetService`, `Booking_Service`

---

## ✅ GIẢI PHÁP (3 BƯỚC)

### BƯỚC 1: Chạy File SQL
1. Mở **SQL Server Management Studio** (SSMS)
2. Kết nối đến database server
3. Mở file: `Database/create_complete_booking_system.sql`
4. Chọn database: **SHOP_PET_Database**
5. Nhấn **F5** để chạy
6. Chờ đến khi thấy thông báo:
   ```
   ✅ HOÀN THÀNH TẠO HỆ THỐNG BOOKING
   ```

### BƯỚC 2: Restart Ứng Dụng
**QUAN TRỌNG!** Phải restart để kết nối lại database.

Nếu dùng **NetBeans:**
- Stop server (nút Stop màu đỏ)
- Run lại project (nút Run màu xanh)

Nếu dùng **Tomcat:**
- Stop Tomcat server
- Start lại Tomcat

### BƯỚC 3: Test Chức Năng
1. Đăng nhập vào website
2. Vào trang **"Đặt Lịch Khám"**
3. Điền đầy đủ thông tin:
   - Chọn dịch vụ khám
   - Chọn ngày & giờ
   - Chọn bác sĩ
   - Ghi chú (tùy chọn)
4. Bấm **"Đặt lịch khám"**
5. ✅ Sẽ thấy thông báo: **"Đặt lịch khám sức khỏe thành công!"**

---

## 📊 DỮ LIỆU ĐÃ TẠO

### 6 Bác Sĩ:
1. BS. Nguyễn Minh Anh - Da liễu & chăm sóc lông
2. BS. Trần Văn Cường - Phẫu thuật & chỉnh hình
3. BS. Lê Thị Mai - Tim mạch & hô hấp
4. BS. Phạm Đức Minh - Tiêu hóa & dinh dưỡng
5. BS. Võ Thị Hương - Sản khoa & sinh sản
6. BS. Đặng Văn Tùng - Thần kinh & hành vi

### 5 Dịch Vụ Khám Sức Khỏe:
1. Khám sức khỏe tổng quát - 200,000đ (30 phút)
2. Khám chuyên sâu - 500,000đ (60 phút)
3. Khám định kỳ - 150,000đ (20 phút)
4. Tiêm phòng cơ bản - 300,000đ (20 phút)
5. Tư vấn dinh dưỡng - 100,000đ (30 phút)

### 4 Dịch Vụ Spa:
1. Tắm + Vệ sinh cơ bản - 150,000đ (45 phút)
2. Cắt tỉa lông chuyên nghiệp - 300,000đ (90 phút)
3. Spa cao cấp - 500,000đ (120 phút)
4. Vệ sinh răng miệng - 200,000đ (30 phút)

---

## 🔍 KIỂM TRA DATABASE

Chạy query này để kiểm tra:

```sql
USE SHOP_PET_Database;

-- Kiểm tra dữ liệu
SELECT 'Doctor' AS TableName, COUNT(*) AS Records FROM Doctor
UNION ALL
SELECT 'PetService', COUNT(*) FROM PetService
UNION ALL
SELECT 'Booking', COUNT(*) FROM Booking;

-- Xem chi tiết
SELECT * FROM Doctor;
SELECT * FROM PetService;
```

**Kết quả mong đợi:**
- Doctor: 6 records ✓
- PetService: 9 records ✓
- Booking: 0 records (chưa có booking nào)

---

## 🐛 NẾU VẪN GẶP LỖI

### Lỗi 1: "Cannot find table Booking"
**Giải pháp:** Chạy lại file SQL, đảm bảo chọn đúng database `SHOP_PET_Database`

### Lỗi 2: Form vẫn bị trống
**Giải pháp:**
1. Kiểm tra console log xem có lỗi gì
2. **RESTART LẠI ỨNG DỤNG** (rất quan trọng!)
3. Clear cache trình duyệt (Ctrl+Shift+Delete)

### Lỗi 3: "Foreign key constraint..."
**Giải pháp:** 
- Chạy file `Database/check_and_create_tables.sql` trước
- Đảm bảo có bảng `Customer`, `PET`, và `Staff`

### Lỗi 4: "Chưa có thông tin pet"
**Giải pháp:**
- Vào **"Thông tin cá nhân"**
- Cập nhật thông tin thú cưng
- Sau đó mới đặt lịch khám

---

## 📝 THAY ĐỔI ĐÃ THỰC HIỆN

### 1. Database Schema:
- ✅ Tạo bảng `Doctor`
- ✅ Tạo bảng `PetService`
- ✅ Tạo bảng `Booking`
- ✅ Tạo bảng `Booking_Service`
- ✅ Tạo indexes để tăng hiệu suất
- ✅ Tạo triggers tự động cập nhật timestamps

### 2. Java Code:
- ✅ Sửa `BookingServiceDAO.java` - bỏ trường `created_at` không cần thiết
- ✅ Sửa `PetServiceDAO.java` - bỏ trường `image_path` không cần thiết
- ✅ Cải thiện `HealthCheckBookingService.java` - thêm logging chi tiết
- ✅ Cải thiện `HealthCheckBookingServlet.java` - error handling tốt hơn

### 3. Logging:
- ✅ Thêm logging chi tiết để debug dễ dàng
- ✅ Hiển thị từng bước tạo booking
- ✅ Log lỗi rõ ràng khi fail

---

## 📖 XEM LOG ĐỂ DEBUG

Khi test, xem log trong console để biết vấn đề ở đâu:

```
========== CREATE HEALTH CHECK BOOKING ==========
Customer: Nguyễn Văn A (ID: 1)
Form data - serviceId: 1, date: 2025-10-20, time: 09:00, doctorId: 1
=== BẮT ĐẦU TẠO BOOKING ===
Bước 1: Kiểm tra thông tin pet...
✓ Pet found: ID=1, Name=Milu
Bước 2: Kiểm tra dịch vụ...
✓ Service validated
Bước 3: Lấy thông tin dịch vụ...
✓ Service: Khám sức khỏe tổng quát, Price: 200000, Duration: 30
Bước 4: Tính thời gian kết thúc...
✓ Appointment End: 2025-10-20 09:30:00
Bước 5: Tạo booking object...
✓ Booking object created
Bước 6: Lưu booking vào database...
  → Bước 6.1: Lưu booking chính vào bảng Booking...
  ✓ Booking created with ID: 1
  → Bước 6.2: Lấy thông tin dịch vụ để tạo Booking_Service...
  ✓ Service found: Khám sức khỏe tổng quát
  → Bước 6.3: Tạo booking service item...
  ✓ BookingService object created: booking_id=1, service_id=1
  → Bước 6.4: Lưu booking service vào bảng Booking_Service...
  ✓ Booking service detail created successfully
✅ SUCCESS: Tạo booking khám sức khỏe thành công! Booking ID: 1
========== END CREATE HEALTH CHECK BOOKING ==========
```

---

## ✨ SAU KHI SỬA XONG

Bạn sẽ có thể:
- ✅ Đặt lịch khám thành công
- ✅ Xem lịch sử đặt lịch
- ✅ Hủy lịch đã đặt
- ✅ Xem chi tiết từng booking
- ✅ Chọn bác sĩ theo chuyên khoa
- ✅ Chọn dịch vụ khám phù hợp

---

## 🎉 HOÀN THÀNH!

Nếu làm theo đúng 3 bước trên, hệ thống đặt lịch sẽ hoạt động hoàn hảo!

**Lưu ý:** Nếu vẫn gặp lỗi, hãy kiểm tra:
1. SQL Server đang chạy
2. Database name: `SHOP_PET_Database`
3. Connection string trong `DBConnection.java`
4. Đã restart ứng dụng chưa
5. Console log có lỗi gì không

