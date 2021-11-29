#!/bin/bash

set -eux

# Required environment variables
envars=()
envars+=("CDATE")
envars+=("CDUMP")
envars+=("REPODIR")
envars+=("ICDIR")
envars+=("MODELDIR")
envars+=("DATADIR")
envars+=("FIXDIR")

# make sure required env vars exist
echeck ${envars[@]}

### D O  N O T  E D I T  B E L O W ###

GDATE=$(date +%Y%m%d%H -d "${CDATE:0:8} ${CDATE:8:2} - 6 hours")
BDATE=$(date +%Y%m%d%H -d "${CDATE:0:8} ${CDATE:8:2} - 3 hours")

[[ -d $DATADIR ]] && rm -rf $DATADIR
mkdir -p $DATADIR && cd $DATADIR

# Create INPUT and RESTART directories
mkdir -p INPUT RESTART

# Link static FV3 data into INPUT
ln -sf $FIXDIR/fix_fv3/C768/C768_mosaic.nc INPUT/grid_spec.nc
for tt in $(seq 1 6); do
  ln -sf $FIXDIR/fix_fv3/C768/C768_grid.tile${tt}.nc INPUT/
  ln -sf $FIXDIR/fix_fv3/C768/C768_oro_data.tile${tt}.nc INPUT/oro_data.tile${tt}.nc
done

# Link static atm data into DATADIR
ln -sf $FIXDIR/fix_am/global_climaeropac_global.txt aerosol.dat
ln -sf $FIXDIR/fix_am/fix_co2_proj/global_co2historicaldata_*.txt .
ln -sf $FIXDIR/fix_am/global_co2historicaldata_glob.txt .
ln -sf $FIXDIR/fix_am/co2monthlycyc.txt
ln -sf $FIXDIR/fix_am/global_volcanic_aerosols_*.txt .
ln -sf $FIXDIR/fix_am/global_h2o_pltc.f77 global_h2oprdlos.f77
ln -sf $FIXDIR/fix_am/ozprdlos_2015_new_sbuvO3_tclm15_nuchem.f77 global_o3prdlos.f77
ln -sf $FIXDIR/fix_am/global_sfc_emissivity_idx.txt sfc_emissivity_idx.txt
ln -sf $FIXDIR/fix_am/global_solarconstant_noaa_an.txt solarconstant_noaa_an.txt

# Rename static atm data per model requirements
rename global_co2historicaldata co2historicaldata global_co2historicaldata_*.txt
rename global_volcanic_aerosols volcanic_aerosols global_volcanic_aerosols_*.txt

# Link static waves data into DATADIR
ln -sf $FIXDIR/fix_wave_gfs/rmp_src_to_dst_conserv_00[2-3]_001.nc .

# Link inline post data into DATADIR
ln -sf $REPODIR/parm/postxconfig-NT-GFS-F00-TWO.txt postxconfig-NT_FH00.txt
ln -sf $REPODIR/parm/postxconfig-NT-GFS-TWO.txt     postxconfig-NT.txt
ln -sf $REPODIR/parm/params_grib2_tbl_new           params_grib2_tbl_new
ln -sf $REPODIR/parm/post_tag_gfs128                itag

# Link FV3 dycore tables into DATADIR
ln -sf $REPODIR/parm/data_table        .
ln -sf $REPODIR/parm/field_table       .
eparse $REPODIR/parm/diag_table.tmpl > diag_table

# Link INPUT data
ln -sf $ICDIR/gdas.${GDATE:0:8}/${GDATE:8:2}/atmos/RESTART/*      INPUT/
ln -sf $ICDIR/${CDUMP}.${CDATE:0:8}/${CDATE:8:2}/atmos/RESTART/*  INPUT/
ln -sf $ICDIR/${CDUMP}.${CDATE:0:8}/${CDATE:8:2}/atmos/${CDUMP}.t${CDATE:8:2}z.atmi*.nc INPUT/
ln -sf $ICDIR/${CDUMP}.${CDATE:0:8}/${CDATE:8:2}/wave/rundata/*   .

# rename/move atm IC data per model requirements
rename "${BDATE:0:8}.${BDATE:8:2}0000." "" INPUT/${BDATE:0:8}.${BDATE:8:2}0000.*
rename sfcanl_data sfc_data INPUT/*sfcanl_data*
mv INPUT/${CDUMP}.t${CDATE:8:2}z.atmi003.nc INPUT/fv_increment3.nc
mv INPUT/${CDUMP}.t${CDATE:8:2}z.atminc.nc  INPUT/fv_increment6.nc
mv INPUT/${CDUMP}.t${CDATE:8:2}z.atmi009.nc INPUT/fv_increment9.nc

# INPUT/coupler.res needs to be replaced with correct start time
rm -f INPUT/coupler.res
cat >> INPUT/coupler.res << _EOF
     2        (Calendar: no_calendar=0, thirty_day_months=1, julian=2, gregorian=3, noleap=4)
  ${GDATE:0:4}    ${GDATE:4:2}    ${GDATE:6:2}    ${GDATE:8:2}     0     0        Model start time:   year, month, day, hour, minute, second
  ${BDATE:0:4}    ${BDATE:4:2}    ${BDATE:6:2}    ${BDATE:8:2}     0     0        Current model time: year, month, day, hour, minute, second
_EOF

# rename/move wave IC data per model requirements
rename "${CDUMP}wave.mod_def" "mod_def" ${CDUMP}wave.*
mv  ${CDUMP}wave.glix_10m.t${CDATE:8:2}z.cur current.glix_10m
mv  ${CDUMP}wave.glix_10m.t${CDATE:8:2}z.ice ice.glix_10m
mv ww3_multi.${CDUMP}wave.t${CDATE:8:2}z.inp ww3_multi.inp

# Copy executable and modules
cp $MODELDIR/tests/fv3_1.exe     ./global_fv3gfs.x
cp $MODELDIR/tests/modules.fv3_1 ./modules.fv3gfs

echo "model setup in: $DATADIR"
