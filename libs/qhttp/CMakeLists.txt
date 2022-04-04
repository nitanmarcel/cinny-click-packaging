project(qhttp C CXX)
cmake_minimum_required(VERSION 3.0.0)


find_package(Qt5Core REQUIRED)
find_package(Qt5Network REQUIRED)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

set(QHTTP "QHttp")

set(SRC
    ../http-parser/http_parser.c 
    ../http-parser/http_parser.h
    qhttpabstracts.cpp 
    qhttpabstracts.hpp
    qhttpfwd.hpp
    qhttpserver.cpp 
    qhttpserver.hpp
    qhttpserverconnection.cpp 
    qhttpserverconnection.hpp
    qhttpserverrequest.cpp 
    qhttpserverrequest.hpp
    qhttpserverresponse.cpp 
    qhttpserverresponse.hpp
    )

set(CMAKE_INCLUDE_CURRENT_DIR ON)
set(CMAKE_AUTOMOC ON)

add_library(${QHTTP} SHARED ${SRC})



set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

target_link_libraries(${QHTTP} PUBLIC
    Qt5::Core
    Qt5::Network
)

target_include_directories(${QHTTP} PUBLIC
    .
    ../
)

target_compile_definitions(${QHTTP} PUBLIC
    QHTTP_DYNAMIC_LIB
    QHTTP_HAS_CLIENT
    QHTTP_MEMORY_LOG=0
)

install(TARGETS ${QHTTP} LIBRARY DESTINATION "${CMAKE_INSTALL_LIBDIR}"
)

