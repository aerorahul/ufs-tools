#!/bin/bash

set -eux

# Required environment variables
envars=()
envars+=("CDATE")
envars+=("CDUMP")
envars+=("ICDIR")

# make sure required env vars exist
echeck ${envars[@]}

### D O  N O T  E D I T  B E L O W ###
# Compute dates of previous cycle (-6h) and beginning of the current cycle (-3h)
GDATE=$(date +%Y%m%d%H -d "${CDATE:0:8} ${CDATE:8:2} - 6 hours")
BDATE=$(date +%Y%m%d%H -d "${CDATE:0:8} ${CDATE:8:2} - 3 hours")

# cd into the directory
mkdir -p $ICDIR && cd $ICDIR

# GDAS atm restarts
tarball="/NCEPPROD/hpssprod/runhistory/rh${GDATE:0:4}/${GDATE:0:6}/${GDATE:0:8}/com_gfs_prod_gdas.${GDATE:0:8}_${GDATE:8:2}.gdas_restart.tar"
rm -f gdas_filelist.txt
cat >> gdas_filelist.txt << _EOF
./gdas.${GDATE:0:8}/${GDATE:8:2}/atmos/RESTART/${BDATE:0:8}.${BDATE:8:2}0000.fv_core.res.nc
./gdas.${GDATE:0:8}/${GDATE:8:2}/atmos/RESTART/${BDATE:0:8}.${BDATE:8:2}0000.fv_core.res.tile1.nc
./gdas.${GDATE:0:8}/${GDATE:8:2}/atmos/RESTART/${BDATE:0:8}.${BDATE:8:2}0000.fv_core.res.tile2.nc
./gdas.${GDATE:0:8}/${GDATE:8:2}/atmos/RESTART/${BDATE:0:8}.${BDATE:8:2}0000.fv_core.res.tile3.nc
./gdas.${GDATE:0:8}/${GDATE:8:2}/atmos/RESTART/${BDATE:0:8}.${BDATE:8:2}0000.fv_core.res.tile4.nc
./gdas.${GDATE:0:8}/${GDATE:8:2}/atmos/RESTART/${BDATE:0:8}.${BDATE:8:2}0000.fv_core.res.tile5.nc
./gdas.${GDATE:0:8}/${GDATE:8:2}/atmos/RESTART/${BDATE:0:8}.${BDATE:8:2}0000.fv_core.res.tile6.nc
./gdas.${GDATE:0:8}/${GDATE:8:2}/atmos/RESTART/${BDATE:0:8}.${BDATE:8:2}0000.fv_srf_wnd.res.tile1.nc
./gdas.${GDATE:0:8}/${GDATE:8:2}/atmos/RESTART/${BDATE:0:8}.${BDATE:8:2}0000.fv_srf_wnd.res.tile2.nc
./gdas.${GDATE:0:8}/${GDATE:8:2}/atmos/RESTART/${BDATE:0:8}.${BDATE:8:2}0000.fv_srf_wnd.res.tile3.nc
./gdas.${GDATE:0:8}/${GDATE:8:2}/atmos/RESTART/${BDATE:0:8}.${BDATE:8:2}0000.fv_srf_wnd.res.tile4.nc
./gdas.${GDATE:0:8}/${GDATE:8:2}/atmos/RESTART/${BDATE:0:8}.${BDATE:8:2}0000.fv_srf_wnd.res.tile5.nc
./gdas.${GDATE:0:8}/${GDATE:8:2}/atmos/RESTART/${BDATE:0:8}.${BDATE:8:2}0000.fv_srf_wnd.res.tile6.nc
./gdas.${GDATE:0:8}/${GDATE:8:2}/atmos/RESTART/${BDATE:0:8}.${BDATE:8:2}0000.fv_tracer.res.tile1.nc
./gdas.${GDATE:0:8}/${GDATE:8:2}/atmos/RESTART/${BDATE:0:8}.${BDATE:8:2}0000.fv_tracer.res.tile2.nc
./gdas.${GDATE:0:8}/${GDATE:8:2}/atmos/RESTART/${BDATE:0:8}.${BDATE:8:2}0000.fv_tracer.res.tile3.nc
./gdas.${GDATE:0:8}/${GDATE:8:2}/atmos/RESTART/${BDATE:0:8}.${BDATE:8:2}0000.fv_tracer.res.tile4.nc
./gdas.${GDATE:0:8}/${GDATE:8:2}/atmos/RESTART/${BDATE:0:8}.${BDATE:8:2}0000.fv_tracer.res.tile5.nc
./gdas.${GDATE:0:8}/${GDATE:8:2}/atmos/RESTART/${BDATE:0:8}.${BDATE:8:2}0000.fv_tracer.res.tile6.nc
./gdas.${GDATE:0:8}/${GDATE:8:2}/atmos/RESTART/${BDATE:0:8}.${BDATE:8:2}0000.phy_data.tile1.nc
./gdas.${GDATE:0:8}/${GDATE:8:2}/atmos/RESTART/${BDATE:0:8}.${BDATE:8:2}0000.phy_data.tile2.nc
./gdas.${GDATE:0:8}/${GDATE:8:2}/atmos/RESTART/${BDATE:0:8}.${BDATE:8:2}0000.phy_data.tile3.nc
./gdas.${GDATE:0:8}/${GDATE:8:2}/atmos/RESTART/${BDATE:0:8}.${BDATE:8:2}0000.phy_data.tile4.nc
./gdas.${GDATE:0:8}/${GDATE:8:2}/atmos/RESTART/${BDATE:0:8}.${BDATE:8:2}0000.phy_data.tile5.nc
./gdas.${GDATE:0:8}/${GDATE:8:2}/atmos/RESTART/${BDATE:0:8}.${BDATE:8:2}0000.phy_data.tile6.nc
_EOF
htar -xvf $tarball -T 4 -L gdas_filelist.txt

