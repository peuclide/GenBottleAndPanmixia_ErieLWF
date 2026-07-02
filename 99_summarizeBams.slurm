#!/bin/bash -l

#SBATCH -n 4
#SBATCH -A peuclide
#SBATCH -t 96:00:00
#SBATCH --mail-user=peuclide@purdue.edu
#SBATCH --mail-type=begin
#SBATCH --mail-type=end
#SBATCH --job-name=BamSummary
#SBATCH --output=/scratch/negishi/peuclide/Erie_WH_2024/output/BamSummary_%A.out
#SBATCH --error=/scratch/negishi/peuclide/Erie_WH_2024/output/BamSummary_%A.err


	###Single###
	###Alignments ###
#####################################
### Programs Used ###################
#####################################
module load biocontainers
module load samtools

echo "START TIME: `date`"

PROJHOME=/scratch/negishi/peuclide/Erie_WH_2024/alns
cd $PROJHOME/

echo ""

echo ""

for file in *sorted.bam; do
 samtools view -c -F 4 $file >> ../combinedBamsMappedReadsJan20.txt 
 samtools view -c $file >> ../combinedBamsTotalReadsJan20.txt 
 echo $file >> ../combinedBamsFileNameJan20.txt
 samtools view -c -q 20 $file >> ../combinedBamsQ20ReadsJan20.txt 
 samtools view -c -q 60 $file >> ../combinedBamsQ60ReadsJan20.txt ; done


echo "END TIME: `date`"

 

