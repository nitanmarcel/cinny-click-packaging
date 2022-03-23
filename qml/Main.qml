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
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0
import QtQml 2.12
import QtWebEngine 1.8
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
                .height / (units.gridUnit / 8)
            : 0
        Behavior on bottomMargin {
            NumberAnimation {
                duration : 175
                easing.type : Easing.OutQuad
            }
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
                url : Qt.resolvedUrl(Backend.getIndexPath())
                //zoomFactor : 2.5
                settings.pluginsEnabled : true
                settings.javascriptEnabled : true
                profile : WebEngineProfile {
                    id : webContext
                    storageName : "Storage"
                    persistentStoragePath : "/home/phablet/.cache/cinny.nitanmarcel/cinny.nitanmarcel/QtWebEngine"
                    onDownloadRequested : function (download) {}
                    onDownloadFinished : function (download) {}
                }
                onNewViewRequested : function (request) {
                    request.action = WebEngineNavigationRequest.IgnoreRequest
                    if (request.userInitiated) {
                        if (request
                                .requestedUrl
                                .toString()
                                .match("blod:file:.*")) {}
                        else {
                            Qt.openUrlExternally(request.requestedUrl)
                        }
                    }
                }
                onFileDialogRequested : function (request) {}
            }
        }


        Dialog {
            id : downloadDialog
            parent : mainView
            modal : true
            width : parent.width
            title : "Downloading.."
            standardButtons : Dialog.Cancel
            Column {
                anchors.fill : parent
                Label {
                    text : "Your file is being downloaded."
                }
            }
            onRejected : function () {}
        }
    }
}
