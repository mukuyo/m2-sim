import QtQuick
import QtQuick3D
import Qt3D.Render
import Qt3D.Extras
import QtQuick3D.Physics
import Qt.labs.folderlistmodel
import MOC

import "../../../assets/models/bot/Rione/viz" as BlueBody
import "../../../assets/models/bot/Rione/rigid_body" as BlueLightBody
import "../../../assets/models/bot/Rione/viz" as YellowBody
import "../../../assets/models/bot/Rione/rigid_body" as YellowLightBody
import "../../../assets/models/ball/"
import "../../../assets/models/circle/ball/"

Node {
    id: robotNode

    RobotInfo {
        id: blue
        num: observer.blueRobotCount
        lightRobotMode: observer.lightBlueRobotMode
        colorHeight: 0.15
        poses: [
            Qt.vector4d(500, 0, 2000, -90),
            Qt.vector4d(750, 0, 2000, -90),
            Qt.vector4d(750, 0, 3000, -90),
            Qt.vector4d(2000, 0, 1500, -90),
            Qt.vector4d(2000, 0, 1800, -90),
            Qt.vector4d(3500, 0, 2000, -90),
            Qt.vector4d(3500, 0, 4000, -90),
            Qt.vector4d(3500, 0, 4500, -90),
            Qt.vector4d(5000, 0, 3500, -90),
            Qt.vector4d(5000, 0, 3000, -90),
            Qt.vector4d(6000, 0, 0, -90),
        ]
    }
    RobotInfo {
        id: yellow
        num: observer.yellowRobotCount
        lightRobotMode: observer.lightYellowRobotMode
        colorHeight: 0.15
        poses: [
            Qt.vector4d(-500, 0, -2000, 90),
            Qt.vector4d(-750, 0, -2000, 90),
            Qt.vector4d(-750, 0, -3000, 90),
            Qt.vector4d(-2000, 0, -1500, 90),
            Qt.vector4d(-2000, 0, -1800, 90),
            Qt.vector4d(-3500, 0, -2000, 90),
            Qt.vector4d(-3500, 0, -4000, 90),
            Qt.vector4d(-3500, 0, -4500, 90),
            Qt.vector4d(-5000, 0, -3500, 90),
            Qt.vector4d(-5000, 0, -3000, 90),
            Qt.vector4d(-6000, 0, 0, 90),
        ]
    }
    Sync {
        id: sync
    }
    property real colorHeight: 0.15

    property real radianOffset: -Math.atan(350.0/547.72)
    property var selectedRobotColor: "blue"
    property real botCursorID: 0
    property var kick_flag: false
    property var isDribble: false
    property var dribbleNum: -1
    property var ballPosition: Qt.vector3d(0, 0, 0)
    
    MotionControl {
        id: motionControl
    }
    MathUtils {
        id: mu
    }

    // onLightBlueRobotModeChanged: {
    //     if (observer.lightBlueRobotMode) {
    //         colorHeight = 0.3;
    //     } else {
    //         colorHeight = 0.15;
    //     }
    // }
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
        }
    }
    Repeater3D {
        id: yBotsFrame
        model: yellow.num
        DynamicRigidBody {
            objectName: "y" + String(index)
            linearAxisLock: DynamicRigidBody.LockY
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
        }
    }
    
    Repeater3D {
        id: bBotsRepeater
        model: blue.num
        delegate: Node {
            property int botIndex: index
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
                source: "#Cylinder"
                pickable: true
                objectName: "b"+String(index)
                scale: Qt.vector3d(2.3, 1.2, 2.3)
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
                            Qt.vector3d(65*Math.cos(Math.PI-radianOffset-blue.poses[index].w), 0, 65*Math.sin(Math.PI-radianOffset-blue.poses[index].w)),  // Left Up
                            Qt.vector3d(65*Math.cos(Math.PI/2.0-radianOffset-blue.poses[index].w), 0, 65*Math.sin(Math.PI/2.0-radianOffset-blue.poses[index].w)), // Left Down
                            Qt.vector3d(65*Math.cos(Math.PI/2.0+radianOffset-blue.poses[index].w), 0, 65*Math.sin(Math.PI/2.0+radianOffset-blue.poses[index].w)), // Right Down
                            Qt.vector3d(65*Math.cos(radianOffset-blue.poses[index].w), 0, 65*Math.sin(radianOffset-blue.poses[index].w))   // Right Up
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
        id: yBotsRepeater
        model: yellow.num
        delegate: Node {
            property int botIndex: index
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
                source: "#Cylinder"
                pickable: true
                objectName: "y"+String(index)
                scale: Qt.vector3d(2.3, 1.2, 2.3)
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
                            Qt.vector3d(65*Math.cos(Math.PI-radianOffset-yellow.poses[index].w), 0, 65*Math.sin(Math.PI-radianOffset-yellow.poses[index].w)), // Left Up
                            Qt.vector3d(65*Math.cos(Math.PI/2.0-radianOffset-yellow.poses[index].w), 0, 65*Math.sin(Math.PI/2.0-radianOffset-yellow.poses[index].w)), // Left Down
                            Qt.vector3d(65*Math.cos(Math.PI/2.0+radianOffset-yellow.poses[index].w), 0, 65*Math.sin(Math.PI/2.0+radianOffset-yellow.poses[index].w)), // Right Down
                            Qt.vector3d(65*Math.cos(radianOffset-yellow.poses[index].w), 0, 65*Math.sin(radianOffset-yellow.poses[index].w))   // Right Up
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
        staticFriction: observer.ballStaticFriction
        dynamicFriction: observer.ballDynamicFriction
        restitution: observer.ballRestitution
    }

    DynamicRigidBody {
        id: ball
        objectName: "ball"
        massMode: DynamicRigidBody.Mass
        mass: 0.043
        position: Qt.vector3d(0, 500, 0)
        physicsMaterial: ballMaterial
        collisionShapes: [
            ConvexMeshShape {
                id: ballShape
                source: "../../../assets/models/ball/meshes/ball.cooked.cvx"
            }
        ]
    }
    Ball {
        id: tempBall
    }

    function botMovement(color, timestep, isYellow=false) {
        let botFrame = isYellow ? yBotsFrame : bBotsFrame;
        let botRepeater = isYellow ? yBotsRepeater : bBotsRepeater;

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
            if (frame.eulerRotation.x > 0 || frame.eulerRotation.z > 0)
                frame.eulerRotation = Qt.vector3d(0, frame.eulerRotation.y, 0);

            let botDistanceBall = Math.sqrt(Math.pow(frame.position.x - ballPosition.x, 2) + Math.pow(frame.position.z - ballPosition.z, 2) + Math.pow(frame.position.y - ballPosition.y, 2));
            let botRadianBall = mu.normalizeRadian(Math.atan2(frame.position.z - ballPosition.z, frame.position.x - ballPosition.x) - Math.PI + color.poses[i].w);
            // if (!isYellow && i ==0)
            //     console.log("bot", i, "distance to ball:", botDistanceBall, "radian to ball:", botRadianBall);
            
            if ((botDistanceBall < 105 * Math.cos(Math.abs(botRadianBall)) && Math.abs(botRadianBall) < Math.PI/15.0)) {
                // isDribble = true;
                // if (color.spinners[i] > 0 && (color.kickspeeds[i].x == 0 && color.kickspeeds[i].y == 0)) {
                //     color.holds[i] = true;
                //     ball.reset(Qt.vector3d(100000, 0, 100000), Qt.vector3d(0, 0, 0));
                //     tempBallFrame.position = Qt.vector3d(95*Math.tan(botRadianBall), 25, -95);
                //     ballPosition = Qt.vector3d(frame.position.x + (95 * Math.cos(-color.poses[i].w + botRadianBall)), -(frame.position.z + (95 * Math.sin(-color.poses[i].w + botRadianBall))), 25);
                // }
                if (color.kickspeeds[i].x != 0 || color.kickspeeds[i].y != 0) {
                    sync.kick(color, frame, i, color.poses[i].w);
                }
            } else {
                // color.holds[i] = false;
                // tempBallFrame.position = Qt.vector3d(0, 5000, 0);
            }
        }
    }

    function updateGameObjects(timestep) 
    {
        isDribble = false;
        
        botMovement(blue, timestep);
        botMovement(yellow, timestep, true);

        if(!isDribble){
            kick_flag = false;
        }

        ball2DPosition = Qt.vector2d(ball.position.x, ball.position.z);
        // if (teleopVelocity.x != 0 || teleopVelocity.y != 0 || teleopVelocity.z != 0){
        //     if (!kick_flag) {
        //         ball.setLinearVelocity(Qt.vector3d(teleopVelocity.x, teleopVelocity.y, teleopVelocity.z));
        //         let ballFriction = 0.99;
        //         teleopVelocity = Qt.vector3d(teleopVelocity.x * ballFriction, teleopVelocity.y * ballFriction, teleopVelocity.z * ballFriction);
        //     } else {
        //         teleopVelocity = Qt.vector3d(0, 0, 0);
        //     }
        // }
    }

    function syncGameObjects() {
        dribbleNum = -1;
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
            ballPosition
        );
    }

    function resetPosition(target, result) {
        if (target == "ball") {
            teleopVelocity = Qt.vector3d(0, 0, 0);
            ball.reset(result.scenePosition, Qt.vector3d(0, 0, 0));
            for (let i = 0; i < blue.botNum; i++) {
                blue.botFrame.children[i].collisionShapes[5].position = Qt.vector3d(0, 5000, 0);
            }
            for (let i = 0; i < yellow.botNum; i++) {
                yellow.botFrame.children[i].collisionShapes[5].position = Qt.vector3d(0, 5000, 0);
            }
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

    Component.onCompleted: {
        for (let i = 0; i < observer.blueRobotCount; i++) {
            let frame = bBotsFrame.children[i];
            let bot = bBotsRepeater.children[i];
            frame.reset(Qt.vector3d(frame.position.x, 0, frame.position.z), Qt.vector3d(0, -90, 0));
            bot.position = Qt.vector3d(frame.position.x, frame.position.y, frame.position.z);
            bot.eulerRotation = Qt.vector3d(frame.eulerRotation.x, frame.eulerRotation.y, frame.eulerRotation.z);
        }
        for (let i = 0; i < observer.yellowRobotCount; i++) {
            let frame = yBotsFrame.children[i];
            let bot = yBotsRepeater.children[i];
            frame.reset(Qt.vector3d(frame.position.x, 0, frame.position.z), Qt.vector3d(0, 90, 0));
            bot.position = Qt.vector3d(frame.position.x, frame.position.y, frame.position.z);
            bot.eulerRotation = Qt.vector3d(frame.eulerRotation.x, frame.eulerRotation.y, frame.eulerRotation.z);
        }
    }
}

