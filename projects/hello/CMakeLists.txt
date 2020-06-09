cmake_minimum_required(VERSION 3.10)

project(hello)

add_executable(hello hello.c)

target_link_libraries(hello sel4muslcsys  muslc) # we need to link against the standard C lib for printf


# Set this image as the rootserver
DeclareRootserver(hello)
