# Before processing the CMake listfiles that generate desired output,
# such as executables and libraries, this settings file, and the files it imports, 
# fill the CMake cache file with variables that are used later or specify buildsystem behaviour

cmake_minimum_required(VERSION 3.7.2)

# ${project_dir} will point to the root of the project,
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

# Some settings
# TODO: What does each of these variables control?

set(RELEASE OFF CACHE BOOL "Performance optimized build")
set(VERIFICATION OFF CACHE BOOL "Only verification friendly kernel features")
set(PLATFORM "sabre" CACHE STRING "Platform to test")
set(CROSS_COMPILER_PREFIX "arm-linux-gnueabi-" CACHE STRING "Compiler to use")

# Search CMAKE_MODULE_PATH for application_settings.cmake
# The file should be found in ${project_dir}/tools/cmake-tool/helpers/
#
# The application_settings file contains three functions that are
# imported:
#   1) ApplyData61ElfloaderSettings(kernel_platform kernel_sel4_arch)
#   2) ApplyCommonReleaseVerificationSettings(kernel_arch)
#   3) correct_platform_strings

include(application_settings)

# correct_platform_strings is defined in 
# ${project_dir}/tools/cmake-tool/helpers/application_settings.cmake
# which is imported by including application_settings above
#
# The function simply translates and caches the user defined $PLATFORM into 
# a new string that names a valid platform for which there is a build.
# Potential variables set are:
#   $KernelPlatform
#   $KernelARMPlatform
#   $KernelSel4Arch

correct_platform_strings()

# Search for FindseL4.cmake in the CMAKE_MODULE_PATH list and load settings.
# The file should be found in ${project_dir}/kernel
#
# This cmake file sets cache variables:
#   KERNEL_PATH          - Path to kernel source; Current directory relative to
#                          FindseL4.cmake
#   KERNEL_HELPERS_PATH  - Path to helper library helper.cmake file; 
#                          KERNEL_PATH/tools/helpers.cmake
#   KERNEL_CONFIG_PATH   - Path to sel4config.cmake;
#                          KERNEL_PATH/configs/sel4config.cmake
#
# It also defines macros to run kernel and libsel4 cmake files:
#   sel4_import_kernel
#   sel4_import_libsel4
#   sel4_configure_platform_settings
#   
# Finally, a built-in cmake module FindPackageStandardHandleArgs is included.
# After including the module, FIND_HANDKE_PACKAGE_STANDAR_ARGS is called to 
# validate the following paths needed by seL4 are valid:
#   DEFAULT_MSG
#   KERNEL_PATH
#   KERNEL_HELPERS_PATH
#   KERNEL_CONFIG_PATH

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