# atm increments and surface analysis
tarball="/NCEPPROD/hpssprod/runhistory/rh${CDATE:0:4}/${CDATE:0:6}/${CDATE:0:8}/com_gfs_prod_${CDUMP}.${CDATE:0:8}_${CDATE:8:2}.${CDUMP}_restart.tar"
rm -f sfc_filelist.txt
cat >> sfc_filelist.txt << _EOF
./${CDUMP}.${CDATE:0:8}/${CDATE:8:2}/atmos/${CDUMP}.t${CDATE:8:2}z.atmi003.nc
./${CDUMP}.${CDATE:0:8}/${CDATE:8:2}/atmos/${CDUMP}.t${CDATE:8:2}z.atmi009.nc
./${CDUMP}.${CDATE:0:8}/${CDATE:8:2}/atmos/${CDUMP}.t${CDATE:8:2}z.atminc.nc
./${CDUMP}.${CDATE:0:8}/${CDATE:8:2}/atmos/RESTART/${BDATE:0:8}.${BDATE:8:2}0000.sfcanl_data.tile1.nc
./${CDUMP}.${CDATE:0:8}/${CDATE:8:2}/atmos/RESTART/${BDATE:0:8}.${BDATE:8:2}0000.sfcanl_data.tile2.nc
./${CDUMP}.${CDATE:0:8}/${CDATE:8:2}/atmos/RESTART/${BDATE:0:8}.${BDATE:8:2}0000.sfcanl_data.tile3.nc
./${CDUMP}.${CDATE:0:8}/${CDATE:8:2}/atmos/RESTART/${BDATE:0:8}.${BDATE:8:2}0000.sfcanl_data.tile4.nc
./${CDUMP}.${CDATE:0:8}/${CDATE:8:2}/atmos/RESTART/${BDATE:0:8}.${BDATE:8:2}0000.sfcanl_data.tile5.nc
./${CDUMP}.${CDATE:0:8}/${CDATE:8:2}/atmos/RESTART/${BDATE:0:8}.${BDATE:8:2}0000.sfcanl_data.tile6.nc
_EOF
htar -xvf $tarball -T 4 -L sfc_filelist.txt

# WW3 ICs
tarball="/NCEPPROD/hpssprod/runhistory/rh${CDATE:0:4}/${CDATE:0:6}/${CDATE:0:8}/com_gfs_prod_${CDUMP}.${CDATE:0:8}_${CDATE:8:2}.${CDUMP}wave_raw.tar"
rm -f  ${CDUMP}wave_filelist.txt
cat >> ${CDUMP}wave_filelist.txt << _EOF
./${CDUMP}.${CDATE:0:8}/${CDATE:8:2}/wave/rundata/${CDUMP}wave.glix_10m.t${CDATE:8:2}z.cur
./${CDUMP}.${CDATE:0:8}/${CDATE:8:2}/wave/rundata/${CDUMP}wave.glix_10m.t${CDATE:8:2}z.ice
./${CDUMP}.${CDATE:0:8}/${CDATE:8:2}/wave/rundata/${CDUMP}wave.mod_def.aoc_9km
./${CDUMP}.${CDATE:0:8}/${CDATE:8:2}/wave/rundata/${CDUMP}wave.mod_def.at_10m
./${CDUMP}.${CDATE:0:8}/${CDATE:8:2}/wave/rundata/${CDUMP}wave.mod_def.ep_10m
./${CDUMP}.${CDATE:0:8}/${CDATE:8:2}/wave/rundata/${CDUMP}wave.mod_def.glix_10m
./${CDUMP}.${CDATE:0:8}/${CDATE:8:2}/wave/rundata/${CDUMP}wave.mod_def.glo_15mxt
./${CDUMP}.${CDATE:0:8}/${CDATE:8:2}/wave/rundata/${CDUMP}wave.mod_def.glo_30m
./${CDUMP}.${CDATE:0:8}/${CDATE:8:2}/wave/rundata/${CDUMP}wave.mod_def.glox_10m
./${CDUMP}.${CDATE:0:8}/${CDATE:8:2}/wave/rundata/${CDUMP}wave.mod_def.gnh_10m
./${CDUMP}.${CDATE:0:8}/${CDATE:8:2}/wave/rundata/${CDUMP}wave.mod_def.gsh_15m
./${CDUMP}.${CDATE:0:8}/${CDATE:8:2}/wave/rundata/${CDUMP}wave.mod_def.points
./${CDUMP}.${CDATE:0:8}/${CDATE:8:2}/wave/rundata/${CDUMP}wave.mod_def.wc_10m
./${CDUMP}.${CDATE:0:8}/${CDATE:8:2}/wave/rundata/ww3_multi.${CDUMP}wave.t${CDATE:8:2}z.inp
_EOF
htar -xvf $tarball -T 4 -L ${CDUMP}wave_filelist.txt

rm -f *_filelist.txt
