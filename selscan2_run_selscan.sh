#!/bin/bash

#SBATCH -n 12
#SBATCH --mem=24G
#SBATCH -A r01380
#SBATCH -p general
#SBATCH -t 06:30:00
#SBATCH --mail-user=peuclide@iu.edu
#SBATCH --mail-type=begin
#SBATCH --mail-type=end
#SBATCH --job-name=selscan
#SBATCH --output=/N/project/glfish/ErieWhitefish/outputs/SELSCAN%A_%a.out
#SBATCH --error=/N/project/glfish/ErieWhitefish/outputs/SELSCAN%A_%a.err

## make VCF files for each populations being compared. 
module load vcftools
cd /N/project/glfish/ErieWhitefish/0_December2025_ReAnalysis/SELSCAN

for i in $(seq 192 231); do
    VCF="NC_059${i}.1.phased.vcf.gz"
    OUT1="NC_059${i}.1.phased.LP"
    OUT2="NC_059${i}.1.phased.TRNR"
    OUT3="NC_059${i}.1.phased.CR"
    OUT4="NC_059${i}.1.phased.MB"
vcftools --gzvcf ../BEAGLE/${VCF} --out $OUT1 --recode --recode-INFO-all --keep LP.keep
vcftools --gzvcf ../BEAGLE/${VCF} --out $OUT2 --recode --recode-INFO-all --keep TR_NR.keep
vcftools --gzvcf ../BEAGLE/${VCF} --out $OUT3 --recode --recode-INFO-all --keep CR.keep
vcftools --gzvcf ../BEAGLE/${VCF} --out $OUT4 --recode --recode-INFO-all --keep MB.keep


done

### RUN SELSCAN
echo "selscan begin:"


## loop through all files and run selscan
## TRNR vs LP
ALT="LP"
REF="TRNR"

for i in $(seq 192 231); do
    LG="NC_059${i}.1.phased"
    ~/Programs/selscan/src/selscan \
        --xpehh \
        --vcf "${LG}.${ALT}.recode.vcf" \
        --vcf-ref "${LG}.${REF}.recode.vcf" \
        --pmap \
        --out "${LG}.${ALT}-${REF}"
done

echo "${ALT} vs ${REF} DONE"

## TRNR vs MB

ALT="MB"
REF="TRNR"

for i in $(seq 192 231); do
    LG="NC_059${i}.1.phased"
    ~/Programs/selscan/src/selscan \
        --xpehh \
        --vcf "${LG}.${ALT}.recode.vcf" \
        --vcf-ref "${LG}.${REF}.recode.vcf" \
        --pmap \
        --out "${LG}.${ALT}-${REF}"
done
echo "${ALT} vs ${REF} DONE"

## TRNR vs CR

ALT="CR"
REF="TRNR"

for i in $(seq 192 231); do
    LG="NC_059${i}.1.phased"
    ~/Programs/selscan/src/selscan \
        --xpehh \
        --vcf "${LG}.${ALT}.recode.vcf" \
        --vcf-ref "${LG}.${REF}.recode.vcf" \
        --pmap \
        --out "${LG}.${ALT}-${REF}"
done
echo "${ALT} vs ${REF} DONE"

## MB vs LP

ALT="LP"
REF="MB"

for i in $(seq 192 231); do
    LG="NC_059${i}.1.phased"
    ~/Programs/selscan/src/selscan \
        --xpehh \
        --vcf "${LG}.${ALT}.recode.vcf" \
        --vcf-ref "${LG}.${REF}.recode.vcf" \
        --pmap \
        --out "${LG}.${ALT}-${REF}"
done
echo "${ALT} vs ${REF} DONE"

## CR vs LP

ALT="CR"
REF="LP"

for i in $(seq 192 231); do
    LG="NC_059${i}.1.phased"
    ~/Programs/selscan/src/selscan \
        --xpehh \
        --vcf "${LG}.${ALT}.recode.vcf" \
        --vcf-ref "${LG}.${REF}.recode.vcf" \
        --pmap \
        --out "${LG}.${ALT}-${REF}"
done
echo "${ALT} vs ${REF} DONE"

## CR vs MB

ALT="CR"
REF="MB"

for i in $(seq 192 231); do
    LG="NC_059${i}.1.phased"
    ~/Programs/selscan/src/selscan \
        --xpehh \
        --vcf "${LG}.${ALT}.recode.vcf" \
        --vcf-ref "${LG}.${REF}.recode.vcf" \
        --pmap \
        --out "${LG}.${ALT}-${REF}"
done
echo "${ALT} vs ${REF} DONE"

echo "ALL DONE"

