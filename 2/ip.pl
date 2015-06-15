#!/usr/bin/perl
use strict;

sub foo{
	my %ethernet_ip;
	`/bin/bash ip.sh`;  
	open(FILE,"<","./.out.txt")||die"cannot open the file: $!\n";
	my @linelist=<FILE>;
	foreach my $eachline(@linelist){
		my($key, $val)= split(/:/,$eachline);
		$ethernet_ip{$key}=$val;
	}
	close FILE;

	return %ethernet_ip;
}

my %hash=foo();

while(my($key1,$value1) = each %hash)
{
	print "$key1 => $value1";
}

