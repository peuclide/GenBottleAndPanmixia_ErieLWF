#!/bin/bash
#BATCH --job-name=GDBImp_ch1
#SBATCH -A highmem
#SBATCH -N 1
#SBATCH -n 48
#SBATCH --array=1-5
#SBATCH -t 24:00:00
#SBATCH --mail-user=peuclide@purdue.edu
#SBATCH --output=/scratch/negishi/peuclide/Erie_WH_2024/output/GenDBI_99%A_%a.out
#SBATCH --error=/scratch/negishi/peuclide/Erie_WH_2024/output/GenDBI_99%A_%a.err


module purge
module load biocontainers
module load gatk4

PROJHOME=/scratch/negishi/peuclide/Erie_WH_2024/
HAPCALLS=/scratch/negishi/peuclide/Erie_WH_2024/gvcfs/
cd $PROJHOME

## Run array on each chromosome independently

arrayFileFull=$(find ./sarek/ -name '*LG99*.bed' -print | sort | cut -b 3-  | sed -n "$SLURM_ARRAY_TASK_ID"p)
arrayFile=$(basename "/$arrayFileFull")
arrayFilePre=$(basename "$arrayFile" .bed)

echo $arrayFileFull
echo $arrayFile
echo $arrayFilePre



tmp_dir=$(mktemp -d /scratch/negishi/peuclide/GenomicsDBImport.tmp.XXXXX)

##### set up database - once database is created need to add to it.


echo "build database start at: `date`"
export_JAVA_OPTIONS="-Xms8g -Xmxg56"

gatk GenomicsDBImport  \
       --genomicsdb-workspace-path $PROJHOME/${arrayFilePre}_db2 \
       --batch-size 20 \
       -L $arrayFileFull \
       --sample-name-map $HAPCALLS/file1-127.samps \
       --tmp-dir $tmp_dir \
       --reader-threads 4
#
echo "build database done at: `date`"
echo ""

##### genotype GVCFs
#
#java -Xms64g -Xmx120g  -jar ./gatk-package-4.1.7.0-local.jar \
#	GenotypeGVCFs \
#  -R reference/GCF_006149115.1_Oner_1.0_genomic.fna \
#  -L reference/GCF_006149115.1_Oner_1.0_genomic.fna.LG1-29.bed \
#  -V gendb://LG1-29_database \
#  -O vcfFiles/LG1-29_output.vcf
#
#echo "Genotypes done at: `date`"
#echo ""
#
### hard filter to ID high-quaity SNPs for recalibration
#
#
#java -Xms5g -Xmx120g  -jar ./gatk-package-4.1.7.0-local.jar \
#	VariantFiltration \
#	-R reference/GCF_006149115.1_Oner_1.0_genomic.fna \
#	-V vcfFiles/LG1-29_output.vcf \
#	--filter-expression "QD < 2.0 || FS > 60.0 || SOR < 3.0 || MQRankSum < -12.5 || ReadPosRankSum < -8.0" \
#	--filter-name "kris_snp_filter" \
#	-O vcfFiles/LG1-29_output.hard-filtered.vcf
#
#echo "Hard filter done at: `date`"
#
### create VCF with only hard filtered varients [done in interactive session]
#
##module load samtools
#
#bcftools view -i 'FILTER="PASS"' vcfFiles/LG1-29_output.hard-filtered.vcf > vcfFiles/LG1-29_output.PASS.hard-filtered.vcf
#
#echo "passed hard filter vcf done at: `date`"
#
