# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl sturm01.t'

use Test::More tests => 34;

use Math::Polynomial::Solve qw(:sturm ascending_order);
use strict;
use warnings;
require "t/coef.pl";

my @case = (
	[[1], 0],
	[[5, 3], 1],
	[[1, 0, 0, -1], 1],
	[[1, 0, 0, 1], 1],
	[[1, 0, 0, 0, 1], 0],
	[[1, 0, 0, 0, -1], 2],
	[[1, 0, 0, 0, 0, 1], 1],
	[[1, 0, 0, 0, 0, -1], 1],
	[[1, 3, 3, 1], 1],
	[[1, 3, 0, -1], 3],
	[[1, 0, 3, -1], 1],
	[[1, -13, 59, -87], 1],
	[[1, -4, 4, -16], 1],
	[[1, -6, 11, -6], 3],
	[[1, 5, -62, -336], 3],
	[[8, -24, 0, 6.25], 3],
	[[1, -2.5, 7/8, -1/16], 3],
);

foreach my $cref (@case)
{
	my($p, $n) = @$cref;
	my @polynomial = @$p;

	ok(poly_real_root_count(@polynomial) == $n, "Polynomial: [" . join(", ", @polynomial) . "]");

	#diag("\nPolynomial: [", join(", ", @polynomial), "]");
	#diag("Has " . poly_real_roots(@polynomial) . " real unique roots.\n");
}

ascending_order(1);

foreach my $cref (@case)
{
	my($p, $n) = @$cref;
	my @polynomial = reverse @$p;

	ok(poly_real_root_count(@polynomial) == $n, "Polynomial: [" . join(", ", @polynomial) . "]");

	#diag("\nPolynomial: [", join(", ", @polynomial), "]");
	#diag("Has " . poly_real_roots(@polynomial) . " real unique roots.\n");
}

exit(0);
