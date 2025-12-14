cmake_minimum_required(VERSION 3.16)
project(Moccer-Sim)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Qt設定
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

# MacのProtobufパス設定
if(CMAKE_SYSTEM_NAME STREQUAL "Darwin")
    if(CMAKE_SYSTEM_PROCESSOR STREQUAL "arm64")
        set(Protobuf_INCLUDE_DIR "/opt/homebrew/opt/protobuf@21/include")
        set(Protobuf_LIBRARIES "/opt/homebrew/opt/protobuf@21/lib/libprotobuf.dylib")
        set(CMAKE_PREFIX_PATH "/opt/homebrew/opt/boost@1.85" ${CMAKE_PREFIX_PATH})
        include_directories("/opt/homebrew/opt/protobuf@21/include")
    else()
        set(Protobuf_INCLUDE_DIR "/usr/local/Cellar/protobuf@21/21.12_1/include")
        set(Protobuf_LIBRARIES "/usr/local/Cellar/protobuf@21/21.12_1/lib/libprotobuf.dylib")
        set(CMAKE_PREFIX_PATH "/usr/local/opt/boost@1.85/" ${CMAKE_PREFIX_PATH})
        include_directories("/usr/local/Cellar/protobuf@21/21.12_1/include")
    endif()
elseif(CMAKE_SYSTEM_NAME STREQUAL "Linux")
    # include_directories("~/Qt/6.10.0/gcc_64/include")
else()
    message(FATAL_ERROR "Unsupported platform")
endif()

find_package(Qt6 REQUIRED COMPONENTS Core Gui Widgets 3DCore 3DExtras 3DRender Quick Quick3D Quick3DPhysics)

find_package(Boost REQUIRED)
include_directories(${Boost_INCLUDE_DIRS})

set(SRC_DIR ${CMAKE_SOURCE_DIR}/src)
set(MODEL_DIR ${SRC_DIR}/models)
set(NET_DIR ${SRC_DIR}/networks)

file(GLOB SOURCES ${SRC_DIR}/*.cpp)
file(GLOB MODEL_SOURCES ${MODEL_DIR}/*.cpp)
file(GLOB NET_SOURCES ${NET_DIR}/*.cpp)
file(GLOB UTIL_SOURCES ${SRC_DIR}/utils/*.cpp)

file(GLOB HEADERS ${SRC_DIR}/*.h)
file(GLOB MODEL_HEADERS ${MODEL_DIR}/*.h)
file(GLOB NET_HEADERS ${NET_DIR}/*.h)
file(GLOB UTIL_HEADERS ${SRC_DIR}/utils/*.h)

# Source files
set(SOURCES
    ${PROTO_SRCS}
    ${SOURCES}
    ${MODEL_SOURCES}
    ${NET_SOURCES}
    ${UTIL_SOURCES}
)

# Ensure moc is run on header files
qt6_wrap_cpp(MOC_SRCS
    ${HEADERS}
    ${MODEL_HEADERS}
    ${NET_HEADERS}
    ${UTIL_HEADERS}
)

# Protobufの設定
set(protobuf_MODULE_COMPATIBLE TRUE)
find_package(Protobuf 3.21.12 REQUIRED)
include_directories(${Protobuf_INCLUDE_DIRS})

# Protobuf用ディレクトリ
set(PROTOBUF_DIR ${CMAKE_SOURCE_DIR}/proto)
set(PROTOBUF_SOURCE_DIR ${PROTOBUF_DIR}/pb_src)
set(PROTOBUF_GENERATE_DIR ${PROTOBUF_DIR}/pb_gen)

file(MAKE_DIRECTORY ${PROTOBUF_GENERATE_DIR})

# Protobufのコンパイル
file(GLOB PROTO_FILES "${PROTOBUF_SOURCE_DIR}/*.proto")
protobuf_generate_cpp(PROTO_SRCS PROTO_HDRS ${PROTO_FILES} IMPORT_DIRS ${PROTOBUF_SOURCE_DIR} PROTOC_OUT_DIR ${PROTOBUF_GENERATE_DIR})

include_directories(${PROTOBUF_GENERATE_DIR})
include_directories(${SRC_DIR})

# mocを適用
qt6_wrap_cpp(MOC_SRCS ${HEADERS})

# 実行ファイルの設定
add_executable(Moccer-Sim main.cpp ${SOURCES} ${MOC_SRCS} ${PROTO_SRCS})

# ライブラリのリンク
target_link_libraries(Moccer-Sim
    Qt6::Core 
    Qt6::Gui
    Qt6::Widgets 
    Qt6::3DCore 
    Qt6::3DExtras 
    Qt6::3DRender
    Qt6::Quick 
    Qt6::Quick3D
    Qt6::Qml
    Qt6::Quick3DPhysics
    ${Protobuf_LIBRARIES} 
    pthread
)

# 実行時ディレクトリの設定
set_target_properties(Moccer-Sim PROPERTIES RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

# Custom 'run' target
add_custom_target(run
    COMMAND ${CMAKE_BINARY_DIR}/bin/Moccer-Sim
    DEPENDS Moccer-Sim
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)

# インストール対象: 実行ファイル
install(TARGETS Moccer-Sim
    RUNTIME DESTINATION bin
)

# インストール対象: ヘッダーファイル（必要に応じて）
install(DIRECTORY ${SRC_DIR}/
    DESTINATION include/moccer-sim
    FILES_MATCHING PATTERN "*.h"
)
