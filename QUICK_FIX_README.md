# 🚀 Sửa Lỗi NetBeans Deploy Nhanh

## Lỗi gặp phải
```
Problem: failed to create task or type copyfiles
Cause: The name is undefined.
```

## Cách sửa nhanh (2 phút)

### Phương pháp 1: Chạy script tự động
```bash
# Chạy file fix_copyfiles.bat
fix_copyfiles.bat
```

### Phương pháp 2: Sửa thủ công
1. Mở file `nbproject/build-impl.xml`
2. Tìm và thay thế tất cả:
   - `copyfiles` → `copy`
   - Thêm `failonerror="false"` vào mỗi task copy
3. Lưu file

### Phương pháp 3: Sử dụng PowerShell
```powershell
# Backup file
Copy-Item "nbproject\build-impl.xml" "nbproject\build-impl.xml.backup"

# Thay thế copyfiles
(Get-Content 'nbproject\build-impl.xml') -replace '<copyfiles files="([^"]+)" iftldtodir="[^"]+" todir="([^"]+)"/>', '<copy file="$1" todir="$2" failonerror="false"/>' | Set-Content 'nbproject\build-impl.xml'

(Get-Content 'nbproject\build-impl.xml') -replace '<copyfiles files="([^"]+)" todir="([^"]+)"/>', '<copy file="$1" todir="$2" failonerror="false"/>' | Set-Content 'nbproject\build-impl.xml'
```

## Kiểm tra kết quả
```bash
ant clean
ant compile
ant dist
```

## Deploy
```bash
ant run -Dtomcat.password=your_password
```

---
**Chi tiết đầy đủ:** Xem file `BUILD_FIX_LOG.md`





