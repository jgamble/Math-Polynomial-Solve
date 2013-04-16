# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl sturm2.t'

use Test::More tests => 10;

use Math::Polynomial::Solve qw(:sturm :utility ascending_order);
use strict;
use warnings;
require "t/coef.pl";

my @case = (
	[2, 3, 1],
	[1, 2, 3, 4],
	[6, 15, 10, 0, -1],
	[2, 6, 5, 0, -1],
	[20, 200, -4, -1],
);


foreach my $cref (@case)
{
	my @polynomial = @$cref;
	my @chain = poly_sturm_chain(@polynomial);

	my @roots = sturm_bisection_roots(\@chain, -10000, 0);
	my @zeroes = poly_evaluate(\@polynomial, \@roots);

	ok(allzeroes($cref, @roots),
		"Polynomial: [" . join(", ", @polynomial) . "]," .
	   "'zeroes' are (" . join(", ", @zeroes) . ")");

	#diag("\nPolynomial: [", join(", ", @polynomial), "]");
	#diag(polychain2str(@chain));
}

ascending_order(1);
foreach my $cref (@case)
{
	my @polynomial = reverse @$cref;
	my @chain = poly_sturm_chain(@polynomial);

	my @roots = sturm_bisection_roots(\@chain, -10000, 0);
	my @zeroes = poly_evaluate(\@polynomial, \@roots);

	ok(allzeroes($cref, @roots),
		"Polynomial: [" . join(", ", @polynomial) . "]," .
	   "'zeroes' are (" . join(", ", @zeroes) . ")");

	#diag("\nPolynomial: [", join(", ", @polynomial), "]");
	#diag(polychain2str(@chain));
}

exit(0);
