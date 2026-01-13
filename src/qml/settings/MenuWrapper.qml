import QtQuick
import QtQuick3D
import QtQuick.Shapes
import QtQuick.Controls

Item {
    id: menuWrapper
    width: 340
    height: menuHeight
    anchors.top: triangleVisual.bottom
    anchors.left: triangleVisual.left
    anchors.topMargin: 8
    clip: true
    Column {
        width: parent.width
        Repeater {
            model: itemModel
            Item {
                width: parent.width
                height: 55
                Text {
                    x: 5
                    width: 100
                    height: 55
                    text: "・" + model.name
                    color: "white"
                    font.pixelSize: 18
                }
                TextField {
                    x: 230
                    y: 20
                    width: 86
                    visible: model.InitValue === -2
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
                TextField {
                    x: 260
                    y: 20
                    width: 54
                    height: 24
                    visible: !model.slider && !model.toggle && !model.combo && model.InitValue !== -2
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
                        if (!isNaN(newValue) && newValue >= -1) {
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
                Text {
                    text: model.detail
                    x: 22
                    y: 25
                    visible: model.detail !== "" || model.toggle || model.slider || model.combo
                    height: 30
                    color: "white"
                    opacity: 0.7
                    font.pixelSize: 14
                }
                ToggleSwitch {
                    id: toggleSwitch
                    visible: model.toggle
                    x: 288
                    y: 34
                }
                ComboBox {
                    x: 165
                    y: -26
                    model: cameraModel
                    visible: model.name === "Main Camera"
                    onCurrentIndexChanged: {
                        selectedCamera = cameraModel[currentIndex];
                    }
                }
                TextField {
                    id: textField
                    x: 265
                    y: 24
                    width: 40
                    visible: model.slider
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
                            text = observer.gravity.toFixed(2).toString();
                        } else if (model.name === "Ball Static Friction") {
                            text = observer.ballStaticFriction.toFixed(2).toString();
                        } else if (model.name === "Ball Dynamic Friction") {
                            text = observer.ballDynamicFriction.toFixed(2).toString();
                        } else if (model.name === "Ball Restitution") {
                            text = observer.ballRestitution.toFixed(2).toString();
                        } else if (model.name === "Rolling Friction") {
                            text = observer.rollingFriction.toFixed(2).toString();
                        } else if (model.name === "Kicker Friction") {
                            text = observer.kickerFriction.toFixed(2).toString();
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
                Slider {
                    id: slider
                    visible: model.slider
                    width: 230
                    x: 20
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
                                tempGravity = value.toFixed(1);
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
                        }
                    }
                }
            }
        }
    }
}