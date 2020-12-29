# ufs-tools
Tools for the Unified Forecast System

Steps:
1. Checkout the UFS repo, cd into it and load the modules
$> git clone https://github.com/ufs-community/ufs-weather-model
$> cd ufs-weather-model
$> git submodule update --init --recursive
$> module use $PWD/modulefiles/orion.intel
$> module load fv3

This is the directory for UFSsrc in step 4b.

2. Build the weather, coupled and data atmosphere executables
a. weather
$> BUILD_DIR=build-fv3 CCPP_SUITES="FV3_GFS_2017" ./build.sh 

b. coupled
$> BUILD_DIR=build-cpld CCPP_SUITES="FV3_GFS_2017_coupled,FV3_GFS_2017_satmedmf_coupled,FV3_GFS_v15p2_coupled" CMAKE_FLAGS="-DS2S=ON" ./build.sh

c. data atmosphere
BUILD_DIR=build-datm CMAKE_FLAGS="-DS2S=ON -DDATM=ON" ./build.sh

Once these executables are built, you can run the 3 tests we discussed.  

3. Checkout the repo containing the standalone driver scripts at the same level as the ufs weather model
$> cd ..
$> git clone https://github.com/aerorahul/ufs-tools -b run-ufs-standalone
$> cd ufs-tools

4. drive_run_ufs.sh is the only script you need to edit.  The following will need to be edited:
a. Comment/uncomment the TEST_NAME you wish to run the test for.
b. UFSsrc is the location of the ufs-weather-model cloned and built in step 1.
c. RUNDIR is the location where temporary run directories for each of the TEST_NAME will be created.

5. Note the number of NTASKS for each test varies  based on the test.
On Orion, you can request interactive jobs.  I suggest 280 tasks (data atmosphere needs these for some ungodly reason when the coupled only requires 192)
e.g.
$> salloc --partition=debug --qos=debug --account=da-cpu --nodes=7 --ntasks-per-node=40 --time=00:30:00 --chdir=$PWD --job-name=InteractiveJob

6. Run the tests, one by one.
$> ./drive_run_ufs.sh

For reference, you can see my runs on Orion at:
/work/noaa/da/rmahajan/work/UFS/standalone
