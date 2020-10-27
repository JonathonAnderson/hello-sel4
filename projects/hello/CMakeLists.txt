cmake_minimum_required(VERSION 3.7.2)

include(settings.cmake)

project(hello C ASM)

find_package(seL4 REQUIRED)
find_package(elfloader-tool REQUIRED)


sel4_import_kernel()

# Elfloader settings that correspond to how Data61 sets its boards up.
# This function is defined in ${project_dir}/tools/cmake-tool/helpers/application_settings.cmake
ApplyData61ElfLoaderSettings(${KernelPlatform} ${KernelSel4Arch})
elfloader_import_project()

find_package(musllibc REQUIRED)
find_package(util_libs REQUIRED)
find_package(seL4_libs REQUIRED)

# This sets up environment build flags and imports musllibc and runtime libraries.
musllibc_setup_build_environment_with_sel4runtime()
sel4_import_libsel4()
util_libs_import_libraries()
sel4_libs_import_libraries()


add_executable(hello EXCLUDE_FROM_ALL hello.c)
target_link_libraries(
    hello
    PUBLIC
        muslc
        sel4
        sel4runtime
        sel4muslcsys
)
target_compile_options(hello PRIVATE -Werror)

# Set this image as the rootserver
include(rootserver)
DeclareRootserver(hello)

include(simulation)
GenerateSimulateScript()
