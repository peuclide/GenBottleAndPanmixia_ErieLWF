#!/bin/bash
  
#SBATCH -n 12
#SBATCH -A peuclide
#SBATCH -A r01380
#SBATCH -t 12:00:00
#SBATCH -N 1
#SBATCH --mail-user=peuclide@iu.edu
#SBATCH --mail-type=begin
#SBATCH --mail-type=end
#SBATCH --job-name=ParaMask
#SBATCH --output=//N/project/glfish/ErieWhitefish/outputs/LWF_ParaMask%A_%a.out
#SBATCH --error=/N/project/glfish/ErieWhitefish/outputs/LWF_ParaMask%A_%a.err

module load java
module load R

Rscript /geode2/home/u070/peuclide/Quartz/R/x86_64-pc-linux-gnu-library/4.4/ParaMaskEM/scripts/run_ParaMask_EM.R \
--het GCF_020615455.1_ASM2061545v1_genomic.merged.snps.filt.no-fail.minDP5.maxDP100.maxMeanDp20.minMeanDP5.mac3.biallelic.recode.vcf.het.stat.txt \
--missing 0.1
--nSNPs 50000
--ID ErieWH
--outdir /N/project/glfish/ErieWhitefish/ErieWH_re-filter_QC/ParaMask_Dec8

WD=/N/project/glfish/ErieWhitefish/ErieWH_re-filter_QC

java -jar ~/Programs/ParaMask/ParaMask/ParaMask_Cluster_Seeds.jar \
        --cov $WD/GCF_020615455.1_ASM2061545v1_genomic.merged.snps.filt.no-fail.minDP5.maxDP100.maxMeanDp20.minMeanDP5.mac3.biallelic.recode.vcf.cov.stat.txt \
        --het $WD/ParaMask_Dec8/ErieWH_EMresults.het \
        --covgw  $WD/GCF_020615455.1_ASM2061545v1_genomic.merged.snps.filt.no-fail.minDP5.maxDP100.maxMeanDp20.minMeanDP5.mac3.biallelic.recode.vcf.cov.gw.txt \
        --cutoff  $(tail -1 $WD/ParaMask_Dec8/ErieWH_EMresults.dist)
