# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl quadratic.t'

use Test::Simple tests => 16;	# Twice the number of scalar @case.

use Math::Polynomial::Solve qw(quadratic_roots fltcmp poly_constmult);
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
	my $b = -sumof(@x) * $coef[0];
	my $c = prodof(@x) * $coef[0];

	ok((fltcmp($b, $coef[1]) == 0 and fltcmp($c, $coef[2]) == 0),
		"   [ " . join(", ", @coef) . " ]");

	#print "\nmy \$b = $b; \$coef[1] = ", $coef[1], "\n";
	#print "\nmy \$c = $c; \$coef[2] = ", $coef[2], "\n";
	#print rootformat(@x), "\n\n";

	#
	# Again, with the negative coefficients.
	#
	@coef = poly_constmult(\@coef, -1);
	@x = quadratic_roots(@coef);
	$b = -sumof(@x) * $coef[0];
	$c = prodof(@x) * $coef[0];

	ok((fltcmp($b, $coef[1]) == 0 and fltcmp($c, $coef[2]) == 0),
		"   [ " . join(", ", @coef) . " ]");
}

1;
