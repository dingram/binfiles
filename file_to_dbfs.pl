#!/usr/bin/perl -w
use strict;
use warnings;

use File::ExtAttr qw(:all);
use DBI;

my $db_name='dbfs_example';
my $db_host='localhost';
my $db_user='dbfs';
my $db_pass='dbfs';

my $dbh=DBI->connect("DBI:mysql:$db_name:$db_host", $db_user, $db_pass) or die("Cannot connect to database\n$!\n");

foreach (@ARGV) {
  print "Processing \033[1m$_\033[0m...";

  my (undef, $inode) = stat;

	my $sql=$dbh->prepare('INSERT INTO `metadata` (inode, attr, val) VALUES (?, ?, ?)');

  my @attrs=listfattr($_);
  foreach my $attr (@attrs) {
    $attr=~s/^user\.//;
    #print "INSERT INTO `metadata` (inode, attr, val) VALUES ($inode, '$attr', '".getfattr($_, 'user.'.$attr)."');\n";
    $sql->execute($inode, $attr, getfattr($_, 'user.'.$attr));
  }
  $sql->execute($inode, 'legacy.path.linux', $_);

  print " done.\n";
}

# $dbh->close;
