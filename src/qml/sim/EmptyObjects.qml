import QtQuick
import QtQuick3D

Node {
    Repeater3D {
        id: bBotsEmpty
        model: blue.num
        Model {
            source: "../../../assets/models/bot/Rione/viz/meshes/visualize.mesh"
            pickable: true
            objectName: "tb"+String(index)
            eulerRotation: Qt.vector3d(0, 0, 0)
        }
    }
    Repeater3D {
        id: yBotsEmpty
        model: yellow.num
        Model {
            source: "../../../assets/models/bot/Rione/viz/meshes/visualize.mesh"
            pickable: true
            objectName: "ty"+String(index)
            eulerRotation: Qt.vector3d(-90, 0, 0)
        }
    }
    Model {
        id: emptyBall
        source: "../../../assets/models/ball/meshes/ball.mesh"
    }
    
    function syncEmptyObjects() {
        for (var i = 0; i < blue.num; i++) {
            bBotsEmpty.children[i].position = blue.poses[i];
        }
        for (var j = 0; j < yellow.num; j++) {
            yBotsEmpty.children[j].position = yellow.poses[j];
        }
        let radians = [0, Math.PI/2, Math.PI, 3*Math.PI/2];
        for (var k = 0; k < 5; k++) {
            if (k == 4) {
                emptyBall.position = Qt.vector3d(ballPosition.x, ballPosition.y, ballPosition.z);
            } else {
                emptyBall.position = Qt.vector3d(ballPosition.x + (10*Math.cos(radians[k])), ballPosition.y, ballPosition.z + (10*Math.sin(radians[k])));
            }
            let results = [];
            if (emptyNum == 1) {
                let ball2D = camera.projectToScreen(
                    Qt.vector3d(emptyBall.position.x, emptyBall.position.y, emptyBall.position.z), ceilingCamera1.position, ceilingCamera1.forward, ceilingCamera1.up, window.width, window.height, ceilingCamera1.fieldOfView, 1.0, 20000
                );
                if (ball2D.x == -1 && ball2D.y == -1) {
                    break;
                }
                results = viewport1.pickAll(ball2D.x, ball2D.y);
            } else {
                let ball2D = camera.projectToScreen(
                    Qt.vector3d(emptyBall.position.x, emptyBall.position.y, emptyBall.position.z), ceilingCamera2.position, ceilingCamera2.forward, ceilingCamera2.up, window.width, window.height, ceilingCamera2.fieldOfView, 1.0, 20000
                );
                if (ball2D.x == -1 && ball2D.y == -1) {
                    break;
                }
                results = viewport2.pickAll(ball2D.x, ball2D.y);
            }
            for (let n = 0; n < results.length; n++) {
                console.log(results[n].objectHit.objectName);
            }
            
            if (results.length < 1) {
                isFoundBall = true;
                break;
            }
        }
        // console.log(emptyNum);
        console.log("---");
    }
}