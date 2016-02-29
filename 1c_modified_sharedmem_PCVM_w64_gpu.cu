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

__global__ void ASM_kernel(char *g_input_string, int input_size, int *g_pattern_decode, int real_pattern_size, int mask, int maskplus, int b, int *g_matched_result)
{
    int tid  = threadIdx.x ;
    int gbid = blockIdx.y * gridDim.x + blockIdx.x ;
    int start = gbid*THREAD_BLOCK_SIZE;
    int start_tid = start + tid;
    int pow_2b = 1 << b;
    unsigned long long int bit_vector=0;
    int t_shift;

    __shared__ char sub_string_shared [256] ;
    __shared__ int pattern_decode_shared [4] ;


  sub_string_shared[tid] = g_input_string[start+tid];
  if ( tid < (real_pattern_size - 1) ){
     sub_string_shared[THREAD_BLOCK_SIZE + tid] = g_input_string[start+THREAD_BLOCK_SIZE+tid];
  }
  if ( (real_pattern_size <= tid) && (tid < real_pattern_size + 4) ){
     pattern_decode_shared[tid-real_pattern_size] = g_pattern_decode[tid-real_pattern_size];
  }
  __syncthreads();

////////////////////////////////////////////////////////////////

  if (start_tid < input_size-real_pattern_size+1) {
    for (int i = 0; i < real_pattern_size; i++) {
       t_shift = i%real_pattern_size;  

        if (sub_string_shared[ tid+i ] == 'A') {
            bit_vector = bit_vector + (((pattern_decode_shared[0] << t_shift*b) & mask) | (pattern_decode_shared[0] >> (real_pattern_size - t_shift)*b));
        }
        else if (sub_string_shared[ tid+i ] == 'C'){
            bit_vector = bit_vector + (((pattern_decode_shared[1] << t_shift*b) & mask) | (pattern_decode_shared[1] >> (real_pattern_size - t_shift)*b));
        }
        else if (sub_string_shared[ tid+i ] == 'T'){
            bit_vector = bit_vector + (((pattern_decode_shared[2] << t_shift*b) & mask) | (pattern_decode_shared[2] >> (real_pattern_size - t_shift)*b));
        }
        else if (sub_string_shared[ tid+i ] == 'G'){   //case of G
            bit_vector = bit_vector + (((pattern_decode_shared[3] << t_shift*b) & mask) | (pattern_decode_shared[3] >> (real_pattern_size - t_shift)*b));
        }
        else {  // can be char "\n" 
            bit_vector = bit_vector + maskplus;
        }

    }
        //Get results
           for (int j = 0; j < real_pattern_size ; j++) {  //circular patterns
                //h_matched_result[(i-real_pattern_size+1)*real_pattern_size+(real_pattern_size-1-j)] += ((bit_vector >> (k*real_pattern_size+j)) & 1);
                g_matched_result[start_tid*real_pattern_size+j] = bit_vector % pow_2b;
                bit_vector = bit_vector >> b;
           }

    //cuPrintf("threadIdx.x = %d \t ,start = %d, matrix_M = %d, matrix_B = %d, string = %s, pattern = %s, pattern_size = %d\n", tid, start_tid, g_matrix_M[(real_pattern_size+1)*(start_tid+i) + i],g_matrix_B[(real_pattern_size+1)*(start_tid+i) + i], g_input_string[i-1], g_pattern_circular[i-1], real_pattern_size);
  }

}

////////////////////////////////
void ASM_process_top (char *g_input_string, size_t input_size,  int *g_pattern_decode, int real_pattern_size, int mask, int maskplus, int b, int *g_matched_result)
{

    // num_blocks = # of thread blocks to cover input stream
    int num_blocks = (input_size-real_pattern_size+1)/THREAD_BLOCK_SIZE + 1 ;


        dim3  dimBlock( THREAD_BLOCK_SIZE, 1 ) ;
        dim3  dimGrid ;

        int p = num_blocks >> 15 ;
        dimGrid.x = num_blocks ;
        if ( p ){
            dimGrid.x = 1<<15 ;
            dimGrid.y = p+1 ;
        }
    cudaPrintfInit();////for cuPrintf

    ASM_kernel <<< dimGrid, dimBlock >>>(g_input_string, input_size, g_pattern_decode, real_pattern_size, mask, maskplus, b, g_matched_result);

    cudaPrintfDisplay();////for cuPrintf
    cudaPrintfEnd();        ////for cuPrintf
}


