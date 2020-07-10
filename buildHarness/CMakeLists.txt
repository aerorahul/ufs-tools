cmake_minimum_required(VERSION 3.15)

project(
  cicemom6-interface
  VERSION 2020.07.09
  LANGUAGES Fortran)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake)

include(GNUInstallDirs)

if(NOT CMAKE_BUILD_TYPE MATCHES "^(Debug|Release|RelWithDebInfo|MinSizeRel)$")
  message(STATUS "Setting build type to 'Release' as none was specified.")
  set(CMAKE_BUILD_TYPE
      "Release"
      CACHE STRING "Choose the type of build." FORCE)
  set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS "Debug" "Release"
                                               "MinSizeRel" "RelWithDebInfo")
endif()

if(NOT CMAKE_Fortran_COMPILER_ID MATCHES "^(Intel|GNU)$")
  message(WARNING "Compiler not officially supported: ${CMAKE_Fortran_COMPILER_ID}")
endif()

# CICE configuration options
option(USE_MPI    "Use MPI Libraries" ON)
option(USE_NetCDF "Use NetCDF IO Libraries" ON)
option(USE_PIO    "Use Parallel IO Libraries" OFF)

if(USE_MPI)
  find_package(MPI REQUIRED COMPONENTS Fortran)
endif()

if(USE_NetCDF)
  find_package(NetCDF REQUIRED COMPONENTS Fortran)
endif()

if(USE_PIO)
  find_package(PIO REQUIRED VERSION 2)
endif()

find_package(fms REQUIRED)

find_package(ESMF MODULE REQUIRED)

if(OPENMP)
  find_package(OpenMP REQUIRED COMPONENTS Fortran)
endif()

include(compiler_flags)

add_subdirectory(CICE-interface)
add_subdirectory(MOM6-interface)
