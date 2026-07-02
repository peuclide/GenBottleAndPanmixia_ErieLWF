#!/bin/bash -l

#SBATCH --array=1-12
#SBATCH -A peuclide
#SBATCH -t 24:00:00
#SBATCH -N 1
#SBATCH -n 32
#SBATCH --mail-user=peuclide@purdue.edu
#SBATCH --mail-type=begin
#SBATCH --mail-type=end
#SBATCH --job-name=BWA.MEM_aln
#SBATCH --output=/scratch/negishi/peuclide/Erie_WH_2024/output/BWA_aln_%A_%a.out
#SBATCH --error=/scratch/negishi/peuclide/Erie_WH_2024/output/BWA_aln_%A_%a.err


        ###Single###
        ###Alignments ###
#####################################
### Programs Used ###################
#####################################

module load biocontainers
module load bwa
module load samtools
#module load picard-tools/2.20.8

#####################################
### Variables #######################
#####################################
echo "START TIME: `date`"

PROJHOME=/scratch/negishi/peuclide/Erie_WH_2024/
cd $PROJHOME/
# make directories

#mkdir -p alns
                                                                                                                          4,1           Topwd=`pwd`

echo "working directory: $pwd"

#text file for forward reads
echo "FO reads"
LINE1=$(find ./Unaligned_filtered -name '*_R1_filtered.fastq.gz' -print | sort | cut -b 3-  | sed -n "$SLURM_ARRAY_TASK_ID"p)
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
#outfile2="${LINE}.RG.sorted.bam"
#outfile3="${LINE}.MD.RG.sorted.bam"
echo "outfile names:"
echo $outfile1
#echo $outfile2
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

# ---------------------------------------------------------------------
        echo "Current working directory: `pwd`"
        echo "Starting run at: `date`"
        echo "SLURM_JOBID: " $SLURM_JOBID
        echo "SLURM_ARRAY_TASK_ID: " $SLURM_ARRAY_TASK_ID
        echo "SLURM_ARRAY_JOB_ID: " $SLURM_ARRAY_JOB_ID
        echo "File Name: " $LINE
# ---------------------------------------------------------------------
        echo ""


echo "Alignment start: `date`"

# cannot use total number of cores for BOTH bwa and sort. 
# can look at memory that previous job just using sef job number
# copy every thing over to scratch $/tmp would save all the intermediary files. then final storage. 

##### 1 - align raw data #### 
bwa mem -t 16 -M $REF $LINE1 $LINE2 \
        | samtools sort  -@12 -o ./alns/$outfile1
        
        
## ---------------------------------------------------------------------
        echo "Finished alignment at: `date`"
## ---------------------------------------------------------------------
        echo ""
       


