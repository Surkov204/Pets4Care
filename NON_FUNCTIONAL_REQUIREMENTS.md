# DANH SÁCH CÁC YÊU CẦU PHI CHỨC NĂNG (NON-FUNCTIONAL REQUIREMENTS)
## Dự án: Pets4Care

---

## 1. BẢO MẬT (SECURITY)

### 1.1. Xác thực và Phân quyền
- ✅ **Session Management**: Sử dụng HttpSession để quản lý phiên đăng nhập
  - Lưu thông tin user trong session (`currentUser`, `role`, `userId`)
  - Hỗ trợ nhiều role: Customer, Staff, Admin, Doctor
  - File: `LoginServlet.java`, các Controller khác

- ✅ **Auto-Login Filter**: Filter tự động đăng nhập từ cookie
  - Lưu thông tin đăng nhập trong cookie (`remembered_email`, `remembered_password`)
  - Bỏ qua auto-login sau khi logout (`justLoggedOut` cookie)
  - File: `AutoLoginFilter.java`

- ✅ **Google OAuth Integration**: Đăng nhập qua Google
  - File: `GoogleLoginServlet.java`, `GoogleUtils.java`, `GoogleConstants.java`

- ⚠️ **Mật khẩu**: Hiện tại lưu plain text (không mã hóa)
  - File: `PasswordUtil.java` - cần cải thiện để hash password

### 1.2. Bảo vệ dữ liệu
- ✅ **SQL Injection Prevention**: Sử dụng PreparedStatement trong các DAO
  - Tìm thấy 927 matches của PreparedStatement/Statement/ResultSet
  - Các DAO đều sử dụng parameterized queries

- ✅ **Input Validation**: Kiểm tra input trước khi xử lý
  - Validation email/password trong `LoginServlet.java`
  - Validation trong các form đăng ký, đặt lịch

### 1.3. Bảo mật thanh toán
- ✅ **PayOS Integration**: Tích hợp PayOS với checksum verification
  - HMAC-SHA256 signature verification
  - File: `PayOSUtils.java`, `PayOSConfig.java`, `PayOSService.java`
  - Webhook verification để xác thực callback từ PayOS

---

## 2. XỬ LÝ LỖI (ERROR HANDLING)

### 2.1. Exception Handling
- ✅ **Try-Catch Blocks**: Xử lý exception trong toàn bộ ứng dụng
  - Tìm thấy 1009 matches của try/catch/throws/Exception
  - Các Servlet đều có error handling

- ✅ **Error Page**: Trang lỗi chuyên dụng
  - File: `web/error.jsp`
  - Hiển thị thông tin lỗi chi tiết trong môi trường development
  - Cung cấp các nút điều hướng (về trang chủ, quay lại, liên hệ hỗ trợ)

- ✅ **Database Error Handling**: Xử lý lỗi kết nối database
  - File: `DBConnection.java` - có logging chi tiết lỗi SQL
  - Hiển thị thông báo lỗi cụ thể (authentication failed, connection error)

### 2.2. Logging
- ✅ **Java Logger**: Sử dụng `java.util.logging.Logger`
  - Tìm thấy 20+ files sử dụng Logger
  - Log các sự kiện quan trọng: login attempts, errors, database operations
  - File: `SpaBookingServlet.java`, `LoginServlet.java`, `DBConnection.java`, v.v.

- ✅ **Console Logging**: Sử dụng System.out.println/System.err.println
  - Logging cho debugging và monitoring
  - Log các bước quan trọng trong quy trình (PayOS requests, email sending)

---

## 3. HIỆU NĂNG (PERFORMANCE)

### 3.1. Database Connection
- ✅ **Connection Management**: Quản lý kết nối database
  - File: `DBConnection.java` - utility class để tạo connection
  - File: `DBConnectionListener.java` - listener để khởi tạo connection khi app start

- ⚠️ **Connection Pooling**: Chưa thấy sử dụng connection pooling
  - Hiện tại mỗi request tạo connection mới
  - Nên cải thiện bằng DataSource/JNDI hoặc HikariCP

