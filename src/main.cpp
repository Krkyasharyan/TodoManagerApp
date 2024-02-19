#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QDebug>
#include <iostream>
#include "db/DatabaseUtils.h"
#include "models/MTodoListModel.h"


int main(int argc, char *argv[]) {
    QGuiApplication app(argc, argv);
    std::cout << "QGuiApplication created" << std::endl;

    DatabaseUtils::initializeDatabase();
    std::cout << "SQLite database initialized" << std::endl;

    QQmlApplicationEngine engine;
    std::cout << "QQmlApplicationEngine created" << std::endl;

    qmlRegisterType<MTodoListModel>("Todo", 1, 0, "TodoListModel");
    std::cout << "MTodoListModel registered with QML" << std::endl;

    const QUrl url(QStringLiteral("qrc:/qml/main.qml"));

    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl) {
            qCritical() << "Main QML file could not be loaded. Exiting...";
            QCoreApplication::exit(-1);
        }
    }, Qt::QueuedConnection);

    engine.load(url);

    if (engine.rootObjects().isEmpty()) {
        qCritical() << "Engine root objects are empty. Check if QML files are properly added to resources.";
        return -1;
    }

    qDebug() << "Application loaded and running";
    return app.exec();
}
