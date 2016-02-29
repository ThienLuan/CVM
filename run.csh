#!/bin/sh

#Guide -> ./file.out PATTERN INPUT_STRING
#./simple_asm.out ./input/test/contents_v0.list ./input/test/defcon_v1.txt parameter_l parameter_k


./compile.csh

#test
#./0a_CVM_w32_cpu.out ./input/cmp_fix_pat_v1.txt ./input/dna_strings.txt 4 2 
#./0a_CVM_w64_cpu.out ./input/dna_patterns_v0.txt ./input/dna_strings.txt 4 2 
#./0b_PCVM_w32_gpu.out ./input/dna_patterns_v0.txt ./input/dna_strings.txt 4 2 
#./0b_PCVM_w64_gpu.out ./input/dna_patterns_v0.txt ./input/dna_strings.txt 4 2 
#./0c_sharedmem_PCVM_w32_gpu.out ./input/dna_patterns_v0.txt ./input/dna_strings.txt 4 2 
#./0c_sharedmem_PCVM_w64_gpu.out ./input/dna_patterns_v0.txt ./input/dna_strings.txt 4 2 
#./1a_modified_CVM_w32_cpu.out ./input/cmp_cir_pat_v1.txt ./input/dna_strings.txt 2
#./1a_modified_CVM_w64_cpu.out ./input/dna_patterns_v0.1.txt ./input/dna_strings.txt 3
#./1b_modified_PCVM_w32_gpu.out ./input/dna_patterns_v0.1.txt ./input/dna_strings.txt 3
#./1b_modified_PCVM_w64_gpu.out ./input/dna_patterns_v0.1.txt ./input/dna_strings.txt 3
#./1c_modified_sharedmem_PCVM_w32_gpu.out ./input/dna_patterns_v0.1.txt ./input/dna_strings.txt 3
#./1c_modified_sharedmem_PCVM_w64_gpu.out ./input/dna_patterns_v0.1.txt ./input/dna_strings.txt 3
#./2a_BVM_cpu.out ./input/cmp_fix_pat_v1.txt ./input/dna_strings.txt 4 2
#./2b_PBVM_gpu.out ./input/dna_patterns_v0.txt ./input/dna_strings.txt 4 2

#test for increasing of parameter l or pattern length m
#./0a_CVM_w32_cpu.out ./input/dna_patterns_v4.txt ./input/dna_strings_v0_3.14M.txt 4 2 
#./0a_CVM_w64_cpu.out ./input/dna_patterns_v4.txt ./input/dna_strings_v0_3.14M.txt 4 2 
#./0b_PCVM_w32_gpu.out ./input/dna_patterns_v4.txt ./input/dna_strings_v0_3.14M.txt 4 2 
#./0b_PCVM_w64_gpu.out ./input/dna_patterns_v4.txt ./input/dna_strings_v0_3.14M.txt 4 2 
#./0c_sharedmem_PCVM_w32_gpu.out ./input/dna_patterns_v4.txt ./input/dna_strings_v0_3.14M.txt 4 2 
#./0c_sharedmem_PCVM_w64_gpu.out ./input/dna_patterns_v4.txt ./input/dna_strings_v0_3.14M.txt 4 2 
#./2a_BVM_cpu.out ./input/dna_patterns_v4.txt ./input/dna_strings_v0_3.14M.txt 4 2
#./2b_PBVM_gpu.out ./input/dna_patterns_v4.txt ./input/dna_strings_v0_3.14M.txt 4 2

#Fixed-length ASM and ACSM
./0a_CVM_w32_cpu.out ./input/cmp_fix_pat_v2.txt ./input/dna_strings_v4_17.56M.txt 3 2 
./0a_CVM_w64_cpu.out ./input/cmp_fix_pat_v2.txt ./input/dna_strings_v4_17.56M.txt 3 2 
./0b_PCVM_w32_gpu.out ./input/cmp_fix_pat_v2.txt ./input/dna_strings_v4_17.56M.txt 3 2 
./0b_PCVM_w64_gpu.out ./input/cmp_fix_pat_v2.txt ./input/dna_strings_v4_17.56M.txt 3 2 
./0c_sharedmem_PCVM_w32_gpu.out ./input/cmp_fix_pat_v2.txt ./input/dna_strings_v4_17.56M.txt 3 2 
./0c_sharedmem_PCVM_w64_gpu.out ./input/cmp_fix_pat_v2.txt ./input/dna_strings_v4_17.56M.txt 3 2 
./1a_modified_CVM_w32_cpu.out ./input/cmp_cir_pat_v2.txt ./input/dna_strings_v4_17.56M.txt 2
./1a_modified_CVM_w64_cpu.out ./input/cmp_cir_pat_v2.txt ./input/dna_strings_v4_17.56M.txt 2
./1b_modified_PCVM_w32_gpu.out ./input/cmp_cir_pat_v2.txt ./input/dna_strings_v4_17.56M.txt 2
./1b_modified_PCVM_w64_gpu.out ./input/cmp_cir_pat_v2.txt ./input/dna_strings_v4_17.56M.txt 2
./1c_modified_sharedmem_PCVM_w32_gpu.out ./input/cmp_cir_pat_v2.txt ./input/dna_strings_v4_17.56M.txt 2
./1c_modified_sharedmem_PCVM_w64_gpu.out ./input/cmp_cir_pat_v2.txt ./input/dna_strings_v4_17.56M.txt 2

