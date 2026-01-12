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
        ListElement { name: "Ball Static Friction"; detail: ""; slider: true; toggle: false; combo: false; InitValue: 0.11; MaxValue: 10 }
        ListElement { name: "Ball Dynamic Friction"; detail: ""; slider: true; toggle: false; combo: false; InitValue: 0.11; MaxValue: 10 }
        ListElement { name: "Ball Restitution"; detail: ""; slider: true; toggle: false; combo: false; InitValue: 1.0; MaxValue: 10 }
        ListElement { name: "Rolling Friction"; detail: ""; slider: true; toggle: false; combo: false; InitValue: 0.02; MaxValue: 10 }
        ListElement { name: "Kicker Friction"; detail: ""; slider: true; toggle: false; combo: false; InitValue: 0.8; MaxValue: 10 }
    }
    ListModel {
        id: geometryItems
        ListElement { name: "Line Thickness"; detail: ""; slider: true; toggle: false; combo: false; InitValue: 0.5; MaxValue: 2 }
        ListElement { name: "Field Width"; detail: ""; slider: true; toggle: false; combo: false; InitValue: 68; MaxValue: 100 }
        ListElement { name: "Field Height"; detail: ""; slider: true; toggle: false; combo: false; InitValue: 105; MaxValue: 150 }
        ListElement { name: "Goal Width"; detail: ""; slider: true; toggle: false; combo: false; InitValue: 7.32; MaxValue: 10 }
        ListElement { name: "Goal Depth"; detail: ""; slider: true; toggle: false; combo: false; InitValue: 2.44; MaxValue: 5 }
        ListElement { name: "Goal Height"; detail: ""; slider: true; toggle: false; combo: false; InitValue: 2.44; MaxValue: 5 }
        ListElement { name: "Penalty Area Width"; detail: ""; slider: true; toggle: false; combo: false; InitValue: 16.5; MaxValue: 20 }
        ListElement { name: "Penalty Area Depth"; detail: ""; slider: true; toggle: false; combo: false; InitValue: 40.3; MaxValue: 50 }
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

    Shape {
        ShapePath {
            strokeColor: "white"
            strokeWidth: 1
            fillColor: "transparent"
            PathMove { x: 16; y: 16 }
            PathLine { x: 16 + triangleContainer.lineEnd; y: 16 }
        }
    }

    Item {
        id: menuWrapper
        width: 340
        height: menuHeight
        anchors.top: triangleVisual.bottom
        anchors.left: triangleVisual.left
        anchors.topMargin: 8
        clip: true

        Column {
            id: menuColumn
            x: 12
            spacing: 2

            Repeater {
                model: itemModel
                Column {
                    property int index: index
                    spacing: 3

                    Text {
                        height: 55
                        text: "・" + model.name
                        color: "white"
                        font.pixelSize: 18
                    }
                    Item {
                        x: 215
                        visible: model.InitValue === -2
                        Column {
                            spacing: 5

                            TextField {
                                width: 86
                                text: model.InitString || ""
                                placeholderText: "ex: 192.168.0.1"
                                font.pixelSize: 14
                                validator: RegularExpressionValidator {
                                    regularExpression: /^((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)\.){3}(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)$/
                                }
                                horizontalAlignment: Text.AlignHCenter
                                Component.onCompleted: {
                                    text = observer.visionMulticastAddress
                                }
                                onEditingFinished: {
                                    if (text !== "") {
                                        model.InitString = text;
                                        if (model.name === "Vision Multicast Address") {
                                            tempVisionMulticastAddress = text;
                                        }
                                    } else {
                                        text = model.InitString || "";
                                    }
                                }
                            }
                        }
                    }
                    Item {
                        visible: !model.slider && !model.toggle && !model.combo && model.InitValue !== -2

                        TextField {
                            x: 250
                            width: 54
                            height: 24
                            text: model.InitValue.toString()
                            font.pixelSize: 14
                            color: "white"
                            horizontalAlignment: Text.AlignHCenter
                            Component.onCompleted: {
                                if (model.name === "Vision Multicast Port") {
                                    text = observer.visionMulticastPort.toString();
                                } else if (model.name === "Command Listen Port") {
                                    text = observer.commandListenPort.toString();
                                } else if (model.name === "Blue Control Port") {
                                    text = observer.blueTeamControlPort.toString();
                                } else if (model.name === "Yellow Control Port") {
                                    text = observer.yellowTeamControlPort.toString();
                                } else if (model.name === "Thread Numner") {
                                    text = observer.numThreads.toString();
                                } else {
                                    text = model.InitValue.toString();
                                }
                            }
                            onEditingFinished: {
                                let newValue = parseInt(text)
                                if (!isNaN(newValue) && newValue >= 0) {
                                    model.InitValue = newValue;
                                    model.value = newValue;
                                    if (model.name === "Vision Multicast Port") {
                                        tempVisionMulticastPort = newValue;
                                    } else if (model.name === "Command Listen Port") {
                                        tempCommandListenPort = newValue;
                                    } else if (model.name === "Blue Control Port") {
                                        tempBlueControlPort = newValue;
                                    } else if (model.name === "Yellow Control Port") {
                                        tempYellowControlPort = newValue;
                                    } else if (model.name === "Thread Numner") {
                                        tempNumThreads = newValue;
                                    }
                                } else {
                                    text = model.InitValue.toString()
                                }
                            }
                        }
                    }
                    Item {
                        y: 25
                        visible: model.detail !== "" || model.toggle || model.slider || model.combo
                        Text {
                            text: model.detail
                            x: 18
                            height: 30
                            color: "white"
                            opacity: 0.7
                            font.pixelSize: 14
                            visible: model.detail !== ""
                        }
                        
                        ToggleSwitch {
                            id: toggleSwitch
                            x: 275
                            y: 0
                            visible: model.toggle
                        }
                        Item {
                            visible: model.combo
                            x: 165
                            y: -26
                            ComboBox {
                                model: cameraModel
                                onCurrentIndexChanged: {
                                    selectedCamera = cameraModel[currentIndex];
                                }
                            }
                        }
                    }
                    Item {
                        width: 280
                        visible: model.slider

                        Slider {
                            id: slider
                            width: parent.width-60
                            x: 15
                            y: 25
                            from: 0.0
                            to: model.MaxValue
                            stepSize: 0.01
                            value: model.InitValue.toFixed(2)

                            onValueChanged: {
                                if (textField.text !== value.toString()) {
                                    if (model.name === "Width") {
                                        tempWindowWidth = value;
                                        model.value = tempWindowWidth;
                                    } else if (model.name === "Height") {
                                        tempWindowHeight = value;
                                        model.value = tempWindowHeight;
                                    } else if (model.name === "Blue Robot Count") {
                                        tempBlueRobotCount = value;
                                        model.value = tempBlueRobotCount;
                                    } else if (model.name === "Yellow Robot Count") {
                                        tempYellowRobotCount = value;
                                        model.value = tempYellowRobotCount;
                                    } else if (model.name === "Desired FPS") {
                                        tempDesiredFps = value;
                                        model.value = tempDesiredFps;
                                    } else if (model.name === "Gravity") {
                                        tempGravity = value.toFixed(2);
                                        model.value = tempGravity;
                                    } else if (model.name === "Ball Static Friction") {
                                        tempBallStaticFriction = value.toFixed(2);
                                        model.value = tempBallStaticFriction;
                                    } else if (model.name === "Ball Dynamic Friction") {
                                        tempBallDynamicFriction = value.toFixed(2);
                                        model.value = tempBallDynamicFriction;
                                    } else if (model.name === "Ball Restitution") {
                                        tempBallRestitution = value.toFixed(2);
                                        model.value = tempBallRestitution;
                                    } else if (model.name === "Rolling Friction") {
                                        tempRollingFriction = value.toFixed(2);
                                        model.value = tempRollingFriction;
                                    } else if (model.name === "Kicker Friction") {
                                        tempKickerFriction = value.toFixed(2);
                                        model.value = tempKickerFriction;
                                    } else if (model.name === "Line Thickness") {
                                        tempLineThickness = value;
                                        model.value = tempLineThickness;
                                    } else if (model.name === "Field Width") {
                                        tempFieldWidth = value;
                                        model.value = tempFieldWidth;
                                    } else if (model.name === "Field Height") {
                                        tempFieldHeight = value;
                                        model.value = tempFieldHeight;
                                    } else if (model.name === "Goal Width") {
                                        tempGoalWidth = value;
                                        model.value = tempGoalWidth;
                                    } else if (model.name === "Goal Depth") {
                                        tempGoalDepth = value;
                                        model.value = tempGoalDepth;
                                    } else if (model.name === "Goal Height") {
                                        tempGoalHeight = value;
                                        model.value = tempGoalHeight;
                                    } else if (model.name === "Penalty Area Width") {
                                        tempPenaltyAreaWidth = value;
                                        model.value = tempPenaltyAreaWidth;
                                    } else if (model.name === "Penalty Area Depth") {
                                        tempPenaltyAreaDepth = value;
                                        model.value = tempPenaltyAreaDepth;
                                    }
                                    if (model.value !== undefined) {
                                        textField.text = model.value.toString();
                                    }
                                }
                            }
                            Component.onCompleted: {
                                if (model.name === "Width") {
                                    value = observer.windowWidth;
                                    tempWindowWidth = value;
                                } else if (model.name === "Height") {
                                    value = observer.windowHeight;
                                    tempWindowHeight = value;
                                } else if (model.name === "Blue Robot Count") {
                                    value = observer.blueRobotCount;
                                    tempBlueRobotCount = value;
                                } else if (model.name === "Yellow Robot Count") {
                                    value = observer.yellowRobotCount;
                                    tempYellowRobotCount = value;
                                } else if (model.name === "Desired FPS") {
                                    value = observer.desiredFps;
                                    tempDesiredFps = value;
                                } else if (model.name === "Gravity") {
                                    value = observer.gravity;
                                    tempGravity = value.toFixed(2);
                                } else if (model.name === "Ball Static Friction") {
                                    value = observer.ballStaticFriction;
                                    tempBallStaticFriction = value.toFixed(2);
                                } else if (model.name === "Ball Dynamic Friction") {
                                    value = observer.ballDynamicFriction;
                                    tempBallDynamicFriction = value.toFixed(2);
                                } else if (model.name === "Ball Restitution") {
                                    value = observer.ballRestitution;
                                    tempBallRestitution = value.toFixed(2);
                                } else if (model.name === "Rolling Friction") {
                                    value = observer.rollingFriction;
                                    tempRollingFriction = value.toFixed(2);
                                } else if (model.name === "Kicker Friction") {
                                    value = observer.kickerFriction;
                                    tempKickerFriction = value.toFixed(2);
                                
                                // } else if (model.name === "Line Thickness") {
                                //     value = observer.lineThickness;
                                // } else if (model.name === "Field Width") {
                                //     value = observer.fieldWidth;
                                // } else if (model.name === "Field Height") {
                                //     value = observer.fieldHeight;
                                // } else if (model.name === "Goal Width") {
                                //     value = observer.goalWidth;
                                // } else if (model.name === "Goal Depth") {
                                //     value = observer.goalDepth;
                                // } else if (model.name === "Goal Height") {
                                //     value = observer.goalHeight;
                                // } else if (model.name === "Penalty Area Width") {
                                //     value = observer.penaltyAreaWidth;
                                // } else if (model.name === "Penalty Area Depth") {
                                //     value = observer.penaltyAreaDepth;
                                }
                            }
                        }

                        TextField {
                            id: textField
                            x: parent.width - 30
                            y: 25
                            width: 40
                            // height: 24
                            text: model.InitValue.toFixed(2)
                            
                            font.pixelSize: 14
                            color: "white"
                            horizontalAlignment: Text.AlignRight
                            Component.onCompleted: {
                                if (model.name === "Width") {
                                    text = observer.windowWidth.toString();
                                } else if (model.name === "Height") {
                                    text = observer.windowHeight.toString();
                                } else if (model.name === "Blue Robot Count") {
                                    text = observer.blueRobotCount.toString();
                                } else if (model.name === "Yellow Robot Count") {
                                    text = observer.yellowRobotCount.toString();
                                } else if (model.name === "Desired FPS") {
                                    text = observer.desiredFps.toString();
                                } else if (model.name === "Gravity") {
                                    text = observer.gravity.toString();
                                } else if (model.name === "Ball Static Friction") {
                                    text = observer.ballStaticFriction.toString();
                                } else if (model.name === "Ball Dynamic Friction") {
                                    text = observer.ballDynamicFriction.toString();
                                } else if (model.name === "Ball Restitution") {
                                    text = observer.ballRestitution.toString();
                                } else if (model.name === "Rolling Friction") {
                                    text = observer.rollingFriction.toString();
                                } else if (model.name === "Kicker Friction") {
                                    text = observer.kickerFriction.toString();
                                
                                // } else if (model.name === "Line Thickness") {
                                //     text = observer.lineThickness.toString();
                                // } else if (model.name === "Field Width") {
                                //     text = observer.fieldWidth.toString();
                                // } else if (model.name === "Field Height") {
                                //     text = observer.fieldHeight.toString();
                                // } else if (model.name === "Goal Width") {
                                //     text = observer.goalWidth.toString();
                                // } else if (model.name === "Goal Depth") {
                                //     text = observer.goalDepth.toString();
                                // } else if (model.name === "Goal Height") {
                                //     text = observer.goalHeight.toString();
                                // } else if (model.name === "Penalty Area Width") {
                                //     text = observer.penaltyAreaWidth.toString();
                                // } else if (model.name === "Penalty Area Depth") {
                                //     text = observer.penaltyAreaDepth.toString();
                                }
                            }
                            onEditingFinished: {
                                let newValue = parseFloat(text)
                                if (!isNaN(newValue) && newValue >= slider.from && newValue <= slider.to) {
                                    slider.value = newValue
                                    model.InitValue = newValue
                                    if (model.name === "Width") {
                                        tempWindowWidth = parseInt(newValue);
                                    } else if (model.name === "Height") {
                                        tempWindowHeight = parseInt(newValue);
                                    } else if (model.name === "Blue Robot Count") {
                                        tempBlueRobotCount = parseInt(newValue);
                                    } else if (model.name === "Yellow Robot Count") {
                                        tempYellowRobotCount = parseInt(newValue);
                                    } else if (model.name === "Desired FPS") {
                                        tempDesiredFps = parseInt(newValue);
                                    } else if (model.name === "Gravity") {
                                        tempGravity = newValue.toFixed(2);
                                    } else if (model.name === "Ball Static Friction") {
                                        tempBallStaticFriction = newValue.toFixed(2);
                                    } else if (model.name === "Ball Dynamic Friction") {
                                        tempBallDynamicFriction = newValue.toFixed(2);
                                    } else if (model.name === "Ball Restitution") {
                                        tempBallRestitution = newValue.toFixed(2);
                                    } else if (model.name === "Rolling Friction") {
                                        tempRollingFriction = newValue.toFixed(2);
                                    } else if (model.name === "Kicker Friction") {
                                        tempKickerFriction = newValue.toFixed(2);
                                    }
                                } else {
                                    text = slider.value.toString()
                                }
                            }
                        }
                    }
                }
            }
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
