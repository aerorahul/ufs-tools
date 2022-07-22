# Compile GFDL atmos cubed sphere dynamical core


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
- FMS: See `CMakeLists.txt`
- GFDL FV3 Dynamical Core [bugfix/fms_kind](https://github.com/aerorahul/GFDL_atmos_cubed_sphere/tree/bugfix/fms_kind)

## Notes:
- An update is required to the Dycore for finding the correct FMS library.branch `noaa-emc:feature/2020.04.03-private`
- The flags to the FV3dycore need to be examined closely.  There are dependencies on files in the CCPP, but we need to "stub" them somehow.  @climbfuji would know how.
