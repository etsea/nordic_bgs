#!/usr/bin/perl
use strict;
use warnings;

# Configuration settings
my $local_share = "$ENV{'HOME'}/.local/share";
my $bg_dir = "$local_share/nordic_bgs";
my $log_file = "$bg_dir/randomizer.log";
my $recent_file = "$bg_dir/recent.log";

# Ensure the log directory exists
unless (-d $bg_dir) {
    mkdir $bg_dir or die "Error creating directory $bg_dir: $!";
}

# Check for necessary utilities
foreach my $util (qw/gzcat feh/) {
    unless (`which $util`) {
        log_error("$util is not installed!");
        exit 1;
    }
}

# Fetch all .bmp.gz files from the directory
my @files = glob("$bg_dir/*.bmp.gz");
unless (@files) {
    log_error("No .bmp.gz files found in $bg_dir");
    exit 1;
}

# Read the recent.log file to get the last 5 backgrounds
my @recent_backgrounds;
if (-f $recent_file) {
    open my $recent_fh, '<', $recent_file or log_error("Unable to open $recent_file: $!");
    @recent_backgrounds = <$recent_fh>;
    chomp @recent_backgrounds;
    close $recent_fh;
}

# Filter out the recent backgrounds
my @eligible_files = grep { my $file = $_; not grep { $_ eq $file } @recent_backgrounds } @files;

# If all files were recently used, reset eligible files
@eligible_files = @files unless @eligible_files;

# Randomly pick one of the eligible files
my $random_file = $eligible_files[int(rand(@eligible_files))];

# Decompress and set wallpaper
system("gzcat \"$random_file\" | feh --bg-scale -");

# Update recent.log with the selected file
unshift @recent_backgrounds, $random_file;
@recent_backgrounds = @recent_backgrounds[0..4] if scalar @recent_backgrounds > 5; # Keep only last 5 entries

open my $recent_fh, '>', $recent_file or log_error("Unable to open $recent_file: $!");
print $recent_fh join("\n", @recent_backgrounds);
close $recent_fh;

# Error logging subroutine
sub log_error {
    my $message = shift;

    open my $log_fh, '>>', $log_file or die "Cannot open log file $log_file: $!";
    print $log_fh "$message\n";
    close $log_fh;

    print "Error: $message\n";
}
