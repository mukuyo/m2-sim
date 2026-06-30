# Windows build script for ssl-RAVEN-Sim (Qt MinGW + vcpkg)
# Run this script from the repo root after installing dependencies.
#
# Prerequisites:
#   1. Qt 6.10.0 with MinGW 13.1.0 64-bit and Qt Quick 3D Physics installed
#      -> Run C:\Qt\MaintenanceTool.exe, log in, and install:
#         Qt 6.10.0 > Additional Libraries > Qt Quick 3D Physics (MinGW 64-bit)
#   2. vcpkg packages installed:
#      -> vcpkg install boost-asio:x64-mingw-dynamic protobuf:x64-mingw-dynamic
#         (or run this script which will do it automatically)

$QtDir     = "C:/Qt/6.10.0/mingw_64"
$MinGWDir  = "C:/Qt/Tools/mingw1310_64/bin"
$CMakeExe  = "C:/Qt/Tools/CMake_64/bin/cmake.exe"
$NinjaExe  = "C:/Qt/Tools/Ninja/ninja.exe"
$VcpkgRoot = "C:/ws/vcpkg"
$Triplet   = "x64-mingw-dynamic"

# Add MinGW to PATH
$env:PATH = "$MinGWDir;" + $env:PATH

# Install dependencies if not yet installed
Write-Host "=== Checking/installing vcpkg dependencies ==="
& "$VcpkgRoot/vcpkg.exe" install "boost-asio:$Triplet" "protobuf:$Triplet"
if ($LASTEXITCODE -ne 0) {
    Write-Error "vcpkg install failed. Check the output above."
    exit 1
}

# Create build directory
$BuildDir = "$PSScriptRoot/build"
if (-not (Test-Path $BuildDir)) { New-Item -ItemType Directory $BuildDir | Out-Null }

Write-Host "=== Running CMake configure ==="
& $CMakeExe `
    -G Ninja `
    -DCMAKE_MAKE_PROGRAM="$NinjaExe" `
    -DCMAKE_C_COMPILER="$MinGWDir/gcc.exe" `
    -DCMAKE_CXX_COMPILER="$MinGWDir/g++.exe" `
    -DCMAKE_PREFIX_PATH="$QtDir" `
    -DCMAKE_TOOLCHAIN_FILE="$VcpkgRoot/scripts/buildsystems/vcpkg.cmake" `
    -DVCPKG_TARGET_TRIPLET=$Triplet `
    -DCMAKE_BUILD_TYPE=Release `
    -S "$PSScriptRoot" `
    -B "$BuildDir"

if ($LASTEXITCODE -ne 0) {
    Write-Error "CMake configure failed."
    exit 1
}

Write-Host "=== Building ==="
& $CMakeExe --build "$BuildDir" --parallel

if ($LASTEXITCODE -ne 0) {
    Write-Error "Build failed."
    exit 1
}

Write-Host ""
Write-Host "=== Build succeeded! ==="
Write-Host "Executable: $BuildDir/bin/m2-Sim.exe"
Write-Host ""
Write-Host "Before running, copy DLLs alongside the .exe:"
Write-Host "  & '$CMakeExe' --install '$BuildDir' --prefix '$BuildDir/install'"
Write-Host "  Or run via Qt's windeployqt:"
Write-Host "  C:/Qt/6.10.0/mingw_64/bin/windeployqt.exe --qmldir src/qml $BuildDir/bin/m2-Sim.exe"
