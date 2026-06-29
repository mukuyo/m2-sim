#include "feedbackSender.h"

#include <iostream>

#include "pi_to_mw.pb.h"

namespace {
// Lower nibble of the header byte. Mirrors RobotClient's command IDs.
constexpr unsigned char DATA_ROBOT = 0x05;
}  // namespace

FeedbackSender::FeedbackSender(const std::string &address, unsigned short port)
    : ioContext_(),
      socket_(ioContext_),
      endpoint_(boost::asio::ip::make_address(address), port) {
    socket_.open(boost::asio::ip::udp::v4());
    // Same host runs RAVEN; multicast loopback must stay on so it receives.
    boost::system::error_code ec;
    socket_.set_option(boost::asio::ip::multicast::enable_loopback(true), ec);
    if (ec) {
        std::cerr << "[FeedbackSender] enable_loopback failed: " << ec.message() << std::endl;
    }
}

FeedbackSender::~FeedbackSender() {
    boost::system::error_code ec;
    socket_.close(ec);
}

void FeedbackSender::sendRobotFeedback(int robotId, float flMps, float blMps,
                                       float brMps, float frMps) {
    PiToMw msg;
    Robot_Status *rs = msg.mutable_robots_status();
    rs->set_robot_id(robotId);
    rs->set_is_detect_photo_sensor(false);
    rs->set_is_detect_dribbler_sensor(false);
    rs->set_is_new_dribbler(false);
    rs->set_battery_voltage(160);  // 16.0 V, firmware sends ×10
    rs->set_cap_power(0);
    rs->set_fl_wheel_speed(flMps);
    rs->set_bl_wheel_speed(blMps);
    rs->set_br_wheel_speed(brMps);
    rs->set_fr_wheel_speed(frMps);

    Ball_Status *bs = msg.mutable_ball_status();
    bs->set_is_ball_exit(false);
    bs->set_ball_camera_x(0.0f);
    bs->set_ball_camera_y(0.0f);

    Ball *ball = msg.mutable_ball();
    ball->set_min_threshold("");
    ball->set_max_threshold("");
    ball->set_ball_detect_radius(0);
    ball->set_circularity_threshold(0.0f);

    msg.set_is_new_robot(true);

    std::string payload;
    if (!msg.SerializeToString(&payload)) {
        std::cerr << "[FeedbackSender] serialize failed for robot " << robotId << std::endl;
        return;
    }

    std::string datagram;
    datagram.reserve(payload.size() + 1);
    datagram.push_back(static_cast<char>(((robotId & 0x0F) << 4) | DATA_ROBOT));
    datagram.append(payload);

    boost::system::error_code ec;
    socket_.send_to(boost::asio::buffer(datagram), endpoint_, 0, ec);
    if (ec) {
        std::cerr << "[FeedbackSender] send failed: " << ec.message() << std::endl;
    }
}
