Pets4Care - NetBeans 17 + JDK 21 + Tomcat 10.1

## Yêu cầu
- JDK 21
- Apache Tomcat 10.1.x (Servlet 6 / Jakarta EE 10)
- NetBeans 17 (hoặc 21)

## Thiết lập nhanh (Ant project + Maven WAR)
Repo gốc là Ant project. Đã bổ sung pom.xml để có thể build bằng Maven ra WAR.

### Chạy bằng NetBeans
1) Mở Project trong NetBeans
2) Project → Properties:
   - Java Platform: chọn JDK 21
   - Run/Server: Add → Tomcat 10.1 (điền đường dẫn cài Tomcat)
3) Clean and Build (Ant hoặc Maven đều được)
4) Run/Deploy lên Tomcat từ NetBeans

### Build bằng Maven (tùy chọn)
```bash
mvn clean package
```
WAR ở target/Pets4Care.war. Copy vào tomcat/webapps/ hoặc cấu hình NetBeans dùng Maven.

## Các cập nhật tương thích Jakarta EE 10
- JSTL trong JSP dùng URI mới: jakarta.tags.core, jakarta.tags.fmt, jakarta.tags.functions
- Dependencies chính (trong pom.xml):
  - jakarta.servlet-api (provided)
  - jakarta.servlet.jsp.jstl
  - jakarta.mail, jakarta.activation
  - gson, jbcrypt, mssql-jdbc
- Tắt tự kết nối DB lúc startup: đã comment @WebListener trong src/java/listener/DBConnectionListener.java
- Bổ sung @WebServlet:
  - SpaBookingServlet → /spa-booking, /spa-cart
  - SpaServiceServlet → /spa-service

## Cấu hình CSDL (SQL Server)
- Driver: com.microsoft.sqlserver.jdbc.SQLServerDriver
- Mặc định trong mã nguồn (utils/DBConnection.java):
  - URL: jdbc:sqlserver://localhost:1433;databaseName=SHOP_PET_Database;encrypt=false;trustServerCertificate=true
  - User/Pass: sa / 12345 (hãy đổi theo máy của bạn)
- Tạo database theo các script trong thư mục Database/ nếu chưa có.

## Email (Gmail SMTP)
- Cập nhật hằng số trong utils/EmailUtils.java bằng App Password hợp lệ, hoặc tắt gửi email khi dev.

## Google OAuth
- Điền CLIENT_ID, CLIENT_SECRET, REDIRECT_URI trong utils/GoogleConstants.java

## Lưu ý khi chạy lần đầu
- Đảm bảo Tomcat 10.1 chạy JDK 21.
- Nếu dùng Ant: Project Properties → Run → Server chọn Tomcat 10.1.
- Nếu dùng Maven: triển khai WAR từ target/.

## Lỗi thường gặp
- JSTL taglib không tìm thấy: dùng URI jakarta.tags.* và có jakarta.servlet.jsp.jstl.
- Lỗi DB: cấu hình lại utils/DBConnection.java, khởi tạo DB từ scripts.
- Lỗi mail: cập nhật EmailUtils.java hoặc vô hiệu hoá khi dev.


