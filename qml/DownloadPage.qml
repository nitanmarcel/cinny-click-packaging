/*
 * Copyright (C) 2016 Stefano Verzegnassi
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License 3 as published by
 * the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see http://www.gnu.org/licenses/.
 */

import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import Ubuntu.Content 1.3
import Ubuntu.DownloadManager 1.2

import Backend 1.0



Page {
    id: picker
    property var activeTransfer

    property string url
    property string handler
    property string contentType

    property var popup

    signal cancel()
    signal imported(string fileUrl)

    header: PageHeader {
        title: i18n.tr("Save with")
    }

    ContentPeerPicker {
        anchors { fill: parent; topMargin: picker.header.height }
        visible: parent.visible
        showTitle: true
        contentType: ContentType.All
        handler: ContentHandler.Destination

        onPeerSelected: {
            //peer.selectionType = ContentTransfer.Single
            picker.activeTransfer = peer.request()
            picker.activeTransfer.stateChanged.connect(function() {
                if (picker.activeTransfer.state === ContentTransfer.InProgress) {
                    console.log("In progress");
                    //picker.activeTransfer.items = picker.activeTransfer.items[0].url = url;
                    console.log(picker.url)
                    picker.activeTransfer.items = [ resultComponent.createObject(parent, {"url": picker.url}) ];

                    picker.activeTransfer.state = ContentTransfer.Charged;
                    Backend.removeDownload(picker.url)
                    pageStack.pop()
                }
            })
        }
        onCancelPressed: {
            Backend.removeDownload(picker.url)
            pageStack.pop()
        }
    }

    ContentTransferHint {
        id: transferHint
        anchors.fill: parent
        activeTransfer: picker.activeTransfer
    }

    SingleDownload {
        id: singleDownload

        metadata: Metadata {
           showInIndicator: true
        }

        onFinished: function (path) {
            picker.url = "file://" + path
            PopupUtils.close(picker.popup)
        }

        onCanceled: function () {
            PopupUtils.close(picker.popup)
            pageStack.pop()
        }
    }
    Component {
        id: resultComponent
        ContentItem {}
    }

    Component.onCompleted: function () {
        picker.popup = PopupUtils.open(dialogComponent)
        singleDownload.metadata.title = url.substring(url.lastIndexOf("/")+1)
        singleDownload.download(url)
    }

    Component {
        id: dialogComponent
        Dialog {

            id: downloadDialog
            title: i18n.tr("Downloading")

            ProgressBar {
                minimumValue: 0
                maximumValue: 100
                value: singleDownload.progress

                anchors {
                    left: parent.left
                    right: parent.right
                }
            }

            Button {
                text: i18n.tr("Cancel")
                onClicked: {
                    singleDownload.cancel()
                }
            }
        }
    }
}
