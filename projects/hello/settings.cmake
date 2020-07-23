cmake_minimum_required(VERSION 3.7.2)

set(project_dir "${CMAKE_CURRENT_LIST_DIR}/../../")
file(GLOB project_modules ${project_dir}/projects/*)
list(
    APPEND
        CMAKE_MODULE_PATH
        ${project_dir}/kernel
        ${project_dir}/tools/cmake-tool/helpers/
        ${project_dir}/tools/elfloader-tool/
        ${project_modules}
)
include(application_settings)

# Some settings
set(RELEASE OFF CACHE BOOL "Performance optimized build")
set(VERIFICATION OFF CACHE BOOL "Only verification friendly kernel features")
set(PLATFORM "imx6" CACHE STRING "Platform to test")


correct_platform_strings()

find_package(seL4 REQUIRED)
sel4_configure_platform_settings()

set(valid_platforms ${KernelPlatform_all_strings} ${correct_platform_strings_platform_aliases})
set_property(CACHE PLATFORM PROPERTY STRINGS ${valid_platforms})
if(NOT "${PLATFORM}" IN_LIST valid_platforms)
    message(FATAL_ERROR "Invalid PLATFORM selected: \"${PLATFORM}\"
Valid platforms are: \"${valid_platforms}\"")
endif()


ApplyCommonReleaseVerificationSettings(${RELEASE} ${VERIFICATION})
