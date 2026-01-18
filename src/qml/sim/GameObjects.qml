import QtQuick
import QtQuick3D
import Qt3D.Render
import Qt3D.Extras
import QtQuick3D.Physics
import Qt.labs.folderlistmodel
import M2

import "../../../assets/models/bot/Rione/viz" as BlueBody
import "../../../assets/models/bot/Rione/rigid_body" as BlueLightBody
import "../../../assets/models/bot/Rione/viz" as YellowBody
import "../../../assets/models/bot/Rione/rigid_body" as YellowLightBody
import "../../../assets/models/ball/"
import "../../../assets/models/circle/ball/"
import "../../../assets/models/circle/ballMarker/"

Node {
    id: robotNode
    Sync {
        id: sync
    }
    property real colorHeight: 0.2

    property real radianOffset: -Math.atan(350.0/547.72)
    property var selectedRobotColor: "blue"
    property real botCursorID: 0
    property var kickFlag: false
    property var preBallPosition: Qt.vector4d(0, 0, 0, 0)
    property var ballAngularVelocity: Qt.vector4d(0, 0, 0, 0)
    property var preBallAngularPosition: Qt.vector4d(0, 0, 0, 0)
    property var ballVelocity: Qt.vector4d(0, 0, 0, 0)
    property var ballModelNum: 10
    property var ballReset: false
    property var ballPositions: new Array(ballModelNum).fill(Qt.vector4d(0, 0, 0, 0))
    MotionControl {
        id: motionControl
    }
    MathUtils {
        id: mu
    }
    Connections {
        target: observer
        function onBlueRobotsChanged() {
            for (var i = 0; i < blue.num; i++) {
                blue.velNormals[i] = observer.blue_robots[i].velnormal;
                blue.velTangents[i] = observer.blue_robots[i].veltangent;
                blue.velAngulars[i] = observer.blue_robots[i].velangular;
                blue.kickspeeds[i] = Qt.vector3d(observer.blue_robots[i].kickspeedx, observer.blue_robots[i].kickspeedz, observer.blue_robots[i].kickspeedx);
                blue.spinners[i] = observer.blue_robots[i].spinner;
            }
        }
        function onYellowRobotsChanged() {
            for (var i = 0; i < yellow.num; i++) {
                yellow.velNormals[i] = observer.yellow_robots[i].velnormal;
                yellow.velTangents[i] = observer.yellow_robots[i].veltangent;
                yellow.velAngulars[i] = observer.yellow_robots[i].velangular;
                yellow.kickspeeds[i] = Qt.vector3d(observer.yellow_robots[i].kickspeedx, observer.yellow_robots[i].kickspeedz, observer.yellow_robots[i].kickspeedx);
                yellow.spinners[i] = observer.yellow_robots[i].spinner;
            }
        }
    }

    Repeater3D {
        id: bBotsFrame
        model: blue.num
        DynamicRigidBody {
            objectName: "b" + String(index)
            linearAxisLock: DynamicRigidBody.LockY
            sendContactReports: true
            position: Qt.vector4d(blue.poses[index].x, 0, blue.poses[index].z, blue.poses[index].w)
            collisionShapes: [
                ConvexMeshShape {
                    source: "../../../assets/models/bot/Rione/rigid_body/meshes/body.cooked.cvx"
                    eulerRotation: Qt.vector3d(-90, 0, 0)
                },
                ConvexMeshShape { 
                    source: "../../../assets/models/bot/Rione/rigid_body/meshes/centerLeft.cooked.cvx" 
                    eulerRotation: Qt.vector3d(-90, 0, 0)
                },
                ConvexMeshShape { 
                    source: "../../../assets/models/bot/Rione/rigid_body/meshes/centerRight.cooked.cvx" 
                    eulerRotation: Qt.vector3d(-90, 0, 0)
                },
                ConvexMeshShape { 
                    source: "../../../assets/models/bot/Rione/rigid_body/meshes/dribbler.cooked.cvx" 
                    eulerRotation: Qt.vector3d(-90, 0, 0)
                },
                ConvexMeshShape {
                    source: "../../../assets/models/bot/Rione/rigid_body/meshes/chip.cooked.cvx" 
                    eulerRotation: Qt.vector3d(-90, 0, 0)
                },
                ConvexMeshShape {
                    source: "../../../assets/models/ball/meshes/ball.cooked.cvx"
                    position: Qt.vector3d(0, 5000, 0)
                }
            ]
            BlueBody.Visualize {
                visible: !observer.lightBlueRobotMode
                eulerRotation: Qt.vector3d(-90, 0, 0)
                position: Qt.vector3d(0, 0, 0)
            }
            BlueLightBody.Frame {
                visible: observer.lightBlueRobotMode
                eulerRotation: Qt.vector3d(-90, 0, 0)
                position: Qt.vector3d(0, 0, 0)
            }
            PerspectiveCamera {
                id: bRobotCamera
                position: Qt.vector3d(0, 90, -70)
                clipFar: 20000
                clipNear: 1
                fieldOfView: 60
                eulerRotation: Qt.vector3d(-35, 0, 0)
                Component.onCompleted: {
                    blue.cameras.push(bRobotCamera);
                }
            }
            Model {
                source: "../../../assets/models/bot/Rione/viz/meshes/visualize.mesh"
                pickable: true
                objectName: "b"+String(index)
                eulerRotation: Qt.vector3d(-90, 0, 0)
            }
            Model {
                source: "#Cylinder"
                scale: Qt.vector3d(0.5, colorHeight, 0.5)
                position: Qt.vector3d(0, 122, 0)
                materials: [
                    DefaultMaterial {
                        diffuseColor: "blue"
                    }
                ]
            }

            Repeater3D {
                model: 4
                delegate: Model {
                    source: "#Cylinder"
                    scale: Qt.vector3d(0.4, colorHeight, 0.4)
                    position: {
                        var offsets = [
                            Qt.vector3d(65*Math.cos(Math.PI-radianOffset), 0, 65*Math.sin(Math.PI-radianOffset)),  // Left Up
                            Qt.vector3d(65*Math.cos(Math.PI/2.0-radianOffset), 0, 65*Math.sin(Math.PI/2.0-radianOffset)), // Left Down
                            Qt.vector3d(65*Math.cos(Math.PI/2.0+radianOffset), 0, 65*Math.sin(Math.PI/2.0+radianOffset)), // Right Down
                            Qt.vector3d(65*Math.cos(radianOffset), 0, 65*Math.sin(radianOffset))   // Right Up
                        ];
                        return Qt.vector3d(
                            offsets[index].x, 122, offsets[index].z
                        );
                    }
                    materials: [
                        DefaultMaterial {
                            diffuseColor: {
                                var colors = ["#EA3EF7", "#75FA4C", "#EA3EF7", "#75FA4C"];
                                return colors[index];
                            }
                        }
                    ]
                }
            }
        }
    }
    // onBBotNumChanged: {
    //     bBotsCamera = [];
    // }

    Repeater3D {
        id: yBotsFrame
        model: yellow.num
        DynamicRigidBody {
            objectName: "y" + String(index)
            linearAxisLock: DynamicRigidBody.LockY
            sendContactReports: true
            position: Qt.vector4d(yellow.poses[index].x, 0, yellow.poses[index].z, yellow.poses[index].w)
            collisionShapes: [
                ConvexMeshShape {
                    source: "../../../assets/models/bot/Rione/rigid_body/meshes/body.cooked.cvx"
                    eulerRotation: Qt.vector3d(-90, 0, 0)
                },
                ConvexMeshShape { 
                    source: "../../../assets/models/bot/Rione/rigid_body/meshes/centerLeft.cooked.cvx" 
                    eulerRotation: Qt.vector3d(-90, 0, 0)
                },
                ConvexMeshShape { 
                    source: "../../../assets/models/bot/Rione/rigid_body/meshes/centerRight.cooked.cvx" 
                    eulerRotation: Qt.vector3d(-90, 0, 0)
                },
                ConvexMeshShape { 
                    source: "../../../assets/models/bot/Rione/rigid_body/meshes/dribbler.cooked.cvx" 
                    eulerRotation: Qt.vector3d(-90, 0, 0)
                },
                ConvexMeshShape {
                    source: "../../../assets/models/bot/Rione/rigid_body/meshes/chip.cooked.cvx" 
                    eulerRotation: Qt.vector3d(-90, 0, 0)
            },
                ConvexMeshShape {
                    source: "../../../assets/models/ball/meshes/ball.cooked.cvx"
                    position: Qt.vector3d(0, 5000, 0)
                }
            ]
            YellowBody.Visualize {
                visible: !observer.lightYellowRobotMode
                eulerRotation: Qt.vector3d(-90, 0, 0)
                position: Qt.vector3d(0, 0, 0)
            }
            YellowLightBody.Frame {
                visible: observer.lightYellowRobotMode
                eulerRotation: Qt.vector3d(-90, 0, 0)
                position: Qt.vector3d(0, 0, 0)
            }
            PerspectiveCamera {
                id: yRobotCamera
                position: Qt.vector3d(0, 90, -70)
                clipFar: 20000
                clipNear: 1
                fieldOfView: 60
                eulerRotation: Qt.vector3d(-35, 0, 0)
                Component.onCompleted: {
                    yellow.cameras.push(yRobotCamera);
                }
            }
            Model {
                source: "../../../assets/models/bot/Rione/viz/meshes/visualize.mesh"
                pickable: true
                objectName: "y"+String(index)
                eulerRotation: Qt.vector3d(-90, 0, 0)
            }
            Model {
                source: "#Cylinder"
                scale: Qt.vector3d(0.5, colorHeight, 0.5)
                position: Qt.vector3d(0, 122, 0)
                materials: [
                    DefaultMaterial {
                        diffuseColor: "yellow"
                    }
                ]
            }

            Repeater3D {
                model: 4
                delegate: Model {
                    source: "#Cylinder"
                    scale: Qt.vector3d(0.4, colorHeight, 0.4)
                    position: {
                        var offsets = [
                            Qt.vector3d(65*Math.cos(Math.PI-radianOffset), 0, 65*Math.sin(Math.PI-radianOffset)), // Left Up
                            Qt.vector3d(65*Math.cos(Math.PI/2.0-radianOffset), 0, 65*Math.sin(Math.PI/2.0-radianOffset)), // Left Down
                            Qt.vector3d(65*Math.cos(Math.PI/2.0+radianOffset), 0, 65*Math.sin(Math.PI/2.0+radianOffset)), // Right Down
                            Qt.vector3d(65*Math.cos(radianOffset), 0, 65*Math.sin(radianOffset))   // Right Up
                        ];
                        return Qt.vector3d(
                            offsets[index].x,
                            122,
                            offsets[index].z
                        );
                    }
                    materials: [
                        DefaultMaterial {
                            diffuseColor: {
                                var colors = ["#EA3EF7", "#75FA4C", "#EA3EF7", "#75FA4C"];
                                return colors[index];
                            }
                        }
                    ]
                }
            }
        }
    }
    // onYBotNumChanged: {
    //     yBotsCamera = [];
    // }

    PhysicsMaterial {
        id: ballMaterial
        restitution: observer.ballRestitution
    }

    DynamicRigidBody {
        id: ball
        objectName: "ball"
        position: Qt.vector3d(0, 0, 0)
        sendContactReports: true
        physicsMaterial: ballMaterial
        collisionShapes: [
            SphereShape {
                diameter: 42
            }
        ]
        Ball {
        }
    }
    Repeater3D {
        id: ballModels
        model: ballModelNum
        Ball {
        }
    }
    BallMarker {
        id: ballMarker
        eulerRotation: Qt.vector3d(0, 0, 0)
        scale: Qt.vector3d(0.8, 0.01, 0.8)
    }

    function botMovement(color, timestep, isYellow=false) {
        let botFrame = isYellow ? yBotsFrame : bBotsFrame;

        for (let i = 0; i < color.num; i++) {
            let frame = botFrame.children[i];
            let tempBallFrame = frame.collisionShapes[5];
            color.poses[i] = Qt.vector4d(frame.position.x, frame.position.y, frame.position.z, mu.normalizeRadian((frame.eulerRotation.y+90) * Math.PI / 180.0));

            color.velocities[i] = mu.calcVelocity(color.poses[i], color.prePoses[i], timestep);
            let newVelocity = motionControl.calcSpeed(Qt.vector3d(color.velTangents[i], color.velNormals[i], color.velAngulars[i]), color.velocities[i], color.preVelocities[i], timestep, color.poses[i].w);

            color.prePoses[i] = color.poses[i];
            color.preVelocities[i] = Qt.vector4d(newVelocity.x, newVelocity.y, newVelocity.z, newVelocity.w);

            frame.setLinearVelocity(Qt.vector3d(newVelocity.x*Math.cos(color.poses[i].w) - newVelocity.y*Math.sin(color.poses[i].w), 0, -newVelocity.x*Math.sin(color.poses[i].w) - newVelocity.y*Math.cos(color.poses[i].w)));
            frame.setAngularVelocity(Qt.vector3d(0, newVelocity.z, 0));

            let botDistanceBall = Math.sqrt(Math.pow(frame.position.x - ballPosition.x, 2) + Math.pow(frame.position.z - ballPosition.z, 2));
            let botRadianBall = mu.normalizeRadian(Math.atan2(frame.position.z - ballPosition.z, frame.position.x - ballPosition.x) - Math.PI + color.poses[i].w);
            if (dribbleInfo.id != -1) {
                if (isYellow == dribbleInfo.isYellow && i == dribbleInfo.id) {
                    botDistanceBall = dribbleInfo.distanceBall;
                    botRadianBall = dribbleInfo.radianBall;
                }
            }
            if (botDistanceBall < 100 * Math.cos(Math.abs(botRadianBall)) && Math.abs(botRadianBall) < Math.PI/15.0 && ballPosition.y < 30) {
                if (!kickFlag && (color.kickspeeds[i].x != 0 || color.kickspeeds[i].y != 0)) {
                    sync.kick(color, frame, i, color.poses[i].w, ballVelocity);
                } else if (color.spinners[i] > 0 && !kickFlag) {
                    color.holds[i] = true;
                    sync.dribble(frame, isYellow, i, botRadianBall, botDistanceBall);
                } else if (color.spinners[i] == 0 && !kickFlag)  {
                    color.holds[i] = false;
                    frame.collisionShapes[5].position = Qt.vector3d(0, 5000, 0);
                    if (ball.position.x > 50000) {
                        ball.reset(Qt.vector3d(frame.position.x + (95 * Math.cos(-color.poses[i].w)), 25, (frame.position.z + (95 * Math.sin(-color.poses[i].w)))), Qt.vector3d(0, 0, 0));
                    }
                    dribbleInfo.id = -1;
                }
                if (dribbleInfo.id != -1) {
                    ballPosition = Qt.vector4d(frame.position.x + (dribbleInfo.distanceBall * Math.cos(-color.poses[dribbleInfo.id].w + dribbleInfo.radianBall)), 
                                            25, 
                                            (frame.position.z + (95 * Math.sin(-color.poses[dribbleInfo.id].w + dribbleInfo.radianBall))), 0);
                }
                
            } else if (color.holds[i]) {
                color.holds[i] = false;
                frame.collisionShapes[5].position = Qt.vector3d(0, 5000, 0);
            }
        }
    }

    function updateGameObjects(timestep) 
    {
        ballVelocity = mu.calcVelocity(ballPosition, preBallPosition, timestep);
        ballAngularVelocity = mu.calcVelocity(ball.eulerRotation, preBallAngularPosition, timestep);
        applyRollingFriction(ball, ballVelocity, ballAngularVelocity, timestep);
        preBallPosition = ballPosition;
        preBallAngularPosition = ball.eulerRotation;
        ballReset = true;
        
        botMovement(blue, timestep);
        botMovement(yellow, timestep, true);

        ball2DPosition = Qt.vector2d(ball.position.x, ball.position.z);
        if (teleopVelocity.x != 0 || teleopVelocity.y != 0 || teleopVelocity.z != 0){
            ball.setLinearVelocity(Qt.vector3d(teleopVelocity.x, teleopVelocity.y, teleopVelocity.z));
            let ballFriction = 0.99;
            teleopVelocity = Qt.vector3d(teleopVelocity.x * ballFriction, teleopVelocity.y * ballFriction, teleopVelocity.z * ballFriction);
        }
    }

    function applyRollingFriction()
    {
        let v = ballVelocity
        let speed = Math.sqrt(v.x*v.x + v.y*v.y + v.z*v.z)
        if (speed < 0.001 || speed > 10 || ballPosition.y > 30) {
            return;
        }
        let nx = -v.x / speed
        let ny = -v.y / speed
        let nz = -v.z / speed
        let muu = observer.rollingFriction * 1000.0
        let f = muu
        ball.applyCentralImpulse(Qt.vector3d(nx * f, ny * f, nz * f))
    }

    function syncGameObjects() {
        let blueBotData = sync.updateBot(blue, false);
        let yellowBotData = sync.updateBot(yellow, true);
        sync.updateBall();
        observer.updateObjects(
            blueBotData.positions, 
            yellowBotData.positions, 
            blueBotData.pixels,
            yellowBotData.pixels,
            blueBotData.cameraExists,
            yellowBotData.cameraExists, 
            blueBotData.ballContacts, 
            yellowBotData.ballContacts,
            ballPosition,
            isFoundBall
        );
    }

    function resetPosition(target, result) {
        if (target == "ball") {
            teleopVelocity = Qt.vector4d(0, 0, 0, 0);
            ballVelocity = Qt.vector4d(0, 0, 0, 0);
            ball.reset(result.scenePosition, Qt.vector3d(0, 0, 0));
            for (let i = 0; i < blue.botNum; i++) {
                blue.botFrame.children[i].collisionShapes[5].position = Qt.vector3d(0, 5000, 0);
            }
            for (let i = 0; i < yellow.botNum; i++) {
                yellow.botFrame.children[i].collisionShapes[5].position = Qt.vector3d(0, 5000, 0);
            }
            dribbleInfo.id = -1;
        } else if (target == "bot") {
            if (selectedRobotColor == "blue") {
                bBotsFrame.children[botCursorID].reset(result.scenePosition, Qt.vector3d(0, -90, 0));
            } else if (selectedRobotColor == "yellow") {
                yBotsFrame.children[botCursorID].reset(result.scenePosition, Qt.vector3d(0, 90, 0));
            }
        }
    }

    function resetBotPosition(results) {
        let scenePosition = Qt.vector3d(0, 0, 0);
        for (let i = 0; i < results.length; i++) {
            if (results[i].objectHit.objectName == "field") scenePosition = results[i].scenePosition;
        }
        for (let i = 0; i < results.length; i++) {
            if (results[i].objectHit.objectName.startsWith("b")) {
                selectedRobotColor = "blue";
                botCursorID = parseInt(results[i].objectHit.objectName.slice(1));;
            } else if (results[i].objectHit.objectName.startsWith("y")) {
                selectedRobotColor = "yellow";
                botCursorID = parseInt(results[i].objectHit.objectName.slice(1));;
            }
        }
        if (selectedRobotColor == "blue") {
            bBotsFrame.children[botCursorID].reset(scenePosition, Qt.vector3d(0, -90, 0));
        } else if (selectedRobotColor == "yellow") {
            yBotsFrame.children[botCursorID].reset(scenePosition, Qt.vector3d(0, 90, 0));
        }
    }

    function updateBallModel() {
        for (let i = ballModelNum - 1; i > 0; i--) {
            ballPositions[i] = ballPositions[i - 1];
            ballModels.children[i].position = Qt.vector4d(ballPositions[i].x, ballPositions[i].y, ballPositions[i].z, ballPositions[i].w);
        }
        ballPositions[0] = Qt.vector4d(ball.position.x, ball.position.y, ball.position.z, 0);
    }

    Timer {
        id: kickTimer
        interval: 500
        repeat: false
        running: false
        onTriggered: {
            kickFlag = false;
            kickTimer.running = false;
        }
    }
    Component.onCompleted: {
        for (let i = 0; i < observer.blueRobotCount; i++) {
            let frame = bBotsFrame.children[i];
            frame.reset(Qt.vector3d(frame.position.x, 0, frame.position.z), Qt.vector3d(0, blue.poses[i].w, 0));
        }
        for (let i = 0; i < observer.yellowRobotCount; i++) {
            let frame = yBotsFrame.children[i];
            frame.reset(Qt.vector3d(frame.position.x, 0, frame.position.z), Qt.vector3d(0, yellow.poses[i].w, 0));
        }
        for (let i = 1; i < ballModelNum; i++) {
            ballModels.children[i].children[0].materials[0].opacity = 0.11;
        }
        ballMarker.children[0].materials[0].diffuseColor= "#EB392A";
        ballMarker.children[0].materials[0].opacity = 0.4;
    }
    QtObject {
        id: dribbleInfo
        property var id: -1
        property var isYellow: false
        property real radianBall: 0.0
        property real distanceBall: 0.0
    }
    function test() {
        let i = 1;
        let dx,dy,dz;
        let vx,vy,vz;
        let zf = blue.poses[i].kickspeedz;
        dx = Math.cos(blue.poses[i].w);
        dy = Math.sin(blue.poses[i].w);
        
        let dlen = Math.sqrt(dx*dx+dy*dy);
        vx = dx*blue.poses[i].kickspeedx/dlen;
        vy = dy*blue.poses[i].kickspeedx/dlen;
        vz = zf;
        let vballx = ballVelocity.x;
        let vbally = ballVelocity.z;
        let vn = -(vballx*dx + vbally*dy);
        let vt = -(vballx*dy - vbally*dx);
        vx += vn * dx - vt * dy;
        vy += vn * dy + vt * dx; 

    }
    function placeClothLineBall() {
        if (Math.abs(ball.position.x) > 5500 && Math.abs(ball.position.z) > 4000) {
            ball.reset(Qt.vector3d(5500 * Math.sign(ball.position.x), 21, 4000 * Math.sign(ball.position.z)), Qt.vector3d(0, 0, 0));
            return;
        }

        if (Math.abs(ball.position.x) > 5500) {
            ball.reset(Qt.vector3d(5500 * Math.sign(ball.position.x), 21, ball.position.z), Qt.vector3d(0, 0, 0));
            return;
        }

        if (ball.position.z < 0) {
            ball.reset(Qt.vector3d(ball.position.x, 21, -4000), Qt.vector3d(0, 0, 0));
        } else {
            ball.reset(Qt.vector3d(ball.position.x, 21, 4000), Qt.vector3d(0, 0, 0));
        }
    }
}

