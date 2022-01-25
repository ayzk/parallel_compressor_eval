/**
 *  @file test_compress_parallel.c
 *  @author Dingwen Tao
 *  @date January, 2017
 *  @brief This is an example of using compression interface in parallel
 *  (C) 2017 by Mathematics and Computer Science (MCS), Argonne National Laboratory.
 *      See COPYRIGHT in top-level directory.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <time.h>
#include <unistd.h>

#include "mpi.h"
#include "rw.h"
#include "zfp.h"

unsigned char* zfp_compress_3D(float* array, double tolerance, size_t r1, size_t r2, size_t r3, size_t* out_size) {
    int status = 0;    /* return value: 0 = success */
    zfp_type type;     /* array scalar type */
    zfp_field* field;  /* array meta data */
    zfp_stream* zfp;   /* compressed stream */
    void* buffer;      /* storage for compressed stream */
    size_t bufsize;    /* byte size of compressed buffer */
    bitstream* stream; /* bit stream to write to or read from */
    size_t zfpsize;    /* byte size of compressed stream */

    /* allocate meta data for the 3D array a[nz][ny][nx] */
    type = zfp_type_float;
    field = zfp_field_3d(array, type, r3, r2, r1);

    /* allocate meta data for a compressed stream */
    zfp = zfp_stream_open(NULL);

    /* set compression mode and parameters via one of three functions */
    /*  zfp_stream_set_rate(zfp, rate, type, 3, 0); */
    /*  zfp_stream_set_precision(zfp, precision); */
    zfp_stream_set_accuracy(zfp, tolerance);

    /* allocate buffer for compressed data */
    bufsize = zfp_stream_maximum_size(zfp, field);
    buffer = malloc(bufsize);

    /* associate bit stream with allocated buffer */
    stream = stream_open(buffer, bufsize);
    zfp_stream_set_bit_stream(zfp, stream);
    zfp_stream_rewind(zfp);

    zfpsize = zfp_compress(zfp, field);
    if (!zfpsize) {
        fprintf(stderr, "compression failed\n");
        status = 1;
    }

    zfp_field_free(field);
    zfp_stream_close(zfp);
    stream_close(stream);
    *out_size = zfpsize;
    return (unsigned char*)buffer;
}

float* zfp_decompress_3D(unsigned char* comp_data, double tolerance, size_t buffer_size, size_t r1, size_t r2, size_t r3) {
    int status = 0;    /* return value: 0 = success */
    zfp_type type;     /* array scalar type */
    zfp_field* field;  /* array meta data */
    zfp_stream* zfp;   /* compressed stream */
    void* buffer;      /* storage for compressed stream */
    size_t bufsize;    /* byte size of compressed buffer */
    bitstream* stream; /* bit stream to write to or read from */
    size_t zfpsize;    /* byte size of compressed stream */

    /* allocate meta data for the 3D array a[nz][ny][nx] */
    float* array = (float*)malloc(r1 * r2 * r3 * sizeof(float));
    type = zfp_type_float;
    field = zfp_field_3d(array, type, r3, r2, r1);

    /* allocate meta data for a compressed stream */
    zfp = zfp_stream_open(NULL);

    /* set compression mode and parameters via one of three functions */
    /*  zfp_stream_set_rate(zfp, rate, type, 3, 0); */
    /*  zfp_stream_set_precision(zfp, precision); */
    zfp_stream_set_accuracy(zfp, tolerance);

    /* allocate buffer for compressed data */
    bufsize = zfp_stream_maximum_size(zfp, field);
    // buffer = malloc(bufsize);
    buffer = (void*)comp_data;
    bufsize = buffer_size;

    /* associate bit stream with allocated buffer */
    stream = stream_open(buffer, bufsize);
    zfp_stream_set_bit_stream(zfp, stream);
    zfp_stream_rewind(zfp);

    if (!zfp_decompress(zfp, field)) {
        fprintf(stderr, "decompression failed\n");
        status = 1;
    }
    zfp_field_free(field);
    zfp_stream_close(zfp);
    stream_close(stream);
    return array;
}

