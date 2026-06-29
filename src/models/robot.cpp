#include "robot.h"
#include <cmath>

Robot::Robot(QObject *parent)
    : QObject(parent),
      id(0),
      kickspeedx(0.0f),
      kickspeedz(0.0f),
      veltangent(0.0f),
      velnormal(0.0f),
      velangular(0.0f),
      spinner(false),
      wheelsspeed(false),
      wheel1(0.0f),
      wheel2(0.0f),
      wheel3(0.0f),
      wheel4(0.0f) {}

Robot::~Robot() = default;

void Robot::visionUpdate(mocSim_Robot_Command robotCommand) {
    id = robotCommand.id();
    kickspeedx = robotCommand.kickspeedx()*1000.0;
    kickspeedz = robotCommand.kickspeedz()*1000.0;
    // Velocity goes through the actuation delay model (advanceActuation), not
    // straight to veltangent/velnormal/velangular which hold the applied value.
    cmdTangent = robotCommand.veltangent()*1000.0;
    cmdNormal = robotCommand.velnormal()*1000.0;
    cmdAngular = robotCommand.velangular();
    spinner = robotCommand.spinner() ? 1.0 : 0.0;
    wheelsspeed = robotCommand.wheelsspeed();
    wheel1 = robotCommand.wheel1();
    wheel2 = robotCommand.wheel2();
    wheel3 = robotCommand.wheel3();
    wheel4 = robotCommand.wheel4();
}

void Robot::controlUpdate(RobotCommand robotCommand) {
    id = robotCommand.id();

    if (robotCommand.has_kick_speed() && robotCommand.kick_speed() > 0) {
        double kickSpeed = robotCommand.kick_speed();
        double limit = robotCommand.kick_angle() > 0 ? 10000 : 10001;
        kickSpeed = kickSpeed * 1000.0;
        if (kickSpeed > limit) {
            kickSpeed = limit;
        }
        double kickAngle = robotCommand.kick_angle() * M_PI / 180.0;
        double length = cos(kickAngle) * kickSpeed;
        double z = sin(kickAngle) * kickSpeed;
        
        kickspeedx = length;
        kickspeedz = z;
    } else {
        kickspeedx = 0;
        kickspeedz = 0;
    }

    spinner = 0.0;
    if (robotCommand.has_dribbler_speed()) {
        spinner = robotCommand.dribbler_speed();
    }

    if (robotCommand.has_move_command()) {
        processMoveCommand(robotCommand.move_command());
    }
}

void Robot::processMoveCommand(const RobotMoveCommand &moveCommand) {
    if (moveCommand.has_wheel_velocity()) {
        // auto &wheelVel = moveCommand.wheel_velocity();
        // robot->setSpeed(0, wheelVel.front_right());
        // robot->setSpeed(1, wheelVel.back_right());
        // robot->setSpeed(2, wheelVel.back_left());
        // robot->setSpeed(3, wheelVel.front_left());
    } else if (moveCommand.has_local_velocity()) {
        auto &vel = moveCommand.local_velocity();
        cmdNormal = vel.left()*1000.0;
        cmdTangent = vel.forward()*1000.0;
        cmdAngular = vel.angular();
    } else if(moveCommand.has_global_velocity()) {
        // auto &vel = moveCommand.global_velocity();
        // dReal orientation = -robot->getDir() * M_PI / 180.0;
        // dReal vx = (vel.x() * cos(orientation)) - (vel.y() * sin(orientation));
        // dReal vy = (vel.y() * cos(orientation)) + (vel.x() * sin(orientation));
        // robot->setSpeed(vx, vy, vel.angular());
    }  else {
        // SimulatorError *pError = robotControlResponse.add_errors();
        // pError->set_code("GRSIM_UNSUPPORTED_MOVE_COMMAND");
        // pError->set_message("Unsupported move command");
    }
}

void Robot::setActuationParams(float tauLin, float tauAng, float deadLin, float deadAng) {
    tauLinearSec = tauLin;
    tauAngularSec = tauAng;
    deadTimeLinearSec = deadLin;
    deadTimeAngularSec = deadAng;
}

// Push the command into a per-axis delay line (transport dead time), then apply
// a first-order lag toward the delayed command. tau/dead = 0 ⇒ applied = cmd.
float Robot::advanceAxis(float &applied, float cmd, std::deque<float> &buf,
                         float tauSec, float deadTimeSec, float dtSec) {
    int delaySteps = (deadTimeSec > 0.0f && dtSec > 0.0f)
                         ? static_cast<int>(std::lround(deadTimeSec / dtSec))
                         : 0;
    buf.push_back(cmd);
    while (static_cast<int>(buf.size()) > delaySteps + 1) {
        buf.pop_front();
    }
    const float delayedCmd = buf.front();  // command from ~delaySteps ticks ago
    const float alpha = (tauSec > 0.0f && dtSec > 0.0f)
                            ? (1.0f - std::exp(-dtSec / tauSec))
                            : 1.0f;
    applied += alpha * (delayedCmd - applied);
    return applied;
}

void Robot::advanceActuation(float dtSec) {
    veltangent = advanceAxis(appliedTangent, cmdTangent, delayBufTangent,
                             tauLinearSec, deadTimeLinearSec, dtSec);
    velnormal = advanceAxis(appliedNormal, cmdNormal, delayBufNormal,
                            tauLinearSec, deadTimeLinearSec, dtSec);
    velangular = advanceAxis(appliedAngular, cmdAngular, delayBufAngular,
                             tauAngularSec, deadTimeAngularSec, dtSec);
}

uint32_t Robot::getId() const { return id; }
float Robot::getKickspeedx() const { return kickspeedx; }
float Robot::getKickspeedz() const { return kickspeedz; }
float Robot::getVeltangent() const { return veltangent; }
float Robot::getVelnormal() const { return velnormal; }
float Robot::getVelangular() const { return velangular; }
float Robot::getSpinner() const { return spinner; }
bool Robot::getWheelsspeed() const { return wheelsspeed; }
float Robot::getWheel1() const { return wheel1; }
float Robot::getWheel2() const { return wheel2; }
float Robot::getWheel3() const { return wheel3; }
float Robot::getWheel4() const { return wheel4; }
