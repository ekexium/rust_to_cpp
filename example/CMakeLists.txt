add_executable(tikv_handler_example main.cpp)
target_include_directories(tikv_handler_example PUBLIC ${INCS})
target_link_libraries(tikv_handler_example ${LIBS} tikv_handler)
