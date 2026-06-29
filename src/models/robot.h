#ifndef ROBOT_H
#define ROBOT_H

#include <iostream>
#include <deque>
#include <QObject>
#include <QVector3D>
#include <QVariantList>
#include <QElapsedTimer>
#include <QRandomGenerator>
#include <QDebug>

#include "mocSim_Commands.pb.h"
#include "ssl_simulation_robot_control.pb.h"
#include "ssl_simulation_robot_feedback.pb.h"

using namespace std;

class Robot : public QObject {
    Q_OBJECT

    Q_PROPERTY(uint32_t id READ getId)
    Q_PROPERTY(float kickspeedx READ getKickspeedx)
    Q_PROPERTY(float kickspeedz READ getKickspeedz)
    Q_PROPERTY(float veltangent READ getVeltangent)
    Q_PROPERTY(float velnormal READ getVelnormal)
    Q_PROPERTY(float velangular READ getVelangular)
    Q_PROPERTY(float spinner READ getSpinner)
    Q_PROPERTY(bool wheelsspeed READ getWheelsspeed)
    Q_PROPERTY(float wheel1 READ getWheel1)
    Q_PROPERTY(float wheel2 READ getWheel2)
    Q_PROPERTY(float wheel3 READ getWheel3)
    Q_PROPERTY(float wheel4 READ getWheel4)

public:
    explicit Robot(QObject *parent = nullptr);
    ~Robot();

    void visionUpdate(mocSim_Robot_Command robotCommand);
    void controlUpdate(RobotCommand robotCommand);

    // Actuation delay model: shapes how the commanded body velocity reaches the
    // simulator (transport dead time + first-order lag), so RAVEN's OC has a
    // realistic plant to compensate. All seconds; 0 ⇒ ideal passthrough.
    void setActuationParams(float tauLinearSec, float tauAngularSec,
                            float deadTimeLinearSec, float deadTimeAngularSec);
    // Advance applied velocity one tick; getVel* then return the applied value.
    void advanceActuation(float dtSec);

    uint32_t getId() const;
    float getKickspeedx() const;
    float getKickspeedz() const;
    float getVeltangent() const;
    float getVelnormal() const;
    float getVelangular() const;
    float getSpinner() const;
    bool getWheelsspeed() const;
    float getWheel1() const;
    float getWheel2() const;
    float getWheel3() const;
    float getWheel4() const;

private:
    void processMoveCommand(const RobotMoveCommand &moveCommand);

    uint32_t id;
    float kickspeedx;
    float kickspeedz;
    float veltangent;
    float velnormal;
    float velangular;

    float spinner;
    bool wheelsspeed;

    float wheel1;
    float wheel2;
    float wheel3;
    float wheel4;

    // --- Actuation delay model state ---
    // Raw command targets (set by vision/control update); veltangent/velnormal/
    // velangular hold the *applied* values that QML reads.
    float cmdTangent = 0.0f;
    float cmdNormal = 0.0f;
    float cmdAngular = 0.0f;
    float appliedTangent = 0.0f;
    float appliedNormal = 0.0f;
    float appliedAngular = 0.0f;
    float tauLinearSec = 0.0f;
    float tauAngularSec = 0.0f;
    float deadTimeLinearSec = 0.0f;
    float deadTimeAngularSec = 0.0f;
    std::deque<float> delayBufTangent;
    std::deque<float> delayBufNormal;
    std::deque<float> delayBufAngular;

    static float advanceAxis(float &applied, float cmd, std::deque<float> &buf,
                             float tauSec, float deadTimeSec, float dtSec);
};

#endif // ROBOT_H