#real data
#./0a_CVM_w32_cpu.out ./input/dna_patterns_v0.txt ./input/dna_strings_v0_3.14M.txt 4 2 
#./0a_CVM_w64_cpu.out ./input/dna_patterns_v0.txt ./input/dna_strings_v0_3.14M.txt 4 2 
#./0b_PCVM_w32_gpu.out ./input/dna_patterns_v0.txt ./input/dna_strings_v0_3.14M.txt 4 2 
#./0b_PCVM_w64_gpu.out ./input/dna_patterns_v0.txt ./input/dna_strings_v0_3.14M.txt 4 2 
#./0c_sharedmem_PCVM_w32_gpu.out ./input/dna_patterns_v0.txt ./input/dna_strings_v0_3.14M.txt 4 2 
#./0c_sharedmem_PCVM_w64_gpu.out ./input/dna_patterns_v0.txt ./input/dna_strings_v0_3.14M.txt 4 2 
#./1a_modified_CVM_w32_cpu.out ./input/dna_patterns_v0.1.txt ./input/dna_strings_v0_3.14M.txt 3
#./1a_modified_CVM_w64_cpu.out ./input/dna_patterns_v0.1.txt ./input/dna_strings_v0_3.14M.txt 3
#./1b_modified_PCVM_w32_gpu.out ./input/dna_patterns_v0.1.txt ./input/dna_strings_v0_3.14M.txt 3
#./1b_modified_PCVM_w64_gpu.out ./input/dna_patterns_v0.1.txt ./input/dna_strings_v0_3.14M.txt 3
#./1c_modified_sharedmem_PCVM_w32_gpu.out ./input/dna_patterns_v0.1.txt ./input/dna_strings_v0_3.14M.txt 3
#./1c_modified_sharedmem_PCVM_w64_gpu.out ./input/dna_patterns_v0.1.txt ./input/dna_strings_v0_3.14M.txt 3
#./2a_BVM_cpu.out ./input/dna_patterns_v0.txt ./input/dna_strings_v0_3.14M.txt 4 2
#./2b_PBVM_gpu.out ./input/dna_patterns_v0.txt ./input/dna_strings_v0_3.14M.txt 4 2

#./0a_CVM_w32_cpu.out ./input/dna_patterns_v0.txt ./input/dna_strings_v1_4.86M.txt 4 3 
#./0b_PCVM_w32_gpu.out ./input/dna_patterns_v0.txt ./input/dna_strings_v1_4.86M.txt 4 3 
#./0c_sharedmem_PCVM_w32_gpu.out ./input/dna_patterns_v0.txt ./input/dna_strings_v1_4.86M.txt 4 3 
#./1_ASM_w32_cpu.out ./input/dna_patterns_v0.txt ./input/dna_strings_v1_4.86M.txt 4 3
#./2a_BVM_cpu.out ./input/dna_patterns_v0.txt ./input/dna_strings_v1_4.86M.txt 4 3
#./2b_PBVM_gpu.out ./input/dna_patterns_v0.txt ./input/dna_strings_v1_4.86M.txt 4 3
#./3_naive_ASM_w32_cpu.out ./input/dna_patterns_v0.txt ./input/dna_strings_v1_4.86M.txt 4 3

