// Standalone check of the RACOON-Pi feedback wire contract that RAVEN relies on.
// Sends one PiToMw datagram through the real FeedbackSender on a loopback
// multicast group, then decodes it exactly the way RAVEN's RobotClient does
// (strip the 1-byte header, ParseFromArray) and asserts every field RACOON-Pi
// would have populated round-trips correctly.
#include <boost/asio.hpp>
#include <cassert>
#include <cmath>
#include <iostream>

#include "networks/feedbackSender.h"
#include "pi_to_mw.pb.h"

namespace {
constexpr char kGroup[] = "239.10.20.30";  // private test group, not the real one
constexpr unsigned short kPort = 17777;
constexpr unsigned char DATA_ROBOT = 0x05;

bool approx(float a, float b) { return std::fabs(a - b) < 1e-3f; }
}  // namespace

int main() {
    GOOGLE_PROTOBUF_VERIFY_VERSION;
    using boost::asio::ip::udp;

    boost::asio::io_context io;
    udp::socket rx(io);
    rx.open(udp::v4());
    rx.set_option(udp::socket::reuse_address(true));
    rx.bind(udp::endpoint(boost::asio::ip::address_v4::any(), kPort));
    rx.set_option(boost::asio::ip::multicast::join_group(
        boost::asio::ip::make_address(kGroup).to_v4()));

    FeedbackSender sender(kGroup, kPort);

    const int robotId = 7;
    FeedbackSender::RobotFeedback fb;
    fb.flMps = 1.0f; fb.blMps = -2.0f; fb.brMps = 3.5f; fb.frMps = -0.25f;
    fb.ballExists = true;
    fb.ballCamX = -120.0f;   // center-origin: ball left of image center
    fb.ballCamY = 64.0f;     // and above center
    fb.photoSensor = true;
    fb.dribblerSensor = true;
    fb.batteryDecivolts = 158;
    fb.capPower = 42;
    fb.isNewRobot = true;
    sender.sendRobotFeedback(robotId, fb);

    char buf[2048];
    udp::endpoint from;
    std::size_t len = rx.receive_from(boost::asio::buffer(buf), from);
    assert(len > 1 && "no datagram received");

    // RAVEN parse path: byte[0] = (id<<4)|cmd, byte[1..] = PiToMw.
    const unsigned char header = static_cast<unsigned char>(buf[0]);
    assert((header & 0x0F) == DATA_ROBOT && "wrong command nibble");
    assert((header >> 4) == robotId && "wrong robot id in header");

    PiToMw msg;
    bool ok = msg.ParseFromArray(buf + 1, static_cast<int>(len - 1));
    assert(ok && "PiToMw parse failed");

    const auto &rs = msg.robots_status();
    assert(rs.robot_id() == (uint32_t)robotId);
    assert(approx(rs.fl_wheel_speed(), 1.0f));
    assert(approx(rs.bl_wheel_speed(), -2.0f));
    assert(approx(rs.br_wheel_speed(), 3.5f));
    assert(approx(rs.fr_wheel_speed(), -0.25f));
    assert(rs.is_detect_photo_sensor() == true);
    assert(rs.is_detect_dribbler_sensor() == true);
    assert(rs.battery_voltage() == 158u);
    assert(rs.cap_power() == 42u);

    const auto &bs = msg.ball_status();
    assert(bs.is_ball_exit() == true);          // "exist": ball is in view
    assert(approx(bs.ball_camera_x(), -120.0f));
    assert(approx(bs.ball_camera_y(), 64.0f));
    assert(msg.is_new_robot() == true);

    // Now the no-ball case: coordinates must collapse to the 9999 sentinel.
    FeedbackSender::RobotFeedback empty;
    empty.ballExists = false;
    sender.sendRobotFeedback(3, empty);
    len = rx.receive_from(boost::asio::buffer(buf), from);
    PiToMw msg2;
    assert(msg2.ParseFromArray(buf + 1, static_cast<int>(len - 1)));
    assert(msg2.ball_status().is_ball_exit() == false);
    assert(approx(msg2.ball_status().ball_camera_x(), 9999.0f));
    assert(approx(msg2.ball_status().ball_camera_y(), 9999.0f));
    assert((static_cast<unsigned char>(buf[0]) >> 4) == 3);

    std::cout << "OK: PiToMw wire contract verified "
                 "(header framing, wheels, camera coords, 9999 sentinel, sensors)\n";
    google::protobuf::ShutdownProtobufLibrary();
    return 0;
}
