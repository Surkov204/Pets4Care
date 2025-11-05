@echo off
setlocal enabledelayedexpansion
echo Testing build process...

REM Create build directories
if not exist "build\web\WEB-INF\classes" mkdir "build\web\WEB-INF\classes"
if not exist "build\web\WEB-INF\lib" mkdir "build\web\WEB-INF\lib"
if not exist "dist" mkdir "dist"

REM Copy web resources
echo Copying web resources...
xcopy /E /I /Y "web\*" "build\web\"

REM Copy JAR files
echo Copying JAR files...
copy /Y "lib\*.jar" "build\web\WEB-INF\lib\"

REM Create WAR file
echo Creating WAR file...
cd build\web
jar -cf "..\..\dist\Pets4Care.war" *
cd ..\..

echo Build test completed!
echo WAR file created: dist\Pets4Care.war

