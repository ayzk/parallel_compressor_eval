#!/bin/bash
#SBATCH --job-name=p256
#SBATCH -p bdws
#SBATCH -A ECP-EZ
#SBATCH --nodes 8
#SBATCH --ntasks-per-node=32
#SBATCH --time=1:00:00
#SBATCH -o p256.%j.%N.out
#SBATCH -e p256.%j.%N.error

printf date=`date`
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$HOME/code/zfp/build/lib64/:$HOME/code/sz2/install/lib/
# printf $LD_LIBRARY_PATH

printf "\n\nCASE1_sz_our\n"
srun parallel_sz2 ~/code/sz2/example/sz.config 0.00431408 0.01 0.000358829 0.000325161 

printf "\n\nCASE1_sz_fraz\n"
srun parallel_sz2 ~/code/sz2/example/sz.config 0.00823464 0.00797187 0.00386663 0.000515885 

printf "\n\nCASE2_sz_our\n"
srun parallel_sz2 ~/code/sz2/example/sz.config 0.01003030 0.02 0.00405014 0.000705899  

printf "\n\nCASE2_sz_fraz\n"
srun parallel_sz2 ~/code/sz2/example/sz.config 0.01686 0.0199813 0.00478061 0.000897832  

printf "\n\nCASE3_sz_our\n"
srun parallel_sz2 ~/code/sz2/example/sz.config 0.01313630 0.05 0.00923987 0.00105257 

printf "\n\nCASE3_sz_fraz\n"
srun parallel_sz2 ~/code/sz2/example/sz.config 0.0192734 0.0493125 0.0125773 0.00125263

printf "\n\nCASE1_zfp_our\n"
srun parallel_zfp 0.05982227206 1.777141137 0.09692075505 277203.319 

printf "\n\nCASE1_zfp_fraz\n"
srun parallel_zfp 0.119977 1.55 0.0783084 262361.00 

printf "\n\nCASE2_zfp_our\n"
srun parallel_zfp 0.2327994825 8.230092457 0.3826561486 548419.5935 

printf "\n\nCASE2_zfp_fraz\n"
srun parallel_zfp 0.337313 2.5 0.268649 657279.00 

printf "\n\nCASE3_zfp_our\n"
srun parallel_zfp 1.08209603 8.230092457 1.949138562 1606804.793 

printf "\n\nCASE3_zfp_fraz\n"
srun parallel_zfp 0.561525 2.5 0.268649 1567270.00 

printf date=`date`