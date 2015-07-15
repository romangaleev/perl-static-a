#!/usr/bin/env perl
use strict;
my ($file1, $file2) = @ARGV;
unless($file2) {
	print "Usage: $0 list1 list2\n";
	exit;
}

sub read_file {
	my ($file) = @_;
	open my $fh, "<", $file;
	my %re;
	while(<$fh>) {
		chomp;
		my $str = $_;
		my ($k, $rest) = ($str =~ /^(.*?)\s+(.*)$/);
		if ($k) {
			$re{$k} = $rest;
		} else {
			$re{$str} = "";
		}
	}
	return \%re;
}

my $h1 = read_file($file1);
my $h2 = read_file($file2);

foreach (sort keys %$h1) {
	print $_, " ", $h1->{$_}, "\n" unless defined $h2->{$_};
}
