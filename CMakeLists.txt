cmake_minimum_required(VERSION 3.13)

include(pico_sdk_import.cmake)

project(rpp-blink C CXX ASM)

pico_sdk_init()

add_executable(rpp-blink
    main.s
)

target_link_options(rpp-blink PRIVATE
    -Wl,--defsym=main=_start
)

target_link_libraries(rpp-blink pico_stdlib)

pico_add_extra_outputs(rpp-blink)

