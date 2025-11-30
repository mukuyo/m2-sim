#include <QApplication>
#include <QQmlApplicationEngine>
#include <QDebug>

#include "src/observer.h"
#include "src/models/camera.h"
#include "src/utils/motionControl.h"
#include "src/utils/mathUtils.h"

class m2sim {
public:
    explicit m2sim(QQmlApplicationEngine &engine) {
        qmlRegisterType<Observer>("MOC", 1, 0, "Observe");
        qmlRegisterType<Camera>("MOC", 1, 0, "Camera");
        qmlRegisterType<MotionControl>("MOC", 1, 0, "MotionControl");
        qmlRegisterType<MathUtils>("MOC", 1, 0, "MathUtils");
        engine.load(QUrl(QStringLiteral("../src/qml/Main.qml")));
    }
};

int main(int argc, char *argv[]) {
    QApplication app(argc, argv);
    QQmlApplicationEngine engine;
    m2sim m2sim(engine);
    (void) m2sim;
    return app.exec();
}
