#ifndef MTODOLISTMODEL_H
#define MTODOLISTMODEL_H

#include <QAbstractListModel>
#include <QVector>
#include "structs.h"
#include <QDateTime>

class MTodoListModel : public QAbstractListModel {
    Q_OBJECT
public:

    struct FilterCriteria {
        QString title;
        QString description;
        QDateTime fromDatetime;
        QDateTime toDatetime;
        bool status;
        bool filterByStatus = false;
    };

    enum TodoRoles {
        TitleRole = Qt::UserRole + 1,
        DescriptionRole,
        DatetimeRole,
        StatusRole
    };

    MTodoListModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    virtual QHash<int, QByteArray> roleNames() const override;

    // basic session todo
    Q_INVOKABLE void addTodoItem(const QString &title, const QString &description, const QString &datetime);
    Q_INVOKABLE void removeTodoItem(int index);
    Q_INVOKABLE void updateTodoItem(int index, const QString &title, const QString &description, const QString &datetime);
    Q_INVOKABLE void toggleTodoStatus(int index);

    // filter logic
    Q_INVOKABLE void filterTodos(const QString& title = QString(),
                                 const QString& description = QString(),
                                 const QString& fromDatetime = QString(),
                                 const QString& toDatetime = QString(),
                                 bool status = false,
                                 bool filterByStatus = false);
    Q_INVOKABLE void resetFilterCriteria();

    // db logic
    Q_INVOKABLE void saveChanges();



private:
    FilterCriteria m_filterCriteria;
    bool m_isFiltering = false;

    void setFilterCriteria(const FilterCriteria& criteria);
    bool matchesFilter(const TodoItem& item) const;

    int lastId = 0;

    // CRUD
    void CRUDaddTodoItem(const QString &title, const QString &description, const QString &datetime, bool status);
    void CRUDloadTodosFromDatabase();
    void CRUDupdateTodoItem(int id, const QString &title, const QString &description, const QString &datetime, bool status);
    void CRUDremoveTodoItem(int id);

protected:
    QVector<TodoItem> m_items;

};

#endif // MTODOLISTMODEL_H
