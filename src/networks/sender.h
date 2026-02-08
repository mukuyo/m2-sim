#ifndef SENDER_H
#define SENDER_H

#include <QObject>
#include <iostream>
#include <thread>
#include <chrono>
#include <boost/property_tree/ptree.hpp>
#include <boost/property_tree/ini_parser.hpp>
#include <boost/optional.hpp>
#include <boost/asio.hpp>
#include <boost/array.hpp>
#include <QVector3D>
#include <QList>
#include <QDebug>
#include <QTimer>
#include "ssl_vision_wrapper.pb.h"
#include "ssl_simulation_robot_feedback.pb.h"

using namespace std;

class Sender : public QObject{
    Q_OBJECT
public:
    explicit Sender(const string address, quint16 port, QObject *parent = nullptr);
    ~Sender();
    void send(int camera_id, QVector3D ball_position, QList<QVector3D> blue_positions, QList<QVector3D> yellow_positions);
    void setPort(string address, quint16 newPort);
    void setDetectionInfo(SSL_DetectionFrame &detection, int camera_num, QVector3D ball_position, QList<QVector3D> blue_positions, QList<QVector3D> yellow_positions);
    SSL_GeometryData setGeometryInfo();

private:
    boost::asio::io_context ioContext_;
    boost::asio::ip::udp::socket socket_;
    boost::asio::ip::udp::endpoint endpoint_;

    int captureCount;
    int geometryCount;
    double t_capture;
    double start_time;
    double loop_time;

    quint16 port;
    string address;
};

#endif // SENDER_H
