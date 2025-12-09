#include <QIcon>
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QtQml>

#include "src/RandomNumberGenerator.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    // 注册 C++ 类型到 QML
    qmlRegisterType<RandomNumberGenerator>("Honeycomb", 1, 0, "RandomNumberGenerator");

    QQmlApplicationEngine engine;
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.loadFromModule("Honeycomb", "Main");
    return app.exec();
}
