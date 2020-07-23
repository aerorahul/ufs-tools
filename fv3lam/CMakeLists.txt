cmake_minimum_required(VERSION 3.15)

project(
  fv3lam
  VERSION 0.0.1
  LANGUAGES Fortran)

include(GNUInstallDirs)

if(NOT CMAKE_BUILD_TYPE MATCHES "^(Debug|Release|MinSizeRel|RelWithDebInfo)$")
  message(STATUS "Setting build type to 'Release' as none was specified.")
  set(CMAKE_BUILD_TYPE "Release"
      CACHE STRING "Choose the type of build." FORCE)
  set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS
                     "Debug" "Release" "MinSizeRel" "RelWithDebInfo")
endif()

if(NOT CMAKE_Fortran_COMPILER_ID MATCHES "^(Intel|GNU)$")
  message(WARNING "Compiler not officially supported: ${CMAKE_Fortran_COMPILER_ID}")
endif()

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake)

option(OPENMP "Enable OpenMP threading" OFF)

find_package(MPI REQUIRED)
find_package(NetCDF REQUIRED COMPONENTS Fortran)
find_package(FMS REQUIRED COMPONENTS R4)

include(fv3lam_compiler_flags)

list(APPEND srcs
  read_fv3lam.f90
  module_fv3lam.f90)

set(exec "read_fv3lam.x")
add_executable(${exec} ${srcs})
target_link_libraries(${exec} PRIVATE NetCDF::NetCDF_Fortran)
target_link_libraries(${exec} PRIVATE FMS::fms_r4)
