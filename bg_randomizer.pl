#!/usr/bin/perl
use strict;
use warnings;

# Check if $XDG_CONFIG_HOME is set, else default to ~/.config
my $xdg_config = $ENV{'XDG_CONFIG_HOME'} || "$ENV{'HOME'}/.config";

# Directory where the compressed backgrounds are stored
my $bg_dir = "$xdg_config/nordic_bgs";

# Fetch all .bmp.gz files from the directory
my @files = glob("$bg_dir/*.bmp.gz");

# Exit if no files found
unless (@files) {
    print "No .bmp.gz files found in $bg_dir\n";
    exit 1;
}

# Randomly pick one of the files
my $random_file = $files[int(rand(@files))];

# Decompress with gzcat and pipe to feh to set the current background
system("gzcat \"$random_file\" | feh --bg-scale -");
