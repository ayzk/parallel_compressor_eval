#!/bin/bash
#SBATCH --job-name=p256
#SBATCH -p bdws
#SBATCH -A ECP-EZ
#SBATCH --nodes 8
#SBATCH --ntasks-per-node=32
#SBATCH --time=1:00:00
#SBATCH -o p256.%j.%N.out
#SBATCH -e p256.%j.%N.error

echo date=`date`
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/zhaok/code/zfp/build/lib64/:/home/zhaok/code/sz2/install/lib/
# echo $LD_LIBRARY_PATH

srun parallel_sz2 ~/code/sz2/example/sz.config 0.00431408 0.01 0.000358829 0.000325161 > ics22_case1_sz_our.txt
srun parallel_zfp 0.05982227206 1.777141137 0.09692075505 277203.319 > ics22_case1_zfp_our.txt