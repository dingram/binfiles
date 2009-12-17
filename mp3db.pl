#!/usr/bin/perl -w
#
# Script to analyse and create/update a database containing information about
# MP3 files stored on disk.
#
# Written by Dave Ingram (11 Dec 2005)
#
use MP3::Tag;
use File::stat;
use DBI;
#use warnings;
#use diagnostics;

# DB format:
#
# Table called files:
#   path 		text
#   parent 		text
#   size 		int 			[default: 0]
#   modified 	datetime 		[default: 0000-00-00 00:00:00]
#   artist 		varchar(255)
#   title 		varchar(255)
#   album 		varchar(255)
#   track 		varchar(3)
#
# Primary key: path, parent
# 
# This might be helpful:
#
# CREATE TABLE `files` (
#  `path` text NOT NULL,
#  `parent` text NOT NULL,
#  `size` int(11) NOT NULL default '0',
#  `modified` datetime NOT NULL default '0000-00-00 00:00:00',
#  `artist` varchar(255) NOT NULL default '',
#  `title` varchar(255) NOT NULL default '',
#  `album` varchar(255) NOT NULL default '',
#  `track` varchar(3) NOT NULL default '',
#  PRIMARY KEY  (`path`(250),`parent`(250)),
#  KEY `modified` (`modified`,`artist`,`title`,`album`),
#  FULLTEXT KEY `path` (`path`,`artist`,`title`,`album`),
#  FULLTEXT KEY `parent` (`parent`)
#) ENGINE=MyISAM


# Change these values and nothing else.

$basepath="/music/Music";
$db_name='mp3info';
$db_host='localhost';
$db_user='mp3info';
$db_pass='RfnWvn2jnfJLH82t';

# DO NOT CHANGE BELOW THIS LINE
# LOOK BUT DON'T TOUCH!
######################################################################

$dbh=DBI->connect("DBI:mysql:$db_name:$db_host", $db_user, $db_pass) or die("Cannot connect to database\n$!\n");

&scanDir("/",""); # all relative to $basepath

$dbh->close;

sub LOG {
	#print "@_\n";
}

sub timeString {
    my ($tm) = @_;
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($tm);
    return sprintf("%04d-%02d-%02d %02d:%02d:%02d", $year+1900, $mon+1, $mday, $hour, $min, $sec);
}

sub searchDB {
	my $file=shift;
	my $parent=shift;
	my $ofile=$file;
	my $oparent=$parent;
	$file=~s/'/''/g;
	$parent=~s/'/''/g;

	my $sql=$dbh->prepare("SELECT modified FROM files WHERE path='$file' AND parent='$parent'");
	$sql->execute;
	if (my(@data)=$sql->fetchrow_array) {
		my $fpath="$oparent/$ofile";
		LOG($fpath);
		LOG("DB   last modified: ".$data[0]);
		my $so=stat($fpath) or die ("$!");
		LOG("File last modified: ".&timeString($so->mtime));
		if (&timeString($so->mtime) eq $data[0]) {
			return 0;
		} else {
			return 1;
		}
	} else {
		return 2;
	}
}

sub updateDB {
	my $file=shift;
	my $parent=shift;
	my $ofile=$file;
	my $oparent=$parent;
	$file=~s/'/''/g;
	$parent=~s/'/''/g;
	my $fpath="$oparent/$ofile";
	
	LOG("Updating file: $oparent/$ofile");
	my $so=stat($fpath) or die("$!");
	
	my $mtime=&timeString($so->mtime);
	LOG("  Modified: $mtime");
	
	my $size=$so->size;
	LOG("  Size: $size");

	my $mp3=MP3::Tag->new($fpath);

	my ($title, $track, $artist, $album)=$mp3->autoinfo();

	$mp3->close;
	
	LOG("  Artist: $artist\n  Album: $album\n  Track: $track\n  Title: $title");

	$artist=~s/'/''/g;
	$title=~s/'/''/g;
	$album=~s/'/''/g;

	my $sql=$dbh->prepare("UPDATE files SET size=$size, modified='$mtime', artist='$artist', title='$title', album='$album', track='$track' WHERE path='$file' AND parent='$parent'");
	$sql->execute;
	LOG("");
}

sub addtoDB {
	my $file=shift;
	my $parent=shift;
	$file=~s/'/''/g;
	$parent=~s/'/''/g;

	my $sql=$dbh->prepare("INSERT INTO files (path,parent) VALUES ('$file','$parent')");
	$sql->execute;
}

sub addInfo {
	my $file=shift;
	my $parent=shift;
	my $t=&searchDB($file,$parent);

	#LOG("Adding info on $basepath$parent/$file");
	
	if    ($t==0) {} # in DB, up-to-date
	elsif ($t==1) {
		# in DB, needs updating
		&updateDB($file,$parent);
	} elsif ($t==2) {
		# not in DB
		&addtoDB($file,$parent);
		&updateDB($file,$parent);
	}
}

sub scanDir {
	my $dir=shift;
	my $parent=shift;
	$dir="" if ($dir eq "/");
	$parent="" if ($parent eq "/");
	
	LOG("Scanning $basepath$parent/$dir...");
	
	opendir(DIR, "$basepath$parent/$dir") or die("Cannot open directory $basepath$parent/$dir!\n");
	my @fs=sort readdir DIR;
	closedir DIR;
	
	foreach my $f (@fs) {
		if (-d "$basepath$parent/$dir/$f") {
			&scanDir($f,"$parent/$dir") unless ($f=~/^\.\.?$/);
		} elsif ($f=~/\.mp3$/) {
			&addInfo($f,"$basepath$parent/$dir");
		}
	}

	LOG("Finished scanning $basepath$parent/$dir...");
}
