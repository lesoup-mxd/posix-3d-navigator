project(Vulkan_Wrapper VERSION 1.0)

set(CMAKE_CXX_STANDARD 17)

find_package(Vulkan REQUIRED)
include_directories(${CMAKE_CURRENT_SOURCE_DIR} ${Vulkan_INCLUDE_DIR})

add_library(vulkan_wrapper SHARED vulkan_wrapper.cpp)
target_link_libraries(vulkan_wrapper ${Vulkan_LIBRARIES})