#!/bin/bash -l

#SBATCH -n 24
#SBATCH -t 24:00:00
#SBATCH -A peuclide
#SBATCH --output=./BWA_ref_%A_%a.out
#SBATCH --error=./BWA_ref_%A_%a.err

module load biocontainers
module load bwa
module load samtools


#echo "making index"

#bwa index ./GCF_020615455.1_ASM2061545v1_cds_from_genomic.fna.gz ## basically takes your yellow perch genome and creates a index file(s). This only needs to be done one time.
#bwa index ./GCA_964263955.1_fCorLav1.hap1.1_genomic.fna.gz

bwa index ./GCF_020615455.1_ASM2061545v1_genomic.fna.gz


#echo "index complete"
