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
//int b = log2(sub_real_pattern)+1;
int pow_2b = 1 << b;
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
     
    //printf("\nT_A: %d\n", T_A);
    //printf("\nT_C: %d\n", T_C);
    //printf("\nT_T: %d\n", T_T);
    //printf("\nT_G: %d\n", T_G);

    //shift-add bit-vector.
    unsigned long long int bit_vector=0;
    int t_shift = 0;
    //int position = 0;
    #define BIT(x) (1<<(x))
    unsigned long long int mask = 0;
    for (int i = 0; i < real_pattern_size*b ; i++) {
	mask = (mask << 1) | 1;
    }
    unsigned long long int maskplus = 0;
    for (int i = 0; i < real_pattern_size ; i++) {
	maskplus = (maskplus << b) | 1;
    }

    //ACSM process
    struct timespec t_start, t_end;
    double elapsedTime;
    clock_gettime (CLOCK_REALTIME, &t_start);

    //for (int i = 0; h_input_string [ i ] ; i++) {
    for (int i = 0; i<input_size-(real_pattern_size-1) ; i++) {
	bit_vector = 0 ;
      for(int k=0; k<real_pattern_size; k++) {

	t_shift = k%real_pattern_size;
        //printf("Process for char: %c, T_A = %u, t_shift = %d\n", h_input_string[ i ], T_A, t_shift);
	

	if (h_input_string[ i+k ] == 'A') {
	    bit_vector = bit_vector + (((T_A << t_shift*b) & mask) | (T_A >> (real_pattern_size - t_shift)*b));
	}
	else if (h_input_string[ i+k ] == 'C'){
	    bit_vector = bit_vector + (((T_C << t_shift*b) & mask) | (T_C >> (real_pattern_size - t_shift)*b));
	}
	else if (h_input_string[ i+k ] == 'T'){
	    bit_vector = bit_vector + (((T_T << t_shift*b) & mask) | (T_T >> (real_pattern_size - t_shift)*b));
	}
	else if (h_input_string[ i+k ] == 'G'){   //case of G
	    bit_vector = bit_vector + (((T_G << t_shift*b) & mask) | (T_G >> (real_pattern_size - t_shift)*b));
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
	   for (int j = 0; j < real_pattern_size; j++) {  //circular patterns
		//h_matched_result[(i-real_pattern_size+1)*real_pattern_size+(real_pattern_size-1-j)] += ((bit_vector >> (k*real_pattern_size+j)) & 1);
                h_matched_result[i*real_pattern_size+j] = bit_vector % pow_2b;
                bit_vector = bit_vector >> b;
	   }
    }// for h_input_string

    clock_gettime(CLOCK_REALTIME, &t_end);
    elapsedTime = (t_end.tv_sec*1000+t_end.tv_nsec/1000000)-(t_start.tv_sec*1000+t_start.tv_nsec/1000000);
 
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
    printf("#--------------Modified CVM Alg. in CPU--------------------#\n");
    printf("############################################################\n");
    printf("#--Pattern Length            |\t\t %10d \t   #\n", real_pattern_size);
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
    free(h_matched_result); 
            
    return 0;
}
