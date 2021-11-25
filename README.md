###`parm/`
`input.nml.tmpl`, `model_configure.tmpl`, `nems.configure.tmpl` and `diag_table.tmpl` are templated from their respective files obtained from the operational GFS forecast run directories.
The templating is solely on the resource usage e.g. No. of ATM and WAV PETs in `nems.configure`, layout for the FV3 dycore in `input.nml` and write component attributes in `model_configure`.
There has been no change in the "science" aspects of the configuration.
The other files in `parm/` directory are copied from `global-workflow` to decouple dependency on it.  They are the exact copies when compared with the operational GFS forecast run directory.

###`scripts/`
`scripts/` contain the scripts to drive `driver.sh` the setup `setup_model.sh`.  This script sets up the run directory by linking the initial conditions and the fix files.  The `configure_run.sh` script configures the runtime parameters such as `NODES`, `THREADS` etc. and creates the actual files from the templates in `parm/` directory.  It also will execute the model.  The `driver.sh` script controls the adjustable parameters and calls the other scripts.

###`data/`
`data/` contains the initial conditions for the GFS forecast initialized on `20211109 18z`.  The script `scripts/get_data.sh` can be used to download this data from HPSS.
This directory and its contents are ignored in git.
