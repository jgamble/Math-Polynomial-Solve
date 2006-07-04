# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl quartic.t'

use Test::Simple tests => 14;

use Math::Polynomial::Solve qw(quartic_roots);
use Math::Complex;

require "t/coef.pl";

my @case = (
	[1, 4, 6, 4, 1],
	[1, 0, 0, 0, -1],
	[1, 0, 0, 0, 1],
	[1, -10, 35, -50, 24],
	[1, 6, -5, -10, -3],
	[1, 6, 7, -7, -12],
	[1, 6, -1, 4,  2],
	[-1, -4, -6, -4, -1],
	[-1, 0, 0, 0, 1],
	[-1, 0, 0, 0, -1],
	[-1, 10, -35, 50, -24],
	[-1, -6, 5, 10, 3],
	[-1, -6, -7, 7, 12],
	[-1, -6, 1, -4, -2],
);

foreach (@case)
{
	my @coef = @$_;
	my @x = quartic_roots(@coef);
	my $b = -sumof(@x) * $coef[0];
	my $e = prodof(@x) * $coef[0];

	ok((fltcmp($b, $coef[1]) == 0 and fltcmp($e, $coef[4]) == 0),
		"   [ " . join(", ", @coef) . " ]");

	#print "\nmy \$b = $b; \$coef[1] = ", $coef[1], "\n";
	#print "\nmy \$e = $e; \$coef[4] = ", $coef[4], "\n";
	#print rootformat(@x), "\n\n";
}

1;
