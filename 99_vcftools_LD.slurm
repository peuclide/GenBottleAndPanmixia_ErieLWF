#!/bin/bash
#BATCH --job-name=VCFfilts
#SBATCH -A peuclide
#SBATCH -N 1
#SBATCH -n 8
#SBATCH -t 48:00:00
#SBATCH --mail-user=peuclide@purdue.edu
#SBATCH --output=/scratch/negishi/peuclide/Erie_WH_2024/output/vcfFilts_%A.out
#SBATCH --error=/scratch/negishi/peuclide/Erie_WH_2024/output/vcfFilts_%A.err

module load purge
module load biocontainers
module load vcftools


PROJHOME=/scratch/negishi/peuclide/Erie_WH_2024
cd $PROJHOME/


echo "FilterVCFs start at:  `date`"


cd /scratch/negishi/peuclide/Erie_WH_2024/vcfFiles/HardFiltered/

vcftools --vcf GCF_020615455.1_ASM2061545v1_genomic.RAD.merged.snps.filt.mac3.GQ20.recode.vcf --geno-r2 --ld-window-bp 1000000 --ld-window-bp-min 10000 --out GCF.RAD.merged.snps.filt.mac3.GQ20 


##END
