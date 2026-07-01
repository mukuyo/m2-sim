#include "observer.h"

Observer::Observer(QObject *parent) : QObject(parent), config("../config/config_v2.ini", QSettings::IniFormat) {
    visionMulticastAddress = config.value("Network/visionMulticastAddress", "127.0.0.1").toString();
    visionMulticastPort = config.value("Network/visionMulticastPort", 10020).toInt();
    commandListenPort = config.value("Network/commandListenPort", 20011).toInt();
    blueTeamControlPort = config.value("Network/blueTeamControlPort", 10301).toInt();
    yellowTeamControlPort = config.value("Network/yellowTeamControlPort", 10302).toInt();
    
    forceDebugDrawMode = config.value("Display/ForceDebugDrawMode", false).toBool();
    lightBlueRobotMode = config.value("LightMode/BlueRobot", true).toBool();
    lightYellowRobotMode = config.value("LightMode/YellowRobot", true).toBool();
    lightStadiumMode = config.value("LightMode/Stadium", true).toBool();
    lightFieldMode = config.value("LightMode/Field", true).toBool();
    ballStaticFriction = config.value("Physics/BallStaticFriction", 0.5).toFloat();
    ballDynamicFriction = config.value("Physics/BallDynamicFriction", 0.3).toFloat();
    ballRestitution = config.value("Physics/BallRestitution", 0.5).toFloat();
    rollingFriction = config.value("Physics/RollingFriction", 0.04).toFloat();
    kickerFriction = config.value("Physics/KickerFriction", 0.8).toFloat();
    gravity = config.value("Physics/Gravity", 9.81).toFloat();
    desiredFps = 60;
    ccdMode = config.value("Physics/CCD", true).toBool();
    hideBallMode = config.value("Camera/HideBallMode", false).toBool();
    onboardCameraWidth = config.value("Camera/OnboardFrameWidth", 640).toInt();
    onboardCameraHeight = config.value("Camera/OnboardFrameHeight", 480).toInt();

    sender = new Sender(visionMulticastAddress.toStdString(), visionMulticastPort, this);
    visionReceiver = new VisionReceiver(this);
    controlBlueReceiver = new ControlBlueReceiver(this);
    controlYellowReceiver = new ControlYellowReceiver(this);

    visionReceiver->startListening(commandListenPort);
    controlBlueReceiver->startListening(blueTeamControlPort);
    controlYellowReceiver->startListening(yellowTeamControlPort);

    connect(visionReceiver, &VisionReceiver::receivedPacket, this, &Observer::visionReceive);
    connect(controlBlueReceiver, &ControlBlueReceiver::receivedPacket, this, &Observer::controlReceive);
    connect(controlYellowReceiver, &ControlYellowReceiver::receivedPacket, this, &Observer::controlReceive);
    connect(this, &Observer::sendBotBallContacts, controlBlueReceiver, &ControlBlueReceiver::updateBallContacts);
    connect(this, &Observer::sendBotBallContacts, controlYellowReceiver, &ControlYellowReceiver::updateBallContacts);

    for (int i = 0; i < MaxRobots; ++i) {
        blueRobots[i] = new Robot(this);
        yellowRobots[i] = new Robot(this);
    }

    windowWidth = config.value("Display/width", 1100).toInt();
    windowHeight = config.value("Display/height", 720).toInt();

    blueRobotCount = config.value("Robot/blueRobotCount", 11).toInt();
    yellowRobotCount = config.value("Robot/yellowRobotCount", 11).toInt();

    numThreads = config.value("Display/NumThreads", -1).toInt();

    // --- Synthetic wheel-encoder feedback + actuation delay model ---
    encoderEnabled = config.value("Encoder/Enabled", true).toBool();
    encoderTeamYellow = (config.value("Encoder/Team", "blue").toString().toLower() == "yellow");
    wheelRadiusMm = config.value("Encoder/WheelRadiusMm", 26.0).toDouble();
    robotRadiusMm = config.value("Encoder/RobotRadiusMm", 90.0).toDouble();
    wheelAngleRad[0] = config.value("Encoder/WheelAngleFlDeg", 60.0).toDouble() * M_PI / 180.0;
    wheelAngleRad[1] = config.value("Encoder/WheelAngleBlDeg", 135.0).toDouble() * M_PI / 180.0;
    wheelAngleRad[2] = config.value("Encoder/WheelAngleBrDeg", -135.0).toDouble() * M_PI / 180.0;
    wheelAngleRad[3] = config.value("Encoder/WheelAngleFrDeg", -60.0).toDouble() * M_PI / 180.0;
    encoderNoiseSigmaMps = config.value("Encoder/NoiseSigmaMps", 0.0).toDouble();
    encoderBiasMps = config.value("Encoder/BiasMps", 0.0).toDouble();
    encoderQuantMps = config.value("Encoder/QuantizationMps", 0.0).toDouble();
    QString feedbackAddress = config.value("Encoder/FeedbackAddress", "224.5.69.4").toString();
    int feedbackPort = config.value("Encoder/FeedbackPort", 16941).toInt();
    feedbackSender = new FeedbackSender(feedbackAddress.toStdString(),
                                        static_cast<unsigned short>(feedbackPort));

    actTauLinearSec = config.value("Actuation/TauLinearSec", 0.0).toFloat();
    actTauAngularSec = config.value("Actuation/TauAngularSec", 0.0).toFloat();
    actDeadTimeLinearSec = config.value("Actuation/DeadTimeLinearSec", 0.0).toFloat();
    actDeadTimeAngularSec = config.value("Actuation/DeadTimeAngularSec", 0.0).toFloat();
    for (int i = 0; i < MaxRobots; ++i) {
        blueRobots[i]->setActuationParams(actTauLinearSec, actTauAngularSec,
                                          actDeadTimeLinearSec, actDeadTimeAngularSec);
        yellowRobots[i]->setActuationParams(actTauLinearSec, actTauAngularSec,
                                            actDeadTimeLinearSec, actDeadTimeAngularSec);
    }
    actuationClock.start();
    feedbackClock.start();

    simTimer = new QTimer(this);
    simTimer->setTimerType(Qt::PreciseTimer);
    connect(simTimer, &QTimer::timeout, this, &Observer::updateSimulator);
    simTimer->start(1000 / 60);
}