#./0a_CVM_w32_cpu.out ./input/dna_patterns_v0.txt ./input/dna_strings_v2_7.74M.txt 4 3 
#./0b_PCVM_w32_gpu.out ./input/dna_patterns_v0.txt ./input/dna_strings_v2_7.74M.txt 4 3 
#./0c_sharedmem_PCVM_w32_gpu.out ./input/dna_patterns_v0.txt ./input/dna_strings_v2_7.74M.txt 4 3 
#./1_ASM_w32_cpu.out ./input/dna_patterns_v0.txt ./input/dna_strings_v2_7.74M.txt 4 3
#./2a_BVM_cpu.out ./input/dna_patterns_v0.txt ./input/dna_strings_v2_7.74M.txt 4 3
#./2b_PBVM_gpu.out ./input/dna_patterns_v0.txt ./input/dna_strings_v2_7.74M.txt 4 3
#./3_naive_ASM_w32_cpu.out ./input/dna_patterns_v0.txt ./input/dna_strings_v2_7.74M.txt 4 3

#./0a_CVM_w32_cpu.out ./input/dna_patterns_v0.txt ./input/dna_strings_v3_12.88M.txt 4 3
#./0b_PCVM_w32_gpu.out ./input/dna_patterns_v0.txt ./input/dna_strings_v3_12.88M.txt 4 3
#./0c_sharedmem_PCVM_w32_gpu.out ./input/dna_patterns_v0.txt ./input/dna_strings_v3_12.88M.txt 4 3
#./1_ASM_w32_cpu.out ./input/dna_patterns_v0.txt ./input/dna_strings_v3_12.88M.txt 4 3
#./2a_BVM_cpu.out ./input/dna_patterns_v0.txt ./input/dna_strings_v3_12.88M.txt 4 3
#./2b_PBVM_gpu.out ./input/dna_patterns_v0.txt ./input/dna_strings_v3_12.88M.txt 4 3
#./3_naive_ASM_w32_cpu.out ./input/dna_patterns_v0.txt ./input/dna_strings_v3_12.88M.txt 4 3

#./0a_CVM_w32_cpu.out ./input/dna_patterns_v0.txt ./input/dna_strings_v4_17.56M.txt 4 3
#./0b_PCVM_w32_gpu.out ./input/dna_patterns_v0.txt ./input/dna_strings_v4_17.56M.txt 4 3
#./0c_sharedmem_PCVM_w32_gpu.out ./input/dna_patterns_v0.txt ./input/dna_strings_v4_17.56M.txt 4 3
#./1_ASM_w32_cpu.out ./input/dna_patterns_v0.txt ./input/dna_strings_v4_17.56M.txt 4 3
#./2a_BVM_cpu.out ./input/dna_patterns_v0.txt ./input/dna_strings_v4_17.56M.txt 4 3
#./2b_PBVM_gpu.out ./input/dna_patterns_v0.txt ./input/dna_strings_v4_17.56M.txt 4 3
#./3_naive_ASM_w32_cpu.out ./input/dna_patterns_v0.txt ./input/dna_strings_v4_17.56M.txt 4 3

