#!/usr/bin/perl

package CalOutput::iCal;

use Date::Parse;
use POSIX;

sub new {
	my ($class, $wk1start) = @_;
	my $this = { };
	bless $this, $class;
	$this->{str} = <<"PREAMBLE";
BEGIN:VCALENDAR
PRODID
 :-//Peter Collingbourne//NONSGML Timetable Parser 0.01//EN
VERSION
 :2.0
PREAMBLE
	$this->{wk1start} = str2time($wk1start);
	return $this;
}

sub set_output_file {
	my ($this, $file) = @_;
	$this->{outfile} = $file;
}

sub week_date_to_unixdate {
	my ($this, $week, $day, $time) = @_;
	my $numdate = $this->{wk1start};
	print unixdate_to_ical_date($numdate) . "\n";
	$numdate += ($week-1) * 86400*7;
	print unixdate_to_ical_date($numdate) . "\n";
	if ($day =~ "Tuesday") {
		$numdate += 86400;
	} elsif ($day =~ "Wednesday") {
		$numdate += 86400*2;
	} elsif ($day =~ /Thursday/) {
		$numdate += 86400*3;
	} elsif ($day =~ "Friday") {
		$numdate += 86400*4;
	}
	print unixdate_to_ical_date($numdate) . "\n";
	$numdate = fix_dst($numdate);
	print unixdate_to_ical_date($numdate) . "\n";
	$time =~ s/.*?(\d\d)\d\d.*?/\1/mg;
	print "time: " . $time . " :emit\n";
	$numdate += $time*3600;
	print "Week $week $day - $time => ";
	print unixdate_to_ical_date($numdate) . "\n\n\n\n";
	return $numdate;
}

sub unixdate_to_ical_date {
	my ($time) = @_;
	return POSIX::strftime("%Y%m%dT%H%M%S", localtime($time));
}

sub ical_dotw {
	my ($dotw) = @_;
	if ($dotw eq "Monday") {
		return "MO";
	} elsif ($dotw eq "Tuesday") {
		return "TU";
	} elsif ($dotw eq "Wednesday") {
		return "WE";
	} elsif ($dotw eq "Thursday") {
		return "TH";
	} elsif ($dotw eq "Friday") {
		return "FR";
	}
}

sub fix_dst { # Fix DST issues by calibrating to the nearest 12:00am
	my ($t) = @_;
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($t);
	if ($hour == 23) {
		$t += 3600;
	} elsif ($hour == 1) {
		$t -= 3600;
	}
	return $t;
}

sub ical_format {
	my ($s) = @_;
	$s =~ s/\\/\\\\/g;
	$s =~ s/,/\\,/g;
	$s =~ s/;/\\;/g;
	return $s;
}

sub add_slot {
	my ($this, $course, $room, $day, $time, $wkst, $wked) = @_;
	my $now_as_ical = unixdate_to_ical_date(time);
	$id++;
	my $isseq;
	my $rrule;
	print "weeks $wkst to $wked\n";
	my $unixws = $this->week_date_to_unixdate($wkst, $day, $time);
	my $bgstr = unixdate_to_ical_date($unixws);
	my $edstr = unixdate_to_ical_date($unixws+3600);
	if ($wkst != $wked) {
		$isseq = 1;
		my $endd = unixdate_to_ical_date($this->week_date_to_unixdate($wked, $day, $time));
		my $dotw = ical_dotw($day);
		$rrule = <<"RULE";
RRULE
 :FREQ=WEEKLY;UNTIL=$endd;INTERVAL=1;BYDAY=$dotw
RULE
	} else {
		$isseq = 0;
		$rrule = "";
	}
	my $icourse = ical_format($course);
	my $iroom = ical_format($room);
	$this->{str} .= <<"SLOT";
BEGIN:VEVENT
CREATED
 :${now_as_ical}Z
UID
 :TP-$id
SEQUENCE
 :$isseq
LAST-MODIFIED
 :${now_as_ical}Z
DTSTAMP
 :${now_as_ical}Z
ORGANIZER
 :MAILTO:nobody\@nowhere
SUMMARY
 :$icourse
LOCATION
 :$iroom
CLASS
 :PUBLIC
PRIORITY
 :3
X-PILOTID
 :0
X-PILOTSTAT
 :1
${rrule}DTSTART
 :$bgstr
DTEND
 :$edstr
END:VEVENT
SLOT
}

