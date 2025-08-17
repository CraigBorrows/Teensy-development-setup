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

        message(STATUS "=== Project Libraries (./lib/) ===")
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


    file(GLOB TEENSY_C_SOURCES ${CORES_DIR}/*.c)
    file(GLOB TEENSY_CPP_SOURCES ${CORES_DIR}/*.cpp)
    file(GLOB TEENSY_ASM_SOURCES ${CORES_DIR}/*.S)

    # Add core sources to target
    target_sources(${TARGET} PRIVATE ${TEENSY_C_SOURCES} ${TEENSY_CPP_SOURCES} ${TEENSY_ASM_SOURCES})

    message(STATUS "Added Teensy ${TEENSY_BOARD} cores: ${CORES_DIR}")
endfunction()

# Function to easily add Teensy libraries (checks project libs first, then teensy libs)
function(add_teensy_library TARGET LIBRARY_NAME)
    set(PROJECT_LIB_DIR ${CMAKE_CURRENT_SOURCE_DIR}/lib/${LIBRARY_NAME})
    set(TEENSY_LIB_DIR ${TEENSY_ROOT}/libraries/${LIBRARY_NAME})

    set(IGNORE_FOLDERS
            extra extras example examples test tests doc docs build-tests
            generator spm-test tools zephyr doxygen conan-wrapper spm_headers
            spm_resources examples_processing OBJLoader assets .github .git .svn
    )

    # Find library directory
    if(EXISTS ${PROJECT_LIB_DIR})
        set(LIB_DIR ${PROJECT_LIB_DIR})
        set(LIB_SOURCE "project")
    elseif(EXISTS ${TEENSY_LIB_DIR})
        set(LIB_DIR ${TEENSY_LIB_DIR})
        set(LIB_SOURCE "teensy")
    else()
        message(FATAL_ERROR "Library '${LIBRARY_NAME}' not found in:\n  - ${PROJECT_LIB_DIR}\n  - ${TEENSY_LIB_DIR}")
    endif()

    # Helper function to check if a path should be ignored
    function(should_ignore_path PATH RESULT_VAR)
        set(${RESULT_VAR} FALSE PARENT_SCOPE)
        foreach(IGNORE_FOLDER ${IGNORE_FOLDERS})
            if(PATH MATCHES "/${IGNORE_FOLDER}(/|$)")
                set(${RESULT_VAR} TRUE PARENT_SCOPE)
                return()
            endif()
        endforeach()
    endfunction()

    # Helper function to find sources in a specific directory (non-recursive)
    function(find_sources_in_dir DIR_PATH SOURCES_VAR)
        file(GLOB DIR_SOURCES
                ${DIR_PATH}/*.c
                ${DIR_PATH}/*.cpp
        )
        set(${SOURCES_VAR} ${DIR_SOURCES} PARENT_SCOPE)
    endfunction()

    function(directory_has_headers DIR_PATH RESULT_VAR)
        file(GLOB HEADERS ${DIR_PATH}/*.h ${DIR_PATH}/*.hpp)
        if(HEADERS)
            set(${RESULT_VAR} TRUE PARENT_SCOPE)
        else()
            set(${RESULT_VAR} FALSE PARENT_SCOPE)
        endif()
    endfunction()

    # Helper function to process a library path and collect all sources
    function(process_library_path BASE_PATH RECURSIVE ALL_SOURCES_VAR)
        set(COLLECTED_SOURCES)

        # Always add the base directory and collect its sources
        target_include_directories(${TARGET} PRIVATE ${BASE_PATH})
        find_sources_in_dir(${BASE_PATH} BASE_SOURCES)
        list(APPEND COLLECTED_SOURCES ${BASE_SOURCES})

        # Get subdirectories
        if(RECURSIVE)
            file(GLOB_RECURSE SUBDIRS LIST_DIRECTORIES true ${BASE_PATH}/*)
        else()
            file(GLOB SUBDIRS LIST_DIRECTORIES true ${BASE_PATH}/*)
        endif()

        foreach(SUBDIR ${SUBDIRS})
            if(IS_DIRECTORY ${SUBDIR})
                should_ignore_path(${SUBDIR} SHOULD_SKIP)
                directory_has_headers(${SUBDIR} HAS_HEADERS)
                if(NOT SHOULD_SKIP AND HAS_HEADERS)
                    message(STATUS "Including ${SUBDIR}")
                    target_include_directories(${TARGET} PRIVATE ${SUBDIR})
                    find_sources_in_dir(${SUBDIR} SUBDIR_SOURCES)
                    list(APPEND COLLECTED_SOURCES ${SUBDIR_SOURCES})
                elseif(NOT SHOULD_SKIP)
                    # Still collect sources even if no headers
                    find_sources_in_dir(${SUBDIR} SUBDIR_SOURCES)
                    list(APPEND COLLECTED_SOURCES ${SUBDIR_SOURCES})
                endif()
            endif()
        endforeach()

        set(${ALL_SOURCES_VAR} ${COLLECTED_SOURCES} PARENT_SCOPE)
    endfunction()

    # Process library based on structure
    if(EXISTS ${LIB_DIR}/src)
        process_library_path(${LIB_DIR}/src TRUE LIB_SOURCES)
    else()
        process_library_path(${LIB_DIR} FALSE LIB_SOURCES)
    endif()

    # Add source files to target
    if(LIB_SOURCES)
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


function(configure_teensy41_target TARGET)



    # Teensy 4.1 definitions
    target_compile_definitions(${TARGET} PRIVATE
            ARDUINO=10819
            TEENSYDUINO=159
            __IMXRT1062__
            ARDUINO_TEENSY41
            F_CPU=600000000
            USB_SERIAL
            LAYOUT_US_ENGLISH
            __arm__
            ARM_MATH_CM7
    )

    target_compile_options(${TARGET} PRIVATE
            # ARM Cortex-M7 flags
            -mcpu=cortex-m7
            -mthumb
            -mfloat-abi=hard
            -mfpu=fpv5-d16

            # Flags for both C and C++
            $<$<COMPILE_LANGUAGE:C>:-std=gnu11>
            $<$<COMPILE_LANGUAGE:C>:-ffunction-sections>
            $<$<COMPILE_LANGUAGE:C>:-fdata-sections>
            $<$<COMPILE_LANGUAGE:C>:-Wall>

            # Flags for C++ only
            $<$<COMPILE_LANGUAGE:CXX>:-std=gnu++14>
            $<$<COMPILE_LANGUAGE:CXX>:-ffunction-sections>
            $<$<COMPILE_LANGUAGE:CXX>:-fdata-sections>
            $<$<COMPILE_LANGUAGE:CXX>:-fno-exceptions>
            $<$<COMPILE_LANGUAGE:CXX>:-fno-rtti>
            $<$<COMPILE_LANGUAGE:CXX>:-felide-constructors>
            $<$<COMPILE_LANGUAGE:CXX>:-Wall>
    )

    target_link_options(${TARGET} PRIVATE
            -mcpu=cortex-m7
            -mthumb
            -mfloat-abi=hard
            -mfpu=fpv5-d16
            -T${TEENSY_ROOT}/cores/teensy4/imxrt1062_t41.ld
            -Wl,--gc-sections,--relax,--defsym=__rtc_localtime=0
            --specs=nano.specs
            -lm
            -lc
    )

    # Generate hex file
    add_custom_command(TARGET ${TARGET} POST_BUILD
            COMMAND ${CMAKE_OBJCOPY} -O ihex -R .eeprom $<TARGET_FILE:${TARGET}> ${TARGET}.hex
            COMMENT "Creating hex file: ${TARGET}.hex"
    )
endfunction()


