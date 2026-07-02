#!/bin/bash -l

#SBATCH -n 8
#SBATCH --mem=120G
#SBATCH --array=1-10
#SBATCH -A standby
#SBATCH -t 4:00:00
#SBATCH -N 1
#SBATCH --mail-user=peuclide@purdue.edu
#SBATCH --mail-type=begin
#SBATCH --mail-type=end
#SBATCH --job-name=addRGM
#SBATCH --output=/scratch/negishi/peuclide/Erie_WH_2024/output/addRG_%A_%a.out
#SBATCH --error=/scratch/negishi/peuclide/Erie_WH_2024/output/addRG_%A_%a.err

ml --force purge
ml biocontainers

ml picard
ml samtools

echo "START TIME: `date`"

PROJHOME=/scratch/negishi/peuclide/Erie_WH_2024/
cd $PROJHOME/


PWD=$(pwd)

echo "working directory: $PWD"


#text file for forward reads
echo "FO reads"
LINE1=$(find ./AlignedFastas -name '*_R1_filtered.fastq.gz' -print | sort | cut -b 3-  | sed -n "$SLURM_ARRAY_TASK_ID"p)
echo $LINE1

#text file for reverse reads
echo "PE reads"
LINE2=${LINE1/_R1_filtered.fastq.gz/_R2_filtered.fastq.gz}
# the below code sometimes sorts bams incorrectly. 
#LINE2=$(find ./raw -name '*2.fq.gz' -print | sort | cut -b 3- | sed -n "$SLURM_ARRAY_TASK_ID"p )

echo $LINE2

# reference

REF=~/2022_WH_scripts/GCF_020615455.1_ASM2061545v1_genomic.fna.gz
echo "reference:"
echo  $REF

#sample name
echo "line prefix"

echo "sample ID:"
LINE=`echo $LINE1 | sed 's/_R1_filtered.fastq.gz//g' | sed 's@.*/@@'`
echo $LINE

sm=`echo $LINE | awk -F'_' '{print $1"_"$2}'`

echo "Sample name:"
echo $sm

# define outfile

outfile1="${LINE}.sorted.bam"
outfile2="${LINE}.RG.sorted.bam"
#outfile3="${LINE}.MD.RG.sorted.bam"
echo "outfile names:"
echo $outfile1
echo $outfile2
#echo $outfile3

## read group info

FIRST_READPREFIX=$LINE
FIRST_READ_HEADER=`zcat ./$LINE1 | head -n 1`
IFS=':' read -ra FIRST_READ_HEADER_ARRAY <<< ${FIRST_READ_HEADER}
FIRST_RG_FLOWCELL_ID=${FIRST_READ_HEADER_ARRAY[2]}
FIRST_RG_LANE=${FIRST_READ_HEADER_ARRAY[3]}
FIRST_RG_SAMPLE_NUMBER=${FIRST_READ_HEADER_ARRAY[9]}

FIRST_RGID="${FIRST_RG_FLOWCELL_ID}.${FIRST_RG_LANE}"
FIRST_RGPU="${FIRST_RG_FLOWCELL_ID}.${FIRST_RG_LANE}.${FIRST_RG_SAMPLE_NUMBER}"

echo ""
echo ""
echo "read group info ---------------------"

#echo "FIRST_READPREFIX:" $FIRST_READPREFIX
#echo "FIRST_READ_HEADER:" $FIRST_READ_HEADER
#echo "FIRST_READ_HEADER_ARRAY:" $FIRST_READ_HEADER_ARRAY
#echo "FIRST_RG_FLOWCELL_ID:" $FIRST_RG_FLOWCELL_ID
#echo "FIRST_RG_LANE:" $FIRST_RG_LANE
#echo "FIRST_RG_SAMPLE_NUMBER:" $FIRST_RG_SAMPLE_NUMBER
echo "FIRST_RGPU:" $FIRST_RGPU
echo "FIRST_RGID:" $FIRST_RGID


#####################################
### Execution of programs ###########
#####################################

#echo "RG start: `date`"

export _JAVA_OPTIONS="-Xms64g -Xmx120g"  # Set the desired memory options
picard AddOrReplaceReadGroups \
      I=$PWD/alns/$outfile1 \
      O=$PWD/alns/RGSorted/$outfile2 \
      RGID=$FIRST_RGID \
      RGPU=$FIRST_RGPU \
      RGPL=ILLUMINA \
      RGLB=Lib-$LINE \
      RGSM=$sm \
      VALIDATION_STRINGENCY=LENIENT


#echo "RG end: `date`"

echo "index start: `date`"
#
##### 3 - Index sam file #########
#
	samtools index alns/RGSorted/$outfile2
#
#	rm $pwd/alns/$outfile1


 echo "Index end: `date`"


echo "all end: `date`"

