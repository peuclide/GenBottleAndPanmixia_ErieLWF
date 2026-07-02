#!/bin/bash

#SBATCH -n 12
#SBATCH --mem=32G
#SBATCH -A r01380
#SBATCH -p general
#SBATCH -t 48:30:00
#SBATCH --mail-user=peuclide@iu.edu
#SBATCH --mail-type=begin
#SBATCH --mail-type=end
#SBATCH --job-name=BEAGLE
#SBATCH --output=/N/project/glfish/ErieWhitefish/outputs/BEAGLE_%A_%a.out
#SBATCH --error=/N/project/glfish/ErieWhitefish/outputs/BEAGLE_%A_%a.err

module load java

for chr in {192..231}; do
  java -Xmx20g -jar beagle.27Feb25.75f.jar \
    gt=NC_059${chr}.1.dip.recode.vcf.gz \
    nthreads=6 \
    out=NC_059${chr}.1.phased
done


