#!/bin/bash
#SBATCH --job-name=p8192
#SBATCH -p bdwall
#SBATCH -A ECP-EZ
#SBATCH --nodes 256
#SBATCH --ntasks-per-node=32
#SBATCH --time=24:00:00
#SBATCH -o p8192.%j.%N.out
#SBATCH -e p8192.%j.%N.error

echo wait .... 30 seconds
sleep 30
echo date=`date`


# Hurricane
srun ./parallel_sz sz.config 13 496 496 96
srun ./parallel_zfp sz.config 13 496 496 96
srun ./parallel_selector sz.config 13 496 496 96
srun ./parallel_kai sz.config 13 496 496 96

# miranda
srun ./parallel_sz sz.config 7 384 384 256
srun ./parallel_zfp sz.config 7 384 384 256
srun ./parallel_selector sz.config 7 384 384 256
srun ./parallel_kai sz.config 7 384 384 256

# qmcpack8h
srun ./parallel_sz sz.config 2 64 64 93840
srun ./parallel_zfp sz.config 2 64 64 93840
srun ./parallel_kai sz.config 2 64 64 93840
srun ./parallel_selector_in_block sz.config 1 64 64 33120
