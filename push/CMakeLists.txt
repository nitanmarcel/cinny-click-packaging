add_executable(push push.cpp )

target_link_libraries(push Qt5::Core)

install(FILES push-apparmor.json DESTINATION push)
install(FILES push.json DESTINATION push)
install(PROGRAMS ${CMAKE_CURRENT_BINARY_DIR}/push DESTINATION push)
