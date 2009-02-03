# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl poly1.t'

use Test::Simple tests => 9;

use Math::Polynomial::Solve qw(poly_roots);
use Math::Complex;

require "t/coef.pl";

#
# All cases are degree 5 or higher, so there should be no need to set
# the Hessenberg flag.
#
my @case = (
	[1, 0, 0, 0, 0, -1],
	[1, 5, 10, 10, 5, 1],
	[1, 0, 0, 0, 1, 1],		# Two of the roots are cube roots of 1
	[1, 1, 1, 1, 1, 1, 1, 1],
	[1, 0, 0, 0, 20, 16],
	[1, 0, -3, -4, 3, 6, 2],
	[-1, 0, 3, 4, -3, -6, -2],
	[4, -20, -7, 49, -70, 7, -53, 90],	# (4x**2 - 8x + 9)(x + 2)(x - 5)(x**3 - 1)
	[1950773,  7551423,  -1682934,  137445,  -4961,  67],
);

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

1;
