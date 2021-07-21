cmake_minimum_required(VERSION 3.18)

project(
  fv3dycore
  VERSION 1.0.0
  LANGUAGES C Fortran)

include(ExternalProject)
include(GNUInstallDirs)

if(NOT CMAKE_BUILD_TYPE MATCHES "^(Debug|Release|Repro|MinSizeRel|RelWithDebInfo)$")
  message(STATUS "No build type specified.")
  set(CMAKE_BUILD_TYPE "Release"
      CACHE STRING "Choose the type of build." FORCE)
  set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS
                     "Debug" "Release" "Repro" "MinSizeRel" "RelWithDebInfo")
endif()
message(STATUS "Setting build type to '${CMAKE_BUILD_TYPE}'.")

if(NOT CMAKE_C_COMPILER_ID MATCHES "^(Intel|GNU|Clang|AppleClang)$")
  message(WARNING "Compiler not officially supported: ${CMAKE_C_COMPILER_ID}")
endif()

if(NOT CMAKE_Fortran_COMPILER_ID MATCHES "^(Intel|GNU)$")
  message(WARNING "Compiler not officially supported: ${CMAKE_Fortran_COMPILER_ID}")
endif()

option(OPENMP "Enable OpenMP threading" OFF)

ExternalProject_Add(fms
  GIT_REPOSITORY "https://github.com/noaa-emc/fms"
  GIT_TAG        "feature/2020.04.03-private"
  PREFIX         "${CMAKE_BINARY_DIR}/fms"
  CMAKE_ARGS     "-DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}/fms"
                 "-DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}"
                 "-DCMAKE_Fortran_COMPILER=${CMAKE_Fortran_COMPILER}"
                 "-DOPENMP=${OPENMP}"
                 "-DGFS_PHYS=ON"
  )

ExternalProject_Add(fv3
  GIT_REPOSITORY "https://github.com/noaa-emc/gfdl_atmos_cubed_sphere"
  GIT_TAG        "feature/cmake_in_dycore_of_emc"
  PREFIX         "${CMAKE_BINARY_DIR}/fv3"
  CMAKE_ARGS     "-DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}/fv3"
                 "-DCMAKE_PREFIX_PATH=${CMAKE_INSTALL_PREFIX}"
                 "-DCMAKE_Fortran_COMPILER=${CMAKE_Fortran_COMPILER}"
                 "-DOPENMP=${OPENMP}"
  DEPENDS        fms
  )
