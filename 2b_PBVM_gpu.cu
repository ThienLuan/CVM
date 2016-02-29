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
#define THREAD_BLOCK_EXP   (7)
#define THREAD_BLOCK_SIZE  (1 << THREAD_BLOCK_EXP)

__global__ void ASM_kernel(char *g_input_string, int input_size, char *g_pattern, int real_pattern_size, int l_par, int mask, int *g_matrix_M, int *g_matrix_B)
{
    int tid  = threadIdx.x ;
    int gbid = blockIdx.y * gridDim.x + blockIdx.x ;
    int start = gbid*THREAD_BLOCK_SIZE;
    int start_1st_tid = start + tid;
    int start_2nd_tid = start + tid - (real_pattern_size - l_par);
    //unsigned int bit_vector=0;
    int match;
    int sub_sum;
    int sub_init;

    //__shared__ char sub_string_shared [THREAD_BLOCK_SIZE + pattern_length - 1] ;
    __shared__ char pattern_shared [32] ;

//  int pow_2b = 1 << b;
//  unsigned int bit_vector = 0;

//  sub_string_shared[tid] = g_input_string[start+tid];
//  if ( tid < (pattern_length - 1) ){
//     sub_string_shared[THREAD_BLOCK_SIZE + tid] = g_input_string[start+THREAD_BLOCK_SIZE+tid];
//  }
  if ( tid < real_pattern_size ){
     pattern_shared[tid] = g_pattern[tid];
  }
  __syncthreads();


  if(start_1st_tid < real_pattern_size - l_par) {
    //initialization
    sub_sum = 0;
    sub_init = 0;
    for (int i=1; i<=start_1st_tid+1; i++) {
        sub_init = ((sub_init << 1) & mask) | 1;
	sub_sum++;
    }
	//g_matrix_B[start_1st_tid+1] = sub_init;
	//g_matrix_M[start_1st_tid+1] = sub_sum;
    //Processing
    for(int i = 1; i<=real_pattern_size-start_1st_tid; i++) {
        //if (g_input_string[i-1] == g_pattern[start_1st_tid+i]) {match = 0;}
        if (g_input_string[i-1] == pattern_shared[start_1st_tid+i]) {match = 0;}
        else {match = 1;}
        g_matrix_B[(real_pattern_size+1)*(i) + start_1st_tid+i+1] = ((g_matrix_B[(real_pattern_size+1)*(i-1) + (start_1st_tid+i)] << 1) & mask) | match;
        
	sub_sum = 0;
        for (int k = 0; k < l_par; k++) {
           //g_matrix_M[(real_pattern_size+1)*(start_1st_tid+i) + i] += (g_matrix_B[(real_pattern_size+1)*(start_1st_tid+i) + i] >> k) & 1;
           sub_sum += (g_matrix_B[(real_pattern_size+1)*(i) + start_1st_tid+i+1] >> k) & 1;
	   g_matrix_M[(real_pattern_size+1)*(i) + start_1st_tid+i+1] = sub_sum;
        }

    }
	
    
  }

////////////////////////////////////////////////////////////////
  if (start_2nd_tid <= input_size-l_par+1) {
    //initialization
    //g_matrix_B[(real_pattern_size+1)*(start_2nd_tid+0) + 0] = 0;
    //g_matrix_M[(real_pattern_size+1)*(start_2nd_tid+0) + 0] = 0;

    for (int i = 1; i <= real_pattern_size; i++) {
            //if (g_input_string[start_2nd_tid+i-1] == g_pattern[i-1]) {match = 0;}
            if (g_input_string[start_2nd_tid+i-1] == pattern_shared[i-1]) {match = 0;}
            else {match = 1;}
            g_matrix_B[(real_pattern_size+1)*(start_2nd_tid+i) + i] = ((g_matrix_B[(real_pattern_size+1)*(start_2nd_tid+i-1) + (i-1)] << 1) & mask) | match;
	    sub_sum = 0;
            for (int k = 0; k < l_par; k++) {
                //g_matrix_M[(real_pattern_size+1)*(start_2nd_tid+i) + i] += (g_matrix_B[(real_pattern_size+1)*(start_2nd_tid+i) + i] >> k) & 1;
                sub_sum += (g_matrix_B[(real_pattern_size+1)*(start_2nd_tid+i) + i] >> k) & 1;
		g_matrix_M[(real_pattern_size+1)*(start_2nd_tid+i) + i] = sub_sum;
            }
//cuPrintf("threadIdx.x = %d \t ,start = %d, matrix_M = %d, matrix_B = %d, string = %s, pattern = %s, pattern_size = %d\n", tid, start_2nd_tid, g_matrix_M[(real_pattern_size+1)*(start_2nd_tid+i) + i],g_matrix_B[(real_pattern_size+1)*(start_2nd_tid+i) + i], g_input_string[i-1], g_pattern[i-1], l_par);
    }


  }
}

