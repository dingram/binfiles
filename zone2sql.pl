#!/usr/bin/perl -w
use strict;

my $userid=0;

my @validrr=(
  'A',     'AAAA',  'A6',     'AFSDB',
  'CNAME', 'DNAME', 'DNSKEY', 'DS',
  'HINFO', 'ISDN',  'KEY',    'LOC',
  'MX',    'NAPTR', 'NS',     'NSEC',
  'NXT',   'PTR',   'RP',     'RRSIG',
  'RT',    'SOA',   'SRV',    'SIG',
  'TXT',   'WKS',   'X25'
);
my $validrrs=join '|', @validrr;
my $lastname='@';

sub real_prev_token($\@) {
  my @tokens = @{$_[1]};
  my $tok=$tokens[--$_[0]];
  return $tok;
}

sub prev_token($\@) {
  my @tokens = @{$_[1]};
  my $tok=$tokens[--$_[0]];
  while ($tok =~ /^\s*$/ && $_[0]<$#tokens) {
    #print "[token $_[0] empty]\n";
    $tok=$tokens[--$_[0]];
  }
  return $tok;
}

sub next_token($\@) {
  my @tokens = @{$_[1]};
  my $tok=$tokens[++$_[0]];
  while ($tok =~ /^\s*$/ && $_[0]<$#tokens) {
    #print "[token $_[0] empty]\n";
    $tok=$tokens[++$_[0]]; 
  }
  return $tok;
}

sub handle_rr($\@) {
  my @tokens = @{$_[1]};
  my $i = \$_[0];
  my @data=('', 'NULL', 'IN', $tokens[$$i], '');

  #print "Current token $$i: $tokens[$$i]\n";
  #print "Going back four tokens:\n";
  my $ii = $$i;
  my $tok='';

  # should be class
  $tok = real_prev_token( $ii, @tokens );
  if ($tok =~ /^(IN|CH|HS)$/) {
    $data[2]=$tok;
    $tok = real_prev_token( $ii, @tokens );
  }

  # should be ttl
  if ($tok !~ /^[0-9]+$/ && $tok ne "\n") {
    $data[0]=$tok;

  } elsif ($tok ne "\n") {
    $data[1]=$tok;

    # should be host
    $tok = real_prev_token( $ii, @tokens );
    $data[0]=$tok;
  } else {
    print STDERR "\e[1;31m>>>\e[m Found a record with no name; assuming name should be \e[31m$lastname\e[m\n";
    $data[0]=$lastname;
  }
  $lastname=$data[0];

  $data[4]=next_token ($$i, @tokens);
  $data[4].=':'.next_token ($$i, @tokens) if ($data[3] eq 'MX');

  dump_rr(@data);
}

my @tokens=();
while (<>) {
  s/\s*;.*$//;
  s/^\s+//;
  next if (/^$/);

  my @bits=split /[\t ]+/;
  chomp @bits;
  push (@tokens, @bits, "\n");
}

my $def_ttl;

for (my $i=0; $i<$#tokens; $i++) {
  if ($tokens[$i] =~ /\$TTL/) {
    $def_ttl=$tokens[++$i];
  } elsif ($tokens[$i] =~ /^IN$/) {
    $i++; # next token...

    if ($tokens[$i] eq "SOA") {
      my @soa=();
      $soa[0]=$tokens[$i-2]; # domain
      $soa[1]=next_token ( $i, @tokens ); # primary ns
      $soa[2]=next_token ( $i, @tokens ); # responsible person
      $soa[3]=next_token ( $i, @tokens ); # serial
      $soa[3] =~ s/\(//;
      $soa[3]=next_token ( $i, @tokens ) if ($soa[3] eq '');
      $soa[4]=next_token ( $i, @tokens ); # refresh
      $soa[5]=next_token ( $i, @tokens ); # retry
      $soa[6]=next_token ( $i, @tokens ); # expire
      $soa[7]=next_token ( $i, @tokens ); # min_ttl

      $lastname=$soa[0];

      &dump_soa(@soa, $def_ttl);

    } elsif ($tokens[$i] =~ /^$validrrs$/) {
      handle_rr($i, @tokens);
    }
  } elsif ($tokens[$i] =~ /^$validrrs$/) {
    handle_rr($i, @tokens);
  }
}

sub dump_soa() {
  my ($domain, $ns, $resp, $ser, $ref, $ret, $exp, $min, $def_ttl) = @_;
  print "INSERT INTO `dns_zones` (`user_id`, `domain`, `primary_ns`, `responsible`, `serial`, `refresh`, `retry`, `expire`, `minimum`, `default_ttl`, `created`, `modified`) VALUES ";

  print "($userid, '$domain', '$ns', '$resp', $ser, $ref, $ret, $exp, $min, $def_ttl, NOW(), NOW());\n";
  print "SET \@zone = LAST_INSERT_ID();\n";
}

sub dump_rr() {
  my ($host, $ttl, $class, $rr, $data) = @_;
  print "INSERT INTO `dns_records` (`dns_zone_id`, `host`, `ttl`, `class`, `rr`, `data`, `created`, `modified`) VALUES ";
  print "(\@zone, '$host', $ttl, '$class', '$rr', '$data', NOW(), NOW());\n";
}
