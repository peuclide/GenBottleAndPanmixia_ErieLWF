#!/bin/bash

#SBATCH --job-name=Va2Tab_%a
#SBATCH -A standby
#SBATCH -t 4:00:00
#SBATCH -N 1
#SBATCH --array=1-300
#SBATCH -n 4
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=peuclide@purdue.edu
#SBATCH --output=/scratch/negishi/peuclide/Erie_WH_2024/output/varient2Table%A_%a.out
#SBATCH --error=/scratch/negishi/peuclide/Erie_WH_2024/output/varient2Table%A_%a.err

module purge
module load biocontainers
module load gatk4


PROJHOME=/scratch/negishi/peuclide/Erie_WH_2024
cd $PROJHOME/

arrayFileFull=$(find ./vcfFiles -name '*vcf' -print -maxdepth 1 | sort | cut -b 3-  | sed -n "$SLURM_ARRAY_TASK_ID"p)
arrayFile=$(basename "/$arrayFileFull")
arrayFilePre=$(basename "$arrayFile" .vcf)

echo "arrayFileFull:"
echo $arrayFileFull
echo "arrayFile:"
echo $arrayFile
echo "arrayFilePre:"
echo $arrayFilePre


#select SNP variants only

export_JAVA_OPTIONS="-Xms2g -Xmx10g"


gatk SelectVariants \
-V $arrayFileFull \
-select-type SNP \
-O $PROJHOME/vcfFiles/SNPFiltered/${arrayFilePre}.snps.vcf.gz

export_JAVA_OPTIONS="-Xms2g -Xmx8g"

gatk VariantsToTable \
-V $PROJHOME/vcfFiles/SNPFiltered/${arrayFilePre}.snps.vcf.gz \
-F CHROM \
-F POS \
-F DP \
-F QD \
-F FS \
-F MQ \
-F MQRankSum \
-F ReadPosRankSum \
-F SOR \
-O $PROJHOME/vcfFiles/SNPQC/${arrayFilePre}.snps.tab 

