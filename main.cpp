#include <QIcon>
#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQuickStyle>
#include <QtQml>

#include "src/RandomNumberGenerator.h"
#include "src/RandomLetterGenerator.h"
#include "src/RandomMixedGenerator.h"
#include "src/BarcodeGenerator.h"
#include "src/QRCodeGenerator.h"
#include "src/JsonYamlConverter.h"
#include "src/ColorPicker.h"
#include "src/ColorSelector.h"
#include "src/MD5Generator.h"
#include "src/SHA1Generator.h"
#include "src/SHA256Generator.h"
#include "src/PasswordStrengthGenerator.h"

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    
    // 设置应用程序图标
    app.setWindowIcon(QIcon(":/qt/qml/Honeycomb/logo.png"));

    // 设置 Qt Quick Controls 样式为 Basic，支持自定义控件外观
    QQuickStyle::setStyle("Basic");

    // 创建图像提供器
    g_barcodeImageProvider = new BarcodeImageProvider();
    g_qrcodeImageProvider = new QRCodeImageProvider();

    // 注册 C++ 类型到 QML
    qmlRegisterType<RandomNumberGenerator>("Honeycomb", 1, 0, "RandomNumberGenerator");
    qmlRegisterType<RandomLetterGenerator>("Honeycomb", 1, 0, "RandomLetterGenerator");
    qmlRegisterType<RandomMixedGenerator>("Honeycomb", 1, 0, "RandomMixedGenerator");
    qmlRegisterType<BarcodeGenerator>("Honeycomb", 1, 0, "BarcodeGenerator");
    qmlRegisterType<QRCodeGenerator>("Honeycomb", 1, 0, "QRCodeGenerator");
    qmlRegisterType<JsonYamlConverter>("Honeycomb", 1, 0, "JsonYamlConverter");
    qmlRegisterType<ColorPicker>("Honeycomb", 1, 0, "ColorPicker");
    qmlRegisterType<ColorSelector>("Honeycomb", 1, 0, "ColorSelector");
    qmlRegisterType<MD5Generator>("Honeycomb", 1, 0, "MD5Generator");
    qmlRegisterType<SHA1Generator>("Honeycomb", 1, 0, "SHA1Generator");
    qmlRegisterType<SHA256Generator>("Honeycomb", 1, 0, "SHA256Generator");
    qmlRegisterType<PasswordStrengthGenerator>("Honeycomb", 1, 0, "PasswordStrengthGenerator");

    QQmlApplicationEngine engine;
    
    // 添加图像提供器到引擎
    engine.addImageProvider("barcode", g_barcodeImageProvider);
    engine.addImageProvider("qrcode", g_qrcodeImageProvider);
    
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.loadFromModule("Honeycomb", "Main");
    return app.exec();
}
