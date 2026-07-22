cmake_minimum_required(VERSION 3.16)

if(APPLE AND (NOT DEFINED CMAKE_OSX_SYSROOT OR CMAKE_OSX_SYSROOT STREQUAL "" OR NOT EXISTS "${CMAKE_OSX_SYSROOT}"))
    if(DEFINED ENV{SDKROOT} AND NOT "$ENV{SDKROOT}" STREQUAL "" AND EXISTS "$ENV{SDKROOT}")
        set(CMAKE_OSX_SYSROOT "$ENV{SDKROOT}" CACHE STRING "macOS SDK path" FORCE)
    else()
        execute_process(
            COMMAND xcrun --sdk macosx --show-sdk-path
            OUTPUT_VARIABLE detected_macos_sdk
            OUTPUT_STRIP_TRAILING_WHITESPACE
            ERROR_QUIET
        )

        if(detected_macos_sdk AND EXISTS "${detected_macos_sdk}")
            set(CMAKE_OSX_SYSROOT "${detected_macos_sdk}" CACHE STRING "macOS SDK path" FORCE)
        endif()
    endif()
endif()

if(CMAKE_GENERATOR STREQUAL "Ninja" AND (NOT DEFINED CMAKE_MAKE_PROGRAM OR CMAKE_MAKE_PROGRAM STREQUAL ""))
    find_program(HONEYCOMB_NINJA_PROGRAM ninja)
    if(HONEYCOMB_NINJA_PROGRAM)
        set(CMAKE_MAKE_PROGRAM "${HONEYCOMB_NINJA_PROGRAM}" CACHE FILEPATH "Ninja executable" FORCE)
    endif()
endif()

project(Honeycomb VERSION 1.1.20260718 LANGUAGES C CXX)

# Toolchain files are loaded by project() and may replace an absolute SDK path
# with the invalid literal "macosx". Normalize it again after toolchain setup.
if(APPLE AND (CMAKE_OSX_SYSROOT STREQUAL "macosx" OR
              CMAKE_OSX_SYSROOT STREQUAL "" OR
              NOT EXISTS "${CMAKE_OSX_SYSROOT}"))
    execute_process(
        COMMAND xcrun --sdk macosx --show-sdk-path
        OUTPUT_VARIABLE detected_macos_sdk
        OUTPUT_STRIP_TRAILING_WHITESPACE
        ERROR_QUIET
    )
    if(detected_macos_sdk AND EXISTS "${detected_macos_sdk}")
        set(CMAKE_OSX_SYSROOT "${detected_macos_sdk}" CACHE PATH "macOS SDK path" FORCE)
    else()
        message(FATAL_ERROR "Unable to resolve the macOS SDK path with xcrun")
    endif()
endif()

include(CTest)

if(APPLE)
    if(NOT DEFINED CMAKE_SHARED_LIBRARY_RUNTIME_C_FLAG OR CMAKE_SHARED_LIBRARY_RUNTIME_C_FLAG STREQUAL "")
        set(CMAKE_SHARED_LIBRARY_RUNTIME_C_FLAG "-Wl,-rpath,")
    endif()
    if(NOT DEFINED CMAKE_SHARED_LIBRARY_RUNTIME_C_FLAG_SEP OR CMAKE_SHARED_LIBRARY_RUNTIME_C_FLAG_SEP STREQUAL "")
        set(CMAKE_SHARED_LIBRARY_RUNTIME_C_FLAG_SEP ":")
    endif()
    if(NOT DEFINED CMAKE_SHARED_LIBRARY_SONAME_C_FLAG OR CMAKE_SHARED_LIBRARY_SONAME_C_FLAG STREQUAL "")
        set(CMAKE_SHARED_LIBRARY_SONAME_C_FLAG "-install_name")
    endif()
endif()

set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTORCC ON)

# MSVC UTF-8 encoding support
if(MSVC)
    add_compile_options(/utf-8)
endif()

find_package(Qt6 REQUIRED COMPONENTS Quick QuickControls2 Widgets WebSockets Multimedia Network SerialPort WebEngineQuick WebChannel DBus)
find_package(yaml-cpp REQUIRED)
find_package(jsoncpp REQUIRED)
find_package(PahoMqttCpp REQUIRED)
find_package(ZXing REQUIRED)

get_filename_component(HONEYCOMB_QT_PREFIX "${Qt6_DIR}/../../.." ABSOLUTE)
set(HONEYCOMB_QT_LIB_DIR "${HONEYCOMB_QT_PREFIX}/lib")
set(HONEYCOMB_APP_DISPLAY_NAME "蜂巢工具箱")
set(HONEYCOMB_INFO_PLIST "${CMAKE_CURRENT_BINARY_DIR}/Honeycomb-Info.plist")

