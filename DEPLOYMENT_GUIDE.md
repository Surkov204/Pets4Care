# 🚀 Hướng Dẫn Deploy Pets4Care

## Vấn đề đã sửa
✅ **Lỗi copyfiles task** - Đã sửa trong `build-impl.xml`  
✅ **Thiếu file index.jsp** - Đã tạo file redirect đến `/home`  
✅ **Build thành công** - WAR file đã được tạo (55MB)

## Cách Deploy

### Phương pháp 1: Sử dụng Ant (Khuyến nghị)
```bash
# Deploy với mật khẩu Tomcat
ant run -Dtomcat.password=your_tomcat_password

# Hoặc nếu không có mật khẩu, sử dụng deploy thủ công
```

### Phương pháp 2: Deploy thủ công
1. **Copy WAR file vào webapps:**
   ```bash
   copy dist\Pets4Care.war C:\apache-tomcat\webapps\
   ```

2. **Khởi động Tomcat:**
   ```bash
   C:\apache-tomcat\bin\startup.bat
   ```

3. **Truy cập ứng dụng:**
   ```
   http://localhost:8080/Pets4Care/
   ```

## Kiểm tra Deploy thành công

### 1. Kiểm tra Tomcat Manager
- Truy cập: `http://localhost:8080/manager/html`
- Tìm ứng dụng `Pets4Care` trong danh sách

### 2. Kiểm tra Logs
- Xem log trong: `C:\apache-tomcat\logs\catalina.out`
- Tìm dòng: `Deployment of web application archive [Pets4Care.war] has finished`

### 3. Test các URL chính
- **Trang chủ:** `http://localhost:8080/Pets4Care/`
- **Home:** `http://localhost:8080/Pets4Care/home`
- **Login:** `http://localhost:8080/Pets4Care/login`
- **Register:** `http://localhost:8080/Pets4Care/register`

## Cấu trúc URL của ứng dụng

| Chức năng | URL |
|-----------|-----|
| Trang chủ | `/Pets4Care/` → redirect to `/home` |
| Home | `/Pets4Care/home` |
| Login | `/Pets4Care/login` |
| Register | `/Pets4Care/register` |
| Logout | `/Pets4Care/logout` |
| Cart | `/Pets4Care/cartservlet` |
| Spa Service | `/Pets4Care/spa-service` |
| Spa Cart | `/Pets4Care/spa-cart` |
| Boarding Room | `/Pets4Care/boarding-room` |
| Admin Orders | `/Pets4Care/admin/manage-order` |

## Troubleshooting

### Lỗi 404 - Resource not available
**Nguyên nhân:** Thiếu file index.jsp hoặc context path sai  
**Giải pháp:** 
1. Kiểm tra file `index.jsp` có trong WAR
2. Kiểm tra context path trong Tomcat manager
3. Restart Tomcat

### Lỗi 500 - Internal Server Error
**Nguyên nhân:** Lỗi database connection hoặc missing libraries  
**Giải pháp:**
1. Kiểm tra database connection
2. Kiểm tra file `DBConnection.java`
3. Xem log trong `catalina.out`

### Lỗi ClassNotFoundException
**Nguyên nhân:** Missing JAR files  
**Giải pháp:**
1. Kiểm tra thư mục `WEB-INF/lib` trong WAR
2. Rebuild project: `ant clean && ant dist`

## Cấu hình Database

Đảm bảo database đã được cấu hình đúng trong `DBConnection.java`:
```java
// Kiểm tra connection string
String url = "jdbc:sqlserver://localhost:1433;databaseName=SHOP_PET_Database";
String username = "your_username";
String password = "your_password";
```

## Monitoring

### Kiểm tra trạng thái ứng dụng
```bash
# Kiểm tra process Tomcat
tasklist | findstr java

# Kiểm tra port 8080
netstat -an | findstr 8080
```

### Log files quan trọng
- `catalina.out` - Log chính của Tomcat
- `localhost.log` - Log của ứng dụng
- `manager.log` - Log của Tomcat Manager

## Rollback (Nếu cần)

Nếu deploy bị lỗi:
1. **Undeploy ứng dụng:**
   - Vào Tomcat Manager
   - Click "Undeploy" cho Pets4Care

2. **Deploy lại:**
   ```bash
   ant clean
   ant dist
   ant run -Dtomcat.password=your_password
   ```

---
**Lưu ý:** Luôn backup database trước khi deploy phiên bản mới!





