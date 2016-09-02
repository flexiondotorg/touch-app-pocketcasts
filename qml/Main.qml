import QtQuick 2.2
import Ubuntu.Web 0.2
import Ubuntu.Components 1.1
import com.canonical.Oxide 1.12 as Oxide
import "UCSComponents"
import Ubuntu.Content 1.1
import QtMultimedia 5.0
import QtFeedback 5.0
import "."
import "../config.js" as Conf

MainView {
    objectName: "mainView"

    applicationName: "jbpocketcasts.flexiondotorg"

    useDeprecatedToolbar: false
    anchorToKeyboard: true
    automaticOrientation: true

    property string myUrl: Conf.webappUrl
    property string myPattern: Conf.webappUrlPattern

    property string myUA: Conf.webappUA ? Conf.webappUA : "Mozilla/5.0 (Linux; Android 5.0; Nexus 5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/38.0.2125.102 Mobile Safari/537.36"

    Page {
        id: page
        anchors {
            fill: parent
            bottom: parent.bottom
        }
        width: parent.width
        height: parent.height

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

        Oxide.WebContext {
            id: webcontext
            userAgent: myUA
            userScripts: [
                Oxide.UserScript {
                    context: webview.contextId
                    url: Qt.resolvedUrl("../keyscript.js")
                }
            ]
        }
        WebView {
            id: webview
            anchors {
                fill: parent
                bottom: parent.bottom
            } 
            width: parent.width
            height: parent.height

            context: webcontext
            url: myUrl
            preferences.localStorageEnabled: true
            preferences.allowFileAccessFromFileUrls: true
            preferences.allowUniversalAccessFromFileUrls: true
            preferences.appCacheEnabled: true
            preferences.javascriptCanAccessClipboard: true
            filePicker: filePickerLoader.item

            readonly property string contextId: "oxide://"
            readonly property int leftKey: 37
            readonly property int rightKey: 39
            readonly property int spaceKey: 32

            function sendKey(key) {
                webview.rootFrame.sendMessage(contextId, "SIMULATE_KEY_EVENT", {key: key})
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
                preferences.localStorageEnabled = true
                if (Qt.application.arguments[1].toString().indexOf(myUrl) > -1) {
                    console.warn("got argument: " + Qt.application.arguments[1])
                    url = Qt.application.arguments[1]
                }
                console.warn("url is: " + url)
            }
            onGeolocationPermissionRequested: { request.accept() }
            Loader {
                id: filePickerLoader
                source: "ContentPickerDialog.qml"
                asynchronous: true
            }
        }
        ThinProgressBar {
            webview: webview
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
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
    }
    Connections {
        target: Qt.inputMethod
        onVisibleChanged: nav.visible = !nav.visible
    }
    Connections {
        target: webview
        onFullscreenChanged: nav.visible = !webview.fullscreen
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
