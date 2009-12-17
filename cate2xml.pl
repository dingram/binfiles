#!/usr/bin/perl

use strict;
use LWP;
use Date::Manip;
use Term::ReadKey;

die "Usage: $0 period class year startDate xmlFile\n" unless (@ARGV == 5);
my ($period, $class, $year, $startDate, $xmlFile) = (@ARGV);

open(XMLFILE, ">$xmlFile") or die " * Failed to open $xmlFile for writing\n";

#chomp(my $username = `whoami`);
my $username='dmi04';
print " * Using username $username to authenticate with CATE\n";

print " * Please enter your CATE password:\n";
print "   > ";
ReadMode("noecho");
chomp(my $password = ReadLine(0));
ReadMode("normal");
print "\n";

print " * Building URL from command line parameters\n";
print " * Using period $period, class $class and year $year to construct URL\n";

my $cateURL = "https://sparrow.doc.ic.ac.uk/~cate/";
my $url = "${cateURL}timetable.cgi?keyt=${year}:${period}:${class}:${username}";
my $browser = LWP::UserAgent->new();

$browser->credentials(
	"sparrow.doc.ic.ac.uk:443",
	"Sparrow",
	$username => $password
);

my $response = $browser->get($url);

if ($response->is_success) {
	print " * Successfully requested page, splitting content for parsing\n";
} else {
	die " * Failed to get page from CATE, aborting\n";
}
my $content = $response->content();
my @lines = split(/\n/, $content);

&Date_Init("DateFormat=non-US");

my ($courses, $lastCourse) = ({}, undef);

