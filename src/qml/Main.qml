import QtQuick
import QtQuick.Window
import Qt3D.Extras
import QtQuick.Scene3D
import QtQuick.Controls
import QtQuick3D.Helpers 
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick3D
import QtQuick3D.Physics
import Qt3D.Render
import MOC

import "settings/"
import "sim/"
import "viz/"

Window {
    id: window
    title: "Moccer-Sim"
    width: windowWidth
    height: windowHeight
    visible: true
    flags: Qt.ExpandedClientAreaHint | Qt.NoTitleBarBackgroundHint
    property int windowWidth: observer.windowWidth
    property int windowHeight: observer.windowHeight
    property var bBotPixelBalls: new Array(16).fill(Qt.vector2d(-1, -1))
    property var yBotPixelBalls: new Array(16).fill(Qt.vector2d(-1, -1))
    property var ball2DPosition: Qt.vector2d(0, 0)
    property var bBot2DPositions: new Array(16).fill(Qt.vector2d(-1, -1))
    property var yBot2DPositions: new Array(16).fill(Qt.vector2d(-1, -1))
    property var cursorPosition: Qt.point(0, 0)
    property int bBotCount: observer.blueRobotCount
    property int yBotCount: observer.yellowRobotCount
    property real runTime: 16.667
    property var selectedCamera: "Overview Camera"
    property real lastTime: 0
    property int key: 0

    Item {
        width: parent.width
        height: parent.height
        focus: true

        PhysicsWorld {
            id: physicsWorld
            scene: viewport.scene
            maximumTimestep: 1000.0 / observer.desiredFps
            minimumTimestep: 1000.0 / observer.desiredFps
            enableCCD: observer.ccdMode
            gravity: Qt.vector3d(0, -observer.gravity*1000.0, 0)
            typicalLength: 100
            typicalSpeed: 1000
            defaultDensity: 1.0
            forceDebugDraw: observer.forceDebugDrawMode
            onFrameDone: (timestep) => {
                game_objects.syncGameObjects();
            }
        }
        Timer {
            interval: 1000.0 / observer.desiredFps
            running: true
            repeat: true
            onTriggered: {
                runTime = (Date.now() - lastTime);
                lastTime = Date.now();
                game_objects.updateGameObjects(runTime);
                // console.log("RunTime:", runTime);
            }
        }
        Timer {
            interval: 1000.0 / (observer.desiredFps / 2)
            running: true
            repeat: true
            onTriggered: {
                game_objects.updateBallModel();
            }
        }
        Keys.onPressed: (event) => {
            event.accepted = true;
            if (event.key === Qt.Key_W) {
                game_objects.teleopVelocity.z += -game_objects.acceleration;
            } else if (event.key === Qt.Key_S) {
                game_objects.teleopVelocity.z += game_objects.acceleration;
            } else if (event.key === Qt.Key_A) {
                game_objects.teleopVelocity.x += -game_objects.acceleration;
            } else if (event.key === Qt.Key_D) {
                game_objects.teleopVelocity.x += game_objects.acceleration;
            }
            key = event.key;
        }
        Keys.onReleased: (event) => {
            if (event.key === Qt.Key_R) {
                key = 0;
            }
        }
        Camera {
            id: camera
        }

        Rectangle {
            anchors.fill: parent
            color: "#848895"
            border.color: "black"

            Observe {
                id: observer
            }

            View3D {
                id: viewport
                anchors.fill: parent
                renderMode: View3D.Offscreen
                property var cameraList: []
                FrameAnimation {
                    id: frameUpdater
                    running: true
                }
                Text {
                    id: cursorText
                    width: 90
                    x: windowWidth - 93
                    y: windowHeight - 23
                    font.pixelSize: 15
                    color: "white"
                    horizontalAlignment: Text.AlignRight
                    text: "(" + cursorPosition.x + "," + cursorPosition.y + ")"
                    opacity: 0.7
                }
                Text {
                    id: fpsText
                    width: 90
                    x: 5
                    y: windowHeight - 23
                    font.pixelSize: 15
                    color: "white"
                    horizontalAlignment: Text.AlignLeft
                    text: "FPS: " +  Math.round(1000.0 / runTime)
                    opacity: 0.7
                }

                Item {
                    id: bBotStatus
                    Repeater {
                        model: observer.blueRobotCount
                        Rectangle {
                            width: 19
                            height: 4
                            color: "transparent"
                            border.color: "#59baf5"
                            opacity: 0.5
                            radius: 1
                        }
                    }
                }
                Item {
                    id: bBotBar
                    Repeater {
                        model: observer.blueRobotCount
                        Rectangle {
                            width: 0
                            height: 3
                            color: "#59baf5"
                            opacity: 0.5
                            radius: 1
                        }
                    }
                }
                Item {
                    id: bBotIDRect
                    Repeater {
                        model: observer.blueRobotCount
                        Rectangle {
                            width: 6
                            height: 6
                            color: "#59baf5"
                            opacity: 0.5
                            radius: 1
                        }
                    }
                }
                Item {
                    id: bBotIDTexts
                    Repeater {
                        model: observer.blueRobotCount
                        Text {
                            horizontalAlignment: Text.AlignLeft
                            font.pixelSize: 6
                            color: "#FFFFFF"
                            text: index
                        }
                    }
                }
                Item {
                    id: yBotStatus
                    Repeater {
                        model: observer.blueRobotCount
                        Rectangle {
                            width: 19
                            height: 4
                            color: "transparent"
                            border.color: "yellow"
                            opacity: 0.5
                            radius: 1
                        }
                    }
                }
                Item {
                    id: yBotBar
                    Repeater {
                        model: observer.yellowRobotCount
                        Rectangle {
                            width: 0
                            height: 3
                            color: "yellow"
                            opacity: 0.5
                            radius: 1
                        }
                    }
                }
                Item {
                    id: yBotIDRect
                    Repeater {
                        model: observer.yellowRobotCount
                        Rectangle {
                            width: 6
                            height: 6
                            color: "yellow"
                            opacity: 0.5
                        }
                    }
                }
                Item {
                    id: yBotIDTexts
                    Repeater {
                        model: observer.yellowRobotCount
                        Text {
                            horizontalAlignment: Text.AlignLeft
                            font.pixelSize: 6
                            color: "#FFFFFF"
                            text: index
                        }
                    }
                }
                Node {
                    id: originNode
                    PerspectiveCamera {
                        id: overviewCamera
                        clipFar: 20000
                        clipNear: 1
                        fieldOfView: 60
                        position: Qt.vector3d(0, 4500, 6140)
                        eulerRotation: Qt.vector3d(-47, 0, 0)
                    }
                }

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    property real dt: 0.001
                    property real linearSpeed: 2000
                    property real lookSpeed: 100
                    property real zoomLimit: 0.16
                    property point lastPos
                    property point clickPos
                    property bool isDraggingWindow: false
                    property bool selectView: false
                    property bool selectBot: false
                    // hoverEnabled: true

                    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

                    onPressed: (event) => {
                        lastPos = Qt.point(event.x, event.y)
                        clickPos = Qt.point(event.x, event.y);
                        isDraggingWindow = (event.y < 35);
                        if (event.button === Qt.LeftButton && key === Qt.Key_R) {
                            game_objects.resetPosition("bot", viewport.pick(event.x, event.y));
                        } else if (event.button === Qt.RightButton) {
                            game_objects.resetPosition("ball", viewport.pick(event.x, event.y));
                        }
                    }
                    onReleased: (event) => {
                        selectBot = false;
                        selectView = false;
                        isDraggingWindow = false;
                    }
                    onPositionChanged: (event) => {
                        let clickDx = event.x - clickPos.x;
                        let clickDy = event.y - clickPos.y;
                        
                        if (isDraggingWindow) {
                            window.x += clickDx
                            window.y += clickDy
                        }
                        let dx = event.x - lastPos.x;
                        let dy = event.y - lastPos.y;
                        
                        let results = viewport.pickAll(event.x, event.y);
                       
                        for (let i = 0; i < results.length; i++) {
                            if (results[i].objectHit.objectName.startsWith("b") || results[i].objectHit.objectName.startsWith("y")) {
                                selectBot = true;
                            }
                            if (results[i].objectHit.objectName === "field") {
                                cursorText.text = "(" + parseInt(results[i].scenePosition.x) + "," + parseInt(-results[i].scenePosition.z) + ")";
                            }
                        }
                        if (selectBot && !selectView) {
                            game_objects.resetBotPosition(results);
                            return;
                        } else {
                            selectView = true;
                        }

                        if (Math.abs(dx) < 2 && Math.abs(dy) < 2) return;

                        if ((mouseArea.pressedButtons & Qt.LeftButton) && (event.modifiers & Qt.ControlModifier)) { // Rotate
                            let rx = dx * dt * linearSpeed * 8;
                            let ry = -dy * dt * linearSpeed * 8;
                            let rz = dy * dt * linearSpeed * 8;

                            let forward = overviewCamera.forward
                            let right = overviewCamera.right
                            let distance = overviewCamera.position.length()

                            overviewCamera.position.x += rx * right.x + rz * forward.x
                            overviewCamera.position.y += ry;
                            overviewCamera.position.z += rx * right.z + rz * forward.z
                        } else if (mouseArea.pressedButtons & Qt.LeftButton) {
                            let pan = -dx * dt * lookSpeed;
                            let tilt = dy * dt * lookSpeed;
                            overviewCamera.eulerRotation.y += pan;
                            overviewCamera.eulerRotation.x += tilt;
                        } else if (mouseArea.pressedButtons & Qt.MiddleButton) {
                            let rz = dy * dt * linearSpeed;
                            let distance = overviewCamera.position.length();
                            if (rz > 0 && distance < zoomLimit) return;
                            overviewCamera.position.z += rz;
                        }
                        lastPos = Qt.point(event.x, event.y);
                    }

                    onWheel: (wheel) => {
                        let rz = wheel.angleDelta.y * dt * linearSpeed
                        let rx = -wheel.angleDelta.x * dt * linearSpeed

                        let forward = overviewCamera.forward
                        let right = overviewCamera.right
                        let distance = overviewCamera.position.length()

                        if (rz > 0 && distance < zoomLimit) return

                        overviewCamera.position.x += rx * right.x + rz * forward.x
                        overviewCamera.position.z += rx * right.z + rz * forward.z
                    }
                    Setting {
                        id: setting
                        property var windowWidth : window.width
                        property var windowHeight : window.height
                        property var visionMulticastPort: observer.visionMulticastPort
                    }
                    View {
                        id: view
                    }
                }
                Node {
                    id: node

                    Lighting {}
                    Field {}

                    GameObjects {
                        id: game_objects
                        property var window: window
                        property var overviewCamera: overviewCamera
                        property vector3d teleopVelocity: Qt.vector3d(0, 0, 0)
                        property real acceleration: 100.0
                        property var field_cursor : Qt.vector3d(0, 0, 0)
                        property var view3D: viewport
                        property var bBotIDTexts: bBotIDTexts
                        property var yBotIDTexts: yBotIDTexts
                    }
                    
                }
            }
        }
    }
    Connections {
        target: observer
        function onSettingChanged() {
            window.width = observer.windowWidth
            window.height = observer.windowHeight

        }
    }
    onSelectedCameraChanged: {
        if (selectedCamera === "Overview Camera") {
            viewport.camera = overviewCamera;
        } else if (selectedCamera == "Selected Robot") {
            if (game_objects.selectedRobotColor === "blue") {
                viewport.camera = game_objects.bBotsCamera[game_objects.botCursorID];
            } else if (game_objects.selectedRobotColor === "yellow") {
                viewport.camera = game_objects.yBotsCamera[game_objects.botCursorID];
            }
        }
    }
    onWidthChanged: {
        observer.windowWidth = width;
        windowWidth = width;
    }
    onHeightChanged: {
        observer.windowHeight = height;
        windowHeight = height;
    }
}