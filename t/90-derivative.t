# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl derivative.t'

use Test::Simple tests => 12;

use Math::Polynomial::Solve qw(:utility);
use strict;
use warnings;

require "t/coef.pl";

#
# Pairs of polynomnials and their derivatives.
#
my @case = (
	[32, 24, 1], [64, 24],
	[1, 2, 3, 4, 289], [4, 6, 6, 4],
	[1, 0, 0, 0, -3, -1], [5, 0, 0, 0, -3],
	[4, -20, -7, 49, -70, 7, -53, 90], [28, -120, -35, 196, -210, 14, -53],
	[1, 0, 0, 0, 34, 0, 0, 0, 1], [8, 0, 0, 0, 136, 0, 0, 0],
	[3, 9, 12, 4], [9, 18, 12],
);

#
# Peel off two items per loop.
#
while (@case)
{
	my $p_ref = shift @case;
	my $d_ref = shift @case;
	my @polynomial = @$p_ref;
	my $constant = $polynomial[$#polynomial];

	my(@derivative) = poly_derivative(@polynomial);

	ok((polycmp($d_ref, \@derivative) == 0),
		" f() = [ " . join(", ", @polynomial) . " ]\n" .
		" f'() = [ " . join(", ", @derivative) . " ].\n"
	);

	my(@antiderivative) = poly_antiderivative(@derivative);
	$antiderivative[$#antiderivative] = $constant;

	ok((polycmp($p_ref, \@antiderivative) == 0),
		" f() = [ " . join(", ", @derivative) . " ]\n" .
		" integral f() = [ " . join(", ", @antiderivative) . " ].\n"
	);
}

1;

