#include "models/MTodoListModel.h"
#include <QSqlQuery>
#include <QSqlError>

MTodoListModel::MTodoListModel(QObject *parent)
    : QAbstractListModel(parent) {
    // init
    CRUDloadTodosFromDatabase();
}

int MTodoListModel::rowCount(const QModelIndex &parent) const {
    if (parent.isValid())
        return 0;

    if (!m_isFiltering) return m_items.size();

    // Count items that match the filter
    return std::count_if(m_items.begin(), m_items.end(), [this](const TodoItem& item){
        return matchesFilter(item);
    });
}

QVariant MTodoListModel::data(const QModelIndex &index, int role) const {
    if (!index.isValid())
        return QVariant();

    // Find the nth item that matches the filter
    int filteredIndex = 0;
    for (const auto& item : m_items) {
        if (matchesFilter(item)) {
            if (filteredIndex == index.row()) {
                switch (role) {
                case TitleRole: return item.title;
                case DescriptionRole: return item.description;
                case DatetimeRole: return item.datetime;
                case StatusRole: return item.status;
                default: return QVariant();
                }
            }
            filteredIndex++;
        }
    }
    return QVariant();
}

QHash<int, QByteArray> MTodoListModel::roleNames() const {
    QHash<int, QByteArray> roles;
    roles[TitleRole] = "title";
    roles[DescriptionRole] = "description";
    roles[DatetimeRole] = "datetime";
    roles[StatusRole] = "status";
    return roles;
}

void MTodoListModel::addTodoItem(const QString &title, const QString &description, const QString &datetime) {
    beginInsertRows(QModelIndex(), m_items.size(), m_items.size());
    m_items.append(TodoItem(title, description, datetime, false, TodoItem::New, lastId++));
    endInsertRows();
}

void MTodoListModel::removeTodoItem(int index) {
    if (index < 0 || index >= m_items.size())
        return;
    CRUDremoveTodoItem(m_items[index].id);
    beginRemoveRows(QModelIndex(), index, index);
    m_items.removeAt(index);
    endRemoveRows();
}

void MTodoListModel::updateTodoItem(int index, const QString &title, const QString &description, const QString &datetime) {
    if (index < 0 || index >= m_items.size())
        return;
    m_items[index].title = title;
    m_items[index].description = description;
    m_items[index].datetime = datetime;
    if(m_items[index].state != TodoItem::New)
        m_items[index].state = TodoItem::Modified;
    emit dataChanged(createIndex(index, 0), createIndex(index, 0));
}

void MTodoListModel::toggleTodoStatus(int index) {
    if(index < 0 || index >= m_items.size()) return;
    m_items[index].status = !m_items[index].status;
    if(m_items[index].state != TodoItem::New)
        m_items[index].state = TodoItem::Modified;
    QModelIndex modelIndex = createIndex(index, 0);
    emit dataChanged(modelIndex, modelIndex, {StatusRole});
}

// Filtering

void MTodoListModel::setFilterCriteria(const FilterCriteria& criteria) {
    beginResetModel();
    m_filterCriteria = criteria;
    m_isFiltering = true;
    endResetModel();
}

bool MTodoListModel::matchesFilter(const TodoItem& item) const {
    if (m_isFiltering) {
        if (!m_filterCriteria.title.isEmpty() && !item.title.contains(m_filterCriteria.title, Qt::CaseInsensitive))
            return false;
        if (!m_filterCriteria.description.isEmpty() && !item.description.contains(m_filterCriteria.description, Qt::CaseInsensitive))
            return false;
        if (m_filterCriteria.filterByStatus && item.status != m_filterCriteria.status)
            return false;
        // Compare dates if fromDatetime and toDatetime are valid
        QDateTime itemDt = QDateTime::fromString(item.datetime, "yyyy-MM-ddTHH:mm:ss"); 
        if (m_filterCriteria.fromDatetime.isValid() && itemDt <= m_filterCriteria.fromDatetime)
            return false;
        if (m_filterCriteria.toDatetime.isValid() && itemDt >= m_filterCriteria.toDatetime)
            return false;
    }
    return true;
}

