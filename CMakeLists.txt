cmake_minimum_required(VERSION 3.16)

set(CMAKE_TOOLCHAIN_FILE ${CMAKE_SOURCE_DIR}/teensy-toolchain.cmake)
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -mcpu=cortex-m7 -mthumb -mfloat-abi=hard -mfpu=fpv5-d16")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -mcpu=cortex-m7 -mthumb -mfloat-abi=hard -mfpu=fpv5-d16")


project(teensy-project C CXX ASM)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# Set C++17 standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

include(utils/TeensyUtils.cmake)
list_teensy_libraries()
list_project_libraries()

# Your source files
file(GLOB_RECURSE PROJECT_SOURCES
        src/*.c
        src/*.cpp
)


# Create executable
add_executable(${PROJECT_NAME}
        ${PROJECT_SOURCES}
)

configure_teensy41_target(${PROJECT_NAME} )
add_teensy_cores(${PROJECT_NAME} teensy4)

add_teensy_library(${PROJECT_NAME} SPI)
add_teensy_library(${PROJECT_NAME} Wire)
