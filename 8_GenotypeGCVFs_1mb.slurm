#!/bin/bash
#BATCH --job-name=GenotypeGVCFs
#SBATCH -A standby
#SBATCH -N 1
#SBATCH -n 8
#SBATCH --array=1-20
#SBATCH -t 4:00:00
#SBATCH --mail-user=peuclide@purdue.edu
#SBATCH --output=/scratch/negishi/peuclide/Erie_WH_2024/output/GenotypeGVCFs%A_%a.out
#SBATCH --error=/scratch/negishi/peuclide/Erie_WH_2024/output/GenotypeGVCFs%A_%a.err

#module force  purge
module load biocontainers
module load gatk4

PROJHOME=/scratch/negishi/peuclide/Erie_WH_2024/

cd $PROJHOME

# Need to split bed files into 1mb sections separately, then run array across all the bed files

arrayFileFull=$(find ./LG1_bed/ -name '*LG1_20*.bed' -print | sort | cut -b 3-  | sed -n "$SLURM_ARRAY_TASK_ID"p)
arrayFile=$(basename "/$arrayFileFull")
arrayFilePre=$(basename "$arrayFile" .bed)


echo "inputs:"
echo  ""
echo $arrayFileFull
echo $arrayFile
echo $arrayFilePre

echo ""


tmp_dir=$(mktemp -d /scratch/negishi/peuclide/GenotypeGVCFs.tmp.XXXXX)

##### set up database - once database is created need to add to it.


#echo "build database start at: `date`"

#/home/peuclide/gatk-4.2.2.0/gatk --java-options "-Xmx4g -Xms4g" GenomicsDBImport  \
#       --genomicsdb-update-workspace-path $PROJHOME/${arrayFilePre}_db \
#       --batch-size 15 \
#       -L $arrayFileFull \
#       --sample-name-map $PROJHOME/File1to10.samps \
#       --tmp-dir $tmp_dir \
#       --reader-threads 1
#
#echo "build database done at: `date`"
#echo ""

#rm -r tmp_dir

echo "genotypeGVCFs start at: `date`"

##### genotype GVCFs
export_JAVA_OPTIONS="-Xms2g -Xmx4g"

gatk GenotypeGVCFs \
  -R sarek/GCF_020615455.1_ASM2061545v1_genomic.fna.gz \
  -L $arrayFileFull \
  -V gendb://GCF_020615455.1_ASM2061545v1_genomic.fna.gz.LG1_db2 \
  -O vcfFiles/${arrayFilePre}.vcf \
  --tmp-dir $tmp_dir


#rm -r $tmp_dir

#echo "Genotypes done at: `date`"
#echo ""

## END
