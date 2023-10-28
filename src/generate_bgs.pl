#!/usr/bin/perl
use strict;
use warnings;
use File::Temp qw/tempfile/;
use File::Spec;

# Configuration settings
my $src_dir = './src';
my $output_dir = './nordic_bgs';
my $log_file = './generation_log.txt';

# Utility check
foreach my $util (qw/convert identify xrandr/) {
    unless (`which $util`) {
        die "Error: $util is not installed!\n";
    }
}

# Fetch current monitor resolution
print_log("Fetching current monitor resolution...");
my $resolution = `xrandr | grep '*' | awk '{print \$1}'`;
chomp $resolution;
my ($resolution_width, $resolution_height) = split 'x', $resolution;
print_log("Current Resolution: ${resolution_width}x${resolution_height}");

# Ensure output directory exists
unless (-d $output_dir) {
    print_log("Output directory $output_dir does not exist. Creating it...");
    mkdir $output_dir or die "Error creating $output_dir: $!\n";
}

# Process images
my $file_number = 1;
print_log("Scanning for *.webp files in $src_dir...");
for my $file (glob "$src_dir/*.webp") {
    next unless -f $file;

    my $output_file = File::Spec->catfile($output_dir, sprintf "nordic_bg_%03d.bmp", $file_number);

    print_log("Processing $file...");

    # Work on a temporary copy of the file
    my ($fh, $temp_file) = tempfile();
    system("cp", "$file", "$temp_file");

    # Image processing
    my $img_width = `identify -format "%w" "$temp_file"`;
    my $img_height = `identify -format "%h" "$temp_file"`;
    
    # Resize logic (unchanged from previous)
    my $img_aspect = $img_width / $img_height;
    my $res_aspect = $resolution_width / $resolution_height;
    if ($img_aspect > $res_aspect) {
        system("convert", "$temp_file", "-resize", "${resolution_width}x", "$temp_file");
    } else {
        system("convert", "$temp_file", "-resize", "x${resolution_height}", "$temp_file");
    }

    # Crop and save to the final destination
    system("convert", "$temp_file", "-gravity", "center", "-crop", "${resolution_width}x${resolution_height}+0+0", "$output_file");

    # Compress
    print_log("Compressing $output_file...");
    system("gzip", "-9", "$output_file");

    $file_number++;
}

print_log("Processing complete!");

# Logging subroutine
sub print_log {
    my $message = shift;
    open my $log_fh, '>>', $log_file or die "Cannot open log file $log_file: $!";
    print $log_fh "$message\n";
    close $log_fh;

    print "$message\n";
}
