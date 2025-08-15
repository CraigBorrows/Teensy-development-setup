cmake_minimum_required(VERSION 3.16)

set(CMAKE_TOOLCHAIN_FILE ${CMAKE_SOURCE_DIR}/teensy-toolchain.cmake)

project(teensy-project C CXX ASM)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
include(utils/TeensyUtils.cmake)

# Set C++17 standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(TEENSY_ROOT $ENV{TEENSY_ROOT})


if(NOT TEENSY_ROOT)
    message(FATAL_ERROR "TEENSY_ROOT environment variable not set")
endif()


# Your source files
set(PROJECT_SOURCES src/main.cpp)

# Create executable
add_executable(${PROJECT_NAME}
        ${PROJECT_SOURCES}
)

add_teensy_cores(${PROJECT_NAME} teensy4)

add_teensy_library(${PROJECT_NAME} SPI)
add_teensy_library(${PROJECT_NAME} Wire)


# Teensy 4.x definitions
target_compile_definitions(${PROJECT_NAME} PRIVATE
        ARDUINO=10819
        TEENSYDUINO=159
        __IMXRT1062__
        ARDUINO_TEENSY41
        F_CPU=600000000
        USB_SERIAL
        LAYOUT_US_ENGLISH
)

# CRITICAL: Add linker script and options
target_link_options(${PROJECT_NAME} PRIVATE
        -T${TEENSY_ROOT}/teensy4/imxrt1062_t41.ld
        -Wl,--gc-sections,--relax
        -mcpu=cortex-m7
        -mfloat-abi=hard
        -mfpu=fpv5-d16
        -mthumb
)

# Generate hex file
add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
        COMMAND ${CMAKE_OBJCOPY} -O ihex -R .eeprom $<TARGET_FILE:${PROJECT_NAME}> ${PROJECT_NAME}.hex
        COMMENT "Creating hex file: ${PROJECT_NAME}.hex"
)