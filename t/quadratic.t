# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl quadratic.t'

use Test::More tests => 32;	# Twice the number of scalar @case.

use Math::Polynomial::Solve qw(quadratic_roots :util ascending_order);
use Math::Complex;
use strict;
use warnings;

require "t/coef.pl";

my @case = (
	[1, 2, 1],
	[1, 0, -1],
	[1, 0, 1],
	[1, -3, 2],
	[1, 11, -6],
	[1, -7, 12],
	[1, -13, 12],
	[5, -6, 5],
);

foreach (@case)
{
	my @coef = @$_;
	my @x = quadratic_roots(@coef);

	ok(allzeroes(\@coef, @x),
		"   [ " . join(", ", @coef) . " ]");

	#diag(rootformat(@x), "\n\n");

	#
	# Again, with the negative coefficients.
	#
	@coef = poly_constmult(\@coef, -1);
	@x = quadratic_roots(@coef);

	ok(allzeroes(\@coef, @x),
		"   [ " . join(", ", @coef) . " ]");

	#diag(rootformat(@x), "\n\n");
}

ascending_order(1);

foreach (@case)
{
	my @coef = reverse @$_;
	my @x = quadratic_roots(@coef);

	ok(allzeroes(\@coef, @x),
		"   [ " . join(", ", @coef) . " ]");

	#diag(rootformat(@x), "\n\n");

	#
	# Again, with the negative coefficients.
	#
	@coef = poly_constmult(\@coef, -1);
	@x = quadratic_roots(@coef);

	ok(allzeroes(\@coef, @x),
		"   [ " . join(", ", @coef) . " ]");

	#diag(rootformat(@x), "\n\n");
}

1;
