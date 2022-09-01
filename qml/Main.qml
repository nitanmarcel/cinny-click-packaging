/*
 * Copyright (C) 2022  Marcel Alexandru Nitan
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * cinny is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
import QtQuick 2.7
import QtQuick.Layouts 1.0
import QtQuick.Controls 2.1
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import Ubuntu.PushNotifications 0.1
import Ubuntu.Content 1.3
import Ubuntu.DownloadManager 1.2
import QtQuick.Window 2.12
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0
import QtQml 2.12
import QtWebEngine 1.8
import QtWebChannel 1.0
import Backend 1.0

// Comment

MainView {
    id : mainView
    objectName : 'mainView'
    applicationName : 'cinny.nitanmarcel'
    automaticOrientation : true
    backgroundColor : "transparent"
    anchors {
        fill : parent
        bottomMargin : UbuntuApplication.inputMethod.visible
            ? UbuntuApplication
                .inputMethod
                .keyboardRectangle
                .height / Screen.devicePixelRatio
            : 0
        Behavior on bottomMargin {
            NumberAnimation {
                duration : 175
                easing.type : Easing.OutQuad
            }
        }
    }


    Settings {
        id: appSettings
        property string systemTheme: 'Ambiance'
        property string pushToken: ''
        property string pushAppId: 'cinny.nitanmarcel_cinny'
        property bool windowActive: true
    }

    Component.onCompleted: function () {
        theme.name = ""
        appSettings.systemTheme = theme.name.substring(theme.name.lastIndexOf(".")+1)
    }
    onActiveChanged: () => {appSettings.windowActive = mainView.active}

    function setCurrentTheme(themeName) {
            if (themeName === "System") {
              theme.name = "";
            }
            else if (themeName === "SuruDark") {
                theme.name = "Ubuntu.Components.Themes.SuruDark"
            }
            else if (themeName === "Ambiance") {
                theme.name = "Ubuntu.Components.Themes.Ambiance"
            }
            else {
              theme.name = "";
            }
        }
    
    PageStack {
        id : mainPageStack
        anchors.fill : parent
        Component.onCompleted : mainPageStack.push(mainPage)
        Page {
            id : mainPage
            anchors.fill : parent
            WebEngineView {
                id : webView
                anchors.fill : parent
                focus : true
                url : "http://localhost:19999/"
                webChannel: channel
                settings.pluginsEnabled : true
                settings.javascriptEnabled : true
                profile : WebEngineProfile {
                    id : webContext
                    storageName : "Storage"
                    persistentStoragePath : "/home/phablet/.local/share/cinny.nitanmarcel/QWebEngine"

                    onDownloadRequested: function (download) {
                         download.accept()
                    }

                }
                onNewViewRequested : function (request) {
                    request.action = WebEngineNavigationRequest.IgnoreRequest
                    if (request.requestedUrl !== "ignore://") {
                        Qt.openUrlExternally(request.requestedUrl)
                    }
                }
                onFileDialogRequested : function (request) {
                    request.accepted = true;
                    var uploadPage = mainPageStack.push(Qt.resolvedUrl("UploadPage.qml"), {"contentType": ContentType.All, "handler": ContentHandler.Source})
                    uploadPage.imported.connect(function (fileUrl) {
                        request.dialogAccept(fileUrl);
                    })
                    uploadPage.rejected.connect(function () {
                        request.dialogReject()
                    })
                }

                onFullScreenRequested : function (request) {
                    request.accept()
                    if (request.toggleOn)
                        window.showFullScreen()
                    else
                        window.showNormal()
                }

            }

            Connections {
                target: UriHandler

                onOpened: {
                    let result = uris[0].toString().replace("cinny://sso/", webView.url.toString())
                    webView.url = result
                  }
              }

            WebChannel {
                id: channel
                registeredObjects: [webChannelObject]
            }

            QtObject {
                id: webChannelObject
                WebChannel.id: "webChannelBackend"

                property alias settings: appSettings
                property alias push: pushClient

                signal matrixPushTokenChanged();

                function handleDownload(fileBase64, fileName) {
                    var filePath = Backend.saveBase64File(fileBase64, fileName)
                    console.log("Downloaded to " + filePath)
                    var downloadPage = mainPageStack.push(Qt.resolvedUrl("DownloadPage.qml"), {"url": filePath, "contentType": ContentType.All, "handler": ContentHandler.Destination})
                }

                function setTheme(themeName) {
                    setCurrentTheme(themeName)
                }
            }
        }
    }

    PushClient {
        id: pushClient
        appId: appSettings.pushAppId

        onTokenChanged: {
            appSettings.pushToken = token
            webChannelObject.matrixPushTokenChanged();
        }
    }
}
