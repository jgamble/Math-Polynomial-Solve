# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl cubic.t'

use Test::Simple tests => 20;

use Math::Polynomial::Solve qw(cubic_roots fltcmp);
use Math::Complex;
use strict;
use warnings;

require "t/coef.pl";

my @case = (
	[1, 3, 3, 1],
	[1, 0, 0, -1],
	[1, 0, 0, 1],
	[1, -13, 59, -87],
	[1, -4, 4, -16],
	[1, -6, 11, -6],
	[1, 5, -62, -336],
	[8, -24, 0, 6.25],
	[729, -1, 1, 9],
	[1, -2.5, 7/8, -1/16],
# Same values as before, but negative
	[-1, -3, -3, -1],
	[-1, 0, 0, 1],
	[-1, 0, 0, -1],
	[-1, 13, -59, 87],
	[-1, 4, -4, 16],
	[-1, 6, -11, 6],
	[-1, -5, 62, 336],
	[-8, 24, 0, -6.25],
	[-729, 1, -1, -9],
	[-1, 2.5, -7/8, 1/16],
);

foreach (@case)
{
	my @coef = @$_;
	my @x = cubic_roots(@coef);
	my $b = -sumof(@x) * $coef[0];
	my $d = -prodof(@x) * $coef[0];

	ok((fltcmp($b, $coef[1]) == 0 and fltcmp($d, $coef[3]) == 0),
		"   [ " . join(", ", @coef) . " ]");

	#print "\nmy \$b = $b; \$coef[1] = ", $coef[1], "\n";
	#print "\nmy \$d = $d; \$coef[3] = ", $coef[3], "\n";
	#print rootformat(@x), "\n\n";
}

1;
