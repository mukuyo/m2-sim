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

QtObject {
    property real num: 0
    property bool lightRobotMode: false
    property real colorHeight: 0
    property string teamColor: "b"

    property var velNormals: new Array(16).fill(0.0)
    property var velTangents: new Array(16).fill(0.0)
    property var velAngulars: new Array(16).fill(0.0)

    property var prePoses: new Array(16).fill(Qt.vector4d(0, 0, 0, 0))
    property var poses: new Array(16).fill(Qt.vector4d(0, 0, 0, 0))

    property var velocities: new Array(16).fill(Qt.vector4d(0, 0, 0, 0))
    property var preVelocities: new Array(16).fill(Qt.vector4d(0, 0, 0, 0))

    property var kickspeeds: new Array(16).fill(Qt.vector3d(0, 0, 0))
    property var spinners: new Array(16).fill(0.0)
    property var holds: new Array(16).fill(false)
    property var spinHolds: new Array(16).fill(false)

    property var distanceBall: new Array(16).fill(0.0)
    property var radianBall: new Array(16).fill(0.0)

    property var cameraExists: new Array(16).fill(false)
    property var cameras: []
    property var position2Ds: new Array(16).fill(Qt.vector2d(0, 0))
    property var idTexts: new Array(16).fill(null)
}