#randome patterns
#./1_ASM_w32_cpu.out ./input/ran_pat_1.txt ./input/dna_strings_v3_12.88M.txt 4 3
#./2_bit_vector_ASM_w32_cpu.out ./input/ran_pat_1.txt ./input/dna_strings_v3_12.88M.txt 4 3
#./3_naive_ASM_w32_cpu.out ./input/ran_pat_1.txt ./input/dna_strings_v3_12.88M.txt 4 3
#
#./1_ASM_w32_cpu.out ./input/ran_pat_2.txt ./input/dna_strings_v3_12.88M.txt 4 3
#./2_bit_vector_ASM_w32_cpu.out ./input/ran_pat_2.txt ./input/dna_strings_v3_12.88M.txt 4 3
#./3_naive_ASM_w32_cpu.out ./input/ran_pat_2.txt ./input/dna_strings_v3_12.88M.txt 4 3
#
#./1_ASM_w32_cpu.out ./input/ran_pat_3.txt ./input/dna_strings_v3_12.88M.txt 4 3
#./2_bit_vector_ASM_w32_cpu.out ./input/ran_pat_3.txt ./input/dna_strings_v3_12.88M.txt 4 3
#./3_naive_ASM_w32_cpu.out ./input/ran_pat_3.txt ./input/dna_strings_v3_12.88M.txt 4 3
#
#./1_ASM_w32_cpu.out ./input/ran_pat_4.txt ./input/dna_strings_v3_12.88M.txt 4 3
#./2_bit_vector_ASM_w32_cpu.out ./input/ran_pat_4.txt ./input/dna_strings_v3_12.88M.txt 4 3
#./3_naive_ASM_w32_cpu.out ./input/ran_pat_4.txt ./input/dna_strings_v3_12.88M.txt 4 3
#
#./1_ASM_w32_cpu.out ./input/ran_pat_5.txt ./input/dna_strings_v3_12.88M.txt 4 3
#./2_bit_vector_ASM_w32_cpu.out ./input/ran_pat_5.txt ./input/dna_strings_v3_12.88M.txt 4 3
#./3_naive_ASM_w32_cpu.out ./input/ran_pat_5.txt ./input/dna_strings_v3_12.88M.txt 4 3
#
#./1_ASM_w32_cpu.out ./input/ran_pat_6.txt ./input/dna_strings_v3_12.88M.txt 4 3
#./2_bit_vector_ASM_w32_cpu.out ./input/ran_pat_6.txt ./input/dna_strings_v3_12.88M.txt 4 3
#./3_naive_ASM_w32_cpu.out ./input/ran_pat_6.txt ./input/dna_strings_v3_12.88M.txt 4 3
#
#./1_ASM_w32_cpu.out ./input/ran_pat_7.txt ./input/dna_strings_v3_12.88M.txt 4 3
#./2_bit_vector_ASM_w32_cpu.out ./input/ran_pat_7.txt ./input/dna_strings_v3_12.88M.txt 4 3
#./3_naive_ASM_w32_cpu.out ./input/ran_pat_7.txt ./input/dna_strings_v3_12.88M.txt 4 3
#
#./1_ASM_w32_cpu.out ./input/ran_pat_8.txt ./input/dna_strings_v3_12.88M.txt 4 3
#./2_bit_vector_ASM_w32_cpu.out ./input/ran_pat_8.txt ./input/dna_strings_v3_12.88M.txt 4 3
#./3_naive_ASM_w32_cpu.out ./input/ran_pat_8.txt ./input/dna_strings_v3_12.88M.txt 4 3
#
#./1_ASM_w32_cpu.out ./input/ran_pat_9.txt ./input/dna_strings_v3_12.88M.txt 4 3
#./2_bit_vector_ASM_w32_cpu.out ./input/ran_pat_9.txt ./input/dna_strings_v3_12.88M.txt 4 3
#./3_naive_ASM_w32_cpu.out ./input/ran_pat_9.txt ./input/dna_strings_v3_12.88M.txt 4 3
#
#./1_ASM_w32_cpu.out ./input/ran_pat_10.txt ./input/dna_strings_v3_12.88M.txt 4 3
#./2_bit_vector_ASM_w32_cpu.out ./input/ran_pat_10.txt ./input/dna_strings_v3_12.88M.txt 4 3
#./3_naive_ASM_w32_cpu.out ./input/ran_pat_10.txt ./input/dna_strings_v3_12.88M.txt 4 3
#
#./1_ASM_w32_cpu.out ./input/ran_pat_11.txt ./input/dna_strings_v3_12.88M.txt 4 3
#./2_bit_vector_ASM_w32_cpu.out ./input/ran_pat_11.txt ./input/dna_strings_v3_12.88M.txt 4 3
#./3_naive_ASM_w32_cpu.out ./input/ran_pat_11.txt ./input/dna_strings_v3_12.88M.txt 4 3
#
#./1_ASM_w32_cpu.out ./input/ran_pat_12.txt ./input/dna_strings_v3_12.88M.txt 4 3
#./2_bit_vector_ASM_w32_cpu.out ./input/ran_pat_12.txt ./input/dna_strings_v3_12.88M.txt 4 3
#./3_naive_ASM_w32_cpu.out ./input/ran_pat_12.txt ./input/dna_strings_v3_12.88M.txt 4 3
#
#./1_ASM_w32_cpu.out ./input/ran_pat_13.txt ./input/dna_strings_v3_12.88M.txt 4 3
#./2_bit_vector_ASM_w32_cpu.out ./input/ran_pat_13.txt ./input/dna_strings_v3_12.88M.txt 4 3
#./3_naive_ASM_w32_cpu.out ./input/ran_pat_13.txt ./input/dna_strings_v3_12.88M.txt 4 3
#
#./1_ASM_w32_cpu.out ./input/ran_pat_14.txt ./input/dna_strings_v3_12.88M.txt 4 3
#./2_bit_vector_ASM_w32_cpu.out ./input/ran_pat_14.txt ./input/dna_strings_v3_12.88M.txt 4 3
#./3_naive_ASM_w32_cpu.out ./input/ran_pat_14.txt ./input/dna_strings_v3_12.88M.txt 4 3
#
#./1_ASM_w32_cpu.out ./input/ran_pat_15.txt ./input/dna_strings_v3_12.88M.txt 4 3
#./2_bit_vector_ASM_w32_cpu.out ./input/ran_pat_15.txt ./input/dna_strings_v3_12.88M.txt 4 3
#./3_naive_ASM_w32_cpu.out ./input/ran_pat_15.txt ./input/dna_strings_v3_12.88M.txt 4 3
#
#./1_ASM_w32_cpu.out ./input/ran_pat_16.txt ./input/dna_strings_v3_12.88M.txt 4 3
#./2_bit_vector_ASM_w32_cpu.out ./input/ran_pat_16.txt ./input/dna_strings_v3_12.88M.txt 4 3
#./3_naive_ASM_w32_cpu.out ./input/ran_pat_16.txt ./input/dna_strings_v3_12.88M.txt 4 3
#
#./1_ASM_w32_cpu.out ./input/ran_pat_17.txt ./input/dna_strings_v3_12.88M.txt 4 3
#./2_bit_vector_ASM_w32_cpu.out ./input/ran_pat_17.txt ./input/dna_strings_v3_12.88M.txt 4 3
#./3_naive_ASM_w32_cpu.out ./input/ran_pat_17.txt ./input/dna_strings_v3_12.88M.txt 4 3
#
#./1_ASM_w32_cpu.out ./input/ran_pat_18.txt ./input/dna_strings_v3_12.88M.txt 4 3
#./2_bit_vector_ASM_w32_cpu.out ./input/ran_pat_18.txt ./input/dna_strings_v3_12.88M.txt 4 3
#./3_naive_ASM_w32_cpu.out ./input/ran_pat_18.txt ./input/dna_strings_v3_12.88M.txt 4 3
#
#./1_ASM_w32_cpu.out ./input/ran_pat_19.txt ./input/dna_strings_v3_12.88M.txt 4 3
#./2_bit_vector_ASM_w32_cpu.out ./input/ran_pat_19.txt ./input/dna_strings_v3_12.88M.txt 4 3
#./3_naive_ASM_w32_cpu.out ./input/ran_pat_19.txt ./input/dna_strings_v3_12.88M.txt 4 3
#
#./1_ASM_w32_cpu.out ./input/ran_pat_20.txt ./input/dna_strings_v3_12.88M.txt 4 3
#./2_bit_vector_ASM_w32_cpu.out ./input/ran_pat_20.txt ./input/dna_strings_v3_12.88M.txt 4 3
#./3_naive_ASM_w32_cpu.out ./input/ran_pat_20.txt ./input/dna_strings_v3_12.88M.txt 4 3

