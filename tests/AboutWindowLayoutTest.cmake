file(READ "${ABOUT_QML}" about_qml)

string(FIND "${about_qml}" "text: I18n.t(\"aboutVersion\")" version_position)
string(FIND "${about_qml}" "id: bottomActionArea" action_area_position)
string(FIND "${about_qml}" "anchors.bottom: parent.bottom" bottom_anchor_position)
string(FIND "${about_qml}" "id: checkUpdateButton" button_position)
string(FIND "${about_qml}" "parent.hovered ? \"#006cbd\" : \"#0078d4\"" primary_style_position)

if(version_position LESS 0 OR action_area_position LESS 0 OR bottom_anchor_position LESS 0 OR button_position LESS 0)
    message(FATAL_ERROR "About window must define version and a bottom-anchored update action area")
endif()

if(NOT version_position LESS action_area_position OR NOT action_area_position LESS button_position)
    message(FATAL_ERROR "Check update button must be placed in the bottom action area")
endif()

if(primary_style_position LESS 0)
    message(FATAL_ERROR "Check update button must use the standard primary button colors")
endif()
