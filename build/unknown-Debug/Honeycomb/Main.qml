import QtQuick
import { currentLang, t } from "qrc:/i18n/i18n.js"

Window {
    width: 640
    height: 480
    visible: true
    title: qsTr(t())
}