void Observer::visionReceive(const mocSim_Packet& packet) {
    bool isYellow = packet.commands().isteamyellow();
    for (const auto& command : packet.commands().robot_commands()) {
        int id = command.id();
        if (id < 0 || id >= MaxRobots) continue;
        if (isYellow) {
            yellowRobots[id]->visionUpdate(command);
        } else {
            blueRobots[id]->visionUpdate(command);
        }
    }
    if (isYellow) emit yellowRobotsChanged();
    else emit blueRobotsChanged();

    // Robot/ball placement (Replacement). turnon=false (robot removal) is not
    // handled: this side always sends turnon=true.
    for (const auto& robotReplacement : packet.replacement().robots()) {
        int id = robotReplacement.id();
        if (id < 0 || id >= MaxRobots) continue;
        float sceneX = robotReplacement.x() * 1000.0f;
        float sceneZ = -robotReplacement.y() * 1000.0f;
        float sceneRotYDeg = robotReplacement.dir() * 180.0 / M_PI - 90.0;
        emit robotReplacementRequested(id, robotReplacement.yellowteam(), sceneX, sceneZ, sceneRotYDeg);
    }
    if (packet.replacement().has_ball()) {
        const auto& ballReplacement = packet.replacement().ball();
        if (ballReplacement.has_x() && ballReplacement.has_y()) {
            float sceneX = ballReplacement.x() * 1000.0f;
            float sceneZ = -ballReplacement.y() * 1000.0f;
            emit ballReplacementRequested(sceneX, sceneZ);
        }
    }
}

void Observer::controlReceive(const RobotControl& packet, bool isYellow) {
    int receive_count = 0;
    for (const auto& robotCommand : packet.robot_commands()) {
        int id = robotCommand.id();
        if (id < 0 || id >= MaxRobots) continue;
        if (!robotCommand.has_move_command()) continue;
        if (isYellow) {
            yellowRobots[id]->controlUpdate(robotCommand);
        } else {
            blueRobots[id]->controlUpdate(robotCommand);
        }
        receive_count++;
    }
    if (receive_count == 0) return;
    if (isYellow) emit yellowRobotsChanged();
    else emit blueRobotsChanged();
}