sub print {
	my ($this) = @_;
	open(OUT, ">$this->{outfile}") or die "$this->{outfile}: $!";
	print OUT $this->{str};
	print OUT "END:VCALENDAR\n";
	close(OUT);
}

package CourseInfo;

sub new {
	my ($class, @pinfo) = @_;
	my $this = { };
	bless $this, $class;
	$this->parse(@pinfo);
	return $this;
}

sub parse_type {
	my ($this, $ptype) = @_;
	my $type = { };
	my ($typeinfo, $lecinfo, $room) = split(m! / !, $ptype);
	if ($typeinfo =~ /([A-Z]+) \(([0-9]+)-([0-9]+)\)/) {
		$type->{type} = $1;
		$type->{weekbegin} = $2;
		$type->{weekend} = $3;
	}
	$type->{lecturers} = [];
	my @lecinfos = split(/, /, $lecinfo);
	for my $linfo (@lecinfos) {
		my $lecturer = { };
		if ($linfo =~ /([A-Za-z\.0-9]+) \(([0-9]+)-([0-9]+)\)/) {
			$lecturer->{name} = $1;
			$lecturer->{weekbegin} = $2;
			$lecturer->{weekend} = $3;
		}
		push @{$type->{lecturers}}, $lecturer;
	}
	if (($room =~ /MENG/) || ($room =~ /EE/) || ($room =~ /Tanaka/)) {
		$type->{room} = $room;
	} else {
		$type->{room} = "huxley $room";
	}
	return $type;
}
	
sub parse {
	my ($this, @pinfo) = @_;
	$this->{types} = [ ];
	if ((@pinfo == 1) || ($pinfo[1] !~ m!/!)) { # The second case is for when a room only appears in the second line
		my $str = $pinfo[0];
		$this->{name} = $str;
		if ($str =~ /Week ([0-9]+)/) {
			my $week = 0+$1;
			my $type = { };
			$type->{type} = "";
			$type->{weekbegin} = $week;
			$type->{weekend} = $week;
			$type->{lecturers} = [];
			$type->{room} = $pinfo[1] if (@pinfo > 1);
			$this->{types}[0] = $type;
		}
	} else {
		$this->{name} = $pinfo[0];
		for my $i (1..$#pinfo) {
			push @{$this->{types}}, $this->parse_type($pinfo[$i]);
		}
	}
}

sub get_transition_times {
	my ($this) = @_;
	my @is_transtime = ();
	for my $type (@{$this->{types}}) {
		$is_transtime[$type->{weekbegin}] = 1;
		$is_transtime[$type->{weekend}+1] = 1;
		for my $lec (@{$type->{lecturers}}) {
			$is_transtime[$lec->{weekbegin}] = 1;
			$is_transtime[$lec->{weekend}+1] = 1;
		}
	}
	my @transtimes = ();
	for my $i (0..$#is_transtime) {
		if ($is_transtime[$i]) {
			push @transtimes, $i;
		}
	}
	return @transtimes;
}

sub get_formatted_string_for_week {
	my ($this, $week) = @_;
	my $str = $this->{name};
	my @rooms = ();
	my $hasoktype = 0;
	for my $type (@{$this->{types}}) {
		next unless (($week >= $type->{weekbegin}) && ($week <= $type->{weekend}));
		$hasoktype = 1;
		$str .= " (".$type->{type}.":";
		for my $lec (@{$type->{lecturers}}) {
			next unless (($week >= $lec->{weekbegin}) && ($week <= $lec->{weekend}));
			$str .= " ".$lec->{name};
		}
		$str .= ")";
		push @rooms, $type->{room};
	}
	my $rooms = join(", ", @rooms);
	if (!$hasoktype) {
		return ("", "");
	} else {
		return ($str, $rooms);
	}
}

