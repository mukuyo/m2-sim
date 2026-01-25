cmake_minimum_required(VERSION 3.16)
project(m2-Sim LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTORCC OFF)

# ===============================
# Platform settings
# ===============================
if(CMAKE_SYSTEM_NAME STREQUAL "Darwin")
    if(CMAKE_SYSTEM_PROCESSOR STREQUAL "arm64")
        set(Protobuf_INCLUDE_DIR "/opt/homebrew/opt/protobuf@21/include")
        set(Protobuf_LIBRARIES "/opt/homebrew/opt/protobuf@21/lib/libprotobuf.dylib")
        set(CMAKE_PREFIX_PATH "/opt/homebrew/opt/boost@1.85" ${CMAKE_PREFIX_PATH})
    else()
        set(Protobuf_INCLUDE_DIR "/usr/local/Cellar/protobuf@21/21.12_1/include")
        set(Protobuf_LIBRARIES "/usr/local/Cellar/protobuf@21/21.12_1/lib/libprotobuf.dylib")
        set(CMAKE_PREFIX_PATH "/usr/local/opt/boost@1.85/" ${CMAKE_PREFIX_PATH})
    endif()
elseif(CMAKE_SYSTEM_NAME STREQUAL "Linux")
    # Linux settings here
else()
    message(FATAL_ERROR "Unsupported platform")
endif()

# ===============================
# Qt
# ===============================
find_package(Qt6 REQUIRED COMPONENTS
    Core Gui Widgets
    3DCore 3DExtras 3DRender
    Quick Quick3D Quick3DPhysics Qml
)

# ===============================
# Boost / Protobuf
# ===============================
find_package(Boost REQUIRED)

set(protobuf_MODULE_COMPATIBLE TRUE)
find_package(Protobuf 3.21.12 REQUIRED)

# ===============================
# Source layout
# ===============================
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

# ===============================
# Executable
# ===============================
add_executable(m2-Sim
    main.cpp
    ${SRC_FILES}
    ${HEADER_FILES}
    ${PROTO_SRCS}
)

# ===============================
# Include / Link
# ===============================
target_include_directories(m2-Sim PRIVATE
    ${SRC_DIR}
    ${PROTO_GEN_DIR}
    ${Boost_INCLUDE_DIRS}
    ${Protobuf_INCLUDE_DIRS}
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

# ===============================
# Output
# ===============================
set_target_properties(m2-Sim PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin
)

# ===============================
# Run helper
# ===============================
add_custom_target(run
    COMMAND ${CMAKE_BINARY_DIR}/bin/m2-Sim
    DEPENDS m2-Sim
)
