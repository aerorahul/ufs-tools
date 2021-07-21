# Compile GFDL atmos cubed sphere dynamical core

<!--
![](https://github.com/aerorahul/ufs-tools/workflows/Build%20Linux/badge.svg)
--!>

`CMakeLists.txt` in this directory clones, builds and installs the dependencies of the GFDL atmos cubed sphere and uses them when building the dynamical core with cmake

## Prerequisites:
- Intel or GNU compilers
- MPI
- NetCDF

## Environment setup (e.g. NOAA Orion)
```
module load intel
module load impi
module load netcdf # loads NETCDF_ROOT environment variable

export CC=mpiicc
export FC=mpiifort
```

## Clone and Build:
```
git clone -b compile_dycore https://github.com/aerorahul/ufs-tools

rm -rf install build
mkdir -p build && cd build
cmake -DCMAKE_INSTALL_PREFIX=../install ../ufs-tools/compile_dycore
make -j6
```

## Branches:
- FMS [feature/2020.04.03-private](https://github.com/noaa-emc/fms/tree/feature/2020.04.03-private)
- GFDL FV3 Dynamical Core [feature/cmake_in_dycore_of_emc](https://github.com/noaa-emc/GFDL_atmos_cubed_sphere/tree/feature/cmake_in_dycore_of_emc)

## Notes:
- An update is required to the FMS tag 2020.04.03 to make the compiler flags `PRIVATE`.  This is done in the branch `noaa-emc:feature/2020.04.03-private`
- We are not passing the flags `-DGFS_PHYS=ON` or any other flag to the dynamical core.  This needs to be adjusted/added to the `FV3` section  of `CMakeLists.txt` directly.