foreach my $line (@lines) {
	my $lineCopy = $line;

	if ($line =~ m#<font color="blue">(\d+)</font> - ([^<>]+)#) {
		print " * Creating entry for course: $1 - $2\n";
		$courses->{$1} = {
			name		=> $2,
			exercises	=> {}
		};

		$lastCourse = $1;
		next;
	}

	if ($line =~ m#<a href="(records.cgi\?.+?)">#) {
		print "   * Found records for course $lastCourse at: $1\n";
		$courses->{$lastCourse}->{recordsURL} = $1;

		next;
	}

	if ($line =~ m#<a href="(notes.cgi\?.+?)">#) {
		print "   * Found notes for course $lastCourse at: $1\n";
		my $notesResponse = $browser->get("${cateURL}${1}");
		if ($notesResponse->is_success) {
			print "     * Downloaded notes index, parsing\n";
			my @notesLines = split(/\n/, $notesResponse->content());
			foreach my $notesLine (@notesLines) {
				if ($notesLine =~ m#<a href="(showfile.cgi\?.+?NOTES:${username})">(.+?)</a>#) {
					print "       * Found notes on $2 at $1\n";
					push(@{$courses->{$lastCourse}->{notesList}}, {
						name	=> $2,
						link	=> $1,
					});
				}
			}
		} else {
			print "     * Spidering of notes failed, continuing\n";
		}

		next;
	}

	if ($line =~ m#colspan="(\d+)"[^<]*<b>(\d+):([^<>]+)</b> <a [^>]*>([^<>]+)</a>#) {
		while ($line =~ s#colspan="(\d+)"[^<]*<b>(\d+):([^<>]+)</b> <a href="([^"]+)"[^>]*>([^<>]+)</a>##) {
			my ($howLong, $exerciseNumber, $type, $specURL, $name) = ($1, $2, $3, $4, $5);
			my ($handInURL, $givenFileList, $ownerEmailDetails);

			print "   * Found active entry for course $lastCourse: $exerciseNumber - $type $name (lasts $howLong)\n";
			print "     * URL for exercise ($name) spec: $specURL\n";

			my $workLine = $lineCopy;
			my $daysIn = 0;
			$workLine =~ s#.*(<tr>.*?<b>${exerciseNumber}:${type}</b>)#\1#;
			while ($workLine =~ s#colspan="(\d+)"##) {
				$daysIn += $1;
				last unless $workLine =~ m#colspan="\d+".*<b>${exerciseNumber}:${type}</b>#;
			}
			$daysIn -= $howLong;

			$workLine = $lineCopy;
			$workLine =~ s#(<b>${exerciseNumber}:${type}</b>.*?</td>).*#\1#;
			while ($workLine =~ s#(<b>${exerciseNumber}:${type}</b>.*?)<a href="([^"]+)">#\1\3#) {
				my $linkURL = $2;
				if ($linkURL =~ /handins\.cgi/) {
					print "     * Found hand-in URL for $name: $linkURL\n";
					$handInURL = $linkURL;
				} elsif ($linkURL =~ /given\.cgi/) {
					print "     * Given files for $name found at ${linkURL}, spidering for content\n";

					my $givenResponse = $browser->get("${cateURL}${linkURL}");
					if ($givenResponse->is_success) {
						print "       * Downloaded file index page, parsing\n";
						my @givenData = split(/\n/, $givenResponse->content());
						foreach my $givenLine (@givenData) {
							if ($givenLine =~ m#<a href="(showfile.cgi\?.+?DATA:${username})">(.+?)</a>#) {
								print "         * Found given file link: $2 at $1\n";
								push(@{$givenFileList}, {
									name	=> $2,
									link	=> $1,
								});
							}
						}
					} else {
						print "       * Failed to spider for files, continuing processing\n";
						$givenFileList = [];
					}
				} elsif ($linkURL =~ /mailto:(.+)\?subject=(.+)/) {
					print "     * Owner email of $name found: $1\n";
					$ownerEmailDetails = {
						email	=> $1,
						subject	=> $2,
					};
				}
			}

			my $date = DateCalc($startDate, "+$daysIn days");
			print "     * Active entry $name starts on " . UnixDate($date, "%d/%m/%Y") . ", finishes on " . UnixDate(DateCalc($date, "+$howLong days"), "%d/%m/%Y\n");

			$courses->{$lastCourse}->{exercises}->{$exerciseNumber} = {
				name			=> $name,
				type			=> $type,
				length			=> $howLong,
				specURL			=> $specURL,
				startsOn		=> UnixDate($date, "%d/%m/%Y"),
				handInURL		=> $handInURL,
				givenFileList		=> $givenFileList,
				ownerEmailDetails 	=> $ownerEmailDetails,
			};
		}

		while ($line =~ s#colspan="(\d+)"[^<]*<b>(\d+):([^<>]+)</b> ([^<>]+)##) {
                        my ($howLong, $exerciseNumber, $type, $name) = ($1, $2, $3, $4);

			$name =~ s/^\s+//g; $name =~ s/\s+$//g;
                        print "   * Found inactive entry for course $lastCourse: $exerciseNumber - $type $name (lasts $howLong)\n";

			my $workLine = $lineCopy;
                        my $daysIn = 0;
                        $workLine =~ s#.*(<tr>.*?<b>${exerciseNumber}:${type}</b>)#\1#;
                        while ($workLine =~ s#colspan="(\d+)"##) {
                                $daysIn += $1;
                                last unless $workLine =~ m#colspan="\d+".*<b>${exerciseNumber}:${type}</b>#;
                        }
                        $daysIn -= $howLong;

                        my $date = DateCalc($startDate, "+$daysIn days");
                        print "     * Inactive entry $name starts on " . UnixDate($date, "%d/%m/%Y") . ", finishes on " . UnixDate(DateCalc($date, "+$howLong days"), "%d/%m/%Y\n");

                        $courses->{$lastCourse}->{exercises}->{$exerciseNumber} = {
                                name            => $name,
                                type            => $type,
                                length          => $howLong,
				startsOn	=> UnixDate($date, "%d/%m/%Y"),
                        };
                }

		next;
	}

	if ($line =~ m#colspan="(\d+)"[^<]*<b>(\d+):([^<>]+)</b> ([^<>]+)#) {
		while ($line =~ s#colspan="(\d+)"[^<]*<b>(\d+):([^<>]+)</b> ([^<>]+)##) {
			my ($howLong, $exerciseNumber, $type, $name) = ($1, $2, $3, $4);

			$name =~ s/^\s+//g; $name =~ s/\s+$//g;
			print "   * Found inactive entry for course $lastCourse: $exerciseNumber - $type $name (lasts $howLong)\n";

			my $workLine = $lineCopy;
                        my $daysIn = 0;
                        $workLine =~ s#.*(<tr>.*?<b>${exerciseNumber}:${type}</b>)#\1#;
                        while ($workLine =~ s#colspan="(\d+)"##) {
                                $daysIn += $1;
                                last unless $workLine =~ m#colspan="\d+".*<b>${exerciseNumber}:${type}</b>#;
                        }
                        $daysIn -= $howLong;

                        my $date = DateCalc($startDate, "+$daysIn days");
                        print "     * Inactive entry $name starts on " . UnixDate($date, "%d/%m/%Y") . ", finishes on " . UnixDate(DateCalc($date, "+$howLong days"), "%d/%m/%Y\n");

			$courses->{$lastCourse}->{exercises}->{$exerciseNumber} = {
				name		=> $name,
				type		=> $type,
				length		=> $howLong,
				startsOn	=> UnixDate($date, "%d/%m/%Y"),
			};
		}

		next;
	}
}

