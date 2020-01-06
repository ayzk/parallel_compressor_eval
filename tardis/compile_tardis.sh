#! /bin/bash

module purge
module load mpich-3.2.1/gcc-4.8.5
rm parallel_selector parallel_sz parallel_kai parallel_zfp

mpicc -std=c99 -O3 ../parallel_sz_2.0.c -o parallel_sz -I/home/kzhao016/tools/SZ-2.1.8.0/install/include /home/kzhao016/tools/SZ-2.1.8.0/install/lib/libSZ.a /home/kzhao016/tools/SZ-2.1.8.0/install/lib/libzlib.a /home/kzhao016/tools/SZ-2.1.8.0/install/lib/libzstd.a  -lm

mpicc -std=c99 -O3 ../parallel_zfp.c -o parallel_zfp -I/home/kzhao016/tools/zfp-20191226-74e8a14/include -I/home/kzhao016/tools/SZ-2.1.8.0/install/include /home/kzhao016/tools/SZ-2.1.8.0/install/lib/libSZ.a /home/kzhao016/tools/SZ-2.1.8.0/install/lib/libzlib.a  /home/kzhao016/tools/SZ-2.1.8.0/install/lib/libzstd.a /home/kzhao016/tools/zfp-20191226-74e8a14/lib/libzfp.a -lm

g++ -O3 -c ../sz_zfp_selector.cpp -o selector.o -I/home/kzhao016/tools/zfp-0.3.1/inc -I/home/kzhao016/tools/SZ-2.0.3.0/install/include

mpicxx -O3 ../parallel_selector.c selector.o -o parallel_selector -I/home/kzhao016/tools/zfp-0.3.1/inc -I/home/kzhao016/tools/SZ-2.0.3.0/install/include /home/kzhao016/tools/SZ-2.0.3.0/install/lib/libSZ.a /home/kzhao016/tools/SZ-2.0.3.0/install/lib/libzlib.a  /home/kzhao016/tools/SZ-2.0.3.0/install/lib/libzstd.a  /home/kzhao016/tools/zfp-0.3.1/lib/libzfp.a

g++ -O3 -c ../rw1.c -o rw.o
mpic++ -O3 rw.o ../parallel_kai.c -o parallel_kai  -I/home/kzhao016/code/meta_compressor/build/include /home/kzhao016/code/meta_compressor/build/lib/libsz_cpp.a /home/kzhao016/tools/zstd-1.4.4/lib/libzstd.a  -lm

