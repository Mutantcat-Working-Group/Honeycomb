# GitHub silently strips non-ASCII bytes from release asset names, so a DMG
# named after the Chinese bundle gets published as "-<version>-macOS-<arch>.dmg".
# This test extracts the real "Collect installer assets" script out of the
# release workflow and runs it, so the guard is exercised instead of assumed.
if(NOT DEFINED SOURCE_DIR)
    message(FATAL_ERROR "SOURCE_DIR is required")
endif()

file(READ "${SOURCE_DIR}/.github/workflows/release.yml" workflow_source)

file(READ "${SOURCE_DIR}/CMakeLists.txt" cmake_source)
if(NOT cmake_source MATCHES "project\\(Honeycomb VERSION ([0-9]+\\.[0-9]+\\.[0-9]+) ")
    message(FATAL_ERROR "Cannot read the project version from CMakeLists.txt")
endif()
set(EXPECTED_VERSION "${CMAKE_MATCH_1}")

# CMake lists are separated by ";", so splitting the workflow into lines would
# silently drop every shell semicolon and produce an unrunnable script. Hide
# them behind a placeholder until the script has been written out.
string(REPLACE ";" "<<HC_SEMI>>" workflow_guarded "${workflow_source}")

string(REGEX MATCHALL "[^\n]*\n" _lines "${workflow_guarded}")
set(_collecting FALSE)
set(_script "")
foreach(_line IN LISTS _lines)
    if(_line MATCHES "^ *- name: Collect installer assets")
        set(_collecting TRUE)
    elseif(_line MATCHES "^ *- name: " AND _collecting)
        set(_collecting FALSE)
    elseif(_collecting)
        if(NOT _line MATCHES "^ *run: \\|")
            string(APPEND _script "${_line}")
        endif()
    endif()
endforeach()

if(_script STREQUAL "")
    message(FATAL_ERROR "Could not extract the Collect installer assets step from release.yml")
endif()

string(REPLACE "<<HC_SEMI>>" ";" _script "${_script}")

if(NOT _script MATCHES "\\$\\{APP_NAME\\}-\\$\\{VERSION\\}-macOS-\\$\\{PKG_ARCH\\}\\.dmg")
    message(FATAL_ERROR "darwin assets must be renamed to an APP_NAME-derived ASCII name")
endif()

# The old behaviour copied whatever the DMG was called, which let a Chinese
# bundle name reach the upload and get mangled by GitHub.
if(_script MATCHES "cp dist/\\*\\.dmg release/")
    message(FATAL_ERROR "Collect installer assets still copies dist/*.dmg verbatim")
endif()

# Publish-time guard, so a bad name cannot slip through in an artifact either.
if(NOT workflow_source MATCHES "refusing to publish non-ASCII asset names")
    message(FATAL_ERROR "release.yml has no ASCII-only guard in the publish job")
endif()

set(_root "${CMAKE_CURRENT_BINARY_DIR}/ReleaseAssetNameTest-sandbox")

file(REMOVE_RECURSE "${_root}")
set(_run_dir "${_root}/run-a")
file(MAKE_DIRECTORY "${_run_dir}/dist")
file(MAKE_DIRECTORY "${_root}")
set(_script_path "${_root}/collect.sh")
file(WRITE "${_script_path}" "${_script}")

# Scenario A: the DMG keeps the Chinese bundle name, which is what CI builds.
file(TOUCH "${_run_dir}/dist/蜂巢工具箱-${EXPECTED_VERSION}-macOS-arm64.dmg")
execute_process(
    COMMAND "${CMAKE_COMMAND}" -E env
        "GITHUB_REF_NAME=v${EXPECTED_VERSION}"
        "OS=darwin"
        "ARCH=arm64"
        "APP_NAME=Honeycomb"
        bash -e "${_script_path}"
    WORKING_DIRECTORY "${_run_dir}"
    RESULT_VARIABLE _result_a
    OUTPUT_VARIABLE _out_a
    ERROR_VARIABLE _err_a
)
if(NOT _result_a EQUAL 0)
    message(FATAL_ERROR "collect step failed on a Chinese-named DMG:\n${_out_a}${_err_a}")
endif()
if(NOT EXISTS "${_run_dir}/release/Honeycomb-${EXPECTED_VERSION}-macOS-arm64.dmg")
    message(FATAL_ERROR "expected release/Honeycomb-${EXPECTED_VERSION}-macOS-arm64.dmg")
endif()

# Scenario B: a non-ASCII or dash-prefixed name anywhere in release/ must fail
# the build instead of being uploaded under a mangled name.
foreach(_bad_name "残留-中文.dmg" "-${EXPECTED_VERSION}-macOS-arm64.dmg")
    set(_bad_dir "${_root}/bad")
    file(REMOVE_RECURSE "${_bad_dir}")
    file(MAKE_DIRECTORY "${_bad_dir}/release")
    file(MAKE_DIRECTORY "${_bad_dir}/dist")
    # A valid DMG has to be present too, otherwise the step would fail for the
    # wrong reason (missing installer) and the guard would never be reached.
    file(TOUCH "${_bad_dir}/dist/蜂巢工具箱-${EXPECTED_VERSION}-macOS-arm64.dmg")
    file(TOUCH "${_bad_dir}/release/${_bad_name}")
    execute_process(
        COMMAND "${CMAKE_COMMAND}" -E env
            "GITHUB_REF_NAME=v${EXPECTED_VERSION}"
            "OS=darwin"
            "ARCH=arm64"
            "APP_NAME=Honeycomb"
            bash -e "${_script_path}"
        WORKING_DIRECTORY "${_bad_dir}"
        RESULT_VARIABLE _result_bad
        OUTPUT_VARIABLE _out_bad
        ERROR_VARIABLE _err_bad
    )
    if(_result_bad EQUAL 0)
        message(FATAL_ERROR "collect step accepted the invalid asset name ${_bad_name}")
    endif()
endforeach()

file(REMOVE_RECURSE "${_root}")
message(STATUS "Release asset naming is guarded at ${EXPECTED_VERSION}")
