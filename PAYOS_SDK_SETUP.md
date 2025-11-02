# Hướng dẫn cài đặt PayOS SDK cho NetBeans Ant Project

## 📦 Bước 1: Tải các JAR files

### 1.1. PayOS Java SDK (Required)
- **Download từ Maven Central:**
  - Link: https://central.sonatype.com/artifact/vn.payos/payos
  - Version mới nhất: `2.1.0` (hoặc cao hơn)
  - File cần tải: `payos-2.1.0.jar`

**Cách tải:**
1. Vào link: https://central.sonatype.com/artifact/vn.payos/payos
2. Chọn tab "Versions"
3. Click vào version mới nhất
4. Click "Browse" → Download file `.jar`

### 1.2. Jackson Databind (Required - để parse JSON)
- Link: https://central.sonatype.com/artifact/com.fasterxml.jackson.core/jackson-databind
- Version: `2.15.0` trở lên
- File: `jackson-databind-2.15.0.jar`

### 1.3. Jackson Core (Required)
- Link: https://central.sonatype.com/artifact/com.fasterxml.jackson.core/jackson-core
- Version: `2.15.0`
- File: `jackson-core-2.15.0.jar`

### 1.4. Jackson Annotations (Required)
- Link: https://central.sonatype.com/artifact/com.fasterxml.jackson.core/jackson-annotations
- Version: `2.15.0`
- File: `jackson-annotations-2.15.0.jar`

## 📂 Bước 2: Thêm JAR vào project

1. Copy tất cả 4 files JAR vào thư mục:
   ```
   d:\SWP391\Pets4Care_tranhongson\Pets4Care\lib\
   ```

2. Trong NetBeans:
   - Right-click vào project "Pets4Care"
   - Chọn "Properties"
   - Chọn "Libraries" → "Compile" tab
   - Click "Add JAR/Folder"
   - Chọn tất cả 4 JAR files vừa copy
   - Click "OK"

## ✅ Bước 3: Verify cài đặt

Restart NetBeans và build project:
```
Clean and Build
```

Nếu không có lỗi compile → SDK đã cài đặt thành công!

## 🔄 Phương án thay thế: Download tự động

Nếu bạn muốn, có thể chuyển sang Maven để tự động quản lý dependencies:

```xml
<dependency>
    <groupId>vn.payos</groupId>
    <artifactId>payos</artifactId>
    <version>2.1.0</version>
</dependency>
```

Nhưng điều này yêu cầu convert project từ Ant sang Maven.
