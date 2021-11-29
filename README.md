### `parm/`
`input.nml.tmpl`, `model_configure.tmpl`, `nems.configure.tmpl` and `diag_table.tmpl` are templated from their respective files obtained from the operational GFS forecast run directories.
The templating is solely on the resource usage e.g. No. of ATM and WAV PETs in `nems.configure`, layout for the FV3 dycore in `input.nml` and write component attributes in `model_configure`.
There has been no change in the "science" aspects of the configuration.
The other files in `parm/` directory are copied from `global-workflow` to decouple dependency on it.  They are the exact copies when compared with the operational GFS forecast run directory.

### `scripts/`
`scripts/` contain the scripts to drive (`driver.sh`) the setup (`setup.sh`) and configure (`configure.sh`) the run.  The `setup.sh` script sets up the run directory by linking the initial conditions and the fix files.  The `configure.sh` script configures the runtime parameters such as `NODES`, `THREADS` etc. and creates the actual files from the templates in `parm/` directory.  It also will set up the `run.sh` script by configuring the job card from `run/` appropriate for the `machine`.  The `driver.sh` script controls the adjustable parameters and calls the other scripts.  It also contains a couple of useful user functions used in the other scripts.

### `run/`
`run/` contains scheduling templates and MPI execution statement for the model.  Current templates are for `wcoss_dell_p3` and `wcoss2`
