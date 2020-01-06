#!/bin/bash
#SBATCH --job-name=4096
#SBATCH -p bdwall
#SBATCH -A ECP-EZ
#SBATCH --nodes 128
#SBATCH --ntasks-per-node=32
#SBATCH --time=48:00:00
#SBATCH -o p4096.%j.%N.out
#SBATCH -e p4096.%j.%N.error

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
srun ./parallel_selector sz.config 2 64 64 93840
srun ./parallel_kai sz.config 2 64 64 93840