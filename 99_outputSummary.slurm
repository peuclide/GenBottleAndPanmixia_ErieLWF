#!/bin/bash

cd /scratch/negishi/peuclide/Erie_WH_2024/output

# Define the output file
output_file="output_summary5022562781.txt"

# Ensure the output file is empty before starting
> "$output_file"

# Find all files containing "21524183" in their names and process each one
find . -type f -name "*5022562781*.err" | while read file; do
  # Check if the file is non-empty and exists
  if [ -s "$file" ]; then
    # Use awk to capture the last three lines and print them along with the filename
    awk -v filename="$file" '{
      # Store the last three lines
      a[NR % 3] = $0
    }
    END {
      # Print the third-from-last, last line, and filename
	print a[(NR+1) % 3] "," a[NR % 3] "," filename    
}' "$file" >> "$output_file"
  fi
done

echo "Last and third-from-last lines from matching files have been written to $output_file"

