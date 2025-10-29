cmake_minimum_required(VERSION 3.10)
project(problem)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O0")

set(ONNXRUNTIME_ROOT "${CMAKE_CURRENT_SOURCE_DIR}/onnxruntime")

include_directories("${ONNXRUNTIME_ROOT}/include")

add_executable(
  ${PROJECT_NAME}
  main.cc
)

find_package(ZLIB REQUIRED)

if(APPLE)
  target_link_libraries(
    ${PROJECT_NAME}
    "-framework CoreFoundation"
    "-framework Foundation"
    ${ONNXRUNTIME_ROOT}/lib/libonnxruntime.a
  )
else()
  find_library(ONNXRUNTIME_LIB onnxruntime PATHS ${ONNXRUNTIME_ROOT}/lib)
  target_link_libraries(${PROJECT_NAME} ${ONNXRUNTIME_LIB})
endif()