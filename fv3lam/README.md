# fv3lam
Reading FV3-LAM restart files in a stand-alone manner.

## Prerequites
- GNU/Intel
- OpenMPI/MPICH
- netCDF4
- FMS

### Installing FMS
This uses a cmake build of FMS.  The branch below is under review at GFDL and will be merged in the master.
```
git clone https://github.com/aerorahul/fms -b bugfix/cmake fms_src
FMS_INSTALL=$PWD/fms_install
mkdir fms_build && cd fms_build
CC=mpiicc FC=mpiifort cmake -DCMAKE_INSTALL_PREFIX=$FMS_INSTALL -DGFS_PHYS=ON ../fms_src
make -j8
make install
```

### Building fv3lam
```
git clone https://github.com/aerorahul/ufs-tools -b regionalIO fv3lam_src
mkdir build && cd build
CC=mpiicc FC=mpiifort cmake -DCMAKE_PREFIX_PATH=$FMS_INSTALL ..
make -j4
ls -l ./read_fv3lam.x
```

### Testing fv3lam
There is an `input.nml` in each of `test1x1` and `test2x2` directories.
Each of those directories are identical and only differ in the `io_layout`.
Copy/link the files in the `INPUT` directory and the exectuable generated above in each of the test directories.  The contents will look like the following:

```
$> tree -L 2 test1x1
test1x1
├── INPUT
│   ├── C96_grid.tile7.nc
│   ├── grid_spec.nc
│   ├── coupler.res
│   ├── fv_core.res.nc
│   ├── fv_core.res.tile1.nc
│   ├── fv_srf_wnd.res.tile1.nc
│   ├── fv_tracer.res.tile1.nc
│   ├── phy_data.nc
│   └── sfc_data.nc
├── input.nml
└── read_fv3lam.x
```
and
```
$> tree -L 2 test2x2
test2x2
├── INPUT
│   ├── C96_grid.tile7.nc
│   ├── grid_spec.nc
│   ├── coupler.res
│   ├── fv_core.res.nc
│   ├── fv_core.res.tile1.nc.0000
│   ├── fv_core.res.tile1.nc.0001
│   ├── fv_core.res.tile1.nc.0002
│   ├── fv_core.res.tile1.nc.0003
│   ├── fv_srf_wnd.res.tile1.nc.0000
│   ├── fv_srf_wnd.res.tile1.nc.0001
│   ├── fv_srf_wnd.res.tile1.nc.0002
│   ├── fv_srf_wnd.res.tile1.nc.0003
│   ├── fv_tracer.res.tile1.nc.0000
│   ├── fv_tracer.res.tile1.nc.0001
│   ├── fv_tracer.res.tile1.nc.0002
│   ├── fv_tracer.res.tile1.nc.0003
│   ├── phy_data.nc.0000
│   ├── phy_data.nc.0001
│   ├── phy_data.nc.0002
│   ├── phy_data.nc.0003
│   ├── sfc_data.nc.0000
│   ├── sfc_data.nc.0001
│   ├── sfc_data.nc.0002
│   └── sfc_data.nc.0003
├── input.nml
└── read_fv3lam.x
```

To test `test1x1`: `cd test1x1; mpirun -np 1 ./read_fv3lam.x`
To test `test2x2`: `cd test2x2; mpirun -np 4 ./read_fv3lam.x`
