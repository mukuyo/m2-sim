cmake_minimum_required(VERSION 3.16)
project(m2-Sim)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

if(CMAKE_SYSTEM_NAME STREQUAL "Darwin")
    if(CMAKE_SYSTEM_PROCESSOR STREQUAL "arm64")
        # Apple Silicon (Homebrew)
        set(Protobuf_INCLUDE_DIR "/opt/homebrew/opt/protobuf@21/include")
        set(Protobuf_LIBRARIES "/opt/homebrew/opt/protobuf@21/lib/libprotobuf.dylib")
        set(CMAKE_PREFIX_PATH "/opt/homebrew/opt/boost@1.85" ${CMAKE_PREFIX_PATH})
        include_directories("/opt/homebrew/opt/protobuf@21/include")
    else()
        # Intel Mac
        set(Protobuf_INCLUDE_DIR "/usr/local/Cellar/protobuf@21/21.12_1/include")
        set(Protobuf_LIBRARIES "/usr/local/Cellar/protobuf@21/21.12_1/lib/libprotobuf.dylib")
        set(CMAKE_PREFIX_PATH "/usr/local/opt/boost@1.85/" ${CMAKE_PREFIX_PATH})
        include_directories("/usr/local/Cellar/protobuf@21/21.12_1/include")
    endif()
elseif(CMAKE_SYSTEM_NAME STREQUAL "Linux")
    # Linux-specific settings can be added here
else()
    message(FATAL_ERROR "Unsupported platform")
endif()

find_package(Qt6 REQUIRED COMPONENTS
    Core Gui Widgets
    3DCore 3DExtras 3DRender
    Quick Quick3D Quick3DPhysics Qml
)

find_package(Boost REQUIRED)

# Protobuf
set(protobuf_MODULE_COMPATIBLE TRUE)
find_package(Protobuf 3.21.12 REQUIRED)

set(SRC_DIR        ${CMAKE_SOURCE_DIR}/src)
set(MODEL_DIR      ${SRC_DIR}/models)
set(NET_DIR        ${SRC_DIR}/networks)
set(UTIL_DIR       ${SRC_DIR}/utils)

set(PROTO_DIR      ${CMAKE_SOURCE_DIR}/proto)
set(PROTO_SRC_DIR  ${PROTO_DIR}/pb_src)
set(PROTO_GEN_DIR  ${PROTO_DIR}/pb_gen)

file(MAKE_DIRECTORY ${PROTO_GEN_DIR})

file(GLOB SRC_FILES
    ${SRC_DIR}/*.cpp
    ${MODEL_DIR}/*.cpp
    ${NET_DIR}/*.cpp
    ${UTIL_DIR}/*.cpp
)

file(GLOB HEADER_FILES
    ${SRC_DIR}/*.h
    ${MODEL_DIR}/*.h
    ${NET_DIR}/*.h
    ${UTIL_DIR}/*.h
)

file(GLOB PROTO_FILES "${PROTO_SRC_DIR}/*.proto")

protobuf_generate_cpp(
    PROTO_SRCS
    PROTO_HDRS
    ${PROTO_FILES}
    IMPORT_DIRS ${PROTO_SRC_DIR}
    PROTOC_OUT_DIR ${PROTO_GEN_DIR}
)

add_executable(m2-Sim
    main.cpp
    ${SRC_FILES}
    ${HEADER_FILES}
    ${PROTO_SRCS}
)

target_include_directories(m2-Sim PRIVATE
    ${SRC_DIR}
    ${PROTO_GEN_DIR}
    ${Boost_INCLUDE_DIRS}
    ${Protobuf_INCLUDE_DIRS}
    ${PROTOBUF_ROOT}/include
)

target_link_libraries(m2-Sim PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Widgets
    Qt6::3DCore
    Qt6::3DExtras
    Qt6::3DRender
    Qt6::Quick
    Qt6::Quick3D
    Qt6::Quick3DPhysics
    Qt6::Qml
    ${Protobuf_LIBRARIES}
    pthread
)

set_target_properties(m2-Sim PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin
)

# Custom target to run the application
add_custom_target(run
    COMMAND ${CMAKE_BINARY_DIR}/bin/m2-Sim
    DEPENDS m2-Sim
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)

# Copy QML files next to the executable
add_custom_command(TARGET m2-Sim POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_directory
    ${CMAKE_SOURCE_DIR}/src/qml
    $<TARGET_FILE_DIR:m2-Sim>/qml
)

install(TARGETS m2-Sim
    RUNTIME DESTINATION bin
)

install(DIRECTORY ${SRC_DIR}/
    DESTINATION include/m2-sim
    FILES_MATCHING PATTERN "*.h"
)