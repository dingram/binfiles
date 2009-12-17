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

use warnings;
use strict;
use LWP;
use Getopt::Long;
use Pod::Usage;
use HTML::TreeBuilder;

sub echo_on() { system "stty", "echo"; }
sub echo_off() { system "stty", "-echo"; }

sub xml_safe($) {
    my ($arg)=@_;
    $arg=~s/&/\&amp;/g;
    $arg=~s/</\&lt;/g;
    $arg=~s/>/\&gt;/g;
    $arg=~s/"/\&quot;/g;
    $arg=~s/'/\&apos;/g;
    return $arg;
}

############################################################

my $o_silent=(-t STDOUT)?1:0;

my ($o_color, $o_local, $o_help, $username, $class)=(1, 0, undef, undef, undef);

GetOptions(
    "silent"=>\$o_silent,
    "color|colour!"=>\$o_color,
    "local!"=>\$o_local,
    "user=s"=>\$username,
    "class=s"=>\$class,
    "help"=>\$o_help,
);

pod2usage(1) if $o_help;

# TODO: auto-calculate these things:
# used in date calculations
my $monthstart=1; # January
my $thisyear=2007;
# Other
my $year='2006';
my $period='3';

##########################################################################
my ($USER, $NORM, $BAD, $GOOD, $ICON);

if ($o_color) {
    ($USER, $NORM, $BAD, $GOOD, $ICON) = ("\033[36m", "\033[0m", "\033[31m", "\033[32m", "\033[1;30;43m");
} else {
    ($USER, $NORM, $BAD, $GOOD, $ICON) = ("", "", "", "", "");
}

my $password;
my $page;
my $browser=LWP::UserAgent->new;
$username=`id -un` unless $username;
$class=`id -gn` unless $class;
chomp $username;
chomp $class;
$class=~s/(?:se|mc|s)//g;

if (!$o_local) {
    print STDERR "Enter CATE password for user ${USER}$username${NORM}: ";
    echo_off();
    $password=<STDIN>;
    echo_on();
    chomp $password;

    #my $url="https://sparrow.doc.ic.ac.uk/~cate/timetable.cgi?keyt=$year:$period:$class:$username";
    my $url="https://sparrow.doc.ic.ac.uk/~cate/timetable.cgi?period=$period&class=$class&keyt=$year%3Anone%3Anone%3A$username";
    $browser->credentials('sparrow.doc.ic.ac.uk:443', 'Sparrow', $username => $password);

    print STDERR "\n\nFetching exercises timetable... " unless $o_silent;
    my $response=$browser->get($url);
    die "\n${BAD}Error:${NORM} Incorrect password\n"
        unless $response->is_success;

    $page=$response->content;
    print STDERR "${GOOD}done${NORM}.\n" unless $o_silent;
} else {
    open (LOCALPAGE, "<cate.html");
    $page=join("",<LOCALPAGE>);
    close LOCALPAGE;
}

print $page;

my $docroot=HTML::TreeBuilder->new_from_content($page);
$docroot->elementify();     # Do I need/want this? Probably.

my @dates=();
my $maintbl=($docroot->look_down('_tag','table'))[3];
my $infocell=(($docroot->look_down('_tag','table'))[0])->look_down('_tag','h1');
my $datetable=(($docroot->look_down('_tag','center'))[0])->right();
my @daterow=(($datetable->look_down('_tag','tr'))[2])->look_down('_tag','th');

my ($day,$month,$oday)=(0,$monthstart,0);
foreach my $dateval (@daterow) {
    $oday=$day unless $day==0;
    if ($dateval->as_text()=~/^\p{Z}*$/) {
        $day=0;
    } else {
        $day=$dateval->as_text();
        $month++ if ($day < $oday);
    }
    my $thisdate=sprintf("%02d%02d",$month,$day);
    push @dates, $thisdate;
}

# Get CATE page header
my $temp=$infocell->as_text();
my ($cate_period, $cate_year)=($temp=~/^(.*) (\d{4}-\d{4})$/);
my $now=localtime;

print "<?xml version=\"1.0\"?>\n<cate>\n";
print "  <user>$username</user>\n  <class>$class</class>\n";
print "  <period>$cate_period</period>\n";
print "  <year>$cate_year</year>\n\n";
print "  <periodid>$period</periodid>\n";
print "  <yearid>$year</yearid>\n\n";
print "  <generated>$now</generated>\n\n";

print "  <courses>\n";

# Get course rows
my @course_rows=($maintbl->look_down('_tag','tr', sub {
            my $sub=($_[0]->look_down('_tag', 'td'))[1];
            return 0 unless $sub;
            $sub->as_text()=~/(\d+)\s+-\s+(.+)/;
        }));

