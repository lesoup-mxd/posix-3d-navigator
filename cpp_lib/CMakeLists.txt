project(CPP_Library VERSION 1.0)

set(CMAKE_CXX_STANDARD 11)

include_directories(${CMAKE_CURRENT_SOURCE_DIR})

add_library(gl_wrapper STATIC gl_wrapper.cpp)

target_link_libraries(gl_wrapper OpenGL::GL)