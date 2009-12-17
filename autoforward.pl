#!/usr/bin/perl
################################################################################
# This program is released under a Creative Commons
# Attribution-NonCommerical-ShareAlike2.5 License.
#
# For more information, please see
#   http://creativecommons.org/licenses/by-nc-sa/2.5/
#
# You are free:
#
# * to copy, distribute, display, and perform the work
# * to make derivative works
#
# Under the following conditions:
#   Attribution:   You must attribute the work in the manner specified by the
#                  author or licensor.
#   Noncommercial: You may not use this work for commercial purposes.
#   Share Alike:   If you alter, transform, or build upon this work, you may
#                  distribute the resulting work only under a license identical
#                  to this one.
#
# * For any reuse or distribution, you must make clear to others the license
#   terms of this work.
# * Any of these conditions can be waived if you get permission from the
#   copyright holder.
#
# Your fair use and other rights are in no way affected by the above.
################################################################################
use strict;
use Parse::RecDescent;

###############################################################################
###                      Version 0.1 beta (2007-03-08)                      ###
###############################################################################

%::globalvars=(
  # Root of mail path (i.e. save $mail-root/$dir)
  'mail-root' => 'IMAP',

  # Where errors should go (i.e. if error_message then; save $mail-root/$errors-to; finish; endif)
  'errors-to' => 'errors',

  # Current vacation level
  'vacation-level' => 0,

  # Vacation aliases
  'vacation-alias' => '',

  # Vacation message path
  'vacation-msg' => '$home/vacation/message',
  # Vacation log file
  'vacation-log' => '$home/vacation/log',
  # Vacation memory file
  'vacation-once' => '$home/vacation/once',
  # Vacation repeat rate
  'vacation-repeat' => '2d',

  # Path to use for automatic archiving ($1 = YYYY-MM)
  'archive-path' => 'IMAP/archive/$1/'
);

%::secmeta=();

%::op_translate=(
  '==' => 'is',
  '!=' => 'is not',
  '=^' => 'begins',
  '!^' => 'does not begin',
  '=$' => 'ends',
  '!$' => 'does not end',
  '=|' => 'contains',
  '!|' => 'does not contain',
  '=~' => 'matches',
  '!~' => 'does not match',
  # for the difficult people
  'is'               => 'is',
  'is not'           => 'is not',
  'begins'           => 'begins',
  'does not begin'   => 'does not begin',
  'ends'             => 'ends',
  'does not end'     => 'does not end',
  'contains'         => 'contains',
  'does not contain' => 'does not contain',
  'matches'          => 'matches',
  'does not match'   => 'does not match',
);

$::indentlvl=0;
$::inch='  ';
$::indent='';

$::RD_ERRORS = 1; # Make sure the parser dies when it encounters an error
$::RD_WARN   = 1; # Enable warnings. This will warn on unused rules &c.
$::RD_HINT   = 1; # Give out hints to help fix problems.

sub newHeader($) { %::secmeta = (); }

# Automatic pretty-printing indentation
sub println($) { my $line=$_[0]; $line=~s/^/$::indent/msg; print "$line\n"; }
sub indent()   { $::indent=$::inch x (++$::indentlvl); }
sub outdent()  { $::indent=$::inch x (--$::indentlvl); }

sub globalSection() {
  println 'if error_message then'; indent;
  println "save $::globalvars{'mail-root'}/$::globalvars{'errors-to'}";
  println 'finish';
  outdent; println "endif\n";

  println "add $::globalvars{'vacation-level'} to n0";
}

sub metaSection($\@\@\@) {
  return 1 if @{$_[1]};

  my $dir=$_[0];
  my @match_rules=(defined(@{$_[2]}[0])) ? @{@{$_[2]}[0]} : ();
  my @actions=(defined(@{$_[3]}[0])) ? @{@{$_[3]}[0]} : ();

  if ($dir eq 'UNDELIVERED') {
    @match_rules = (!@match_rules) ? ('not delivered') : ('#comp and', 'not delivered', '#(', '#comp or', @match_rules, '#)');

    section("###########\n## INBOX ##\n###########\n", [], [[@match_rules]], [[@actions]]);
  } elsif ($dir eq 'DESTROY') {
    @actions = (!@actions) ? ('seen') : (@actions, 'seen');

    section("#!!!!!!!!!!!!!!!!#\n#! DELETE EMAIL !#\n#!!!!!!!!!!!!!!!!#\n", [], [[@match_rules]], [[@actions]]);
  }
}

