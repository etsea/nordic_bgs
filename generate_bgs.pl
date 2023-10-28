#!/usr/bin/perl
use strict;
use warnings;
use File::Copy;

# Check and store the current monitor resolution
print "Fetching current monitor resolution...\n";
my $resolution = `xrandr | grep '*' | awk '{print \$1}'`;
chomp $resolution;
my ($resolution_width, $resolution_height) = split 'x', $resolution;
print "Current Resolution: ${resolution_width}x${resolution_height}\n";

# Check if the nordic_bgs directory exists
unless (-d "./nordic_bgs") {
    print "Output directory nordic_bgs does not exist. Creating it...\n";
    mkdir "./nordic_bgs";
}

# Setting up initial file number for the output files
my $file_number = 1;

# Searching for *.webp files in ./src/ directory
print "Scanning for *.webp files in ./src/ directory...\n";
for my $file (glob "./src/*.webp") {
    next unless -f $file;

    #... [rest of the code for image processing] ...

    # Incrementing file number for next iteration
    $file_number++;
}

print "Processing complete!\n";

# Move the resulting nordic_bgs directory to $XDG_CONFIG_HOME/
my $xdg_config = $ENV{'XDG_CONFIG_HOME'} || "$ENV{'HOME'}/.config";
if (-d './nordic_bgs') {
    system("mv", "./nordic_bgs", "$xdg_config/");
    print "Moved nordic_bgs to $xdg_config\n";
}

# Copy ./bg_randomizer.pl to ~/.bgset.pl
if (-f './bg_randomizer.pl') {
    copy('./bg_randomizer.pl', "$ENV{'HOME'}/.bgset.pl");
    system("chmod", "+x", "$ENV{'HOME'}/.bgset.pl");  # make it executable
    print "Copied ./bg_randomizer.pl to ~/.bgset.pl and made it executable\n";
}

# Add a cron job to execute ~/.bgset.pl with Perl every 20 minutes
open(my $fh, "|-", "crontab -l 2>/dev/null");
my $cron_content = <$fh>;
close($fh);

unless ($cron_content =~ /\.bgset\.pl/) {  # avoid adding duplicate cron job
    open($fh, "|-", "crontab -");
    print $fh "$cron_content\n*/20 * * * * /usr/bin/perl $ENV{'HOME'}/.bgset.pl\n";
    close($fh);
    print "Added cron job to execute ~/.bgset.pl every 20 minutes\n";
}
