set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -fno-alias -auto -safe-cray-ptr -ftz -assume byterecl -i4 -r8 -nowarn -sox -traceback -msse2")

set(CMAKE_Fortran_FLAGS_RELEASE "-O3 -debug minimal -fp-model source")

set(CMAKE_Fortran_FLAGS_DEBUG "-g -O0 -check -check noarg_temp_created -check nopointer -warn -warn noerrors -fpe0 -ftrapuv")

set(CMAKE_Fortran_LINK_FLAGS "")
