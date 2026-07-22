;=== [可配置区域] ============================================
; 命令行参数覆盖示例:
;   makensis.exe /DVERSION=1.0.20260722 /DSTAGING=E:\Projects\Honeycomb_1.0.20260722_msvc2022_64 Honeycomb.nsi
!ifndef VERSION
  !define VERSION "1.0.20260722"
!endif
!ifndef STAGING_DIR
  !define STAGING_DIR "E:\Projects\Honeycomb_1.0.20260722_msvc2022_64"
!endif
!define PRODUCT_NAME    "蜂巢工具箱"
!define PRODUCT_NAME_EN "Honeycomb"
!define MANUFACTURER    "Mutantcat"
!define WEBSITE         "www.mutantcat.org.cn"
!define EMAIL           "feedback@mutantcat.org.cn"
!define APP_EXE         "appHoneycomb.exe"
;=== [可配置区域结束] ========================================

!define INSTALLER_NAME  "${PRODUCT_NAME_EN}_${VERSION}_msvc2022_64_setup.exe"
!define REG_KEY         "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME_EN}"
!define EXE_SOURCE      "${STAGING_DIR}\${APP_EXE}"

;============================================================================
; 基础设置
;============================================================================
Unicode True
SetCompressor /SOLID lzma

Name "${PRODUCT_NAME} ${VERSION}"
OutFile "${INSTALLER_NAME}"
InstallDir "$PROGRAMFILES\${PRODUCT_NAME_EN}"
InstallDirRegKey HKCU "${REG_KEY}" "InstallLocation"
RequestExecutionLevel admin
BrandingText "蜂巢工具箱 v${VERSION}"

;============================================================================
; 现代界面 (MUI2)
;============================================================================
!include "MUI2.nsh"

!define MUI_ABORTWARNING
!define MUI_ICON   "E:\Projects\Honeycomb\logo.ico"
!define MUI_UNICON "E:\Projects\Honeycomb\logo.ico"

; 欢迎页正文（厂商 / 官网 / 邮箱）
!define MUI_WELCOMEPAGE_TITLE_3LINES
!define MUI_WELCOMEPAGE_TEXT "即将安装 ${PRODUCT_NAME} ${VERSION}。$\r$\n$\r$\n本软件由 ${MANUFACTURER} 提供，官网 ${WEBSITE}，技术支持 ${EMAIL}。$\r$\n$\r$\n建议关闭所有正在运行的 ${PRODUCT_NAME} 实例后继续。$\r$\n$\r$\n点击 [下一步] 继续。"

; 完成页
!define MUI_FINISHPAGE_SHOWREADME
!define MUI_FINISHPAGE_SHOWREADME_TEXT "创建桌面快捷方式(&D)"
!define MUI_FINISHPAGE_SHOWREADME_FUNCTION CreateDesktopShortcut
!define MUI_FINISHPAGE_RUN
!define MUI_FINISHPAGE_RUN_TEXT "立即启动 ${PRODUCT_NAME}(&L)"
!define MUI_FINISHPAGE_RUN_FUNCTION LaunchApp

; 页面序列
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "${STAGING_DIR}\LICENSE.txt"
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

; 语言
!insertmacro MUI_LANGUAGE "SimpChinese"
!insertmacro MUI_LANGUAGE "English"

;============================================================================
; 安装段
;============================================================================
Section "MainSection" SEC01
    SetOutPath "$INSTDIR"
    File /r "${STAGING_DIR}\*.*"

    ; 开始菜单
    CreateDirectory "$SMPROGRAMS\${PRODUCT_NAME}"
    CreateShortcut  "$SMPROGRAMS\${PRODUCT_NAME}\${PRODUCT_NAME}.lnk" "$INSTDIR\${APP_EXE}"
    CreateShortcut  "$SMPROGRAMS\${PRODUCT_NAME}\卸载.lnk"                 "$INSTDIR\uninstall.exe"

    ; 卸载注册表
    WriteRegStr   HKLM "${REG_KEY}" "DisplayName"       "${PRODUCT_NAME} ${VERSION}"
    WriteRegStr   HKLM "${REG_KEY}" "DisplayVersion"    "${VERSION}"
    WriteRegStr   HKLM "${REG_KEY}" "Publisher"         "${MANUFACTURER}"
    WriteRegStr   HKLM "${REG_KEY}" "URLInfoAbout"       "${WEBSITE}"
    WriteRegStr   HKLM "${REG_KEY}" "URLUpdateInfo"      "${WEBSITE}"
    WriteRegStr   HKLM "${REG_KEY}" "HelpLink"           "mailto:${EMAIL}"
    WriteRegStr   HKLM "${REG_KEY}" "Contact"            "${EMAIL}"
    WriteRegStr   HKLM "${REG_KEY}" "InstallLocation"    "$INSTDIR"
    WriteRegStr   HKLM "${REG_KEY}" "UninstallString"    '"$INSTDIR\uninstall.exe"'
    WriteRegDWORD HKLM "${REG_KEY}" "NoModify"           1
    WriteRegDWORD HKLM "${REG_KEY}" "NoRepair"           1

    WriteUninstaller "$INSTDIR\uninstall.exe"
SectionEnd

;============================================================================
; 卸载段
;============================================================================
Section "Uninstall"
    RMDir /r "$INSTDIR"
    RMDir /r "$SMPROGRAMS\${PRODUCT_NAME}"
    Delete "$DESKTOP\${PRODUCT_NAME}.lnk"
    DeleteRegKey HKLM "${REG_KEY}"
SectionEnd

;============================================================================
; 自定义函数
;============================================================================
Function CreateDesktopShortcut
    CreateShortcut "$DESKTOP\${PRODUCT_NAME}.lnk" "$INSTDIR\${APP_EXE}"
FunctionEnd

Function LaunchApp
    ExecShell "" "$INSTDIR\${APP_EXE}"
FunctionEnd
