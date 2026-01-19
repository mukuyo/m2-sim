#ifndef OBSERVER_H
#define OBSERVER_H

#include <QObject>
#include <QThread>
#include <QUdpSocket>
#include <QHostAddress>
#include <QSettings>
#include <QTimer>
#include <QElapsedTimer>
#include <iostream>
#include "networks/receiver.h"
#include "networks/sender.h"
#include "models/robot.h"
#include "mocSim_Packet.pb.h"
#include "ssl_simulation_robot_control.pb.h"

using namespace std;

class Observer : public QObject {
    Q_OBJECT
    Q_PROPERTY(QList<QObject*> blue_robots READ getBlueRobots NOTIFY blueRobotsChanged)
    Q_PROPERTY(QList<QObject*> yellow_robots READ getYellowRobots NOTIFY yellowRobotsChanged)
    Q_PROPERTY(int windowWidth READ getWindowWidth WRITE setWindowWidth NOTIFY settingChanged)
    Q_PROPERTY(int windowHeight READ getWindowHeight WRITE setWindowHeight NOTIFY settingChanged)
    Q_PROPERTY(QString visionMulticastAddress READ getVisionMulticastAddress WRITE setVisionMulticastAddress NOTIFY settingChanged)
    Q_PROPERTY(int visionMulticastPort READ getVisionMulticastPort WRITE setVisionMulticastPort NOTIFY settingChanged)
    Q_PROPERTY(int commandListenPort READ getCommandListenPort WRITE setCommandListenPort NOTIFY settingChanged)
    Q_PROPERTY(int blueTeamControlPort READ getBlueTeamControlPort WRITE setBlueTeamControlPort NOTIFY settingChanged)
    Q_PROPERTY(int yellowTeamControlPort READ getYellowTeamControlPort WRITE setYellowTeamControlPort NOTIFY settingChanged)
    Q_PROPERTY(bool forceDebugDrawMode READ getForceDebugDrawMode WRITE setForceDebugDrawMode NOTIFY settingChanged)
    Q_PROPERTY(bool lightBlueRobotMode READ getLightBlueRobotMode WRITE setLightBlueRobotMode NOTIFY settingChanged)
    Q_PROPERTY(bool lightYellowRobotMode READ getLightYellowRobotMode WRITE setLightYellowRobotMode NOTIFY settingChanged)
    Q_PROPERTY(bool lightStadiumMode READ getLightStadiumMode WRITE setLightStadiumMode NOTIFY settingChanged)
    Q_PROPERTY(bool lightFieldMode READ getLightFieldMode WRITE setLightFieldMode NOTIFY settingChanged)
    Q_PROPERTY(int blueRobotCount READ getBlueRobotCount WRITE setBlueRobotCount NOTIFY settingChanged)
    Q_PROPERTY(int yellowRobotCount READ getYellowRobotCount WRITE setYellowRobotCount NOTIFY settingChanged)
    Q_PROPERTY(float ballRestitution READ getBallRestitution WRITE setBallRestitution NOTIFY settingChanged)
    Q_PROPERTY(float rollingFriction READ getRollingFriction WRITE setRollingFriction NOTIFY settingChanged)
    Q_PROPERTY(float kickerFriction READ getKickerFriction WRITE setKickerFriction NOTIFY settingChanged)
    Q_PROPERTY(float gravity READ getGravity WRITE setGravity NOTIFY settingChanged)
    Q_PROPERTY(float desiredFps READ getDesiredFps WRITE setDesiredFps NOTIFY settingChanged)
    Q_PROPERTY(bool ccdMode READ getCcdMode WRITE setCcdMode NOTIFY settingChanged)
    Q_PROPERTY(int numThreads READ getNumThreads WRITE setNumThreads NOTIFY settingChanged)
    Q_PROPERTY(bool hideBallMode READ getHideBallMode WRITE setHideBallMode NOTIFY settingChanged)
    // Q_PROPERTY(int fieldWidth READ getFieldWidth WRITE setFieldWidth NOTIFY settingChanged)
    // Q_PROPERTY(int fieldHeight READ getFieldHeight WRITE setFieldHeight NOTIFY settingChanged)
    // Q_PROPERTY(int lineThickness READ getLineThickness WRITE setLineThickness NOTIFY settingChanged)
    // Q_PROPERTY(int centerCircleRadius READ getCenterCircleRadius WRITE setCenterCircleRadius NOTIFY settingChanged)
    // Q_PROPERTY(int goalWidth READ getGoalWidth WRITE setGoalWidth NOTIFY settingChanged)
    // Q_PROPERTY(int goalDepth READ getGoalDepth WRITE setGoalDepth NOTIFY settingChanged)
    // Q_PROPERTY(int goalHeight READ getGoalHeight WRITE setGoalHeight NOTIFY settingChanged)
    // Q_PROPERTY(int goalThickness READ getGoalThickness WRITE setGoalThickness NOTIFY settingChanged)
    // Q_PROPERTY(int wallThickness READ getWallThickness WRITE setWallThickness NOTIFY settingChanged)
    // Q_PROPERTY(int penaltyPoint READ getPenaltyPoint WRITE setPenaltyPoint NOTIFY settingChanged)
    // Q_PROPERTY(int penaltyWidth READ getPenaltyWidth WRITE setPenaltyWidth NOTIFY settingChanged)
    // Q_PROPERTY(int penaltyHeight READ getPenaltyHeight WRITE setPenaltyHeight NOTIFY settingChanged)

public:
    explicit Observer(QObject *parent = nullptr);
    ~Observer();

