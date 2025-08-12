set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR arm)

# Toolchain
set(CMAKE_C_COMPILER arm-none-eabi-gcc)
set(CMAKE_CXX_COMPILER arm-none-eabi-g++)
set(CMAKE_ASM_COMPILER arm-none-eabi-gcc)
set(CMAKE_OBJCOPY arm-none-eabi-objcopy)
set(CMAKE_SIZE arm-none-eabi-size)

# Teensy settings
set(TEENSY_VERSION 41)
set(CPU_CORE_SPEED 600000000)

# Get Teensy root from environment
set(TEENSY_ROOT $ENV{TEENSY_ROOT})

# Compiler flags
set(TEENSY_C_FLAGS "-Wall -g -Os -mcpu=cortex-m7 -mfloat-abi=hard -mfpu=fpv5-d16 -mthumb")
set(TEENSY_CXX_FLAGS "${TEENSY_C_FLAGS} -std=gnu++17 -felide-constructors -fno-exceptions -fno-rtti")

set(CMAKE_C_FLAGS "${TEENSY_C_FLAGS}")
set(CMAKE_CXX_FLAGS "${TEENSY_CXX_FLAGS}")

# Don't set CMAKE_EXE_LINKER_FLAGS here - we'll do it in CMakeLists.txt

# Skip compiler tests
set(CMAKE_C_COMPILER_WORKS 1)
set(CMAKE_CXX_COMPILER_WORKS 1)