////////////////////////////////////////////////////////////////////////////////////
int main(int argc, char **argv)
{
    char inputFile[FILENAME_MAXLEN];
    char patternFile[FILENAME_MAXLEN];
    strcpy( inputFile, argv[2]) ;
    strcpy( patternFile, argv[1]) ;
    int k_par;
    k_par = strtol(argv[3], NULL, 10);

////////////////////////////////////////////////////////////////////////////////////
//Process input patterns
    int input_size;
    int pattern_size;
    int real_pattern_size;
    char *h_input_string = NULL ;
    char *h_pattern = NULL ;
    int  *h_matched_result = NULL ;
    int  *h_pattern_decode = (int*) malloc( sizeof(int)*4 ) ;

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
    real_pattern_size = pattern_size-1;

 
    h_matched_result = (int *) malloc (sizeof(int)*(input_size-real_pattern_size+1)*real_pattern_size);
    assert( NULL != h_matched_result );
    memset( h_matched_result, 0, sizeof(int)*(input_size-real_pattern_size+1)*real_pattern_size) ;

    // copy the file into the buffer
    input_size = fread (h_input_string, 1, input_size, fpin);
    fclose(fpin);
    pattern_size = fread (h_pattern, 1, pattern_size, fpattern);
    fclose(fpattern);
     
    //printf("Cir string = %s, length = %d\n", h_pattern, real_pattern_size);

    //ACSM Preprocess - Define table T[]
    unsigned long long int T_A = 0;
	int cal_A = 0;
    unsigned long long int T_C = 0;
	int cal_C = 0;
    unsigned long long int T_T = 0;
	int cal_T = 0;
    unsigned long long int T_G = 0;
	int cal_G = 0;

float sub_real_pattern_size = real_pattern_size+1;
float float_b = log2(sub_real_pattern_size);
int b = float_b;
if(b != float_b) {
   b=b+1;
}
//int b = log2(sub_real_pattern_size)+1;
//int pow_2b = 1 << b;
//printf("#-pattern = %d, b=%d, float_b = %f, opw_2b = %d-#\n",real_pattern_size,b,float_b,pow_2b);

    //for ( int i = real_pattern_size-1; i>=0; i--) {
    for ( int i = 0; h_pattern[ i ]; i++) {
      if(h_pattern[ i ] != '\n') {
        //printf("Process for char: %c\n", h_pattern[ i ]);
	if (h_pattern[ i ] == 'A') {
	    cal_A = 0;
	    cal_C = 1;
	    cal_T = 1;
	    cal_G = 1;
	}
	else if (h_pattern[ i ] == 'C'){
	    cal_A = 1;
	    cal_C = 0;
	    cal_T = 1;
	    cal_G = 1;
	}
	else if (h_pattern[ i ] == 'T'){
	    cal_A = 1;
	    cal_C = 1;
	    cal_T = 0;
	    cal_G = 1;
	}
	else if (h_pattern[ i ] == 'G'){
	    cal_A = 1;
	    cal_C = 1;
	    cal_T = 1;
	    cal_G = 0;
	}

	T_A = (T_A << b) + cal_A;
	T_C = (T_C << b) + cal_C;
	T_T = (T_T << b) + cal_T;
	T_G = (T_G << b) + cal_G;

      }
    }
	h_pattern_decode[0] = T_A;
	h_pattern_decode[1] = T_C;
	h_pattern_decode[2] = T_T;
	h_pattern_decode[3] = T_G;
     
    //printf("\nT_A: %d\n", T_A);
    //printf("\nT_C: %d\n", T_C);
    //printf("\nT_T: %d\n", T_T);
    //printf("\nT_G: %d\n", T_G);

    //shift-add bit-vector.
    //unsigned long long int bit_vector=0;
    //int t_shift = 0;
    #define BIT(x) (1<<(x))
    unsigned long long int mask = 0;
    for (int i = 0; i < real_pattern_size*b ; i++) {
	mask = (mask << 1) | 1;
    }
    unsigned long long int maskplus = 0;
    for (int i = 0; i < real_pattern_size ; i++) {
	maskplus = (maskplus << b) | 1;
    }

/*
    //ACSM process
    struct timespec t_start, t_end;
    double elapsedTime;
    clock_gettime (CLOCK_REALTIME, &t_start);

    //for (int i = 0; h_input_string [ i ] ; i++) {
    for (int i = 0; i<input_size-(real_pattern_size-1) ; i++) {
	bit_vector = 0 ;
      for(int k=0; k< real_pattern_size; k++) {

	t_shift = k%real_pattern_size;
        //printf("Process for char: %c, T_A = %u, t_shift = %d\n", h_input_string[ i ], T_A, t_shift);
	

	if (h_input_string[ i+k ] == 'A') {
	    bit_vector = bit_vector + ((T_A >> t_shift*b) & mask);
	}
	else if (h_input_string[ i+k ] == 'C'){
	    bit_vector = bit_vector + ((T_C >> t_shift*b) & mask);
	}
	else if (h_input_string[ i+k ] == 'T'){
	    bit_vector = bit_vector + ((T_T >> t_shift*b) & mask);
	}
	else if (h_input_string[ i+k ] == 'G'){   //case of G
	    bit_vector = bit_vector + ((T_G >> t_shift*b) & mask);
	}
	else {  // can be char "\n" 
	    bit_vector = bit_vector + maskplus; 
	}
	//Get results
//	for (int j = no_of_patterns-1; j >= 0; j--) {
//             h_matched_result[i*no_of_patterns+j] = vector % pow_2b;
//             vector = vector >> b;
//        }

    	//printf("bit_vector: %u\n", bit_vector);
		
      }
	   for (int j = 0; j < real_pattern_size ; j++) {  //circular patterns
		//h_matched_result[(i-real_pattern_size+1)*real_pattern_size+(real_pattern_size-1-j)] += ((bit_vector >> (k*real_pattern_size+j)) & 1);
                h_matched_result[i*real_pattern_size+j] = bit_vector % pow_2b;
                bit_vector = bit_vector >> b;
	   }
    }// for h_input_string

    clock_gettime(CLOCK_REALTIME, &t_end);
    elapsedTime = (t_end.tv_sec*1000+t_end.tv_nsec/1000000)-(t_start.tv_sec*1000+t_start.tv_nsec/1000000);
*/

    //Process in GPU
    char *g_input_string;
    int *g_matched_result;
    int *g_pattern_decode;

    cudaMalloc (&g_input_string, sizeof(char)*input_size);
    cudaMalloc (&g_matched_result, sizeof(int)*(input_size-real_pattern_size+1)*real_pattern_size);
    cudaMalloc (&g_pattern_decode, sizeof(int)*4);

    cudaMemcpy (g_input_string, h_input_string, sizeof(char)*input_size, cudaMemcpyHostToDevice );
    cudaMemcpy (g_pattern_decode, h_pattern_decode, sizeof(int)*4, cudaMemcpyHostToDevice);


    // record time setting
    cudaEvent_t start, stop;
    float time;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);
    cudaEventRecord(start, 0);


    // step 3: run ASM on GPU           
    ASM_process_top ( g_input_string, input_size, g_pattern_decode, real_pattern_size, mask, maskplus, b, g_matched_result) ;

    // record time setting
    cudaEventRecord(stop, 0);
    cudaEventSynchronize(stop);
    cudaEventElapsedTime(&time, start, stop);

    cudaMemcpy (h_matched_result, g_matched_result, sizeof(int)*(input_size-real_pattern_size+1)*real_pattern_size, cudaMemcpyDeviceToHost );


    // step 4: output matched result
    int total_result = 0;
    for (int i = 0; i < input_size-(real_pattern_size-1); i++) {
        for (int j = 0; j < real_pattern_size; j++) {
            //printf("At position %4d, circular pattern %4d : match pattern %d\n", i, j, h_matched_result[i*real_pattern_size + j]);
	    if(h_matched_result[i*real_pattern_size + j] <= k_par) {total_result++;}
	}
    }
    printf("\n\n");
    printf("############################################################\n");
    printf("#--Approximate Circular String Matching with k-Mismatches--#\n");
    printf("#----------------------------------------------------------#\n");
    printf("#----------Modified shared-mem PCVM Alg. in GPU------------#\n");
    printf("############################################################\n");
    printf("#--Pattern Length            |\t\t %10d \t   #\n",real_pattern_size);
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
    free(h_matched_result); 

    cudaFree(g_input_string);
    cudaFree(g_pattern_decode);
    cudaFree(g_matched_result);
            
    return 0;
}
