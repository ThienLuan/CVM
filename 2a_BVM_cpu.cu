////////////////////////////////////////////////////////////
//Ho Thien Luan -> History Tracking!
// 1. Ver_0: Approximate string matching with k-mismatches
// 2. Ver_1: Optimize by using sharing_memory for storing pattern 
//
//
//
////////////////////////////////////////////////////////////
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include <cuda.h>
#include <math.h>      
#include <cuda_runtime.h>
#include "cuPrintf.cu"
#include <time.h>

#define FILENAME_MAXLEN     256
 
int main(int argc, char **argv)
{
    char inputFile[FILENAME_MAXLEN];
    char patternFile[FILENAME_MAXLEN];
    strcpy( inputFile, argv[2]) ;
    strcpy( patternFile, argv[1]) ;
    int l_par;
    int k_par;
    l_par = strtol(argv[3], NULL, 10);
    k_par = strtol(argv[4], NULL, 10);

////////////////////////////////////////////////////////////////////////////////////
//Process input patterns
    int input_size;
    int pattern_size;
    int real_pattern_size;
    char *h_input_string = NULL ;
    char *h_pattern = NULL ;
    //int  *h_matched_result = NULL ;
    int  *h_matrix_M = NULL ;
    int  *h_matrix_B = NULL ;

    // step 1: read patterns and dump transition table 
//    int deviceID = 0 ;
//    cudaDeviceProp deviceProp;
//    cudaGetDeviceProperties(&deviceProp, deviceID);

    //readPatternFromFile( patternFile) ;
    
    //step 2: prepare input stream
    FILE* fpin = fopen( inputFile, "rb");
    assert ( NULL != fpin ) ;
    
    // obtain file size
    fseek (fpin , 0 , SEEK_END);
    input_size = ftell (fpin);
    rewind (fpin);

    //step2: prepare input pattern 
    FILE* fpattern = fopen( patternFile, "rb");
    assert ( NULL != fpattern ) ;
    
    // obtain file size
    fseek (fpattern , 0 , SEEK_END);
    pattern_size = ftell (fpattern);
    rewind (fpattern);
    
    // allocate memory to contain the whole file
    h_input_string = (char *) malloc (sizeof(char)*input_size);
    assert( NULL != h_input_string );

    h_pattern = (char *) malloc (sizeof(char)*pattern_size);
    assert( NULL != h_pattern );
    real_pattern_size = pattern_size-1; // del char "\n" 

 
    h_matrix_M = (int *) malloc (sizeof(int)*(input_size+1)*(2*pattern_size+1));
    assert( NULL != h_matrix_M );
    memset( h_matrix_M, 0, sizeof(int)*(input_size+1)*(2*pattern_size+1)) ;

    h_matrix_B = (int *) malloc (sizeof(int)*(input_size+1)*(2*pattern_size+1));
    assert( NULL != h_matrix_B );
    memset( h_matrix_B, 0, sizeof(int)*(input_size+1)*(2*pattern_size+1)) ;

    //h_matched_result = (int *) malloc (sizeof(int)*(input_size-l_par+1)*l_par);
    //assert( NULL != h_matched_result );
    //memset( h_matched_result, 0, sizeof(int)*(input_size-l_par+1)*l_par ) ;

    // copy the file into the buffer
    input_size = fread (h_input_string, 1, input_size, fpin);
    fclose(fpin);
    pattern_size = fread (h_pattern, 1, pattern_size, fpattern);
    fclose(fpattern);
     
    //printf("Cir string = %s, length = %d\n", h_pattern, real_pattern_size);

    //Bit-vector-mismatches Alg.
    unsigned int bit_vector=0;
    //int position = 0;
    #define BIT(x) (1<<(x))
    unsigned int mask = 0;
    for (int i = 0; i < l_par ; i++) {
        mask = (mask << 1) | 1;
    }
    //printf("Mask = %d\n", mask);
    unsigned int match = 0;

    //Bit-vector process
    struct timespec t_start, t_end;
    double elapsedTime;
    clock_gettime (CLOCK_REALTIME, &t_start);
    for (int i = 0; i <= input_size ; i++) {
	h_matrix_B[i*real_pattern_size] = 0;
	h_matrix_M[i*real_pattern_size] = 0;
    }

    for (int i = 1; i <=real_pattern_size; i++) {
	bit_vector = ((bit_vector << 1) & mask) | 1;
	h_matrix_B[i] = bit_vector;	
	for (int j = 0; j < l_par; j++) {
	    h_matrix_M[i] += (bit_vector >> j) & 1;
	}
    //printf("position %d -> h_matrix_B = %u, h_matrix_M = %u\n",i, h_matrix_B[i], h_matrix_M[i]);
    }

    for (int i = 1; i <= real_pattern_size; i++) {
	for (int j = 1; j <= input_size ; j++) {  //circular patterns
	    if (h_input_string[j-1] == h_pattern[i-1]) {match = 0;}
	    else {match = 1;}
	    h_matrix_B[(real_pattern_size+1)*j + i] = ((h_matrix_B[(real_pattern_size+1)*(j-1) + (i-1)] << 1) & mask) | match;
            
	    for (int k = 0; k < l_par; k++) {
            	h_matrix_M[(real_pattern_size+1)*j + i] += (h_matrix_B[(real_pattern_size+1)*j + i] >> k) & 1;
            }
	}	
    }

    clock_gettime(CLOCK_REALTIME, &t_end);
    elapsedTime = (t_end.tv_sec*1000+t_end.tv_nsec/1000000)-(t_start.tv_sec*1000+t_start.tv_nsec/1000000);

 
    // step 4: output matched result
    int total_result = 0;
    //for (int i = l_par; i<= input_size; i++) {
    for (int i = l_par; i <= input_size; i++) {
        for (int j = l_par; j <= real_pattern_size; j++) {
            //printf("At position %4d, circular pattern %4d : match pattern %d\n", i, j,  h_matrix_M[i*(real_pattern_size+1) + j]);
	    if(h_matrix_M[i*(real_pattern_size+1) + j] <= k_par) {total_result++;}
	}
    }
/*
    //Print out Matrix M
    for (int j = 0; j <= real_pattern_size; j++) {
    	for (int i = 0; i<= input_size; i++) {
            printf("%d\t", h_matrix_M[i*(real_pattern_size+1) + j]);
	}
    printf("\n");
    }
*/
    printf("\n\n");
    printf("############################################################\n");
    printf("#--Approximate Circular String Matching with k-Mismatches--#\n");
    printf("#----------------------------------------------------------#\n");
    printf("#-----------Bit-vector-mismatches Alg. in CPU--------------#\n");
    printf("############################################################\n");
    printf("#--Pattern Length            |\t\t %10d \t   #\n",real_pattern_size);
    printf("#----------------------------------------------------------#\n");
    printf("#--Input integer l           |\t\t %10d \t   #\n",l_par);
    printf("#----------------------------------------------------------#\n");
    printf("#--Input Size (bytes)        |\t\t %10d \t   #\n", input_size );
    printf("#----------------------------------------------------------#\n");
    printf("#--Total matched with k = %d  |\t\t %10d \t   #\n", k_par, total_result);
    printf("#----------------------------------------------------------#\n");
    printf("#--Total elapsed time (ms)   |\t\t %10f \t   #\n", elapsedTime);
    printf("#----------------------------------------------------------#\n");
    printf("#--Throughput Result (Gbps)  |\t\t %10f \t   #\n", (float)(input_size*8)/(elapsedTime*1000000) );
    printf("#--Throughput Result (Mbps)  |\t\t %10f \t   #\n", (float)(input_size*8)/(elapsedTime*1000) );
    printf("############################################################\n");


    free(h_input_string);
    free(h_pattern);
    //free(h_matched_result); 
    free(h_matrix_M); 
    free(h_matrix_B); 

            
    return 0;
}
