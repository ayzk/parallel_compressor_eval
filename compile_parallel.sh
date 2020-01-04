#! /bin/bash

module purge
module load gcc/8.2.0-g7hppkz
module load mpich
rm parallel_selector parallel_sz parallel_kai parallel_zfp

mpicc -std=c99 -O3 parallel_sz_2.0.c -o parallel_sz -I/home/kazhao/tools/SZ-2.1.8.0/install/include /home/kazhao/tools/SZ-2.1.8.0/install/lib/libSZ.a /home/kazhao/tools/SZ-2.1.8.0/install/lib/libzlib.a /home/kazhao/tools/SZ-2.1.8.0/install/lib/libzstd.a -lm

mpicc -std=c99 -O3 parallel_zfp.c -o parallel_zfp -I/home/kazhao/tools/zfp-20191226-74e8a14/include -I/home/kazhao/tools/SZ-2.1.8.0/install/include /home/kazhao/tools/SZ-2.1.8.0/install/lib/libSZ.a /home/kazhao/tools/SZ-2.1.8.0/install/lib/libzlib.a /home/kazhao/tools/SZ-2.1.8.0/install/lib/libzstd.a /home/kazhao/tools/zstd/lib64/libzstd.a /home/kazhao/tools/zfp-20191226-74e8a14/lib/libzfp.a -lm

g++ -O3 -c sz_zfp_selector.cpp -o selector.o -I/home/xin/codes/zfp-0.3.1/inc -I/home/kazhao/tools/SZ-2.0.3.0/install/include

mpicxx -O3 parallel_selector.c selector.o -o parallel_selector -I/home/xin/codes/zfp-0.3.1/inc -I/home/kazhao/tools/SZ-2.0.3.0/install/include /home/kazhao/tools/SZ-2.0.3.0/install/lib/libSZ.a /home/kazhao/tools/SZ-2.0.3.0/install/lib/libzlib.a /home/kazhao/tools/SZ-2.0.3.0/install/lib/libzstd.a /home/xin/codes/zfp-0.3.1/lib/libzfp.a

g++ -O3 -c rw1.c -o rw.o 
mpic++ -O3 rw.o parallel_kai.c -o parallel_kai  -I/home/kazhao/meta_compressor/build/include /home/kazhao/meta_compressor/build/lib/libsz_cpp.a /home/kazhao/tools/zstd/lib64/libzstd.a  -lm

