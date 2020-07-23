cmake_minimum_required(VERSION 3.15)

project(
  fv3lamio
  VERSION 0.0.1
  LANGUAGES C Fortran)

include(ExternalProject)
include(GNUInstallDirs)

if(NOT CMAKE_BUILD_TYPE MATCHES "^(Debug|Release|MinSizeRel|RelWithDebInfo)$")
  message(STATUS "Setting build type to 'Release' as none was specified.")
  set(CMAKE_BUILD_TYPE "Release"
      CACHE STRING "Choose the type of build." FORCE)
  set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS
                     "Debug" "Release" "MinSizeRel" "RelWithDebInfo")
endif()

if(NOT CMAKE_C_COMPILER_ID MATCHES "^(Intel|GNU|Clang|AppleClang)$")
  message(WARNING "Compiler not officially supported: ${CMAKE_C_COMPILER_ID}")
endif()

if(NOT CMAKE_Fortran_COMPILER_ID MATCHES "^(Intel|GNU)$")
  message(WARNING "Compiler not officially supported: ${CMAKE_Fortran_COMPILER_ID}")
endif()

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake)

option(OPENMP "Enable OpenMP threading" OFF)

find_package(MPI REQUIRED)
find_package(NetCDF REQUIRED COMPONENTS Fortran)

find_package(FMS REQUIRED)

list(APPEND srcs
  read_fv3lam.f90
  module_fv3lam.f90)


if(CMAKE_Fortran_COMPILER_ID MATCHES "GNU")
  set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -fcray-pointer -fconvert=big-endian -ffree-line-length-none -fno-range-check -fbacktrace")
  set(CMAKE_Fortran_FLAGS_RELEASE "-O3 -funroll-all-loops -finline-functions")
  set(CMAKE_Fortran_FLAGS_DEBUG "-O0 -g -fcheck=bounds -ffpe-trap=invalid,zero,overflow,underflow" )
  set(CMAKE_Fortran_LINK_FLAGS "" )
elseif(CMAKE_Fortran_COMPILER_ID MATCHES "Intel")
  include(compiler_flags_Intel_Fortran)
else()
  message(WARNING "Fortran compiler with ID ${CMAKE_Fortran_COMPILER_ID} will be used with CMake default options")
endif()

set(exec "read_fv3lam.x")
add_executable(${exec} ${srcs})
target_link_libraries(${exec} PRIVATE NetCDF::NetCDF_Fortran)
target_link_libraries(${exec} PRIVATE FMS::fms_r4)

