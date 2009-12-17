#!/usr/bin/perl -w
use strict;
use warnings;

use File::ExtAttr qw(:all);
use MP3::Tag;
use File::LibMagic;

my $flm = File::LibMagic->new();

foreach (@ARGV) {
  my $mp3 = MP3::Tag->new($_);
  print "Processing \033[1m$_\033[0m...";

  $mp3->get_tags();
  my ($title, $track, $artist, $album, $comment, $year, $genre) = $mp3->autoinfo();

  &setAttr($_, 'music.artist' , $artist );
  &setAttr($_, 'music.album'  , $album  );
  &setAttr($_, 'music.track'  , $track  );
  &setAttr($_, 'music.title'  , $title  );
  &setAttr($_, 'music.year'   , $year   );
  &setAttr($_, 'music.comment', $comment);
  &setAttr($_, 'music.genre'  , $genre  );

  # determine the MIME type
  &setAttr($_, 'file.type.mime', $flm->checktype_filename($_));

  $mp3->close();

  print " done.\n";
}

sub setAttr() {
  my ($file, $attr, $value) = @_;
  return if (!$value);
  #print $attr.' = '.$value."\n";
  setfattr($_, 'user.'.$attr, $value);
}
