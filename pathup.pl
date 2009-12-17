#!/usr/bin/perl
$arg=shift;
$_=<>;
if ($arg eq "pkg-up") {
  s#\.#/#g;
  s#[^/]+#..#g;
} elsif ($arg eq "pkg-under") {
  s#\.#_#g;
}
print;
