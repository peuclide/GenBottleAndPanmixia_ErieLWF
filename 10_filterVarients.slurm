#!/bin/bash
#BATCH --job-name=HardFilter
#SBATCH -A standby
#SBATCH -N 1
#SBATCH -n 4
#SBATCH --array=1-300
#SBATCH -t 4:00:00
#SBATCH --mail-user=peuclide@purdue.edu
#SBATCH --output=/scratch/negishi/peuclide/Erie_WH_2024/output/GenDBI_1-10%A_%a.out
#SBATCH --error=/scratch/negishi/peuclide/Erie_WH_2024/output/GenDBI_1-10%A_%a.err

module purge
module load biocontainers
module load gatk4

PROJHOME=/scratch/negishi/peuclide/Erie_WH_2024/


cd $PROJHOME/

arrayFileFull=$(find ./vcfFiles/SNPFiltered/ -name '*vcf.gz' -print -maxdepth 1 | sort | cut -b 3-  | sed -n "$SLURM_ARRAY_TASK_ID"p)
arrayFile=$(basename "/$arrayFileFull")
arrayFilePre=$(basename "$arrayFile" .snps.vcf.gz)

echo "arrayFileFull:"
echo $arrayFileFull
echo "arrayFile:"
echo $arrayFile
echo "arrayFilePre:"
echo $arrayFilePre


#select SNP variants only
export_JAVA_OPTIONS="-Xms2g -Xmx10g"


#gatk SelectVariants \
#-V $arrayFileFull \
#-select-type SNP \
#-O $PROJHOME/vcfFiles/SNPFiltered/${arrayFilePre}.snps.vcf.gz 

#filter using GATK recommended hard filter thresholds https://gatk.broadinstitute.org/hc/en-us/articles/360035890471-Hard-filtering-germline-short-variants

export_JAVA_OPTIONS="-Xms2g -Xmx10g"

gatk VariantFiltration \
-V $PROJHOME/vcfFiles/SNPFiltered/${arrayFile} \
-filter "QD < 2.0" --filter-name "QD2" \
-filter "SOR > 3.0" --filter-name "SOR3" \
-filter "FS > 60.0" --filter-name "FS60" \
-filter "MQ < 40.0" --filter-name "MQ40" \
-filter "MQRankSum < -12.5" --filter-name "MQRankSum-12.5" \
-filter "ReadPosRankSum < -8.0" --filter-name "ReadPosRankSum-8" \
-O $PROJHOME/vcfFiles/HardFiltered/${arrayFilePre}.snps.filt.vcf.gz 

#rm $PROJHOME/vcfFiles/SNPFiltered/${arrayFilePre}.snps.vcf.gz






#END
