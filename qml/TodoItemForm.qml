import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: creationForm
    width: parent.width
    height: parent.height
    property var tiftodoListModel: null
    property string confirmButtonText: "Create"
    property bool isCreate: true
    property int index: -1
    property string tifTitle: ""
    property string tifDescription: ""
    property string tifDatetime: ""


    Popup {
        id: datetimePopup
        width: 300
        height: 350
        modal: true

        ColumnLayout {
            anchors.fill: parent
            spacing: 10

            // Custom Calendar
            CustomCalendar {
                id: calendar
                width: 280
                height: 200
                onClicked: function(date) {
                    calendar.selectedDate = date
                    calendar.isSelected = true
                }
            }

            // Custom Time Picker
            RowLayout {
                TextField {
                    id: hourField
                    width: 40
                    placeholderText: "HH"
                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                    maximumLength: 2

                    onEditingFinished: {
                        let hr = parseInt(text);
                        if (isNaN(hr) || hr < 0) {
                            text = "00";
                        } else if (hr > 23) {
                            text = "23";
                        } else if (hr < 10 && text.length < 2) {
                            text = "0" + hr.toString();
                        }
                    }
                }

                Text { text: ":" }

                TextField {
                    id: minuteField
                    width: 40
                    placeholderText: "MM"
                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                    maximumLength: 2

                    onEditingFinished: {
                        let min = parseInt(text);
                        if (isNaN(min) || min < 0) {
                            text = "00";
                        } else if (min > 59) {
                            text = "59";
                        } else if (min < 10 && text.length < 2) {
                            text = "0" + min.toString();
                        }
                    }
                }
            }




            Button {
                text: "Apply"
                onClicked: {
                    // Combine date and time into a single string
                    let formattedDate = Qt.formatDate(calendar.selectedDate, "yyyy-MM-dd");
                    let formattedTime = hourField.text + ":" + minuteField.text + ":00";
                    let datetimeString = formattedDate + "T" + formattedTime;
                    console.log("Selected Datetime:", datetimeString);
                    datetimeField.text = datetimeString;
                    datetimePopup.close();
                }
            }
        }
    }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 10

        TextField {
            id: titleField
            placeholderText: isCreate || tifTitle === "" ? "Title" : tifTitle;
        }

        TextField {
            id: descriptionField
            placeholderText: isCreate || tifDescription === "" ? "Description" : tifDescription;
        }

        TextField {
            id: datetimeField
            placeholderText: isCreate || tifDatetime === "" ? "yyyy-MM-ddTHH:mm:ss" : tifDatetime;
            readOnly: true
        }

        Button {
            id: datetimePopupButton
            text: "Set Datetime"
            onClicked: datetimePopup.open()
        }

        Button {
            text: confirmButtonText
            onClicked: {
                if(isCreate) {
                    tiftodoListModel.addTodoItem(titleField.text, descriptionField.text, datetimeField.text)
                    titleField.text = ""
                    descriptionField.text = ""
                    datetimeField.text = ""
                    todoItemCreationDialog.close()
                }
                else {
                    let resTitle = titleField.text !== "" ? titleField.text : titleField.placeholderText;

                    // TODO: this, when editing, puts yyyy-MM-ddTHH:mm:ss if none is selected
                    let resDescription = descriptionField.text !== "" ? descriptionField.text : descriptionField.placeholderText;

                    let resDatetime = datetimeField.text !== "" ? datetimeField.text : datetimeField.placeholderText;

                    tiftodoListModel.updateTodoItem(index, resTitle, resDescription, resDatetime)
                    titleField.text = ""
                    descriptionField.text = ""
                    datetimeField.text = ""
                    todoItemEditDialog.close()
                }
            }
        }

        Button {
            text: "Close"
            onClicked: {
                titleField.text = ""
                descriptionField.text = ""
                datetimeField.text = ""

                if(isCreate)
                    todoItemCreationDialog.close()
                else
                    todoItemEditDialog.close()
            }
        }
    }
}