////////////////////////////////
void ASM_process_top (char *g_input_string, size_t input_size,  char *g_pattern, int real_pattern_size, int l_par, int mask, int *g_matrix_M, int *g_matrix_B)
{

    // num_blocks = # of thread blocks to cover input stream
    int num_blocks = (input_size+real_pattern_size-2*l_par+1)/THREAD_BLOCK_SIZE + 1 ;
    //total thread = (m-l) + (n-l+1)


        dim3  dimBlock( THREAD_BLOCK_SIZE, 1 ) ;
        dim3  dimGrid ;

        int p = num_blocks >> 15 ;
        dimGrid.x = num_blocks ;
        if ( p ){
            dimGrid.x = 1<<15 ;
            dimGrid.y = p+1 ;
        }
    cudaPrintfInit();////for cuPrintf

    ASM_kernel <<< dimGrid, dimBlock >>>(g_input_string, input_size, g_pattern, real_pattern_size, l_par, mask, g_matrix_M, g_matrix_B);

    cudaPrintfDisplay();////for cuPrintf
    cudaPrintfEnd();        ////for cuPrintf
}

////////////////////////////////////////////// 
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
    //Parallel Bit-vector-mismaeches alg.

    #define BIT(x) (1<<(x))
    unsigned int mask = 0;
    for (int i = 0; i < l_par ; i++) {
        mask = (mask << 1) | 1;
    }
/*
    //printf("Mask = %d\n", mask);
    unsigned int match = 0;
    unsigned int bit_vector=0;

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
*/

    // Process in GPU
    char *g_input_string;
    char *g_pattern;
    int *g_matrix_M;
    int *g_matrix_B;

    cudaMalloc (&g_input_string, sizeof(char)*input_size);
    cudaMalloc (&g_pattern, sizeof(char)*pattern_size);
    cudaMalloc (&g_matrix_M, sizeof(int)*(input_size+1)*(2*pattern_size+1));
    cudaMalloc (&g_matrix_B, sizeof(int)*(input_size+1)*(2*pattern_size+1));

    cudaMemcpy (g_input_string, h_input_string, sizeof(char)*input_size, cudaMemcpyHostToDevice );
    cudaMemcpy (g_pattern, h_pattern, sizeof(char)*pattern_size, cudaMemcpyHostToDevice );

    // record time setting
    cudaEvent_t start, stop;
    float time;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);
    cudaEventRecord(start, 0);
/*
    unsigned int bit_vector=0;
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

    cudaMemcpy (g_matrix_M, h_matrix_M, sizeof(int)*(input_size+1)*(2*pattern_size+1), cudaMemcpyHostToDevice );
    cudaMemcpy (g_matrix_B, h_matrix_B, sizeof(int)*(input_size+1)*(2*pattern_size+1), cudaMemcpyHostToDevice );
*/
    // step 3: run ASM on GPU           
    ASM_process_top ( g_input_string, input_size, g_pattern, real_pattern_size, l_par, mask, g_matrix_M, g_matrix_B) ;
    //With circular string matching l_par = l;

    // record time setting
    cudaEventRecord(stop, 0);
    cudaEventSynchronize(stop);
    cudaEventElapsedTime(&time, start, stop);

    cudaMemcpy (h_matrix_M, g_matrix_M, sizeof(int)*(input_size+1)*(2*pattern_size+1), cudaMemcpyDeviceToHost );
    cudaMemcpy (h_matrix_B, g_matrix_B, sizeof(int)*(input_size+1)*(2*pattern_size+1), cudaMemcpyDeviceToHost );


    // step 4: output matched result
    int total_result = 0;
    //for (int i = l_par; i<= input_size; i++) {
    for (int i = l_par; i <= input_size; i++) {
        for (int j = l_par; j <= real_pattern_size; j++) {
            //printf("At position %4d, circular pattern %4d : match_M %d, match_B = %d\n", i, j, h_matrix_M[i*(real_pattern_size+1) + j], h_matrix_B[i*(real_pattern_size+1) + j]);
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
    printf("#---------------Parallel BVM Alg. in GPU-------------------#\n");
    printf("############################################################\n");
    printf("#--Pattern Length            |\t\t %10d \t   #\n",real_pattern_size);
    printf("#----------------------------------------------------------#\n");
    printf("#--Input integer l           |\t\t %10d \t   #\n",l_par);
    printf("#----------------------------------------------------------#\n");
    printf("#--Input Size (bytes)        |\t\t %10d \t   #\n", input_size );
    printf("#----------------------------------------------------------#\n");
    printf("#--Total matched with k = %d  |\t\t %10d \t   #\n", k_par, total_result);
    printf("#----------------------------------------------------------#\n");
    //printf("#--Total elapsed time (ms)   |\t\t %10f \t   #\n", elapsedTime);
    printf("#--Total elapsed time (ms)   |\t\t %10f \t   #\n", time);
    printf("#----------------------------------------------------------#\n");
    //printf("#--Throughput Result (Gbps)  |\t\t %10f \t   #\n", (float)(input_size*8)/(elapsedTime*1000000) );
    //printf("#--Throughput Result (Mbps)  |\t\t %10f \t   #\n", (float)(input_size*8)/(elapsedTime*1000) );
    printf("#--Throughput Result (Gbps)  |\t\t %10f \t   #\n", (float)(input_size*8)/(time*1000000) );
    printf("#--Throughput Result (Mbps)  |\t\t %10f \t   #\n", (float)(input_size*8)/(time*1000) );
    printf("############################################################\n");


    free(h_input_string);
    free(h_pattern);
    //free(h_matched_result); 
    free(h_matrix_M); 
    free(h_matrix_B); 

    cudaFree(g_input_string);
    cudaFree(g_pattern);
    cudaFree(g_matrix_M); 
    cudaFree(g_matrix_B); 

            
    return 0;
}
