import QtQuick 2.4
import Ubuntu.Components 1.3
import com.canonical.Oxide 1.12 as Oxide

Oxide.WebContext {

    property string ctxtId: "oxide://key-sim/"

    userScripts: [
        Oxide.UserScript {
            context: ctxtId
            url: Qt.resolvedUrl("../keyscript.js")
            matchAllFrames: true
        }
    ]
}
