#ifndef DATABASEUTIL_H
#define DATABASEUTIL_H

#include <QtSql/QSqlDatabase>
#include <QtSql/QSqlError>
#include <QtSql/QSqlQuery>

class DatabaseUtils {
public:
    static void initializeDatabase();
};

#endif // DATABASEUTIL_H
