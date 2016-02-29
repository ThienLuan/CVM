#!/bin/sh

nvcc ./0a_CVM_w32_cpu.cu -o ./0a_CVM_w32_cpu.out
nvcc ./0b_PCVM_w32_gpu.cu -o ./0b_PCVM_w32_gpu.out
nvcc ./0c_sharedmem_PCVM_w32_gpu.cu -o ./0c_sharedmem_PCVM_w32_gpu.out
nvcc ./1a_modified_CVM_w32_cpu.cu -o ./1a_modified_CVM_w32_cpu.out 
nvcc ./1b_modified_PCVM_w32_gpu.cu -o ./1b_modified_PCVM_w32_gpu.out 
nvcc ./1c_modified_sharedmem_PCVM_w32_gpu.cu -o ./1c_modified_sharedmem_PCVM_w32_gpu.out 

nvcc ./0a_CVM_w64_cpu.cu -o ./0a_CVM_w64_cpu.out
nvcc ./0b_PCVM_w64_gpu.cu -o ./0b_PCVM_w64_gpu.out
nvcc ./0c_sharedmem_PCVM_w64_gpu.cu -o ./0c_sharedmem_PCVM_w64_gpu.out
nvcc ./1a_modified_CVM_w64_cpu.cu -o ./1a_modified_CVM_w64_cpu.out 
nvcc ./1b_modified_PCVM_w64_gpu.cu -o ./1b_modified_PCVM_w64_gpu.out 
nvcc ./1c_modified_sharedmem_PCVM_w64_gpu.cu -o ./1c_modified_sharedmem_PCVM_w64_gpu.out 

nvcc ./2a_BVM_cpu.cu -o ./2a_BVM_cpu.out
nvcc ./2b_PBVM_gpu.cu -o ./2b_PBVM_gpu.out
