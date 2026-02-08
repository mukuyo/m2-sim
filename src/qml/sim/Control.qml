import QtQuick

QtObject {
    function kick(color, frame, i, radian, ballVelocity) {
        color.holds[i] = false;
        
        frame.collisionShapes[5].position = Qt.vector3d(0, 5000, 0);
        if (ball.position.x > 50000) {
            ball.reset(Qt.vector3d(frame.position.x + (95 * Math.cos(-radian)), 25, (frame.position.z + (95 * Math.sin(-radian)))), Qt.vector3d(0, 0, 0));
        }
        dribbleInfo.id = -1;

        kickFlag = true;
        kickTimer.running = true;
        color.kickspeeds[i].x *= observer.kickerFriction;
        color.kickspeeds[i].y *= observer.kickerFriction;
        ball.setLinearVelocity(Qt.vector3d(
            color.kickspeeds[i].x * Math.cos(radian),
            color.kickspeeds[i].y,
            -color.kickspeeds[i].x * Math.sin(radian)
        ));
    }

    function dribble(frame, isYellow, i, botRadianBall, botDistanceBall, color) {
        dribbleInfo.id = i;
        dribbleInfo.isYellow = isYellow;
        dribbleInfo.radianBall = botRadianBall;
        dribbleInfo.distanceBall = 95;
        // ball.simulationEnabled = false;
        ball.reset(Qt.vector3d(100000, 0, 100000), Qt.vector3d(0, 0, 0));
        
        // ball.reset(Qt.vector3d(frame.position.x + (95 * Math.cos(-color.poses[i].w)), 25, (frame.position.z + (95 * Math.sin(-color.poses[i].w)))), Qt.vector3d(0, 0, 0));
        frame.collisionShapes[5].position = Qt.vector3d(0, 25, -95*Math.cos(botRadianBall));
    }
}