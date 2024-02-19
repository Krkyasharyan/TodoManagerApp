#ifndef STRUCTS_H
#define STRUCTS_H

#include <QString>

struct TodoItem {
    int id;
    QString title;
    QString description;
    QString datetime;
    bool status;

    enum State { New, Modified, Unchanged } state = Unchanged;

    TodoItem() {}
    TodoItem(const QString &title, const QString &description, const QString &datetime, bool status, State state = Unchanged, int id = -1)
        : id(id), title(title), description(description), datetime(datetime), status(status), state(state) {}
};

#endif // STRUCTS_H
