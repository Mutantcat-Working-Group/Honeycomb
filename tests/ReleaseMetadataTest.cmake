if(NOT DEFINED SOURCE_DIR)
    message(FATAL_ERROR "SOURCE_DIR is required")
endif()

file(READ "${SOURCE_DIR}/CMakeLists.txt" cmake_source)
file(READ "${SOURCE_DIR}/main.cpp" main_source)
file(READ "${SOURCE_DIR}/windows/AboutWindow.qml" about_source)
file(READ "${SOURCE_DIR}/windows/ChangelogWindow.qml" changelog_source)
file(READ "${SOURCE_DIR}/i18n/zh_CN.js" zh_source)
file(READ "${SOURCE_DIR}/i18n/en_US.js" en_source)
file(READ "${SOURCE_DIR}/sdk/NSIS/Honeycomb.nsi" nsis_source)

# CMakeLists.txt is the single source of truth for the version; every other
# surface has to follow it instead of keeping its own literal.
if(NOT cmake_source MATCHES "project\\(Honeycomb VERSION ([0-9]+\\.[0-9]+\\.[0-9]+) ")
    message(FATAL_ERROR "Cannot read the project version from CMakeLists.txt")
endif()
set(EXPECTED_VERSION "${CMAKE_MATCH_1}")
set(RELEASE_DATE "${CMAKE_MATCH_3}")

string(FIND "${cmake_source}" "MACOSX_BUNDLE_SHORT_VERSION_STRING \${PROJECT_VERSION}" short_version_index)
if(short_version_index EQUAL -1)
    message(FATAL_ERROR "macOS short version must use the complete project version")
endif()

if(NOT nsis_source MATCHES "!define VERSION \"${EXPECTED_VERSION}\"")
   message(FATAL_ERROR "Windows installer version is not ${EXPECTED_VERSION}")
endif()

foreach(source IN ITEMS changelog_source zh_source en_source)
    if(NOT "${${source}}" MATCHES "${RELEASE_DATE}")
        message(FATAL_ERROR "${source} does not contain the ${RELEASE_DATE} release entry")
    endif()
endforeach()

if(NOT zh_source MATCHES "新增.*网页组件选取.*窗口组件选取")
    message(FATAL_ERROR "Chinese changelog does not list both component inspector features")
endif()

if(NOT en_source MATCHES "Added.*Web Component Inspector.*Window Component Inspector")
    message(FATAL_ERROR "English changelog does not list both component inspector features")
endif()

foreach(tag_color IN ITEMS e53935 00897b 3949ab f4511e 8e24aa 00838f 43a047 5e35b1 d81b60)
    if(NOT changelog_source MATCHES "#${tag_color}")
        message(FATAL_ERROR "Changelog tag palette is missing #${tag_color}")
    endif()
endforeach()

# The About page must render the compiled-in version, not a stale literal.
if(NOT main_source MATCHES "setContextProperty\\(\"appVersion\", QStringLiteral\\(HONEYCOMB_VERSION\\)\\)")
    message(FATAL_ERROR "main.cpp must expose appVersion from HONEYCOMB_VERSION")
endif()

if(NOT about_source MATCHES "I18n\\.t\\(\"aboutVersion\"\\)\\.replace\\(\"\\{0\\}\", appVersion\\)")
    message(FATAL_ERROR "About window must substitute appVersion into the version label")
endif()

foreach(source IN ITEMS zh_source en_source)
    if(NOT "${${source}}" MATCHES "aboutVersion: \"[^\"0-9]*\\{0\\}\"")
        message(FATAL_ERROR "${source} aboutVersion must be a {0} template, not a hardcoded version literal")
    endif()
endforeach()

message(STATUS "Release metadata is consistent at ${EXPECTED_VERSION}")