configure_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/cmake/Info.plist.in"
    "${HONEYCOMB_INFO_PLIST}"
    @ONLY
)

qt_standard_project_setup(REQUIRES 6.8)

set_source_files_properties(logo.icns PROPERTIES MACOSX_PACKAGE_LOCATION Resources)


qt_add_executable(appHoneycomb
    main.cpp
    app.rc
    logo.icns
)

qt_add_qml_module(appHoneycomb
    URI Honeycomb
    QML_FILES
        Main.qml
        windows/AboutWindow.qml
        windows/HelpWindow.qml
        windows/ChangelogWindow.qml
        windows/FeedbackWindow.qml
        windows/RandomNumberWindow.qml
        windows/RandomLetterWindow.qml
        windows/RandomMixedWindow.qml
        windows/BarcodeWindow.qml
        windows/BatchBarcodeWindow.qml
        windows/QRCodeWindow.qml
        windows/QRCodeScannerWindow.qml
        windows/TimestampWindow.qml
        windows/ColorConverterWindow.qml
        windows/UnicodeWindow.qml
        windows/UTF8Window.qml
        windows/AsciiTableWindow.qml
        windows/RadixWindow.qml
        windows/ComplementWindow.qml
        windows/TextDiffWindow.qml
        windows/RegexWindow.qml
        windows/CaseConvertWindow.qml
        windows/TrimSpaceWindow.qml
        windows/TrimNewlineWindow.qml
        windows/TrimAllWindow.qml
        windows/TrimCJKSpaceWindow.qml
        windows/ReplaceWindow.qml
        windows/WordCountWindow.qml
        windows/JsonFormatWindow.qml
        windows/JsonYamlWindow.qml
        windows/ColorPickerWindow.qml
        windows/ColorSelectorWindow.qml
        windows/HtmlColorWindow.qml
        windows/BrTagWindow.qml
        windows/UserAgentWindow.qml
        windows/EnvironmentPathWindow.qml
        windows/DockerToolWindow.qml
        windows/SqlFormatWindow.qml
        windows/LddQuickWindow.qml
        windows/ProcessManagerWindow.qml
        windows/PortManagerWindow.qml
        windows/GoCrossWindow.qml
        windows/HtaccessNginxWindow.qml
        windows/ManifestWindow.qml
        windows/HarmonyPermissionWindow.qml
        windows/PermissionMatrixWindow.qml
        windows/CronParserWindow.qml
        windows/HttpStatusWindow.qml
        windows/ContentTypeWindow.qml
        windows/HtmlCharWindow.qml
        windows/WinEncryptWindow.qml
        windows/MD5Window.qml
        windows/FileChecksumWindow.qml
        windows/FileHashWindow.qml
        windows/FileMD5Window.qml
        windows/FileSHA1Window.qml
        windows/FileSHA256Window.qml
        windows/FileBase64Window.qml
        windows/FileInfoWindow.qml
        windows/Base64ImagePreviewWindow.qml
        windows/ImageCompressWindow.qml
        windows/SHA1Window.qml
        windows/SHA256Window.qml
        windows/PasswordStrengthWindow.qml
        windows/RandomMacWindow.qml
        windows/RandomIpv4Window.qml
        windows/RandomIpv6Window.qml
        windows/UuidWindow.qml
        windows/WebSocketTestWindow.qml
        windows/RestfulTestWindow.qml
        windows/MQTTListenerWindow.qml
        windows/MQTTPublisherWindow.qml
        windows/DNSLookupWindow.qml
        windows/SubnetCalculatorWindow.qml
        windows/RTSPViewerWindow.qml
        windows/RegisterRangeWindow.qml
        windows/ResistorCalculatorWindow.qml
        windows/RISCVInstructionWindow.qml
        windows/RegisterRefWindow.qml
        windows/AsmRefWindow.qml
        windows/ContextFloatWindow.qml
        windows/AIPromptWindow.qml
        windows/NNTableWindow.qml
        windows/KerasLayerWindow.qml
        windows/MLHandbookWindow.qml
        windows/FolderMappingWindow.qml
        windows/FakeApiWindow.qml
        windows/SMCryptoWindow.qml
        windows/AESCryptoWindow.qml
        windows/OpenAITestWindow.qml
        windows/SettingsWindow.qml
        windows/AgentPromptWindow.qml
        windows/AiTextReducerWindow.qml
        windows/WebInspectorWindow.qml
        windows/SerialPortWindow.qml
        windows/WindowElementInspectorWindow.qml
    RESOURCES
        i18n/zh_CN.js
        i18n/en_US.js
        i18n/i18n.js
        assets/icons/icon.jpg
        logo.png
    SOURCES
        lib/qrcodegen/qrcodegen.hpp
        lib/qrcodegen/qrcodegen.cpp
        src/RandomNumberGenerator.h
        src/RandomNumberGenerator.cpp
        src/RandomLetterGenerator.h
        src/RandomLetterGenerator.cpp
        src/RandomMixedGenerator.h
        src/RandomMixedGenerator.cpp
        src/BarcodeGenerator.h
        src/BarcodeGenerator.cpp
        src/QRCodeGenerator.h
        src/QRCodeGenerator.cpp
        src/QRCodeScanner.h
        src/QRCodeScanner.cpp
        src/JsonYamlConverter.h
        src/JsonYamlConverter.cpp
        src/ColorPicker.h
        src/ColorPicker.cpp
        src/ColorSelector.h
        src/ColorSelector.cpp
        src/MD5Generator.h
        src/MD5Generator.cpp
        src/SHA1Generator.h
        src/SHA1Generator.cpp
        src/SHA256Generator.h
        src/SHA256Generator.cpp
        src/PasswordStrengthGenerator.h
        src/PasswordStrengthGenerator.cpp
        src/RandomMacGenerator.h
        src/RandomMacGenerator.cpp
        src/RandomIpv4Generator.h
        src/RandomIpv4Generator.cpp
        src/RandomIpv6Generator.h
        src/RandomIpv6Generator.cpp
        src/UuidGenerator.h
        src/UuidGenerator.cpp
        src/WebSocketTest.h
        src/WebSocketTest.cpp
        src/RestfulTest.h
        src/RestfulTest.cpp
        src/MQTTListener.h
        src/MQTTListener.cpp
        src/MQTTPublisher.h
        src/MQTTPublisher.cpp
        src/SubnetCalculator.h
        src/SubnetCalculator.cpp
        src/RTSPViewer.h
        src/RTSPViewer.cpp
        src/ResistorCalculator.h
        src/ResistorCalculator.cpp
        src/FolderHttpServer.h
        src/FolderHttpServer.cpp
        src/FakeApiServer.h
        src/FakeApiServer.cpp
        src/SMCrypto.h
        src/SMCrypto.cpp
        src/AESCrypto.h
        src/AESCrypto.cpp
        src/OpenAIClient.h
        src/OpenAIClient.cpp
        src/AgentPromptManager.h
        src/AgentPromptManager.cpp
        src/DNSLookupTool.h
        src/DNSLookupTool.cpp
        src/EnvironmentPathTool.h
        src/EnvironmentPathTool.cpp
        src/ProcessManagerTool.h
        src/ProcessManagerTool.cpp
        src/FileHashCalculator.h
        src/FileHashCalculator.cpp
        src/FileUtilityTool.h
        src/FileUtilityTool.cpp
        src/UpdateChecker.h
        src/UpdateChecker.cpp
        src/SerialPortTool.h
        src/SerialPortTool.cpp
        src/WindowElementInspector.h
        src/WindowElementInspector.cpp
    )

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(appHoneycomb PROPERTIES
    MACOSX_BUNDLE_GUI_IDENTIFIER com.mutantcat.honeycomb
    MACOSX_BUNDLE_BUNDLE_NAME "${HONEYCOMB_APP_DISPLAY_NAME}"
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_COPYRIGHT "Honeycomb"
    MACOSX_BUNDLE_INFO_PLIST "${HONEYCOMB_INFO_PLIST}"
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE_ICON_FILE logo
    MACOSX_BUNDLE TRUE
    MACOSX_RPATH TRUE
    WIN32_EXECUTABLE TRUE
)

