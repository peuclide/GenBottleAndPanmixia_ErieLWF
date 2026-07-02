#!/bin/bash
#BATCH --job-name=GDBImp_ch2
#SBATCH -A peuclide
#SBATCH -N 1
#SBATCH -n 6
#SBATCH --array=1,2,3,4,21,22,23,24,25,26,27,33,34,35,36,37,38,41
#SBATCH -t 96:00:00
#SBATCH --mail-user=peuclide@purdue.edu
#SBATCH --output=/scratch/negishi/peuclide/Erie_WH_2024/output/GenDBI_11-50%A_%a.out
#SBATCH --error=/scratch/negishi/peuclide/Erie_WH_2024/output/GenDBI_11-50%A_%a.err


module purge
module load biocontainers
module load gatk4

PROJHOME=/scratch/negishi/peuclide/Erie_WH_2024/
HAPCALLS=/scratch/negishi/peuclide/Erie_WH_2024/gvcfs/
cd $PROJHOME

arrayFileFull=$(find ./sarek/ -name '*LG*.bed' -print | sort | cut -b 3-  | sed -n "$SLURM_ARRAY_TASK_ID"p)
arrayFile=$(basename "/$arrayFileFull")
arrayFilePre=$(basename "$arrayFile" .bed)

echo $arrayFileFull
echo $arrayFile
echo $arrayFilePre



tmp_dir=$(mktemp -d /scratch/negishi/peuclide/GenomicsDBImport.tmp.XXXXX)

##### set up database - once database is created need to add to it.


echo "update database start at: `date`"
export_JAVA_OPTIONS="-Xms8g -Xmx8g"

gatk GenomicsDBImport  \
       --genomicsdb-update-workspace-path $PROJHOME/${arrayFilePre}_db \
       --batch-size 20 \
       --sample-name-map $HAPCALLS/file51-127.samps \
       --tmp-dir $tmp_dir \
       --reader-threads 4
#
echo "update database done at: `date`"
echo ""

## END
