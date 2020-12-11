cmake_minimum_required(VERSION 2.8)
project(tikv_handler)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_FLAGS "-lpthread -lssl -lcrypto -ldl")
set(INCS ${CMAKE_SOURCE_DIR}/target/cxx)
list(APPEND INCS ${CMAKE_SOURCE_DIR}/include)
set(LIBS ${CMAKE_SOURCE_DIR}/target/debug/libtikv_client.a)
set(SRCS ${CMAKE_SOURCE_DIR}/src/tikv_client.cpp)

add_library(tikv_handler STATIC ${SRCS})
target_include_directories(tikv_handler PUBLIC ${INCS})
target_link_libraries(tikv_handler ${LIBS})

add_subdirectory(example)
