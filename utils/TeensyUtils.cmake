# TeensyUtils.cmake - Helper functions for Teensy development
set(TEENSY_ROOT $ENV{TEENSY_ROOT})

if(NOT TEENSY_ROOT)
    message(FATAL_ERROR "TEENSY_ROOT environment variable not set")
endif()

function(list_teensy_libraries)
    set(LIBS_DIR ${TEENSY_ROOT}/libraries)

    if(EXISTS ${LIBS_DIR})
        file(GLOB AVAILABLE_LIBS RELATIVE ${LIBS_DIR} ${LIBS_DIR}/*)
        list(FILTER AVAILABLE_LIBS INCLUDE REGEX "^[^.].*")  # Remove hidden files

        message(STATUS "=== Available Teensy Libraries ===")
        foreach(LIB ${AVAILABLE_LIBS})
            if(IS_DIRECTORY ${LIBS_DIR}/${LIB})
                message(STATUS "  - ${LIB}")
            endif()
        endforeach()
        message(STATUS "===================================")
    else()
        message(WARNING "Libraries directory not found: ${LIBS_DIR}")
    endif()
endfunction()

function(list_project_libraries)
    set(PROJECT_LIBS_DIR ${CMAKE_CURRENT_SOURCE_DIR}/lib)

    if(EXISTS ${PROJECT_LIBS_DIR})
        file(GLOB PROJECT_LIBS RELATIVE ${PROJECT_LIBS_DIR} ${PROJECT_LIBS_DIR}/*)
        list(FILTER PROJECT_LIBS INCLUDE REGEX "^[^.].*")  # Remove hidden files

        message(STATUS "=== Project Libraries (./libs/) ===")
        foreach(LIB ${PROJECT_LIBS})
            if(IS_DIRECTORY ${PROJECT_LIBS_DIR}/${LIB})
                message(STATUS "  - ${LIB}")
            endif()
        endforeach()
        message(STATUS "====================================")
    else()
        message(STATUS "No project libraries directory found: ${PROJECT_LIBS_DIR}")
    endif()
endfunction()

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

# Function to easily add Teensy libraries (checks project libs first, then teensy libs)
function(add_teensy_library TARGET LIBRARY_NAME)
    set(PROJECT_LIB_DIR ${CMAKE_CURRENT_SOURCE_DIR}/libs/${LIBRARY_NAME})
    set(TEENSY_LIB_DIR ${TEENSY_ROOT}/libraries/${LIBRARY_NAME})

    # Check project libs directory first
    if(EXISTS ${PROJECT_LIB_DIR})
        set(LIB_DIR ${PROJECT_LIB_DIR})
        set(LIB_SOURCE "project")
    elseif(EXISTS ${TEENSY_LIB_DIR})
        set(LIB_DIR ${TEENSY_LIB_DIR})
        set(LIB_SOURCE "teensy")
    else()
        message(FATAL_ERROR "Library '${LIBRARY_NAME}' not found in:\n  - ${PROJECT_LIB_DIR}\n  - ${TEENSY_LIB_DIR}")
    endif()

    # Always add the main library directory
    target_include_directories(${TARGET} PRIVATE ${LIB_DIR})

    # Check if there's a src folder - if so, only search in there recursively
    if(EXISTS ${LIB_DIR}/src)
        message(STATUS "Found src/ folder, adding recursively from src/")
        target_include_directories(${TARGET} PRIVATE ${LIB_DIR}/src)

        # Add all subdirectories under src/ but exclude unwanted folders
        file(GLOB_RECURSE SRC_SUBDIRS LIST_DIRECTORIES true ${LIB_DIR}/src/*)
        foreach(SUBDIR ${SRC_SUBDIRS})
            if(IS_DIRECTORY ${SUBDIR})
                # Get the folder name to check if we should exclude it
                get_filename_component(FOLDER_NAME ${SUBDIR} NAME)
                string(TOLOWER ${FOLDER_NAME} FOLDER_NAME_LOWER)

                # Skip unwanted directories
                if(NOT FOLDER_NAME_LOWER MATCHES "^(examples?|tests?|docs?|\.git|\.svn)$")
                    target_include_directories(${TARGET} PRIVATE ${SUBDIR})
                endif()
            endif()
        endforeach()

        # Find source files in src/
        file(GLOB_RECURSE LIB_SOURCES
                ${LIB_DIR}/src/*.c
                ${LIB_DIR}/src/*.cpp
        )
    else()
        # No src folder, use old behavior but still exclude unwanted folders
        message( sgfwqeadsadding from root")

        # Add subdirectories but exclude unwanted ones
        file(GLOB SUBDIRS LIST_DIRECTORIES true ${LIB_DIR}/*)
        foreach(SUBDIR ${SUBDIRS})
            if(IS_DIRECTORY ${SUBDIR})
                get_filename_component(FOLDER_NAME ${SUBDIR} NAME)
                string(TOLOWER ${FOLDER_NAME} FOLDER_NAME_LOWER)

                # Skip unwanted directories
                if(NOT FOLDER_NAME_LOWER MATCHES "^(examples?|tests?|docs?|\.git|\.svn)$")
                    target_include_directories(${TARGET} PRIVATE ${SUBDIR})
                endif()
            endif()
        endforeach()

        # Find source files in root
        file(GLOB_RECURSE LIB_SOURCES
                ${LIB_DIR}/*.c
                ${LIB_DIR}/*.cpp
        )
    endif()

    # Exclude source files from unwanted directories
    if(LIB_SOURCES)
        list(FILTER LIB_SOURCES EXCLUDE REGEX ".*(examples?|tests?|docs?)/.*")
        target_sources(${TARGET} PRIVATE ${LIB_SOURCES})
    endif()

    message(STATUS "Added ${LIB_SOURCE} library: ${LIBRARY_NAME} from ${LIB_DIR}")
endfunction()


# Function to add multiple libraries at once
function(add_teensy_libraries TARGET)
    foreach(LIBRARY ${ARGN})
        add_teensy_library(${TARGET} ${LIBRARY})
    endforeach()
endfunction()