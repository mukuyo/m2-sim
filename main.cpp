#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QDebug>
#include <QCoreApplication>

#include "src/observer.h"
#include "src/models/camera.h"
#include "src/utils/motionControl.h"
#include "src/utils/mathUtils.h"

class M2Sim
{
public:
    explicit M2Sim(QQmlApplicationEngine &engine)
    {
        qmlRegisterType<Observer>("M2", 1, 0, "Observer");
        qmlRegisterType<Camera>("M2", 1, 0, "Camera");
        qmlRegisterType<MotionControl>("M2", 1, 0, "MotionControl");
        qmlRegisterType<MathUtils>("M2", 1, 0, "MathUtils");

        const QUrl mainQmlUrl(
            "../src/qml/Main.qml"
        );

        QObject::connect(
            &engine,
            &QQmlApplicationEngine::objectCreated,
            &engine,
            [mainQmlUrl](QObject *obj, const QUrl &objUrl) {
                if (!obj && objUrl == mainQmlUrl) {
                    qCritical() << "Failed to load QML:" << mainQmlUrl;
                    QCoreApplication::exit(-1);
                }
            },
            Qt::QueuedConnection
        );

        engine.load(mainQmlUrl);
    }
};

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
    M2Sim sim(engine);

    return app.exec();
}
