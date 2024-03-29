#! /bin/bash

module purge
module load gcc/8.2.0-g7hppkz
module load mpich
rm parallel_zfp parallel_sz2

szsrc=$HOME/code/sz2/install/include
szlib=$HOME/code/sz2/install/lib/
zfpsrc=$HOME/code/zfp/include
zfplib=$HOME/code/zfp/build/lib64/

gcc -c rw.c

# mpicc -std=c99 -O3 rw.o parallel_sz2.c -o parallel_sz2 -I$szsrc $szlib/libSZ.a $szlib/libzstd.a $szlib/libzlib.a -lm

mpicc -std=c99 -O3 rw.o parallel_sz2.c -o parallel_sz2 -I$szsrc -L$szlib -lSZ -lzstd -lm

mpicc -std=c99 -O3 rw.o parallel_zfp.c -o parallel_zfp -I$zfpsrc -L$zfplib -lzfp -lm