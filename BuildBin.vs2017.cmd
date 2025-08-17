cd /d "%~dp0"

for /f "usebackq tokens=*" %%i in (`"%programfiles(x86)%\microsoft visual studio\installer\vswhere.exe" -version [15.0^,16.0^) -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath`) do (
  set InstallDir=%%i
)
if "%1" == "" (
  call :BuildBin x86 || goto :eof
  call :BuildBin x64 || goto :eof
  call :BuildBin ARM || goto :eof
  call :BuildBin ARM64 || goto :eof
) else (
  call :BuildBin %1 || goto :eof
)

goto :eof

:BuildBin

setlocal

if "%1" == "Win32" set ARCH=x86
if "%1" == "x86" set ARCH=x86
if "%1" == "X86" set ARCH=x86
if "%1" == "x64" set ARCH=amd64
if "%1" == "X64" set ARCH=amd64
if "%1" == "arm" set ARCH=amd64_arm
if "%1" == "ARM" set ARCH=amd64_arm
if "%1" == "arm64" set ARCH=amd64_arm64
if "%1" == "ARM64" set ARCH=amd64_arm64

call "%InstallDir%\VC\Auxiliary\Build\vcvarsall.bat" %ARCH% 10.0.16299.0

pushd CPP\7zip
nmake
popd

if exist "%SIGNBAT_PATH%" (
  if "%ARCH%" == "x86" (
    call "%SIGNBAT_PATH%" CPP\7zip\Bundles\Format7zF\x86\7z.dll
  ) else (
    call "%SIGNBAT_PATH%" CPP\7zip\Bundles\Format7zF\%1\7z.dll
  )
)

endlocal
goto :eof
