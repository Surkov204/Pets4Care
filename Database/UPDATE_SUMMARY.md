# Tóm tắt cập nhật code cho schema mới

## Đã cập nhật:

### 1. DoctorAttendanceDAO.java ✅
- Đổi từ view `DoctorAttendanceRecords` → bảng `AttendanceRecords`
- Đổi `DoctorID` → `doctor_id`
- Các method: `getLatestRecord()`, `getAllRecords()`, `hasCheckedInToday()`

### 2. DoctorPayrollDAO.java ✅
- Đổi từ view `DoctorPayrollRecords` → bảng `PayrollRecords`
- Đổi `DoctorID` → `doctor_id`
- Các method: `getPayrollHistory()`, `getLatestPayroll()`

### 3. StaffSalaryDAO.java ✅
- Đổi từ `EmployeeType = 'STAFF' AND EmployeeID` → `staff_id`
- Thêm method `getDoctorHourlyRate()` và `updateDoctorHourlyRate()`

### 4. ShiftRequest.java (Model) ✅
- Thêm fields: `staff_id`, `doctor_id`
- Giữ `employeeID` để backward compatibility

### 5. ShiftRequestDAO.java ⚠️ CẦN HOÀN THIỆN
- Đã cập nhật `addRequest()` method
- Cần cập nhật:
  - `getAllRequests()` - đã cập nhật một phần
  - `getById()` - cần cập nhật
  - `getRequestsForStaff()` - cần cập nhật
  - `swapShift()` - cần cập nhật EmployeeID → staff_id/doctor_id
  - `passShift()` - cần cập nhật EmployeeID → staff_id/doctor_id
  - `createPassRequest()` - cần cập nhật
  - `addPassRequest()` - cần cập nhật

## Cần cập nhật thêm:

### ShiftRequestDAO.java - Các method còn lại:
1. `getById()` - cần đọc `staff_id` hoặc `doctor_id` từ ResultSet
2. `getRequestsForStaff()` - cần đọc `staff_id` hoặc `doctor_id` từ ResultSet
3. `swapShift()` - cần đọc `staff_id` hoặc `doctor_id` thay vì `EmployeeID`
4. `passShift()` - cần đọc `staff_id` hoặc `doctor_id` thay vì `EmployeeID`
5. `createPassRequest()` - cần sử dụng `staff_id` hoặc `doctor_id`
6. `addPassRequest()` - cần sử dụng `staff_id` hoặc `doctor_id`

### Controllers cần kiểm tra:
- `DoctorScheduleController.java` - sử dụng `setEmployeeID()`
- `AdminApproveShiftRequestController.java` - sử dụng `getEmployeeID()`

### JSP files:
- `web/admin/manageRequest.jsp` - hiển thị `${r.employeeID}`

## Lưu ý:
- Tất cả các bảng đã được migrate: `AttendanceRecords`, `PayrollRecords`, `StaffSalary`, `ShiftRequests`
- Pattern: Mỗi record chỉ thuộc Doctor HOẶC Staff (không được cả hai)
- Cột `EmployeeID` trong `ShiftRequests` đã được đổi thành `staff_id`
- Cần cập nhật code để hỗ trợ cả `staff_id` và `doctor_id`



