#
# Tests of the poly_roots() function, all of polynomials of degree
# four or less. Cases are all 0.9216 times the values of the cases
# in poly0.t.
#
use Test::Simple tests => 22;

use Math::Polynomial::Solve qw(poly_roots set_hessenberg);
use Math::Complex;

require "t/coef.pl";

my @case = (
	[1.8432, 0.9216],
	[0.9216, 1.8432, 0.9216],
	[0.9216, 2.7648, 2.7648, 0.9216],
	[0.9216, 3.6864, 5.5296, 3.6864, 0.9216],
	[2.7648, 5.5296, -0.9216, -3.6864, 1.8432],
	[-2.7648, -5.5296, 0.9216, 3.6864, -1.8432],
	[0.9216, 0, -27.648, 0, 266.3424],
	[-0.9216, 0, 27.648, 0, -266.3424],
	[0.9216, 0, -27.648, 0, 266.3424, 0, 0, 0],
	[266.3424, 0, -27.648, 0, 0.9216],
	[0.9216, 11.0592, 42.3936, 55.296, 23.04],
);

#
# All of these tests will be dispatched to the
# quadratic_roots, cubic_roots, and quartic_roots functions.
#
set_hessenberg(0);

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
set_hessenberg(1);

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
