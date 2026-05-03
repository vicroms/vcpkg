cmake_minimum_required(VERSION 3.20)
project(vcpkg-ci-eval-b VERSION 1.0.0)

option(WITH_FEATURE_A "Install shared configuration header" OFF)

if(WITH_FEATURE_A)
    install(FILES config.h DESTINATION include/vcpkg-ci-eval)
endif()
