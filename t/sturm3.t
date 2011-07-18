# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl sturm2.t'

use Test::Simple tests => 5;

use Math::Polynomial::Solve qw(:sturm :utility);
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


while (@case)
{
	my $p = shift @case;

	my @polynomial = @$p;
	my @chain = poly_sturm_chain(@polynomial);

	my @roots = sturm_bisection_roots(\@chain, -10000, 0);
	my @zeros = poly_evaluate(\@polynomial, \@roots);

	my $c = 0;
	$c += abs(fltcmp($_, 0.0)) foreach(@zeros);
	ok($c == 0,
		"Polynomial: [" . join(", ", @polynomial) . "], nonzero count = $c");
}

exit(0);
