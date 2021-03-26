#!/bin/bash

# run a UFS case

set -eux

MACHINE_ID=${MACHINE_ID:-?}
UFSsrc=${UFSsrc:-?}
TEST_NAME=${TEST_NAME:-fv3_control}
APRUN=${APRUN:-mpirun}
RUNDIR=${RUNDIR:-/tmp/$TEST_NAME}
UFSexe=${UFSexe:-ufs_model}

# Templates and sources from $UFSsrc
source $UFSsrc/tests/default_vars.sh
source $UFSsrc/tests/tests/$TEST_NAME
source $UFSsrc/tests/atparse.bash
source $UFSsrc/tests/edit_inputs.sh

#export INPUT_DIR=${CNTL_DIR}
INPUT_DIR=${CNTL_DIR}

# create and cd into RUNDIR
[[ -d $RUNDIR ]] && rm -rf $RUNDIR
mkdir -p $RUNDIR && cd $RUNDIR

####################################
# Make configure and run files
####################################

echo "parsing ... $UFSsrc/tests/fv3_conf/${FV3_RUN:-fv3_run.IN} > fv3_run"
atparse < $UFSsrc/tests/fv3_conf/${FV3_RUN:-fv3_run.IN} > fv3_run
echo "parsing ... $UFSsrc/tests/parm/${INPUT_NML:-input.nml.IN} > input.nml"
atparse < $UFSsrc/tests/parm/${INPUT_NML:-input.nml.IN} > input.nml
echo "parsing ... $UFSsrc/tests/parm/${MODEL_CONFIGURE:-model_configure.IN} > model_configure"
atparse < $UFSsrc/tests/parm/${MODEL_CONFIGURE:-model_configure.IN} > model_configure
echo "parsing ... $UFSsrc/tests/parm/${NEMS_CONFIGURE:-nems.configure} > nems.configure"
atparse < $UFSsrc/tests/parm/${NEMS_CONFIGURE:-nems.configure} > nems.configure

source ./fv3_run

if [[ $DATM = 'true' ]] || [[ $S2S = 'true' ]]; then
  edit_ice_in     < $UFSsrc/tests/parm/ice_in_template > ice_in
  edit_mom_input  < $UFSsrc/tests/parm/${MOM_INPUT:-MOM_input_template_$OCNRES} > INPUT/MOM_input
  edit_diag_table < $UFSsrc/tests/parm/diag_table_template > diag_table
  edit_data_table < $UFSsrc/tests/parm/data_table_template > data_table
  # CMEPS
  cp $UFSsrc/tests/parm/fd_nems.yaml fd_nems.yaml
  cp $UFSsrc/tests/parm/pio_in pio_in
  cp $UFSsrc/tests/parm/med_modelio.nml med_modelio.nml
fi
if [[ $DATM = 'true' ]]; then
  cp $UFSsrc/tests/parm/datm_data_table.IN datm_data_table
fi

set +x
module use $UFSsrc/modulefiles/$MACHINE_ID
module load fv3
module list
set -x

ulimit -s unlimited
export OMP_STACKSIZE=512M
export KMP_AFFINITY=scatter
export OMP_NUM_THREADS=${OMP_NUM_THREADS:-1}

# Copy over the UFS executable
echo "Copying UFS executable from $UFSexe"
[[ -f $UFSexe ]] && cp $UFSexe ./ufs_model || false

$APRUN ./ufs_model 2>&1 | tee out
rc=$?

exit $rc
