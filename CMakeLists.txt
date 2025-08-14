cmake_minimum_required(VERSION 3.16)

if(CMAKE_BUILD_TYPE STREQUAL "Debug" OR NOT CMAKE_BUILD_TYPE)
    include_directories(
            /opt/teensy/arduino-1.8.19/hardware/teensy/avr/teensy4  # Docker path
    )
endif()

set(CMAKE_TOOLCHAIN_FILE ${CMAKE_SOURCE_DIR}/teensy-toolchain.cmake)

project(teensy-project C CXX ASM)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# Set C++17 standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(TEENSY_ROOT $ENV{TEENSY_ROOT})
set(ARDUINO_ROOT $ENV{ARDUINO_ROOT})

if(NOT TEENSY_ROOT)
    message(FATAL_ERROR "TEENSY_ROOT environment variable not set")
endif()

message(STATUS "Using Teensy root: ${TEENSY_ROOT}")

# Find Teensy 4 core source files
file(GLOB TEENSY_C_SOURCES "${TEENSY_ROOT}/teensy4/*.c")
file(GLOB TEENSY_CPP_SOURCES "${TEENSY_ROOT}/teensy4/*.cpp")
file(GLOB TEENSY_ASM_SOURCES "${TEENSY_ROOT}/teensy4/*.S")


# Your source files
set(PROJECT_SOURCES src/main.cpp)

# Create executable
add_executable(${PROJECT_NAME}.elf
        ${PROJECT_SOURCES}
        ${TEENSY_C_SOURCES}
        ${TEENSY_CPP_SOURCES}
        ${TEENSY_ASM_SOURCES}
        ${ARDUINO_ROOT}/hardware/arduino/avr/libraries/SPI/src/SPI.cpp # SPI
        ${ARDUINO_ROOT}/hardware/arduino/avr/libraries/Wire/src/Wire.cpp # I2C
)

# More comprehensive include directories
target_include_directories(${PROJECT_NAME}.elf PRIVATE
        ${TEENSY_ROOT}/teensy4
        ${ARDUINO_ROOT}/hardware/arduino/avr/libraries/SPI/src # SPI
        ${ARDUINO_ROOT}/hardware/arduino/avr/libraries/Wire/src # I2C
        src
)


# Teensy 4.x definitions
target_compile_definitions(${PROJECT_NAME}.elf PRIVATE
        ARDUINO=10819
        TEENSYDUINO=159
        __IMXRT1062__
        ARDUINO_TEENSY41
        F_CPU=600000000
        USB_SERIAL
        LAYOUT_US_ENGLISH
)

# CRITICAL: Add linker script and options
target_link_options(${PROJECT_NAME}.elf PRIVATE
        -T${TEENSY_ROOT}/teensy4/imxrt1062_t41.ld
        -Wl,--gc-sections,--relax
        -mcpu=cortex-m7
        -mfloat-abi=hard
        -mfpu=fpv5-d16
        -mthumb
)

# Generate hex file
add_custom_command(TARGET ${PROJECT_NAME}.elf POST_BUILD
        COMMAND ${CMAKE_OBJCOPY} -O ihex -R .eeprom $<TARGET_FILE:${PROJECT_NAME}.elf> ${PROJECT_NAME}.hex
        COMMENT "Creating hex file: ${PROJECT_NAME}.hex"
)