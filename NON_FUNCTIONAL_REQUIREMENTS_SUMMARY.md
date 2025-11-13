# YÊU CẦU PHI CHỨC NĂNG - PETS4CARE
## Tóm tắt cho thuyết trình

---

## 1. BẢO MẬT (SECURITY)

✅ **Xác thực & Phân quyền**
- Session management (HttpSession)
- Hỗ trợ 4 roles: Customer, Staff, Admin, Doctor
- Auto-login với cookie (Remember Me)
- Google OAuth integration

✅ **Bảo vệ dữ liệu**
- SQL Injection prevention (PreparedStatement)
- Input validation
- PayOS payment security (HMAC-SHA256 signature)

⚠️ **Cần cải thiện**: Mã hóa mật khẩu (hiện tại plain text)

---

## 2. XỬ LÝ LỖI (ERROR HANDLING)

✅ **Exception Handling**
- Try-catch blocks trong toàn bộ ứng dụng
- Error page chuyên dụng với UI thân thiện
- Database error handling chi tiết

✅ **Logging**
- Java Logger cho các sự kiện quan trọng
- Console logging cho debugging
- Log levels: INFO, WARNING, SEVERE

---

## 3. HIỆU NĂNG (PERFORMANCE)

✅ **Database Connection**
- Connection management utility
- Database initialization listener

✅ **Timeout Configuration**
- HTTP request timeout (30s)
- Tránh request bị treo

⚠️ **Cần cải thiện**: Connection pooling (hiện tại mỗi request tạo connection mới)

---

## 4. KIẾN TRÚC (ARCHITECTURE)

✅ **MVC Pattern**
- Controller (96 files): Xử lý HTTP requests
- Service (24 files): Business logic
- DAO (42 files): Data access layer
- Model (30 files): Data entities

✅ **Separation of Concerns**
- Utils classes cho chức năng chung
- Filter cho cross-cutting concerns
- Listener cho lifecycle events

---

## 5. CẤU HÌNH (CONFIGURATION)

✅ **Configuration Management**
- PayOS config (PayOSConfig.java)
- Properties files (payos.properties)
- Web.xml cho servlet mapping
- Context.xml cho Tomcat

⚠️ **Cần cải thiện**: Chuyển hardcoded credentials sang environment variables

---

## 6. TÍNH KHẢ DỤNG (AVAILABILITY)

✅ **Fallback Mechanisms**
- PayOS fallback URL
- Error recovery strategies

✅ **Auto Initialization**
- Database schema auto-init
- Service initialization trong servlet init()

---

## 7. TÍNH TIN CẬY (RELIABILITY)

✅ **Data Validation**
- Input validation trong servlets
- Form validation

✅ **Email Service**
- Gửi email xác nhận đơn hàng
- Gửi OTP (forgot password, đăng ký)
- Gửi biên lai hoàn tiền
- Error handling cho email failures

⚠️ **Cần cải thiện**: Transaction management cho data consistency

---

## 8. TÍNH TƯƠNG THÍCH (COMPATIBILITY)

✅ **Web Standards**
- Jakarta EE (migration từ Java EE)
- UTF-8 encoding cho tiếng Việt
- Responsive design (Tailwind CSS)

✅ **Database**
- Microsoft SQL Server support
- Encrypted connection options

---

## 9. MONITORING & DEBUGGING

✅ **Logging System**
- Comprehensive logging (INFO, WARNING, SEVERE)
- Console output cho debugging

✅ **Debug Support**
- Debug pages (debug-boarding.jsp, debug-payos.jsp)
- Test pages (test-webhook.jsp, test-payos.jsp)

---

## 10. DEPLOYMENT

✅ **Build & Deploy**
- Ant build scripts (build.xml)
- Batch scripts (build-test.bat, deploy.bat)
- PowerShell scripts

✅ **Database Scripts**
- Migration scripts trong Database/
- Scripts cho tạo bảng, insert data, update constraints

---

## 📊 THỐNG KÊ

- **Controllers**: 96 files
- **DAOs**: 42 files  
- **Services**: 24 files
- **Models**: 30 files
- **Utils**: 7 files
- **Exception Handling**: 1009+ try-catch blocks
- **Database Operations**: 927+ PreparedStatement usages
- **Session Management**: 1009+ session usages

---

## ⚠️ ĐIỂM CẦN CẢI THIỆN

### 🔴 Ưu tiên cao:
1. Mã hóa mật khẩu (BCrypt/Argon2)
2. Connection pooling
3. Chuyển credentials sang environment variables
4. Transaction management

### 🟡 Ưu tiên trung bình:
1. Caching strategy
2. Error monitoring service
3. API rate limiting
4. XSS protection

