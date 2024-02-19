#include "db/DatabaseUtils.h"

void DatabaseUtils::initializeDatabase() {
    QSqlDatabase db = QSqlDatabase::addDatabase("QSQLITE");
    db.setDatabaseName("tasks.sqlite");

    if (!db.open()) {
        qFatal("Cannot open database");
        return;
    }

    QSqlQuery query;
    if (!query.exec("CREATE TABLE IF NOT EXISTS todos ("
                    "id INTEGER PRIMARY KEY AUTOINCREMENT, "
                    "title TEXT NOT NULL, "
                    "description TEXT, "
                    "datetime TEXT NOT NULL, "
                    "status BOOLEAN NOT NULL)")) {
        qFatal("Failed to query database");
    }
}
