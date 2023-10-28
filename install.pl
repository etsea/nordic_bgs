#!/usr/bin/perl
use strict;
use warnings;

# Paths and constants
my $local_share = "$ENV{HOME}/.local/share";
my $bg_dir = "$local_share/nordic_bgs";
my $bg_script_name = "setbg.pl";

# Execute the generate_bgs.pl script using perl
system("perl ./src/generate_bgs.pl");

# Move the generated backgrounds to ~/.local/share/nordic_bgs
if (-d "./nordic_bgs") {
    system("mv", "./nordic_bgs", $local_share);
} else {
    die "Error: ./nordic_bgs directory not found. Did the generation script fail?";
}

# Install bg_randomizer.pl to ~/.local/share/nordic_bgs/setbg.pl
if (-f "./src/bg_randomizer.pl") {
    system("cp", "./src/bg_randomizer.pl", "$bg_dir/$bg_script_name");
    system("chmod", "+x", "$bg_dir/$bg_script_name");
} else {
    die "Error: bg_randomizer.pl not found in ./src/";
}

# Insert environment variable settings into setbg.pl
my $display = $ENV{DISPLAY} || ':0';
my $xauthority = $ENV{XAUTHORITY} || "$ENV{HOME}/.Xauthority";

my $env_insert = "\$ENV{'DISPLAY'} = '$display';\n\$ENV{'XAUTHORITY'} = '$xauthority';\n";

system("perl -i -pe 'print \"$env_insert\" if \$. == 5' $bg_dir/$bg_script_name");

# Prompt the user for cron job interval
print "Please enter the interval (in minutes between 1 and 120) for the cron job: ";
my $interval = <STDIN>;
chomp $interval;
if ($interval !~ /^[1-9][0-9]{0,2}$/ || $interval < 1 || $interval > 120) {
    die "Error: Invalid interval. Please enter a number between 1 and 120.";
}

# Add cron job
my $cron_command = "*/$interval * * * * $bg_dir/$bg_script_name";
system("echo \"$cron_command\" | crontab -");

print "Installation complete. The background randomizer is set to run every $interval minutes.\n";