sub outputMatchRules(\@) {
  my @match_rules=@{$_[0]};
  my $rulecount=0;
  my $rulecomp='or';

  if (@match_rules) {
    print 'if ';
    foreach my $rule (@match_rules) {
      if ($rule =~ /^#/) {
        if ($rule eq '#(') {
          # start group
          println ((($rulecount==0)?'':"$rulecomp ").'(');
          indent;
          $rulecount=0;
        } elsif ($rule eq '#)') {
          # end group
          outdent;
          println ')';
        } elsif ($rule =~ /^#comp (.+)$/) {
          $rulecomp=$1;
        }
      } else {
        println ((($rulecount++==0)?'':"$rulecomp ").$rule);
      }
    }
    println "then";
    print "\n";
    indent;
  }
}

sub section($\@\@\@) {
  return 1 if @{$_[1]};

  my $dir=$_[0];
  #my @match_rules=@{@{$_[2]}[0]};
  #my @actions=();
  my @match_rules=(defined(@{$_[2]}[0])) ? @{@{$_[2]}[0]} : ();
  my @actions=(defined(@{$_[3]}[0])) ? @{@{$_[3]}[0]} : ();
  my $special=0;

  @actions=@{@{$_[3]}[0]} if (defined @{$_[3]}[0]);

  $special=1 if ($dir =~ /\n/);

  println <<_

############################################################
## Dir: $dir
############################################################
_
  unless ($special);
  println "\n$dir" if ($special);

  outputMatchRules(@match_rules);

  println "save $::globalvars{'mail-root'}/$dir\n" unless ($special);

  if (defined($::secmeta{'ARCHIVE'})) {
    println 'if $tod_log matches "^(....-..)" then'; indent;
    println "save $::globalvars{'archive-path'}$::secmeta{'ARCHIVE'}";
    outdent; println "endif\n";
  }

  if (defined($::secmeta{'VACATION'})) {
    $::secmeta{'VACATION'}--;
    my $vacalias = join(' alias ', (split /\s+/, $::globalvars{'vacation-alias'}));
    $vacalias = ' alias '.$vacalias if ($vacalias ne '');

    println "if personal$vacalias";
    println "and \$n0 is above $::secmeta{'VACATION'} then"; indent;
    println 'mail'; indent;
    println 'to $reply_address';
    println "subject \"Re: \$h_subject:\"";
    println "expand file $::globalvars{'vacation-msg'}";
    println "log  $::globalvars{'vacation-log'}";
    println "once $::globalvars{'vacation-once'}";
    println "once_repeat $::globalvars{'vacation-repeat'}";
    outdent; outdent; println "endif\n";
  }

  println $_ foreach (@actions);
  print "\n" if (@actions);

  println 'finish' unless ($::secmeta{'NOFINISH'});
  if (@match_rules) {
    outdent; println 'endif';
  }
}

