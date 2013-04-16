# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl sturm2.t'

use Test::Simple tests => 34;

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

	my @chain = poly_sturm_chain(@polynomial);

	my $c = sturm_real_root_range_count(\@chain, -10000, 10000);

	ok($c == $n, "Polynomial: [" . join(", ", @polynomial) . "], count = $c");

	#diag("\nPolynomial: [", join(", ", @polynomial), "]");
	#diag("Has " . sturm_real_root_range_count(\@chain, -10000, 10000) .
	#     " real unique roots b/n -10K and 10K.\n");
	#diag(polychain2str(@chain));
}

ascending_order(1);

foreach my $cref (@case)
{
	my($p, $n) = @$cref;
	my @polynomial = reverse @$p;

	my @chain = poly_sturm_chain(@polynomial);

	my $c = sturm_real_root_range_count(\@chain, -10000, 10000);

	ok($c == $n, "Polynomial: [" . join(", ", @polynomial) . "], count = $c");

	#diag("\nPolynomial: [", join(", ", @polynomial), "]");
	#diag("Has " . sturm_real_root_range_count(\@chain, -10000, 10000) .
	#     " real unique roots b/n -10K and 10K.\n");
	#diag(polychain2str(@chain));
}

exit(0);
