# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl sturm0.t'

use Test::More tests => 32;

use Math::Polynomial::Solve qw(:sturm fltcmp ascending_order);
use strict;
use warnings;
require "t/coef.pl";

my @case = (
	[ [1], 1, ],
	[ [5, 3], 5, ],
	[ [32, 24, 1], 3.5, ],
	[ [1, 3, 0, -1], 2.25, ],
	[ [1, 0, 0, -1], 1, ],
	[ [1, 0, 0, 1], -1, ],
	[ [1, 0, 0, 0, 1], -1, ],
	[ [1, 0, 0, 0, -1], 1, ],
	[ [1, 0, 0, 0, 0, 1], -1, ],
	[ [1, 0, 0, 0, 0, -1], 1, ],
	[ [1, 3, 3, 1], 0, ],
	[ [1, 3, 0, -1], 2.25, ],
	[ [1, 0, 3, -1], -3.75, ],
	[ [1, -4, 4, -16], -900, ],
	[ [1, -6, 11, -6], 1, ],
	[ [8, -24, 0, 6], 14.625, ],
);

foreach my $cref (@case)
{
	my($p, $c) = @$cref;

	my @polynomial = @$p;
	my @chain = poly_sturm_chain( @polynomial );

	if (scalar @chain)
	{
		my($fn) = @{$chain[$#chain]};	# get the last (constant) polynomial.
		ok(fltcmp($c, $fn) == 0, "Polynomial: [" . join(", ", @polynomial) . "], fn = $fn");

		diag("\nPolynomial: [", join(", ", @polynomial), "]");
		diag(polychain2str(@chain));
	}
	else
	{
		ok(0,  "Polynomial: [" . join(", ", @polynomial) . "], chain fails");
	}
}

ascending_order(1);

foreach my $cref (@case)
{
	my($p, $c) = @$cref;

	my @polynomial = @$p;
	my @chain = poly_sturm_chain( @polynomial );

	if (scalar @chain)
	{
		my($fn) = @{$chain[$#chain]};	# get the last (constant) polynomial.
		ok(fltcmp($c, $fn) == 0, "Polynomial: [" . join(", ", @polynomial) . "], fn = $fn");

		diag("\nPolynomial: [", join(", ", @polynomial), "]");
		diag(polychain2str(@chain));
	}
	else
	{
		ok(0,  "Polynomial: [" . join(", ", @polynomial) . "], chain fails");
	}
}

exit(0);

