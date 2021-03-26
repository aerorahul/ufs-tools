#!/bin/bash

# A compile script based on test name

set -eux

MACHINE_ID=${MACHINE_ID:-?}
UFSsrc=${UFSsrc:-?}
TEST_NAME=${TEST_NAME:-fv3_control}

# D O  N O T  E D I T  B E L O W

cd $UFSsrc || false

set +x
module use $UFSsrc/modulefiles/$MACHINE_ID
module load fv3
module list
set -x

if [[ "$TEST_NAME" = "fv3_control" ]]; then
  CMAKE_OPTS="-DAPP=ATM"
  SUITES="FV3_GFS_2017"
elif [[ "$TEST_NAME" = "cpld_control" ]]; then
  CMAKE_OPTS="-DAPP=S2S"
  SUITES="FV3_GFS_2017_coupled,FV3_GFS_2017_satmedmf_coupled,FV3_GFS_v15p2_coupled,FV3_GFS_v16_coupled"
elif [[ "$TEST_NAME" = "datm_control_gefs" ]]; then
  CMAKE_OPTS="-DAPP=DATM_NEMS"
  SUITES=""
fi

export BUILD_DIR="build/$TEST_NAME"
export BUILD_VERBOSE=YES
export BUILD_JOBS=8

[[ -d $BUILD_DIR ]] && rm -rf $BUILD_DIR

CMAKE_FLAGS=$CMAKE_OPTS CCPP_SUITES=$SUITES ./build.sh
rc=$?

exit $rc