if(APPLE)
    set_target_properties(appHoneycomb PROPERTIES
        OUTPUT_NAME "${HONEYCOMB_APP_DISPLAY_NAME}"
        BUILD_RPATH "@executable_path/../Frameworks;${HONEYCOMB_QT_LIB_DIR}"
        INSTALL_RPATH "@executable_path/../Frameworks;${HONEYCOMB_QT_LIB_DIR}"
        INSTALL_RPATH_USE_LINK_PATH TRUE
    )

    target_link_options(appHoneycomb PRIVATE
        "LINKER:-rpath,@executable_path/../Frameworks"
        "LINKER:-rpath,${HONEYCOMB_QT_LIB_DIR}"
    )
endif()

target_link_libraries(appHoneycomb
    PRIVATE
        Qt6::Quick
        Qt6::QuickControls2
        Qt6::Widgets
        Qt6::WebSockets
        Qt6::Multimedia
        Qt6::Network
        Qt6::SerialPort
        Qt6::WebEngineQuick
        Qt6::WebChannel
        Qt6::DBus
        yaml-cpp::yaml-cpp
        JsonCpp::JsonCpp
        PahoMqttCpp::paho-mqttpp3-static
        ZXing::ZXing
)

# ===== 窗口组件选取：平台特定依赖 =====
if(APPLE)
    target_sources(appHoneycomb PRIVATE src/WindowElementInspector_mac.mm)
    # AXUIElement + AppKit 需链接这些 framework
    find_library(APPKIT_FRAMEWORK AppKit)
    find_library(APPSERVICES_FRAMEWORK ApplicationServices)
    target_link_libraries(appHoneycomb PRIVATE ${APPKIT_FRAMEWORK} ${APPSERVICES_FRAMEWORK})
    add_custom_command(TARGET appHoneycomb POST_BUILD
        COMMAND /usr/bin/codesign --force --deep --sign - --identifier com.mutantcat.honeycomb --requirements "=designated => identifier \"com.mutantcat.honeycomb\"" "$<TARGET_BUNDLE_DIR:appHoneycomb>"
        COMMENT "Applying a stable ad-hoc signature for macOS privacy permissions"
        VERBATIM
    )
