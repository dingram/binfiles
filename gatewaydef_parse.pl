#!/usr/bin/perl
use strict;
use warnings;

### OPEN FILE
open INFILE, "gatewaydefs.txt";

# ignore line 1
my $line=<INFILE>;

# get number of gateways
$line=<INFILE>;
my ($nogw)=($line=~/^numgateways\s+(\d+)\s*$/);

print "<?xml version=\"1.0\"?>\n";
print "<gatewaydefs>\n";

# while we're still looking for gateways
while ($nogw>0) {
  
  # skip line if it's blank
  while (($line=<INFILE>)=~/^\s*$/) { }
  
  my $name=$line; chomp $name;
  # set up first line of details
  $line=<INFILE>;
  my ($cost,$maxcpu,$maxmem,$maxupg,$maxsec,$bw,$w,$h,$desc) = ($line=~/^\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(.*)$/);
  $maxupg/=1; # to ignore maxupg warnings: it's never used
  print "  <gateway>\n";
  print "    <name>$name</name>\n";
  print "    <cost>$cost</cost>\n";
  print "    <bandwidth>$bw</bandwidth>\n";
  print "    <width>$w</width>\n";
  print "    <height>$h</height>\n";
  print "    <description>$desc</description>\n";
  $line=<INFILE>;

  print "    <cpus>\n";
  # get cpu info
  my $cpurx='^\s*cpu' . ('[\s\n\r]+(\d+)[\s\n\r]+(\d+)' x $maxcpu);
  while ($line!~/${cpurx}/) { $line.=<INFILE>; }
  # execute the regexp and get the results... array of numbers, first = x, second=y, third=x, etc
  my @cpucoords=($line=~/${cpurx}/);
  for (my $i=0; $i<$#cpucoords; $i++) {
    print "      <cpu x=\"".$cpucoords[$i]."\" y=\"".$cpucoords[++$i]."\" />\n";
  }
  $line=<INFILE>;
  print "    </cpus>\n";

  print "    <memory>\n";
  # get mem info
  my $memrx='^\s*mem' . ('[\s\n\r]+(\d+)[\s\n\r]+(\d+)' x $maxmem);
  while ($line!~/${memrx}/) { $line.=<INFILE>; }
  my @memcoords=($line=~/${memrx}/);
  for (my $i=0; $i<$#memcoords; $i++) {
    print "      <mem x=\"".$memcoords[$i]."\" y=\"".$memcoords[++$i]."\" />\n";
  }
  $line=<INFILE>;
  print "    </memory>\n";

  if ($maxsec>0) {
    print "    <security>\n";
    # get sec info
    my $secrx='^\s*sec' . ('[\s\n\r]+(\d+)[\s\n\r]+(\d+)' x $maxsec);
    my @seccoords=($line=~/${secrx}/);
    for (my $i=0; $i<$#seccoords; $i++) {
      print "      <sec x=\"".$seccoords[$i]."\" y=\"".$seccoords[++$i]."\" />\n";
    }
    $line=<INFILE>;
    print "    </security>\n";
  } else {
    print "    <security />\n";
  }

  # get modem info
  my $mdmrx='^\s*modem[\s\n\r]+(\d+)[\s\n\r]+(\d+)\s*$';
  my @mdmcoords=($line=~/${mdmrx}/);
  print "    <modem x=\"".$mdmcoords[0]."\" y=\"".$mdmcoords[1]."\" />\n";
  $line=<INFILE>;

  # get power info
  my $pwrrx='^\s*power[\s\n\r]+(\d+)[\s\n\r]+(\d+)\s*$';
  my @pwrcoords=($line=~/${pwrrx}/);
  print "    <power x=\"".$pwrcoords[0]."\" y=\"".$pwrcoords[1]."\" />\n";

  print "  </gateway>\n";
  print "\n" if ($nogw>1);
  
  # decrease number of gateways left to read
  $nogw--;
}
print "</gatewaydefs>\n";

#### CLOSE FILE
#
close INFILE;
