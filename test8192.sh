#!/bin/bash
#SBATCH --job-name=p8192
#SBATCH -p bdwall
#SBATCH -A ECP-EZ
#SBATCH --nodes 256
#SBATCH --ntasks-per-node=32
#SBATCH --time=5:00:00
#SBATCH -o p8192.%j.%N.out
#SBATCH -e p8192.%j.%N.error

echo wait .... 30 seconds
sleep 30
echo date=`date`
# NYX
srun ./parallel_sz_old sz.config 6 512 512 512
srun ./parallel_zfp sz.config 6 512 512 512
srun ./parallel_selector sz.config 6 512 512 512
srun ./parallel_dingwen sz.config 6 512 512 512

# Hurricane
srun ./parallel_sz_old sz.config 13 496 496 96
srun ./parallel_zfp sz.config 13 496 496 96
srun ./parallel_selector sz.config 13 496 496 96
srun ./parallel_dingwen sz.config 13 496 496 96

# SCALE
srun ./parallel_sz_old sz.config 12 1200 1200 96
srun ./parallel_zfp sz.config 12 1200 1200 96
srun ./parallel_selector sz.config 12 1200 1200 96
srun ./parallel_dingwen sz.config 12 1200 1200 96