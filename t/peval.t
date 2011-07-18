# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl quartic.t'

use Test::Simple tests => 4;

use Math::Polynomial::Solve qw(quartic_roots poly_evaluate fltcmp);
use Math::Complex;
use strict;
use warnings;

require "t/coef.pl";

my @case = (
	[1, 4, 6, 4, 1],
	[1, 0, 0, 0, -1],
	[1, 0, 0, 0, 1],
	[1, -10, 35, -50, 24],
);

foreach (@case)
{
	my @coef = @$_;
	my @x = quartic_roots(@coef);

	my @y = poly_evaluate(\@coef, \@x);

	#rootprint(@x);

	ok( (fltcmp($y[0], 0.0) == 0 and
		fltcmp($y[1], 0.0) == 0 and
		fltcmp($y[2], 0.0) == 0 and
		fltcmp($y[3], 0.0) == 0),
		"   [ " . join(", ", @coef) . " ]");
}

1;
