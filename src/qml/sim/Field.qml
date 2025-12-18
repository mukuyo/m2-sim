import QtQuick
import QtQuick3D
import QtQuick3D.Physics

import "../../../assets/models/stadium/"
import "../../../assets/models/circle/line/"

Node {
    id: rootEntity
    property int leftGoalCount: 0
    property int rightGoalCount: 0

    Stadium {
        id: stadium
        scale: Qt.vector3d(10, 10, 10)
        visible: !observer.lightStadiumMode
    }
    PhysicsMaterial {
        id: fieldMaterial
        staticFriction: 0.0
        dynamicFriction: 0.0
        restitution: 0.0
    }
    StaticRigidBody {
        id: field
        eulerRotation: Qt.vector3d(-90, 0, 0)
        physicsMaterial: fieldMaterial
        collisionShapes: PlaneShape {}
        Model {
            source: "#Rectangle"
            objectName: "field"
            pickable: true
            scale: Qt.vector3d(154, 124, 0.1)
            opacity: observer.lightFieldMode
            materials: [ 
                DefaultMaterial {
                    diffuseMap: Texture {
                        source: "../../../assets/textures/field_texture.jpg"
                    }
                }
            ]
        }
    }

    Model {
        id: topWall
        pickable: true
        source: "#Cube"
        scale: Qt.vector3d(126.2, 3, 0.2)
        position: Qt.vector3d(0, 50, -4810)
        materials: [
            DefaultMaterial {
                diffuseColor: "black"
            }
        ]
    }
    StaticRigidBody {
        id: topWallSecret
        objectName: "topWallSecret"
        sendContactReports: true
        position: Qt.vector3d(0, 50, -5310)
        scale: Qt.vector3d(126.2, 3, 10)
        physicsMaterial: physicsMaterial
        collisionShapes: BoxShape {}
    }

    Model {
        id: bottomWall
        source: "#Cube"
        scale: Qt.vector3d(126.2, 3, 0.2)
        position: Qt.vector3d(0, 50, 4810)
        eulerRotation: Qt.vector3d(0, 180, 0)
        materials: [
            DefaultMaterial {
                diffuseColor: "black"
            }
        ]
    }
    StaticRigidBody {
        id: bottomWallSecret
        position: Qt.vector3d(0, 50, 5310)
        scale: Qt.vector3d(126.2, 3, 10)
        physicsMaterial: physicsMaterial
        collisionShapes: BoxShape {}
    }
    
    Model {
        id: leftWall
        source: "#Cube"
        scale: Qt.vector3d(96.2, 3, 0.2)
        position: Qt.vector3d(-6310, 50, 0)
        eulerRotation: Qt.vector3d(0, 90, 0)
        materials: [
            DefaultMaterial {
                diffuseColor: "black"
            }
        ]
    }
    StaticRigidBody {
        id: leftWallSecret
        position: Qt.vector3d(-6810, 50, 0)
        scale: Qt.vector3d(96.2, 3, 10)
        eulerRotation: Qt.vector3d(0, 90, 0)
        physicsMaterial: physicsMaterial
        collisionShapes: BoxShape {}
    }

    Model {
        id: rightWall
        source: "#Cube"
        scale: Qt.vector3d(96.2, 3, 0.2)
        position: Qt.vector3d(6310, 50, 0)
        eulerRotation: Qt.vector3d(0, -90, 0)
        materials: [
            DefaultMaterial {
                diffuseColor: "black"
            }
        ]
    }
    StaticRigidBody {
        id: rightWallSecret
        position: Qt.vector3d(6810, 50, 0)
        scale: Qt.vector3d(96.2, 3, 10)
        eulerRotation: Qt.vector3d(0, -90, 0)
        physicsMaterial: physicsMaterial
        collisionShapes: BoxShape {}
    }

    Model {
        id: rightGoal
        source: "#Cube"
        scale: Qt.vector3d(18.4, 3, 0.2)
        position: Qt.vector3d(6180, 50, 0)
        eulerRotation: Qt.vector3d(0, -90, 0)
        materials: [
            DefaultMaterial {
                diffuseColor: "black"
            }
        ]
    }
    StaticRigidBody {
        id: rightGoalSecret
        objectName: "rightGoalSecret"
        receiveContactReports: true
        position: Qt.vector3d(6480, 50, 0)
        scale: Qt.vector3d(18.4, 3, 6.2)
        eulerRotation: Qt.vector3d(0, -90, 0)
        physicsMaterial: physicsMaterial
        collisionShapes: BoxShape {}
        
        onBodyContact: (body, positions, impulses, normals) => {
            if (body.objectName == "ball") {
                goalHitMarker.visible = true;
                goalHitMarker.position = Qt.vector3d(6165, positions[0].y, positions[0].z);
                goalHitMarker.eulerRotation = Qt.vector3d(0, -90, 0);
                rightGoalTimer.start();
            }
        }
    }

    StaticRigidBody {
        id: rightGoalTop
        objectName: "rightGoalTop"
        receiveContactReports: true
        position: Qt.vector3d(6090, 50, -910)
        scale: Qt.vector3d(1.8, 3, 0.2)
        physicsMaterial: physicsMaterial
        collisionShapes: BoxShape {}
        Model {
            id: rightGoalTopModel
            source: "#Cube"
            materials: [
                DefaultMaterial {
                    diffuseColor: "black"
                }
            ]
        }
        onBodyContact: (body, positions, impulses, normals) => {
            if (body.objectName == "ball") {
                goalHitMarker.visible = true;
                goalHitMarker.position = Qt.vector3d(positions[0].x, positions[0].y, -895);
                goalHitMarker.eulerRotation = Qt.vector3d(0, 0, 0);
                rightGoalTimer.start();
            }
        }
    }

    StaticRigidBody {
        id: rightGoalBottom
        objectName: "rightGoalBottom"
        receiveContactReports: true
        position: Qt.vector3d(6090, 50, 910)
        scale: Qt.vector3d(1.8, 3, 0.2)
        physicsMaterial: physicsMaterial
        collisionShapes: BoxShape {}
        Model {
            id: rightGoalBottomModel
            source: "#Cube"
            materials: [
                DefaultMaterial {
                    diffuseColor: "black"
                }
            ]
        }
        onBodyContact: (body, positions, impulses, normals) => {
            if (body.objectName == "ball") {
                goalHitMarker.visible = true;
                goalHitMarker.position = Qt.vector3d(positions[0].x, positions[0].y, 895);
                goalHitMarker.eulerRotation = Qt.vector3d(0, 180, 0);
                rightGoalTimer.start();
            }
        }
    }

    Model {
        id: leftGoal
        source: "#Cube"
        scale: Qt.vector3d(18.4, 3, 0.2)
        position: Qt.vector3d(-6180, 50, 0)
        eulerRotation: Qt.vector3d(0, 90, 0)
        materials: [
            DefaultMaterial {
                diffuseColor: "black"
            }
        ]
    }
    StaticRigidBody {
        id: leftGoalSecret
        objectName: "leftGoalSecret"
        receiveContactReports: true
        position: Qt.vector3d(-6480, 50, 0)
        scale: Qt.vector3d(18.4, 3, 6.2)
        eulerRotation: Qt.vector3d(0, 90, 0)
        physicsMaterial: physicsMaterial
        collisionShapes: BoxShape {}
        onBodyContact: (body, positions, impulses, normals) => {
            if (body.objectName == "ball") {
                goalHitMarker.visible = true;
                goalHitMarker.position = Qt.vector3d(-6165, positions[0].y, positions[0].z);
                goalHitMarker.eulerRotation = Qt.vector3d(0, 90, 0);
                leftGoalTimer.start();
            }
        }
    }

    StaticRigidBody {
        id: leftGoalTop
        objectName: "leftGoalTop"
        receiveContactReports: true
        position: Qt.vector3d(-6090, 50, -910)
        scale: Qt.vector3d(1.8, 3, 0.2)
        physicsMaterial: physicsMaterial
        collisionShapes: BoxShape {}
        Model {
            id: leftGoalTopModel
            source: "#Cube"
            materials: [
                DefaultMaterial {
                    diffuseColor: "black"
                }
            ]
        }
        onBodyContact: (body, positions, impulses, normals) => {
            if (body.objectName == "ball") {
                goalHitMarker.visible = true;
                goalHitMarker.position = Qt.vector3d(positions[0].x, positions[0].y, -895);
                goalHitMarker.eulerRotation = Qt.vector3d(0, 0, 0);
                leftGoalTimer.start();
            }
        }
    }

    StaticRigidBody {
        id: leftGoalBottom
        objectName: "leftGoalBottom"
        receiveContactReports: true
        position: Qt.vector3d(-6090, 50, 910)
        scale: Qt.vector3d(1.8, 3, 0.2)
        physicsMaterial: physicsMaterial
        collisionShapes: BoxShape {}
        Model {
            id: leftGoalBottomModel
            source: "#Cube"
            materials: [
                DefaultMaterial {
                    diffuseColor: "black"
                }
            ]
        }
        onBodyContact: (body, positions, impulses, normals) => {
            if (body.objectName == "ball") {
                goalHitMarker.visible = true;
                goalHitMarker.position = Qt.vector3d(positions[0].x, positions[0].y, 895);
                goalHitMarker.eulerRotation = Qt.vector3d(0, 180, 0);
                leftGoalTimer.start();
            }
        }
    }

    Model {
        id: centerLine
        source: "#Rectangle"
        scale: Qt.vector3d(0.1, 90, 1)
        position: Qt.vector3d(0, 3, 0)
        eulerRotation: Qt.vector3d(-90, 0, 0)
        materials: [
            DefaultMaterial {
                diffuseColor: "white"
            }
        ]
    }

    Model {
        id: horizontalLine
        source: "#Rectangle"
        scale: Qt.vector3d(120, 0.1, 1)
        position: Qt.vector3d(0, 3, 0)
        eulerRotation: Qt.vector3d(-90, 0, 0)
        materials: [
            DefaultMaterial {
                diffuseColor: "white"
            }
        ]
    }

    Model {
        id: topEdge
        source: "#Rectangle"
        scale: Qt.vector3d(120, 0.1, 1)
        position: Qt.vector3d(0, 3, -4495)
        eulerRotation: Qt.vector3d(-90, 0, 0)
        materials: [
            DefaultMaterial {
                diffuseColor: "white"
            }
        ]
    }

    Model {
        id: bottomEdge
        source: "#Rectangle"
        scale: Qt.vector3d(120, 0.1, 1)
        position: Qt.vector3d(0, 3, 4495)
        eulerRotation: Qt.vector3d(-90, 0, 0)
        materials: [
            DefaultMaterial {
                diffuseColor: "white"
            }
        ]
    }

    Model {
        id: leftEdge
        source: "#Rectangle"
        scale: Qt.vector3d(0.1, 90, 1)
        position: Qt.vector3d(-5995, 3, 0)
        eulerRotation: Qt.vector3d(-90, 0, 0)
        materials: [
            DefaultMaterial {
                diffuseColor: "white"
            }
        ]
    }

    Model {
        id: rightEdge
        source: "#Rectangle"
        scale: Qt.vector3d(0.1, 90, 1)
        position: Qt.vector3d(5995, 3, 0)
        eulerRotation: Qt.vector3d(-90, 0, 0)
        materials: [
            DefaultMaterial {
                diffuseColor: "white"
            }
        ]
    }

    Model {
        id: leftPenaltyTop
        source: "#Rectangle"
        scale: Qt.vector3d(18, 0.1, 1)
        position: Qt.vector3d(-5095, 3, -1800)
        eulerRotation: Qt.vector3d(-90, 0, 0)
        materials: [
            DefaultMaterial {
                diffuseColor: "white"
            }
        ]
    }

    Model {
        id: rightPenaltyTop
        source: "#Rectangle"
        scale: Qt.vector3d(18, 0.1, 1)
        position: Qt.vector3d(5095, 3, -1800)
        eulerRotation: Qt.vector3d(-90, 0, 0)
        materials: [
            DefaultMaterial {
                diffuseColor: "white"
            }
        ]
    }

    Model {
        id: leftPenaltyBottom
        source: "#Rectangle"
        scale: Qt.vector3d(18, 0.1, 1)
        position: Qt.vector3d(-5095, 3, 1800)
        eulerRotation: Qt.vector3d(-90, 0, 0)
        materials: [
            DefaultMaterial {
                diffuseColor: "white"
            }
        ]
    }

    Model {
        id: rightPenaltyBottom
        source: "#Rectangle"
        scale: Qt.vector3d(18, 0.1, 1)
        position: Qt.vector3d(5095, 3, 1800)
        eulerRotation: Qt.vector3d(-90, 0, 0)
        materials: [
            DefaultMaterial {
                diffuseColor: "white"
            }
        ]
    }

    Model {
        id: leftPenaltyVertical
        source: "#Rectangle"
        scale: Qt.vector3d(0.1, 36, 1)
        position: Qt.vector3d(-4200, 3, 0)
        eulerRotation: Qt.vector3d(-90, 0, 0)
        materials: [
            DefaultMaterial {
                diffuseColor: "white"
            }
        ]
    }

    Model {
        id: rightPenaltyVertical
        source: "#Rectangle"
        scale: Qt.vector3d(0.1, 36, 1)
        position: Qt.vector3d(4200, 3, 0)
        eulerRotation: Qt.vector3d(-90, 0, 0)
        materials: [
            DefaultMaterial {
                diffuseColor: "white"
            }
        ]
    }
    LineCircle {
        position: Qt.vector3d(0, 4, 0)
        eulerRotation: Qt.vector3d(90, 0, 0)
    }
    Model {
        id: ballCollisionMarker
        source: "#Cylinder"
        scale: Qt.vector3d(0.4, 0.05, 0.4)
        eulerRotation: Qt.vector3d(-90, -90, 0)
        position: Qt.vector3d(0, 10000, 0)
        opacity: 1.0
        materials: [
            DefaultMaterial {
                diffuseColor: "#ED752F"
            }
        ]
    }
    Timer {
        id: leftGoalTimer
        interval: 10
        repeat: true
        running: false
        onTriggered: {
            let color = 1.0;
            leftGoal.materials[0].diffuseColor = Qt.rgba(color, 0, 0, 1);
            leftGoalTopModel.materials[0].diffuseColor = Qt.rgba(color, 0, 0, 1);
            leftGoalBottomModel.materials[0].diffuseColor = Qt.rgba(color, 0, 0, 1);
            leftGoalCount++;
            if (leftGoalCount >= 40) {
                leftGoal.materials[0].diffuseColor = "black";
                leftGoalTopModel.materials[0].diffuseColor = "black";
                leftGoalBottomModel.materials[0].diffuseColor = "black";
                leftGoalTimer.stop();
                leftGoalCount = 0;
            }
        }
    }
    Timer {
        id: rightGoalTimer
        interval: 10
        repeat: true
        running: false
        onTriggered: {
            let color = 1.0;
            rightGoal.materials[0].diffuseColor = Qt.rgba(color, 0, 0, 1);
            rightGoalTopModel.materials[0].diffuseColor = Qt.rgba(color, 0, 0, 1);
            rightGoalBottomModel.materials[0].diffuseColor = Qt.rgba(color, 0, 0, 1);
            rightGoalCount++;
            if (rightGoalCount >= 40) {
                rightGoal.materials[0].diffuseColor = "black";
                rightGoalTopModel.materials[0].diffuseColor = "black";
                rightGoalBottomModel.materials[0].diffuseColor = "black";
                rightGoalTimer.stop();
                rightGoalCount = 0;
            }
        }
    }
    Model {
        id: goalHitMarker
        visible: false
        position: Qt.vector3d(0, 0, 0)
        eulerRotation: Qt.vector3d(-90, 90, 0)
        scale: Qt.vector3d(0.8, 0.8, 0.8)   // サイズ調整

        source: "#Rectangle"  // 平面

        materials: DefaultMaterial {
            diffuseMap: Texture {
                source: "../../../docs/images/ball_collision.png"   // ← 貼りたい画像
            }
            lighting: DefaultMaterial.NoLighting
            opacity: 0.9
        }
    }
}
