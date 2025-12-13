import QtQuick

QtObject {
    function updateBot(color, isYellow=false) {
        let botFrame = isYellow ? yBotsFrame : bBotsFrame;
        let botPixelBalls = isYellow ? window.yBotPixelBalls : window.bBotPixelBalls;
        let botIDTexts = isYellow ? yBotIDTexts : bBotIDTexts;
        let botStatus = isYellow ? yBotStatus : bBotStatus;
        let botIDRect = isYellow ? yBotIDRect : bBotIDRect;
        let botBar = isYellow ? yBotBar : bBotBar;

        let botPositions = []
        let botBallContacts = []
        let ballPixels = []

        for (let i = 0; i < color.num; i++) {
            let frame = botFrame.children[i];

            botPositions.push(Qt.vector3d(frame.position.x, -frame.position.z, mu.radianToDegree(color.poses[i].w)));
            let botDistanceBall = Math.sqrt(Math.pow(frame.position.x - ballPosition.x, 2) + Math.pow(frame.position.z - ballPosition.z, 2) + Math.pow(frame.position.y - ballPosition.y, 2));
            let botRadianBall = mu.normalizeRadian(Math.atan2(frame.position.z - ballPosition.z, frame.position.x - ballPosition.x) - Math.PI + color.poses[i].w);
            if (dribbleNum == (i + (isYellow ? 10 : 0))) {
                botDistanceBall = 95;
                botRadianBall = remBotRadianBall;
            }
            if (botDistanceBall < 100 * Math.cos(Math.abs(botRadianBall)) && Math.abs(botRadianBall) < Math.PI/15.0 && color.spinners[i] > 0) {
                remBotRadianBall = botRadianBall;
                ballPosition = Qt.vector3d(frame.position.x + (95 * Math.cos(-color.poses[i].w + botRadianBall)), 25, (frame.position.z + (95 * Math.sin(-color.poses[i].w + botRadianBall))));
            } else if (color.holds[i]) {
                color.holds[i] = false;
                frame.collisionShapes[5].position = Qt.vector3d(0, 5000, 0);
                if (dribbleNum == (i + (isYellow ? 10 : 0))) {
                    ball.reset(Qt.vector3d(ballPosition.x, ballPosition.y, ballPosition.z), Qt.vector3d(0, 0, 0));
                    dribbleNum = -1;
                }
            }
            sync.updateID(color, frame, i, botIDTexts, botStatus, botIDRect, botBar);
            // sync.updateCamera(color, frame, i, bot, color.radians[i], isYellow);
        }
        return { positions: botPositions, ballContacts: color.holds, pixels: botPixelBalls, cameraExists: color.cameraExists };
    }
    function updateBall() {
        if (ball.position.x < 50000) {
            ballModels.children[0].position = Qt.vector3d(ball.position.x, ball.position.y, ball.position.z);
            ballPosition = Qt.vector3d(ball.position.x, ball.position.y, ball.position.z);
        } else {
            ballModels.children[0].position = Qt.vector3d(ballPosition.x, ballPosition.y, ballPosition.z);
        }
        ballMarker.position = Qt.vector3d(ballPosition.x, 5, ballPosition.z);
    }

    function kick(color, frame, i, radian) {
        color.holds[i] = false;
        frame.collisionShapes[5].position = Qt.vector3d(0, 5000, 0);
        if (ball.position.x > 50000) {
            ball.reset(Qt.vector3d(frame.position.x + (95 * Math.cos(-radian)), 25, (frame.position.z + (95 * Math.sin(-radian)))), Qt.vector3d(0, 0, 0));
        }

        let rg =0.043;
        if (!kick_flag) {
            kick_flag = true;
            ball.applyCentralImpulse(Qt.vector3d(
                color.kickspeeds[i].x * Math.cos(radian)*rg,
                color.kickspeeds[i].y*rg,
                -color.kickspeeds[i].x * Math.sin(radian)*rg
            ));
        }
        
    }


    function updateID(color, frame, i, botIDTexts, botStatus, botIDRect, botBar) {
        let frame2D = camera.projectToScreen(
            Qt.vector3d(frame.position.x-15, frame.position.y + 128, frame.position.z-86.5), overviewCamera.position, overviewCamera.forward, overviewCamera.up, window.width, window.height, overviewCamera.fieldOfView, 1.0, 20000
        );
        if (i >= 10) {
            botIDTexts.children[i].x = frame2D.x - 15;
            botIDRect.children[i].x = frame2D.x - 20;
            botStatus.children[i].x = frame2D.x - 20;
            botBar.children[i].x = frame2D.x - 20;
        } else {
            botIDTexts.children[i].x = frame2D.x - 12;
            botIDRect.children[i].x = frame2D.x - 13;
            botStatus.children[i].x = frame2D.x - 7;
            botBar.children[i].x = frame2D.x - 7;
        }
        botIDTexts.children[i].y = frame2D.y - 11;
        botIDRect.children[i].y = frame2D.y - 10;
        botStatus.children[i].y = frame2D.y - 9;
        botBar.children[i].y = frame2D.y - 9;
        botBar.children[i].width = Math.sqrt(Math.pow(color.velNormals[i], 2) + Math.pow(color.velTangents[i], 2)) * 0.003;
    }
    function updateCamera(color, frame, i, bot, radian, isYellow) {
        let cameraPosition = Qt.vector3d(-70*Math.sin(radian)+frame.position.x, color.cameras[i].position.y + frame.position.y, -70*Math.cos(radian)+frame.position.z);
        let tempBallPixel = camera.getBallPosition(ball.position, cameraPosition, color.cameras[i].forward, color.cameras[i].up, 640, 480, 60);
        if (tempBallPixel.x !=-1 && tempBallPixel.y != -1) {
            botPixelBalls[i] = tempBallPixel;
            botCameraExists[i] = true;
        } else {
            color.cameraExists[i] = false;
        }
        color.position2Ds[i] = Qt.vector2d(bot.position.x, bot.position.z);
        if (!isYellow) {
            bBot2DPositions = bBot2DPositions
        } else {
            yBot2DPositions = yBot2DPositions
        }
    }
}