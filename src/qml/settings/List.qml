import QtQuick
import QtQuick3D
import QtQuick.Shapes
import QtQuick.Controls

Item {
    id: triangleContainer
    property string label: ""
    property real lineEnd: 0
    property real expandValue: 65
    property real triangleAngle: 0
    property bool menuVisible: false
    property real menuHeight: 0
    
    width: 80 * (expandValue / 65)
    height: 20 + menuHeight

    ListModel {
        id: displayItems
        ListElement { name: "Width"; detail: ""; slider: true; toggle: false; combo: false; InitValue: 1100; MaxValue: 2560 }
        ListElement { name: "Height"; detail: ""; slider: true; toggle: false; combo: false; InitValue: 720; MaxValue: 1240 }
        ListElement { name: "Force Debug Draw"; detail: "Enable drawing of all active shapes"; slider: false; toggle: true; combo: false; InitValue: 0 }
        ListElement { name: "Thread Numner"; detail: "Number of threads (-1 for auto)"; slider: false; toggle: false; combo: false; InitValue: -1  }
    }
    ListModel {
        id: physicsItems
        ListElement { name: "Desired FPS"; detail: ""; slider: true; toggle: false; combo: false; InitValue: 60.0; MaxValue: 60.0 }
        ListElement { name: "Gravity"; detail: ""; slider: true; toggle: false; combo: false; InitValue: 9.812; MaxValue: 100 }
        ListElement { name: "Continuous Collision Detection"; detail: "※ Restart after changing this mode"; slider: false; toggle: true; combo: false; InitValue: 1 }
        // ListElement { name: "Ball Radius"; detail: ""; slider: true; toggle: false; combo: false; InitValue: 0.1; MaxValue: 0.5 }
        // ListElement { name: "Ball Mass"; detail: ""; slider: true; toggle: false; combo: false; InitValue: 0.043; MaxValue: 10 }
        // ListElement { name: "Ball Static Friction"; detail: ""; slider: true; toggle: false; combo: false; InitValue: 0.11; MaxValue: 10 }
        // ListElement { name: "Ball Dynamic Friction"; detail: ""; slider: true; toggle: false; combo: false; InitValue: 0.11; MaxValue: 10 }
        ListElement { name: "Ball Restitution"; detail: ""; slider: true; toggle: false; combo: false; InitValue: 1.0; MaxValue: 1 }
        ListElement { name: "Rolling Friction"; detail: ""; slider: true; toggle: false; combo: false; InitValue: 0.02; MaxValue: 1 }
        ListElement { name: "Kicker Friction"; detail: ""; slider: true; toggle: false; combo: false; InitValue: 0.8; MaxValue: 1 }
    }
    ListModel {
        id: geometryItems
        ListElement { name: "Line Thickness"; detail: ""; slider: true; toggle: false; combo: false; InitValue: 0.5; MaxValue: 2 }
        // ListElement { name: "Field Width"; detail: ""; slider: true; toggle: false; combo: false; InitValue: 68; MaxValue: 100 }
        // ListElement { name: "Field Height"; detail: ""; slider: true; toggle: false; combo: false; InitValue: 105; MaxValue: 150 }
        // ListElement { name: "Goal Width"; detail: ""; slider: true; toggle: false; combo: false; InitValue: 7.32; MaxValue: 10 }
        // ListElement { name: "Goal Depth"; detail: ""; slider: true; toggle: false; combo: false; InitValue: 2.44; MaxValue: 5 }
        // ListElement { name: "Goal Height"; detail: ""; slider: true; toggle: false; combo: false; InitValue: 2.44; MaxValue: 5 }
        // ListElement { name: "Penalty Area Width"; detail: ""; slider: true; toggle: false; combo: false; InitValue: 16.5; MaxValue: 20 }
        // ListElement { name: "Penalty Area Depth"; detail: ""; slider: true; toggle: false; combo: false; InitValue: 40.3; MaxValue: 50 }
    }
    ListModel {
        id: robotItems
        ListElement { name: "Blue Robot Count"; detail: ""; slider: true; toggle: false; combo: false; InitValue: 9; MaxValue: 16 }
        ListElement { name: "Yellow Robot Count"; detail: ""; slider: true; toggle: false; combo: false; InitValue: 9; MaxValue: 16 }
    }
    ListModel {
        id: cameraItems
        ListElement { name: "Main Camera"; detail: "Switch to one of the cameras"; slider: false; toggle: false; combo: true; InitValue: 0; MaxValue: -2 }
        // ListElement { name: "Overview Camera Position"; detail: ""; slider: false; toggle: false; combo: false; InitValue: 0; MaxValue: -2; InitString: "0, 10, 20" }
        // ListElement { name: "Overview Camera Distance"; detail: ""; slider: true; toggle: false; combo: false; InitValue: 10; MaxValue: 20 }
        // ListElement { name: "Overview Camera Height"; detail: ""; slider: true; toggle: false; combo: false; InitValue: 5; MaxValue: 10 }
        // ListElement { name: "Overview Camera Angle"; detail: ""; slider: true; toggle: false; combo: false; InitValue: 30; MaxValue: 60 }
    }
    ListModel {
        id: lightItems
        ListElement { name: "Blue Robot"; detail: "Light mode for blue team robots"; slider: false; toggle: true; combo: false; InitValue: 0; MaxValue: -2 }
        ListElement { name: "Yellow Robot"; detail: "Light mode for yellow team robots"; slider: false; toggle: true; combo: false; InitValue: 0; MaxValue: -2 }
        ListElement { name: "Stadium"; detail: "Light mode for stadium"; slider: false; toggle: true; combo: false; InitValue: 0; MaxValue: -2 }
        ListElement { name: "Field"; detail: "Light mode for field"; slider: false; toggle: true; combo: false; InitValue: 0; MaxValue: -2 }
    }
    ListModel {
        id: communicationItems
        ListElement { name: "Vision Multicast Address"; detail: "Address for vision data multicast"; slider: false; toggle: false; combo: false; InitValue: -2; MaxValue: -2; InitString: "-2" }
        ListElement { name: "Vision Multicast Port"; detail: "Port for vision data multicast"; slider: false; toggle: false; combo: false; InitValue: 10020; MaxValue: -2 }
        ListElement { name: "Command Listen Port"; detail: "Port for command listening"; slider: false; toggle: false; combo: false; InitValue: 20011; MaxValue: -2 }
        ListElement { name: "Blue Control Port"; detail: "Port for blue team control"; slider: false; toggle: false; combo: false; InitValue: 30011; MaxValue: -2 }
        ListElement { name: "Yellow Control Port"; detail: "Port for yellow team control"; slider: false; toggle: false; combo: false; InitValue: 30012; MaxValue: -2 }
    }

    
    ListModel {
        id: itemModel
    }
    Component.onCompleted: {
        if (label == "Display") {
            itemModel.clear();
            for (var i = 0; i < displayItems.count; i++) {
                itemModel.append(displayItems.get(i));
            }
        } else if (label == "Physics") {
            itemModel.clear();
            for (var i = 0; i < physicsItems.count; i++) {
                itemModel.append(physicsItems.get(i));
            }
        } else if (label == "Geometry") {
            itemModel.clear();
            for (var i = 0; i < geometryItems.count; i++) {
                itemModel.append(geometryItems.get(i));
            }
        } else if (label == "Robots") {
            itemModel.clear();
            for (var i = 0; i < robotItems.count; i++) {
                itemModel.append(robotItems.get(i));
            }
        } else if (label == "Camera") {
            itemModel.clear();
            for (var i = 0; i < cameraItems.count; i++) {
                itemModel.append(cameraItems.get(i));
            }
        } else if (label == "Light Mode") {
            itemModel.clear();
            for (var i = 0; i < lightItems.count; i++) {
                itemModel.append(lightItems.get(i));
            }
        } else if (label == "Communication") {
            itemModel.clear();
            for (var i = 0; i < communicationItems.count; i++) {
                itemModel.append(communicationItems.get(i));
            }
        }
    }

    Text {
        x: 15
        y: -9
        height: menuHeight
        text: label
        font.pixelSize: 20
        color: "white"
    }

    Item {
        id: triangleVisual
        width: 300
        height: 16
        Item {
            id: triangleRotated
            width: parent.width
            height: parent.height
            anchors.fill: parent
            transform: Rotation {
                id: triangleRotation
                origin.x: 4
                origin.y: 4
                axis { x: 0; y: 0; z: 1 }
                angle: triangleAngle
            }

            Shape {
                anchors.fill: parent
                ShapePath {
                    strokeWidth: 0
                    fillColor: "white"
                    PathMove { x: 0; y: 0 }
                    PathLine { x: 8; y: 4 }
                    PathLine { x: 0; y: 8 }
                }
            }

            NumberAnimation {
                id: lineAnim
                target: triangleContainer
                property: "lineEnd"
                to: expandValue
                duration: 400
                easing.type: Easing.InOutQuad
            }
            NumberAnimation {
                id: lineAnimBack
                target: triangleContainer
                property: "lineEnd"
                to: 0
                duration: 400
                easing.type: Easing.InOutQuad
            }
        }
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: lineAnim.running = true
            onExited: lineAnimBack.running = true
            onClicked: {
                triangleAnim.from = triangleAngle
                triangleAngle += 90
                if (triangleAngle >= 180) triangleAngle = 0
                triangleAnim.to = triangleAngle
                triangleAnim.running = true

                menuVisible = !menuVisible
                heightAnim.from = menuHeight
                heightAnim.to = menuVisible ? heightValue : 0
                heightAnim.running = true
            }
            cursorShape: Qt.PointingHandCursor
        }
    }
    MenuWrapper {
        // id: menuWrapper
        // y: 20
        // width: parent.width
        // height: menuHeight
        // model: itemModel
    }
    Shape {
        ShapePath {
            strokeColor: "white"
            strokeWidth: 1
            fillColor: "transparent"
            PathMove { x: 16; y: 16 }
            PathLine { x: 16 + triangleContainer.lineEnd; y: 16 }
        }
    }


    NumberAnimation {
        id: triangleAnim
        target: triangleRotation
        property: "angle"
        duration: 500
        easing.type: Easing.InOutQuad
    }

    NumberAnimation {
        id: heightAnim
        target: triangleContainer
        property: "menuHeight"
        duration: 300
        easing.type: Easing.InOutQuad
    }
}
