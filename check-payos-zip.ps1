# Script để kiểm tra file payos.1.0.61.zip và hướng dẫn các bước tiếp theo

Write-Host "`n🔍 ===== KIỂM TRA PAYOS ZIP FILE =====" -ForegroundColor Cyan
Write-Host ""

# Tìm file zip
$zipFile = Get-ChildItem -Path "." -Filter "payos*.zip" -ErrorAction SilentlyContinue | Select-Object -First 1

if ($null -eq $zipFile) {
    Write-Host "❌ Không tìm thấy file payos*.zip trong thư mục hiện tại" -ForegroundColor Red
    Write-Host ""
    Write-Host "💡 Hướng dẫn:" -ForegroundColor Yellow
    Write-Host "   1. Copy file payos.1.0.61.zip vào thư mục này"
    Write-Host "   2. Chạy lại script này"
    Write-Host ""
    exit 1
}

Write-Host "✅ Tìm thấy file: $($zipFile.Name)" -ForegroundColor Green
Write-Host "   Đường dẫn: $($zipFile.FullName)" -ForegroundColor Gray
Write-Host "   Kích thước: $([math]::Round($zipFile.Length / 1MB, 2)) MB" -ForegroundColor Gray
Write-Host ""

# Tạo thư mục temp để giải nén
$extractPath = Join-Path $PWD "temp_payos_extract"
if (Test-Path $extractPath) {
    Remove-Item $extractPath -Recurse -Force
}
New-Item -ItemType Directory -Path $extractPath | Out-Null

Write-Host "📦 Đang giải nén file zip..." -ForegroundColor Yellow
try {
    Expand-Archive -Path $zipFile.FullName -DestinationPath $extractPath -Force
    Write-Host "✅ Giải nén thành công!" -ForegroundColor Green
    Write-Host ""
} catch {
    Write-Host "❌ Lỗi khi giải nén: $_" -ForegroundColor Red
    exit 1
}

# Kiểm tra nội dung
Write-Host "🔍 Đang kiểm tra nội dung..." -ForegroundColor Yellow
Write-Host ""

# Tìm các file .jar
$jarFiles = Get-ChildItem -Path $extractPath -Filter "*.jar" -Recurse

if ($jarFiles.Count -gt 0) {
    Write-Host "✅ Tìm thấy $($jarFiles.Count) file JAR:" -ForegroundColor Green
    foreach ($jar in $jarFiles) {
        Write-Host "   - $($jar.Name)" -ForegroundColor Cyan
        Write-Host "     Đường dẫn: $($jar.FullName)" -ForegroundColor Gray
        
        # Kiểm tra xem có phải PayOS SDK không
        if ($jar.Name -like "*payos*") {
            Write-Host "     ⭐ Đây là PayOS SDK!" -ForegroundColor Yellow
        }
    }
    Write-Host ""
    
    # Copy vào lib/
    Write-Host "📋 Bước tiếp theo:" -ForegroundColor Yellow
    Write-Host "   1. Copy các file JAR vào thư mục lib/" -ForegroundColor White
    Write-Host "   2. Trong NetBeans: Right-click project → Properties → Libraries → Add JAR/Folder" -ForegroundColor White
    Write-Host "   3. Chọn các file JAR từ lib/" -ForegroundColor White
    Write-Host ""
    
    # Hỏi có muốn copy không
    $copy = Read-Host "Bạn có muốn copy các file JAR vào lib/ không? (Y/N)"
    if ($copy -eq "Y" -or $copy -eq "y") {
        $libPath = Join-Path $PWD "lib"
        if (-not (Test-Path $libPath)) {
            New-Item -ItemType Directory -Path $libPath | Out-Null
        }
        
        foreach ($jar in $jarFiles) {
            $destPath = Join-Path $libPath $jar.Name
            Copy-Item -Path $jar.FullName -Destination $destPath -Force
            Write-Host "   ✅ Đã copy: $($jar.Name)" -ForegroundColor Green
        }
        Write-Host ""
        Write-Host "✅ Đã copy tất cả JAR files vào lib/" -ForegroundColor Green
    }
} else {
    Write-Host "⚠️ Không tìm thấy file JAR nào trong zip" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "💡 File zip này có thể là:" -ForegroundColor Yellow
    Write-Host "   - PHP SDK (cho WooCommerce)" -ForegroundColor White
    Write-Host "   - Tài liệu hướng dẫn" -ForegroundColor White
    Write-Host "   - Không phải Java SDK" -ForegroundColor White
    Write-Host ""
    
    # Liệt kê tất cả files
    $allFiles = Get-ChildItem -Path $extractPath -Recurse | Where-Object { -not $_.PSIsContainer }
    Write-Host "📁 Nội dung file zip:" -ForegroundColor Cyan
    foreach ($file in $allFiles | Select-Object -First 20) {
        $relativePath = $file.FullName.Replace($extractPath, "")
        Write-Host "   $relativePath" -ForegroundColor Gray
    }
    if ($allFiles.Count -gt 20) {
        Write-Host "   ... và $($allFiles.Count - 20) files khác" -ForegroundColor Gray
    }
    Write-Host ""
    
    Write-Host "💡 Bước tiếp theo:" -ForegroundColor Yellow
    Write-Host "   Code hiện tại của bạn đang dùng manual HTTP calls" -ForegroundColor White
    Write-Host "   Đây là cách ĐÚNG và không cần SDK!" -ForegroundColor Green
    Write-Host ""
    Write-Host "   Nếu muốn dùng SDK:" -ForegroundColor Yellow
    Write-Host "   1. Tải từ: https://repo1.maven.org/maven2/vn/payos/payos/" -ForegroundColor White
    Write-Host "   2. Tìm version mới nhất (vd: 2.1.0)" -ForegroundColor White
    Write-Host "   3. Download file payos-2.1.0.jar" -ForegroundColor White
    Write-Host "   4. Copy vào lib/" -ForegroundColor White
}

# Dọn dẹp
Write-Host ""
Write-Host "🧹 Dọn dẹp thư mục temp..." -ForegroundColor Yellow
Remove-Item $extractPath -Recurse -Force -ErrorAction SilentlyContinue
Write-Host "✅ Hoàn tất!" -ForegroundColor Green
Write-Host ""
Write-Host "📚 Xem hướng dẫn chi tiết trong: PAYOS_NEXT_STEPS.md" -ForegroundColor Cyan
Write-Host ""

