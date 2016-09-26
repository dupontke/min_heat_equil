#!/bin/bash 
#SBATCH --job-name=3evg_gtp_sah.min_heat_equil
#SBATCH --output=3evg_gtp_sah.min_heat_equil.err 
#SBATCH --time=48:00:00 
#SBATCH --nodes=1
#SBATCH --partition=mccullagh-gpu
#SBATCH --gres=gpu:titan:1
#SBATCH --mail-type=END 
#SBATCH --mail-user=dupontke@colostate.edu
#
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/software/usr/gcc-4.9.2/lib64"
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/software/usr/hpcx-v1.2.0-292-gcc-MLNX_OFED_LINUX-2.4-1.0.0-redhat6.6/ompi-mellanox-v1.8/lib"
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/usr/local/cuda-7.5/lib64"
export AMBERHOME="/mnt/lustre_fs/users/mjmcc/apps/amber16"
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$AMBERHOME/lib"
#
MFP=3evg_gtp_sah

echo "Start minimization with pinned peptides:"
mkdir min.1
cd min.1
time $AMBERHOME/bin/pmemd.cuda -O -i ../$MFP.min1.in   -o $MFP.min1.log   -p ../../3evg_gtp_sah.prmtop -c ../../3evg_gtp_sah.inpcrd  -r $MFP.min1.rst   -x $MFP.min1.ncdf   -inf $MFP.min1.inf   -ref ../../3evg_gtp_sah.inpcrd
cd ../

echo "Start minimization with free peptides:"
mkdir min.2
cd min.2
time $AMBERHOME/bin/pmemd.cuda -O -i ../$MFP.min2.in   -o $MFP.min2.log   -p ../../3evg_gtp_sah.prmtop -c ../min.1/$MFP.min1.rst     -r $MFP.min2.rst   -x $MFP.min2.ncdf  -inf $MFP.min2.inf   -ref ../min.1/$MFP.min1.rst
cd ../

echo "Start heating:"
mkdir heating
cd heating
time $AMBERHOME/bin/pmemd.cuda -O -i ../$MFP.heat.in   -o $MFP.heat.log   -p ../../3evg_gtp_sah.prmtop -c ../min.2/$MFP.min2.rst     -r $MFP.heat.rst   -x $MFP.heat.ncdf   -inf $MFP.heat.inf   -ref ../min.2/$MFP.min2.rst
cd ../

echo "Start volume equilibration with pinned peptide (4 of them):"
mkdir equil.1
cd equil.1
time $AMBERHOME/bin/pmemd.cuda -O -i ../$MFP.equil1.in -o $MFP.equil1.log -p ../../3evg_gtp_sah.prmtop -c ../heating/$MFP.heat.rst   -r $MFP.equil1.rst -x $MFP.equil1.ncdf -inf $MFP.equil1.inf -ref ../heating/$MFP.heat.rst
cd ../

mkdir equil.2
cd equil.2
time $AMBERHOME/bin/pmemd.cuda -O -i ../$MFP.equil1.in -o $MFP.equil2.log -p ../../3evg_gtp_sah.prmtop -c ../equil.1/$MFP.equil1.rst -r $MFP.equil2.rst -x $MFP.equil2.ncdf -inf $MFP.equil2.inf -ref ../equil.1/$MFP.equil1.rst
cd ../

mkdir equil.3
cd equil.3
time $AMBERHOME/bin/pmemd.cuda -O -i ../$MFP.equil1.in -o $MFP.equil3.log -p ../../3evg_gtp_sah.prmtop -c ../equil.2/$MFP.equil2.rst -r $MFP.equil3.rst -x $MFP.equil3.ncdf -inf $MFP.equil3.inf -ref ../equil.2/$MFP.equil2.rst
cd ../

mkdir equil.4
cd equil.4
time $AMBERHOME/bin/pmemd.cuda -O -i ../$MFP.equil1.in -o $MFP.equil4.log -p ../../3evg_gtp_sah.prmtop -c ../equil.3/$MFP.equil3.rst -r $MFP.equil4.rst -x $MFP.equil4.ncdf -inf $MFP.equil4.inf -ref ../equil.3/$MFP.equil3.rst
cd ../

echo "Complete equilibration:"
mkdir equil.5
cd equil.5
time $AMBERHOME/bin/pmemd.cuda -O -i ../$MFP.equil2.in -o $MFP.equil5.log -p ../../3evg_gtp_sah.prmtop -c ../equil.4/$MFP.equil4.rst -r $MFP.equil5.rst -x $MFP.equil5.ncdf -inf $MFP.equil5.inf -ref ../equil.4/$MFP.equil4.rst
cd ../
echo "DONE!"

#cd Truncated

#cpptrajhome=$AMBERHOME/AmberTools/bin/
#echo $cpptrajhome

#time ./truncation.py 3evg_gtp_sah $cpptrajhome