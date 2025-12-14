#include "mathUtils.h"

MathUtils::MathUtils(QObject *parent)
    : QObject(parent), config("../config/config.ini", QSettings::IniFormat) {
}

float MathUtils::normalizeRadian(float radian) {
    while (radian > M_PI) {
        radian -= 2 * M_PI;
    }
    while (radian < -M_PI) {
        radian += 2 * M_PI;
    }
    return radian;
}

float MathUtils::radianToDegree(float radian) {
    return radian * (180.0f / M_PI);
}

float MathUtils::degreeToRadian(float degree) {
    return degree * (M_PI / 180.0f);
}

QVector4D MathUtils::calcVelocity(QVector4D pose, QVector4D prePose, float deltaTime) {
    QVector4D worldVelocity = QVector4D(
        (pose.x() - prePose.x()) / deltaTime,
        (pose.y() - prePose.y()) / deltaTime,
        (pose.z() - prePose.z()) / deltaTime,
        normalizeRadian(pose.w() - prePose.w()) / deltaTime
    );
    return QVector4D(
        worldVelocity.x() * cos(-pose.w()) - worldVelocity.y() * sin(-pose.w()),
        worldVelocity.x() * sin(-pose.w()) + worldVelocity.y() * cos(-pose.w()),
        worldVelocity.z(),
        worldVelocity.w()
    );
}
