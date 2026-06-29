#include "camera.h"

Camera::Camera(QObject *parent) : QObject(parent) {}

QMatrix4x4 Camera::createViewMatrix(const QVector3D& eye, const QVector3D& center, const QVector3D& up) {
    QMatrix4x4 view;
    view.lookAt(eye, center, up);
    return view;
}

QMatrix4x4 Camera::createProjectionMatrix(float fovDegrees, float aspectRatio, float nearPlane, float farPlane) {
    QMatrix4x4 proj;
    proj.perspective(fovDegrees, aspectRatio, nearPlane, farPlane);
    return proj;
}

QVector2D Camera::getBallPosition(QVector3D objectPos, QVector3D cameraPos, QVector3D cameraForward, QVector3D cameraUp, int screenWidth, int screenHeight, float fovDegrees) {
    QVector3D center = cameraPos + cameraForward.normalized();
    QMatrix4x4 view = createViewMatrix(cameraPos, center, cameraUp);
    QMatrix4x4 proj = createProjectionMatrix(fovDegrees, float(screenWidth) / screenHeight, 1.0f, 20000.0f);

    float radius = 20.0f;
    QVector<QVector3D> offsets = generateOffsets(radius);
    QVector2D screenSum(0, 0);
    int count = 0;

    for (const auto& offset : offsets) {
        QVector4D worldPos(objectPos + offset, 1.0f);
        QVector4D clipSpace = proj * view * worldPos;

        if (clipSpace.w() == 0.0f)
            continue;

        clipSpace /= clipSpace.w();

        float ndcX = clipSpace.x();
        float ndcY = clipSpace.y();
        float ndcZ = clipSpace.z();

        if (ndcX >= -1.0f && ndcX <= 1.0f &&
            ndcY >= -1.0f && ndcY <= 1.0f &&
            ndcZ >= -1.0f && ndcZ <= 1.0f) {
            
            float pixelX = (ndcX * 0.5f + 0.5f) * screenWidth;
            float pixelY = (1.0f - (ndcY * 0.5f + 0.5f)) * screenHeight;

            screenSum += QVector2D(pixelX, pixelY);
            count++;
        }
    }

    if (count == 0) {
        // qDebug() << "Ball is not visible";
        return QVector2D(-1, -1); // 完全に視野外
    }

    QVector2D avgScreenPos = screenSum / count;
    // qDebug() << "Ball projected center (visible part):" << avgScreenPos;
    return avgScreenPos;
}

QVector<QVector3D> Camera::generateOffsets(float radius) {
    QVector<QVector3D> offsets;
    const int steps = 5;
    for (int x = -steps; x <= steps; ++x) {
        for (int y = -steps; y <= steps; ++y) {
            for (int z = -steps; z <= steps; ++z) {
                QVector3D offset(x, y, z);
                if (offset.lengthSquared() <= steps * steps) {
                    offsets.append(offset.normalized() * radius);
                }
            }
        }
    }
    return offsets;
}

QVector2D Camera::projectToScreen(
    const QVector3D& worldPos,
    const QVector3D& cameraPos,
    const QVector3D& cameraForward,
    const QVector3D& cameraUp,
    int screenWidth,
    int screenHeight,
    float fovDegrees,
    float nearPlane = 1.0f,
    float farPlane = 20000.0f
) {
    QVector3D center = cameraPos + cameraForward.normalized();
    QMatrix4x4 view = createViewMatrix(cameraPos, center, cameraUp);
    QMatrix4x4 proj = createProjectionMatrix(fovDegrees, float(screenWidth) / screenHeight, nearPlane, farPlane);

    QVector4D clipSpace = proj * view * QVector4D(worldPos, 1.0f);

    if (clipSpace.w() == 0.0f)
        return QVector2D(-1, -1);

    QVector4D ndc = clipSpace / clipSpace.w();

    if (ndc.x() < -1.0f || ndc.x() > 1.0f ||
        ndc.y() < -1.0f || ndc.y() > 1.0f ||
        ndc.z() < -1.0f || ndc.z() > 1.0f) {
        return QVector2D(-1, -1);
    }

    float pixelX = (ndc.x() * 0.5f + 0.5f) * screenWidth;
    float pixelY = (1.0f - (ndc.y() * 0.5f + 0.5f)) * screenHeight;

    return QVector2D(pixelX, pixelY);
}