package CalParser;

use HTML::Parser;

sub new {
	my ($class) = @_;
	my $this = { };
	bless $this, $class;
	return $this;
}

sub set_output {
	my ($this, $output) = @_;
	$this->{out} = $output;
}

sub do_parse {
	my ($this, $file) = @_;
	my $parser = new HTML::Parser(
		api_version => 3,
		start_h => [sub { $this->c_start($_[0]) }, "tagname"],
		end_h => [sub { $this->c_end($_[0]) }, "tagname"],
		text_h => [sub { $this->c_text($_[0]) }, "dtext"],
	);
	$this->{parser} = $parser;
	$this->{inside} = 0;
	$this->{rownum} = -1;
	$parser->parse_file($file) or die "$file: $!";
	$this->{out}->print;
}

sub c_start {
	my ($this, $tagname) = @_;
	if ($tagname eq "tr") {
		$this->{rownum}++;
		$this->{colnum} = -1;
	}
	if (($tagname eq "td") || ($tagname eq "th")) {
		$this->{colnum}++;
		$this->{linenum} = 0;
		$this->{inside} = 1;
	}
	if ($tagname eq "br") {
		$this->end_line();
	}
}

sub c_end {
	my ($this, $tagname) = @_;
	if (($tagname eq "td") || ($tagname eq "th")) {
		$this->{inside} = 0;
		$this->end_line();
		$this->end_entry();
	}
}

sub c_text {
	my ($this, $text) = @_;
	$this->{inside} or return;
	my $rn = $this->{rownum};
	my $cn = $this->{colnum};
	if (($rn == 0) && ($cn == 0)) {
		# do nothing
	} elsif ($rn == 0) {
		$this->{colnames}[$cn-1] .= $text;
	} elsif ($cn == 0) {
		$this->{rownames}[$rn-1] .= $text;
	} else {
		$this->{cur_line} .= $text;
	}
}

sub end_entry {
	my ($this) = @_;
	@{$this->{cur_lines}} or return;
	my $ci = new CourseInfo(@{$this->{cur_lines}});
	my @tp = $ci->get_transition_times;
	for my $i (0..$#tp) {
		my $beginweek = $tp[$i];
		print "beginweek $beginweek\n";
		# The 11 on the following line is actually not a hardcoded
		# value, it should only be used in dire circumstances
		# (e.g. an event starts but does not stop for some reason)
		my $endweek = ($i == $#tp) ? 12 : $tp[$i+1]-1;
		print "endweek $endweek\n";
		my ($str, $room) = $ci->get_formatted_string_for_week($beginweek);
		print "$str\n";
		if ($str) {
			$this->{out}->add_slot($str, $room, $this->{colnames}[$this->{colnum}-1], $this->{rownames}[$this->{rownum}-1], $beginweek, $endweek);
		}
	}
	$this->{cur_lines} = [];
}

sub end_line {
	my ($this) = @_;
	if ($this->{cur_line}) {
		push @{$this->{cur_lines}}, $this->{cur_line};
		$this->{cur_line} = "";
	} else {
		$this->end_entry();
	}
}
	
package main;

use Getopt::Long;

sub main {
	my $wk1start, $input, $output;
	GetOptions("s|start=s" => \$wk1start, "o|output=s" => \$output) or die "Required options missing";
	my $input = $ARGV[0] or die "No input file specified";
	$wk1start or die "No start date specified";
	unless ($output) {
		$output = $input;
		$output =~ s/\.html?$//ig;
		$output .= ".ics";
	}
	print STDERR "Generating ICAL output to '$output'\n";
	my $cp = new CalParser;
	my $ical = new CalOutput::iCal($wk1start);
	$ical->set_output_file($output);
	$cp->set_output($ical);
	$cp->do_parse($input);
}

main;


