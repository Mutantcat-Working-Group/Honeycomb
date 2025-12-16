cmake_minimum_required(VERSION 3.16)

project(Honeycomb VERSION 1.1.20251209 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTORCC ON)

find_package(Qt6 REQUIRED COMPONENTS Quick QuickControls2 Widgets WebSockets Multimedia)
find_package(yaml-cpp REQUIRED)
find_package(jsoncpp REQUIRED)
find_package(PahoMqttCpp REQUIRED)


qt_standard_project_setup(REQUIRES 6.8)


qt_add_executable(appHoneycomb
    main.cpp
    app.rc
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
        windows/QRCodeWindow.qml
        windows/TimestampWindow.qml
        windows/ColorConverterWindow.qml
        windows/UnicodeWindow.qml
        windows/AsciiTableWindow.qml
        windows/RadixWindow.qml
        windows/ComplementWindow.qml
        windows/TextDiffWindow.qml
        windows/RegexWindow.qml
        windows/CaseConvertWindow.qml
        windows/TrimSpaceWindow.qml
        windows/TrimNewlineWindow.qml
        windows/TrimAllWindow.qml
        windows/ReplaceWindow.qml
        windows/WordCountWindow.qml
        windows/JsonFormatWindow.qml
        windows/JsonYamlWindow.qml
        windows/ColorPickerWindow.qml
        windows/ColorSelectorWindow.qml
        windows/HtmlColorWindow.qml
        windows/BrTagWindow.qml
        windows/UserAgentWindow.qml
        windows/GoCrossWindow.qml
        windows/HtaccessNginxWindow.qml
        windows/ManifestWindow.qml
        windows/HarmonyPermissionWindow.qml
        windows/HttpStatusWindow.qml
        windows/ContentTypeWindow.qml
        windows/HtmlCharWindow.qml
        windows/WinEncryptWindow.qml
        windows/MD5Window.qml
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
        windows/SubnetCalculatorWindow.qml
        windows/RTSPViewerWindow.qml
        windows/RegisterRangeWindow.qml
        windows/ResistorCalculatorWindow.qml
        windows/RISCVInstructionWindow.qml
        windows/RegisterRefWindow.qml
        windows/AsmRefWindow.qml
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
    )

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(appHoneycomb PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appHoneycomb
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appHoneycomb
    PRIVATE
        Qt6::Quick
        Qt6::QuickControls2
        Qt6::Widgets
        Qt6::WebSockets
        Qt6::Multimedia
        yaml-cpp::yaml-cpp
        JsonCpp::JsonCpp
        PahoMqttCpp::paho-mqttpp3-static
)

include(GNUInstallDirs)
install(TARGETS appHoneycomb
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