#change of pattern lengths
#./1_ASM_w32_cpu.out ./input/dna_patterns_v0.txt ./input/dna_strings_v4_17.56M.txt 2
#./2_bit_vector_ASM_w32_cpu.out ./input/dna_patterns_v0.txt ./input/dna_strings_v4_17.56M.txt 2
#./3_naive_ASM_w32_cpu.out ./input/dna_patterns_v0.txt ./input/dna_strings_v4_17.56M.txt 2

#./1_ASM_w32_cpu.out ./input/dna_patterns_v1.txt ./input/dna_strings_v4_17.56M.txt 2
#./2_bit_vector_ASM_w32_cpu.out ./input/dna_patterns_v1.txt ./input/dna_strings_v4_17.56M.txt 2
#./3_naive_ASM_w32_cpu.out ./input/dna_patterns_v1.txt ./input/dna_strings_v4_17.56M.txt 2

#./1_ASM_w32_cpu.out ./input/dna_patterns_v2.txt ./input/dna_strings_v4_17.56M.txt 2
#./2_bit_vector_ASM_w32_cpu.out ./input/dna_patterns_v2.txt ./input/dna_strings_v4_17.56M.txt 2
#./3_naive_ASM_w32_cpu.out ./input/dna_patterns_v2.txt ./input/dna_strings_v4_17.56M.txt 2

#./2_bit_vector_ASM_w32_cpu.out ./input/dna_patterns_v3.txt ./input/dna_strings_v4_17.56M.txt 2
#./2_bit_vector_ASM_w32_cpu.out ./input/dna_patterns_v4.txt ./input/dna_strings_v4_17.56M.txt 2
