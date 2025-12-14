import QtQuick
import QtQuick3D
import QtQuick.Shapes
import QtQuick.Controls

Item {
    id: vobject
    width: viewWindowWidth
    height: viewWindowHeight

    property real ratio: 13400 / dispWidth
    property real ballRadius: 21.5 / ratio * 3.5
    property real botRadius: 180 / ratio
    property real textRatio: ratio / 44.667
    property var fieldCenter: Qt.vector2d(windowWidth / 2, dispY + dispHeight / 2)
    property var bBotPosition2Ds: new Array(16).fill(Qt.vector2d(-1, -1))
    property var yBotPosition2Ds: new Array(16).fill(Qt.vector2d(-1, -1))

    Timer {
        interval: 1000.0 / observer.desiredFps
        running: true
        repeat: true
        onTriggered: {
            update2DPositions();
        }
    }
    Item {
        id: blue2Ds
        Repeater {
            model: blue.num
            Rectangle {
                id: blue2DRect
                x: blue.position2Ds[index].x / ratio + fieldCenter.x - botRadius
                y: bBotPosition2Ds[index].y / ratio + fieldCenter.y - botRadius
                width: botRadius * 2
                height: botRadius * 2
                color: "transparent"
                border.color: "#30A1CE"
                radius: width / 2
                opacity: opacityValue
            }
        }
    }
    Item {
        id: blue2DTexts
        Repeater {
            model: blue.num
            Text {
                x: bBotPosition2Ds[index].x / ratio + fieldCenter.x - botRadius + (2.2 / textRatio)
                y: bBotPosition2Ds[index].y / ratio + fieldCenter.y - botRadius + (0.5 / textRatio)
                text: index
                color: "white"
                font.pixelSize: 6 / textRatio
            }
        }
    }
    Item {
        id: yellow2Ds
        Repeater {
            model: yellow.num
            Rectangle {
                x: yBotPosition2Ds[index].x / ratio + fieldCenter.x - botRadius
                y: yBotPosition2Ds[index].y / ratio + fieldCenter.y - botRadius
                width: botRadius * 2
                height: botRadius * 2
                color: "transparent"
                border.color: "yellow"
                radius: width / 2
                opacity: opacityValue
            }
        }
    }
    Item {
        id: yellow2DTexts
        Repeater {
            model: yellow.num
            Text {
                x: yBotPosition2Ds[index].x / ratio + fieldCenter.x - botRadius + (2.2 / textRatio)
                y: yBotPosition2Ds[index].y / ratio + fieldCenter.y - botRadius + (0.5 / textRatio)
                text: index
                color: "white"
                font.pixelSize: 6 / textRatio
            }
        }
    }
    Rectangle {
        id: vball
        x: ball2DPosition.x / ratio + fieldCenter.x - ballRadius
        y: ball2DPosition.y / ratio + fieldCenter.y - ballRadius
        width: ballRadius * 2
        height: ballRadius * 2
        color: "orange"
        radius: width / 2
        opacity: opacityValue
    }
    Rectangle {
        id: vballMarker
        x: ball2DPosition.x / ratio + fieldCenter.x - ballRadius * 5
        y: ball2DPosition.y / ratio + fieldCenter.y - ballRadius * 5
        width: ballRadius * 10
        height: ballRadius * 10
        color: "transparent"
        border.color: "red"
        radius: width / 2
        opacity: opacityValue
    }
    function update2DPositions() {
        for (let i = 0; i < blue.num; i++) {
            blue2Ds.children[i].x = blue.position2Ds[i].x / ratio + fieldCenter.x - botRadius;
            blue2Ds.children[i].y = blue.position2Ds[i].y / ratio + fieldCenter.y - botRadius;
            blue2DTexts.children[i].x = blue.position2Ds[i].x / ratio + fieldCenter.x - botRadius + (2.2 / textRatio);
            blue2DTexts.children[i].y = blue.position2Ds[i].y / ratio + fieldCenter.y - botRadius + (0.5 / textRatio);
        }
        for (let i = 0; i < yellow.num; i++) {
            yellow2Ds.children[i].x = yellow.position2Ds[i].x / ratio + fieldCenter.x - botRadius;
            yellow2Ds.children[i].y = yellow.position2Ds[i].y / ratio + fieldCenter.y - botRadius;
            yellow2DTexts.children[i].x = yellow.position2Ds[i].x / ratio + fieldCenter.x - botRadius + (2.2 / textRatio);
            yellow2DTexts.children[i].y = yellow.position2Ds[i].y / ratio + fieldCenter.y - botRadius + (0.5 / textRatio);
        }
    }
}