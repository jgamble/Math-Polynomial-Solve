# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl sturm3.t'

use Test::More tests => 2;
#use Test::More tests => 10;

use Math::Polynomial::Solve qw(:sturm :utility poly_roots ascending_order);
use strict;
use warnings;
require "t/coef.pl";

my @case = (
	[20, 200, -4, -1],
);
	#[2, 3, 1],
	#[1, 2, 3, 4],
	#[6, 15, 10, 0, -1],
	#[2, 6, 5, 0, -1],


foreach my $cref (@case)
{
	my @polynomial = @$cref;
	my @plroots = poly_roots(@polynomial);
	my @chain = poly_sturm_chain(@polynomial);

	my @roots = sturm_bisection_roots(\@chain, -10000, 100);
	my @zeroes = poly_evaluate(\@polynomial, \@roots);

	ok(allzeroes(\@polynomial, @roots),
		"Polynomial: [" . join(", ", @polynomial) . "],\n" .
	   " 'zeroes' are (" . join(", ", @zeroes) . ")\n" .
	   " sturm_bisection() returns (" . join(", ", @roots) . ")\n" .
	   "      poly_roots() returns (" . join(", ", @plroots) . ")"
	);

	#diag("\nPolynomial: [", join(", ", @polynomial), "]");
	#diag(polychain2str(@chain));
}

ascending_order(1);
foreach my $cref (@case)
{
	my @polynomial = reverse @$cref;
	my @plroots = poly_roots(@polynomial);
	my @chain = poly_sturm_chain(@polynomial);

	my @roots = sturm_bisection_roots(\@chain, -10000, 100);
	my @zeroes = poly_evaluate(\@polynomial, \@roots);

	ok(allzeroes(\@polynomial, @roots),
		"Polynomial (ascending flag): [" . join(", ", @polynomial) . "],\n" .
	   " 'zeroes' are (" . join(", ", @zeroes) . ")\n" .
	   " sturm_bisection() returns (" . join(", ", @roots) . ")\n" .
	   "      poly_roots() returns (" . join(", ", @plroots) . ")"
	);

	#diag("\nPolynomial: [", join(", ", @polynomial), "]");
	#diag(polychain2str(@chain));
}

exit(0);
