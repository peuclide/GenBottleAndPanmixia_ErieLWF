#!/bin/bash -l

#SBATCH -n 48
#SBATCH --array=62,67,69,70,71%3
#SBATCH -A highmem
#SBATCH -t 24:00:00
#SBATCH --mail-user=peuclide@purdue.edu
#SBATCH --mail-type=begin
#SBATCH --mail-type=end
#SBATCH --job-name=HaplotypeCaller
#SBATCH --output=/scratch/negishi/peuclide/Erie_WH_2024/output/HaplotypeCaller_%A_%a.out
#SBATCH --error=/scratch/negishi/peuclide/Erie_WH_2024/output/HaplotypeCaller_%A_%a.err

PROJHOME=/scratch/negishi/peuclide/Erie_WH_2024
cd $PROJHOME/


### load modules 

module --force purge
module load biocontainers
ml gatk4
#ml picard
#module load samtools
#ml htslib
#module load bcftools/1.11


#####################################
### Variables #######################
####################################
# Takes your bam file (*MD.RG.sorted.bam) and uses haplotype caller to create a gvcf file. You will need an indexed reference to do this.

	arrayFileFull=$(find ./alns/alns_RG_MD/ -name '*MD.RG.sorted.bam' -print | sort | cut -b 3-  | sed -n "$SLURM_ARRAY_TASK_ID"p)
	arrayFile=$(basename "/$arrayFileFull")
	arrayFilePre=$(basename "$arrayFile" .MD.RG.sorted.bam)
	outFile="gvcfs/${arrayFilePre}"
	reference=~/2022_WH_scripts/GCF_020615455.1_ASM2061545v1_genomic.fna.gz

mkdir -p gvcfs/

echo "arrayFileFull:"
echo $arrayFileFull
echo "arrayFile:"
echo $arrayFile
echo "arrayFilePre:"
echo $arrayFilePre
echo "outFile:"
echo $outFile
echo "Reference:"
echo $reference



	#####################################
	### Execution of programs ###########
	#####################################


	# ---------------------------------------------------------------------
	echo "Current working directory: `pwd`"
	echo "Starting run at: `date`"
	echo "SLURM_JOBID: " $SLURM_JOBID
	echo "SLURM_ARRAY_TASK_ID: " $SLURM_ARRAY_TASK_ID
	echo "SLURM_ARRAY_JOB_ID: " $SLURM_ARRAY_JOB_ID
	echo "File Name: " $arrayFileFull
	# ---------------------------------------------------------------------
	echo ""


#make dict
#export_JAVA_OPTIONS="-Xms64g -Xmx120g"

#picard CreateSequenceDictionary R= $reference O= ${reference}.dict
### NOTE dict needs to be name without 'fna.gz': ref.fna.gz.dict >> ref.dict

#make index
#make index
#gunzip $reference
#bgzip $reference
#samtools faidx $reference

##### Call genotypes ########

export_JAVA_OPTIONS="-Xmx64g -Djava.io.tmpdir=/scratch/negishi/peuclide/tmpdir" 

gatk HaplotypeCaller \
	 -ERC GVCF \
	 -R $reference \
	 -I $arrayFileFull \
	 -O ${outFile}.hapcalls.g.vcf.gz

	# ---------------------------------------------------------------------
	echo "Finished gvcfs at: `date`"
	# ---------------------------------------------------------------------
	echo ""




