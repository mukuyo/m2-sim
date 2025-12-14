#pragma once

#include <iostream>
#include <QObject>
#include <QVector3D>
#include <QSettings>
#include <cmath>

using namespace std;

class MathUtils : public QObject {
    Q_OBJECT

public:
    explicit MathUtils(QObject *parent = nullptr);
    Q_INVOKABLE float normalizeRadian(float radian);
    Q_INVOKABLE float radianToDegree(float radian);
    Q_INVOKABLE float degreeToRadian(float degree);
    Q_INVOKABLE QVector4D calcVelocity(QVector4D pose, QVector4D prePose, float deltaTime);

private:
    QSettings config;
};