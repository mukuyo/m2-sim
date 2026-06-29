# 合成エンコーダ feedback ＋ 作動遅延モデル

RAVEN(ssl-RAVEN) のエンコーダ融合EKF / OC / システム同定を sim で検証するために追加した機能。RAVEN 側の手順は RAVEN リポジトリ `docs/sim-validation-ekf-oc.md`。

## 何をするか
1. **合成ホイールエンコーダ feedback**: 各ロボットの物理(Bullet)真値pose を差分して body twist [vx,vy,ω] を得て、逆オムニキネマ `v_i = sinα_i·vx − cosα_i·vy − R·ω` で4輪速度[m/s]に変換、ノイズ/バイアス/量子化を注入し、**`PiToMw` として 224.5.69.4:16941 にマルチキャスト**送出する（ヘッダ `(robotId<<4)|0x05`）。RAVEN の `RobotClient` がこれを受信する（SSL-sim の RobotControlResponse では RAVEN に届かないため）。
2. **作動遅延モデル**: 受信した body 速度指令に **一次遅れ τ ＋ トランスポートむだ時間** を per-axis で付与してから物理に渡す（OC に現実的なプラントを与える）。
3. **オンボードカメラ＋センサ feedback（RACOON-Pi 相当）**: 各ロボットに載った `PerspectiveCamera` にボールを投影し、`PiToMw.Ball_Status` の `ball_camera_x/y` と `is_ball_exit` を埋める。座標は RACOON-Pi の `camera/transport/encoder.py` と同じ **中心原点・x右/y上のピクセル**（`x = px − W/2`, `y = H/2 − py`）。視野外のときは `is_ball_exit=false` とし、座標は RACOON-Pi の欠損センチネル **9999** に落とす。さらにキッカー photo センサ／ドリブラーセンサ（`is_detect_photo_sensor` / `is_detect_dribbler_sensor`）を、sim の「ボール保持(holds)」状態から立てる。これにより RAVEN 側のボール探索・保持判定が sim で動く。

## 実装
- `src/networks/feedbackSender.{h,cpp}` … PiToMw マルチキャスト送出。`RobotFeedback` 構造体で車輪速度・カメラ座標・センサ・電圧をまとめて受け取る。
- `src/observer.cpp::emitEncoderFeedback` … pose差分→body twist→逆キネ→ノイズ→送出。加えてチーム別のカメラ存在/ピクセル/保持状態を受け取り、ピクセル→中心原点変換・9999センチネル・センサ反映を行う。`updateObjects` から毎フレーム。
- `src/models/camera.cpp::getBallPosition` … ロボットカメラへのボール投影（視野内はピクセル座標、外なら `(-1,-1)`）。※従来 `count==0` 判定がコメントアウトされ常に `(-1,-1)` を返していたバグを修正。
- `src/qml/sim/Sync.qml::updateCamera` … 各ロボットの `cameras[i]` の `scenePosition/forward/up` でボールを投影し、`cameraExists[i]` とピクセルを更新（従来コメントアウトで無効化されていたものを有効化）。
- `src/models/robot.cpp::advanceActuation` … 指令→適用速度の遅延/一次遅れ。`Observer::updateSimulator` から毎tick。
- `proto/pb_src/pi_to_mw.proto` … RAVEN から取り込み。
- `test/feedback_wire_test.cpp` … RAVEN の受信手順（ヘッダ除去→`ParseFromArray`）で全フィールドが復元できることを検証する単体テスト。

## 設定（`config/config_v2.ini`）
```ini
[Encoder]
Enabled=true            ; feedback送出ON
Team=blue               ; RAVENが操作する側
FeedbackAddress=224.5.69.4
FeedbackPort=16941
WheelRadiusMm=26.0
RobotRadiusMm=90.0
WheelAngleFlDeg=60.0    ; RAVEN system_model encoder.* と一致させる
WheelAngleBlDeg=135.0
WheelAngleBrDeg=-135.0
WheelAngleFrDeg=-60.0
NoiseSigmaMps=0.0       ; 0=理想エンコーダ。NIS/R同定テスト時に注入
BiasMps=0.0
QuantizationMps=0.0

[Actuation]
TauLinearSec=0.0        ; 0=passthrough（既存挙動不変）
TauAngularSec=0.0
DeadTimeLinearSec=0.0
DeadTimeAngularSec=0.0

[Camera]
OnboardFrameWidth=640   ; オンボードカメラ解像度。RACOON-Pi の撮像と合わせる
OnboardFrameHeight=480  ; ball_camera_x/y はこの中心原点ピクセルで送出
```

既定（全0 + Encoder.Enabled以外）は理想エンコーダ＋遅延なしで、従来挙動と一致。`blueRobotCount` は RAVEN が駆動するIDが spawn する程度に確保すること（11 推奨）。
