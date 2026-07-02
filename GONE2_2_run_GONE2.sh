#!/bin/bash


set -euo pipefail

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <yourdata> <pre>"
  exit 1
fi

yourdata="$1"
pre="$2"

plink2 --pedmap $yourdata \
       --make-pgen \
       --chr-set 40 \
       --out ./temp_data

plink2 --pfile temp_data \
       --not-chr 22 32 38 \
       --make-pgen \
       --out ${pre}.filtered_data
       
plink2 --pfile ${pre}.filtered_data \
       --recode ped \
       --out ${pre}.filtered_data
       
       
/N/project/glfish/programs/GONE2/gone2 -r 1.1 -t 8 ${pre}.filtered_data.ped 

       
