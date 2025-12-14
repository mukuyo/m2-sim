import QtQuick
import QtQuick3D

Node {
    id: lightRoot
    property real lightIntensity: 0.5

    DirectionalLight {
        eulerRotation.x: -90
        brightness: 2.0
    }
    DirectionalLight {
        eulerRotation.y: 135
        brightness: lightIntensity
    }
    DirectionalLight {
        eulerRotation.y: -90
        brightness: lightIntensity
    }
    DirectionalLight {
        eulerRotation.x: 0
        brightness: lightIntensity
    }
    DirectionalLight {
        eulerRotation.x: 180
        brightness: lightIntensity
    }
    // DirectionalLight {
    //     eulerRotation.y: -90
    //     brightness: 2.0
    // }
    // DirectionalLight {
    //     eulerRotation.x: -45
    //     brightness: 0.03
    // }
    // DirectionalLight {
    //     eulerRotation.x: -135
    //     brightness: 0.03
    // }
    // DirectionalLight {
    //     eulerRotation.y: 45
    //     brightness: 0.03
    // }
    // DirectionalLight {
    //     eulerRotation.y: -45
    //     brightness: 0.03
    // }
}
