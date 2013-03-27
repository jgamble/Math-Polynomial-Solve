# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl zyxw.t'

use Test::Simple tests => 40;

use Math::Polynomial::Solve qw(ascending_order :classical :numeric :utility);
use Math::Complex;
use strict;
use warnings;

require "t/coef.pl";

#
#
#
my @quadratic_case = (
	[1, 9, 14],
	[1, 1, 1],
	[1, 1, 1],
	[1, 20, 16],
	[1, -4, 2],
);

my @cubic_case = (
	[1, 5, 9, 14],
	[1, 0, 1, 1],
	[1, 8, 1, 1],
	[1, 0, 20, 16],
	[1, -4, 6, 2],
);

my @quartic_case = (
	[1, 4, 5, 9, 14],
	[1, 0, 0, 1, 1],
	[1, 8, 8, 1, 1],
	[1, 0, 0, 20, 16],
	[1, -4, 3, 6, 2],
);

my @polyrootf_case = (
	[1, 0, 3],
	[1, 0, 0, 3],
	[1, 0, 0, 0, 3],
	[1, 0, 0, 0, 0, 3],
	[1, 0, 0, 0, 0, 0, 3],
);

ascending_order(1);


foreach (@quadratic_case)
{
	my @coef = reverse @$_;
	my @x = quadratic_roots(@coef);

	ok(allzeroes(\@coef, @x),
		"quadratic_roots: [ " . join(", ", @coef) . " ]");

	#print "\nmy \$cn_1 = $cn_1; \$coef[1] = ", $coef[1], "\n";
	#print "\nmy \$c0 = $c0; \$coef[$n] = ", $coef[$n], "\n";
	#print rootformat(@x), "\n\n";
}

foreach (@cubic_case)
{
	my @coef = reverse @$_;
	my $n = $#coef;
	my @x = cubic_roots(@coef);
	my $cn_1 = -sumof(@x) * $coef[0];
	my $c0 = prodof(@x) * $coef[0];
	$c0 = -$c0 if ($n % 2 == 1);

	ok(allzeroes(\@coef, @x),
		"cubic_roots: [ " . join(", ", @coef) . " ]");

	#print "\nmy \$cn_1 = $cn_1; \$coef[1] = ", $coef[1], "\n";
	#print "\nmy \$c0 = $c0; \$coef[$n] = ", $coef[$n], "\n";
	#print rootformat(@x), "\n\n";
}

foreach (@quartic_case)
{
	my @coef = reverse @$_;
	my $n = $#coef;
	my @x = quartic_roots(@coef);
	my $cn_1 = -sumof(@x) * $coef[0];
	my $c0 = prodof(@x) * $coef[0];
	$c0 = -$c0 if ($n % 2 == 1);

	ok(allzeroes(\@coef, @x),
		"quartic_roots: [ " . join(", ", @coef) . " ]");

	#print "\nmy \$cn_1 = $cn_1; \$coef[1] = ", $coef[1], "\n";
	#print "\nmy \$c0 = $c0; \$coef[$n] = ", $coef[$n], "\n";
	#print rootformat(@x), "\n\n";
}

poly_option(root_function => 1);

foreach (@polyrootf_case)
{
	my @coef = reverse @$_;
	my $n = $#coef;
	my @x = poly_roots(@coef);
	my $cn_1 = -sumof(@x) * $coef[0];
	my $c0 = prodof(@x) * $coef[0];
	$c0 = -$c0 if ($n % 2 == 1);

	ok(allzeroes(\@coef, @x),
		"poly_roots with root_function: [ " . join(", ", @coef) . " ]");

	#print "\nmy \$cn_1 = $cn_1; \$coef[1] = ", $coef[1], "\n";
	#print "\nmy \$c0 = $c0; \$coef[$n] = ", $coef[$n], "\n";
	#print rootformat(@x), "\n\n";
}

poly_option(root_function => 1, hessenberg => 0);

foreach (@quadratic_case, @cubic_case, @quartic_case, @polyrootf_case)
{
	my @coef = reverse @$_;
	my $n = $#coef;
	my @x = poly_roots(@coef);
	my $cn_1 = -sumof(@x) * $coef[0];
	my $c0 = prodof(@x) * $coef[0];
	$c0 = -$c0 if ($n % 2 == 1);

	ok(allzeroes(\@coef, @x),
		"all: [ " . join(", ", @coef) . " ]");

	#print "\nmy \$cn_1 = $cn_1; \$coef[1] = ", $coef[1], "\n";
	#print "\nmy \$c0 = $c0; \$coef[$n] = ", $coef[$n], "\n";
	#print rootformat(@x), "\n\n";
}

1;
