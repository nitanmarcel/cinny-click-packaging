add_executable(push push.cpp )

install(FILES push-apparmor.json DESTINATION push)
install(FILES push.json DESTINATION push)
install(PROGRAMS ${CMAKE_CURRENT_BINARY_DIR}/push DESTINATION push)
