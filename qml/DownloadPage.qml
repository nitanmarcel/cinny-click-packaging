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
import Lomiri.Components 1.3
import Lomiri.Content 1.3
import Backend 1.0


Page {
    id: picker
    property var activeTransfer

    property string url
    property string handler
    property string contentType

    signal cancel()
    signal imported(string fileUrl)

    header: PageHeader{
        title: i18n.tr("Save With")
        leadingActionBar.actions:[
            Action {
                id: backAction
                iconName: "back"
                text: i18n.tr('Back')
                onTriggered:{
                    Backend.removeDownload(picker.url)
                    pageStack.pop()
                }
            }
        ]
    }
    ContentPeerPicker {
        anchors { fill: parent; topMargin: picker.header.height }
        visible: parent.visible
        showTitle: false
        contentType: ContentType.All
        handler: ContentHandler.Share

        onPeerSelected: {
            //peer.selectionType = ContentTransfer.Single
            picker.activeTransfer = peer.request()
            picker.activeTransfer.stateChanged.connect(function() {
                if (picker.activeTransfer.state === ContentTransfer.InProgress) {
                    console.log("In progress " + picker.url);
                    //picker.activeTransfer.items = picker.activeTransfer.items[0].url = url;
                    picker.activeTransfer.items = [ resultComponent.createObject(parent, {"url": "file://" + picker.url}) ];
                    picker.activeTransfer.state = ContentTransfer.Charged;
                    Backend.removeDownload(picker.url)
                    pageStack.pop()
                }

            })
        }


        onCancelPressed: {
            Backend.removeDownload()
            Backend.removeDownload(picker.url)
            pageStack.pop()
        }
    }

    ContentTransferHint {
        id: transferHint
        anchors.fill: parent
        activeTransfer: picker.activeTransfer
    }
    Component {
        id: resultComponent
        ContentItem {}
    }
}
