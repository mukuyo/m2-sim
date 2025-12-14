import QtQuick
import QtQuick3D
import QtQuick.Shapes
import QtQuick.Controls

Item {
    id: view
    property int viewWindowWidth: 1100
    property int viewWindowHeight: 800

    width: viewWindowWidth
    height: viewWindowHeight

    property real opacityValue: 0.8
    property int dispX: windowWidth / 2 - (viewWindowWidth / 8)
    property int dispY: windowHeight - 240
    property int dispWidth: viewWindowWidth / 4
    property int dispHeight: dispWidth / 4.0 * 3.0

    property var cornerRects: [
        { x: 0, y: 0, w: 2, h: 16 },
        { x: 0, y: 0, w: 16, h: 2 },
        { x: 0, y: dispHeight - 16, w: 2, h: 16 },
        { x: 0, y: dispHeight - 2, w: 16, h: 2 },
        { x: dispWidth - 16, y: 0, w: 16, h: 2 },
        { x: dispWidth - 2, y: 0, w: 2, h: 16 },
        { x: dispWidth - 16, y: dispHeight - 2, w: 16, h: 2 },
        { x: dispWidth - 2, y: dispHeight - 16, w: 2, h: 16 }
    ]

    Rectangle {
        x: dispX
        y: dispY
        width: dispWidth
        height: dispHeight
        color: "black"
        opacity: 0.2
    }

    Repeater {
        model: cornerRects
        Rectangle {
            x: dispX + modelData.x
            y: dispY + modelData.y
            width: modelData.w
            height: modelData.h
            color: "transparent"
            border.color: "white"
            border.width: 2
            opacity: opacityValue
        }
    }
    VField {
        id: vfield
    }
    VObject {
        id: vobject
    }
}