import QtQuick
import QtQuick3D
import QtQuick3D.Physics

import "../../../assets/models/stadium/"
import "../../../assets/models/circle/line/"

Node {
    id: rootEntity

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
                
                ballCollisionMarker.position = Qt.vector3d(6170, positions[0].y, positions[0].z);
                ballCollisionMarker.eulerRotation = Qt.vector3d(-90, -90, 0) 
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
            source: "#Cube"
            materials: [
                DefaultMaterial {
                    diffuseColor: "black"
                }
            ]
        }
        onBodyContact: (body, positions, impulses, normals) => {
            if (body.objectName == "ball") {
                ballCollisionMarker.position = Qt.vector3d(positions[0].x, positions[0].y, -900);
                ballCollisionMarker.eulerRotation = Qt.vector3d(-90, 0, 0) 
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
            source: "#Cube"
            materials: [
                DefaultMaterial {
                    diffuseColor: "black"
                }
            ]
        }
        onBodyContact: (body, positions, impulses, normals) => {
            if (body.objectName == "ball") {
                ballCollisionMarker.position = Qt.vector3d(positions[0].x, positions[0].y, 900);
                ballCollisionMarker.eulerRotation = Qt.vector3d(-90, 0, 0) 
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
                ballCollisionMarker.position = Qt.vector3d(-6170, positions[0].y, positions[0].z);
                ballCollisionMarker.eulerRotation = Qt.vector3d(-90, 90, 0) 
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
            source: "#Cube"
            materials: [
                DefaultMaterial {
                    diffuseColor: "black"
                }
            ]
        }
        onBodyContact: (body, positions, impulses, normals) => {
            if (body.objectName == "ball") {
                ballCollisionMarker.position = Qt.vector3d(positions[0].x, positions[0].y, -900);
                ballCollisionMarker.eulerRotation = Qt.vector3d(-90, 0, 0) 
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
            source: "#Cube"
            materials: [
                DefaultMaterial {
                    diffuseColor: "black"
                }
            ]
        }
        onBodyContact: (body, positions, impulses, normals) => {
            if (body.objectName == "ball") {
                ballCollisionMarker.position = Qt.vector3d(positions[0].x, positions[0].y, 900);
                ballCollisionMarker.eulerRotation = Qt.vector3d(-90, 0, 0) 
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
}