### 3.2. Timeout Configuration
- ✅ **HTTP Timeout**: Cấu hình timeout cho HTTP requests
  - File: `PayOSUtils.java` - setConnectTimeout(30000), setReadTimeout(30000)
  - Tránh request bị treo

### 3.3. Caching
- ⚠️ **No Caching Strategy**: Chưa thấy implementation caching
  - Có thể cải thiện bằng cache cho static data (danh sách dịch vụ, sản phẩm)

---

## 4. KHẢ NĂNG MỞ RỘNG (SCALABILITY)

### 4.1. Architecture
- ✅ **MVC Pattern**: Tách biệt Controller, Service, DAO, Model
  - Controller: xử lý HTTP requests
  - Service: business logic
  - DAO: data access layer
  - Model: data entities

- ✅ **Separation of Concerns**: Code được tổ chức tốt
  - Utils classes cho các chức năng chung
  - Filter cho cross-cutting concerns

### 4.2. Stateless Design
- ✅ **Session-based State**: Sử dụng session để quản lý state
  - Tìm thấy 1009 matches của session/Session/HttpSession
  - Phù hợp cho horizontal scaling

---

## 5. KHẢ NĂNG BẢO TRÌ (MAINTAINABILITY)

### 5.1. Code Organization
- ✅ **Package Structure**: Tổ chức code theo package rõ ràng
  - `controller/`: 96 files
  - `dao/`: 42 files
  - `service/`: 24 files
  - `model/`: 30 files
  - `utils/`: 7 files
  - `filter/`: 1 file
  - `listener/`: 1 file

### 5.2. Configuration Management
- ✅ **Configuration Files**: Tách cấu hình ra file riêng
  - `PayOSConfig.java`: Cấu hình PayOS (client ID, API key, checksum key)
  - `payos.properties`: Properties file cho PayOS
  - `context.xml`: Cấu hình Tomcat context
  - `web.xml`: Servlet configuration

- ⚠️ **Hardcoded Values**: Một số giá trị vẫn hardcode
  - Database credentials trong `DBConnection.java`
  - Email credentials trong `EmailUtils.java`
  - Nên chuyển sang properties file hoặc environment variables

### 5.3. Documentation
- ✅ **Documentation Files**: Có nhiều file hướng dẫn
  - `DEPLOYMENT_GUIDE.md`
  - `PAYOS_COMPLETE_GUIDE.md`
  - `WEBHOOK_TEST_GUIDE.md`
  - `DEBUG_INSTRUCTIONS.md`
  - Và nhiều file markdown khác

---

## 6. KHẢ NĂNG SỬ DỤNG (USABILITY)

### 6.1. User Experience
- ✅ **Error Messages**: Thông báo lỗi rõ ràng bằng tiếng Việt
  - Error page có giao diện đẹp, thân thiện
  - Các thông báo lỗi trong form validation

- ✅ **Responsive Design**: Sử dụng Tailwind CSS
  - File: `error.jsp` sử dụng Tailwind CSS
  - Responsive với mobile-first approach

### 6.2. Internationalization
- ✅ **UTF-8 Encoding**: Hỗ trợ tiếng Việt
  - Email content với UTF-8 encoding
  - JSP pages với charset UTF-8
  - `MimeUtility.encodeText()` cho email subject

---

## 7. TÍNH KHẢ DỤNG (AVAILABILITY)

### 7.1. Error Recovery
- ✅ **Fallback Mechanisms**: Có fallback cho PayOS
  - File: `PayOSConfig.java` - có BASE_URL_PRIMARY và BASE_URL_FALLBACK
  - Có thể switch giữa các endpoint

### 7.2. Database Initialization
- ✅ **Auto Initialization**: Tự động khởi tạo database schema
  - File: `BoardingBookingDAO.java` - có `initializeDatabase()` method
  - File: `SpaBookingServlet.java` - gọi initialization trong `init()`

---

## 8. TÍNH TIN CẬY (RELIABILITY)

### 8.1. Transaction Management
- ⚠️ **Transaction Handling**: Chưa thấy explicit transaction management
  - Các DAO operations có thể cần transaction cho data consistency
  - Nên sử dụng `Connection.setAutoCommit(false)` cho multi-step operations

