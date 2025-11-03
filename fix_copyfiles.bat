@echo off
echo ========================================
echo    SUA LOI COPYFILES TRONG NETBEANS
echo ========================================
echo.

REM Kiem tra file build-impl.xml co ton tai khong
if not exist "nbproject\build-impl.xml" (
    echo LOI: Khong tim thay file nbproject\build-impl.xml
    echo Vui long chay script nay trong thu muc goc cua project
    pause
    exit /b 1
)

echo Dang backup file goc...
if not exist "nbproject\build-impl.xml.backup" (
    copy "nbproject\build-impl.xml" "nbproject\build-impl.xml.backup"
    echo Da backup thanh cong!
) else (
    echo File backup da ton tai, bo qua...
)

echo.
echo Dang sua loi copyfiles...

REM Thay the copyfiles trong target library-inclusion-in-manifest
echo - Sua target library-inclusion-in-manifest...
powershell -Command "(Get-Content 'nbproject\build-impl.xml') -replace '<copyfiles files=\"([^\"]+)\" iftldtodir=\"[^\"]+\" todir=\"([^\"]+)\"/>', '<copy file=\"$1\" todir=\"$2\" failonerror=\"false\"/>' | Set-Content 'nbproject\build-impl.xml'"

REM Thay the copyfiles trong target library-inclusion-in-archive
echo - Sua target library-inclusion-in-archive...
powershell -Command "(Get-Content 'nbproject\build-impl.xml') -replace '<copyfiles files=\"([^\"]+)\" todir=\"([^\"]+)\"/>', '<copy file=\"$1\" todir=\"$2\" failonerror=\"false\"/>' | Set-Content 'nbproject\build-impl.xml'"

echo.
echo ========================================
echo           DA SUA XONG!
echo ========================================
echo.

REM Kiem tra ket qua
echo Dang kiem tra ket qua...
findstr /n "copyfiles" "nbproject\build-impl.xml" >nul
if %errorlevel% == 0 (
    echo CANH BAO: Van con task copyfiles trong file!
    echo Vui long kiem tra lai thu cong.
) else (
    echo OK: Da thay the het task copyfiles.
)

echo.
echo Cac buoc tiep theo:
echo 1. Chay: ant clean
echo 2. Chay: ant compile  
echo 3. Chay: ant dist
echo 4. Deploy: ant run -Dtomcat.password=your_password
echo.

pause





