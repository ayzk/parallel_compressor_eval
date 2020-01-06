#!/bin/bash
#SBATCH --job-name=3_2048
#SBATCH -p bdwall
#SBATCH -A ECP-EZ
#SBATCH --nodes 64
#SBATCH --ntasks-per-node=32
#SBATCH --time=6:00:00
#SBATCH -o p2048.%j.%N.out
#SBATCH -e p2048.%j.%N.error

echo wait .... 30 seconds
sleep 30
echo date=`date`

# qmcpack6k
srun ./parallel_sz sz.config 20 64 64 34496
srun ./parallel_zfp sz.config 20 64 64 34496
srun ./parallel_selector sz.config 20 64 64 34496
srun ./parallel_kai sz.config 20 64 64 34496