    Q_INVOKABLE void updateObjects(
        QList<QVector3D> blue_positions, 
        QList<QVector3D> yellow_positions, 
        QList<QVector2D> blueBallPixels, 
        QList<QVector2D> yellowBallPixels,
        QList<bool> blueBallCameraExists,
        QList<bool> yellowBallCameraExists,
        QList<bool> bBotBallContacts, 
        QList<bool> yBotBallContacts, 
        QVector3D ball_position,
        bool isFoundBall
    );

    void start(quint16 port);
    void stop();

    void visionReceive(mocSim_Packet packet);
    void controlReceive(RobotControl packet, bool isYellow);
    void updateSender();

    QList<QObject*> getBlueRobots() const {
        QList<QObject*> blueList;
        for (int i = 0; i < blueRobotCount; ++i) {
            blueList.append(blue_robots[i]);
        }
        return blueList;
    }
    QList<QObject*> getYellowRobots() const {
        QList<QObject*> yellowList;
        for (int i = 0; i < yellowRobotCount; ++i) {
            yellowList.append(yellow_robots[i]);
        }
        return yellowList;
    }
    int getWindowWidth() const { return windowWidth; }
    int getWindowHeight() const { return windowHeight; }
    QString getVisionMulticastAddress() const { return visionMulticastAddress; }
    int getVisionMulticastPort() const { return visionMulticastPort; }
    int getCommandListenPort() const { return commandListenPort; }
    int getBlueTeamControlPort() const { return blueTeamControlPort; }
    int getYellowTeamControlPort() const { return yellowTeamControlPort; }
    bool getForceDebugDrawMode() const { return forceDebugDrawMode; }
    bool getLightBlueRobotMode() const { return lightBlueRobotMode; }
    bool getLightYellowRobotMode() const { return lightYellowRobotMode; }
    bool getLightStadiumMode() const { return lightStadiumMode; }
    bool getLightFieldMode() const { return lightFieldMode; }
    int getBlueRobotCount() const { return blueRobotCount; }
    int getYellowRobotCount() const { return yellowRobotCount; }
    float getBallRestitution() const { return ballRestitution; }
    float getRollingFriction() const { return rollingFriction; }
    float getKickerFriction() const { return kickerFriction; }
    float getGravity() const { return gravity; }
    float getDesiredFps() const { return desiredFps; }
    bool getCcdMode() const { return ccdMode; }
    int getNumThreads() const { return numThreads; }
    bool getHideBallMode() const { return hideBallMode; }
    
    void setWindowWidth(int width);
    void setWindowHeight(int height);
    void setVisionMulticastAddress(const QString &address);
    void setVisionMulticastPort(int port);
    void setCommandListenPort(int port);
    void setBlueTeamControlPort(int port);
    void setYellowTeamControlPort(int port);
    void setForceDebugDrawMode(bool mode);
    void setLightBlueRobotMode(bool mode);
    void setLightYellowRobotMode(bool mode);
    void setLightStadiumMode(bool mode);
    void setLightFieldMode(bool mode);
    void setBlueRobotCount(int count);
    void setYellowRobotCount(int count);
    void setBallRestitution(float restitution);
    void setRollingFriction(float friction);
    void setKickerFriction(float friction);
    void setGravity(float gravity);
    void setDesiredFps(int fps);
    void setCcdMode(bool mode);
    void setNumThreads(int threads);
    void setHideBallMode(bool mode);
    void updateSimulator();
    
signals:
    void blueRobotsChanged();
    void yellowRobotsChanged();
    void settingChanged();
    void sendBotBallContacts(
        const QList<bool> &bBotBallContacts, 
        const QList<bool> &yBotBallContacts,
        const QList<bool> &bBallCameraExists,
        const QList<bool> &yBallCameraExists,
        const QList<QVector2D> &bBallCameraPositions,
        const QList<QVector2D> &yBallCameraPositions
    );
    void updateSenderData(QVector3D ball, QList<QVector3D> blue, QList<QVector3D> yellow);
    void updateSimulationSignal();

private:
    QSettings config;
    QTimer *timer;

    VisionReceiver *visionReceiver;
    ControlBlueReceiver *controlBlueReceiver;
    ControlYellowReceiver *controlYellowReceiver;

    Sender *sender;

    Robot *blue_robots[16];
    Robot *yellow_robots[16];

    int windowWidth;
    int windowHeight;
    int numThreads;

    QString visionMulticastAddress;
    int visionMulticastPort;
    int commandListenPort;
    int blueTeamControlPort;
    int yellowTeamControlPort;

    bool forceDebugDrawMode;
    bool lightBlueRobotMode;
    bool lightYellowRobotMode;
    bool lightStadiumMode;
    bool lightFieldMode;

    int blueRobotCount;
    int yellowRobotCount;

    float ballStaticFriction;
    float ballDynamicFriction;
    float ballRestitution;
    float rollingFriction;
    float kickerFriction;
    float gravity;
    int desiredFps;
    bool ccdMode;
    bool hideBallMode;

    QList<QVector3D> bluePositions;
    QList<QVector3D> yellowPositions;
    QVector3D ballPosition;

    RobotControlResponse robotControlResponse;

    QElapsedTimer elapsedTimer;
    QTimer *loopTimer;
    float frameInterval;
    QElapsedTimer elapsed;
    qint64 prevTimeMs;
    double fps;
};

#endif // OBSERVER_H
