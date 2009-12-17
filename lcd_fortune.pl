#!/usr/bin/perl -w

# fortune.pl - an example client for LCDproc

# This is just a small example of a client for LCDd the
# LCDproc server
#
# Copyright (c) 1999, William Ferrell, Scott Scriven
#               2001, David Glaude
#               2002, Jonathan Oxer
#               2002, Rene Wagner <reenoo@gmx.de>
#
# This file is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# any later version.
#
# This file is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this file; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
#

use LCDd;

############################################################
# Configurable part. Set it according your setup.
############################################################

# Path to `fortune' program.
$FORTUNE = "fortune";

# Host which runs lcdproc daemon (LCDd)
$HOST = "localhost";

# Port on which LCDd listens to requests
$PORT = "13666";

############################################################
# End of user configurable parts
############################################################


# Connect to the server...
$lcd = LCDd->new(
    server  => $HOST,
    port  => $PORT,
    name => "fortune.pl" )
	|| die "Cannot connect to LCDproc port\n";

$screen = LCDd::Screen->new( $lcd, name=>"fortune",
                                -onIgnore=>\&update_text );
$widget[0] = LCDd::Title->new( $screen, title=>"Fortune" );
$widget[1] = LCDd::Scroller->new( $screen );

update_text();

$lcd->Pump();
exit;

sub update_text {
    # Grab some text.
    $text = `$FORTUNE` || die "\n$0: Error running `$FORTUNE'.\nPlease check that the path is correct.\n\n";
    @lines = split(/\n/, $text);
    $text = join(" / ", @lines);

    # Now, show a fortune...
#    print $remote "widget_set fortune text 1 2 20 4 v 16 {$text}\n";
    $widget[1]->set(
      left	=> 1,
      top	=> 2,
      right	=> 20,
      bottom=> 4,
      dir	=> "v",
      speed	=> 16,
      text	=> $text,
    );
}

1;
