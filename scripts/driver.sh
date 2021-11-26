#!/bin/bash

set -eux

CDATE=2021110918
CDUMP=gfs

MACHINE="wcoss_dell_p3"
#MACHINE="wcoss2"

if [[ $MACHINE = "wcoss2" ]]; then
  basedir=/lfs/h2/emc/eib/noscrub/Rahul.Mahajan/GFSForecast
  tmpdir=/lfs/h2/emc/stmp/$USER
  FIXDIR=/lfs/h2/emc/global/noscrub/Kate.Friedman/glopara/FIX/fix_nco_gfsv16
  MAX_NCORES_PER_NODE=128
elif [[ $MACHINE = "wcoss_dell_p3" ]]; then
  basedir=/gpfs/dell2/emc/modeling/noscrub/Rahul.Mahajan/GFSForecast
  tmpdir=/gpfs/dell2/stmp/$USER
  FIXDIR=/gpfs/dell2/emc/modeling/noscrub/emc.glopara/git/fv3gfs/fix_nco_gfsv16
  MAX_NCORES_PER_NODE=28
fi

REPODIR=$basedir/ufs-tools
MODELDIR=$basedir/ufs-weather-model
ICDIR=$basedir/data
DATADIR=$tmpdir/opsfcst

NODES=606
NCPUS=4
NTHREADS=7
WRITE_GROUPS=8
WRITE_TASKS_PER_GROUP=56
LAYOUT_X=16
LAYOUT_Y=16

# Export any variables used by the scripts
export MACHINE
export CDATE
export CDUMP
export REPODIR
export MODELDIR
export ICDIR
export DATADIR
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

$REPODIR/scripts/setup_model.sh
$REPODIR/scripts/configure.sh

if [[ $MACHINE = "wcoss2" ]]; then
  qsub   $DATADIR/run.sh
elif [[ $MACHINE = "wcoss_dell_p3" ]]; then
  bsub < $DATADIR/run.sh
fi
