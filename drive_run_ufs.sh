#!/bin/bash

# A simple driver script designed to run a UFS test

set -eux

MACHINE_ID=orion.intel

TEST_NAME=fv3_ccpp_control
#TEST_NAME=cpld_control
#TEST_NAME=datm_control_gefs

UFSsrc=/work/noaa/marine/Jian.Kuang/ufs-weather-model

[[ "$TEST_NAME" = "fv3_ccpp_control" ]] && UFSexe=$UFSsrc/build-fv3/ufs_model
[[ "$TEST_NAME" = "cpld_control" ]] && UFSexe=$UFSsrc/build-cpld/ufs_model
[[ "$TEST_NAME" = "datm_control_gefs" ]] && UFSexe=$UFSsrc/build-datm/ufs_model

# These tasks are specific to Orion. See default_vars.sh
[[ "$TEST_NAME" = "fv3_ccpp_control" ]] && NTASKS=150
[[ "$TEST_NAME" = "cpld_control" ]] && NTASKS=192
[[ "$TEST_NAME" = "datm_control_gefs" ]] && NTASKS=256

APRUN="srun --label -n $NTASKS"

RUNDIR=/work/noaa/marine/Jian.Kuang/dataroot/$TEST_NAME

# These directories are Orion-specific
RT_COMPILER=$(echo $MACHINE_ID | cut -d. -f2)
RTPWD=/work/noaa/nems/emc.nemspara/RT/NEMSfv3gfs/develop-20201112/${RT_COMPILER^^}
INPUTDATA_ROOT=/work/noaa/nems/emc.nemspara/RT/NEMSfv3gfs/input-data-20201220/
# !These directories are Orion-specific

set +x
module use $UFSsrc/modulefiles/$MACHINE_ID
module load fv3
module list
set -x

export MACHINE_ID
export TEST_NAME
export UFSsrc
export UFSexe
export APRUN
export RUNDIR
export RT_COMPILER # needed in stupid default_vars.sh
export RTPWD
export INPUTDATA_ROOT

./run_ufs.sh