my $grammar = q{

  ConfigFile : CommentLine(s?) GlobalSection Section(s) eofile
             | <error>

  GlobalSection : GlobalHeader NewLine GlobalLines  { &::globalSection(); }
          | <error>

  Section : WS MetaHeader WS NewLine CommentLine(s?) MetaDisabled(?) MetaActions(?) MatchRuleBlock(?) ActionBlock(?)
            { &::metaSection($item[2], $item[6], $item[8], $item[9]); }
          | WS SectionHeader WS NewLine CommentLine(s?) MetaDisabled(?) MetaActions(?) MatchRuleBlock(?) ActionBlock(?)
            { &::section($item[2], $item[6], $item[8], $item[9]); }
          | <error>

  GlobalLines : GlobalLine GlobalLines
              | GlobalLine
              | <error>

  GlobalLine  : WS Comment WS NewLine
              | WS KeyVal WS NewLine
              | <error>

  MatchRuleBlock : WS CompStyle WS NewLine MatchRuleBlock { $return = [ "#comp $item[2]" ]; push @{$return}, @{$item[5]}; }
                 | WS CompStyle WS NewLine                { $return = [ "#comp $item[2]" ]; }
                 | WS Group WS NewLine MatchRuleBlock     { $return = [ $item[2] ]; push @{$return}, @{$item[5]}; }
                 | WS Group WS NewLine                    { $return = [ $item[2] ]; }
                 | WS MatchRule WS NewLine MatchRuleBlock { $return = [ $item[2] ]; push @{$return}, @{$item[5]}; }
                 | WS MatchRule WS NewLine                { $return = [ $item[2] ]; }
                 | CommentLine MatchRuleBlock             { $return = $item[2]; }
                 | CommentLine                            { $return = []; }
                 | <error>

  CommentLine : WS Comment WS NewLine

  MatchRule : MatchHeader
            | MatchAnyDomain
            | MatchAnyAddress
            | <error>

  MetaActions : WS MetaAction WS NewLine MetaActions
              | WS MetaAction WS NewLine
              | CommentLine MetaActions
              | CommentLine
              | <error>

  MetaAction  : '@' /[A-Z]+/  RWS Value { $::secmeta{$item[2]}=$item[4]; 1; }
              | '@' /[A-Z]+/            { $::secmeta{$item[2]}=1;        1; }
              | <error>

  ActionBlock : WS Action WS NewLine ActionBlock { $return = [ $item[2] ]; push @{$return}, @{$item[5]}; }
              | WS Action WS NewLine             { $return = [ $item[2] ]; }
              | CommentLine ActionBlock          { $return = $item[2]; }
              | CommentLine                      { $return = []; }
              | WS Custom WS NewLine ActionBlock { $return = [ $item[2] ]; push @{$return}, @{$item[5]}; }
              | WS Custom WS NewLine             { $return = [ $item[2] ]; }
              | <error>

  Action : copyTo
         | saveTo
         | <error>

  Comment       : /##.*/               { $item[1]; }
                | /#.*/                { ''; }
                | <error>
  MetaHeader    : '[!' /[A-Z]+/ '!]'   { &::newHeader($item[2]); $item[2]; }
                | <error>
  SectionHeader : '[' /[^]]+/  ']'     { &::newHeader($item[2]); $item[2]; }
                | <error>
  CompStyle     : /(and|or)/i          { $item[1]; }
                | <error>

  Group      : /(end)?/i /group/i   { ($item[1] eq 'end')?'#)':'#('; }
             | <error>

  Custom : 'custom' WS NewLine /.+?(?=endcustom)/ms 'endcustom' { $return = $item[4]; $return=~/^(\s*)/; $return=~s/^$1//msg; }
         | <error>

  MatchHeader     : /header/i RWS Key RWS Operator RWS Value      { "\$h_$item[3]: $::op_translate{$item[5]} \"$item[7]\""; }
                  | <error>
  MatchAnyDomain  : Negator(?) /anydomain/i RWS Value
                      { 'foranyaddress $h_From:,$h_Reply-To:'."\n$::inch".'($thisaddress '.((@{$item[1]})?'does not match':'matches').' "@([^@]+\\\\\\\\.)?'.$item[4].'")'; }
                  | <error>
  MatchAnyAddress : /anyaddress/i RWS Operator RWS Value
                      { 'foranyaddress $h_From:,$h_To:,$h_Cc:,$h_Reply-To:,$h_Resent-To:,$h_X-Envelope-To:'."\n$::inch".'($thisaddress '."$::op_translate{$item[3]} \"$item[5]\")"; }
                  | <error>

  MetaDisabled : '@DISABLED' WS NewLine { $item[0]; }
               | <error>

  copyTo : /copyto/i RWS Value { "deliver \"$item[3]\""; }
              | <error>
  saveTo : /saveto/i RWS Value { "save $item[3]";        }
              | <error>

  KeyVal : Key WS '=' WS Value { $::globalvars{$item[1]} = $item[5]; 1; }
         | <error>

  Key   : /\S+/
        | <error>
  Value : /"?/ /[^\n"]+/ /"?/ { $item[2]; }
        | <error>

  GlobalHeader : '[!GLOBAL!]' { &::newHeader(''); }
               | <error>

  Negator  : /!/
           | <error>
  Operator : /[=!][=~\|\$\^]/
           | /is( not)?/i
           | /(begins|ends|contains|matches)/i
           | /does not (begin|end|contain|match)/i
           | <error>

  NewLine : /[\n\r]+/
          | <error>
  WS      : /[ \t]*/
          | <error>
  RWS     : /[ \t]+/
          | <error>

  eofile  : /^\Z/
};

# All whitespace is significant; don't skip it please.
$Parse::RecDescent::skip='';
my $parse = new Parse::RecDescent($grammar);
my $configfile = join '',(<>);

print "# Exim filter  <<== do not edit or remove this line!\n\n";
$parse->ConfigFile($configfile);
