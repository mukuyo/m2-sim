# How to Import Custom Model

## Prepare the Physics 3D Models
You can donwload the example 3D models
[Download 3D Models](https://drive.google.com/drive/folders/17iXSCv_ecgYn4Mx0ziXjV6I9hVO665dg?usp=share_link)

You must prepare the 5 Models like below.
This simulator can not calculate complex body, so you have to simple body.
You save the obj file recommend.

### Main Body
The model is saved name `body`

### Left (Right) Body
The model is saved name `centerLeft` or `centerRight`

### Dribbler
The model is named `dribbler.obj`

### Chip Kick
The model is named `chip.obj`

## Run the balsam
You have to run [Qt balsam](https://doc.qt.io/qt-6/qtquick3d-tool-balsam.html)
```bash
balsam body.obj
```
You can get body.mesh

## Run the cooker
You have to run [Qt cooker](https://doc.qt.io/qt-6/ja/qtquick3dphysics-cooking.html)
```bash
cooker body.mesh
```
You can get `body.cooked.tri` and `body.cooked.cvx`
