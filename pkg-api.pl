#!/usr/bin/env perl
use strict;
use warnings;
use PPI;

my ($base_path, $module) = @ARGV;
unless($module) {
	print "Usage: $0 base_path module_path\n";
	print " - we suppose all base modules are in base_path\n";
	exit;
}

sub matchsub {
	return sub { $_[1]->isa('PPI::Statement::Sub') and $_[1]->name };
}

sub matchbase {
	return sub { $_[1]->isa('PPI::Statement::Include') and $_[1]->pragma eq 'base' };
}

sub get_meth {
	my ($base_path, $module) = @_;
	my $doc = PPI::Document->new(join("/", $base_path, $module));
	my $meth = $doc->find( matchsub() );
	my $base = $doc->find( matchbase() );

	my @parent;
	if ($base && $base->[0]) {
		my ($pkg_name) = $base->[0]->arguments;
		if ($pkg_name =~ /\((.*?)\)/) {
			$pkg_name = $1;
		}
		$pkg_name =~  s/\:\:/\//g;
		$pkg_name =~  s/\'//g;
		$pkg_name .= ".pm";
		@parent = get_meth($base_path, $pkg_name);
	}

	my @names = map { $_->name } @$meth;
	return (@names, @parent);
}

sub hash (@) { my %re = map { $_ => 1 } @_; \%re; }

sub uniq (@) { sort keys %{hash(@_)} }

print join "\n", uniq( get_meth($base_path, $module) );
print "\n";
