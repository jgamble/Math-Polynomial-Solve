#
# Tests of the poly_roots() function, all of polynomials of degree
# four or less.
#
use Test::Simple tests => 24;

use Math::Polynomial::Solve qw(:numeric fltcmp);
use Math::Complex;
use strict;
use warnings;

require "t/coef.pl";

my @case = (
	[2, 1],
	[1, 2, 1],
	[1, 3, 3, 1],
	[729, -1, 1, 9],
	[1, 4, 6, 4, 1],
	[3, 6, -1, -4, 2],
	[-3, -6, 1, 4, -2],
	[1, 0, -30, 0, 289],
	[-1, 0, 30, 0, -289],
	[1, 0, -30, 0, 289,  0,  0,  0],
	[289, 0, -30, 0, 1],
	[1, 12, 46, 60, 25],
);

#
# All of these tests will be dispatched to the
# quadratic_roots, cubic_roots, and quartic_roots functions.
#
poly_option(hessenberg => 0);

foreach (@case)
{
	my @coef = @$_;
	my $n = $#coef;
	my @x = poly_roots(@coef);
	my $cn_1 = -sumof(@x) * $coef[0];
	my $c0 = prodof(@x) * $coef[0];
	$c0 = -$c0 if ($n % 2 == 1);

	ok((fltcmp($cn_1, $coef[1]) == 0 and fltcmp($c0, $coef[$n]) == 0),
		"   [ " . join(", ", @coef) . " ]");

	#print "\nmy \$cn_1 = $cn_1; \$coef[1] = ", $coef[1], "\n";
	#print "\nmy \$c0 = $c0; \$coef[$n] = ", $coef[$n], "\n";
	#print rootformat(@x), "\n\n";
}

#
# Repeate, except that the next line sets the
# 'always use the iterative matrix' flag.
#
poly_option(hessenberg => 1);

foreach (@case)
{
	my @coef = @$_;
	my $n = $#coef;
	my @x = poly_roots(@coef);
	my $cn_1 = -sumof(@x) * $coef[0];
	my $c0 = prodof(@x) * $coef[0];
	$c0 = -$c0 if ($n % 2 == 1);

	ok((fltcmp($cn_1, $coef[1]) == 0 and fltcmp($c0, $coef[$n]) == 0),
		"   [ " . join(", ", @coef) . " ]");

	#print "\nmy \$b = $b; \$coef[1] = ", $coef[1], "\n";
	#print "\nmy \$e = $e; \$coef[$n] = ", $coef[$n], "\n";
	#print rootformat(@x), "\n\n";
}

1;
