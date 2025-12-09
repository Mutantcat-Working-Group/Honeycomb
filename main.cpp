#include <QIcon>
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QtQml>

#include "src/RandomNumberGenerator.h"
#include "src/RandomLetterGenerator.h"
#include "src/RandomMixedGenerator.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    // 注册 C++ 类型到 QML
    qmlRegisterType<RandomNumberGenerator>("Honeycomb", 1, 0, "RandomNumberGenerator");
    qmlRegisterType<RandomLetterGenerator>("Honeycomb", 1, 0, "RandomLetterGenerator");
    qmlRegisterType<RandomMixedGenerator>("Honeycomb", 1, 0, "RandomMixedGenerator");

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
