#!/bin/bash

# A simple driver script designed to run a UFS test

set -eux

# U S E R  C O N T R O L S
MACHINE_ID=orion.intel

TEST_NAME=fv3_control
#TEST_NAME=cpld_control
#TEST_NAME=datm_control_gefs

UFSsrc=/work/noaa/da/rmahajan/work/UFS/standalone/ufs-weather-model

RUNDIR=/work/noaa/da/rmahajan/work/UFS/standalone/stmp/${TEST_NAME}

# D O  N O T  E D I T  B E L O W

[[ "$TEST_NAME" = "fv3_control" ]] && UFSexe=$UFSsrc/build/$TEST_NAME/ufs_model
[[ "$TEST_NAME" = "cpld_control" ]] && UFSexe=$UFSsrc/build/$TEST_NAME/ufs_model
[[ "$TEST_NAME" = "datm_control_gefs" ]] && UFSexe=$UFSsrc/build/$TEST_NAME/ufs_model

# These tasks are specific to Orion. See default_vars.sh
[[ "$TEST_NAME" = "fv3_control" ]] && NTASKS=150
[[ "$TEST_NAME" = "cpld_control" ]] && NTASKS=192
[[ "$TEST_NAME" = "datm_control_gefs" ]] && NTASKS=256

APRUN="srun --label -n $NTASKS"

RT_COMPILER=$(echo $MACHINE_ID | cut -d. -f2)
RT_SUFFIX=""
RTPWD=/work/noaa/nems/emc.nemspara/RT/NEMSfv3gfs/develop-20210212/${RT_COMPILER^^}
INPUTDATA_ROOT=/work/noaa/nems/emc.nemspara/RT/NEMSfv3gfs/input-data-20210212
INPUTDATA_ROOT_WW3=${INPUTDATA_ROOT}/WW3_input_data_20201220

export MACHINE_ID
export TEST_NAME
export UFSsrc
export UFSexe
export APRUN
export RUNDIR
export RT_COMPILER # needed in stupid default_vars.sh
export RT_SUFFIX   # needed in stupid default_vars.sh
export RTPWD
export INPUTDATA_ROOT
export INPUTDATA_ROOT_WW3

[[ ! -f $UFSexe ]] && COMPILE_UFS="YES"
[[ ${COMPILE_UFS:-""} =~ [yYtT] ]] && ./compile_ufs.sh

./run_ufs.sh
rc=$?

exit 0
