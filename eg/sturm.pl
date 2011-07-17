#!/bin/perl
#
use Carp;
use Math::Polynomial::Solve qw(:sturm);
use strict;
use warnings;
#use IO::Prompt;

my $line;

while ($line = prompt("Polynomial: ", -num))
{
	my @coef = split(/,? /, $line);

	my @chain = poly_sturm_chain( @coef );

	my($fn) = @{$chain[$#chain]};	# get the last (constant) polynomial.

	print "\nPolynomial: [", join(", ", @coef), "]\n";
	foreach my $j (0..$#chain)
	{
		my @c = @{$chain[$j]};
		print sprintf("    f%2d: [", $j) . join(", ", @c), "]\n";
	}
	print "Number of unique, real, roots: ", poly_real_root_count(@coef), "\n\n";
}

exit(0);

sub prompt
{
	my $pr = shift;
	print $pr;
	my $inp = <>;
	chomp $inp;
	return $inp;
}

