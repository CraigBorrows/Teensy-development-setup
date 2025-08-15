# TeensyUtils.cmake - Helper functions for Teensy development

# Set the Teensy root path
set(TEENSY_ROOT ${CMAKE_CURRENT_LIST_DIR}/path/to/teensy_core_libs)

# Function to add all Teensy cores for a specific board
function(add_teensy_cores TARGET TEENSY_BOARD)
    set(CORES_DIR ${TEENSY_ROOT}/cores/${TEENSY_BOARD})

    # Add core include directories
    target_include_directories(${TARGET} PRIVATE
            ${CORES_DIR}
    )

    # Find and add all core source files
    file(GLOB_RECURSE CORE_SOURCES
            ${CORES_DIR}/*.c
            ${CORES_DIR}/*.cpp
            ${CORES_DIR}/*.S
    )

    # Add core sources to target
    target_sources(${TARGET} PRIVATE ${CORE_SOURCES})

    message(STATUS "Added Teensy ${TEENSY_BOARD} cores: ${CORES_DIR}")
endfunction()

# Function to easily add Teensy libraries
function(add_teensy_library TARGET LIBRARY_NAME)
    set(LIB_DIR ${TEENSY_ROOT}/libraries/${LIBRARY_NAME})

    if(EXISTS ${LIB_DIR})
        # Add library include directory
        target_include_directories(${TARGET} PRIVATE
                ${LIB_DIR}
                ${LIB_DIR}/src
        )

        # Find and add library source files
        file(GLOB_RECURSE LIB_SOURCES
                ${LIB_DIR}/*.c
                ${LIB_DIR}/*.cpp
        )

        if(LIB_SOURCES)
            target_sources(${TARGET} PRIVATE ${LIB_SOURCES})
        endif()

        message(STATUS "Added Teensy library: ${LIBRARY_NAME}")
    else()
        message(WARNING "Teensy library not found: ${LIBRARY_NAME} at ${LIB_DIR}")
    endif()
endfunction()

# Function to add multiple libraries at once
function(add_teensy_libraries TARGET)
    foreach(LIBRARY ${ARGN})
        add_teensy_library(${TARGET} ${LIBRARY})
    endforeach()
endfunction()