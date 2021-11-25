#!/bin/bash

set -eux

# Required environment variables
envars=()
envars+=("ROOTDIR")
envars+=("RUNDIR")
envars+=("NODES")
envars+=("NCPUS")
envars+=("NTHREADS")
envars+=("WRITE_GROUPS")
envars+=("WRITE_TASKS_PER_GROUP")
envars+=("LAYOUT_X")
envars+=("LAYOUT_Y")
envars+=("MAX_NCORES_PER_NODE")

# make sure required env vars exist
echeck ${envars[@]}

### D O  N O T  E D I T  B E L O W ###

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

cd $RUNDIR || exit 1

# Parse templated files to create final files
eparse() { ( set -eu; set +x; eval "set -eu; cat<<_EOF"$'\n'"$(< "$1")"$'\n'"_EOF"; ) }
eparse $ROOTDIR/parm/input.nml.tmpl       > input.nml
eparse $ROOTDIR/parm/model_configure.tmpl > model_configure
eparse $ROOTDIR/parm/nems.configure.tmpl  > nems.configure

# Load run-time modules
set +x
module use $( pwd -P )
module load modules.fv3gfs
module load cray-pals
module list
set -x

# Set run-time environment
export OMP_STACKSIZE=512M
export OMP_NUM_THREADS=$NTHREADS
export OMP_PLACES=cores
#export ESMF_RUNTIME_COMPLIANCECHECK=OFF:depth=4

echo "Model started:  " `date`
#mpiexec -n $NCORES -ppn $NCPUS -depth $NTHREADS ./global_fv3gfs.x
echo "Model ended:    " `date`