void Observer::setWindowWidth(int width) { 
    windowWidth = width; 
    config.setValue("Display/width", width);
    emit settingChanged(); 
}
void Observer::setWindowHeight(int height) { 
    windowHeight = height; 
    config.setValue("Display/height", height);
    emit settingChanged(); 
}
void Observer::setVisionMulticastPort(int port) { 
    visionMulticastPort = port; 
    config.setValue("Network/visionMulticastPort", port);
    sender->setPort(visionMulticastAddress.toStdString(), visionMulticastPort);
    emit settingChanged(); 
}
void Observer::setVisionMulticastAddress(const QString &address) {
    visionMulticastAddress = address;
    config.setValue("Network/visionMulticastAddress", QString::fromStdString(visionMulticastAddress.toStdString()));
    sender->setPort(visionMulticastAddress.toStdString() , visionMulticastPort);
    emit settingChanged();
}
void Observer::setCommandListenPort(int port) {
    commandListenPort = port;
    config.setValue("Network/commandListenPort", port);
    visionReceiver->setPort(commandListenPort);
    emit settingChanged();
}
void Observer::setBlueTeamControlPort(int port) {
    blueTeamControlPort = port;
    config.setValue("Network/blueTeamControlPort", port);
    controlBlueReceiver->setPort(blueTeamControlPort);
    emit settingChanged();
}
void Observer::setYellowTeamControlPort(int port) {
    yellowTeamControlPort = port;
    config.setValue("Network/yellowTeamControlPort", port);
    controlYellowReceiver->setPort(yellowTeamControlPort);
    emit settingChanged();
}
void Observer::setForceDebugDrawMode(bool mode) {
    forceDebugDrawMode = mode;
    config.setValue("Display/ForceDebugDrawMode", mode);
    emit settingChanged();
}
void Observer::setLightBlueRobotMode(bool mode) {
    lightBlueRobotMode = mode;
    config.setValue("LightMode/BlueRobot", mode);
    emit settingChanged();
}
void Observer::setLightYellowRobotMode(bool mode) {
    lightYellowRobotMode = mode;
    config.setValue("LightMode/YellowRobot", mode);
    emit settingChanged();
}
void Observer::setLightStadiumMode(bool mode) {
    lightStadiumMode = mode;
    config.setValue("LightMode/Stadium", mode);
    emit settingChanged();
}
void Observer::setLightFieldMode(bool mode) {
    lightFieldMode = mode;
    config.setValue("LightMode/Field", mode);
    emit settingChanged();
}
void Observer::setBlueRobotCount(int count) {
    blueRobotCount = count;
    config.setValue("Robot/blueRobotCount", count);
    emit settingChanged();
}
void Observer::setYellowRobotCount(int count) {
    yellowRobotCount = count;
    config.setValue("Robot/yellowRobotCount", count);
    emit settingChanged();
}
void Observer::setBallRestitution(float restitution) {
    ballRestitution = restitution;
    config.setValue("Physics/BallRestitution", qRound(restitution*100)/100.0);
    emit settingChanged();
}
void Observer::setRollingFriction(float friction) {
    rollingFriction = friction;
    config.setValue("Physics/RollingFriction", qRound(friction*100)/100.0);
    emit settingChanged();
}
void Observer::setKickerFriction(float friction) {
    kickerFriction = friction;
    config.setValue("Physics/KickerFriction", qRound(friction*100)/100.0);
    emit settingChanged();
}
void Observer::setGravity(float gravity) {
    this->gravity = gravity;
    config.setValue("Physics/Gravity", qRound(gravity*100)/100.0);
    emit settingChanged();
}
void Observer::setDesiredFps(int fps) {
    Q_UNUSED(fps);
    desiredFps = 60;
    config.setValue("Physics/DesiredFps", desiredFps);
    emit settingChanged();
}
void Observer::setCcdMode(bool mode) {
    ccdMode = mode;
    config.setValue("Physics/CCD", mode);
    emit settingChanged();
}
void Observer::setNumThreads(int threads) {
    numThreads = threads;
    config.setValue("Display/NumThreads", numThreads);
    emit settingChanged();
}
void Observer::setHideBallMode(bool mode) {
    hideBallMode = mode;
    config.setValue("Camera/HideBallMode", mode);
    emit settingChanged();
}

void Observer::updateObjects(
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
) {
    bluePositions = blue_positions.mid(0, blueRobotCount);
    yellowPositions = yellow_positions.mid(0, yellowRobotCount);

    // Synthesize RACOON-Pi feedback (wheel encoders + onboard camera + sensors)
    // for the team RAVEN controls.
    float fbDt = feedbackClock.nsecsElapsed() * 1e-9f;
    feedbackClock.restart();
    emitEncoderFeedback(encoderTeamYellow ? yellowPositions : bluePositions,
                        encoderTeamYellow ? yellowBallCameraExists : blueBallCameraExists,
                        encoderTeamYellow ? yellowBallPixels : blueBallPixels,
                        encoderTeamYellow ? yBotBallContacts : bBotBallContacts,
                        fbDt);

    if (isFoundBall)
        this->ballPosition = ball_position;
    emit sendBotBallContacts(bBotBallContacts, yBotBallContacts, blueBallCameraExists, yellowBallCameraExists, blueBallPixels, yellowBallPixels);
}

