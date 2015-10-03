# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl cubic.t'

use Test::More tests => 52;	# Twice the number of scalar @case.

use Math::Polynomial::Solve qw(cubic_roots :utility ascending_order);
use Math::Complex;
use strict;
use warnings;

require "t/coef.pl";

my @case = (
	[1, 3, 3, 1],
	[1, 0, 0, -1],
	[1, 0, 0, 1],
	[1, -13, 59, -87],
	[1, -4, 4, -16],
	[1, -6, 11, -6],
	[1, 5, -62, -336],
	[8, 0, -6, -1],		# can't trisect 60 deg angle.
	[1, 0, 0, -2],		# can't duplicate the cube.
	[1, 1, -2, -1],		# can't construct a septagon.
	[8, -24, 0, 6.25],
	[729, -1, 1, 9],
	[1, -2.5, 7/8, -1/16],
);

foreach (@case)
{
	my @coef = @$_;
	my @x = cubic_roots(@coef);

	ok(allzeroes(\@coef, @x),
		"   [ " . join(", ", @coef) . " ]");

	#diag(rootformat(@x), "\n\n");

	#
	# Again, with the negative coefficients.
	#
	@coef = poly_constmult(\@coef, -1);
	@x = cubic_roots(@coef);

	ok(allzeroes(\@coef, @x),
		"   [ " . join(", ", @coef) . " ]");

	#diag(rootformat(@x), "\n\n");
}

ascending_order(1);

foreach (@case)
{
	my @coef = reverse @$_;
	my @x = cubic_roots(@coef);

	ok(allzeroes(\@coef, @x),
		"   [ " . join(", ", @coef) . " ]");

	#diag(rootformat(@x), "\n\n");

	#
	# Again, with the negative coefficients.
	#
	@coef = poly_constmult(\@coef, -1);
	@x = cubic_roots(@coef);

	ok(allzeroes(\@coef, @x),
		"   [ " . join(", ", @coef) . " ]");

	#diag(rootformat(@x), "\n\n");
}

1;
