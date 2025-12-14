cmake_minimum_required(VERSION 3.16)

project(Honeycomb VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTORCC ON)

find_package(Qt6 REQUIRED COMPONENTS Quick QuickControls2 Widgets)
find_package(yaml-cpp REQUIRED)
find_package(LibreSSL REQUIRED)
find_package(jsoncpp REQUIRED)

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
        yaml-cpp::yaml-cpp
        JsonCpp::JsonCpp
        libressl::libressl
)

include(GNUInstallDirs)
install(TARGETS appHoneycomb
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
