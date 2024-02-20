import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.15


Item {
    width: parent.width
    height: parent.height-200
    property var tvtodoListModel: null

    Material.theme: Material.Light

    ColumnLayout {
        anchors.fill: parent
        spacing: 10


        Filter {
            id: todoFilter
            width: 1080
            height: 120
            Layout.alignment: Qt.AlignHCenter

            ftodoListModel: tvtodoListModel
        }

        ListView {
            id: todoListView
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: tvtodoListModel
            clip: true
            spacing: 2

            delegate: Rectangle {
                width: todoListView.width
                height: 100
                color: model.status ? "#89CFF0" : "#f9f9f9"
                border.color: "#dcdcdc"
                border.width: 1
                radius: 10

                RowLayout {
                    anchors.fill: parent
                    spacing: 10
                    anchors.margins: 8

                    CheckBox {
                        id: doneCheckBox
                        checked: model.status
                        Layout.alignment: Qt.AlignVCenter
                        onCheckedChanged: {
                            if (checked !== model.status) {
                                tvtodoListModel.toggleTodoStatus(index)
                            }
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                        spacing: 4

                        Text {
                            text: model.title
                            font.bold: true
                            font.pixelSize: 16
                            color: "#333333"
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }

                        Text {
                            text: model.description
                            font.pixelSize: 14
                            color: "#666666"
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }

                        Text {
                            text: model.datetime
                            font.pixelSize: 12
                            color: "#aaaaaa"
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }
                    }

                    // Spacer to push buttons to the right
                    Item {
                        Layout.fillWidth: true
                    }

                    Button {
                        text: qsTr("Edit")
                        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                        onClicked: {
                            todoItemEditDialog.index = index
                            todoItemEditDialog.title = model.title
                            todoItemEditDialog.description = model.description
                            todoItemEditDialog.datetime = model.datetime
                            todoItemEditDialog.open()
                        }
                    }

                    Button {
                        text: qsTr("Delete")
                        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                        onClicked: {
                            tvtodoListModel.removeTodoItem(index)
                        }
                    }
                }
            }
        }


        Popup {
            id: todoItemEditDialog
            focus: true
            anchors.centerIn:  parent
            width: parent.width * 0.8
            height: parent.height * 0.6
            modal: true
            closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent

            property int index: -1
            property string title: ""
            property string description: ""
            property string datetime: ""

            Frame {
                anchors.fill: parent
                TodoItemForm {
                    id: creationForm
                    tiftodoListModel: tvtodoListModel
                    confirmButtonText: "Edit"
                    index: todoItemEditDialog.index
                    isCreate: false
                    anchors.fill: parent
                    tifTitle: todoItemEditDialog.title
                    tifDescription: todoItemEditDialog.description
                    tifDatetime: todoItemEditDialog.datetime
                }
            }
        }
    }
}
