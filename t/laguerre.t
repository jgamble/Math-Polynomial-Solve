# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl quartic.t'

use Test::Simple tests => 6;

use Math::Polynomial::Solve qw(laguerre poly_evaluate fltcmp);
use Math::Complex;
use strict;
use warnings;

require "t/coef.pl";

ok_laguerre([1, 2, -11, -12], [-4.5, 0.5, 2.5]);
ok_laguerre([12, 11, -2, -1], [-0.5, 0.3, -5]);
#ok_laguerre([1, 2, -11, -12], [-4.5, 0.5, 2.5]);
exit(0);

sub ok_laguerre
{
	my($c_ref, $est_ref) = @_;
	my @coef = @$c_ref;
	my @x = laguerre($c_ref, $est_ref);

	#rootprint(@x);

	foreach my $xv (@x)
	{
		my $yv = poly_evaluate($c_ref, $xv);
		ok( (fltcmp($yv, 0.0) == 0),
		"   [ " . join(", ", @coef) . " ], root == $xv");
	}
}

1;
