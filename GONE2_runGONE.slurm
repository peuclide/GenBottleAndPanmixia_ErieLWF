#!/bin/bash

#SBATCH -J GONE
#SBATCH -p general
#SBATCH -o /N/project/glfish/ErieWhitefish/0_December2025_ReAnalysis/GONE/GONE_analysis_%j.out
#SBATCH -e /N/project/glfish/ErieWhitefish/0_December2025_ReAnalysis/GONE/GONE_analysis_%j.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=peuclide@iu.edu
#SBATCH --nodes=1
#SBATCH --cpus-per-task=18
#SBATCH --time=48:30:00
#SBATCH --mem=48G
#SBATCH -A r01380


WD=/N/project/glfish/ErieWhitefish/0_December2025_ReAnalysis/GONE/GONE2
module load java


### RUN GONE

## copy over GONE and run
cd $WD
X=500000
r=1.1

/N/project/glfish/programs/GONE2/gone2 -r $r -t 12 -x -o testX filtered_data.ped 


