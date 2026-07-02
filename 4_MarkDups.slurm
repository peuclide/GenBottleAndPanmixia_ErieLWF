#!/bin/bash -l

#SBATCH -n 32
#SBATCH --array=123
#SBATCH -A peuclide
#SBATCH -t 24:00:00
#SBATCH --mail-user=peuclide@purdue.edu
#SBATCH --mail-type=begin
#SBATCH --mail-type=end
#SBATCH --job-name=MarkDups
#SBATCH --output=/scratch/negishi/peuclide/Erie_WH_2024/output/MarkDups_indx_%A_%a.out
#SBATCH --error=/scratch/negishi/peuclide/Erie_WH_2024/output/MarkDups_indx_%A_%a.err

PROJHOME=/scratch/negishi/peuclide/Erie_WH_2024
cd $PROJHOME/

module purge
module load biocontainers
module load samtools
ml gatk4

#arrayfile=$(ls alns/RGSorted/*RG.sorted.bam | sort -u | awk -v line=$SLURM_ARRAY_TASK_ID '{if(NR==line) print $0}')
#prefix=`echo $arrayfile | sed 's@.*/@@'`

arrayfile=$(find ./alns/RGSorted -name '*RG.sorted.bam' -print | sort | cut -b 3- | sed -n "$SLURM_ARRAY_TASK_ID"p)
prefix=`echo $arrayfile | sed 's/.RG.sorted.bam//g' | sed 's@.*/@@'`


pwd=`pwd`

echo "working directory: $pwd"

echo "VARIABLES:"
echo $arrayfile
echo $prefix


echo "OUTFILE:"

outfile=${prefix}.MD.RG.sorted.bam
echo $outfile

echo "Marking Duplicates at: `date`"

#mkdir -p combined_bams

#### 4 - Mark duplicates #########
#	java -Xms36g -Xmx108g -jar ./picard.jar MarkDuplicates \
#	I=$pwd/$bamfile1 \
#	O=$pwd/alns/combined_bams/$outfile \
#	VALIDATION_STRINGENCY=LENIENT M=$pwd/output/${prefix}.duplication_metrics_from_MarkDuplicates.txt

M=$pwd/output/MDlogs/${prefix}.duplication_metrics_from_MarkDuplicates.txt

export_JAVA_OPTIONS="-Xms8g -Xmx56g"

gatk MarkDuplicatesSpark \
	-I $pwd/$arrayfile \
	-O $pwd/alns/alns_RG_MD/$outfile \
	-M $M  
	#--conf 'spark.executor.cores=36'

# ---------------------------------------------------------------------
	echo "Finished Marking Duplicates at: `date`"
# ---------------------------------------------------------------------
	echo ""

#### 5 - Index NEW sam file #########

samtools index $pwd/alns/alns_RG_MD/$outfile -@ 2

	# ---------------------------------------------------------------------
	echo "Finished indexing NEW sam file (marked duplicates) at: `date`"
	# ---------------------------------------------------------------------
	echo ""

	#### Remove intermediate files ###########
	#rm $pwd/$bamfile1
	#rm $pwd/$bamfile2
	#rm $pwd/$bamfile3
	
	
	# ---------------------------------------------------------------------
	#echo "Finished removing intermediate files at: `date`"
	# ---------------------------------------------------------------------
	echo ""

	# ---------------------------------------------------------------------
	echo "Finished all at: `date`"
	# ---------------------------------------------------------------------
	echo ""


