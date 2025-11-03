@echo off
echo Searching for Ant...

REM Try to find Ant in common locations
set ANT_PATHS=C:\Program Files\NetBeans-21\netbeans\ext\ant\bin\ant.bat;C:\Program Files\Apache\ant\bin\ant.bat;C:\apache-ant\bin\ant.bat;C:\ant\bin\ant.bat

for %%p in (%ANT_PATHS%) do (
    if exist "%%p" (
        echo Found Ant at: %%p
        "%%p" -f build.xml %*
        goto :end
    )
)

echo Ant not found in common locations. Trying to run with 'ant' command...
ant -f build.xml %*
if %ERRORLEVEL% neq 0 (
    echo Error: Ant not found. Please install Apache Ant or add it to PATH.
    echo You can download Ant from: https://ant.apache.org/bindownload.cgi
)

:end