endif()
if(WIN32)
    target_sources(appHoneycomb PRIVATE src/WindowElementInspector_win.cpp)
    # UI Automation COM
    target_link_libraries(appHoneycomb PRIVATE ole32 oleaut32 uuid)
endif()
if(UNIX AND NOT APPLE)
    target_sources(appHoneycomb PRIVATE src/WindowElementInspector_linux.cpp)
    # AT-SPI2
    find_package(PkgConfig REQUIRED)
    pkg_check_modules(AT_SPI2 REQUIRED atspi-2.0)
    target_include_directories(appHoneycomb PRIVATE ${AT_SPI2_INCLUDE_DIRS})
    target_link_libraries(appHoneycomb PRIVATE ${AT_SPI2_LIBRARIES})
endif()

target_compile_definitions(appHoneycomb PRIVATE HONEYCOMB_VERSION="${PROJECT_VERSION}")

if(BUILD_TESTING)
    qt_add_executable(update_checker_test
        tests/UpdateCheckerTest.cpp
        src/UpdateChecker.h
        src/UpdateChecker.cpp
    )
    target_link_libraries(update_checker_test PRIVATE Qt6::Core Qt6::Network)
    if(APPLE)
        set_target_properties(update_checker_test PROPERTIES
            BUILD_RPATH "${HONEYCOMB_QT_LIB_DIR}"
        )
    endif()
    add_test(NAME UpdateCheckerTest COMMAND update_checker_test)
    add_test(
        NAME AboutWindowLayoutTest
        COMMAND ${CMAKE_COMMAND}
            -DABOUT_QML=${CMAKE_CURRENT_SOURCE_DIR}/windows/AboutWindow.qml
            -P ${CMAKE_CURRENT_SOURCE_DIR}/tests/AboutWindowLayoutTest.cmake
    )
    add_test(
        NAME ManagerTableScrollTest
        COMMAND ${CMAKE_COMMAND}
            -DPROCESS_QML=${CMAKE_CURRENT_SOURCE_DIR}/windows/ProcessManagerWindow.qml
            -DPORT_QML=${CMAKE_CURRENT_SOURCE_DIR}/windows/PortManagerWindow.qml
            -P ${CMAKE_CURRENT_SOURCE_DIR}/tests/ManagerTableScrollTest.cmake
    )
    add_test(
        NAME WindowElementInspectorIntegrationTest
        COMMAND ${CMAKE_COMMAND}
            -DQML_FILE=${CMAKE_CURRENT_SOURCE_DIR}/windows/WindowElementInspectorWindow.qml
            -DCMAKE_FILE=${CMAKE_CURRENT_SOURCE_DIR}/CMakeLists.txt
            -DCOMMON_BACKEND=${CMAKE_CURRENT_SOURCE_DIR}/src/WindowElementInspector.cpp
            -DMAC_BACKEND=${CMAKE_CURRENT_SOURCE_DIR}/src/WindowElementInspector_mac.mm
            -P ${CMAKE_CURRENT_SOURCE_DIR}/tests/WindowElementInspectorIntegrationTest.cmake
    )
endif()

include(GNUInstallDirs)
install(TARGETS appHoneycomb
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
