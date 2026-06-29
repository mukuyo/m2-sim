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
        let ballPixels = []
        
        for (let i = 0; i < color.num; i++) {
            let frame = botFrame.children[i];

            botPositions.push(Qt.vector3d(frame.position.x, -frame.position.z, mu.radianToDegree(color.poses[i].w)));
            let botDistanceBall = Math.sqrt(Math.pow(frame.position.x - ballPosition.x, 2) + Math.pow(frame.position.z - ballPosition.z, 2) + Math.pow(frame.position.y - ballPosition.y, 2));
            let botRadianBall = mu.normalizeRadian(Math.atan2(frame.position.z - ballPosition.z, frame.position.x - ballPosition.x) - Math.PI + color.poses[i].w);
            if (frame.collisionShapes[5].position.y != 5000) {
                ballReset = false;
            }
            sync.updateID(color, frame, i, botIDTexts, botStatus, botIDRect, botBar);
            sync.updateCamera(color, frame, i, isYellow);
        }
        
        return { positions: botPositions, ballContacts: color.holds, pixels: botPixelBalls, cameraExists: color.cameraExists };
    }
    function updateBall() {
        if (dribbleInfo.id == -1) {
            // ballModels.children[0].position = Qt.vector3d(ball.position.x, ball.position.y, ball.position.z);
            // After a kick/release, Control.kick() (and the spinner-off release in
            // GameObjects) queue ball.reset(mouth), which Qt Quick 3D Physics applies on
            // the NEXT step. For that one step ball.position is still the off-field park
            // sentinel (~100000) set by Control.dribble(). Publishing it makes Raven
            // reject the ball ("abnormal coordinates") and it vanishes. Only publish an
            // on-field position; otherwise hold the last good ballPosition until physics
            // catches up (one frame later the ball appears at the mouth, flying).
            if (Math.abs(ball.position.x) < 50000 && Math.abs(ball.position.z) < 50000) {
                ballPosition = Qt.vector4d(ball.position.x, ball.position.y, ball.position.z, 0);
            }
            tempBallModel.visible = false;
            // ballModels.children[0].children[0].materials[0].diffuseColor= "orange";
        } else {
            tempBallModel.visible = true;
            let frame = dribbleInfo.isYellow ? yBotsFrame.children[dribbleInfo.id] : bBotsFrame.children[dribbleInfo.id];
            let color = dribbleInfo.isYellow ? yellow : blue;
            tempBallModel.position = Qt.vector3d(frame.position.x + (95 * Math.cos(-color.poses[dribbleInfo.id].w)), 25, (frame.position.z + (95 * Math.sin(-color.poses[dribbleInfo.id].w))));
            ballPosition = Qt.vector4d(
                frame.position.x + (95 * Math.cos(color.poses[dribbleInfo.id].w)),
                25,
                frame.position.z + (95 * Math.sin(-color.poses[dribbleInfo.id].w)),
                0
            );
            // ballModels.children[0].children[0].materials[0].diffuseColor= "#EB392A";
            // ballModels.children[0].position = Qt.vector3d(ballPosition.x, ballPosition.y, ballPosition.z);
        }
        ballMarker.position = Qt.vector3d(ballPosition.x, 5, ballPosition.z);
        if (isFoundBall) {
            ballMarker.children[0].materials[0].diffuseColor= "#EB392A";
        } else {
            ballMarker.children[0].materials[0].diffuseColor= "black";
        }
    }



    function updateID(color, frame, i, botIDTexts, botStatus, botIDRect, botBar) {

        let frame2D = camera.projectToScreen(
            Qt.vector3d(frame.position.x-15, frame.position.y + 128, frame.position.z-86.5), overviewCamera.position, overviewCamera.forward, overviewCamera.up, window.width, window.height, overviewCamera.fieldOfView, 1.0, 20000
        );
        if (i >= 10) {
            botIDTexts.children[i].x = frame2D.x - 21;
            botIDRect.children[i].x = frame2D.x - 20;
            botStatus.children[i].x = frame2D.x - 14;
            botBar.children[i].x = frame2D.x - 14;
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
        botBar.children[i].width = Math.sqrt(Math.pow(color.velNormals[i], 2) + Math.pow(color.velTangents[i], 2)) * 0.008;
    }
    function updateCamera(color, frame, i, isYellow) {
        // Project the ball onto the robot's onboard camera (RACOON-Pi camera),
        // reproducing the per-robot ball detection that RACOON-Pi reports to
        // RAVEN via PiToMw. The onboard PerspectiveCamera is a child of the
        // robot frame, so its scenePosition/forward/up already follow the robot
        // pose in world space — no manual trigonometry needed.
        let botPixelBalls = isYellow ? window.yBotPixelBalls : window.bBotPixelBalls;
        let cam = color.cameras[i];
        if (cam === undefined) {
            color.cameraExists[i] = false;
            botPixelBalls[i] = Qt.vector2d(-1, -1);
        } else {
            // The ball pixel must be measured in the onboard camera's own frame
            // (default 640x480), independent of the GUI window size.
            let tempBallPixel = camera.getBallPosition(
                ball.position, cam.scenePosition, cam.forward, cam.up,
                observer.onboardCameraWidth, observer.onboardCameraHeight, cam.fieldOfView
            );
            if (tempBallPixel.x !== -1 && tempBallPixel.y !== -1) {
                botPixelBalls[i] = tempBallPixel;
                color.cameraExists[i] = true;
            } else {
                botPixelBalls[i] = Qt.vector2d(-1, -1);
                color.cameraExists[i] = false;
            }
        }
        color.position2Ds[i] = Qt.vector2d(frame.position.x, frame.position.z);
    }


}