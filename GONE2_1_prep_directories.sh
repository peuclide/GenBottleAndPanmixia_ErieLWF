#!/bin/bash
  
#SBATCH -J GONE
#SBATCH -p general
#SBATCH -o /N/project/glfish/ErieWhitefish/0_December2025_ReAnalysis/GONE/GONE_analysis_%j.out
#SBATCH -e /N/project/glfish/ErieWhitefish/0_December2025_ReAnalysis/GONE/GONE_analysis_%j.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=peuclide@iu.edu
#SBATCH --nodes=1
#SBATCH --cpus-per-task=18
#SBATCH --time=48:30:00
#SBATCH --mem=48G
#SBATCH -A r01380

## GONE_SETUP

#1 create 5 random sets of 500k loci vcfs
module load bcftools
#mkdir GONE_REPS

VCF=GCF_020615455.1_ASM2061545v1_genomic.merged.snps.filt.no-fail.minDP5.maxDP100.maxMeanDp20.minMeanDP5.mac3.biallelic.ParaMask.mm85.recode.vcf.gz
X=500000

for i in {6..10}; do
  OUT=GONE_REPS/output.random_${X}.rep${i}.vcf.gz

  bcftools view -m2 -M2 -v snps "$VCF" \
    | bcftools query -f '%CHROM\t%POS\n' \
    | shuf -n "$X" \
    | sort -k1,1 -k2,2n \
    | bcftools view -R /dev/stdin "$VCF" -Oz -o "$OUT"

  tabix -p vcf "$OUT"
done
#
### split into Huron and Erie
module load vcftools

for i in {6..10}; do
  VCF=GONE_REPS/output.random_${X}.rep${i}.vcf.gz
  OUT=GONE_REPS/output.random_${X}.rep${i}.cr
	
  vcftools --gzvcf $VCF --keep CR.keep --recode --recode-INFO-all --out $OUT
  
  OUT=GONE_REPS/output.random_${X}.rep${i}.er
	
  vcftools --gzvcf $VCF --keep ER.keep --recode --recode-INFO-all --out $OUT
  
done

### create ped files for eachset

module load plink
OUTDIR=/N/project/glfish/ErieWhitefish/0_December2025_ReAnalysis/GONE

for i in {6..10}; do
  VCF=GONE_REPS/output.random_${X}.rep${i}.cr.recode.vcf
  OUT=output.random_${X}.rep${i}.cr
	
plink2 --vcf $VCF --export ped --out ${OUTDIR}/c${i}/$OUT

  VCF=GONE_REPS/output.random_${X}.rep${i}.er.recode.vcf
  OUT=output.random_${X}.rep${i}.er 
#	
plink2 --vcf $VCF --export ped --out ${OUTDIR}/e${i}/$OUT
    
done
#
### Re-name chromsomes in map files to numeric
cd $OUTDIR

for i in {6..10}; do
  MAP=./c${i}/output.random_${X}.rep${i}.cr.map
	
awk '{
  if (!($1 in chr)) {
    chr[$1] = ++n
    print $1 "\t" chr[$1] > "chr_relabel_lookup.txt"
  }
  $1 = chr[$1]
  print
}' $MAP > ${MAP}.tmp
mv ${MAP}.tmp $MAP

  MAP=./e${i}/output.random_${X}.rep${i}.er.map
	
awk '{
  if (!($1 in chr)) {
    chr[$1] = ++n
    print $1 "\t" chr[$1] > "chr_relabel_lookup.txt"
  }
  $1 = chr[$1]
  print
}' $MAP > ${MAP}.tmp
mv ${MAP}.tmp $MAP
    
done

## copy over GONE and run

for i in {6..10}; do
  REP=output.random_${X}.rep${i}.cr
	cd c${i}/
	cp -r ../GONEprog/* ./
	bash script_GONE.sh $REP

  REP=output.random_${X}.rep${i}.er
	cd ../e${i}/
	cp -r ../GONEprog/* ./
	bash script_GONE.sh $REP
    cd $OUTDIR
done


## END
