#!/bin/bash

#SBATCH -n 12
#SBATCH --mem=24G
#SBATCH -A r01380
#SBATCH -p general
#SBATCH -t 06:30:00
#SBATCH --mail-user=peuclide@iu.edu
#SBATCH --mail-type=begin
#SBATCH --mail-type=end
#SBATCH --job-name=selscanNorm
#SBATCH --output=/N/project/glfish/ErieWhitefish/outputs/SELSCAN_norm%A_%a.out
#SBATCH --error=/N/project/glfish/ErieWhitefish/outputs/SELSCAN_norm%A_%a.err

cd /N/project/glfish/ErieWhitefish/0_December2025_ReAnalysis/SELSCAN

### RUN NORM
echo "selscan begin:"


## loop through all files and run selscan
## TRNR vs LP
ALT="LP"
REF="TRNR"

for i in $(seq 192 231); do
    LG="NC_059${i}.1.phased"
    ~/Programs/selscan/src/norm \
        --xpehh \
        --files "${LG}.${ALT}-${REF}.xpehh.out"
done

echo "${ALT} vs ${REF} DONE"

## TRNR vs MB

ALT="MB"
REF="TRNR"

for i in $(seq 192 231); do
    LG="NC_059${i}.1.phased"
    ~/Programs/selscan/src/norm \
        --xpehh \
        --files "${LG}.${ALT}-${REF}.xpehh.out"
done
echo "${ALT} vs ${REF} DONE"

## TRNR vs CR

ALT="CR"
REF="TRNR"

for i in $(seq 192 231); do
    LG="NC_059${i}.1.phased"
    ~/Programs/selscan/src/norm \
        --xpehh \
        --files "${LG}.${ALT}-${REF}.xpehh.out"
done
echo "${ALT} vs ${REF} DONE"

## MB vs LP

ALT="LP"
REF="MB"

for i in $(seq 192 231); do
    LG="NC_059${i}.1.phased"
    ~/Programs/selscan/src/norm \
        --xpehh \
        --files "${LG}.${ALT}-${REF}.xpehh.out"
done
echo "${ALT} vs ${REF} DONE"

## CR vs LP

ALT="CR"
REF="LP"

for i in $(seq 192 231); do
    LG="NC_059${i}.1.phased"
    ~/Programs/selscan/src/norm \
        --xpehh \
        --files "${LG}.${ALT}-${REF}.xpehh.out"
done
echo "${ALT} vs ${REF} DONE"

## CR vs MB

ALT="CR"
REF="MB"

for i in $(seq 192 231); do
    LG="NC_059${i}.1.phased"
    ~/Programs/selscan/src/norm \
        --xpehh \
        --files "${LG}.${ALT}-${REF}.xpehh.out"
done
echo "${ALT} vs ${REF} DONE"

echo "ALL DONE"

