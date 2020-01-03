#! /bin/bash

module purge
module load gcc/8.2.0-g7hppkz
module load openmpi

mpicc -std=c99 -O3 parallel_sz_2.0.c -o parallel_sz -I/home/kazhao/z-checker-installer/SZ/sz-install/include /home/kazhao/z-checker-installer/SZ/sz-install/lib/libSZ.a /home/kazhao/z-checker-installer/SZ/sz-install/lib/libzlib.a /home/kazhao/zstd/lib64/libzstd.a -lm

mpicc -std=c99 -O3 parallel_zfp.c -o parallel_zfp -I/home/kazhao/z-checker-installer/zfp/include -I/home/kazhao/z-checker-installer/SZ/sz-install/include /home/kazhao/z-checker-installer/SZ/sz-install/lib/libSZ.a /home/kazhao/z-checker-installer/SZ/sz-install/lib/libzlib.a /home/kazhao/z-checker-installer/SZ/sz-install/lib/libzstd.a /home/kazhao/z-checker-installer/zfp/lib/libzfp.a -lm

g++ -O3 -c sz_zfp_selector.cpp -o selector.o -I/home/xin/codes/zfp-0.3.1/inc -I/home/kazhao/tools/SZ-2.0.3.0/install/include

mpicxx -O3 parallel_selector.c selector.o -o parallel_selector -I/home/xin/codes/zfp-0.3.1/inc -I/home/kazhao/tools/SZ-2.0.3.0/install/include /home/kazhao/tools/SZ-2.0.3.0/install/lib/libSZ.a /home/kazhao/tools/SZ-2.0.3.0/install/lib/libzlib.a /home/kazhao/tools/SZ-2.0.3.0/install/lib/libzstd.a /home/xin/codes/zfp-0.3.1/lib/libzfp.a

mpicc -std=c99 -O3 parallel_sz_kai.c -o parallel_sz_kai -I/home/kazhao/z-checker-installer/SZ/sz-install/include /home/kazhao/z-checker-installer/SZ/sz-install/lib/libSZ.a /home/kazhao/z-checker-installer/SZ/sz-install/lib/libzlib.a -lm
