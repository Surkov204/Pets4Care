# Script PowerShell để sửa lỗi copyfiles trong NetBeans
# Tác giả: AI Assistant
# Ngày: 26/10/2025

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "    SUA LOI COPYFILES TRONG NETBEANS" -ForegroundColor Cyan  
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Kiểm tra file build-impl.xml có tồn tại không
if (-not (Test-Path "nbproject\build-impl.xml")) {
    Write-Host "LOI: Khong tim thay file nbproject\build-impl.xml" -ForegroundColor Red
    Write-Host "Vui long chay script nay trong thu muc goc cua project" -ForegroundColor Red
    Read-Host "Nhan Enter de thoat"
    exit 1
}

# Backup file gốc
Write-Host "Dang backup file goc..." -ForegroundColor Yellow
if (-not (Test-Path "nbproject\build-impl.xml.backup")) {
    Copy-Item "nbproject\build-impl.xml" "nbproject\build-impl.xml.backup"
    Write-Host "Da backup thanh cong!" -ForegroundColor Green
} else {
    Write-Host "File backup da ton tai, bo qua..." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Dang sua loi copyfiles..." -ForegroundColor Yellow

# Đọc nội dung file
$content = Get-Content "nbproject\build-impl.xml" -Raw

# Thay thế copyfiles trong target library-inclusion-in-manifest
Write-Host "- Sua target library-inclusion-in-manifest..." -ForegroundColor Cyan
$content = $content -replace '<copyfiles files="([^"]+)" iftldtodir="[^"]+" todir="([^"]+)"/>', '<copy file="$1" todir="$2" failonerror="false"/>'

# Thay thế copyfiles trong target library-inclusion-in-archive  
Write-Host "- Sua target library-inclusion-in-archive..." -ForegroundColor Cyan
$content = $content -replace '<copyfiles files="([^"]+)" todir="([^"]+)"/>', '<copy file="$1" todir="$2" failonerror="false"/>'

# Ghi lại file
$content | Set-Content "nbproject\build-impl.xml" -Encoding UTF8

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "           DA SUA XONG!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

# Kiểm tra kết quả
Write-Host "Dang kiem tra ket qua..." -ForegroundColor Yellow
$remainingCopyfiles = Select-String -Path "nbproject\build-impl.xml" -Pattern "copyfiles" -Quiet

if ($remainingCopyfiles) {
    Write-Host "CANH BAO: Van con task copyfiles trong file!" -ForegroundColor Red
    Write-Host "Vui long kiem tra lai thu cong." -ForegroundColor Red
} else {
    Write-Host "OK: Da thay the het task copyfiles." -ForegroundColor Green
}

Write-Host ""
Write-Host "Cac buoc tiep theo:" -ForegroundColor Cyan
Write-Host "1. Chay: ant clean" -ForegroundColor White
Write-Host "2. Chay: ant compile" -ForegroundColor White  
Write-Host "3. Chay: ant dist" -ForegroundColor White
Write-Host "4. Deploy: ant run -Dtomcat.password=your_password" -ForegroundColor White
Write-Host ""

Read-Host "Nhan Enter de thoat"





