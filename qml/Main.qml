import QtQuick 2.4
import QtMultimedia 5.0
import QtFeedback 5.0
import Ubuntu.Components 1.3
import Ubuntu.Web 0.2
import Ubuntu.Content 1.1
import "../config.js" as Conf
import "./UCSComponents"


MainView {

    objectName: "mainView"

    // Note! applicationName needs to match the "name" field of the click manifest
    applicationName: "jbpocketcasts.flexiondotorg"
    anchorToKeyboard: true

    width: units.gu(100)
    height: units.gu(75)

    property string myUrl: Conf.webappUrl
    property string myPattern: Conf.webappUrlPattern
    property string myUA: Conf.webappUA ? Conf.webappUA : "Mozilla/5.0 (Linux; Android 5.0; Nexus 5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/38.0.2125.102 Mobile Safari/537.36"

    // as we don't need a page header just use a simple Item to contain the main content.
    Item {
        id: mainContent

        anchors.fill: parent

        WebView {
            id: webview

            readonly property int leftKey: 37
            readonly property int rightKey: 39
            readonly property int spaceKey: 32

            anchors.fill: parent
            context: OxideContext {
                id: ctxt
                userAgent: myUA
            }
            url: myUrl
            preferences.localStorageEnabled: true
            preferences.allowFileAccessFromFileUrls: true
            preferences.allowUniversalAccessFromFileUrls: true
            preferences.appCacheEnabled: true
            preferences.javascriptCanAccessClipboard: true
            filePicker: filePickerLoader.item

            function sendKey(key) {
                webview.rootFrame.sendMessageNoReply(ctxt.ctxtId, "SIMULATE_KEY_EVENT", {key: key})
            }

            function navigationRequestedDelegate(request) {
                var url = request.url.toString();
                var pattern = myPattern.split(',');
                var isvalid = false;

                if (Conf.hapticLinks) {
                    vibration.start()
                }

                if (Conf.audibleLinks) {
                    clicksound.play()
                }

                for (var i=0; i<pattern.length; i++) {
                    var tmpsearch = pattern[i].replace(/\*/g,'(.*)')
                    var search = tmpsearch.replace(/^https\?:\/\//g, '(http|https):\/\/');
                    if (url.match(search)) {
                        isvalid = true;
                        break
                    }
                }
                if(isvalid == false) {
                    console.warn("Opening remote: " + url);
                    Qt.openUrlExternally(url)
                    request.action = Oxide.NavigationRequest.ActionReject
                }
            }
            Component.onCompleted: {
                if (Qt.application.arguments[1].toString().indexOf(myUrl) > -1) {
                    console.warn("got argument: " + Qt.application.arguments[1])
                    url = Qt.application.arguments[1]
                }
                console.warn("url is: " + url)
            }
            onGeolocationPermissionRequested: { request.accept() }

            ThinProgressBar {
                webview: webview
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                }
            }

            Loader {
                id: filePickerLoader
                source: "ContentPickerDialog.qml"
                asynchronous: true
            }
        }

        RadialBottomEdge {
            id: nav
            visible: true
            actions: [
                RadialAction {
                    id: play
                    iconName: "media-playback-start"
                    onTriggered: webview.sendKey(webview.spaceKey)
                    text: qsTr("Play/Pause")
                },
                RadialAction {
                    id: forward
                    iconName: "media-skip-forward"
                    onTriggered: webview.sendKey(webview.rightKey)
                    text: qsTr("Forward")
                },
                RadialAction {
                    id: back
                    iconName: "media-skip-backward"
                    onTriggered: webview.sendKey(webview.leftKey)
                    text: qsTr("Back")
                }
            ]
        }

        Connections {
            target: Qt.inputMethod
            onVisibleChanged: nav.visible = !nav.visible
        }
        Connections {
            target: webview
            onFullscreenChanged: nav.visible = !webview.fullscreen
        }

        HapticsEffect {
            id: vibration
            attackIntensity: 0.0
            attackTime: 50
            intensity: 1.0
            duration: 10
            fadeTime: 50
            fadeIntensity: 0.0
        }

        SoundEffect {
            id: clicksound
            source: "../sounds/Click.wav"
        }

        Connections {
            target: UriHandler
            onOpened: {
                if (uris.length === 0 ) {
                    return;
                }
                webview.url = uris[0]
                console.warn("uri-handler request")
            }
        }
    }
}
