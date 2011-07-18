# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl sturm2.t'

use Test::Simple tests => 17;

use Math::Polynomial::Solve qw(:sturm);
use strict;
use warnings;
require "t/coef.pl";

my @case = (
	[1], 0,
	[5, 3], 1,
	[1, 0, 0, -1], 1,
	[1, 0, 0, 1], 1,
	[1, 0, 0, 0, 1], 0,
	[1, 0, 0, 0, -1], 2,
	[1, 0, 0, 0, 0, 1], 1,
	[1, 0, 0, 0, 0, -1], 1,
	[1, 3, 3, 1], 1,
	[1, 3, 0, -1], 3,
	[1, 0, 3, -1], 1,
	[1, -13, 59, -87], 1,
	[1, -4, 4, -16], 1,
	[1, -6, 11, -6], 3,
	[1, 5, -62, -336], 3,
	[8, -24, 0, 6.25], 3,
	[1, -2.5, 7/8, -1/16], 3,
);

while (@case)
{
	my $p = shift @case;
	my $n = shift @case;

	my @polynomial = @$p;
	my @chain = poly_sturm_chain(@polynomial);

	my $c = sturm_real_root_range_count(\@chain, -10000, 10000);

	ok($c == $n, "Polynomial: [" . join(", ", @polynomial) . "], count = $c");

	#print "\nPolynomial: [", join(", ", @polynomial), "]\n";
	#print "Has ", poly_real_roots(@polynomial), "\n";
	#rootprint(@x);
}

exit(0);
