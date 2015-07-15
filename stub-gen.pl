#!/usr/bin/env perl
use strict;
use warnings;
use PPI;

my ($path, $exclude) = @ARGV;
unless($path) {
	print "Usage: $0 path\n";
	exit;
}

sub matchsub {
	return sub { $_[1]->isa('PPI::Statement::Sub') and $_[1]->name };
}

my $d1 = PPI::Document->new($path);
my $stubs = $d1->find( matchsub() );

my $d2 = PPI::Document->new($exclude);
my $excl = $d2->find( matchsub() );


my $h = {};
foreach (@$excl) {
	$h->{$_->name} = 1;
}

foreach (sort { $a->name cmp $b->name } @$stubs) {
	my $name = $_->name;
	next if $h->{$name};
print <<EOT;
sub $name {
	GDC::Log::Tracer::LOG(\@_);
	shift->SUPER::$name(\@_);
}

EOT
}

print "1;\n";

