set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -fdefault-real-8 -fdefault-double-8 -Waliasing -fcray-pointer -fconvert=big-endian -ffree-line-length-none -fno-range-check -fbacktrace")

set(CMAKE_Fortran_FLAGS_RELEASE "-O3")

set(CMAKE_Fortran_FLAGS_DEBUG "-O0 -g -fbounds-check -ffpe-trap=invalid,zero,overflow")

set(CMAKE_Fortran_LINK_FLAGS "")
