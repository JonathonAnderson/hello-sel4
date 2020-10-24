cmake_minimum_required(VERSION 3.7.2)

# project_dir will point to the root of the project,
# i.e. the root folder containing following directories:
# build, kernel, projects, tools
set(project_dir "${CMAKE_CURRENT_LIST_DIR}/../../")

# Gather a list of projects to be built
list(
    APPEND
        project_modules
        ${project_dir}/projects/hello/
        ${project_dir}/projects/musllibc/
        ${project_dir}/projects/sel4_libs/
        ${project_dir}/projects/sel4runtime/
        ${project_dir}/projects/util_libs/
)

# Define the list of paths to be searched when using include() or find_package()
# Note that the list of projects specified above is included
list(
    APPEND
        CMAKE_MODULE_PATH
        ${project_dir}/kernel
        ${project_dir}/tools/cmake-tool/helpers/
        ${project_dir}/tools/elfloader-tool/
        ${project_modules}
)

# Search CMAKE_MODULE_PATH for application_settings.cmake
# The file should be found in ${project_dir}/tools/cmake-tool/helpers/
# TODO: What does  application_settings configure or provide?
include(application_settings)

# Some settings
# TODO: What does each of these variables control?
set(RELEASE OFF CACHE BOOL "Performance optimized build")
set(VERIFICATION OFF CACHE BOOL "Only verification friendly kernel features")
set(PLATFORM "sabre" CACHE STRING "Platform to test")
set(CROSS_COMPILER_PREFIX "arm-linux-gnueabi-" CACHE STRING "Compiler to use")

# TODO: What does correct_platform_strings do?
correct_platform_strings()

# Search for FindseL4.cmake in the CMAKE_MODULE_PATH list and load settings
# The file should be found in ${project_dir}/kernel
# TODO: What does seL4 configure or provide?
find_package(seL4 REQUIRED)

# TODO What does seL4_configure_platform_settings do?
sel4_configure_platform_settings()

# TODO: What are valid platforms?
#       where do these variables inherit from?
set(valid_platforms ${KernelPlatform_all_strings} ${correct_platform_strings_platform_aliases})

# TODO: What does seting the platform property do?
set_property(CACHE PLATFORM PROPERTY STRINGS ${valid_platforms})

# Checks to make sure that the platform we selected is considered a valid platform
# If not, return an error message with available platforms
if(NOT "${PLATFORM}" IN_LIST valid_platforms)
    message(FATAL_ERROR "Invalid PLATFORM selected: \"${PLATFORM}\"
Valid platforms are: \"${valid_platforms}\"")
endif()

# TODO: What are common release verification settings?
ApplyCommonReleaseVerificationSettings(${RELEASE} ${VERIFICATION})
