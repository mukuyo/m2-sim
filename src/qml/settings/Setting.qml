import QtQuick
import QtQuick3D
import QtQuick.Shapes
import QtQuick.Controls

Item {
    id: setting
    width: windowWidth
    height: windowHeight
    property int tempWindowWidth: observer.windowWidth
    property int tempWindowHeight: observer.windowHeight

    property string tempVisionMulticastAddress: observer.visionMulticastAddress
    property int tempVisionMulticastPort: observer.visionMulticastPort
    property int tempCommandListenPort: observer.commandListenPort
    property int tempBlueTeamControlPort: observer.blueTeamControlPort
    property int tempYellowTeamControlPort: observer.yellowTeamControlPort
    property bool tempForceDebugDrawMode: observer.forceDebugDrawMode
    property bool tempLightBlueRobotMode: observer.lightBlueRobotMode
    property bool tempLightYellowRobotMode: observer.lightYellowRobotMode
    property bool tempLightStadiumMode: observer.lightStadiumMode
    property bool tempLightFieldMode: observer.lightFieldMode
    property int tempBlueRobotCount : observer.blueRobotCount
    property int tempYellowRobotCount : observer.yellowRobotCount
    property real tempDesiredFps: observer.desiredFps
    property bool tempCCDMode: observer.ccdMode
    property real tempGravity: observer.gravity
    property real tempBallStaticFriction: observer.ballStaticFriction
    property real tempBallDynamicFriction: observer.ballDynamicFriction
    property real tempBallRestitution: observer.ballRestitution
    property real tempFieldWidth: 0
    property real tempFieldHeight: 0
    property real tempLineThickness: 0
    property real tempGoalWidth: 0
    property real tempGoalHeight: 0
    property real tempGoalDepth: 0
    property real tempPenaltyAreaWidth: 0
    property real tempPenaltyAreaDepth: 0
    property int tempNumThreads: observer.numThreads
    // property real tempFieldWidth: observer.fieldWidth
    // property real tempFieldHeight: observer.fieldHeight
    // property real tempLineThickness: observer.lineThickness
    // property real tempGoalWidth: observer.goalWidth
    // property real tempGoalHeight: observer.goalHeight
    // property real tempGoalDepth: observer.goalDepth
    // property real tempPenaltyAreaWidth: observer.penaltyAreaWidth
    // property real tempPenaltyAreaDepth: observer.penaltyAreaDepth


    property var cameraModel: ["Overview Camera", "Selected Robot"]
    property bool isMenuRunning: false

    ListModel {
        id: menuModel
        ListElement { label: "Display"; expandValue: 62; heightValue: 240 }
        ListElement { label: "Physics"; expandValue: 65; heightValue: 450 }
        ListElement { label: "Geometry"; expandValue: 85; heightValue: 190 }
        ListElement { label: "Robots"; expandValue: 60; heightValue: 190 }
        ListElement { label: "Camera"; expandValue: 65; heightValue: 190 }
        ListElement { label: "Light Mode"; expandValue: 65; heightValue: 220 }
        ListElement { label: "Communication"; expandValue: 135; heightValue: 280; }
    }

    HBMenu {}

    Rectangle {
        id: rightShadowRect
        width: windowWidth / 3
        height: windowHeight
        color: "black"
        opacity: 0.72
        x: windowWidth

        CrossMenu {}

        Text {
            id: settingText
            x: 15
            y: 5
            text: "Setting"
            font.pixelSize: 27
            color: "white"
        }

        Column {
            x: 32
            y: 63
            spacing: 18

            Repeater {
                model: menuModel
                List {
                    label: model.label
                    expandValue: model.expandValue
                    property var heightValue: model.heightValue
                    // property int visionMulticastPort: model.visionMulticastPort
                }
            }
        }
        onWidthChanged: {
            if (isMenuRunning) {
                rightShadowRect.x = windowWidth * 2 / 3;
                leftShadowRect.x = 0;
            } else {
                rightShadowRect.x = windowWidth;
                leftShadowRect.x = -windowWidth;
            }
        }
        SequentialAnimation on x {
            id: rightAnim
            running: false
            NumberAnimation {
                to: windowWidth * 2 / 3
                duration: 1000
                easing.type: Easing.OutCubic
            }
            onStopped: {
                isMenuRunning = true;
                rightShadowRect.x = windowWidth * 2 / 3;
            }
        }
        SequentialAnimation on x {
            id: rightReverseAnim
            running: false
            NumberAnimation {
                to: windowWidth
                duration: 1000
                easing.type: Easing.OutCubic
            }
            onStopped: {
                isMenuRunning = false;
                rightShadowRect.x = windowWidth;
            }
        }

        Rectangle {
            id: saveButton
            width: windowWidth / 3 - 60
            height: 45
            x: 30
            y: windowHeight - 65
            color: "#8A8F91"
            opacity: 1.0
            radius: 5
            Text {
                anchors.centerIn: parent
                text: "Save"
                font.pixelSize: 18
                color: "white"
            }
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    observer.windowWidth = tempWindowWidth;
                    observer.windowHeight = tempWindowHeight;
                    observer.visionMulticastAddress = tempVisionMulticastAddress;
                    observer.visionMulticastPort = tempVisionMulticastPort;
                    observer.commandListenPort = tempCommandListenPort;
                    observer.blueTeamControlPort = tempBlueTeamControlPort;
                    observer.yellowTeamControlPort = tempYellowTeamControlPort;
                    observer.forceDebugDrawMode = tempForceDebugDrawMode;
                    observer.lightBlueRobotMode = tempLightBlueRobotMode;
                    observer.lightYellowRobotMode = tempLightYellowRobotMode;
                    observer.lightStadiumMode = tempLightStadiumMode;
                    observer.lightFieldMode = tempLightFieldMode;
                    observer.blueRobotCount = tempBlueRobotCount;
                    observer.yellowRobotCount = tempYellowRobotCount;
                    observer.desiredFps = tempDesiredFps;
                    observer.ccdMode = tempCCDMode;
                    observer.gravity = tempGravity;
                    observer.ballStaticFriction = tempBallStaticFriction;
                    observer.ballDynamicFriction = tempBallDynamicFriction;
                    observer.ballRestitution = tempBallRestitution;
                    observer.numThreads = tempNumThreads;
                    // observer.lineThickness = tempLineThickness;
                    // observer.goalWidth = tempGoalWidth;
                    // observer.goalHeight = tempGoalHeight;
                    // observer.goalDepth = tempGoalDepth;
                    // observer.penaltyAreaWidth = tempPenaltyAreaWidth;
                    // observer.penaltyAreaDepth = tempPenaltyAreaDepth;
                }
            }
        }
    }

    // Left shadow rectangle
    Rectangle {
        id: leftShadowRect
        width: windowWidth * 2 / 3
        height: windowHeight
        color: "black"
        opacity: 0.5
        x: -width

        SequentialAnimation on x {
            id: leftAnim
            running: false
            NumberAnimation {
                to: 0
                duration: 1000
                easing.type: Easing.OutCubic
            }
            onStopped: {
                leftShadowRect.x = 0;
            }
        }
        SequentialAnimation on x {
            id: leftReverseAnim
            running: false
            NumberAnimation {
                to: -width
                duration: 1000
                easing.type: Easing.OutCubic
            }
            onStopped: {
                leftShadowRect.x = -width;
            }
        }
    }
}
