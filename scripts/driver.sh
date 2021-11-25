#!/bin/bash

#PBS -j oe
#PBS -N fcst_210x12
#PBS -A GFS-DEV
#PBS -q dev
#PBS -l place=vscatter,select=210:ncpus=12:mpiprocs=12
#PBS -l walltime=01:00:00

set -eux

CDATE=2021110918
CDUMP=gfs
ROOTDIR="/lfs/h2/emc/eib/noscrub/Rahul.Mahajan/ufs-tools"
MODELDIR="/lfs/h2/emc/eib/noscrub/Rahul.Mahajan/UFS/fv3gfs.fd"

RUNDIR=${STMP:-"/lfs/h2/emc/stmp/$USER"}/opsfcst

FIXDIR="/lfs/h2/emc/global/noscrub/Kate.Friedman/glopara/FIX/fix_nco_gfsv16"

# DATADIR contains gdas.$CDATE and gfs.$CDATE
DATADIR=$ROOTDIR/data

MAX_NCORES_PER_NODE=128 # (WCOSS2: 128, WCOSS-Dell: 28)

NODES=210
NCPUS=12
NTHREADS=8
WRITE_GROUPS=8
WRITE_TASKS_PER_GROUP=48
LAYOUT_X=16
LAYOUT_Y=16

# Export any variables used by the scripts
export CDATE
export CDUMP
export ROOTDIR
export DATADIR
export MODELDIR
export RUNDIR
export FIXDIR
export MAX_NCORES_PER_NODE
export NODES
export NCPUS
export NTHREADS
export WRITE_GROUPS
export WRITE_TASKS_PER_GROUP
export LAYOUT_X
export LAYOUT_Y

### D O  N O T  E D I T ###

# USER FUNCTIONS
eparse() { ( set -eu; set +x; eval "set -eu; cat<<_EOF"$'\n'"$(< "$1")"$'\n'"_EOF"; ) }
echeck() {
  (
    envars=($@)
    set +ux
    for vv in ${envars[@]}; do
      if [[ -z "${!vv}" ]]; then
        echo "ERROR: env var $vv is not set."; exit 1
      fi
      printf "%-25s %s\n" " $vv " "${!vv}"
    done
  )
}

export -f eparse
export -f echeck

$ROOTDIR/scripts/setup_model.sh
$ROOTDIR/scripts/configure_run.sh