foreach my $course_row (@course_rows) {
    print "    <course>\n";
    my @course_cells=$course_row->look_down('_tag','td');
    shift @course_cells;    # lose the first empty cell
    my $course_info=shift @course_cells;
    my $course_classes=shift @course_cells;
    my @class_list=$course_classes->content_list();
    my $course_hasrecords=defined($course_info->look_down('src','icons/r.gif'));

    my ($course_id, $course_name)=($course_info->as_text()=~/(\d+)\s+-\s+(.+)/);
    $course_name=~s/ +$//;
    $course_name=xml_safe($course_name);

    print "      <id>$course_id</id>\n";
    print "      <name>$course_name</name>\n";
    print "      <classes>\n";
    foreach my $cont (@class_list) {
        if (ref($cont)) {
            if (lc($cont->attr('color')) eq 'red') {
                print "        <compulsory>".xml_safe($cont->as_text())."</compulsory>\n";
            } elsif (lc($cont->attr('color')) eq 'blue') {
                print "        <optional>".xml_safe($cont->as_text())."</optional>\n";
            } elsif (lc($cont->attr('color')) eq 'green') {
                print "        <notin>".xml_safe($cont->as_text())."</notin>\n";
            }
        }
    }
    print "      </classes>\n";
    # basically to be used in a for loop, to check rowdepth-1 right-siblings for exercises
    print "      <exercises>\n";

    my $exRow=$course_row;
    for (my $i=0; $i<$course_info->attr('rowspan'); $i++) {
        my $curcol=0;
        foreach my $ex_cell (@course_cells) {
            my $ex_title=$ex_cell->as_text();
            unless ($ex_title=~/^\p{Z}*$/) {
                my $ex_bg=lc($ex_cell->attr('bgcolor'));
                my $ex_link=$ex_cell->look_down('_tag','a',
                                    sub {
                                        not $_[0]->look_down('_tag','img');
                                    });
                my $ex_subt;
                if ($ex_bg eq 'white') {
                    $ex_subt='unassessed';
                } elsif ($ex_bg eq '#ccffcc') {
                    $ex_subt='assessed';
                } elsif ($ex_bg eq '#f0ccf0') {
                    $ex_subt='group';
                } else {
                    $ex_subt='unknown';
                }

                my $ex_hasgiven=defined($ex_cell->look_down('src','icons/g.gif'));
                $ex_title=~/^([0-9.]+):(\S+)\s+(.+?)\s*$/;
                print "        <exercise>\n";
                print "          <num>".xml_safe($1)."</num>\n";
                print "          <type>".xml_safe($2)."</type>\n";
                print "          <subtype>$ex_subt</subtype>\n";
                print "          <title>".xml_safe($3)."</title>\n";
                if (defined($ex_link)) {
                    $ex_link->attr('href')=~/key=\d+:\d+:(\d+):[^:]+:SPECS/;
                    my $ex_specid=$1;
                    print "          <specid>$ex_specid</specid>\n";
                }
                print "          <startdate>$thisyear$dates[$curcol]</startdate>\n";
                $curcol+=$ex_cell->attr('colspan') if $ex_cell->attr('colspan');
                $curcol++ unless $ex_cell->attr('colspan');
                print "          <enddate>$thisyear".$dates[$curcol-1]."</enddate>\n";

                if ($ex_hasgiven) {
                    my $giv_url="https://sparrow.doc.ic.ac.uk/~cate/".($ex_cell->look_down('src','icons/g.gif'))->parent()->attr('href');
                    print STDERR "${ICON} G ${NORM}: $course_name: $3... " unless $o_silent;
                    my $response=$browser->get($giv_url);
                    die "\n${BAD}Error retrieving given files for $course_name module, $3 exercise:${NORM} ", $response->status_line
                        unless $response->is_success;

                    my $giv_page=$response->content;
                    my $givdoc=HTML::TreeBuilder->new_from_content($giv_page);
                    $givdoc->elementify();
                    print STDERR "${GOOD}done${NORM}.\n" unless $o_silent;

                    print "          <givenfiles>\n";

                    # second DIV then 'rowspan' = '2'
                    my @giv_files=$givdoc->look_down(
                                                    '_tag', 'a',
                                                    'href', qr/showfile.cgi/
                                                    );

                    foreach my $giv_file (@giv_files) {
                        my $temp=$giv_file->as_text();
                        print "            <file>\n";
                        print "              <name>".xml_safe($temp)."</name>\n";
                        $giv_file->attr('href')=~/key=[^:]+:[^:]+:([^:]+):[^:]+:([^:]+):/;
                        print "              <fileid>$1:$2</fileid>\n";
                        $temp=$giv_file->parent->right->as_text();
                        print "              <timestamp>$temp</timestamp>\n";
                        $temp=$giv_file->parent->right->right->as_text();
                        print "              <size>$temp</size>\n";
                        $temp=$giv_file->parent->right->right->right->as_text();
                        print "              <hits>$temp</hits>\n";
                        print "            </file>\n";
                    }
                    print "          </givenfiles>\n";
                    $givdoc->delete();
                }
                print "        </exercise>\n";
            } else {
                $curcol+=$ex_cell->attr('colspan') if $ex_cell->attr('colspan');
                $curcol++ unless $ex_cell->attr('colspan');
            }
        }
        $exRow=$exRow->right();
        @course_cells=$exRow->look_down('_tag','td');
    }
    print "      </exercises>\n";
    unless ($o_local || !$course_hasrecords) {
        my $rec_url="https://sparrow.doc.ic.ac.uk/~cate/".($course_info->look_down('src','icons/r.gif'))->parent()->attr('href');
        print STDERR "${ICON} R ${NORM}: $course_name... " unless $o_silent;
        my $response=$browser->get($rec_url);
        die "\n${BAD}Error retrieving records for $course_name module:${NORM} ", $response->status_line
            unless $response->is_success;

        my $rec_page=$response->content;
        my $recdoc=HTML::TreeBuilder->new_from_content($rec_page);
        $recdoc->elementify();
        print STDERR "${GOOD}done${NORM}.\n" unless $o_silent;
        print "\n      <records>\n";

        print "        <exercises>\n";
        # second DIV then 'rowspan' = '2'
        my $rec_div=($recdoc->look_down('bgcolor','#BBF9F9'))[1];
        my @rec_exercises=$rec_div->look_down('rowspan','2');
        my @rec_exnum=();
        foreach my $rec_ex (@rec_exercises) {
            my $temp=$rec_ex->as_text();
            $temp=~/([0-9.]+)\s*([A-Z]{2,})\s*([a-z]+)\s*Due:\s+(.+?)\s*$/;
            print "          <exercise>\n";
            print "            <id>$1</id>\n";
            print "            <type>$2</type>\n";
            print "            <subtype>$3</subtype>\n";
            print "            <due>$4</due>\n";
            print "          </exercise>\n";
            push @rec_exnum, $1;
        }
        print "        </exercises>\n";
        my $rec_excount=$#rec_exercises+1;

        my @rec_rows=$rec_div->look_down('_tag','tr');
        splice (@rec_rows,0,3);    # lose the first two useless elements
        splice (@rec_rows,-1);     # lose the final (total) element

        print "        <students>\n";
        foreach my $rec_row (@rec_rows) {
            my @rec_cells=$rec_row->look_down('_tag','td');
            splice (@rec_cells,0,2);    # lose the first two useless elements
            my $rec_studentcell=shift @rec_cells;

            print "          <student>\n";
            print "            <login>".$rec_studentcell->as_text()."</login>\n";
            print "            <exercises>\n";
            my $rec_excount=0;
            foreach my $rec_ex (@rec_cells) {
                print "              <exercise>\n";
                print "                <id>$rec_exnum[$rec_excount]</id>\n";
                if ($rec_ex->as_text()=~/(\S+):\s*(\S+)/) {
                    print "                <type>$1</type>\n";
                    print "                <date>$2</date>\n";
                } elsif ($rec_ex->as_text()=~/([a-zA-Z0-9 ()]+)/) {
                    print "                <type>group</type>\n";
                    print "                <date>$1</date>\n";
                } else {
                    print "                <type>none</type>\n";
                }
                print "              </exercise>\n";
                $rec_excount++;
            }
            print "            </exercises>\n";
            print "          </student>\n";
        }
        print "        </students>\n";

        print "      </records>\n";
        $recdoc->delete();
    }
    print "    </course>\n";
}

print "  </courses>\n";
print "</cate>\n";

$docroot->delete();

__END__

=head1 NAME

cate2xml - Attempts to return data from CATE in XML format

=head1 SYNOPSIS

cate2xml.pl [options]

 Options:
   --help         this message
   --user=user    sets username to use when connecting to CATE
   --class=class  sets user's class (e.g. "c2", "j3") when connecting to CATE
   --nocolor      disables coloured progress output

=head1 OPTIONS

=over 8

=item B<--help>

Prints a brief help message and exits.

=item B<--user=>I<username>

Sets the username when connecting to CATE to I<username>.

=item B<--class=>I<class>

Sets the class (e.g. B<c2> for Computing year 2, B<j3> for JMC year 3, etc) that's used when connecting to CATE.

=item B<--[no[-]]color>

Enables coloured progress output (default). Adding "no" or "no-" to the option disables this behaviour.

=back

=head1 DESCRIPTION

B<cate2xml> will read details from CATE and output them in easily-parsed XML form. The details read include:

=over 8

=item B<*> Exercise timetable

=item B<*> Lists of given files for exercises, if available

=item B<*> Records for each module, if available

=back

=head1 AUTHOR

David Ingram (dave@partis-project.net)

=cut
