#!/usr/bin/perl

use strict;

for(0..100,31337)
{
   my ($bitx, $bity)=fb($_);
   #my ($inv)=fbi($bit);
   print "$_: $bitx, $bity\n";
}

sub fb($)
{
   my @table=([0,1,2,3],[0,2,1,3],[3,2,1,0],[3,1,2,0]);
   my $n=shift;
   if($n==0) { return (0,0) }
   elsif($n==1) { return (1,1) }
   elsif($n==2) { return (3,1) }
   elsif($n==3) { return (2,2) }
   else
   {
      my ($b1,$trans1)=fb($n&3);
      my ($b2,$trans2)=fb($n>>2);
      return ((($b2<<3)&0xaaaaaaa8)|(($b2<<1)&0x55555554)|$table[$trans2][$b1],$trans1^$trans2);
   }
}

sub fbi($)
{
   my @table=([0,1,2,3],[0,2,1,3],[3,2,1,0],[3,1,2,0]);
   my $n=shift;
   if($n==0) { return (0,0) }
   elsif($n==1) { return (1,1) }
   elsif($n==2) { return (3,2) }
   elsif($n==3) { return (2,1) }
   else
   {
      my ($b2,$trans2)=fbi( (($n&0xaaaaaaa8)>>3) | (($n&0x55555554)>>1) );
      my ($b1,$trans1)=fbi($table[$trans2][$n&3]);
      return (($b2<<2)|$b1,$trans1^$trans2);
   }
} 
