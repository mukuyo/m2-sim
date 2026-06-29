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
 */
class FeedbackSender {
public:
    FeedbackSender(const std::string &address, unsigned short port);
    ~FeedbackSender();

    /** Wheel peripheral speeds in m/s (FL, BL, BR, FR), matching firmware units. */
    void sendRobotFeedback(int robotId, float flMps, float blMps, float brMps, float frMps);

private:
    boost::asio::io_context ioContext_;
    boost::asio::ip::udp::socket socket_;
    boost::asio::ip::udp::endpoint endpoint_;
};

#endif // FEEDBACK_SENDER_H
