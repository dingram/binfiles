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
#
# Reads a timetable from the web or a local file and parses it to XML
#

use warnings;
use strict;
use LWP;

use constant {
    STATE_UNDEF     => -1,
    STATE_TERM      =>  0,
    STATE_CLASS     =>  1,
    STATE_DATES     =>  2,
    STATE_TIME      =>  3,
    STATE_MON       =>  4,
    STATE_TUE       =>  5,
    STATE_WED       =>  6,
    STATE_THU       =>  7,
    STATE_FRI       =>  8,
    STATE_EOF       =>  9
};

my %dayorder = ('mon'=>1, 'tue'=>2, 'wed'=>3, 'thu'=>4, 'fri'=>5);

sub thisTerm() {
    my $mon=(localtime)[4]+1;
    if    ($mon < 4) { return "spring"; }
    elsif ($mon < 7) { return "summer"; }
    elsif ($mon < 9) { return ""; }
    else             { return "autumn"; }
}

my $state=STATE_TERM;
my @days=( "mon", "tue", "wed", "thu", "fri");
my %days=(
    "mon" => [],
    "tue" => [],
    "wed" => [],
    "thu" => [],
    "fri" => [],
);
my @input;

if ($ARGV[0] eq "") {
    @input=<STDIN>;
} else {
    if ($ARGV[0]=~m#^http://#i) {
        # full web address
        my $browser=LWP::UserAgent->new;
        my $response=$browser->get($ARGV[0]);
        die "Error: ", $response->status_line unless $response->is_success;
        @input=split /[\r\n]+/, $response->content;

    } elsif (-r $ARGV[0]) {
        # file is readable - slurp it
        open FILE, "<", $ARGV[0];
        @input = <FILE>;
        close FILE;
    } elsif ($ARGV[0]=~/\d_\d+_\d+$/i) {
        my $url;
        if (defined $ARGV[1] && $ARGV[1]=~/(?:autumn|spring|summer)/i) {
            # Assume it's a timetable for the given term
            $url="http://www.doc.ic.ac.uk/teaching/timetables/".lc($ARGV[1])."/class/$ARGV[0].htm";
        } else {
            # Assume it's a timetable for current term
            $url="http://www.doc.ic.ac.uk/teaching/timetables/".thisTerm()."/class/$ARGV[0].htm";
        }

        # fetch URL
        my $browser=LWP::UserAgent->new;
        my $response=$browser->get($url);
        die "Error: ", $response->status_line unless $response->is_success;
        @input=split /[\r\n]+/, $response->content;
    } else {
        die "Cannot handle input file $ARGV[0]\n";
    }
}

my @lines=map { s/<t([hrd])>[\n\r]+/<t$1>/imsg; $_; } grep { (!/<\/?(?:html|head|body|meta|title|h3|thead|tbody)>/i) } map {s/<([^ >]+)( [^>]+)?>/<$1>/g; $_;} @input;

print "<?xml version=\"1.0\"?>\n<timetable>\n";

foreach (@lines) {
    if ($state==STATE_TERM) {
        next unless (/^<font>.+[0-9]{4}<\/font>/i);
        s/font/term/ig;
        print " $_";
        $state=STATE_CLASS;
    } elsif ($state==STATE_CLASS) {
        next unless (/^<font>.+\(Week.*\)<\/font>/i);
        if (/\(Week.+(\d+)\s*-\s*(\d+)\)/) {
            print "\n <weekstart>$1</weekstart>\n <weekend>$2</weekend>\n";
        } elsif (/\(Week.+(\d+)\)/) {
            print "\n <weekstart>$1</weekstart>\n <weekend>$1</weekend>\n";
        }
        s/font/class/ig;
        s/ +\(Week[^)]+\)//i;
        print " $_";
        $state=STATE_DATES;
    } elsif ($state==STATE_DATES) {
        next unless (/^<font>Week.+start date:.+<\/font>.+Date Published:.+<br>/i);
        s/<font>Week.+start date:\s*(.*)<\/font>.+Date Published:\s*(.*)<\/i>.*/\n <effective>$1<\/effective>\n <published>$2<\/published>/i;
        print;
        $state=STATE_TIME;
    } elsif ($state==STATE_TIME) {
        next unless (/<font>\d{4}<\/font>/i);
        s/<font>/<!-- /;
        s/<\/font>/ -->/;
        #print;
        $state=STATE_MON;
    } elsif ($state>=STATE_MON && $state<=STATE_FRI) {
        next unless (/<font>.+<\/font>/i);
        s/<font>(.+)<\/font>/$1/i;
        push @{$days{$days[$state - STATE_MON]}}, $_;
        $state=($state==STATE_FRI)?STATE_TIME:$state+1;
    } else {
        print if $_;
    }
}
print "\n <days>\n";

foreach (sort {$dayorder{$a}<=>$dayorder{$b}} keys %days) {
    print "  <$_>\n";
    my $time=9;
    foreach (@{$days{$_}}) { &doPeriod($time,$_); $time++; }
    print "  </$_>\n";
}

print " </days>\n";
print "</timetable>\n";

sub doPeriod($$) {
    my ($time, $lecstring, undef)=@_;
    print "   <period>\n";
    printf ("    <time>%02d00</time>\n", $time);
    chomp $lecstring;
    my @lecs=split(/<br><br>/i, $lecstring);
    foreach (@lecs) {
        chomp;
        next if (/^<br>$/);
        print "    <lecture>\n";
        /^(.*)<br>(\S+)\s+\((\d+)-(\d+)\)\s+\/\s+(.*)\s+\/\s+(.*)/i;
        my ($title, $type, $weekstart, $weekend, $lecturers, $rooms)=($1, $2, $3, $4, $5, $6);
        print "     <title>$title</title>\n";
        print "     <type>$type</type>\n";
        print "     <weekstart>$weekstart</weekstart>\n";
        print "     <weekend>$weekend</weekend>\n";

        my @lectlist=split(/,/i, $lecturers);
        #print "     <lecturers>$lecturers</lecturers>\n";
        print "     <lecturers>\n";
        foreach (@lectlist) {
            /(\S+)\s+\((\d+)-(\d+)\)/i;
            print "      <lecturer>\n";
            print "       <name>$1</name>\n";
            print "       <weekfrom>$2</weekfrom>\n";
            print "       <weekto>$3</weekto>\n";
            print "      </lecturer>\n";
        }
        print "     </lecturers>\n";

        $rooms=~s/,/\//g;
        print "     <rooms>$rooms</rooms>\n";
        print "    </lecture>\n";
    }
    print "   </period>\n";
}
