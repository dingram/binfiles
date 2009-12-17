#!/usr/bin/perl -w
################################################################################
## This program is released under a Creative Commons
## Attribution-NonCommerical-ShareAlike2.5 License.
##
## For more information, please see
##   http://creativecommons.org/licenses/by-nc-sa/2.5/
## 
## You are free:
## 
## * to copy, distribute, display, and perform the work
## * to make derivative works
## 
## Under the following conditions:
##   Attribution:   You must attribute the work in the manner specified by the
##                  author or licensor.
##   Noncommercial: You may not use this work for commercial purposes.
##   Share Alike:   If you alter, transform, or build upon this work, you may
##                  distribute the resulting work only under a license identical
##                  to this one.
## 
## * For any reuse or distribution, you must make clear to others the license
##   terms of this work.
## * Any of these conditions can be waived if you get permission from the
##   copyright holder.
## 
## Your fair use and other rights are in no way affected by the above.
################################################################################

use strict;
use DBI;

my $dbname="admin";
my $dbhost="db-admin.doc.ic.ac.uk";
my $dbport=5430;
my $myuser="dmi04";

my $dbh=DBI::connect("dbi:Pg:dbname=$dbname;host=$dbhost;port=$dbport","$myuser","$mypass");
die "ERR: Couldn't open connection: ".$dbh->errstr."\n" unless ($dbh);
my $sth=$dbh->prepare("SELECT * FROM hosts WHERE bleh");
my $exc;
my $res=$sth->execute($exc);
die "Exec $exc query failed: ".$dbh->errstr."\n" unless ($res);
my $numres=$sth->rows;
for (my $i=1; $i<=$numres; $i++) {
	my $row=$sth->fetchrow_hashref;
	print "$i\t".$row->{something}."\n";
}
$sth->finish;
$dbh->disconnect;
exit;