// USAGE
// mpirun -np 16 parallel sz.config folder_num r3 r2 r1
int main(int argc, char* argv[]) {
    srand(time(0));
    char* cfgFile;

    MPI_Init(NULL, NULL);

    int world_size;
    MPI_Comm_size(MPI_COMM_WORLD, &world_size);

    int world_rank;
    MPI_Comm_rank(MPI_COMM_WORLD, &world_rank);

    double rel_bound[100];
    double absbound[100];

    //Begin modify this part
    int num_vars = 4;
    char* file_folder = "/lcrc/project/ECP-EZ/public/compression/hasan-datasets/";
    char file[4][100] = {"baryon_density.f32.bin.log.dat", "dark_matter_density.f32.bin.log.dat", "temperature.f32.bin.log.dat", "velocity_x.f32.bin"};
    size_t r5 = 0, r4 = 0, r3 = 512, r2 = 512, r1 = 512;
    absbound[0] = atof(argv[1]);
    absbound[1] = atof(argv[2]);
    absbound[2] = atof(argv[3]);
    absbound[3] = atof(argv[4]);
    //End modify this part

    if (world_rank == 0) printf("Start parallel compressing ... \n");
    if (world_rank == 0) printf("size: %d\n", world_size);
    double start, end;
    double costReadOri = 0.0, costReadZip = 0.0, costWriteZip = 0.0, costWriteOut = 0.0, costComp = 0.0, costDecomp = 0.0;

    MPI_Barrier(MPI_COMM_WORLD);

    size_t compressed_size[100];
    char zip_filename[100];
    // char out_filename[100];
    size_t inSize, outSize;
    size_t nbEle;
    int status;
    float* dataIn;

    size_t est_compressed_size = r1 * r2 * r3 * sizeof(float) * num_vars / 3;
    unsigned char* compressed_output = (unsigned char*)malloc(est_compressed_size);
    unsigned char* compressed_output_pos = compressed_output;
    int folder_index = world_rank;
    for (int i = 0; i < num_vars; i++) {
        char filename[100];
        sprintf(filename, "%s/%s", file_folder, file[i]);
        // Read Input Data
        if (world_rank == 0) {
            start = MPI_Wtime();
            dataIn = readFloatData(filename, &nbEle, &status);
            end = MPI_Wtime();
            // printf("file %s read time: %.2f\n", filename, end - start);
            start = MPI_Wtime();
            MPI_Bcast(&nbEle, 1, MPI_UNSIGNED_LONG_LONG, 0, MPI_COMM_WORLD);
            MPI_Bcast(dataIn, nbEle, MPI_FLOAT, 0, MPI_COMM_WORLD);
            end = MPI_Wtime();
            // printf("broadcast time: %.2f\n", end - start);
        } else {
            MPI_Bcast(&nbEle, 1, MPI_UNSIGNED_LONG_LONG, 0, MPI_COMM_WORLD);
            dataIn = (float*)malloc(nbEle * sizeof(float));
            MPI_Bcast(dataIn, nbEle, MPI_FLOAT, 0, MPI_COMM_WORLD);
        }
        MPI_Barrier(MPI_COMM_WORLD);
        if (world_rank == 0) {
            end = MPI_Wtime();
            costReadOri += end - start;
        }

        // float max = dataIn[0];
        // float min = dataIn[0];
        // for (int j = 1; j < r1 * r2 * r3; j++) {
        //     if (max < dataIn[j]) max = dataIn[j];
        //     if (min > dataIn[j]) min = dataIn[j];
        // }
        // absbound[i] = rel_bound[i] * (max - min);

        // Compress Input Data
        size_t out_size;
        // if (world_rank == 0) printf ("Compressing %s\n", filename);
        MPI_Barrier(MPI_COMM_WORLD);
        if (world_rank == 0) start = MPI_Wtime();
        unsigned char* bytesOut = zfp_compress_3D(dataIn, absbound[i], r3, r2, r1, &compressed_size[i]);
        MPI_Barrier(MPI_COMM_WORLD);
        if (world_rank == 0) {
            end = MPI_Wtime();
            costComp += end - start;
        }
        free(dataIn);
        memcpy(compressed_output_pos, bytesOut, compressed_size[i]);
        compressed_output_pos += compressed_size[i];
        free(bytesOut);
    }
    struct stat st = {0};
    if (stat("/lcrc/globalscratch/zhaok", &st) == -1) {
        mkdir("/lcrc/globalscratch/zhaok", 0777);
    }
    sprintf(zip_filename, "%s/zfp_%d_%d.out", "/lcrc/globalscratch/zhaok", folder_index, rand());  // Write Compressed Data

    size_t total_size = compressed_output_pos - compressed_output;
    // Write Compressed Data
    MPI_Barrier(MPI_COMM_WORLD);
    if (world_rank == 0) start = MPI_Wtime();
    // if (world_rank == 0) printf("write compressed file to disk %s \n", zip_filename);
    writeByteData(compressed_output, total_size, zip_filename, &status);
    MPI_Barrier(MPI_COMM_WORLD);
    if (world_rank == 0) {
        end = MPI_Wtime();
        costWriteZip += end - start;
    }
    free(compressed_output);
    // Read Compressed Data
    MPI_Barrier(MPI_COMM_WORLD);
    if (world_rank == 0) start = MPI_Wtime();
    // if (world_rank == 0) printf("read compressed file from disk %s \n", zip_filename);
    compressed_output = readByteData(zip_filename, &inSize, &status);
    if (inSize != total_size) {
        printf("ERROR! Broken file : %s", zip_filename);
    } else {
        remove(zip_filename);
    }
    MPI_Barrier(MPI_COMM_WORLD);
    if (world_rank == 0) {
        end = MPI_Wtime();
        costReadZip += end - start;
    }
    compressed_output_pos = compressed_output;

    for (int i = 0; i < num_vars; i++) {
        // Decompress Compressed Data
        MPI_Barrier(MPI_COMM_WORLD);
        // if (world_rank == 0) printf("decompress %d-th field\n", i);
        if (world_rank == 0) start = MPI_Wtime();
        float* dataOut = zfp_decompress_3D(compressed_output_pos, absbound[i], compressed_size[i], r3, r2, r1);
        MPI_Barrier(MPI_COMM_WORLD);
        if (world_rank == 0) {
            end = MPI_Wtime();
            costDecomp += end - start;
        }
        compressed_output_pos += compressed_size[i];
        free(dataOut);
    }
    free(compressed_output);

    if (world_rank == 0) {
        printf("ZFP Finish parallel compressing, total compression ratio = %.4g\n", 1.0 * r1 * r2 * r3 * sizeof(float) * num_vars / total_size);
        printf("Separate ratios\n");
        for (int i = 0; i < num_vars; i++) {
            printf("%s = %.4g \n", file[i], 1.0 * r1 * r2 * r3 * sizeof(float) / compressed_size[i]);
        }
        // printf("\n");
        // printf("Timecost of reading original files = %.2f seconds\n", costReadOri);
        printf("Timecost of compressing using %d processes = %.2f seconds\n", world_size, costComp);
        printf("Timecost of writing compressed files = %.2f seconds\n", costWriteZip);
        printf("Timecost of reading compressed files = %.2f seconds\n", costReadZip);
        printf("Timecost of decompressing using %d processes = %.2f seconds\n", world_size, costDecomp);
        // printf("Timecost of writing decompressed files = %.2f seconds\n", costWriteOut);
        printf("Throughput of reading compressed files = %.2f GB/s\n", total_size * world_size / 1000.0 / 1000 / 1000 / costReadZip);
        printf("Throughput of writing compressed files = %.2f GB/s\n", total_size * world_size / 1000.0 / 1000 / 1000 / costWriteZip);
    }

    MPI_Finalize();

    return 0;
}