void Observer::updateSimulator() {
    // Advance the actuation delay model before QML reads applied velocities.
    float dtSec = actuationClock.nsecsElapsed() * 1e-9f;
    actuationClock.restart();
    if (dtSec > 0.0f && dtSec < 0.5f) {  // ignore startup / stalls
        for (int i = 0; i < MaxRobots; ++i) {
            blueRobots[i]->advanceActuation(dtSec);
            yellowRobots[i]->advanceActuation(dtSec);
        }
    }
    emit updateSimulationSignal();
    sender->send(1, ballPosition, bluePositions, yellowPositions);
}

void Observer::emitEncoderFeedback(const QList<QVector3D> &positions,
                                   const QList<bool> &ballCameraExists,
                                   const QList<QVector2D> &ballCameraPixels,
                                   const QList<bool> &ballContacts,
                                   float dtSec) {
    if (!encoderEnabled || feedbackSender == nullptr) {
        return;
    }
    const int n = positions.size();
    if (prevEncoderPositions.size() != n || dtSec <= 0.0f || dtSec > 0.5f) {
        prevEncoderPositions = positions;  // (re)seed; need two frames to differentiate
        return;
    }
    // Onboard-camera frame center: pixels from QML are top-left origin; RACOON-Pi
    // reports center-origin, x right / y up (camera/transport/encoder.py).
    const float halfW = onboardCameraWidth * 0.5f;
    const float halfH = onboardCameraHeight * 0.5f;
    std::normal_distribution<double> gauss(0.0, encoderNoiseSigmaMps > 0.0 ? encoderNoiseSigmaMps : 1.0);
    for (int i = 0; i < n; ++i) {
        // positions[i] = (X = frame.x [mm], Y = -frame.z [mm], heading [deg]) —
        // the same pose RAVEN receives on vision, so the encoder agrees with it.
        const QVector3D &p = positions[i];
        const QVector3D &pp = prevEncoderPositions[i];
        double wvx = (p.x() - pp.x()) / dtSec;  // world vx [mm/s]
        double wvy = (p.y() - pp.y()) / dtSec;  // world vy [mm/s]
        double dthDeg = std::fmod(p.z() - pp.z() + 540.0, 360.0) - 180.0;  // wrapped [deg]
        double omega = (dthDeg * M_PI / 180.0) / dtSec;  // [rad/s]
        double w = p.z() * M_PI / 180.0;                 // heading [rad]
        // Rotate world velocity into the body frame (+x heading, +y left).
        double forward = wvx * std::cos(w) + wvy * std::sin(w);   // body vx [mm/s]
        double left = -wvx * std::sin(w) + wvy * std::cos(w);     // body vy [mm/s]

        float wheelMps[4];
        for (int k = 0; k < 4; ++k) {
            // v_k = sin(α)·vx − cos(α)·vy − R·ω  [mm/s] (matches RAVEN forward kin.)
            double vMm = std::sin(wheelAngleRad[k]) * forward
                       - std::cos(wheelAngleRad[k]) * left
                       - robotRadiusMm * omega;
            double vMps = vMm / 1000.0 + encoderBiasMps;
            if (encoderNoiseSigmaMps > 0.0) {
                vMps += gauss(encoderRng);
            }
            if (encoderQuantMps > 0.0) {
                vMps = std::round(vMps / encoderQuantMps) * encoderQuantMps;
            }
            wheelMps[k] = static_cast<float>(vMps);
        }

        FeedbackSender::RobotFeedback fb;
        fb.flMps = wheelMps[0];
        fb.blMps = wheelMps[1];
        fb.brMps = wheelMps[2];
        fb.frMps = wheelMps[3];

        // Onboard-camera ball detection (RACOON-Pi Ball_Status).
        const bool ballSeen = i < ballCameraExists.size() && ballCameraExists[i];
        fb.ballExists = ballSeen;
        if (ballSeen && i < ballCameraPixels.size()) {
            const QVector2D &px = ballCameraPixels[i];  // top-left pixel origin
            fb.ballCamX = px.x() - halfW;               // +x right
            fb.ballCamY = halfH - px.y();               // +y up
        }

        // Kicker photo / dribbler sensors. The sim exposes a single "ball at the
        // mouth" contact (holds[i]); RACOON-Pi has both an IR kicker sensor and a
        // dribbler sensor that are effectively co-asserted when the ball is held.
        const bool ballHeld = i < ballContacts.size() && ballContacts[i];
        fb.photoSensor = ballHeld;
        fb.dribblerSensor = ballHeld;

        feedbackSender->sendRobotFeedback(i, fb);
    }
    prevEncoderPositions = positions;
}