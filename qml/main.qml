import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Todo 1.0
import QtQuick.Controls.Material 2.15
import QtQuick.Dialogs

ApplicationWindow {
    id: mainWindowId
    visible: true
    width: 1080
    height: 800
    color: "#f0f0f0"
    title: "TODO List"
    Material.theme: Material.Light

    property bool closing: false

    onClosing: {
          close.accepted = closing
          onTriggered: if(!closing) saveChangesPopup.open()
       }


    TodoListModel {
        id: todoListModel
    }

    ColumnLayout {
            anchors.fill: parent
            spacing: 10

            TodoView {
                id: todoView
                Layout.fillWidth: true
                Layout.preferredHeight: parent.height - 60
                tvtodoListModel: todoListModel
            }

            // Container for action buttons
            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 50
                spacing: 10
                Layout.alignment: Qt.AlignBottom



                Button {
                    text: "Save and quit"
                    onClicked: {
                        todoListModel.saveChanges();
                        Qt.quit();
                    }
                }

                Item {
                    Layout.fillWidth: true
                }

                Button {
                    text: "Add New Todo"
                    onClicked: todoItemCreationDialog.open()
                }
            }
        }

    Popup {
        id: todoItemCreationDialog
        focus: true
        anchors.centerIn:  parent
        width: parent.width * 0.8
        height: parent.height * 0.6
        modal: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent

        Frame {
            anchors.fill: parent
            TodoItemForm {
                id: creationForm
                tiftodoListModel: todoListModel
                confirmButtonText: "Create"
                isCreate: true
                anchors.fill: parent
            }
        }
    }

    Dialog {
            id: saveChangesPopup
            title: "Confirm Exit"
            modal: true

            // This ensures the dialog is centered
            x: (parent.width - width) / 2
            y: (parent.height - height) / 2

            // Use Material Design's standard layout and theming for the dialog
            Material.background: Material.color(Material.Grey, Material.Shade200)  // Example background color

            ColumnLayout {
                anchors.fill: parent
                spacing: 10

                Text {
                    text: "Do you want to save changes before exiting?"
                    Layout.alignment: Qt.AlignHCenter
                    color: Material.color(Material.Grey, Material.Shade800)  // Example text color
                }

                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 10

                    Button {
                        text: "Save & Quit"
                        Material.background: Material.color(Material.Blue)  // Blue button for "Save & Quit"
                        onClicked: {
                            todoListModel.saveChanges();
                            closing = true
                            mainWindowId.close()
                        }
                    }


                    Button {
                        text: "Cancel"
                        onClicked: {
                            saveChangesPopup.close();
                        }
                    }

                    Button {
                        text: "Quit Without Saving"
                        Material.background: Material.color(Material.Red)  // Red button for "Quit Without Saving"
                        onClicked: {
                            closing = true
                            mainWindowId.close()
                        }
                    }

                }
            }
        }

}
