import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    property var ftodoListModel: null

    Rectangle {
        anchors.fill: parent
        color: "#f0f0f0"
        radius: 8

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 20

            // Filters Row
            RowLayout {
                spacing: 10
                Layout.alignment: Qt.AlignHCenter

                // Title Filter
                TextField {
                    id: titleFilter
                    placeholderText: "Filter by title..."
                    Layout.preferredWidth: 200
                    onEditingFinished: applyFilters()
                }
                Button {
                    icon.source: "/resources/icons/reset_icon.png"
                    icon.color: "transparent"
                    onClicked: {
                        titleFilter.text = "";
                        applyFilters()
                    }
                    visible: titleFilter.text !== ""
                }

                // Description Filter
                TextField {
                    id: descriptionFilter
                    placeholderText: "Filter by description..."
                    Layout.preferredWidth: 200
                    onEditingFinished: applyFilters()
                }
                Button {
                    icon.source: "/resources/icons/reset_icon.png"
                    icon.color: "transparent"
                    onClicked: { descriptionFilter.text = ""; applyFilters(); }
                    visible: descriptionFilter.text !== ""
                }

                // From Date Selection and Display
                Button {
                    text: "From Date"
                    onClicked: fromDatePopup.open()
                }
                Label {
                    text: fromDate.isSelected ? fromDate.selectedDate.toLocaleDateString(Qt.locale(), "yyyy-MM-dd") : "Select from date"
                }
                Button {
                    icon.source: "/resources/icons/reset_icon.png"
                    icon.color: "transparent"
                    onClicked: {
                        fromDate.selectedDate = new Date()
                        fromDate.isSelected = false
                        applyFilters()
                    }
                    visible: fromDate.isSelected
                }

                // To Date Selection and Display
                Button {
                    text: "To Date"
                    onClicked: toDatePopup.open()
                }
                Label {
                    text: toDate.isSelected ? toDate.selectedDate.toLocaleDateString(Qt.locale(), "yyyy-MM-dd") : "Select to date"
                }
                Button {
                    icon.source: "/resources/icons/reset_icon.png"
                    icon.color: "transparent"
                    onClicked: {
                        toDate.selectedDate = new Date()
                        toDate.isSelected = false
                        applyFilters()
                    }
                    visible: toDate.isSelected
                }

                // Status Filter Button and Indicator
                Button {
                    id: statusFilterButton
                    text: "Filter by status"
                    onClicked: statusPopup.open()
                }
                Label {
                    id: statusIndicator
                    text: statusIndicator.filterByStatus ? (statusIndicator.status ? "✅" : "❌") : "⚪"

                    property bool filterByStatus: false
                    property bool status: false
                }
                Button {
                    icon.source: "/resources/icons/reset_icon.png"
                    icon.color: "transparent"
                    onClicked: {
                        statusIndicator.filterByStatus = false
                        statusIndicator.text = "⚪"
                        applyFilters()
                    }
                    visible: statusIndicator.filterByStatus
                }
            }

            // Apply and Reset Filters Row
            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 10

                // Reset Filters Button
                Button {
                    text: "Reset All Filters"
                    onClicked: resetFilters()
                }
            }
        }
    }

    function applyFilters() {
        var formattedFromDate = fromDate.isSelected ? (Qt.formatDate(fromDate.selectedDate, "yyyy-MM-dd") + "T00:00:00") : "";
        var formattedToDate = toDate.isSelected ? (Qt.formatDate(toDate.selectedDate, "yyyy-MM-dd") + "T23:59:59") : "";

        todoListModel.filterTodos(titleFilter.text,
                                  descriptionFilter.text,
                                  formattedFromDate,
                                  formattedToDate,
                                  statusIndicator.status,
                                  statusIndicator.filterByStatus);

        console.log("Applying filters...");
    }

    function resetFilters() {
        titleFilter.text = "";
        descriptionFilter.text = "";
        fromDate.selectedDate = new Date();
        fromDate.isSelected = false;
        toDate.selectedDate = new Date();
        toDate.isSelected = false;
        statusIndicator.text = "⚪";
        statusIndicator.filterByStatus = false;
        statusIndicator.status = false;

        todoListModel.resetFilterCriteria();

        console.log("Resetting filters...");
    }

    Popup {
        id: fromDatePopup
        width: 300
        height: 400
        modal: true
        contentItem: CustomCalendar {
            id: fromDate
            onClicked: function(date) {
                fromDate.selectedDate = date
                fromDate.isSelected = true
                applyFilters()
                fromDatePopup.close();
            }
        }
    }

    Popup {
        id: toDatePopup
        width: 300
        height: 400
        modal: true
        contentItem: CustomCalendar {
            id: toDate
            onClicked: function(date) {
                toDate.selectedDate = date
                toDate.isSelected = true
                applyFilters()
                toDatePopup.close();
            }
        }
    }

    Popup {
        id: statusPopup
        x: statusFilterButton.x
        y: statusFilterButton.height*2
        width: 80
        height: 80

        ColumnLayout {
            anchors.fill: parent
            Button {
                text: "Done"
                onClicked: {
                    console.log("Filtering by status: Done");
                    statusIndicator.status = true
                    statusIndicator.filterByStatus = true
                    statusIndicator.text = "✅";
                    applyFilters()
                    statusPopup.close();
                }
            }
            Button {
                text: "Pending"
                onClicked: {
                    console.log("Filtering by status: Pending");
                    statusIndicator.status = false
                    statusIndicator.filterByStatus = true
                    statusIndicator.text = "🟡";
                    applyFilters()
                    statusPopup.close();
                }
            }
        }
    }

}
