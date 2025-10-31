# Script to run Ant with full path
param(
    [string]$Target = "clean dist"
)

# Try to find Ant in common locations
$antPaths = @(
    "C:\Program Files\NetBeans-21\netbeans\ext\ant\bin\ant.bat",
    "C:\Program Files\Apache\ant\bin\ant.bat",
    "C:\apache-ant\bin\ant.bat",
    "C:\ant\bin\ant.bat"
)

$antFound = $false
foreach ($path in $antPaths) {
    if (Test-Path $path) {
        Write-Host "Found Ant at: $path"
        & $path -f build.xml $Target
        $antFound = $true
        break
    }
}

if (-not $antFound) {
    Write-Host "Ant not found in common locations. Trying to run with 'ant' command..."
    try {
        & ant -f build.xml $Target
    } catch {
        Write-Host "Error: Ant not found. Please install Apache Ant or add it to PATH."
        Write-Host "You can download Ant from: https://ant.apache.org/bindownload.cgi"
    }
}

