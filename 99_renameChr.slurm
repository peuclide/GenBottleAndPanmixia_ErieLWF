#!/bin/sh

#SBATCH -n 24
#SBATCH -t 24:00:00
#SBATCH -A peuclide
#SBATCH --output=/scratch/negishi/peuclide/Erie_WH_2024/output/rename_vcf_%A_%a.out
#SBATCH --error=/scratch/negishi/peuclide/Erie_WH_2024/output/rename_vcf_%A_%a.err


cd /scratch/negishi/peuclide/Erie_WH_2024/vcfFiles/vcftoolFiltered


ml biocontainers
ml bcftools
ml htslib
ml samtools


bgzip GCF_020615455.1_ASM2061545v1_genomic.merged.snps.filt.no-fail.minDP3.maxDP1000.biallelic_high_quality_sites_gt85.hwe.recode.vcf
tabix -p vcf GCF_020615455.1_ASM2061545v1_genomic.merged.snps.filt.no-fail.minDP3.maxDP1000.biallelic_high_quality_sites_gt85.hwe.recode.vcf.gz

bcftools annotate --rename-chrs ~/2022_WH_scripts/RenameChr GCF_020615455.1_ASM2061545v1_genomic.merged.snps.filt.no-fail.minDP3.maxDP1000.biallelic_high_quality_sites_gt85.hwe.recode.vcf.gz -Oz -o GCF_020615455.1_ASM2061545v1_genomic.merged.snps.filt.no-fail.minDP3.maxDP1000.biallelic_high_quality_sites_gt85.hwe.numLG.vcf.gz


## END