---

**Tóm tắt**: Dự án có nền tảng tốt về bảo mật, xử lý lỗi, và kiến trúc. Cần cải thiện về performance (connection pooling) và security (mã hóa mật khẩu, credentials management).

---

## Phần bổ sung mở rộng (tham chiếu ISO 25010 / FURPS+)

- Hiệu năng (Performance)
  - Mục tiêu: P95 < 1.5s cho trang chủ/chi tiết dịch vụ; P95 < 2.5s cho quy trình đặt lịch/thanh toán.
  - Năng lực: 500 concurrent users, 50 RPS bền vững; scale-out theo session.
  - Cần làm: Connection pooling (JNDI/HikariCP), query index, pagination, HTTP/2 + gzip/brotli, image optimization/CDN, caching (service list, categories), batch/bulk operations.

- Độ tin cậy (Reliability)
  - Mục tiêu: 99.5% availability (M/M); MTTR < 30 phút.
  - Hiện có: Error page, logging, PayOS fallback, DB auto-init.
  - Cần làm: Transaction management, retry/backoff, circuit breaker, idempotency keys (webhook/payment), scheduled backups + restore drills, graceful shutdown.

- Khả dụng/Khôi phục thảm họa (Availability/DR)
  - Mục tiêu RPO ≤ 15 phút, RTO ≤ 60 phút.
  - Cần làm: Automated backups, offsite replication, runbook DR, chaos testing mức giới hạn.

- Khả năng mở rộng (Scalability)
  - Mục tiêu: Scale tuyến tính tới 3× lưu lượng.
  - Cần làm: Stateless controllers, session store chia sẻ (nếu cần), tách read/write DB, job queue cho tác vụ dài (email/billing), tách service theo domain.

- Bảo mật (Security)
  - Mục tiêu: Không lưu plaintext password; bảo vệ dữ liệu nhạy cảm.
  - Cần làm: BCrypt/Argon2, CSRF/XSS protection, secret management (ENV/keystore), TLS mọi tầng, hạn chế rate/anti-bruteforce, audit log (login, thanh toán, thay đổi dữ liệu).

- Riêng tư & Tuân thủ (Privacy/Compliance)
  - Mục tiêu: Tối thiểu-hóa dữ liệu; xóa/sửa theo yêu cầu người dùng.
  - Cần làm: Data retention policy, masking trong log, consent cho email/marketing, quyền truy cập data theo role.

- Quan sát được (Observability)
  - Mục tiêu: Trace 100% giao dịch thanh toán/đặt lịch.
  - Cần làm: Structured logging, metrics (latency, error rate, throughput), health endpoints (/health, /ready), tracing (request ID), alerting theo SLO.

- Khả năng vận hành (Operability)
  - Mục tiêu: Zero-downtime deploy cho cập nhật nhỏ.
  - Cần làm: Pipeline CI/CD, feature flags, toggle cấu hình runtime, log rotation, định nghĩa runbook sự cố.

- Khả năng bảo trì (Maintainability)
  - Mục tiêu: PR < 500 dòng; cyclomatic complexity kiểm soát.
  - Cần làm: Module hóa service/DAO, chuẩn logging, code style/lint, unit/integration tests, tài liệu runbook/config.

- Tính tương thích & Di động (Compatibility/Portability)
  - Mục tiêu: Chạy trên Tomcat chuẩn, SQL Server 2019+.
  - Cần làm: Tách cấu hình qua ENV/props, không hardcode đường dẫn/secret, script bootstrap môi trường.

- Khả năng sử dụng & Truy cập (Usability/Accessibility)
  - Mục tiêu: Hỗ trợ mobile-first, đọc tốt tiếng Việt UTF-8.
  - Cần làm: Kiểm tra contrast, keyboard nav cơ bản, validation rõ ràng, thông báo lỗi thân thiện.

- Chất lượng dữ liệu (Data Quality)
  - Mục tiêu: Tính nhất quán booking/payment.
  - Cần làm: Ràng buộc DB (FK, check), validation server-side, idempotency khi ghi dữ liệu, reconcile định kỳ.

- Công suất & Dung lượng (Capacity)
  - Mục tiêu: DB < 50GB năm 1; log lưu 14–30 ngày.
  - Cần làm: Retention chính sách, partition/archiving nếu cần, quota cho upload/assets.

- Hỗ trợ & Bảo hành (Supportability)
  - Mục tiêu: SLA phản hồi sự cố 4 giờ làm việc.
  - Cần làm: Kênh hỗ trợ, mẫu báo cáo sự cố, dashboard health, nhật ký thay đổi (CHANGELOG).

