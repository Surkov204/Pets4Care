@echo off
echo ========================================
echo      DEPLOY PETS4CARE APPLICATION
echo ========================================
echo.

REM Kiem tra Tomcat password
if "%1"=="" (
    echo LOI: Vui long cung cap mat khau Tomcat
    echo Cu phap: deploy.bat your_tomcat_password
    echo.
    echo Hoac chay deploy thu cong:
    echo 1. Copy dist\Pets4Care.war vao C:\apache-tomcat\webapps\
    echo 2. Khoi dong Tomcat: C:\apache-tomcat\bin\startup.bat
    echo 3. Truy cap: http://localhost:8080/Pets4Care/
    pause
    exit /b 1
)

set TOMCAT_PASSWORD=%1

echo Dang build project...
call ant clean
if %errorlevel% neq 0 (
    echo LOI: Clean failed
    pause
    exit /b 1
)

call ant dist
if %errorlevel% neq 0 (
    echo LOI: Build failed
    pause
    exit /b 1
)

echo.
echo Dang deploy len Tomcat...
call ant run -Dtomcat.password=%TOMCAT_PASSWORD%
if %errorlevel% neq 0 (
    echo LOI: Deploy failed
    echo Thu lai voi phuong phap thu cong:
    echo 1. Copy dist\Pets4Care.war vao C:\apache-tomcat\webapps\
    echo 2. Khoi dong Tomcat
    pause
    exit /b 1
)

echo.
echo ========================================
echo        DEPLOY THANH CONG!
echo ========================================
echo.
echo Ung dung da duoc deploy tai:
echo http://localhost:8080/Pets4Care/
echo.
echo Cac URL chinh:
echo - Trang chu: http://localhost:8080/Pets4Care/
echo - Home: http://localhost:8080/Pets4Care/home
echo - Login: http://localhost:8080/Pets4Care/login
echo - Register: http://localhost:8080/Pets4Care/register
echo.

REM Mo browser
start http://localhost:8080/Pets4Care/

pause





