#!/bin/bash

set -eux

# Required environment variables
envars=()
envars+=("MACHINE")
envars+=("CDATE")
envars+=("REPODIR")
envars+=("DATADIR")
envars+=("MAX_NCORES_PER_NODE")
envars+=("NODES")
envars+=("NCPUS")
envars+=("NTHREADS")
envars+=("WRITE_GROUPS")
envars+=("WRITE_TASKS_PER_GROUP")
envars+=("LAYOUT_X")
envars+=("LAYOUT_Y")

# make sure required env vars exist
echeck ${envars[@]}

### D O  N O T  E D I T  B E L O W ###

GDATE=$(date +%Y%m%d%H -d "${CDATE:0:8} ${CDATE:8:2} - 6 hours")
BDATE=$(date +%Y%m%d%H -d "${CDATE:0:8} ${CDATE:8:2} - 3 hours")

# Calculations based on User settings
NCORES=$((NODES*NCPUS))
NCORES_PER_NODE=$((NCPUS*NTHREADS))

# Do a quick compatibility check
[[ "$NCORES_PER_NODE" -gt "$MAX_NCORES_PER_NODE" ]] && ( echo "No. of cores per node ($NCORES_PER_NODE) exceeds maximum available ($MAX_NCORES_PER_NODE), ABORT!"; exit 1 )

# Calculate ATM and WAV PETs
ATM_PES=$((6*LAYOUT_X*LAYOUT_Y+WRITE_GROUPS*WRITE_TASKS_PER_GROUP))
WAV_PES=$((NCORES-ATM_PES))
ATM_PET_MIN=0
ATM_PET_MAX=$((ATM_PET_MIN+ATM_PES-1))
WAV_PET_MIN=$((ATM_PET_MAX+1))
WAV_PET_MAX=$((WAV_PET_MIN+WAV_PES-1))

cd $DATADIR || exit 1

# Parse templated files to create final files
eparse $REPODIR/parm/input.nml.tmpl       > input.nml
eparse $REPODIR/parm/model_configure.tmpl > model_configure
eparse $REPODIR/parm/nems.configure.tmpl  > nems.configure

# Parse machine specifiy job-card and run script
eparse $REPODIR/run/${MACHINE}.sh.tmpl > run.sh

exit 0