print " * Outputting parsed data to XML\n";
print XMLFILE qq#<timetable username="${username}" period="${period}" class="${class}">\n#;

while (my ($courseNumber, $courseHash) = each(%{$courses})) {
	print XMLFILE qq#\t<course number="${courseNumber}" name="$courseHash->{name}">\n#;

	if (exists($courseHash->{recordsURL})) {
		print XMLFILE qq#\t\t<records url="${cateURL}$courseHash->{recordsURL}"/>\n#;
	}

	if (exists($courseHash->{notesList})) {
		print XMLFILE qq#\t\t<notes>\n#;
		foreach my $notesData (@{$courseHash->{notesList}}) {
			print XMLFILE qq#\t\t\t<data url="${cateURL}$notesData->{link}">$notesData->{name}</data>\n#;
		}
		print XMLFILE qq#\t\t</notes>\n#;
	}

	print XMLFILE qq#\t\t<exercises>\n#;
	foreach my $exerciseNumber (sort(keys(%{$courseHash->{exercises}}))) {
		my $exerciseHash = $courseHash->{exercises}->{$exerciseNumber};
		print XMLFILE qq#\t\t\t<exercise number="${exerciseNumber}" name="$exerciseHash->{name}">\n#;

		print XMLFILE qq#\t\t\t\t<type>$exerciseHash->{type}</type>\n#;
		print XMLFILE qq#\t\t\t\t<startDate>$exerciseHash->{startsOn}</startDate>\n#;
		print XMLFILE "\t\t\t\t<endDate>" . UnixDate(DateCalc(ParseDate($exerciseHash->{startsOn}), "+" . ($exerciseHash->{length} - 1) . " days"), "%d/%m/%Y") . "</endDate>\n";

		if (exists($exerciseHash->{specURL})) {
			print XMLFILE qq#\t\t\t\t<specification>${cateURL}$exerciseHash->{specURL}</specification>\n#;
		}

		if (exists($exerciseHash->{handInURL})) {
			print XMLFILE qq#\t\t\t\t<handIn>${cateURL}$exerciseHash->{handInURL}</handIn>\n#;
		}

		if (exists($exerciseHash->{givenFileList})) {
			print XMLFILE qq#\t\t\t\t<givenFiles>\n#;

			foreach my $givenFileHash (@{$exerciseHash->{givenFileList}}) {
				print XMLFILE qq#\t\t\t\t\t<data url="${cateURL}$givenFileHash->{link}">$givenFileHash->{name}</data>\n#;
			}

			print XMLFILE qq#\t\t\t\t</givenFiles>\n#;
		}

		if (exists($exerciseHash->{ownerEmailDetails})) {
			print XMLFILE qq#\t\t\t\t<owner email="$exerciseHash->{ownerEmailDetails}->{email}" subject="$exerciseHash->{ownerEmailDetails}->{subject}"/>\n#;
		}

		print XMLFILE qq#\t\t\t</exercise>\n#;
	}
	print XMLFILE qq#\t\t</exercises>\n#;

	print XMLFILE qq#\t</course>\n#;
}

print XMLFILE qq#</timetable>#;
close(XMLFILE);
print " * Successfully scraped CATE, finishing\n";
