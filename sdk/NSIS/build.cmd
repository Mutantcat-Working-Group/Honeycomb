@echo off & setlocal EnableExtensions EnableDelayedExpansion
title NSIS 安装包构建脚本 —— 蜂巢工具箱

;=== 路径配置（按你的环境改） ===
set "MAKENSIS=C:\Program Files (x86)\NSIS\makensis.exe"
if not exist "%MAKENSIS%" set "MAKENSIS=C:\Program Files\NSIS\makensis.exe"
set "SIGNTOOL=D:\Softwares\Win签名工具\signtool.exe"
set "PFX=D:\Cert\Mutantcat.pfx"
set "PWD=LINGSHI.15m"
set "TSURL=http://timestamp.sectigo.com"

;=== 参数 ===
set "VERSION=%~1"
set "STAGING=%~2"
if "%VERSION%"=="" (
    echo [ERROR] 缺少版本号参数。用法:
    echo   build.cmd ^<VERSION^> ^<STAGING_PATH^>
    echo 示例:
    echo   build.cmd 1.1.20260712 E:\Projects\Honeycomb_1.1.20260712_msvc2022_64
    exit /b 1
)
if "%STAGING%"=="" (
    echo [ERROR] 缺少 staging 路径参数。
    exit /b 1
)
if not exist "%MAKENSIS%" (
    echo [ERROR] 找不到 makensis.exe，请先安装 NSIS:
    echo   https://nsis.sourceforge.io/Download
    echo 安装后再次运行本脚本。
    exit /b 1
)
if not exist "%STAGING%\appHoneycomb.exe" (
    echo [ERROR] staging 路径下找不到 appHoneycomb.exe: %STAGING%
    exit /b 1
)

echo ============================================
echo   构建安装包  %VERSION%
echo   Staging:  %STAGING%
echo ============================================
echo.

;=== 编译 ===
"%MAKENSIS%" /DVERSION="%VERSION%" /DSTAGING="%STAGING%" "%~dp0Honeycomb.nsi"
if errorlevel 1 (
    echo.
    echo [ERROR] NSIS 编译失败。
    exit /b 1
)

set "INSTALLER=Honeycomb_%VERSION%_msvc2022_64_setup.exe"
if exist "%~dp0%INSTALLER%" (
    echo [OK] 安装包: %~dp0%INSTALLER%
) else (
    echo [ERROR] 找不到输出文件。
    exit /b 1
)

;=== 签名 ===
if exist "%SIGNTOOL%" (
    echo.
    echo === 签名安装包 ===
    "%SIGNTOOL%" sign /f "%PFX%" /p "%PWD%" /fd SHA256 /tr "%TSURL%" /td SHA256 "%~dp0%INSTALLER%"
    if errorlevel 1 (
        echo [WARN] 签名失败，但安装包仍可用。
    ) else (
        echo [OK] 签名完成。
        "%SIGNTOOL%" verify /pa "%~dp0%INSTALLER%" >nul 2>&1
        if not errorlevel 1 echo [OK] 签名验证通过。
    )
) else (
    echo.
    echo [INFO] 找不到 signtool.exe，跳过签名（安装包仍可正常使用）。
)

echo.
echo === 完成 ===
exit /b 0