#!/bin/sh

# Check and store the current monitor resolution
echo "Fetching current monitor resolution..."
resolution=$(xrandr | grep '*' | awk '{print $1}')
resolution_width=$(echo $resolution | cut -d 'x' -f1)
resolution_height=$(echo $resolution | cut -d 'x' -f2)
echo "Current Resolution: ${resolution_width}x${resolution_height}"

# Check if the nordic_bgs directory exists
if [ ! -d "./nordic_bgs" ]; then
    echo "Directory nordic_bgs does not exist. Creating it..."
    mkdir "./nordic_bgs"
fi

# Setting up initial file number for the output files
file_number=1

# Searching for *.webp files in */src/ directories
echo "Scanning for *.webp files in */src/ directories..."
for file in */src/*.webp; do
    if [ ! -f "$file" ]; then
        continue
    fi

    # Constructing output file name
    output_file="./nordic_bgs/nordic_bg_$(printf '%03d' $file_number).bmp"
    
    echo "Processing $file..."

    # Using convert from ImageMagick to crop (if necessary) and then scale the image
    echo "Cropping and scaling $file to match the current resolution..."
    convert "$file" -gravity center -crop ${resolution_width}x${resolution_height}+0+0 -resize ${resolution_width}x${resolution_height} "$output_file"
    
    # Using gzip to compress the file
    echo "Compressing $output_file..."
    gzip -9 "$output_file"

    # Incrementing file number for next iteration
    file_number=$((file_number + 1))
done

echo "Processing complete!"
