# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl division.t'

use Test::More tests => 12;

use Math::Polynomial::Solve qw(:utility ascending_order);
use strict;
use warnings;

require "t/coef.pl";

#
# Groups of four: numerator, divisor, quotient, remainder.
#
my @case0 = (
	[
		[32, 24, 1],
		[64, 24],
		[0.5, 0.1875],
		[-3.5]
	],
	[
		[1, 2, 3, 4, 289],
		[4, 6, 6, 4],
		[0.25, 0.125],
		[0.75, 2.25, 288.5]
	],
	[
		[1, 0, 0, 0, -3, -1],
		[5, 0, 0, 0, -3],
		[0.2, 0],
		[-2.4, -1]
	],
	[
		[4, -20, -7, 49, -70, 7, -53, 90],
		[4, -8, 9],
		[1, -3, -10, -1, 3, 10],
		[0]
	],
	[
		[1, 0, 0, 0, 34, 0, 0, 0, 1],
		[1, 4, 8, 4, 1],
		[1, -4, 8, -4, 1],
		[0]
	],
	[
		[3, 9, 12, 4],
		[1, 3, 3, 1],
		[3],
		[3, 1]
	]
);

foreach my $cref (@case0)
{
	my($p_ref, $d_ref, $q_ref, $r_ref) = @$cref;

	my($q, $r) = poly_divide($p_ref, $d_ref);

	my @polynomial = @$p_ref;
	my @divisor = @$d_ref;
	my @quotient = @$q;
	my @remainder = @$r;

	ok((polycmp($q_ref, $q) == 0 and polycmp($r_ref, $r) == 0),
		" [ " . join(", ", @polynomial) . " ] /" .
		" [ " . join(", ", @divisor) . " ] returns\n" .
		" [ " . join(", ", @quotient) . " ] and" .
		" [ " . join(", ", @remainder) . " ].\n"
	);
}


ascending_order(1);
foreach my $cref (@case0)
{
	my($p_ref, $d_ref, $q_ref, $r_ref) = @$cref;

	#
	# Put them in ascending order...
	#
	my @p = reverse @$p_ref;
	my @d = reverse @$d_ref;
	my @q0 = reverse @$q_ref;
	my @r0 = reverse @$r_ref;

	my($q, $r) = poly_divide(\@p, \@d);


	ok((polycmp(\@q0, $q) == 0 and
		polycmp(\@r0, $r) == 0),
		" [ " . join(", ", @p) . " ] /" .
		" [ " . join(", ", @d) . " ] returns\n" .
		" [ " . join(", ", @$q) . " ] and" .
		" [ " . join(", ", @$r) . " ].\n" .
		"but should have returned: " .
		" [ " . join(", ", @q0) . " ] and" .
		" [ " . join(", ", @r0) . " ].\n"
	);
}

1;
