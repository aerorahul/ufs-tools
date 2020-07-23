if(CMAKE_Fortran_COMPILER_ID MATCHES "GNU")

  set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -fcray-pointer -fconvert=big-endian -ffree-line-length-none -fno-range-check -fbacktrace")
  set(CMAKE_Fortran_FLAGS_RELEASE "-O3 -funroll-all-loops -finline-functions")
  set(CMAKE_Fortran_FLAGS_DEBUG "-O0 -g -fcheck=bounds -ffpe-trap=invalid,zero,overflow,underflow" )
  set(CMAKE_Fortran_LINK_FLAGS "" )

elseif(CMAKE_Fortran_COMPILER_ID MATCHES "Intel")

  set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -fpp -fno-alias -auto -safe-cray-ptr -ftz -assume byterecl -align array64byte -nowarn -sox -traceback")
  set(CMAKE_Fortran_FLAGS_RELEASE "-O2 -debug minimal -fp-model source -nowarn -qoverride-limits -qno-opt-dynamic-align -qopt-prefetch=3")
  set(CMAKE_Fortran_FLAGS_DEBUG "-g -O0 -check -check noarg_temp_created -check nopointer -warn -warn noerrors -fpe0 -ftrapuv")
  set(CMAKE_Fortran_LINK_FLAGS "")

else()

  message(WARNING "Fortran compiler with ID ${CMAKE_Fortran_COMPILER_ID} will be used with CMake default options")

endif()
