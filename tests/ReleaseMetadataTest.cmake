if(NOT DEFINED SOURCE_DIR)
    message(FATAL_ERROR "SOURCE_DIR is required")
endif()

file(READ "${SOURCE_DIR}/CMakeLists.txt" cmake_source)
file(READ "${SOURCE_DIR}/windows/ChangelogWindow.qml" changelog_source)
file(READ "${SOURCE_DIR}/i18n/zh_CN.js" zh_source)
file(READ "${SOURCE_DIR}/i18n/en_US.js" en_source)
file(READ "${SOURCE_DIR}/sdk/NSIS/Honeycomb.nsi" nsis_source)

if(NOT cmake_source MATCHES "project\\(Honeycomb VERSION 1\\.1\\.20260723 ")
    message(FATAL_ERROR "Project version is not 1.1.20260723")
endif()

string(FIND "${cmake_source}" "MACOSX_BUNDLE_SHORT_VERSION_STRING \${PROJECT_VERSION}" short_version_index)
if(short_version_index EQUAL -1)
    message(FATAL_ERROR "macOS short version must use the complete project version")
endif()

if(NOT nsis_source MATCHES "VERSION=1\\.1\\.20260723" OR
   NOT nsis_source MATCHES "VERSION \"1\\.1\\.20260723\"")
    message(FATAL_ERROR "Windows installer version is not 1.1.20260723")
endif()

foreach(source IN ITEMS changelog_source zh_source en_source)
    if(NOT "${${source}}" MATCHES "20260723")
        message(FATAL_ERROR "${source} does not contain the 20260723 release entry")
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
