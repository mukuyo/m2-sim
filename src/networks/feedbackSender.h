#ifndef FEEDBACK_SENDER_H
#define FEEDBACK_SENDER_H

#include <string>
#include <boost/asio.hpp>

/**
 * Emits synthetic wheel-encoder feedback to RAVEN's RobotClient.
 *
 * RAVEN does not read the SSL-simulation RobotControlResponse for wheel speeds;
 * it ingests them through the ssl-RAVEN-MW link as `PiToMw` datagrams on a
 * multicast group (default 224.5.69.4:16941). Each datagram is one robot:
 *   byte[0] = (robotId << 4) | 0x05   // upper nibble = id, lower nibble = DATA_ROBOT
 *   byte[1..] = serialized PiToMw
 * In simulator mode (is_real=false) RAVEN accepts DATA_ROBOT without the
 * OFFER/OK handshake, so emitting these datagrams is sufficient.
 *
 * Besides the wheel speeds, the datagram also carries the on-robot sensor state
 * RACOON-Pi would report: the onboard-camera ball detection (center-origin pixel
 * coordinates, x right / y up) and the kicker photo / dribbler sensors. This is
 * what lets RAVEN run its ball-search and ball-possession logic against the sim.
 */
class FeedbackSender {
public:
    FeedbackSender(const std::string &address, unsigned short port);
    ~FeedbackSender();

    /**
     * One robot's status, mirroring RACOON-Pi's PiToMw.
     * Wheel speeds are peripheral m/s (FL, BL, BR, FR), matching firmware units.
     * ballExists==true means the ball is in the onboard camera view; ballCamX/Y
     * are then center-origin pixels (x right, y up). When ballExists==false the
     * coordinates are forced to the 9999 "no ball" sentinel RACOON-Pi uses.
     */
    struct RobotFeedback {
        float flMps = 0.0f;
        float blMps = 0.0f;
        float brMps = 0.0f;
        float frMps = 0.0f;
        bool ballExists = false;
        float ballCamX = 0.0f;
        float ballCamY = 0.0f;
        bool photoSensor = false;     // ball in front of the kicker (IR/photo)
        bool dribblerSensor = false;  // ball held at the dribbler
        int batteryDecivolts = 160;   // 16.0 V; firmware sends voltage ×10
        int capPower = 0;
        bool isNewRobot = true;       // Rock5A (true) vs Pi4 (false)
    };

    void sendRobotFeedback(int robotId, const RobotFeedback &fb);

private:
    // RACOON-Pi's NO_BALL_COORD: x/y when the ball is not detected.
    static constexpr float kBallCoordMissing = 9999.0f;


    boost::asio::io_context ioContext_;
    boost::asio::ip::udp::socket socket_;
    boost::asio::ip::udp::endpoint endpoint_;
};

#endif // FEEDBACK_SENDER_H