void MTodoListModel::filterTodos(const QString& title,
                                 const QString& description,
                                 const QString& fromDatetime,
                                 const QString& toDatetime,
                                 bool status,
                                 bool filterByStatus){

    m_filterCriteria.status = status;
    m_filterCriteria.filterByStatus = filterByStatus;
    m_filterCriteria.title = title;
    m_filterCriteria.description = description;
    m_filterCriteria.fromDatetime = fromDatetime.isEmpty() ? QDateTime() : QDateTime::fromString(fromDatetime, "yyyy-MM-ddTHH:mm:ss");

    m_filterCriteria.toDatetime = toDatetime.isEmpty() ? QDateTime() : QDateTime::fromString(toDatetime, "yyyy-MM-ddTHH:mm:ss");

    setFilterCriteria(m_filterCriteria);
}

void MTodoListModel::resetFilterCriteria() {
    beginResetModel();
    m_isFiltering = false;
    m_filterCriteria = {};
    endResetModel();
}

// CRUD
void MTodoListModel::CRUDaddTodoItem(const QString &title, const QString &description, const QString &datetime, bool status) {
    QSqlQuery query;
    query.prepare("INSERT INTO todos (title, description, datetime, status) VALUES (?, ?, ?, ?)");
    query.addBindValue(title);
    query.addBindValue(description);
    query.addBindValue(datetime);
    query.addBindValue(status);
    if (!query.exec()) {
        qDebug() << "addTodoItem error:" << query.lastError().text();
    }
}

void MTodoListModel::CRUDloadTodosFromDatabase() {
    QSqlQuery query("SELECT id, title, description, datetime, status FROM todos");
    while (query.next()) {
        int id = query.value(0).toInt();
        QString title = query.value(1).toString();
        QString description = query.value(2).toString();
        QString datetime = query.value(3).toString();
        bool status = query.value(4).toBool();

        lastId = id;

        beginInsertRows(QModelIndex(), m_items.size(), m_items.size());
        m_items.append({title, description, datetime, status, TodoItem::Unchanged, id});
        endInsertRows();
    }
}

void MTodoListModel::CRUDupdateTodoItem(int id, const QString &title, const QString &description, const QString &datetime, bool status) {
    QSqlQuery query;
    query.prepare("UPDATE todos SET title = ?, description = ?, datetime = ?, status = ? WHERE id = ?");
    query.addBindValue(title);
    query.addBindValue(description);
    query.addBindValue(datetime);
    query.addBindValue(status);
    query.addBindValue(id);
    if (!query.exec()) {
        qDebug() << "updateTodoItem error:" << query.lastError().text();
    }
}

void MTodoListModel::CRUDremoveTodoItem(int id) {
    QSqlQuery query;
    query.prepare("DELETE FROM todos WHERE id = ?");
    query.addBindValue(id);
    if (!query.exec()) {
        qDebug() << "removeTodoItem error:" << query.lastError().text();
    }
}

void MTodoListModel::saveChanges() {
    QSqlDatabase db = QSqlDatabase::database();
    db.transaction();

    for (const auto &item : m_items) {
        switch (item.state) {
        case TodoItem::New:
            CRUDaddTodoItem(item.title, item.description, item.datetime, item.status);
            break;
        case TodoItem::Modified:
            CRUDupdateTodoItem(item.id, item.title, item.description, item.datetime, item.status);
            break;
        default:
            // No action needed for unchanged items
            break;
        }
    }

    if (db.commit()) {
        qDebug() << "Changes saved successfully";
        // Optionally, reset the state of all items to Unchanged
    } else {
        db.rollback();
        qDebug() << "Failed to save changes";
    }
}


