#!/bin/bash

# A simple driver script designed to run a UFS test

set -eux

# U S E R  C O N T R O L S
MACHINE_ID=orion.intel

#TEST_NAME=fv3_ccpp_control
#TEST_NAME=cpld_control
TEST_NAME=datm_control_gefs

UFSsrc=/work/noaa/da/rmahajan/work/UFS/standalone/ufs-weather-model

RUNDIR=/work/noaa/da/rmahajan/work/UFS/standalone/stmp/${TEST_NAME}-stage

# D O  N O T  E D I T

[[ "$TEST_NAME" = "fv3_ccpp_control" ]] && UFSexe=$UFSsrc/build-fv3/ufs_model
[[ "$TEST_NAME" = "cpld_control" ]] && UFSexe=$UFSsrc/build-cpld/ufs_model
[[ "$TEST_NAME" = "datm_control_gefs" ]] && UFSexe=$UFSsrc/build-datm/ufs_model

# These tasks are specific to Orion. See default_vars.sh
[[ "$TEST_NAME" = "fv3_ccpp_control" ]] && NTASKS=150
[[ "$TEST_NAME" = "cpld_control" ]] && NTASKS=192
[[ "$TEST_NAME" = "datm_control_gefs" ]] && NTASKS=256

APRUN="srun --label -n $NTASKS"

RT_COMPILER=$(echo $MACHINE_ID | cut -d. -f2)
RTPWD=/work/noaa/nems/emc.nemspara/RT/NEMSfv3gfs/develop-20201220/${RT_COMPILER^^}
INPUTDATA_ROOT=/work/noaa/nems/emc.nemspara/RT/NEMSfv3gfs/input-data-20201220

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
