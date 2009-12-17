#!/usr/bin/perl
while (<>) { print unless ($l{$_}++); }
