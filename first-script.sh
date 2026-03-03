#!/bin/bash

# Script: first-script.sh
# Description: Lists filesystems with 80%+ usage, shows recently modified files and top 10 largest files

# threshold for usage
THRESHOLD=80

# get filesystems with usage greater or equal to threshold
# skip tmpfs, devtmpfs by default
mapfile -t busy_fs < <(df -h --output=target,pcent | tail -n +2 | awk -v t="$THRESHOLD" '{gsub(/%/,"",$2); if($2+0 >= t) print $1}')

if [ ${#busy_fs[@]} -eq 0 ]; then
    echo "No filesystems at or above ${THRESHOLD}% usage."
    exit 0
fi

for fs in "${busy_fs[@]}"; do
    echo "\n=== Filesystem: $fs ==="

    # list recently modified files (last 7 days) in that filesystem
    echo "Recently modified files (last 7 days):"
    find "$fs" -xdev -type f -mtime -7 -print | sort | head -n 20

    # list top 10 largest files in that filesystem
    echo "\nTop 10 largest files:"
    find "$fs" -xdev -type f -printf '%s %p\n' 2>/dev/null | sort -nr | head -n 10 | awk '{printf "%s bytes\t%s\n", $1, $2}'

done
