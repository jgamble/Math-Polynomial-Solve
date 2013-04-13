# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl poly1.t'

use Test::More tests => 18;

use Math::Polynomial::Solve qw(poly_roots fltcmp ascending_order);
use Math::Complex;
use strict;
use warnings;

require "t/coef.pl";

#
# All cases are degree 5 or higher, so there should be no need to set
# the Hessenberg flag.
#
my @case = (
	[1, 0, 0, 0, 0, -1],
	[1, 5, 10, 10, 5, 1],
	[1, 0, 0, 0, 1, 1],		# Two of the roots are cube roots of 1
	[1, 1, 1, 1, 1, 1, 1, 1],
	[1, 0, 0, 0, 20, 16],
	[1, 0, -3, -4, 3, 6, 2],
	[-1, 0, 3, 4, -3, -6, -2],
	[4, -20, -7, 49, -70, 7, -53, 90],	# (4x**2 - 8x + 9)(x + 2)(x - 5)(x**3 - 1)
	[1950773,  7551423,  -1682934,  137445,  -4961,  67],
);

#
# The last case is an oddball one, and I'm upping the tolerance
# for it.
#
poly_tolerance(fltcmp => 4.5e-8);

foreach (@case)
{
	my @coef = @$_;
	my @x = poly_roots(@coef);

	ok(allzeroes(\@coef, @x),
		"   [ " . join(", ", @coef) . " ]");

	#diag(rootformat(@x), "\n\n");
}

ascending_order(1);

poly_tolerance(fltcmp => 2.0e-7);
foreach (@case)
{
	my @coef = @$_;
	my @x = poly_roots(@coef);

	ok(allzeroes(\@coef, @x),
		"   [ " . join(", ", reverse @coef) . " ]");

	#diag(rootformat(@x), "\n\n");
}

1;
