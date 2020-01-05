#ifndef _IO_H
#define _IO_H
#define SZ_SCES 0 //successful
#define SZ_NSCS -1 //Not successful
#define SZ_FERR -2 //Failed to open input file
#define SZ_TERR -3 //wrong data type (should be only float or double)
#define SZ_DERR -4 //dimension error
#define SZ_MERR -5 //sz_mode error
#define SZ_BERR -6 //bound-mode error (should be only ABS, REL, ABS_AND_REL, ABS_OR_REL, or PW_REL)
unsigned char *readByteData(char *srcFilePath, size_t *byteLength, int *status);
float *readFloatData(char *srcFilePath, size_t *nbEle, int *status);
void writeByteData(unsigned char *bytes, size_t byteLength, char *tgtFilePath, int *status);

#endif /* ----- #ifndef _IO_H  ----- */
