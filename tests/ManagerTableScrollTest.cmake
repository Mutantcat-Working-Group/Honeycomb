foreach(manager_qml IN ITEMS "${PROCESS_QML}" "${PORT_QML}")
    file(READ "${manager_qml}" manager_source)

    string(FIND "${manager_source}" "ScrollBar.vertical: ScrollBar" scrollbar_position)
    string(FIND "${manager_source}" "policy: ScrollBar.AsNeeded" policy_position)
    string(FIND "${manager_source}" "boundsBehavior: Flickable.StopAtBounds" bounds_position)

    if(scrollbar_position LESS 0 OR policy_position LESS 0 OR bounds_position LESS 0)
        message(FATAL_ERROR "${manager_qml} must provide a visible, as-needed vertical table scrollbar")
    endif()
endforeach()
