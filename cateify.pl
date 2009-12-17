#!/usr/bin/perl
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

use XML::Twig;
use Date::Calc qw(:all);

@curtime=localtime(time);
$curtime[4]++;
$curtime[5]+=1900;
$curdate=sprintf("%04d%02d%02d",$curtime[5],$curtime[4],$curtime[3]);
@thisdate=listDate($curdate);

my $xmldoc=XML::Twig->new('twig_handlers' => { course => \&doCourse });

print STDERR "Current date: ".niceDate($curdate)."\n\n";
print "Current exercises: \n";

$xmldoc->parse(STDIN) unless $ARGV[0];
$xmldoc->parsefile($ARGV[0]) if $ARGV[0];
$xmldoc->purge;

sub niceDate($) {
    $date=shift;
    $date=~s/(....)(..)(..)/\3\/\2\/\1/;
    return $date;
}

sub listDate($) {
    $date=shift;
    $date=~s/(....)(..)(..)/\3\/\2\/\1/;
    return ($1, $2, $3);
}

sub doCourse {
    my ($t, $course)=@_;
    my $ex=$course->first_child('exercises')->first_child('exercise');
    return 1 unless defined $ex;
    do {
        if ($ex->first_child_text('startdate') le $curdate
            && $ex->first_child_text('enddate') ge $curdate
            && $ex->first_child_text('subtype') =~ /^(?:assessed|group)$/i) {
            my @enddate=listDate($ex->first_child_text('enddate'));
            my $daysleft = Day_of_Year($enddate[0], $enddate[1], $enddate[2]) - Day_of_Year($thisdate[0], $thisdate[1], $thisdate[2]);
            
            print "    \033[1;37m".$ex->first_child_text('title')."\033[0m";
            print " (" . $course->first_child_text('name') . ")";
            print "\n";
            print "      Due on: " . niceDate($ex->first_child_text('enddate')) . "\n";
            print "      That's ";
            if ($daysleft==0) {
                print "\033[1;5;7;31mTODAY\033[0m!\n";
            } elsif ($daysleft==1) {
                print "\033[1;7;31mTOMORROW\033[0m!\n";
            } elsif ($daysleft<4) {
                print "in \033[1;31mthe next few days\033[0m.\n";
            } elsif ($daysleft<7) {
                print "in \033[1;33mthe next seven days\033[0m.\n";
            } elsif ($daysleft<14) {
                print "in \033[33mthe next two weeks\033[0m.\n";
            } elsif ($daysleft>=14) {
                print "\033[32mages away\033[0m.\n";
            } else {
                print "in \033[32m" . $daysleft . "\033[0m days' time.\n";
            }
            print "\n";
        }
    } while ($ex=$ex->next_sibling);
    return 1;
}
