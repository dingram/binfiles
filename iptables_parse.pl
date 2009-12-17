#!/usr/bin/perl -w

use strict;
use warnings;

my %optconv=(
  'A' => 'append',
  'D' => 'delete',
  'I' => 'insert',
  'R' => 'replace',
  'L' => 'list',
  'F' => 'flush',
  'Z' => 'zero',
  'N' => 'new-chain',
  'X' => 'delete-chain',
  'P' => 'policy',
  'E' => 'rename-chain',
  'p' => 'protocol',
  's' => 'source',
  'd' => 'destination',
  'j' => 'jump',
  'i' => 'in-interface',
  'o' => 'out-interface',
  'f' => 'fragment',
  'm' => 'match',
  # Also:
  # src-range
  # dst-range
  # source-ports
  # destination-ports
  # ports
  # state
  # to-destination
  # to-ports
  'sport' => 'source-port',
  'dport' => 'destination-port'
);

while (<>) {
  chomp;
  if (/^\*(\w+)/) {
    ##> table
    print "\033[37mTable \033[1;33m$1\033[0m:\n";
  } elsif (/^:(\w+) (\w+)/) {
    ##> default target
    print " Chain \033[1;37m$1\033[0m default policy: \033[1;31m$2\033[0m\n";
  } elsif (/^#/) {
    ##> comment
  } elsif (/^\[/) {
    ##> rule
    # decode rule into hash
    s/^\[\d+:\d+\] //;
    my %ruleparts=();
    my @rule=split / +/;
    for (my $i=0; $i<$#rule; $i+=2) {
      $rule[$i]=~s/^-+//;
      $rule[$i]=$optconv{$rule[$i]} if ($optconv{$rule[$i]});
      $ruleparts{$rule[$i]} = $rule[$i+1];
      if ($ruleparts{$rule[$i]} eq '!') {
        $ruleparts{$rule[$i]} .= splice (@rule, $i+2, 1);
      }
    }

#    print "\033[36m";
#    foreach my $k (sort keys %ruleparts) {
#      print "   $k => $ruleparts{$k}\n";
#    }
#    print "\033[0m";

    my $ruletext="  \033[1;37m";
    $ruletext.=$ruleparts{'append'}."\033[0m chain: ";

    my $rp=$ruleparts{'in-interface'};
    $ruletext.=&isNot(\$rp)."from interface \033[1;37m$rp\033[0m, " if $rp;

    $rp=$ruleparts{'out-interface'};
    $ruletext.=&isNot(\$rp)."to interface \033[1;37m$rp\033[0m, " if $ruleparts{'out-interface'};

    $rp=$ruleparts{'source'};
    $ruletext.=&isNot(\$rp)."from host \033[1;37m$rp\033[0m, " if $ruleparts{'source'};

    $rp=$ruleparts{'source-port'};
    $ruletext.=&isNot(\$rp)."from port \033[1;37m$rp\033[0m, " if $ruleparts{'source-port'};

    $rp=$ruleparts{'destination'};
    $ruletext.=&isNot(\$rp)."destined to host \033[1;37m$rp\033[0m, " if $ruleparts{'destination'};

    $rp=$ruleparts{'destination-port'};
    $ruletext.=&isNot(\$rp)."destined to port \033[1;37m$rp\033[0m, " if $ruleparts{'destination-port'};

    $rp=$ruleparts{'protocol'};
    $ruletext.=&isNot(\$rp)."using \033[1;37m$rp\033[0m protocol, " if $ruleparts{'protocol'};

    $rp=$ruleparts{'to-destination'};
    $ruletext.="redirect to \033[1;32m$rp\033[0m, " if $ruleparts{'to-destination'};

    if ($ruleparts{'match'}) {
      if ($ruleparts{'match'} eq 'state') {

        $rp=$ruleparts{'state'};
        $ruletext.="connection state ".&isNot(\$rp)."\033[1;32m$rp\033[0m, " if $rp;
      }
    }
    $ruletext.="policy \033[1;36m".$ruleparts{'jump'}."\033[0m" if $ruleparts{'jump'};

    print "$ruletext\033[0m\n";
  } elsif (/^COMMIT$/) {
    ##> end of table
    print "\n";
  }
}


sub isNot(\$) {
  my $thing=shift;
  if (substr($$thing, 0, 1) eq '!') { $$thing=substr($$thing,1); return "\033[1;4;31mNOT\033[0m "; }
  else { return ''; }
}