### 8.2. Data Validation
- ✅ **Input Validation**: Kiểm tra dữ liệu đầu vào
  - Validation trong servlets trước khi xử lý
  - File: `LoginServlet.java` - validate email/password không rỗng

### 8.3. Email Service
- ✅ **Email Integration**: Gửi email xác nhận, OTP
  - File: `EmailUtils.java`
  - Gửi email xác nhận đơn hàng
  - Gửi OTP cho forgot password và đăng ký
  - Gửi biên lai hoàn tiền
  - Error handling cho email failures

---

## 9. TÍNH TƯƠNG THÍCH (COMPATIBILITY)

### 9.1. Web Standards
- ✅ **Jakarta EE**: Sử dụng Jakarta EE (migration từ Java EE)
  - `jakarta.servlet.*` packages
  - `jakarta.mail.*` packages
  - `jakarta.servlet.annotation.WebFilter`, `@WebListener`

### 9.2. Database
- ✅ **SQL Server**: Hỗ trợ Microsoft SQL Server
  - Driver: `com.microsoft.sqlserver.jdbc.SQLServerDriver`
  - Connection string với các options: encrypt, trustServerCertificate

---

## 10. TÍNH BẢO MẬT DỮ LIỆU (DATA SECURITY)

### 10.1. Sensitive Data
- ⚠️ **Credentials Storage**: Một số credentials hardcode trong code
  - Database password trong `DBConnection.java`
  - Email password trong `EmailUtils.java`
  - PayOS credentials trong `PayOSConfig.java`
  - **Khuyến nghị**: Chuyển sang environment variables hoặc encrypted properties

### 10.2. Data Encryption
- ✅ **HTTPS Support**: Cấu hình cho HTTPS (qua web server)
- ✅ **Email Encryption**: Sử dụng STARTTLS cho email
  - File: `EmailUtils.java` - `mail.smtp.starttls.enable = true`

---

## 11. MONITORING & OBSERVABILITY

### 11.1. Logging
- ✅ **Comprehensive Logging**: Logging ở nhiều levels
  - INFO: successful operations
  - WARNING: failed login attempts
  - SEVERE: errors và exceptions
  - Console output cho debugging

### 11.2. Debugging Support
- ✅ **Debug Pages**: Có các trang debug
  - `debug-boarding.jsp`
  - `debug-payos.jsp`
  - `test-webhook.jsp`
  - `test-payos.jsp`

---

## 12. DEPLOYMENT & OPERATIONS

### 12.1. Build & Deploy
- ✅ **Build Scripts**: Có các script build và deploy
  - `build.xml`: Ant build script
  - `build-test.bat`, `deploy.bat`, `deploy-test.bat`
  - `fix_copyfiles.bat`, `fix_copyfiles.ps1`

### 12.2. Database Scripts
- ✅ **Database Scripts**: Có nhiều SQL scripts
  - `Database/` folder với các migration scripts
  - Scripts cho tạo bảng, insert data, update constraints

---

## TÓM TẮT CÁC ĐIỂM CẦN CẢI THIỆN

### 🔴 Ưu tiên cao:
1. **Mã hóa mật khẩu**: Hiện tại lưu plain text - cần hash (BCrypt, Argon2)
2. **Connection Pooling**: Cần implement để cải thiện performance
3. **Credentials Management**: Chuyển hardcoded credentials sang environment variables
4. **Transaction Management**: Cần explicit transaction cho data consistency

### 🟡 Ưu tiên trung bình:
1. **Caching Strategy**: Implement cache cho static data
2. **Error Monitoring**: Tích hợp error tracking service (Sentry, Log4j2)
3. **API Rate Limiting**: Bảo vệ API endpoints khỏi abuse
4. **Input Sanitization**: XSS protection cho user input

### 🟢 Ưu tiên thấp:
1. **Performance Monitoring**: APM tools để monitor performance
2. **Automated Testing**: Unit tests, integration tests
3. **Code Quality**: Static analysis tools (SonarQube)

---

**Ngày tạo**: 2024
**Phiên bản**: 1.0


